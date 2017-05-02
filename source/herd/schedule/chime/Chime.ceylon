import io.vertx.ceylon.core {

	Verticle
}
import ceylon.json {
	
	JSON = Object
}
import herd.schedule.chime.timer {

	StandardTimeRowFactory
}
import java.util {
	JavaTimeZone=TimeZone
}


"Chime scheduler verticle. Starts scheduling.  
 
 > Ensure that the verticle is started just a once!  
 
 Static strings contain keys of the JSON messages and some possible values."
since( "0.1.0" ) by( "Lis" )
shared class Chime extends Verticle
{
	
	// configuration
	
	"Fields for configuration."
	shared static object configuration {
		"Default listening address."
		shared String defaultAddress = "chime";
		"Configuration key for the listening address."
		shared String address = "address";
		"Configuration key for the max year period limit."
		shared String maxYearPeriodLimit = "max year period limit"; 
		"Configuration key for the tolerance to compare fire time and current time in milliseconds."
		shared String tolerance = "tolerance";
		"Separator of scheduler manager and timer names."
		shared String nameSeparator = ":";
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
		"Key for the publish field."
		shared String publish = "publish";
		"Key for the start time."
		shared String startTime = "start time";
		"Key for the end time."
		shared String endTime = "end time";
		"Key for the time zone."
		shared String timeZone = "time zone";
		"Key for the delay."
		shared String delay = "delay";
		"Key for the imer description type."
		shared String type = "type";
		"Key for the fieldcontaining timer event."
		shared String event = "event";
		"Key for a message to be sent with fire event."
		shared String message = "message";
		"Key for a message delivery options to be sent with fire event."
		shared String deliveryOptions = "delivery options";
	}
	
	"Timer types."
	shared static object type {
		"Key for the imer description type."
		shared String key => Chime.key.type;
		"Cron timer type."
		shared String cron = "cron";
		"Interval timer type."
		shared String interval = "interval";
		"Union timer type."
		shared String union = "union";
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


	"Cron and date fields"
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
		"Month, used in timer start/end date."
		shared String month = "month";
		"Year, used in timer start/end date."
		shared String year = "year";
	}
	
	"Defines error messages."
	shared static object errors {
		
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
		
	}

	
	"Applies JVM time zones for the converters."
	static object jvmConverterFactory satisfies TimeConverterFactory {
		shared actual TimeConverter? getConverter( String timeZone ) {
			JavaTimeZone tz = JavaTimeZone.getTimeZone( timeZone );
			if ( tz.id == timeZone ) {
				return ConverterWithTimezone( tz );
			}
			else {
				return null;
			}
		}
	}
	

	"Scheduler manager."
	variable SchedulerManager? scheduler = null;
	
	"Address to listen on event buss."
	variable String actualAddress = configuration.defaultAddress;
	
	"Max year limitation."
	variable Integer maxYearPeriod = 10; 
	
	"Tolerance to compare fire time and current time in milliseconds."
	variable Integer actualTolerance = 10; 

	"Instantiates _Chime_.  
	 > Ensure that the _Chime_ verticle is started just a once!"
	shared new() extends Verticle() {}
	

	"Reads configuration from json."
	void readConfiguration( "Configuration in JSON format." JSON config ) {
		// read listening address
		if ( is String addr = config[Chime.configuration.address] ) {
			actualAddress = addr;
		}
		// year period limitation
		if ( is Integer maxYear = config[Chime.configuration.maxYearPeriodLimit] ) {
			if ( maxYear < 100 ) { maxYearPeriod = maxYear; }
			else { maxYearPeriod = 100; }
		}
		// tolerance to compare times
		if ( is Integer tol = config[Chime.configuration.tolerance] ) {
			if ( tol > 0 ) { actualTolerance = tol; }
		}
	}
	
	
	"Starts _Chime_. Called by Vert.x during deployement."
	shared actual void start() {
		// read configuration
		if ( exists c = config ) {
			readConfiguration( c );
		}
		
		// create scheduler
		SchedulerManager sch = SchedulerManager (
			actualAddress, vertx, vertx.eventBus(),
			StandardTimeRowFactory( maxYearPeriod ).initialize(), jvmConverterFactory,
			actualTolerance
		);
		scheduler = sch;
		sch.connect();
	}
	
	"Stops the _Chime_ verticle."
	shared actual void stop() {
		scheduler?.stop();
		scheduler = null;
	}
	
}
