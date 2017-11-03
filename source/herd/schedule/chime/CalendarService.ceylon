import ceylon.time {
	DateTime
}
import herd.schedule.chime.service.calendar {
	Calendar
}


"Calendar + ignorance flage."
since("0.3.0") by("Lis")
interface CalendarService satisfies Calendar {
	"Calendar ignorance flag." shared formal Boolean calendarIgnorance;
}


"Implementation of `CalendarService`."
since("0.3.0") by("Lis")
class CalendarServiceImpl (
	shared actual Boolean calendarIgnorance,
	Calendar calendar
)
		satisfies CalendarService
{
	shared actual Boolean inside(DateTime date) => calendar.inside(date);
	
	shared actual DateTime nextOutside(DateTime date) => calendar.nextOutside(date);
}


"[[CalendarService]] which restricts nothing."
since("0.3.0") by("Lis")
object emptyCalendar satisfies CalendarService {
	shared actual Boolean inside(DateTime date) => false;
	shared actual DateTime nextOutside(DateTime date) => date.plusSeconds(1);
	shared actual Boolean calendarIgnorance => true;
}
