import io.vertx.ceylon.core {

	Verticle
}
import ceylon.json {
	
	JSON = Object
}
import herd.schedule.chime.timer {

	definitions,
	TimerFactory,
	StandardTimerFactory
}


"Chime scheduler verticle. Starts scheduling."
by( "Lis" )
shared class ChimeScheduler() extends Verticle()
{
	
	"Scheduler manager."
	variable SchedulerManager? scheduler = null;
	
	"Address to listen on event buss."
	variable String address = definitions.defaultAddress;
	
	"Max year limitation."
	variable Integer maxYearPeriod = 10; 
	
	"Tolerance to compare fire time and current time in milliseconds."
	variable Integer tolerance = 10; 
	
	"Factory to create timers - refine to produce timers of nonstandard types.
	 Standard factory creates cron-like timer and interval timer."
	TimerFactory timerFactory = StandardTimerFactory( maxYearPeriod ).initialize();


	"Reads configuration from json."
	void readConfiguration( "Configuration in JSON format." JSON config ) {
		// read listening address
		if ( is String addr = config.get( definitions.address ) ) {
			address = addr;
		}
		// year period limitation
		if ( is Integer maxYear = config.get ( definitions.maxYearPeriodLimit ) ) {
			if ( maxYear < 100 ) { maxYearPeriod = maxYear; }
			else { maxYearPeriod = 100; }
		}
		// tolerance to compare times
		if ( is Integer tol = config.get ( definitions.tolerance ) ) {
			if ( tol > 0 ) { tolerance = tol; }
		}
	}
	
	
	"Starts _Chime_. Called by Vert.x during deployement."
	shared actual void start() {
		// read configuration
		if ( exists c = config ) {
			readConfiguration( c );
		}
		
		// create scheduler
		SchedulerManager sch = SchedulerManager( vertx, vertx.eventBus(), timerFactory, tolerance );
		scheduler = sch;
		sch.connect( address );
	}
	
}
