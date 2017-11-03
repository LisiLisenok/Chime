import io.vertx.ceylon.core {

	Verticle,
	Future
}
import ceylon.json {
	
	JsonObject
}


"Chime scheduler verticle. Starts scheduling.  
 
 Static objects contain keys of the `JSON` messages and some possible values."
since("0.1.0") by("Lis")
shared class Chime extends Verticle
{
	
	// configuration
	
	"Fields for configuration."
	shared static object configuration {
		"Default listening address."
		shared String defaultAddress = "chime";
		"Configuration key for the listening address."
		shared String address = "address";
		"Configuration key for the tolerance to compare fire time and current time in milliseconds."
		shared String tolerance = "tolerance";
		"Separator of scheduler and timer names."
		shared Character nameSeparatorChar = ':';
		"Separator of scheduler and timer names."
		shared String nameSeparator => nameSeparatorChar.string;
		"Key for the  `JsonArray` of modules to search extensions as service providers."
		shared String services = "services";
		"Key for the local mark.  
		 Local mark is `Boolean` shows if _Chime_ address is not propagated across the cluster (when the mark is `true`)
		 or _Chime_ has to listen all nodes (when the mark is `false`)."
		shared String local = "local";
	}
	
	"Fields for messages keys."
	shared static object key {
		"Key for the operation."
		shared String operation = "operation";
		"Key for the timer name."
		shared String name = "name";
		"Key for the timer state."
		shared String state = "state";
		"Key for the timer description."
		shared String description = "description";
		"Key for the time."
		shared String time = "time";
		"Key for the time count."
		shared String count = "count";
		"Key for the schedulers array."
		shared String schedulers = "schedulers";
		"Key for the timers array."
		shared String timers = "timers";
		"Key for the max count."
		shared String maxCount = "max count";
		"Key for the start time."
		shared String startTime = "start time";
		"Key for the end time."
		shared String endTime = "end time";
		
		"Key for the service type."
		shared String service = "service";
		
		"Key for the time zone."
		shared String timeZone = "time zone";
		"Key for the time zone provider."
		shared String timeZoneProvider = "time zone provider";
		
		"Key for the delay."
		shared String delay = "delay";
		"Key for the timer description type."
		shared String type = "type";
		"Key for the field containing timer event."
		shared String event = "event";
		
		"Key for the type of message source provider."
		shared String messageSource = "message source";
		"Key for the options passed to message source provider when message source asked."
		shared String messageSourceOptions = "message source options";
		"Key for a message to be sent with fire event."
		shared String message = "message";
		
		"Key for the event producer provider."
		shared String eventProducer = "event producer";
		"Key for the options passed to event producer provider when event producing asked."
		shared String eventProducerOptions = "event producer options";
		
		"Calendar applied to the timer."
		shared String calendar = "calendar";
	}
	
	
	"Timer types."
	shared static object type {
		"Key for the timer description type."
		shared String key => Chime.key.type;
		"Cron timer type."
		shared String cron = "cron";
		"Interval timer type."
		shared String interval = "interval";
		"Union timer type."
		shared String union = "union";
	}
	
	
	"Cron and date fields."
	shared static object date { 
		"Seconds, used in CRON timer and timer start/end date."
		shared String seconds = "seconds";
		"Minutes, used in CRON timer and timer start/end date."
		shared String minutes = "minutes";
		"Hours, used in CRON timer and timer start/end date."
		shared String hours = "hours";
		"Days of week, used in CRON timer."
		shared String daysOfWeek = "days of week";
		"Days of month, used in CRON timer."
		shared String daysOfMonth = "days of month";
		"Months, used in CRON timer."
		shared String months = "months";
		"Years, used in CRON timer."
		shared String years = "years";
		
		"Day of month, used in timer start/end date."
		shared String dayOfMonth = "day of month";
		"Day of week."
		shared String dayOfWeek = "day of week";
		"Order of nth weekday."
		shared String order = "order";
		"Month, used in timer start/end date."
		shared String month = "month";
		"Year, used in timer start/end date."
		shared String year = "year";
	}
	
	
	"Time zone provider types."
	shared static object timeZoneProvider {
		"Key for the time zone provider."
		shared String key => Chime.key.timeZoneProvider;
		"Provides time zones available on JVM.  
		 This is default provider."
		shared String jvm = "jvm";
	}
	
	"Message source constants."
	shared static object messageSource {
		"Key for the message source provider."
		shared String key => Chime.key.messageSource;
		"Key for the options passed to message source provider when message source asked."
		shared String messageSourceOptions => Chime.key.messageSourceOptions;
		"Direct source - returns message given in timer create request.  
		 See [[herd.schedule.chime.service.message::DirectMessageSourceFactory]].  
		 This is default provider."
		shared String direct = "direct";
	}
	
	"Calendar provider."
	shared static object calendar {
		"Key for the calendar data."
		shared String key => Chime.key.calendar;
		"Key for the calendar type."
		shared String type => Chime.key.type;
		
		"Calendar event ignorance flag.
		 If set to true restricted time will be ignored and next fire time will be shifted to the next timer time.
		 Otherwise fire time will be shifted to the next time admitted by calendar.  
		 Default is `true`."
		shared String ignoreEvent = "ignore event";
		
		"Annually calendar type, see [[herd.schedule.chime.service.calendar::AnnuallyFactory]]."
		shared String annually = "annually";
		
		"Daily calendar type, see [[herd.schedule.chime.service.calendar::DailyFactory]]."
		shared String daily = "daily";
		"Key for the _from_ date or time, `JsonObject`."
		shared String from = "from";
		"Key for the _to_ date or time, `JsonObject`."
		shared String to = "to";
		"Key for the tolerance, Integer in seconds."
		shared String tolerance = "tolerance";
		
		"Dativity calendar type, see [[herd.schedule.chime.service.calendar::DativityFactory]]."
		shared String dativity = "dativity";
		"Key for the _dates_ list of dates, `JsonArray` of
		 	\"dates\" -> JsonArray {
		 		JsonObject {
		 			\"day\" -> Integer day
		 			\"month\" -> Integer or String month
		 			\"year\" -> Integer year, optional
		 		}
		 	} 
		 "
		shared String dates = "dates";

		"Intersection calendar type, see [[herd.schedule.chime.service.calendar::IntersectionFactory]]."
		shared String intersection = "intersection";
		"Union calendar type, see [[herd.schedule.chime.service.calendar::UnionCalendarFactory]]."
		shared String union = "union";
		"Key for the list of calendars."
		shared String calendars = "calendars";
		
		"Last day of week calendar type, see [[herd.schedule.chime.service.calendar::LastDayOfWeekFactory]]."
		shared String lastDayOfWeek = "last day of week";
		
		"Monthly calendar type, see [[herd.schedule.chime.service.calendar::MonthlyFactory]]."
		shared String monthly = "monthly";
		
		"Weekday of month calendar type, see [[herd.schedule.chime.service.calendar::WeekdayOfMonthFactory]]."
		shared String weekdayOfMonth = "weekday of month";
		
		"Weekly calendar type, see [[herd.schedule.chime.service.calendar::WeeklyFactory]]."
		shared String weekly = "weekly";
		
	}
	
	"Event producer constants."
	shared static object eventProducer {
		"Key for the event producer provider."
		shared String key => Chime.key.eventProducer;
		"Key for the options passed to event producer provider when event producing asked."
		shared String eventProducerOptions => Chime.key.eventProducerOptions;
		"EventBus event producer.  
		 See [[herd.schedule.chime.service.producer::EBProducerFactory]].  
		 This is default provider."
		shared String eventBus = "event bus";
		"Key for a message delivery options to be sent with fire event."
		shared String deliveryOptions = "delivery options";
		"Key for the publish field.  
		 Which is `true` if event has to be published and `false` if it has to be send.  
		 Default is `false`."
		shared String publish = "publish";
	}
		
	"Event constants."
	shared static object event {
		"Key for the field containing timer event."
		shared String key => Chime.key.event;
		"Indicates that message is for the timer fire event."
		shared String fire = "fire";
		"Indicates that the message is for the timer complete event."
		shared String complete = "complete";
	}
	
	
	"Operation codes."
	shared static object operation {
		"Key for the operation field."
		shared String key => Chime.key.operation;
		"Operation code for the timer creation."
		shared String create = "create";
		"Operation code for the timer deletion."
		shared String delete = "delete";
		"Operation code for the getting or modifying shceduler or timer state (pause, run)."
		shared String state = "state";
		"Operation code for the getting total or scheduler info."
		shared String info = "info";
	}
	
	"State fields."
	shared static object state {
		"Key for the state field."
		shared String key => Chime.key.state;
		"Value of the state field, if state is requested."
		shared String get = "get";
		"Value of the state field, if state is running."
		shared String running = "running";
		"Value of the state field, if state is paused."
		shared String paused = "paused";
		"Value of the state field, if state is completed."
		shared String completed = "completed";
	}
	
	"Defines error messages."
	shared static object errors {
		
		shared Integer assertionErrorCode = 1001;
		
		"Code of 'unsupported operation' error."
		shared Integer codeUnsupportedOperation = 1;
		"Message of 'unsupported operation' error."
		shared String unsupportedOperation = "unsupported operation";
		
		"Code of 'operation has to be specified' error."
		shared Integer codeOperationIsNotSpecified = 2;
		"Message of 'operation has to be specified' error."
		shared String operationIsNotSpecified = "operation has to be specified";
		
		"Code of 'scheduler doesn't exist' error."
		shared Integer codeSchedulerNotExists = 3;
		"Message of 'scheduler doesn't exist' error."
		shared String schedulerNotExists = "scheduler doesn't exist";
		
		"Code of 'scheduler name has to be specified' error."
		shared Integer codeSchedulerNameHasToBeSpecified = 4;
		"Message of 'scheduler name has to be specified' error."
		shared String schedulerNameHasToBeSpecified = "scheduler name has to be specified";
		
		"Code of 'scheduler state has to be one of - 'get', 'paused', 'running'' error."
		shared Integer codeIncorrectSchedulerState = 5;
		"Message of 'scheduler state has to be one of - 'get', 'paused', 'running'' error."
		shared String incorrectSchedulerState = "scheduler state has to be one of - 'get', 'paused', 'running'";
		
		"Code of 'state has to be specified' error."
		shared Integer codeStateToBeSpecified = 6;
		"Message of 'state has to be specified' error."
		shared String stateToBeSpecified = "state has to be specified";
		
		"Code of 'timer already exists' error."
		shared Integer codeTimerAlreadyExists = 7;
		"Message of 'timer already exists' error."
		shared String timerAlreadyExists = "timer already exists";
		
		"Code of 'timer doesn't exist' error."
		shared Integer codeTimerNotExists = 8;
		"Message of 'timer doesn't exist' error."
		shared String timerNotExists = "timer doesn't exist";
		
		"Code of 'timer name has to be specified' error."
		shared Integer codeTimerNameHasToBeSpecified = 9;
		"Message of 'timer name has to be specified' error."
		shared String timerNameHasToBeSpecified = "timer name has to be specified";
		
		"Code of 'timer type has to be specified' error."
		shared Integer codeTimerTypeHasToBeSpecified = 10;
		"Message of 'timer type has to be specified' error."
		shared String timerTypeHasToBeSpecified = "timer type has to be specified";
		
		"Code of 'unsupported timer type' error."
		shared Integer codeUnsupportedTimerType = 11;
		"Message of 'unsupported timer type' error."
		shared String unsupportedTimerType = "unsupported timer type";
		
		"Code of 'incorrect start date' error."
		shared Integer codeIncorrectStartDate = 12;
		"Message of 'incorrect start date' error."
		shared String incorrectStartDate = "incorrect start date";
		
		"Code of 'incorrect end date' error."
		shared Integer codeIncorrectEndDate = 13;
		"Message of 'incorrect end date' error."
		shared String incorrectEndDate = "incorrect end date";
		
		"Code of 'end date has to be after start date' error."
		shared Integer codeEndDateToBeAfterStartDate = 14;
		"Message of 'end date has to be after start date' error."
		shared String endDateToBeAfterStartDate = "end date has to be after start date";
		
		"Code of 'unsupported time zone' error."
		shared Integer codeUnsupportedTimezone = 15;
		"Message of 'unsupported time zone' error."
		shared String unsupportedTimezone = "unsupported time zone";
		
		"Code of 'timer description has to be specified' error."
		shared Integer codeTimerDescriptionHasToBeSpecified = 16;
		"Message of 'timer description has to be specified' error."
		shared String timerDescriptionHasToBeSpecified = "timer description has to be specified";
		
		"Code of 'timer state has to be one of - 'get', 'paused', 'running'' error."
		shared Integer codeIncorrectTimerState = 17;
		"Message of 'timer state has to be one of - 'get', 'paused', 'running'' error."
		shared String incorrectTimerState = "timer state has to be one of - 'get', 'paused', 'running'";
		
		"Code of 'delay has to be specified' error."
		shared Integer codeDelayHasToBeSpecified = 18;
		"Message of 'delay has to be specified' error."
		shared String delayHasToBeSpecified = "delay has to be specified";
		
		"Code of 'delay has to be greater than zero' error."
		shared Integer codeDelayHasToBeGreaterThanZero = 19;
		"Message of 'delay has to be greater than zero' error."
		shared String delayHasToBeGreaterThanZero = "delay has to be greater than zero";
		
		"Code of 'incorrect cron timer description' error."
		shared Integer codeIncorrectCronTimerDescription = 20;
		"Message of 'incorrect cron timer description' error."
		shared String incorrectCronTimerDescription = "incorrect cron timer description";
		
		"Code of 'timers list has to be specified' error."
		shared Integer codeTimersListHasToBeSpecified = 21;
		"Message of 'timers list has to be specified' error."
		shared String timersListHasToBeSpecified = "timers list has to be specified";
		
		"Code of 'timer description has to be in JSON' error."
		shared Integer codeNotJSONTimerDescription = 22;
		"Message of 'timer description has to be in JSON' error."
		shared String notJSONTimerDescription = "timer description has to be in JSON";
		
		"Code of 'unsupported service provider' error."
		shared Integer codeUnsupportedServiceProviderType = 23;
		"Message of 'unsupported service provider' error."
		shared String unsupportedServiceProviderType = "unsupported service provider";
		
		"Code of 'annually calendar requires months to be given' error."
		shared Integer codeAnnuallyCalendarMonths = 24;
		"Message of 'annually calendar requires months to be given' error."
		shared String annuallyCalendarMonths = "annually calendar requires months to be given";
		
		"Code of 'daily calendar requires 'to' date to be after 'from'' error."
		shared Integer codeDailyCalendarOrder = 25;
		"Message of 'daily calendar requires 'to' date to be after 'from'' error."
		shared String dailyCalendarOrder = "daily calendar requires 'to' date to be after 'from'";
		
		"Code of 'daily calendar requires 'to' and 'from' dates to be specified' error."
		shared Integer codeDailyCalendarFormat = 26;
		"Message of 'daily calendar requires 'to' and 'from' dates to be specified' error."
		shared String dailyCalendarFormat = "daily calendar requires 'to' and 'from' dates to be specified";
		
		"Code of 'dativity calendar requires dates to be specified' error."
		shared Integer codeDativityCalendarDates = 27;
		"Message of 'dativity calendar requires dates to be specified' error."
		shared String dativityCalendarDates = "dativity calendar requires dates to be specified";
		
		"Code of 'a list of calendars to be specified' error."
		shared Integer codeCalendars = 28;
		"Message of 'a list of calendars to be specified' error."
		shared String calendars = "a list of calendars to be specified";
		
		"Code of 'calendar type has to be specified' error."
		shared Integer codeCalendarTypeHasToBeSpecified = 29;
		"Message of 'calendar type has to be specified' error."
		shared String calendarTypeHasToBeSpecified = "calendar type has to be specified";
		
		"Code of 'days of month have to be specified' error."
		shared Integer codeMonthlyCalendarDaysOfMonth = 30;
		"Message of 'days of month have to be specified' error."
		shared String monthlyCalendarDaysOfMonth = "days of month have to be specified";
		
		"Code of 'days of week have to be specified' error."
		shared Integer codeWeeklyCalendarDaysOfWeek = 31;
		"Message of 'days of week have to be specified' error."
		shared String weeklyCalendarDaysOfWeek = "days of week have to be specified";
		
	}

	
	"Scheduler manager."
	variable SchedulerManager? scheduler = null;


	"Instantiates _Chime_."
	shared new() extends Verticle() {}

	
	"Starts _Chime_. Called by Vert.x during deployement."
	shared actual void startAsync(Future<Anything> startFuture) {
		// create scheduler
		SchedulerManager sch = SchedulerManager (
			// Chime address
			if (is String addr = config?.get(Chime.configuration.address))
				then addr else Chime.configuration.defaultAddress,
			// tolerance to compare times
			if (is Integer tol = config?.get(Chime.configuration.tolerance))
				then tol else 10,
			// true if local event bus consumer has to be used and false otherwise
			if (is Boolean local = config?.get(Chime.configuration.local))
				then local else false,
			// vertx instance
			vertx
		);
		scheduler = sch;
		sch.initialize(config else JsonObject{}, startFuture);
	}
	
	"Stops the _Chime_ verticle."
	shared actual void stop() {
		scheduler?.stop();
		scheduler = null;
	}
	
}
