import io.vertx.ceylon.core {

	Vertx
}
import io.vertx.ceylon.core.eventbus {

	Message
}
import ceylon.json {

	JsonObject,
	JsonArray
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


"Scheduler - listen address of scheduler [[address]] on event bus and manages timers.
 This class is used internaly by Chime
 
 ### Requests
 
 Requests are send in `JSON` format on scheduler name address    
 	{  
 		\"operation\" -> String // operation code, mandatory  
 		\"name\" -> String // timer short or full name, mandatory  
 		\"state\" -> String // state, nonmandatory, except sate operation  
 		
 		// fields for create operation:
 		\"maximum count\" -> Integer // maximum number of fires, default - unlimited  
 		\"publish\" -> Boolean // if true message to be published and send otherwise, nonmandatory  
 
 		\"start time\" -> `JsonObject` // start time, nonmadatory, if doesn't exists timer will start immediately  
 		{  
 			\"seconds\" -> Integer // seconds, mandatory  
 			\"minutes\" -> Integer // minutes, mandatory  
 			\"hours\" -> Integer // hours, mandatory  
 			\"day of month\" -> Integer // days of month, mandatory  
 			\"month\" -> Integer or String // months, if string - short name, mandatory  
 			\"year\" -> Integer // year, Integer, mandatory  
 		}  
 
 		\"end time\" -> `JsonObject` // end time, nonmadatory, default no end time  
 		{  
 			\"seconds\" -> Integer // seconds, mandatory  
 			\"minutes\" -> Integer // minutes, mandatory  
 			\"hours\" -> Integer // hours, mandatory  
 			\"day of month\" -> Integer // days of month, mandatory  
 			\"month\" -> Integer or String // months, if string - short name, mandatory  
 			\"year\" -> Integer // year, Integer, mandatory  
 		}  
 
 		\"time zone\" -> String // time zone name, nonmandatory, default server local  

 		\"description\" -> JsonObject // timer desciption, mandatoty for create operation  
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
 
 Scheduler responses on each request in `JSON` format:  
 	{  
 		\"response\" -> String // response code - one of `ok` or `error`  
 		\"name\" -> String //  timer name  
 		\"state\" -> String // state  
 		
 		\"error\" -> String // error description, exists only if response == `error`
 		\"timers\" -> JsonArray // list of timer names currently scheduled - response on info operation with no name field specified
 		
 		// Info operation returns fields from create operation also
 	}  
 
 "
since("0.1.0") by("Lis")
class TimeScheduler (
	"Scheduler name." String name,
	"Removes schedulerwhen delete operation requested." TimeScheduler?(String) removeScheduler,
	"Vertx the scheduler operates on." Vertx vertx,
	"Factory to create timers." TimerCreator factory,
	"Tolerance to compare fire time and current time in miliseconds." Integer tolerance,
	"Default time services: time zone, message source, event producer, calendar." TimeServices defaultServices
)
		extends Operator(name, vertx.eventBus())
{
	
	String nameWithSeparator = name + Chime.configuration.nameSeparator;
	
	"Tolerance to compare fire time."
	variable Period tolerancePeriod = zero.plusMilliseconds(tolerance);
	
	"Timers sorted by next fire time."
	HashMap<String, TimerContainer> timers = HashMap<String, TimerContainer>();
	
	"Id of vertx timer."
	variable Integer? timerID = null;
	
	"Value for scheduler state - running, paused or completed."
	variable State schedulerState = State.paused;
	
	"Scheduler state - running, paused or completed."
	shared State state => schedulerState;
	
	"Scheduler `JsonObject` short info (name and state)."
	shared JsonObject shortInfo
			=> JsonObject {
				Chime.key.name -> address,
				Chime.key.state -> schedulerState.string
			};
	
	"Scheduler full info in `JsonObject`"
	shared JsonObject fullInfo {
		value ret = JsonObject {
			Chime.key.name -> address,
			Chime.key.state -> state.string,
			Chime.key.timeZone -> defaultServices.timeZoneID,
			Chime.key.timers -> JsonArray{for (timer in timers.items) timer.fullDescription()}
		};
		return ret;
	}
	
	
	"Generates unique name for the timer."
	String generateUniqueName() {
		String prefix = uuidString();
		variable Integer nextID = 0;		
		while (true) {
			String name = prefix + (++ nextID).string;
			if (!timers.contains(name)) {
				return name;
			}
		}
	}
	
	
	"Minimum timer delay."
	Integer minDelay() {
		DateTime current = localTime();
		variable Integer delay = 0;
		for (timer in timers.items) {
			if (timer.state == State.running, exists localDate = timer.localFireTime) {
				Integer offset = localDate.offset(current);
				if (offset <= 0) {
					if (delay > 500 || delay == 0) {
						delay = 500;
					}
				}
				else if (offset < delay || delay == 0) {
					delay = offset;
				}
			}
		}
		return delay;
	}
	
	"Current local time."
	DateTime localTime() => systemTime.instant().dateTime(timeZone.system);
	
	"Fire timers, returns `true` if some timer has been fired and `false` if no one timer has been fired."
	void fireTimers() {
		DateTime current = localTime().plus(tolerancePeriod);
		for (timer in timers.items) {
			if (timer.state == State.running,
				exists localDate = timer.localFireTime,
				localDate < current
			) {
				timer.timerFireEvent();
				timer.shiftTime();
			}
		}
	}
	
	"Removes completed timers and pusblishes complete event."
	void removeCompletedTimers() {
		timers.removeAll([for (timer in timers.items) if (timer.state == State.completed) timer.name]);
	}


// vertx timer

	"Cancels current vertx timer."
	void cancelCurrentVertxTimer() {
		if (exists id = timerID) {
			timerID = null;
			vertx.cancelTimer(id);
		}
	}
	
	"Builds vertx timer using min delay."
	void buildVertxTimer() {
		cancelCurrentVertxTimer();
		Integer delay = minDelay();
		if ( delay > 0 ) {
			timerID = vertx.setTimer(delay, vertxTimerFired);
		}
	}
	
	"Vertx timer has been fired - send message and use next vertx timer."
	void vertxTimerFired( Integer id ) {
		if (state == State.running, exists currentID = timerID, currentID == id) {
			timerID = null;
			fireTimers();
			removeCompletedTimers();
			buildVertxTimer();
		}
	}
	
	
// operations	

	"Returns timer full name from short name."
	String timerFullName(String timerShortName) {
		if (timerShortName.startsWith(nameWithSeparator) && timerShortName.size > nameWithSeparator.size) {
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
		"timer state" State state
	) {
		if (state == State.running) {
			timer.start(localTime());
			if (timer.state == State.running) {
				timers.put(timer.name, timer);
				buildVertxTimer();
			}
		}
		else if (state == State.paused) {
			timers.put(timer.name, timer);
		}
	}

	
	"Creates operators map."
	shared actual Map<String, Anything(Message<JsonObject?>)> createOperators()
			=> map<String, Anything(Message<JsonObject?>)> {
				Chime.operation.create -> operationCreate,
				Chime.operation.delete -> operationDelete,
				Chime.operation.state -> operationState,
				Chime.operation.info -> operationInfo
			};

	"Extracts timer full name from request or generates that."
	String timerNamerFromRequest(JsonObject request) {
		if (is String tName = request[Chime.key.name], !tName.empty) {
			if (tName == address) {
				return nameWithSeparator + generateUniqueName();
			}
			else if (tName.startsWith(nameWithSeparator) && tName.size > nameWithSeparator.size) {
				return tName;
			}
			else {
				return nameWithSeparator + tName;
			}
		}
		else {
			// timer name is not specified - generate unique name
			return nameWithSeparator + generateUniqueName();
		}
	}

	"Create timer with request."
	shared TimerContainer|<Integer->String> createTimer(JsonObject request) {
		if (request.defines(Chime.key.description)) {
			String timerName = timerNamerFromRequest(request);
			if (timers.defines(timerName)) {
				// timer already exists
				return Chime.errors.codeTimerAlreadyExists -> Chime.errors.timerAlreadyExists;
			}
			else {
				value timer = factory.createTimer(timerName, request, defaultServices);
				if (is TimerContainer timer) {
					addTimer(timer, extractState(request) else State.running);
					// timer successfully added
					return timer;
				}
				else {
					// wrong description
					return timer.key -> timer.item;
				}
			}
		}
		else {
			// timer description have to be specified
			return Chime.errors.codeTimerDescriptionHasToBeSpecified -> Chime.errors.timerDescriptionHasToBeSpecified;
		}
	}

	"Creates new timer."
	shared void operationCreate(Message<JsonObject?> msg) {
		if (exists request = msg.body()) {
			value ret = createTimer(request);
			if (is TimerContainer ret) {
				msg.reply(ret.stateDescription());
			}
			else {
				msg.fail(ret.key, ret.item);
			}
		}
		else {
			// timer description have to be specified
			msg.fail(Chime.errors.codeTimerDescriptionHasToBeSpecified, Chime.errors.timerDescriptionHasToBeSpecified);
		}
	}
	
	"Deletes existing timer."
	shared TimerContainer? deleteTimer(String name) {
		if (exists t = timers.remove(timerFullName(name))) {
			t.complete();
			return t;
		}
		else {
			return null;
		}
	}
	
	"'delete' timer request."
	shared void operationDelete(Message<JsonObject?> msg) {
		value nn = msg.body()?.get(Chime.key.name);
		if ( is String tName = nn ) {
			if (tName.empty || tName == address) {
				// delete this scheduler
				removeScheduler(address);
				stop();
				msg.reply(shortInfo);
			}
			else if (exists t = deleteTimer(tName)) {
				msg.reply(t.stateDescription()); // timer successfully removed
			}
			else {
				// timer doesn't exist
				msg.fail(Chime.errors.codeTimerNotExists, Chime.errors.timerNotExists);
			}
		}
		else if (is JsonArray arr = nn, nonempty names = arr.narrow<String>().sequence()) {
			JsonArray ret = JsonArray{};
			for (item in names) {
				if (exists t = timers.remove(timerFullName(item))) {
					t.complete();
					ret.add(t.name);
				}
			}
			msg.reply(JsonObject{Chime.key.timers -> ret});
		}
		else {
			// timer name to be specified
			msg.fail(Chime.errors.codeTimerNameHasToBeSpecified, Chime.errors.timerNameHasToBeSpecified);
		}
	}
	
	"Replies on the state request of this scheduler."
	shared void replyWithSchedulerState(String state, Message<JsonObject?> msg) {
		if (state == Chime.state.get) {
			// return state
			msg.reply(shortInfo);
		}
		else if (state == State.paused.string){
			// set paused state
			pause();
			msg.reply(shortInfo);
		}
		else if (state == State.running.string){
			// set running state
			start();
			msg.reply(shortInfo);
		}
		else {
			// state to be one of - get, paused, running
			msg.fail(Chime.errors.codeIncorrectTimerState, Chime.errors.incorrectTimerState);
		}
	}
	
	"Processes 'timer state' operation."
	shared void operationState(Message<JsonObject?> msg) {
		if (exists request = msg.body(), is String tName = request[Chime.key.name]) {
			 if (is String state = request[Chime.key.state]) {
				if (tName.empty || tName == address) {
					// this scheduler state is requested
					replyWithSchedulerState(state, msg);
				}
				else if (exists t = timers[timerFullName(tName)]) {
					if (state == Chime.state.get) {
						// return state
						msg.reply(t.stateDescription());
					}
					else if (state == State.paused.string) {
						// set paused state
						t.state = State.paused;
						msg.reply(t.stateDescription());
					}
					else if (state == State.running.string) {
						// set running state
						if (t.state == State.paused) {
							t.start(localTime());
							if (t.state == State.running) {
								buildVertxTimer();
							}
							else {
								timers.remove(t.name);
							}
						}
						msg.reply(t.stateDescription());
					}
					else {
						// state to be one of - get, paused, running
						msg.fail(Chime.errors.codeIncorrectTimerState, Chime.errors.incorrectTimerState);
					}
				}
				else {
					// timer doesn't exist
					msg.fail(Chime.errors.codeTimerNotExists, Chime.errors.timerNotExists);
				}
			}
			else {
				// timer state to be specified
				msg.fail(Chime.errors.codeStateToBeSpecified, Chime.errors.stateToBeSpecified);
			}
		}
		else {
			// timer name to be specified
			msg.fail(Chime.errors.codeTimerNameHasToBeSpecified, Chime.errors.timerNameHasToBeSpecified);
		}
	}


	"Return info on a given timer."
	shared JsonObject? timerInfo(String name) => timers[timerFullName(name)]?.fullDescription();

	
	"Replies with scheduler info - array of timer names."
	shared void operationInfo(Message<JsonObject?> msg) {
		value nn = msg.body()?.get(Chime.key.name);
		if (is String tName = nn) {
			if (tName.empty || tName == address) {
				// reply with info on this scheduler
				msg.reply( fullInfo );
			}
			else if (exists t = timerInfo(tName)) {
				// reply with timer info
				msg.reply(t);
			}
			else {
				// timer doesn't exist
				msg.fail(Chime.errors.codeTimerNotExists, Chime.errors.timerNotExists);
			}
		}
		else if (is JsonArray arr = nn, nonempty names = arr.narrow<String>().sequence()) {
			JsonArray ret = JsonArray{};
			for (item in names) {
				if (exists t = timerInfo(item)) {
					ret.add(t);
				}
			}
			msg.reply(JsonObject{Chime.key.timers -> ret});
		}
		else {
			// reply with info on this scheduler
			msg.reply(fullInfo);
		}
	}

	
// scheduler methods
	
	"Starts scheduling."
	see(`function pause`)
	see(`function stop`)
	shared void start() {
		if (state != State.running) {
			schedulerState = State.running;
			DateTime current = localTime();
			for (timer in timers.items) {
				if (timer.state == State.running) {
					timer.start(current);
				}
			}
			removeCompletedTimers();
			buildVertxTimer();
		}
	}
	
	"Pauses scheduling - all fires to be missed while start not called."
	see(`function start`)
	shared void pause() {
		schedulerState = State.paused;
		cancelCurrentVertxTimer();
	}
	
	"Completes all timers and terminates this scheduler."
	shared actual void stop() {
		super.stop();
		schedulerState = State.completed;
		// fire completed on all timers
		for (timer in timers.items) {
			if (timer.state != State.completed) {
				timer.complete();
			}
		}
		timers.clear();
		cancelCurrentVertxTimer();
	}
	
}
