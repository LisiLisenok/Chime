import ceylon.time {
	Time,
	Period,
	DateTime,
	time
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


"Resticts timer fire to to the given time range."
since("0.3.0") by("Lis")
class Daily(Time from, Time to, Period tolerancePeriod) satisfies Calendar
{
	Time shifted = to.plus(tolerancePeriod);
	
	shared actual Boolean inside(DateTime date) {
		value t = date.time;
		return t >= from && t <= to;
	}
	
	shared actual DateTime nextOutside(DateTime date) {
		if (inside(date)) {
			return date.date.at(shifted);
		}
		else {
			return date;
		}
	}
}


"Service provider of daily calendar.  
 I.e. calendar which excludes _from - to_ time of day.  
 To apply this calendar to the given timer / scheduler add to the JSON create request with following `JsonObject`:
 		\"calendar\" -> JsonObject {
 			\"type\" -> \"daily\";
 			// start time to be excluded
 			\"from\" -> JsonObject {
 				\"hours\" -> XXX; // default is 0
 				\"minutes\" -> XXX; // default is 0
 				\"seconds\" -> XXX; // default is 0
 			};
 			// end time to be excluded
 			\"to\" -> JsonObject {
 				\"hours\" -> XXX; // default is 0
 				\"minutes\" -> XXX; // default is 0
 				\"seconds\" -> XXX; // default is 0
 			};
 			// seconds to be added to the 'to' time when next out of calendar date is searched, default is 1s
 			\"tolerance\" -> XXX; 
		};
 "
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class DailyFactory() satisfies CalendarFactory
{
	
	Time timeFromJson(JsonObject descr)
		=> time (
			if (is Integer t = descr[Chime.date.hours]) then t else 0,
			if (is Integer t = descr[Chime.date.minutes]) then t else 0,
			if (is Integer t = descr[Chime.date.seconds]) then t else 0
		);
	
	shared actual Calendar|<Integer->String> create(ChimeServices services, JsonObject options) {
		if (is JsonObject fromDescr = options[Chime.calendar.from],
			is JsonObject toDescr = options[Chime.calendar.to]
		) {
			Time from = timeFromJson(fromDescr);
			Time to = timeFromJson(toDescr);
			if (to > from) {
				return Daily (
					from, to,
					Period{seconds = if (is Integer t = options[Chime.calendar.tolerance]) then t else 1;}
				);
			}
			else {
				return Chime.errors.codeDailyCalendarOrder -> Chime.errors.dailyCalendarOrder;
			}
		}
		else {
			return Chime.errors.codeDailyCalendarFormat -> Chime.errors.dailyCalendarFormat;
		}
	}
	
	shared actual String type => Chime.calendar.daily;
	
}
