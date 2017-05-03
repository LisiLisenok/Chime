import ceylon.time {
	DateTime
}
import ceylon.json {
	ObjectValue
}
import io.vertx.ceylon.core.eventbus {
	DeliveryOptions
}


"Represents a timer event: fire or complete.  
 Timer publishes or sends the event in JSON format to timer address when the timer fires or completes.  
 [[Timer]] interface converts JSON event into `TimerEvent`.  
 
 > Complete event is always published.
 "
see( `interface Timer`, `function Timer.handler` )
tagged( "Event" )
since( "0.2.0" ) by( "Lis" )
shared abstract class TimerEvent (
	"Name of the timer which sent the message."
	shared String timerName,
	"Total number of fires."
	shared Integer count
)
		of TimerFire | TimerCompleted
{}


"Timer fire event."
see( `interface Timer`, `function Timer.handler` )
tagged( "Event" )
since( "0.2.0" ) by( "Lis" )
shared final class TimerFire (
	"Nameof the timer which fires the message."
	String timerName,
	"Total number of fires."
	Integer count,
	"String formated time / date."
	shared String time,
	"Time zone ID."
	shared String timeZone,
	"Date the fire is occured at."
	shared DateTime date,
	"Optional message attached to the timer fire event."
	shared ObjectValue? message,
	"Optional delivery options message is sent with."
	shared DeliveryOptions? options
)
		extends TimerEvent( timerName, count )
{}


"Timer complete event."
see( `interface Timer`, `function Timer.handler` )
tagged( "Event" )
since( "0.2.0" ) by( "Lis" )
shared final class TimerCompleted (
	"Name of the timer which fires the message."
	String timerName,
	"Total number of fires."
	Integer count
)
		extends TimerEvent( timerName, count )
{}
