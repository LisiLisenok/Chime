import ceylon.json {
	ObjectValue
}
import herd.schedule.chime.service.message {
	MessageSource
}
import ceylon.time {
	DateTime
}
import herd.schedule.chime.service.timezone {
	TimeZone
}
import herd.schedule.chime.service.producer {
	EventProducer
}


"Services for the timer or scheduler."
since("0.3.0") by("Lis")
final class TimeServices (
	shared TimeZone timeZone,
	shared MessageSource messageSource,
	shared EventProducer eventProducer,
	shared CalendarService calendar
)
		satisfies TimeZone&MessageSource&EventProducer&CalendarService
{
	shared actual void extract(TimerFire event, Anything(ObjectValue?) onMessage)
			=> messageSource.extract(event, onMessage);
	
	shared actual Boolean inside(DateTime date) => calendar.inside(date);
	
	shared actual DateTime nextOutside(DateTime date) => calendar.nextOutside(date);
	
	shared actual void send(TimerEvent event) => eventProducer.send(event);
	
	shared actual String timeZoneID => timeZone.timeZoneID;
	
	shared actual DateTime toLocal(DateTime remote) => timeZone.toLocal(remote);
	
	shared actual DateTime toRemote(DateTime local) => timeZone.toRemote(local);
	
	shared actual Boolean calendarIgnorance => calendar.calendarIgnorance; 
}
