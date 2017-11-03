import herd.schedule.chime.service {
	ChimeServices
}
import ceylon.json {
	JsonObject,
	JsonArray
}
import ceylon.collection {
	ArrayList
}
import herd.schedule.chime {
	Chime
}


"Extracts a list of calendars from Json description."
since("0.3.0") by("Lis")
{Calendar*}|<Integer->String> extractCalendars(ChimeServices services, JsonObject options) {
	if (is JsonArray calendarDescrs = options[Chime.calendar.calendars]) {
		ArrayList<Calendar> calendars = ArrayList<Calendar>();
		for(item in calendarDescrs.narrow<JsonObject>()) {
			value c = services.createCalendar(item);
			if (is Calendar c) {
				calendars.add(c);
			}
			else {
				return c;
			}
		}
		return calendars;
	}
	else {
		return Chime.errors.codeCalendars-> Chime.errors.calendars;
	}
}
