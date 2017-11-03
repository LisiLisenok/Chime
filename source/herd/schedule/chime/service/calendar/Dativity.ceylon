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


"Restricts time to the given dates."
since("0.3.0") by("Lis")
class Dativity(Set<DayMonth> dates) satisfies Calendar 
{	
	shared actual Boolean inside(DateTime date) => DayMonth.fromDate(date.date) in dates;
	
	shared actual DateTime nextOutside(DateTime date) {
		variable DateTime ret = date;
		while (inside(ret)) {
			ret = ret.plusDays(1);
		}
		return ret;
	}	
}


"Service provider of dativity calendar.  
 I.e. calendar which excludes a given list of dates.  
 To apply this calendar to the given timer / scheduler add to the JSON create request with following `JsonObject`:
 	\"calendar\" -> JsonObject {
 		\"type\" -> \"dativity\";
 		// List of dates to be excluded from the fire event.
 		// Each date is JsonObject which contains day, month and optionally year.
 		// If year is omitted the date is applied to any year
 		// If only a one date is given it can be specified without JsonArray, i.e. JsonObject can be stored under dates key
 		\"dates\" -> JsonArray {
 			JsonObject {
 				\"day\" -> Integer day
 				\"month\" -> Integer or String month
 				\"year\" -> Integer year, optional
 			}
 		} 
 	};
"
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class DativityFactory() satisfies CalendarFactory
{
	shared actual Calendar|<Integer->String> create(ChimeServices services, JsonObject options) {
		value dativity = options[Chime.calendar.dates];
		if (is JsonArray dativity) {
			try {
				return Dativity(set{for(item in dativity.narrow<JsonObject>()) DayMonth.fromJson(item)});
				
			}
			catch (AssertionError err) {
				return Chime.errors.assertionErrorCode -> err.message;
			}
		}
		else if (is JsonObject dativity) {
			try {
				return Dativity(set{DayMonth.fromJson(dativity)});
				
			}
			catch (AssertionError err) {
				return Chime.errors.assertionErrorCode -> err.message;
			}
		}
		else {
			return Chime.errors.codeDativityCalendarDates-> Chime.errors.dativityCalendarDates;
		}
	}
	
	shared actual String type => Chime.calendar.dativity;
	
}
