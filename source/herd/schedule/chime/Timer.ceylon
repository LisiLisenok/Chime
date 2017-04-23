

"Wraps event bus to provide exchanging messages with previously created timer.  
 The object implementing interface is returned by [[Scheduler.createIntervalTimer]]
 and [[Scheduler.createCronTimer]].  
 
 Timer is sent timer fire or complete events with [[TimerEvent]].
 To set timer event handler call [[handler]].  
 
 > Complete event is always published.
 "
see( `interface Scheduler` )
since( "0.2.0" ) by( "Lis" )
shared interface Timer {
	
	"Full name of the timer, i.e. \"scheduler name:timer name\"."
	shared formal String name;
	
	"Stops and removes this timer."
	shared formal void delete();

	"Pauses this timer."
	see( `function resume` )
	shared formal void pause();
	
	"Resumes this timer after pausing."
	see( `function pause` )
	shared formal void resume();
	
	"Requests timer info."
	shared formal void info( "Info handler." Anything(Throwable|TimerInfo) info );
	
	"Sets the handler for the timer events. Replaces previous one if has been set."
	shared formal void handler( Anything(TimerEvent) handler );
	
	"Unregister the handler from the event bus, while keep timer alive."
	shared formal void unregister();
	
}