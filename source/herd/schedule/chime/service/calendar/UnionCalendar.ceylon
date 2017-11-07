import ceylon.time {
	DateTime
}
import herd.schedule.chime.service {
	ChimeServices,
	Extension
}
import ceylon.json {
	JsonObject
}
import herd.schedule.chime {
	Chime
}


"Unions calendars with logical `or`."
since("0.3.0") by("Lis")
class UnionCalendar({Calendar*} calendars) satisfies Calendar
{
	shared actual Boolean inside(DateTime date) {
		for (item in calendars) {
			if (item.inside(date)) {
				return true;
			}
		}
		return false;
	}
	
	shared actual DateTime nextOutside(DateTime date) {
		variable DateTime ret = date;
		while (inside(ret)) {
			variable DateTime max = ret;
			for (item in calendars) {
				if (item.inside(ret)) {
					value f = item.nextOutside(ret);
					if (f > max) {max = f;}
				}
			}
			ret = max;
		}
		return ret;
	}
	
}


"Service provider of union calendar.  
 I.e. calendar which unons a given list of calendar.  
 To apply this calendar to the given timer / scheduler add to the JSON create request with following `JsonObject`:
 	\"calendar\" -> JsonObject {
 		\"type\" -> \"union\";
 		// List of calendars to be unioned.
 		\"calendars\" -> JsonArray {
 			// calendars in `JsonObject`'s
 		} 
 	};
 "
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class UnionFactory() satisfies CalendarFactory
{
	
	shared actual Calendar|<Integer->String> create(ChimeServices services, JsonObject options) {
		value calendars = extractCalendars(services, options);
		if (is {Calendar*} calendars) {
			return UnionCalendar(calendars);
		}
		else {
			return calendars;
		}
	}
	
	shared actual String type => Chime.calendar.union;
	
}