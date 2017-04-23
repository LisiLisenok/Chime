import ceylon.time {
	DateTime
}


"Wraps event bus to provide exchanging messages with previously created scheduler.  
 The object implementing interface is returned by [[connectToScheduler]]."
see( `interface Timer`, `function connectToScheduler` )
since( "0.2.0" ) by( "Lis" )
shared interface Scheduler {
	
	"Name of the scheduler."
	shared formal String name;

	"Removes this scheduler."
	shared formal void delete();
	
	"Pauses this scheduler."
	see( `function resume` )
	shared formal void pause();
	
	"Resumes this scheduler after pausing."
	see( `function pause` )
	shared formal void resume();
	
	"Requests scheduler info."
	shared formal void info( "Info handler." Anything(Throwable|SchedulerInfo) info );
	
	"Creates interval timer."
	shared formal void createIntervalTimer (
		"Callback when timer created."
		Anything(Timer|Throwable) handler,
		"Interval timer delay in seconds."
		Integer delay,
		"Timer name. Timer address is timer full name, i.e. \"scheduler name:timer name\"."
		String? timerName = null,
		"`True` if timer is paused at initial and `false` if running."
		Boolean paused = false,
		"`True` if timer has to publish event and `false` if sends."
		Boolean publish = false,
		"Maximum number of fires or null if unlimited."
		Integer? maxCount = null,
		"Timer start date."
		DateTime? startDate = null,
		"Timer end date."
		DateTime? endDate = null,
		"Time zone."
		String? timeZone = null
	);
	
	"Creates cron timer."
	shared formal void createCronTimer (
		"Callback when timer created." Anything(Timer|Throwable) handler,
		"Seconds." String seconds,
		"Minutes." String minutes,
		"Hours." String hours,
		"Days of month." String daysOfMonth,
		"Months." String months,
		"Optional days of week." String? daysOfWeek = null,
		"Optional years." String? years = null,
		"Timer name. Timer address is timer full name, i.e. \"scheduler name:timer name\"."
		String? timerName = null,
		"`True` if timer is paused at initial and `false` if running."
		Boolean paused = false,
		"`True` if timer has to publish event and `false` if sends."
		Boolean publish = false,
		"Maximum number of fires or null if unlimited."
		Integer? maxCount = null,
		"Timer start date."
		DateTime? startDate = null,
		"Timer end date."
		DateTime? endDate = null,
		"Time zone."
		String? timeZone = null
	);
	
}
