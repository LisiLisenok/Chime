import ceylon.time {
	DateTime
}
import herd.schedule.chime.service {
	ChimeServices,
	Extension
}
import ceylon.json {
	JsonObject,
	JsonArray
}
import herd.schedule.chime {
	Chime
}


"Retricts time to the given days of month."
since("0.3.0") by("Lis")
class Monthly(Set<Integer> restrictedDays) satisfies Calendar 
{
	shared actual Boolean inside(DateTime date) => date.day in restrictedDays;
	
	shared actual DateTime nextOutside(DateTime date) {
		variable DateTime ret = date;
		while (inside(ret)) {
			ret = ret.plusDays(1);
		}
		return ret;
	}
}

"Service provider of monthly calendar.  
 I.e. calendar which excludes a given list of days for every month.  
 To apply this calendar to the given timer / scheduler add to the JSON create request with following `JsonObject`:
 	\"calendar\" -> JsonObject {
 		\"type\" -> \"monthly\";
 		\"days of month\" -> JsonArray{1, 2, 3} // days to be excluded from the fire event
 	};
 "
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class MonthlyFactory() satisfies CalendarFactory
{
	shared actual Calendar|<Integer->String> create(ChimeServices services, JsonObject options) {
		if (is JsonArray days = options[Chime.date.daysOfMonth]) {
			return Monthly(set(days.narrow<Integer>())); 
		}
		else {
			return Chime.errors.codeMonthlyCalendarDaysOfMonth-> Chime.errors.monthlyCalendarDaysOfMonth;
		}
	}
	
	shared actual String type => Chime.calendar.monthly;
	
}
