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
import ceylon.time {

	systemTime,
	Period,
	zero,
	DateTime
}
import ceylon.time.timezone {

	timeZone
}
import herd.schedule.chime.timer {
	definitions
}
import herd.schedule.chime.cron {
	
	calendar
}


"Scheduler - listen address of scheduler [[name]] on event bus and manages timers.
 This class is used internaly by Chime
 
 ### Requests
 
 Requests are send in [[JSON]] format on scheduler name address    
 	{  
 		\"operation\" -> String // operation code, mandatory  
 		\"name\" -> String // timer short or full name, mandatory  
 		\"state\" -> String // state, nonmandatory, except sate operation  
 		
 		// fields for create operation:
 		\"maximum count\" -> Integer // maximum number of fires, default - unlimited  
 		\"publish\" -> Boolean // if true message to be published and send otherwise, nonmandatory  
 
 		\"start time\" -> `JSON` // start time, nonmadatory, if doesn't exists timer will start immediately  
 		{  
 			\"seconds\" -> Integer // seconds, mandatory  
 			\"minutes\" -> Integer // minutes, mandatory  
 			\"hours\" -> Integer // hours, mandatory  
 			\"day of month\" -> Integer // days of month, mandatory  
 			\"month\" -> Integer or String // months, if string - short name, mandatory  
 			\"year\" -> Integer // year, Integer, mandatory  
 		}  
 
 		\"end time\" -> `JSON` // end time, nonmadatory, default no end time  
 		{  
 			\"seconds\" -> Integer // seconds, mandatory  
 			\"minutes\" -> Integer // minutes, mandatory  
 			\"hours\" -> Integer // hours, mandatory  
 			\"day of month\" -> Integer // days of month, mandatory  
 			\"month\" -> Integer or String // months, if string - short name, mandatory  
 			\"year\" -> Integer // year, Integer, mandatory  
 		}  
 
 		\"time zone\" -> String // time zone name, nonmandatory, default server local  

 		\"description\" -> JSON // timer desciption, mandatoty for create operation  
 	}  
 
 timer full name is *'scheduler name':'timer short name'*
 
 #### operation codes:  
 * \"create\" - create new timer with specified name, state and description
 * \"delete\" - delete timer with name `name`
 * \"info\" - get information on timer (if timer name is specified) or scheduler (if timer name is not specified)
 * \"state\":
		* if state field is \"get\" state is to be returned
		* if state field is \"running\" timer is to be run if not already
		* if state field is \"paused\" timer is to be paused if not already
		* otherwise error is returned
 
 #### supported timers (types):
 * cron style, defined like cron, but with some simplifications
 * incremental, fires after each specified period (minimum 1 second)
 
 #### timer description in depends on the timer type:
 
 * cron style timer description:  
 	{  
 		\"type\" -> String // timer type, mandatory  	
 
 		\"seconds\" -> String // seconds in cron style, mandatory  
 		\"minutes\" -> String // minutes in cron style, mandatory  
 		\"hours\" -> String // hours in cron style, mandatory  
 		\"day of month\" -> String // days of month in cron style, mandatory  
 		\"month\" -> String // months in cron style, mandatory  
 		\"day of week\" -> String // days of week in cron style, L means last, # means nth of month, nonmandatory  
 		\"year\" -> String // year in cron style, nonmandatory   		
 	}  
 
 * interval timer description:  
 	{  
 		\"type\" -> String // timer type, mandatory  	
 		\"delay\" -> Integer // timer delay in seconds, if <= 0 timer fires only once, mandatory
 	}

  
 ### Response.
 
 Scheduler responses on each request in [[JSON]] format:  
 	{  
 		\"response\" -> String // response code - one of `ok` or `error`  
 		\"name\" -> String //  timer name  
 		\"state\" -> String // state  
 		
 		\"error\" -> String // error description, exists only if response == `error`
 		\"timers\" -> JSONArray // list of timer names currently scheduled - response on info operation with no name field specified
 		
 		// Info operation returns fields from create operation also
 	}  
 
 "
by( "Lis" )
class TimeScheduler(
	"Scheduler name." shared String name,
	"Vertx the scheduler operates on." Vertx vertx,
	"EventBus to pass messages." EventBus eventBus,
	"Factory to create timers." TimerCreator factory,
	"Tolerance to compare fire time and current time in miliseconds." Integer tolerance 
	)
		extends Operator( eventBus )
{
	
	"Tolerance to compare fire time."
	variable Period tolerancePeriod = zero.plusMilliseconds( tolerance );
	
	"Timers sorted by next fire time."
	HashMap<String, TimerContainer> timers = HashMap<String, TimerContainer>();
	
	"Id of vertx timer."
	variable Integer? timerID = null;
	
	"Value for scheduler state - running, paused or completed."
	variable TimerState schedulerState = timerPaused;
	
	"Scheduler state - running, paused or completed."
	shared TimerState state => schedulerState;
	
	"Scheduler `JSON` short info (name and state)."
	shared JSON shortInfo
			=> JSON {
				definitions.fieldName -> name,
				definitions.fieldState -> schedulerState.string
			};
	
	"Scheduler full info in `JSON`:
	 	\"response\" -> ok,
	 	\"name\" -> scheduler name,
	 	\"state\" -> scheduler state
	 	\"timers\" -> array of timer names
	 "
	shared JSON fullInfo => JSON {
		definitions.fieldResponse -> definitions.responseOK,
		definitions.fieldName -> name,
		definitions.fieldState -> state.string,
		definitions.fieldTimers -> JSONArray( { for ( timer in timers.items ) timer.name } )
	};
	
		
// timers map methods
	
	"`true` if timer is running."
	Boolean selectRunning( TimerContainer timer ) => timer.state == timerRunning;
	
	"`true` if timer is completed."
	Boolean selectCompleted( TimerContainer timer ) => timer.state == timerCompleted;
	
	"`true` if timer is running or paused."
	Boolean selectIncompleted( TimerContainer timer ) => timer.state != timerCompleted;
	
	"Name of the given timer."
	String timerName( TimerContainer timer ) => timer.name;
	
	"Remove completed timers."
	void removeCompleted() => timers.removeAll( timers.items.filter( selectCompleted ).map( timerName ) );
	
	
	"Minimum timer delay."
	Integer minDelay() {
		DateTime current = localTime();
		variable Integer delay = 0;
		for ( timer in timers.items.filter( selectRunning ) ) {
			if ( exists localDate = timer.localFireTime ) {
				Integer offset = localDate.offset( current );
				if ( offset <= 0 ) {
					if ( delay > 500 || delay == 0 ) {
						delay = 500;
					}
				}
				else if ( offset < delay || delay == 0 ) {
					delay = offset;
				}
			}
		}
		return delay;
	}
	
	"Current local time."
	DateTime localTime() => systemTime.instant().dateTime( timeZone.system );
	
	"Fire timers, returns `true` if some timer has been fired and `false` if no one timer has been fired."
	void fireTimers() {
		variable Boolean completed = false;
		DateTime current = localTime().plus( tolerancePeriod );
		for ( timer in timers.items.filter( selectRunning ) ) {
			if ( exists localDate = timer.localFireTime, exists remoteDate = timer.remoteFireTime ) {
				if ( localDate < current ) {
					timer.shiftTime();
					sendTimerMessage( timer, remoteDate );
					if ( timer.state == timerCompleted ) {
						sendTimerMessage( timer );
						completed = true;
					}
				}
			}
		}
		if ( completed ) {
			removeCompleted();
		}
	}
	
	"Sends fire or completed message in standard Chime format.
	 
	 message format:  
	 {  
	 	\"name\": timer name, String   
	 	\"time\": String formated time / date from [[TimerContainer.remoteFireTime]] or nothing if not specified   
	 	\"count\": total number of fire times  
	 	\"state\": String representation of [[TimerContainer.state]]   
	 }
	 "
	shared void sendTimerMessage( TimerContainer timer, DateTime? date = null ) {
		JSON message;
		
		// date string
		if ( exists date ) {
			message = JSON {
				definitions.fieldName -> timer.name,
				definitions.fieldTime -> date.string,
				definitions.fieldCount -> timer.count,
				definitions.fieldState -> timer.state.string,
				calendar.seconds -> date.seconds,
				calendar.minutes -> date.minutes,
				calendar.hours -> date.hours,
				calendar.dayOfMonth -> date.day,
				calendar.month -> date.month.integer,
				calendar.year -> date.year,
				definitions.timeZoneID -> timer.timeZoneID
			};
		}
		else {
			message = JSON {
				definitions.fieldName -> timer.name,
				definitions.fieldCount -> timer.count,
				definitions.fieldState -> timer.state.string
			};
		}
		
		// send message
		if ( timer.publish ) {
			eventBus.publish( timer.name, message );
		}
		else {
			eventBus.send( timer.name, message );
		}
	}


// vertx timer

	"Cancels current vertx timer."
	void cancelCurrentVertxTimer() {
		if ( exists id = timerID ) {
			timerID = null;
			vertx.cancelTimer( id );
		}
	}
	
	"Builds vertx timer using min delay."
	void buildVertxTimer() {
		cancelCurrentVertxTimer();
		Integer delay = minDelay();
		if ( delay > 0 ) {
			timerID = vertx.setTimer( delay, vertxTimerFired );
		}
	}
	
	"Vertx timer has been fired - send message and use next vertx timer."
	void vertxTimerFired( Integer id ) {
		if ( state == timerRunning, exists currentID = timerID, currentID == id ) {
			timerID = null;
			fireTimers();
			buildVertxTimer();
		}
	}
	
	
// operations	

	"Returns timer full name from short name."
	String timerFullName( String timerShortName ) {
		if ( timerShortName.startsWith( name + definitions.nameSeparator ) ) {
			return timerShortName;
		}
		else {
			return name + definitions.nameSeparator + timerShortName;
		}
	}
	
	"Adds timer to timers - to be added according to next fire time sort.
	 If timer has been added previously it will be replaced."
	void addTimer (
		"timer to be added" TimerContainer timer,
		"timer state" TimerState state )
	{
		if ( state == timerRunning ) {
			timer.start( localTime() );
			if ( timer.state == timerRunning ) {
				timers.put( timer.name, timer );
				buildVertxTimer();
			}
			else {
				sendTimerMessage( timer );
			}
		}
		else if ( state == timerPaused ) {
			timers.put( timer.name, timer );
		}
	}

	
	"Creates operators map."
	shared actual Map<String, Anything(Message<JSON>)> createOperators()
			=> map<String, Anything(Message<JSON>)> {
				definitions.opCreate -> operationCreate,
				definitions.opDelete -> operationDelete,
				definitions.opState -> operationState,
				definitions.opInfo -> operationInfo
			};

	"Creates new timer."
	shared void operationCreate( Message<JSON> msg ) {
		if ( exists request = msg.body(), is String tName = request.get( definitions.fieldName ) ) {
			String timerName = timerFullName( tName );
			if ( timers.defines( timerName ) ) {
				// timer already exists
				failMessage( msg, errorMessages.timerAlreadyExists );
			}
			else {
				value timer = factory.createTimer( timerFullName( tName ), request );
				if ( is TimerContainer timer ) {
					addTimer( timer, extractState( request ) else timerRunning );
					// timer successfully added
					respondMessage( msg, timer.stateDescription() );
				}
				else {
					// wrong description
					failMessage( msg, timer );
				}
			}
		}
		else {
			// timer name to be specified
			failMessage( msg, errorMessages.timerNameHasToBeSpecified );
		}
		
	}
	
	"Deletes existing timer."
	shared void operationDelete( Message<JSON> msg ) {
		if ( exists request = msg.body(), is String tName = request.get( definitions.fieldName ) ) {
			String timerName = timerFullName( tName );
			// delete timer
			if ( exists t = timers.remove( timerName ) ) {
				t.complete();
				// timer successfully removed
				respondMessage( msg, t.stateDescription() );
			}
			else {
				// timer doesn't exist
				failMessage( msg, errorMessages.timerNotExists );
			}
		}
		else {
			// timer name to be specified
			failMessage( msg, errorMessages.timerNameHasToBeSpecified );
		}
	}
	
	"Processes 'timer state' operation."
	shared void operationState( Message<JSON> msg ) {
		if ( exists request = msg.body(), is String tName = request.get( definitions.fieldName ) ) {
			 if ( is String state = request.get( definitions.fieldState ) ) {
				String timerName = timerFullName( tName );
				if ( exists t = timers.get( timerName ) ) {
					if ( state == definitions.stateGet ) {
						// return state
						respondMessage( msg, t.stateDescription() );
					}
					else if ( state == timerPaused.string ){
						// set paused state
						t.state = timerPaused;
						respondMessage( msg, t.stateDescription() );
					}
					else if ( state == timerRunning.string ) {
						// set running state
						if ( t.state == timerPaused ) {
							t.start( localTime() );
							if ( t.state == timerRunning ) {
								buildVertxTimer();
							}
							else {
								timers.remove( t.name );
								sendTimerMessage( t );
							}
						}
						respondMessage( msg, t.stateDescription() );
					}
					else {
						// state to be one of - get, paused, running
						failMessage( msg, errorMessages.incorrectTimerState );
					}
				}
				else {
					// timer doesn't exist
					failMessage( msg, errorMessages.timerNotExists );
				}
			}
			else {
				// timer state to be specified
				failMessage( msg, errorMessages.stateToBeSpecified );
			}
		}
		else {
			// timer name to be specified
			failMessage( msg, "timer name has to be specified" );
		}
	}
		
	"Replies with scheduler info - array of timer names."
	shared void operationInfo( Message<JSON> msg ) {
		if ( exists request = msg.body(), is String tName = request.get( definitions.fieldName ) ) {
			// contains name field - reply with info about timer with specified name
			String timerName = timerFullName( tName );
			if ( exists t = timers.get( timerName ) ) {
				// timer successfully removed
				respondMessage( msg, t.fullDescription() );
			}
			else {
				// timer doesn't exist
				failMessage( msg, errorMessages.timerNotExists );
			}
		}
		else {
			// timer name to be specified
			failMessage( msg, errorMessages.timerNameHasToBeSpecified );
		}
	}

	
// scheduler methods
	
	"Starts scheduling."
	see( `function pause` )
	see( `function stop` )
	shared void start() {
		if ( state != timerRunning ) {
			schedulerState = timerRunning;
			DateTime current = localTime();
			for ( timer in timers.items.filter( selectRunning ) ) {
				timer.start( current );
				if ( timer.state == timerCompleted ) {
					sendTimerMessage( timer );
				}
			}
			removeCompleted();
			buildVertxTimer();
		}
	}
	
	"Pauses scheduling - all fires to be missed while start not called."
	see( `function start` )
	shared void pause() {
		schedulerState = timerPaused;
		cancelCurrentVertxTimer();
	}
	
	"Completes all timers and terminates this scheduler."
	shared void stop() {
		schedulerState = timerCompleted;
		
		// fire completed on all timers
		for ( timer in timers.items.filter( selectIncompleted ) ) {
			timer.complete();
			sendTimerMessage( timer );
		}
		timers.clear();
		
		cancelCurrentVertxTimer();
	}
	
}
