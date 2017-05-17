import io.vertx.ceylon.core.eventbus {
	EventBus,
	DeliveryOptions
}
import ceylon.json {
	JsonObject,
	JsonArray,
	ObjectValue
}


"Connects to already existed scheduler."
see( `interface Scheduler` )
throws( `class AssertionError`, "scheduler name contains ':'" )
tagged( "Proxy" )
since( "0.2.0" ) by( "Lis" )
shared void connectScheduler (
	"Handler to receive created scheduler or error if occured."
	Anything( Throwable|Scheduler ) handler,
	"Address to call _Chime_." String shimeAddress,
	"Event bus to send message to _Chime_." EventBus eventBus,
	"Name of the scheduler to be connected or created.  
	 Must not contain ':' symbol, since it separates scheduler and timer names."
	String name,
	"Timeout to send message with."
	Integer? sendTimeout = null
) {
	"Scheduler name must not contain ``Chime.configuration.nameSeparator``, since it separates scheduler and timer names."
	assert( !name.contains( Chime.configuration.nameSeparator ) );
	JsonObject request = JsonObject {
		Chime.key.operation -> Chime.operation.info,
		Chime.key.name -> name
	};
	if ( exists sendTimeout ) {
		eventBus.send<JsonObject> (
			shimeAddress, request, DeliveryOptions( null, null, sendTimeout ),
			SchedulerImpl.createSchedulerImpl( handler, eventBus, sendTimeout )
		);
	}
	else {
		eventBus.send<JsonObject> (
			shimeAddress, request,
			SchedulerImpl.createSchedulerImpl( handler, eventBus, sendTimeout )
		);
	}
	
}


"Creates new scheduler or connects to already existed scheduler."
see( `interface Scheduler` )
throws( `class AssertionError`, "scheduler name contains ':'" )
tagged( "Proxy" )
since( "0.2.0" ) by( "Lis" )
shared void createScheduler (
	"Handler to receive created scheduler or error if occured."
	Anything( Throwable|Scheduler ) handler,
	"Address to call _Chime_." String shimeAddress,
	"Event bus to send message to _Chime_." EventBus eventBus,
	"Name of the scheduler to be connected or created.  
	 Must not contain ':' symbol, since it separates scheduler and timer names."
	String name,
	"`True` if new scheduler is paused and `false` if running.  
	 If scheduler has been created early its state is not changed."
	Boolean paused = false,
	"Optional time zone default for the scheduler."
	String? timeZone = null,
	"Optional time zone provider, default is \"jvm\"."
	String? timeZoneProvider = null,
	"Optional message source type default for the scheduler."
	String? messageSource = null,
	"Optional configuration passed to message source factory."
	ObjectValue? messageSourceConfig = null,
	"Default delivery options a timer fire event has to be sent with."
	DeliveryOptions? deliveryOptions = null,
	"Timeout to send message with."
	Integer? sendTimeout = null
) {
	"Scheduler name must not contain ``Chime.configuration.nameSeparator``, since it separates scheduler and timer names."
	assert( !name.contains( Chime.configuration.nameSeparator ) );
	JsonObject request = JsonObject {
		Chime.key.operation -> Chime.operation.create,
		Chime.key.name -> name,
		Chime.key.state -> ( if ( paused ) then Chime.state.paused else Chime.state.running )
	};
	if ( exists timeZone ) {
		request.put( Chime.key.timeZone, timeZone );
		if ( exists timeZoneProvider ) {
			request.put( Chime.key.timeZoneProvider, timeZoneProvider );
		}
	}
	if ( exists messageSource ) {
		request.put( Chime.key.messageSource, messageSource );
		if ( exists messageSourceConfig ) {
			request.put( Chime.key.messageSourceConfig, messageSourceConfig );
		}
	}
	if ( exists deliveryOptions ) {
		request.put( Chime.key.deliveryOptions, deliveryOptions.toJson() );
	}
	
	if ( exists sendTimeout ) {
		eventBus.send<JsonObject> (
			shimeAddress, request, DeliveryOptions( null, null, sendTimeout ),
			SchedulerImpl.createSchedulerImpl( handler, eventBus, sendTimeout )
		);
	}
	else {
		eventBus.send<JsonObject> (
			shimeAddress, request, SchedulerImpl.createSchedulerImpl( handler, eventBus, sendTimeout )
		);
	}
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
	{String*} names = {},
	"Timeout to send message with."
	Integer? sendTimeout = null
	
) {
	JsonObject request = JsonObject {
		Chime.key.operation -> Chime.operation.info
	};
	if ( !names.empty ) {
		request.put( Chime.key.name, JsonArray( names ) );
	}
	
	if ( exists sendTimeout ) {
		eventBus.send<JsonObject> (
			shimeAddress, request, DeliveryOptions( null, null, sendTimeout ),
			SchedulerImpl.replyWithInfo( handler )
		);
	}
	else {
		eventBus.send<JsonObject> (
			shimeAddress, request, SchedulerImpl.replyWithInfo( handler )
		);
	}
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
	Anything( Throwable|{String*} )? handler = null,
	"Timeout to send message with."
	Integer? sendTimeout = null
) {
	JsonObject request = JsonObject {
		Chime.key.operation -> Chime.operation.delete,
		Chime.key.name -> ( if ( names.empty ) then "" else JsonArray( names ) )
	};
	if ( exists handler ) {
		if ( exists sendTimeout ) {
			eventBus.send<JsonObject> (
				shimeAddress, request, DeliveryOptions( null, null, sendTimeout ),
				SchedulerImpl.replyWithList( handler, Chime.key.schedulers )
			);
		}
		else {
			eventBus.send<JsonObject> (
				shimeAddress, request, SchedulerImpl.replyWithList( handler, Chime.key.schedulers )
			);
		}
	}
	else {
		if ( exists sendTimeout ) {
			eventBus.send( shimeAddress, request, DeliveryOptions( null, null, sendTimeout ) );
		}
		else {
			eventBus.send( shimeAddress, request );	
		}
	}
}
