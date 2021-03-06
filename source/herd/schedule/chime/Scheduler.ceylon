import ceylon.time {
	DateTime
}
import ceylon.json {
	
	JsonObject,
	JsonArray,
	ObjectValue
}


"Wraps event bus to provide exchanging messages with previously created scheduler.  
 The object implementing interface is returned by [[connectScheduler]]."
see(`interface Timer`, `function connectScheduler`, `function createScheduler`)
tagged("Proxy")
since("0.2.0") by("Lis")
shared interface Scheduler {
	
	"Name of the scheduler.  
	 _Chime_ listens event bus at this address for the messages to this scheduler.  
	 See details in [[module herd.schedule.chime]]."
	shared formal String name;

	"Removes this scheduler."
	shared formal void delete("Optional reply handler. Replied with scheduler name." Anything(Throwable|String)? reply = null);
	
	"Pauses this scheduler."
	see(`function resume`)
	shared formal void pause("Optional reply handler. Replied with scheduler state." Anything(Throwable|State)? reply = null);
	
	"Resumes this scheduler after pausing."
	see(`function pause`)
	shared formal void resume("Optional reply handler. Replied with scheduler state." Anything(Throwable|State)? reply = null);
	
	"Requests scheduler info."
	see(`function schedulerInfo`)
	shared formal void info("Info handler." Anything(Throwable|SchedulerInfo) info);
	
	"Requests info on a list of timers."
	see(`function schedulerInfo`) since("0.2.1")
	shared formal void timersInfo (
		"Names of timers info is requested for." {String+} timers,
		"Info handler." Anything(Throwable|TimerInfo[]) info
	);
	
	"Deletes a list of timers.  
	 `handler` is called with a list of actually deleted timers or with an error if occured. "
	see(`function delete`) since("0.2.1")
	shared formal void deleteTimers (
		"Names of timers to be deleted." {String+} timers,
		"Optional delete handler." Anything(Throwable|{String*})? handler = null
	);
	
	"Creates an interval timer."
	shared default void createIntervalTimer (
		"Callback when timer created."
		Anything(Timer|Throwable) handler,
		"Interval timer delay in seconds."
		Integer delay,
		"Timer name. Timer address is timer full name, i.e. **scheduler name:timer name**.  
		 By default unique timer name is generate."
		String? timerName = null,
		"`True` if timer is paused at initial and `false` if running."
		Boolean paused = false,
		"Maximum number of fires or null if unlimited."
		Integer? maxCount = null,
		"Timer start date."
		DateTime? startDate = null,
		"Timer end date."
		DateTime? endDate = null,
		"Time zone, default is machine local."
		String? timeZone = null,
		"Optional time zone provider, default is \"jvm\"."
		String? timeZoneProvider = null,
		"Message to be passed to message source in order to extract final message."
		ObjectValue? message = null,
		"Optional message source type, default is \"direct\" which attaches `message` as is."
		String? messageSource = null,
		"Optional configuration passed to message source factory."
		JsonObject? messageSourceOptions = null,
		"Event producer provider."
		String? eventProducer = null,
		"Optional configuration passed to event producer factory."
		JsonObject? eventProducerOptions = null
	) => createTimer ( 
			handler, JsonObject {Chime.key.type -> Chime.type.interval, Chime.key.delay -> delay},
			timerName, paused, maxCount, startDate, endDate, timeZone, timeZoneProvider,
			message, messageSource, messageSourceOptions, eventProducer, eventProducerOptions
		);
	
	"Creates a cron timer."
	shared default void createCronTimer (
		"Callback when timer created." Anything(Timer|Throwable) handler,
		"Seconds." String seconds,
		"Minutes." String minutes,
		"Hours." String hours,
		"Days of month." String daysOfMonth,
		"Months." String months,
		"Optional days of week." String? daysOfWeek = null,
		"Optional years." String? years = null,
		"Timer name. Timer address is timer full name, i.e. **scheduler name:timer name**.  
		 By default unique timer name is generate."
		String? timerName = null,
		"`True` if timer is paused at initial and `false` if running."
		Boolean paused = false,
		"Maximum number of fires or null if unlimited."
		Integer? maxCount = null,
		"Timer start date."
		DateTime? startDate = null,
		"Timer end date."
		DateTime? endDate = null,
		"Time zone."
		String? timeZone = null,
		"Optional time zone provider, default is \"jvm\"."
		String? timeZoneProvider = null,
		"Message to be passed to message source in order to extract final message."
		ObjectValue? message = null,
		"Optional message source type, default is \"direct\" which attaches `message` as is."
		String? messageSource = null,
		"Optional configuration passed to message source factory."
		JsonObject? messageSourceOptions = null,
		"Event producer provider."
		String? eventProducer = null,
		"Optional configuration passed to event producer factory."
		JsonObject? eventProducerOptions = null
	) {
		JsonObject descr = JsonObject {
			Chime.key.type -> Chime.type.cron,
			Chime.date.seconds -> seconds,
			Chime.date.minutes -> minutes,
			Chime.date.hours -> hours,
			Chime.date.daysOfMonth -> daysOfMonth,
			Chime.date.months -> months
		};
		if (exists d = daysOfWeek, !d.empty) {
			descr.put(Chime.date.daysOfWeek, d);
		}
		if (exists d = years, !d.empty) {
			descr.put(Chime.date.years, d);
		}
		createTimer ( 
			handler, descr, timerName, paused, maxCount, startDate, endDate, timeZone,
			timeZoneProvider, message, messageSource, messageSourceOptions,
			eventProducer, eventProducerOptions
		);
	}
	
	"Creates an union timer."
	since( "0.2.1" )
	shared default void createUnionTimer (
		"Callback when timer created."
		Anything(Timer|Throwable) handler,
		"Nonempty list of the timers to be combined into union."
		{JsonObject+} timers,
		"Timer name. Timer address is timer full name, i.e. **scheduler name:timer name**.  
		 By default unique timer name is generate."
		String? timerName = null,
		"`True` if timer is paused at initial and `false` if running."
		Boolean paused = false,
		"Maximum number of fires or null if unlimited."
		Integer? maxCount = null,
		"Timer start date."
		DateTime? startDate = null,
		"Timer end date."
		DateTime? endDate = null,
		"Time zone."
		String? timeZone = null,
		"Optional time zone provider, default is \"jvm\"."
		String? timeZoneProvider = null,
		"Message to be passed to message source in order to extract final message."
		ObjectValue? message = null,
		"Optional message source type, default is \"direct\" which attaches `message` as is."
		String? messageSource = null,
		"Optional configuration passed to message source factory."
		JsonObject? messageSourceOptions = null,
		"Event producer provider."
		String? eventProducer = null,
		"Optional configuration passed to event producer factory."
		JsonObject? eventProducerOptions = null
	) =>
		createTimer ( 
			handler, JsonObject {Chime.key.type -> Chime.type.union, Chime.key.timers -> JsonArray(timers)},
			timerName, paused, maxCount, startDate, endDate, timeZone, timeZoneProvider,
			message, messageSource, messageSourceOptions, eventProducer, eventProducerOptions
		);

	
	"Creates a timer with the given description."
	since( "0.2.1" )
	shared formal void createTimer (
		"Callback when timer created." Anything(Timer|Throwable) handler,
		"JSON timer description." JsonObject description,
		"Timer name. Timer address is timer full name, i.e. **scheduler name:timer name**.  
		 By default unique timer name is generate."
		String? timerName = null,
		"`True` if timer is paused at initial and `false` if running."
		Boolean paused = false,
		"Maximum number of fires or null if unlimited."
		Integer? maxCount = null,
		"Timer start date."
		DateTime? startDate = null,
		"Timer end date."
		DateTime? endDate = null,
		"Opyional time zone, default is scheduler or local."
		String? timeZone = null,
		"Optional time zone provider, default is scheduler or \"jvm\"."
		String? timeZoneProvider = null,
		"Message to be passed to message source in order to extract final message."
		ObjectValue? message = null,
		"Optional message source type, default is scheduler or \"direct\" which attaches `message` as is."
		String? messageSource = null,
		"Optional configuration passed to message source factory."
		JsonObject? messageSourceOptions = null,
		"Event producer provider."
		String? eventProducer = null,
		"Optional configuration passed to event producer factory."
		JsonObject? eventProducerOptions = null
	);
	
}
