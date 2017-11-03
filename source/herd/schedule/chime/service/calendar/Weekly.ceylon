import ceylon.time {
	DateTime
}
import ceylon.time.base {
	DayOfWeek
}
import herd.schedule.chime.service {
	ChimeServices,
	Extension
}
import herd.schedule.chime.cron {
	calendar
}
import ceylon.json {
	JsonObject,
	JsonArray
}
import herd.schedule.chime {
	Chime
}


"Restricts time to week days."
since("0.3.0") by("Lis")
class Weekly(Set<DayOfWeek> restrictedDays) satisfies Calendar
{
	shared actual Boolean inside(DateTime date) => date.dayOfWeek in restrictedDays;
	
	shared actual DateTime nextOutside(DateTime date) {
		variable DateTime ret = date;
		while (inside(ret)) {
			ret = ret.plusDays(1);
		}
		return ret;
	}
}


"Service provider of weekly calendar.  
 I.e. calendar which excludes a given list of week days every week.  
 To apply this calendar to the given timer / scheduler add to the JSON create request with following `JsonObject`:
 	\"calendar\" -> JsonObject {
 		\"type\" -> \"weekly\";
 		// days of week to be excluded from the fire event, Sunday has index 1
 		// digital, full or short (3 letters) string names are admitted
 		\"days of week\" -> JsonArray{1, Monday, Tue}
 	};
 "
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class WeeklyFactory() satisfies CalendarFactory
{
	shared actual Calendar|<Integer->String> create(ChimeServices services, JsonObject options) {
		if (is JsonArray dow = options[Chime.date.daysOfWeek]) {
			try {
				return Weekly(set{for (item in dow.narrow<Integer|String>()) calendar.dayOfWeekFromString(item)}); 
			}
			catch (AssertionError err) {
				return Chime.errors.assertionErrorCode -> err.message;
			}
		}
		else {
			return Chime.errors.codeWeeklyCalendarDaysOfWeek-> Chime.errors.weeklyCalendarDaysOfWeek;
		}
	}
	
	shared actual String type => Chime.calendar.weekly;
	
}
