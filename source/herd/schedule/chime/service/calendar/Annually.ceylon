import ceylon.time {
	DateTime,
	dateTime
}
import ceylon.time.base {
	Month,
	monthOf
}
import herd.schedule.chime.service {
	Extension,
	ChimeServices
}
import ceylon.json {
	JsonObject,
	JsonArray
}
import herd.schedule.chime {
	Chime
}
import herd.schedule.chime.cron {
	calendar
}


"Restricts time to the given months."
since("0.3.0") by("Lis")
class Annually(Set<Month> months) satisfies Calendar 
{
	shared actual Boolean inside(DateTime date) => date.month in months;
	
	shared actual DateTime nextOutside(DateTime date) {
		if (inside(date)) {
			variable DateTime ret = date.plusMonths(1);
			ret = dateTime(ret.year, ret.month, 1, ret.hours, ret.minutes, ret.seconds, 0);
			while (inside(ret)) {
				ret = ret.plusMonths(1);
			}
			return ret;
		}
		else {
			return date;
		}
	}
}


"Service provider of annually calendar.  
 I.e. calendar which excludes a given list of months.  
 To apply this calendar to the given timer / scheduler add to the JSON create request with following `JsonObject`:
		\"calendar\" -> JsonObject {
			\"type\" -> \"annually\";
 			// monthes to be excluded from the fire event
 			// digital, full or short (3 letters) string names are admitted
			\"months\" -> JsonArray{1, February, Mar}
 		};
 "
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class AnnuallyFactory() satisfies CalendarFactory
{
	shared actual Calendar|<Integer->String> create(ChimeServices services, JsonObject options) {
		if (is JsonArray months = options[Chime.date.months]) {
			try {
				return Annually(set{for (item in months.narrow<Integer|String>()) monthOf(calendar.digitalMonth(item))}); 
			}
			catch (AssertionError err) {
				return Chime.errors.assertionErrorCode -> err.message;
			}
		}
		else {
			return Chime.errors.codeAnnuallyCalendarMonths-> Chime.errors.annuallyCalendarMonths;
		}
	}
	
	shared actual String type => Chime.calendar.annually;
	
}
