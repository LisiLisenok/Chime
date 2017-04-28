import ceylon.time {
	DateTime
}
import ceylon.json {
	
	JSON = Object,
	ObjectValue
}
import io.vertx.ceylon.core.eventbus {
	DeliveryOptions
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
	shared default void createIntervalTimer (
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
		String? timeZone = null,
		"Message to be attached to the timer fire event."
		ObjectValue? message = null,
		"Delivery options message has to be sent with."
		DeliveryOptions? options = null
	) =>
		createTimer( 
			handler, JSON { Chime.key.type -> Chime.type.interval, Chime.key.delay -> delay },
			timerName, paused, publish, maxCount, startDate, endDate, timeZone, message, options
		);
	
	"Creates cron timer."
	shared default void createCronTimer (
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
		String? timeZone = null,
		"Message to be attached to the timer fire event."
		ObjectValue? message = null,
		"Delivery options message has to be sent with."
		DeliveryOptions? options = null
	) {
		JSON descr = JSON {
			Chime.key.type -> Chime.type.cron,
			Chime.date.seconds -> seconds,
			Chime.date.minutes -> minutes,
			Chime.date.hours -> hours,
			Chime.date.daysOfMonth -> daysOfMonth,
			Chime.date.months -> months,
			Chime.date.daysOfWeek -> "*",
			Chime.date.years -> "2015-2019"			
		};
		if ( exists d = daysOfWeek, !d.empty ) {
			descr.put( Chime.date.daysOfWeek, d );
		}
		if ( exists d = years, !d.empty ) {
			descr.put( Chime.date.years, d );
		}
		createTimer( 
			handler, descr, timerName, paused, publish, maxCount, startDate, endDate, timeZone, message, options
		);
	}
	
	"Creates timer with the given description."
	shared formal void createTimer (
		"Callback when timer created." Anything(Timer|Throwable) handler,
		"JSON timer description." JSON description,
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
		String? timeZone = null,
		"Message to be attached to the timer fire event."
		ObjectValue? message = null,
		"Delivery options message has to be sent with."
		DeliveryOptions? options = null
	);
	
}
