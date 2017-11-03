import ceylon.time.base {
	DayOfWeek
}
import ceylon.time {
	DateTime
}
import herd.schedule.chime.service {
	ChimeServices,
	Extension
}
import herd.schedule.chime.cron {
	calendar
}
import ceylon.json {
	JsonObject
}
import herd.schedule.chime {
	Chime
}


"Restricts time to the given weekday of month."
since("0.3.0") by("Lis")
class WeekdayOfMonth(DayOfWeek dw, Integer order) satisfies Calendar
{
	shared actual Boolean inside(DateTime date) => date.dayOfWeek == dw && order == (date.day - 1) / 7 + 1;
	
	shared actual DateTime nextOutside(DateTime date) {
		if (inside(date)) {
			return date.plusDays(1);
		}
		else {
			return date;
		}
	}
	
}


"Service provider of weekday of month calendar.  
 I.e. calendar which excludes a given weekday with the given order in each month (i.e. excludes nth weekday).  
 To apply this calendar to the given timer / scheduler add to the JSON create request with following `JsonObject`:
 	\"calendar\" -> JsonObject {
 		\"type\" -> \"weekday of month\";
 		// day of week number or name (Sunday has number 1),
 		// digital, full or short (3 letters) string names are admitted
 		\"day of week\" -> Integer|String;
 		\"order\" -> Integer // weekday order
 	};
 "
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class WeekdayOfMonthFactory() satisfies CalendarFactory
{
	shared actual Calendar|<Integer->String> create(ChimeServices services, JsonObject options) {
		try {
			return WeekdayOfMonth (
				calendar.dayOfWeekFromJson(options, Chime.date.dayOfWeek),
				options.getInteger(Chime.date.order)
			);
		}
		catch (AssertionError err) {
			return Chime.errors.assertionErrorCode -> err.message;
		}
	}
	
	shared actual String type => Chime.calendar.weekdayOfMonth;
	
}
