import io.vertx.ceylon.core {

	Verticle
}
import ceylon.json {
	
	JSON = Object
}
import herd.schedule.chime.timer {

	TimerFactory,
	StandardTimerFactory
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
		"Key for the response code."
		shared String response = "response";
		"Key for the error field."
		shared String error = "error";
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
		"Key for the time zone ID."
		shared String timeZoneID = "time zone";
		"Key for the delay."
		shared String delay = "delay";
		"Key for the imer description type."
		shared String type = "type";
		"Key for the fieldcontaining timer event."
		shared String event = "event";
	}
	
	"Timer types."
	shared static object type {
		"Key for the imer description type."
		shared String key => Chime.key.type;
		"Cron timer type."
		shared String cron = "cron";
		"Interval timer type."
		shared String interval = "interval";
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
		"Value of the state field, if state is requested."
		shared String get = "get";
		"Value of the state field, if state is running."
		shared String running = "running";
		"Value of the state field, if state is paused."
		shared String paused = "paused";
		"Value of the state field, if state is completed."
		shared String completed = "completed";
	}
	
	"Response codes."
	shared static object response {
		"Response code for the operation acception."
		shared String ok = "ok";
		"Response code for the error which has been occured during operation execution."
		shared String error = "error";
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
	

	"Scheduler manager."
	variable SchedulerManager? scheduler = null;
	
	"Address to listen on event buss."
	variable String actualAddress = configuration.defaultAddress;
	
	"Max year limitation."
	variable Integer maxYearPeriod = 10; 
	
	"Tolerance to compare fire time and current time in milliseconds."
	variable Integer actualTolerance = 10; 
	
	"Factory to create timers - refine to produce timers of nonstandard types.
	 Standard factory creates cron-like timer and interval timer."
	TimerFactory timerFactory = StandardTimerFactory( maxYearPeriod ).initialize();

	shared new() extends Verticle() {}
	

	"Reads configuration from json."
	void readConfiguration( "Configuration in JSON format." JSON config ) {
		// read listening address
		if ( is String addr = config.get( Chime.configuration.address ) ) {
			actualAddress = addr;
		}
		// year period limitation
		if ( is Integer maxYear = config.get ( Chime.configuration.maxYearPeriodLimit ) ) {
			if ( maxYear < 100 ) { maxYearPeriod = maxYear; }
			else { maxYearPeriod = 100; }
		}
		// tolerance to compare times
		if ( is Integer tol = config.get ( Chime.configuration.tolerance ) ) {
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
		SchedulerManager sch = SchedulerManager( vertx, vertx.eventBus(), timerFactory, actualTolerance );
		scheduler = sch;
		sch.connect( actualAddress );
	}
	
}
