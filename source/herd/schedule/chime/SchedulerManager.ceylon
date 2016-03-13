import io.vertx.ceylon.core {

	Vertx
}
import io.vertx.ceylon.core.eventbus {

	Message,
	EventBus
}
import ceylon.json {
	
	JSON=Object,
	JSONArray=Array
}
import ceylon.collection {

	HashMap
}
import herd.schedule.chime.timer {
	TimerFactory,
	definitions
}


"manages shcedulers - [[TimeScheduler]]:
 * creates
 * deletes
 * starts
 * pauses
 * schedulers info
 
 Instances of the class are used internaly by Chime.  
 All operations performed as response on request send to general Chime address, \"chime\" by default.
 Or specified in configuration file.
 Scheduler to be created before any operations with timers requested.
 
 ### Requesting:  
 
 expects messages in `JSON` format:  
 	{  
 		\"operation\" -> String // operation code, mandatory  
 		\"name\" -> String // scheduler or full timer (\"scheduler name:timer name\") name, mandatory   
 		\"state\" -> String // state, mandatory only for state operation   
 	} 
 
 If timer name specified as *\"scheduler name:timer name\"* operation is performed for timer - 
 see description in [[TimeScheduler]] otherwise for scheduler - see description below.
 
 #### operation codes: 
 * \"create\" - create new scheduler with specified name, state and description, if state is not specified, sceduler to be run.
   If full timer name specified *`scheduler name`:`timer name`* timer is to be created, if no scheduler with \"scheduler name\"
   has been created before, it will be created.
 * \"delete\" - delete scheduler with name `name` (or timer if full timer name specified *\"scheduler name:timer name\"*)
 * \"info\" - requesting info on Chime, specific scheduler (scheduler name to be provided) or
 timer (full timer name specified *\"scheduler name:timer name\"* to be provided)
 * \"state\":
 	* if is \"get\" state is to be returned
 	* if is \"running\" scheduler is to be run if not already
 	* if is \"paused\" scheduler is to be paused if not already
 	* otherwise error is returned

 #### examples:
 	// create new scheduler with name \"scheduler name\"
 	JSON message = JSON { 
 		\"operation\" -> \"create\", 
 		\"name\" -> \"scheduler name\" 
 	} 
  	
  	// change state of scheduler with \"scheduler name\" on paused
 	JSON message = JSON { 
 		\"operation\" -> \"state\", 
 		\"name\" -> \"scheduler name\",  
 		\"state\" -> \"paused\"
 	} 
 	
 ### Response  
 response on messages is in `JSON`:  
 	{  
 		\"response\" -> String // response code - one of \"ok\" or \"error\"  
 		\"name\" -> String // scheduler or full timer (\"scheduler name:timer name\") name  
 		\"state\" -> String // scheduler state  
 		\"schedulers\" -> JSONArray // scheduler names, exists as response on \"info\" operation with no \"name\" field  
 		\"error\" -> String // error description, exists only if response == \"error\"
 	} 

 "
by( "Lis" )
see(`class TimeScheduler`)
class SchedulerManager(
	"Vetrx the scheduler is running on." Vertx vertx,
	"Event bus used to dispatch messages." EventBus eventBus,
	"Factory to create timers" TimerFactory factory,
	"Tolerance to compare fire time and current time in miliseconds." Integer tolerance 
)
		extends Operator( eventBus )
{
	
	"Time schedulers."
	HashMap<String, TimeScheduler> schedulers = HashMap<String, TimeScheduler>();
	
	TimerCreator creator = TimerCreator( factory );
	
	"Returns scheduler by its name or `null` if doesn't exist."
	shared TimeScheduler? getScheduler( "Name of the scheduler looked for." String name ) => schedulers.get( name );
	
	"Adds new scheduler.  
	 Retruns new or already existed shceduler with name `name`."
	shared TimeScheduler addScheduler( "Scheduler name." String name, "Scheduler state." TimerState state ) {
		if ( exists sch = getScheduler( name ) ) {
			return sch;
		}
		else {
			TimeScheduler sch = TimeScheduler( name, vertx, eventBus, creator, tolerance );
			schedulers.put( name, sch );
			sch.connect( name );
			if ( state == timerRunning ) {
				sch.start();
			}
			return sch;
		}
	}
	
	
// operation methods
	
	"Creates operators map"
	shared actual Map<String, Anything(Message<JSON>)> createOperators()
			=> map<String, Anything(Message<JSON>)> {
				definitions.opCreate -> operationCreate,
				definitions.opDelete -> operationDelete,
				definitions.opState -> operationState,
				definitions.opInfo -> operationInfo
			};
	
	"Processes 'create new scheduler' operation."
	void operationCreate( Message<JSON> msg ) {
		if ( exists request = msg.body(), is String name = request.get( definitions.fieldName ) ) {
			
			String schedulerNamer;
			String timerName;
			if ( exists inc = name.firstInclusion( definitions.nameSeparator ) ) {
				schedulerNamer = name.spanTo( inc - 1 );
				timerName = name;
			}
			else {
				schedulerNamer = name;
				timerName = "";
			}
			value scheduler = addScheduler( schedulerNamer, extractState( request ) else timerRunning );
			if ( timerName.empty ) {
				failMessage( msg, errorMessages.timerAlreadyExists );
			}
			else {
				// add timer to scheduler
				scheduler.operationCreate( msg );
			}
		}
		else {
			// response with wrong format error
			failMessage( msg, errorMessages.schedulerNameHasToBeSpecified );
		}
	}
	
	"Processes 'delete scheduler' operation."
	void operationDelete( Message<JSON> msg ) {
		if ( exists request = msg.body(), is String name = request.get( definitions.fieldName ) ) {
			// delete scheduler
			if ( exists sch = schedulers.remove( name ) ) {
				sch.stop();
				// scheduler successfully removed
				respondMessage( msg, sch.shortInfo );
			}
			else {
				// scheduler doesn't exists - look if name is full timer name
				value schedulerName = name.spanTo( ( name.firstInclusion( definitions.nameSeparator ) else 0 ) - 1 );
				if ( !schedulerName.empty, exists sch = schedulers.get( schedulerName ) ) {
					// scheduler has to remove timer
					sch.operationDelete( msg );
				}
				else {
					// scheduler or timer doesn't exist
					failMessage( msg, errorMessages.schedulerNotExists );
				}
			}
		}
		else {
			// response with wrong format error
			failMessage( msg, errorMessages.schedulerNameHasToBeSpecified );
		}
	}
	
	"Processes 'scheduler state' operation."
	void operationState( Message<JSON> msg ) {
		if ( exists request = msg.body(), is String name = request.get( definitions.fieldName ) ) {
			if ( is String state = request.get( definitions.fieldState ) ) {
				if ( exists sch = schedulers.get( name ) ) {
					if ( state == definitions.stateGet ) {
						// return state
						respondMessage( msg, sch.shortInfo );
					}
					else if ( state == timerPaused.string ){
						// set paused state
						sch.pause();
						respondMessage( msg, sch.shortInfo );
					}
					else if ( state == timerRunning.string ){
						// set running state
						sch.start();
						respondMessage( msg, sch.shortInfo );
					}
					else {
						// state to be one of - get, paused, running
						failMessage( msg, errorMessages.incorrectTimerState );
					}
				}
				else {
					// scheduler doesn't exists - look if name is full timer name
					value schedulerName = name.spanTo( ( name.firstInclusion( definitions.nameSeparator ) else 0 ) - 1 );
					if ( !schedulerName.empty, exists sch = schedulers.get( schedulerName ) ) {
						// scheduler has to provide timer state
						sch.operationState( msg );
					}
					else {
						// scheduler or timer doesn't exist
						failMessage( msg, errorMessages.schedulerNotExists );
					}
				}
			}
			else {
				// scheduler state to be specified
				failMessage( msg, errorMessages.stateToBeSpecified );
			}
		}
		else {
			// scheduler name to be specified
			failMessage( msg, errorMessages.schedulerNameHasToBeSpecified);
		}
	}
	
	"Replies with Chime info - array of scheduler names."
	void operationInfo( Message<JSON> msg ) {
		if ( is String name = msg.body()?.get( definitions.fieldName ) ) {
			if ( exists sch = schedulers.get( name ) ) {
				// reply with scheduler info
				msg.reply( sch.fullInfo );
			}
			else {
				// scheduler doesn't exists - look if name is full timer name
				value schedulerName = name.spanTo( ( name.firstInclusion( definitions.nameSeparator ) else 0 ) - 1 );
				if ( !schedulerName.empty, exists sch = schedulers.get( schedulerName ) ) {
					// scheduler has to reply for timer info
					sch.operationInfo( msg );
				}
				else {
					// scheduler or timer doesn't exist
					failMessage( msg, errorMessages.schedulerNotExists );
				}
			}
		}
		else {
			msg.reply (
				JSON {
					definitions.fieldResponse -> definitions.responseOK,
					definitions.fieldSchedulers -> JSONArray( { for ( scheduler in schedulers.items ) scheduler.name } )
				}
			);
		}
	}
	
}