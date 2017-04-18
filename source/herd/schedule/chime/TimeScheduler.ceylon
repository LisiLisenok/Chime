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
since( "0.1.0" ) by( "Lis" )
class TimeScheduler(
	"Scheduler name." shared String name,
	"Vertx the scheduler operates on." Vertx vertx,
	"EventBus to pass messages." EventBus eventBus,
	"Factory to create timers." TimerCreator factory,
	"Tolerance to compare fire time and current time in miliseconds." Integer tolerance 
	)
		extends Operator( eventBus )
{
		
	"Next ID used when no timer name specified."
	variable Integer nextID = 0;
		
	String nameWithSeparator = name + Chime.configuration.nameSeparator;
		
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
				Chime.key.name -> name,
				Chime.key.state -> schedulerState.string
			};
	
	"Scheduler full info in `JSON`:
	 	\"response\" -> ok,
	 	\"name\" -> scheduler name,
	 	\"state\" -> scheduler state
	 	\"timers\" -> array of timer names
	 "
	shared JSON fullInfo => JSON {
		Chime.key.name -> name,
		Chime.key.state -> state.string,
		Chime.key.timers -> JSONArray( { for ( timer in timers.items ) timer.name } )
	};
	
	
	"Generates unique name for the timer."
	String generateUniqueName() {
		while ( timers.contains( ( ++ nextID ).string ) ) {}
		return nextID.string;
	}
	
// timers map methods
	
	"`true` if timer is completed."
	Boolean selectCompleted( TimerContainer timer ) => timer.state == timerCompleted;
	
	"Name of the given timer."
	String timerName( TimerContainer timer ) => timer.name;
	
	"Remove completed timers."
	void removeCompleted() => timers.removeAll( timers.items.filter( selectCompleted ).map( timerName ) );
	
	
	"Minimum timer delay."
	Integer minDelay() {
		DateTime current = localTime();
		variable Integer delay = 0;
		for ( timer in timers.items ) {
			if ( timer.state == timerRunning, exists localDate = timer.localFireTime ) {
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
		for ( timer in timers.items ) {
			if ( timer.state == timerRunning,
				 exists localDate = timer.localFireTime,
				 exists remoteDate = timer.remoteFireTime
			) {
				if ( localDate < current ) {
					timer.shiftTime();
					sendFireEvent( timer, remoteDate );
					if ( timer.state == timerCompleted ) {
						sendCompleteEvent( timer );
						completed = true;
					}
				}
			}
		}
		if ( completed ) {
			removeCompleted();
		}
	}
	
	"Sends fire event in standard Chime format.
	 
	 message format:  
	 {  
	 	\"name\": timer name, String   
	 	\"event\": \"fire\"
	 	\"time\": String formated time / date from [[TimerContainer.remoteFireTime]] or nothing if not specified   
	 	\"count\": total number of fire times  
	 }
	 "
	shared void sendFireEvent( TimerContainer timer, DateTime date ) {
		JSON message = JSON {
			Chime.key.event -> Chime.event.fire,
			Chime.key.name -> timer.name,
			Chime.key.time -> date.string,
			Chime.key.count -> timer.count,
			Chime.date.seconds -> date.seconds,
			Chime.date.minutes -> date.minutes,
			Chime.date.hours -> date.hours,
			Chime.date.dayOfMonth -> date.day,
			Chime.date.month -> date.month.integer,
			Chime.date.year -> date.year,
			Chime.key.timeZone -> timer.timeZoneID
		};
		// send message
		if ( timer.publish ) {
			eventBus.publish( timer.name, message );
		}
		else {
			eventBus.send( timer.name, message );
		}
	}
	
	"Sends complete event in standard Chime format.
	 
	 message format:  
	 {  
	 	\"name\": timer name, String   
	 	\"event\": \"complete\"
	 	\"count\": total number of fire times  
	 }
	 "
	shared void sendCompleteEvent( TimerContainer timer ) {
		JSON message = JSON {
			Chime.key.event -> Chime.event.complete,
			Chime.key.name -> timer.name,
			Chime.key.count -> timer.count
		};
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
		if ( timerShortName.startsWith( nameWithSeparator ) && timerShortName.size > nameWithSeparator.size ) {
			return timerShortName;
		}
		else {
			return nameWithSeparator + timerShortName;
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
				sendCompleteEvent( timer );
			}
		}
		else if ( state == timerPaused ) {
			timers.put( timer.name, timer );
		}
	}

	
	"Creates operators map."
	shared actual Map<String, Anything(Message<JSON?>)> createOperators()
			=> map<String, Anything(Message<JSON?>)> {
				Chime.operation.create -> operationCreate,
				Chime.operation.delete -> operationDelete,
				Chime.operation.state -> operationState,
				Chime.operation.info -> operationInfo
			};

	"Creates new timer."
	shared void operationCreate( Message<JSON?> msg ) {
		if ( exists request = msg.body(), request.defines( Chime.key.description ) ) {
			String timerName;
			if ( is String tName = request[Chime.key.name] ) {
				if ( tName.startsWith( nameWithSeparator ) && tName.size > nameWithSeparator.size ) {
					timerName = tName;
				}
				else {
					timerName = nameWithSeparator + generateUniqueName();
				}
			}
			else {
				// timer name is not specified - generate unique name
				timerName = nameWithSeparator + generateUniqueName();
			}
			if ( timers.defines( timerName ) ) {
				// timer already exists
				msg.fail( errorMessages.codeTimerAlreadyExists, errorMessages.timerAlreadyExists );
			}
			else {
				value timer = factory.createTimer( timerName, request );
				if ( is TimerContainer timer ) {
					addTimer( timer, extractState( request ) else timerRunning );
					// timer successfully added
					msg.reply( timer.stateDescription() );
				}
				else {
					// wrong description
					msg.fail( 0, timer );
				}
			}
		}
		else {
			// timer name to be specified
			msg.fail( errorMessages.codeTimerDescriptionHasToBeSpecified, errorMessages.timerDescriptionHasToBeSpecified );
		}
		
	}
	
	"Deletes existing timer."
	shared void operationDelete( Message<JSON?> msg ) {
		if ( exists request = msg.body(), is String tName = request[Chime.key.name] ) {
			String timerName = timerFullName( tName );
			// delete timer
			if ( exists t = timers.remove( timerName ) ) {
				t.complete();
				// timer successfully removed
				msg.reply( t.stateDescription() );
			}
			else {
				// timer doesn't exist
				msg.fail( errorMessages.codeTimerNotExists, errorMessages.timerNotExists );
			}
		}
		else {
			// timer name to be specified
			msg.fail( errorMessages.codeTimerNameHasToBeSpecified, errorMessages.timerNameHasToBeSpecified );
		}
	}
	
	"Processes 'timer state' operation."
	shared void operationState( Message<JSON?> msg ) {
		if ( exists request = msg.body(), is String tName = request[Chime.key.name] ) {
			 if ( is String state = request[Chime.key.state] ) {
				String timerName = timerFullName( tName );
				if ( exists t = timers[timerName] ) {
					if ( state == Chime.state.get ) {
						// return state
						msg.reply( t.stateDescription() );
					}
					else if ( state == timerPaused.string ){
						// set paused state
						t.state = timerPaused;
						msg.reply( t.stateDescription() );
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
								sendCompleteEvent( t );
							}
						}
						msg.reply( t.stateDescription() );
					}
					else {
						// state to be one of - get, paused, running
						msg.fail( errorMessages.codeIncorrectTimerState, errorMessages.incorrectTimerState );
					}
				}
				else {
					// timer doesn't exist
					msg.fail( errorMessages.codeTimerNotExists, errorMessages.timerNotExists );
				}
			}
			else {
				// timer state to be specified
				msg.fail( errorMessages.codeStateToBeSpecified, errorMessages.stateToBeSpecified );
			}
		}
		else {
			// timer name to be specified
			msg.fail( errorMessages.codeTimerNameHasToBeSpecified, errorMessages.timerNameHasToBeSpecified );
		}
	}
		
	"Replies with scheduler info - array of timer names."
	shared void operationInfo( Message<JSON?> msg ) {
		if ( exists request = msg.body(), is String tName = request[Chime.key.name] ) {
			// contains name field - reply with info about timer with specified name
			String timerName = timerFullName( tName );
			if ( exists t = timers[timerName] ) {
				// timer successfully removed
				msg.reply( t.fullDescription() );
			}
			else {
				// timer doesn't exist
				msg.fail( errorMessages.codeTimerNotExists, errorMessages.timerNotExists );
			}
		}
		else {
			// timer name to be specified
			msg.fail( errorMessages.codeTimerNameHasToBeSpecified, errorMessages.timerNameHasToBeSpecified );
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
			for ( timer in timers.items ) {
				if ( timer.state == timerRunning ) {
					timer.start( current );
					if ( timer.state == timerCompleted ) {
						sendCompleteEvent( timer );
					}
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
		for ( timer in timers.items ) {
			if ( timer.state != timerCompleted ) {
				timer.complete();
				sendCompleteEvent( timer );
			}
		}
		timers.clear();
		cancelCurrentVertxTimer();
	}
	
}
