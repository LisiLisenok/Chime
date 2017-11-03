import ceylon.json {
	ObjectValue,
	JsonObject,
	JsonArray
}
import ceylon.time {
	DateTime
}
import io.vertx.ceylon.core.eventbus {
	DeliveryOptions,
	EventBus
}


"Creates a timer with the given description.  
 If scheduler hasn't been created yet then new scheduler is created."
tagged("Proxy") since("0.3.0") by("Lis")
see(`function Scheduler.createTimer`, `function Scheduler.createCronTimer`,
	`function Scheduler.createIntervalTimer`, `function Scheduler.createUnionTimer`,
	`function createIntervalTimer`, `function createCronTimer`, `function createUnionTimer`)
shared void createTimer (
	"Address to call _Chime_." String chimeAddress,
	"Event bus to send request over." EventBus eventBus,
	"Callback when timer created." Anything(Timer|Throwable) handler,
	"`JSON` timer description." JsonObject description,
	"Optional name of the scheduler timer has to work within.  
	 If scheduler hasn't been created yet then new scheduler is created."
	String? schedulerName = null,
	"Optional timer name. Timer address is timer full name, i.e. **scheduler name:timer name**.  
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
	"Optional time zone, default is scheduler or local."
	String? timeZone = null,
	"Optional time zone provider, default is scheduler default or \"jvm\"."
	String? timeZoneProvider = null,
	"Message to be passed to message source in order to extract final message."
	ObjectValue? message = null,
	"Optional message source type, default is scheduler or \"direct\" which attaches `message` as is."
	String? messageSource = null,
	"Optional configuration passed to message source factory."
	ObjectValue? messageSourceConfig = null,
	"Event producer provider."
	String? eventProducer = null,
	"Optional configuration passed to event producer factory."
	JsonObject? eventProducerOptions = null,
	"Timeout to send the request with."
	Integer? sendTimeout = null
) {
	JsonObject timer = JsonObject {
		Chime.key.operation -> Chime.operation.create
	};
	if (exists timerName)  {
		timer.put(Chime.key.name, timerName);
	}
	if (paused) {
		timer.put(Chime.key.state, Chime.state.paused);
	}
	if (exists maxCount) {
		timer.put(Chime.key.maxCount, maxCount);
	}
	if (exists startDate) {
		timer.put (
			Chime.key.startTime,
			JsonObject {
				Chime.date.seconds -> startDate.seconds,
				Chime.date.minutes -> startDate.minutes,
				Chime.date.hours -> startDate.hours,
				Chime.date.dayOfMonth -> startDate.day,
				Chime.date.month -> startDate.month.integer,
				Chime.date.year -> startDate.year
			}
		);
	}
	if (exists endDate) {
		timer.put (
			Chime.key.endTime,
			JsonObject {
				Chime.date.seconds -> endDate.seconds,
				Chime.date.minutes -> endDate.minutes,
				Chime.date.hours -> endDate.hours,
				Chime.date.dayOfMonth -> endDate.day,
				Chime.date.month -> endDate.month.integer,
				Chime.date.year -> endDate.year
			}
		);
	}
	if (exists timeZone) {
		timer.put(Chime.key.timeZone, timeZone);
	}
	if (exists timeZoneProvider) {
		timer.put(Chime.key.timeZoneProvider, timeZoneProvider);
	}
	if (exists message) {
		timer.put(Chime.key.message, message);
	}
	if (exists messageSource) {
		timer.put(Chime.key.messageSource, messageSource);
	}
	if (exists messageSourceConfig) {
		timer.put(Chime.key.messageSourceOptions, messageSourceConfig);
	}
	if (exists eventProducer) {
		timer.put(Chime.key.eventProducer, eventProducer);
	}
	if (exists eventProducerOptions) {
		timer.put(Chime.key.eventProducerOptions, eventProducerOptions);
	}
	timer.put(Chime.key.description, description);
	
	if (exists sendTimeout) {
		eventBus.send<JsonObject> (
			chimeAddress, timer, DeliveryOptions(null, null, sendTimeout),
			SchedulerImpl.replyWithTimer(schedulerName, eventBus, sendTimeout, handler)
		);
	}
	else {
		eventBus.send<JsonObject> (
			chimeAddress, timer, SchedulerImpl.replyWithTimer(schedulerName, eventBus, sendTimeout, handler)
		);
	}
}


"Creates an interval timer.  
 If scheduler hasn't been created yet then new scheduler is created."
tagged("Proxy") since("0.3.0") by("Lis")
see(`function Scheduler.createTimer`, `function Scheduler.createCronTimer`,
	`function Scheduler.createIntervalTimer`, `function Scheduler.createUnionTimer`,
	`function createTimer`, `function createCronTimer`, `function createUnionTimer`)
shared void createIntervalTimer (
	"Address to call _Chime_." String chimeAddress,
	"Event bus to send request over." EventBus eventBus,
	"Callback when timer created."
	Anything(Timer|Throwable) handler,
	"Interval timer delay in seconds."
	Integer delay,
	"Optional name of the scheduler timer has to work within.  
	 If scheduler hasn't been created yet then new scheduler is created."
	String? schedulerName = null,
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
	ObjectValue? messageSourceConfig = null,
	"Event producer provider."
	String? eventProducer = null,
	"Optional configuration passed to event producer factory."
	JsonObject? eventProducerOptions = null,
	"Timeout to send the request with."
	Integer? sendTimeout = null
) => createTimer (
	chimeAddress, eventBus, handler, JsonObject {Chime.key.type -> Chime.type.interval, Chime.key.delay -> delay},
	schedulerName, timerName, paused, maxCount, startDate, endDate, timeZone, timeZoneProvider,
	message, messageSource, messageSourceConfig, eventProducer, eventProducerOptions, sendTimeout
);


"Creates a cron timer.  
 If scheduler hasn't been created yet then new scheduler is created."
tagged("Proxy") since("0.3.0") by("Lis")
see(`function Scheduler.createTimer`, `function Scheduler.createCronTimer`,
	`function Scheduler.createIntervalTimer`, `function Scheduler.createUnionTimer`,
	`function createTimer`, `function createIntervalTimer`, `function createUnionTimer`)
shared void createCronTimer (
	"Address to call _Chime_." String chimeAddress,
	"Event bus to send request over." EventBus eventBus,
	"Callback when timer created." Anything(Timer|Throwable) handler,
	"Seconds." String seconds,
	"Minutes." String minutes,
	"Hours." String hours,
	"Days of month." String daysOfMonth,
	"Months." String months,
	"Optional days of week." String? daysOfWeek = null,
	"Optional years." String? years = null,
	"Optional name of the scheduler timer has to work within.  
	 If scheduler hasn't been created yet then new scheduler is created."
	String? schedulerName = null,
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
	ObjectValue? messageSourceConfig = null,
	"Event producer provider."
	String? eventProducer = null,
	"Optional configuration passed to event producer factory."
	JsonObject? eventProducerOptions = null,
	"Timeout to send the request with."
	Integer? sendTimeout = null
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
		chimeAddress, eventBus, handler, descr, schedulerName, timerName, paused, maxCount, startDate, endDate,
		timeZone, timeZoneProvider, message, messageSource, messageSourceConfig, eventProducer, eventProducerOptions, sendTimeout
	);
}


"Creates an union timer.  
 If scheduler hasn't been created yet then new scheduler is created."
tagged("Proxy") since("0.3.0") by("Lis")
see(`function Scheduler.createTimer`, `function Scheduler.createCronTimer`,
	`function Scheduler.createIntervalTimer`, `function Scheduler.createUnionTimer`,
	`function createTimer`, `function createCronTimer`, `function createIntervalTimer`)
shared void createUnionTimer (
	"Address to call _Chime_." String chimeAddress,
	"Event bus to send request over." EventBus eventBus,
	"Callback when timer created."
	Anything(Timer|Throwable) handler,
	"Nonempty list of the timers to be combined into union."
	{JsonObject+} timers,
	"Optional name of the scheduler timer has to work within.  
	 If scheduler hasn't been created yet then new scheduler is created."
	String? schedulerName = null,
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
	ObjectValue? messageSourceConfig = null,
	"Event producer provider."
	String? eventProducer = null,
	"Optional configuration passed to event producer factory."
	JsonObject? eventProducerOptions = null,
	"Timeout to send the request with."
	Integer? sendTimeout = null
) => createTimer (
	chimeAddress, eventBus, handler, JsonObject { Chime.key.type -> Chime.type.union, Chime.key.timers -> JsonArray(timers) },
	schedulerName, timerName, paused, maxCount, startDate, endDate, timeZone, timeZoneProvider,
	message, messageSource, messageSourceConfig, eventProducer, eventProducerOptions, sendTimeout
);


"Requests info on the timers from the given list."
tagged("Proxy") since("0.3.0") by("Lis ")
shared void timersInfo (
	"Address to call _Chime_." String chimeAddress,
	"Event bus to send request over." EventBus eventBus,
	"Timer full names info is requested about." {String+} timers,
	"Callback to get info or error if occured." Anything(Throwable|TimerInfo[]) info,
	"Timeout to send message with." Integer? sendTimeout = null
) {
	value request = JsonObject {
		Chime.key.operation -> Chime.operation.info,
		Chime.key.name -> JsonArray(timers)
	};
	if (exists sendTimeout) {
		eventBus.send<JsonObject> (
			chimeAddress, request, DeliveryOptions(null, null, sendTimeout), TimerImpl.replyWithInfo(info)
		);
	}
	else {
		eventBus.send<JsonObject>(chimeAddress, request, TimerImpl.replyWithInfo(info));
	}
}


"Deletes timers from the given list."
tagged("Proxy") since("0.3.0") by("Lis ")
shared void deleteTimers (
	"Address to call _Chime_." String chimeAddress,
	"Event bus to send request over." EventBus eventBus,
	"Full names of timers to be deleted." {String+} timers,
	"Callback when operation is completed." Anything(Throwable|{String*})? handler = null,
	"Timeout to send message with." Integer? sendTimeout = null
) {
	value request = JsonObject {
		Chime.key.operation -> Chime.operation.delete,
		Chime.key.name -> JsonArray(timers)
	};
	if (exists handler) {
		if (exists sendTimeout) {
			eventBus.send<JsonObject> (
				chimeAddress, request, DeliveryOptions(null, null, sendTimeout),
				SchedulerImpl.replyWithList(handler, Chime.key.timers)
			);
		}
		else {
			eventBus.send<JsonObject>(chimeAddress, request, SchedulerImpl.replyWithList(handler, Chime.key.timers));
		}
	}
	else {
		if (exists sendTimeout) {
			eventBus.send(chimeAddress, request, DeliveryOptions(null, null, sendTimeout));
		}
		else {
			eventBus.send(chimeAddress, request);
		}
	}
}
