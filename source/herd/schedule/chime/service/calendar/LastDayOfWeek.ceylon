import ceylon.time.base {
	DayOfWeek
}
import ceylon.time {
	DateTime
}
import herd.schedule.chime.service {
	Extension,
	ChimeServices
}
import ceylon.json {
	JsonObject
}
import herd.schedule.chime {
	Chime
}
import herd.schedule.chime.cron {
	calendar
}


"Restricts time to the last day of week of the month."
since("0.3.0") by("Lis")
class LastDayOfWeek(DayOfWeek dw) satisfies Calendar
{
	shared actual Boolean inside(DateTime date) => date.dayOfWeek == dw && date.plusWeeks(1).month != date.month;
	
	shared actual DateTime nextOutside(DateTime date) {
		if (inside(date)) {
			return date.plusDays(1);
		}
		else {
			return date;
		}
	}
}


"Service provider of last day of week calendar.  
 I.e. calendar which excludes only a last day of week in each month.  
 To apply this calendar to the given timer / scheduler add to the JSON create request with following `JsonObject`:
 	\"calendar\" -> JsonObject {
 		\"type\" -> \"last day of week\";
 		\"day of week\" -> Integer|String // day of week number or name (Sunday has number 1)
 	};
 "
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class LastDayOfWeekFactory() satisfies CalendarFactory
{
	shared actual Calendar|<Integer->String> create(ChimeServices services, JsonObject options) {
		try {
			return LastDayOfWeek(calendar.dayOfWeekFromJson(options, Chime.date.dayOfWeek));
		}
		catch (AssertionError err) {
			return Chime.errors.assertionErrorCode -> err.message;
		}
	}
	
	shared actual String type => Chime.calendar.lastDayOfWeek;
	
}
