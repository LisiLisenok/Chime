import io.vertx.ceylon.core.eventbus {
	Message,
	EventBus
}
import ceylon.json {
	JSON=Object,
	JSONArray=Array
}


"Connects to scheduler. If scheduler has not been created yet then new one is created."
see( `interface Scheduler` )
throws( `class AssertionError`, "scheduler name contains ':'" )
tagged( "Proxy" )
since( "0.2.0" ) by( "Lis" )
shared void connectToScheduler (
	"Handler to receive created scheduler or error if occured."
	Anything( Throwable|Scheduler ) handler,
	"Address to call _Chime_." String shimeAddress,
	"Event bus to send message to _Chime_." EventBus eventBus,
	"Name of the scheduler to be connected or created.  
	 Must not contain ':' symbol, since it separates scheduler and timer names."
	String name,
	"`True` if new scheduler is paused and `false` if running.  
	 If scheduler has been created early its state is not changed."
	Boolean paused = false
) {
	"Scheduler name must not contain ``Chime.configuration.nameSeparator``, since it separates scheduler and timer names."
	assert( !name.contains( Chime.configuration.nameSeparator ) );
	
	eventBus.send<JSON> (
		shimeAddress,
		JSON {
			Chime.key.operation -> Chime.operation.create,
			Chime.key.name -> name,
			Chime.key.state -> ( if ( paused ) then Chime.state.paused else Chime.state.running )
		},
		( Throwable | Message<JSON?> msg ) {
			if ( is Message<JSON?> msg ) {
				"Chime has to respond with non-optional message."
				assert( exists ret = msg.body() );
				handler( SchedulerImpl( ret.getString( Chime.key.name ), eventBus ) );
			}
			else {
				handler( msg );
			}
		}
	);
}


"Returns info on the given schedulers."
tagged( "Proxy" )
see( `function Scheduler.timersInfo`, `function Scheduler.info` )
since( "0.2.0" ) by( "Lis" )
shared void schedulerInfo (
	"Handler to receive scheduler infos or error if occured."
	Anything( Throwable|SchedulerInfo[] ) handler,
	"Address to call _Chime_."
	String shimeAddress,
	"Event bus to send message to _Chime_."
	EventBus eventBus,
	"List of scheduler name, the info to be requested for.  
	 If empty then info on all schedulers are requested."
	String* names
) {
	JSON request = JSON {
		Chime.key.operation -> Chime.operation.info
	};
	if ( !names.empty ) {
		request.put( Chime.key.name, JSONArray( names ) );
	}
	eventBus.send (
		shimeAddress, request,
		( Throwable|Message<JSON?> msg ) {
			if ( is Message<JSON?> msg ) {
				"Reply from scheduler request has not to be null."
				assert( exists ret = msg.body() );
				value sch = ret.getArray( Chime.key.schedulers );
				handler( [for ( item in sch.narrow<JSON>() ) SchedulerInfo.fromJSON( item )] );
			}
			else {
				handler( msg );
			}
		}
	);
}


"Deletes schedulers or timers with the given names."
tagged( "Proxy" )
see( `function Scheduler.deleteTimers`, `function Scheduler.delete` )
since( "0.2.1" ) by( "Lis" )
shared void delete (
	"Address to call _Chime_."
	String shimeAddress,
	"Event bus to send message to _Chime_."
	EventBus eventBus,
	"List of scheduler or timer names.  
	 If empty then every scheduler and timer have to be deleted."
	{String*} names = {},
	"Optional handler called with a list of names of actually deleted schedulers or timers."
	Anything( Throwable|{String*} )? handler = null
) {
	JSON request = JSON {
		Chime.key.operation -> Chime.operation.delete,
		Chime.key.name -> ( if ( names.empty ) then "" else JSONArray( names ) )
	};
	if ( exists handler ) {
		eventBus.send (
			shimeAddress, request,
			( Throwable|Message<JSON?> msg ) {
				if ( is Message<JSON?> msg ) {
					"Reply from scheduler request has not to be null."
					assert( exists ret = msg.body() );
					handler (
						ret.getArray( Chime.key.schedulers ).narrow<String>()
							.chain( ret.getArray( Chime.key.timers ).narrow<String>() )
					);
				}
				else {
					handler( msg );
				}
			}
		);
	}
	else {
		eventBus.send( shimeAddress, request );		
	}
}
