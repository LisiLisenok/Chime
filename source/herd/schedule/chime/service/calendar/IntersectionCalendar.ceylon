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


"Intersects calendars with logical `and`."
since("0.3.0") by("Lis")
class IntersectionCalendar({Calendar*} calendars) satisfies Calendar
{
	shared actual Boolean inside(DateTime date) {
		for (item in calendars) {
			if (!item.inside(date)) {
				return false;
			}
		}
		return true;
	}
	
	shared actual DateTime nextOutside(DateTime date) {
		variable DateTime ret = date;
		while (inside(ret)) {
			variable DateTime? min = null;
			for (item in calendars) {
				if (item.inside(ret)) {
					value f = item.nextOutside(ret);
					if (exists ff = min) {
						if (f < ff) {min = f;}
					}
					else {min = f;}
				}
			}
			if (exists m = min) {ret = m;}
			else {break;}
		}
		return ret;
	}
	
}


"Service provider of intersection calendar.  
 I.e. calendar which intersects a given list of calendars.  
 To apply this calendar to the given timer / scheduler add to the JSON create request with following `JsonObject`:
 	\"calendar\" -> JsonObject {
 		\"type\" -> \"intersection\";
 		// List of calendars to be intersected.
 		\"calendars\" -> JsonArray {
 			// calendars in `JsonObject`'s
 		} 
 	};
 "
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class IntersectionFactory() satisfies CalendarFactory
{
	shared actual Calendar|<Integer->String> create(ChimeServices services, JsonObject options) {
		value calendars = extractCalendars(services, options);
		if (is {Calendar*} calendars) {
			return IntersectionCalendar(calendars);
		}
		else {
			return calendars;
		}
	}
	
	shared actual String type => Chime.calendar.intersection;
	
}