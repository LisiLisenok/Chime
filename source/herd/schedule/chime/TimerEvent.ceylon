import ceylon.time {
	DateTime
}
import ceylon.json {
	JsonObject,
	ObjectValue
}


"Represents a timer event: fire or complete.  
 Timer publishes or sends the event in `JSON` format to timer address when the timer fires or completes.  
 [[Timer]] interface converts `JsonObject` event into `TimerEvent`.  
 
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
{
	"Writes the event into `JsonObject`."
	shared formal JsonObject toJson();
}


"Timer fire event."
see( `interface Timer`, `function Timer.handler` )
tagged( "Event" )
since( "0.2.0" ) by( "Lis" )
shared final class TimerFire (
	"Name of the timer which fires the message."
	String timerName,
	"Total number of fires."
	Integer count,
	"Time zone ID."
	shared String timeZone,
	"Date the fire is occured at."
	shared DateTime date,
	"Optional message attached to the timer fire event."
	shared ObjectValue? message
)
		extends TimerEvent( timerName, count )
{
	
	shared actual JsonObject toJson() {
		value ret = JsonObject {
			Chime.key.event -> Chime.event.fire,
			Chime.key.name -> timerName,
			Chime.key.count -> count,
			Chime.key.time -> date.string,
			Chime.date.seconds -> date.seconds,
			Chime.date.minutes -> date.minutes,
			Chime.date.hours -> date.hours,
			Chime.date.dayOfMonth -> date.day,
			Chime.date.month -> date.month.integer,
			Chime.date.year -> date.year,
			Chime.key.timeZone -> timeZone
		};
		if ( exists msg = message ) {
			ret.put( Chime.key.message, msg );
		}
		return ret;
	}
	
	"Json representation of the event with another message attached to."
	shared JsonObject toJsonWithMessage( "Message value to be attached to the event." ObjectValue? attachedMessage ) {
		value ret = JsonObject {
			Chime.key.event -> Chime.event.fire,
			Chime.key.name -> timerName,
			Chime.key.count -> count,
			Chime.key.time -> date.string,
			Chime.date.seconds -> date.seconds,
			Chime.date.minutes -> date.minutes,
			Chime.date.hours -> date.hours,
			Chime.date.dayOfMonth -> date.day,
			Chime.date.month -> date.month.integer,
			Chime.date.year -> date.year,
			Chime.key.timeZone -> timeZone
		};
		if ( exists msg = attachedMessage ) {
			ret.put( Chime.key.message, msg );
		}
		return ret;
	}
	
	shared actual String string {
		String ret = "fire event of ``timerName`` at ``date`` with total fires of ``count``";
		if ( exists msg = message ) {
			return ret + " and message ``msg``";
		}
		else {
			return ret;
		}
	}
}


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
{
	shared actual JsonObject toJson()
		=> JsonObject {
			Chime.key.event -> Chime.event.complete,
			Chime.key.name -> timerName,
			Chime.key.count -> count
		};
	shared actual String string => "complete event of ``timerName`` with total fires of ``count``";
}
