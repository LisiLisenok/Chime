import io.vertx.ceylon.core {

	Vertx,
	CompositeFuture,
	Future
}
import io.vertx.ceylon.core.eventbus {

	Message,
	deliveryOptions
}
import ceylon.json {
	
	JsonObject,
	JsonArray
}
import ceylon.collection {

	HashMap
}
import herd.schedule.chime.service.timezone {
	TimeZone
}
import herd.schedule.chime.service.message {
	MessageSource,
	DirectMessageSourceFactory
}
import ceylon.time {
	now
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
 	JsonObject message = JsonObject { 
 		\"operation\" -> \"create\", 
 		\"name\" -> \"scheduler name\" 
 	} 
  	
  	// change state of scheduler with \"scheduler name\" on paused
 	JsonObject message = JsonObject { 
 		\"operation\" -> \"state\", 
 		\"name\" -> \"scheduler name\",  
 		\"state\" -> \"paused\"
 	} 
 	
 ### Response  
 response on messages is in `JSON`:  
 	{  
 		\"name\" -> String // scheduler or full timer (\"scheduler name:timer name\") name  
 		\"state\" -> String // scheduler state  
 		\"schedulers\" -> JsonArray // scheduler names, exists as response on \"info\" operation with no \"name\" field  
 	}
 	
 or fail message with corresponding error, see [[Chime.errors]].  

 "
since("0.1.0") by("Lis")
see(`class TimeScheduler`)
class SchedulerManager extends Operator
{
	
	static String schedulerNameFromFullName(String fullName)
			=> fullName[... (fullName.firstOccurrence(Chime.configuration.nameSeparatorChar) else 0) - 1];
	
	"Time schedulers."
	HashMap<String, TimeScheduler> schedulers = HashMap<String, TimeScheduler>();
	
	"Generated scheduler name if requested."
	late String generatedSchedulerName = let
		(value dt = now().dateTime(), String delim = "-")
		"sdr-" + dt.year.string + delim + dt.month.string + delim + dt.day.string
		+ delim + dt.hours.string + delim + dt.minutes.string + delim + dt.seconds.string
		+ delim + dt.milliseconds.string;
	
	
	"Tolerance to compare fire time and current time in miliseconds." Integer tolerance;
	"Mark shows if address is not propagated across the cluster." Boolean local; 	
	"Provides Chime services." ChimeServiceProvider providers; 
	"Create timer with container." TimerCreator creator;
	"Default message source used if no one specified at timer." MessageSource defaultMessageSource;
	

	"Instantiates new manager."
	shared new (
		"Address Chime listens." String address,
		"Tolerance to compare fire time and current time in miliseconds." Integer tolerance,
		"Mark shows if address is not propagated across the cluster." Boolean local,
		"Vetrx the scheduler is running on." Vertx vertx 
	)
			extends Operator(address, vertx.eventBus())
	{
		this.tolerance = tolerance;
		this.local = local;
		this.providers = ChimeServiceProvider(vertx, address);
		this.creator = TimerCreator(providers);
		this.defaultMessageSource = DirectMessageSourceFactory.directMessageSource;
	}
	
	
	"Initializes the scheduler. When initialized `complete` is called.
	 Calls `connect` if successfully initialized.  "
	shared void initialize (
		"Configuration." JsonObject config,
		"Future to indicate the _Chime_ is started." Future<Anything> startFuture
	) => providers.initialize (
			config,
			(Throwable|CompositeFuture result) {
				if (is CompositeFuture result) {
					connect(local);
					instantiateFromArray(config, Chime.key.schedulers);
					instantiateFromArray(config, Chime.key.timers);
					startFuture.complete();
				}
				else {
					startFuture.fail(result);
				}
			}
		);

	"Instantiates schedulers or timers from `request[key]`."
	void instantiateFromArray(JsonObject request, String key) {
		if (is JsonArray arr = request[key]) {
			for (item in arr.narrow<JsonObject>()) {
				value ret = createSchedulerOrTimer(item);
				switch (ret)
				case (is TimeScheduler) {
					// TODO: log
				}
				case (is TimerContainer) {
					// TODO: log
				}
				case (is Integer->String) {
					// TODO: log
				}
			}
		}
	}

	
// operation methods
	
	"Creates operators map."
	shared actual Map<String, Anything(Message<JsonObject?>)> createOperators()
			=> map<String, Anything(Message<JsonObject?>)> {
				Chime.operation.create -> operationCreate,
				Chime.operation.delete -> operationDelete,
				Chime.operation.state -> operationState,
				Chime.operation.info -> operationInfo
			};
	
	"Extracts name from request."
	String? extractNameFromRequest(JsonObject request) {
		if (is String name = request[Chime.key.name], !name.empty && name != address) {
			return name;
		}
		else {
			return null;
		}
	}
	
	"Creates scheduler or timer as defined in request."
	TimeScheduler|TimerContainer|<Integer->String> createSchedulerOrTimer(JsonObject request) {
		String name = extractNameFromRequest(request) else generatedSchedulerName;
		String schedulerName =
				if (exists inc = name.firstOccurrence(Chime.configuration.nameSeparatorChar))
				then name.spanTo( inc - 1 ) else name;
		
		if (exists scheduler = schedulers.get(schedulerName)) {
			// scheduler already exists
			if (request.defines(Chime.key.description)) {
				// add timer to scheduler
				return scheduler.createTimer(request);
			}
			else {
				// timer description is not specified - reply with info on scheduler
				return scheduler;
			}
		}
		else {
			value exactServices = servicesFromRequest(request, providers, providers.localTimeZone, defaultMessageSource);
			if (is [TimeZone, MessageSource] exactServices) {
				// create new scheduler
				TimeScheduler scheduler = TimeScheduler (
					schedulerName, schedulers.remove, providers.vertx, creator,
					tolerance, exactServices[0], exactServices[1],
					if (exists options = request.getObjectOrNull(Chime.key.deliveryOptions))
					then deliveryOptions.fromJson(options) else null
				);
				schedulers.put(schedulerName, scheduler);
				scheduler.connect(local);
				value state = extractState(request) else State.running;
				if (state == State.running) {
					scheduler.start();
				}
				if (request.defines(Chime.key.description)) {
					// add timer to scheduler
					return scheduler.createTimer(request);
				}
				else {
					// timer description is not specified - reply with info on scheduler
					return scheduler;
				}
			}
			else {
				return exactServices.key -> exactServices.item;
			}
		}
	}
	
	"Processes 'create new scheduler or timer' operation."
	void operationCreate(Message<JsonObject?> msg) {
		if (exists request = msg.body()) {
			value ret = createSchedulerOrTimer(request);
			switch (ret)
			case (is TimeScheduler) {msg.reply(ret.shortInfo);}
			case (is TimerContainer) {msg.reply(ret.stateDescription());}
			case (is Integer->String) {msg.fail(ret.key, ret.item);}
		}
		else {
			// response with wrong format error
			msg.fail(Chime.errors.codeSchedulerNameHasToBeSpecified, Chime.errors.schedulerNameHasToBeSpecified);
		}
	}
	
	"Processes 'delete scheduler or timer' operation."
	void operationDelete(Message<JsonObject?> msg) {
		value nn = msg.body()?.get(Chime.key.name);
		if (is String name = nn) {
			if (name.empty || name == address) {
				// remove all schedulers
				JsonArray ret = JsonArray{};
				for (scheduler in schedulers.items) {
					scheduler.stop();
					ret.add(scheduler.address);
				}
				msg.reply(JsonObject{Chime.key.schedulers -> ret});
				schedulers.clear();
			}
			else if (exists sch = schedulers.remove(name)) {
				// delete scheduler
				sch.stop();
				// scheduler successfully removed
				msg.reply(sch.shortInfo);
			}
			else {
				// scheduler doesn't exists - look if name is full timer name
				value schedulerName = schedulerNameFromFullName(name);
				if (!schedulerName.empty, exists sch = schedulers[schedulerName]) {
					// scheduler has to remove timer
					sch.operationDelete(msg);
				}
				else {
					// scheduler doesn't exist
					msg.fail(Chime.errors.codeSchedulerNotExists, Chime.errors.schedulerNotExists);
				}
			}
		}
		else if (is JsonArray arr = nn, nonempty names = arr.narrow<String>().sequence()) {
			JsonArray retSchedulers = JsonArray{};
			JsonArray retTimers = JsonArray{};
			for (item in names) {
				if (exists sch = schedulers.remove(item)) {
					// delete scheduler
					sch.stop();
					retSchedulers.add(sch.address);
				}
				else {
					// delete timer
					value schedulerName = schedulerNameFromFullName(item);
					if (!schedulerName.empty, exists sch = schedulers[schedulerName]) {
						if (exists t = sch.deleteTimer(item)) {
							retTimers.add(t.name);
						}
					}
				}
			}
			msg.reply(JsonObject{Chime.key.schedulers -> retSchedulers, Chime.key.timers -> retTimers});
		}
		else {
			// response with wrong format error
			msg.fail(Chime.errors.codeSchedulerNameHasToBeSpecified, Chime.errors.schedulerNameHasToBeSpecified);
		}
	}
	
	"Processes 'scheduler state' operation."
	void operationState(Message<JsonObject?> msg) {
		if (exists request = msg.body(), is String name = request[Chime.key.name]) {
			if (is String state = request[Chime.key.state]) {
				if (exists sch = schedulers[name]) {
					sch.replyWithSchedulerState(state, msg);
				}
				else {
					// scheduler doesn't exists - look if name is full timer name
					value schedulerName = schedulerNameFromFullName(name);
					if (!schedulerName.empty, exists sch = schedulers[schedulerName]) {
						// scheduler has to provide timer state
						sch.operationState(msg);
					}
					else {
						// scheduler or timer doesn't exist
						msg.fail(Chime.errors.codeSchedulerNotExists, Chime.errors.schedulerNotExists);
					}
				}
			}
			else {
				// scheduler state to be specified
				msg.fail(Chime.errors.codeStateToBeSpecified, Chime.errors.stateToBeSpecified);
			}
		}
		else {
			// scheduler name to be specified
			msg.fail(Chime.errors.codeSchedulerNameHasToBeSpecified, Chime.errors.schedulerNameHasToBeSpecified);
		}
	}
	
	"Replies with Chime or particular scheduler or timer info."
	void operationInfo(Message<JsonObject?> msg) {
		value nn = msg.body()?.get(Chime.key.name);
		if (is String name = nn, !name.empty, name != address) {
			if (exists sch = schedulers[name]) {
				// reply with scheduler info
				msg.reply(sch.fullInfo);
			}
			else {
				// scheduler doesn't exists - look if name is full timer name
				value schedulerName = schedulerNameFromFullName(name);
				if (!schedulerName.empty, exists sch = schedulers[schedulerName]) {
					// scheduler has to reply for timer info
					sch.operationInfo(msg);
				}
				else {
					// scheduler or timer doesn't exist
					msg.fail(Chime.errors.codeSchedulerNotExists, Chime.errors.schedulerNotExists);
				}
			}
		}
		else if (is JsonArray arr = nn, nonempty names = arr.narrow<String>().sequence()) {
			JsonArray retSchedulers = JsonArray{};
			JsonArray retTimers = JsonArray{};
			for (item in names) {
				if (exists sch = schedulers[item]) {
					retSchedulers.add(sch.fullInfo);
				}
				else {
					value schedulerName = schedulerNameFromFullName(item);
					if (!schedulerName.empty, exists sch = schedulers[schedulerName]) {
						if (exists t = sch.timerInfo(item)) {
							retTimers.add(t);
						}
					}
				}
			}
			msg.reply(JsonObject{Chime.key.schedulers -> retSchedulers, Chime.key.timers -> retTimers});
		}
		else {
			msg.reply (
				JsonObject {
					Chime.key.schedulers -> JsonArray([for (scheduler in schedulers.items) scheduler.fullInfo]),
					Chime.extension.services -> providers.extensionsInfo()
				}
			);
		}
	}
	
}