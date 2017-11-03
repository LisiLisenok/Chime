import ceylon.json {
	JsonObject
}
import ceylon.time {
	dateTime,
	DateTime
}
import herd.schedule.chime.cron {
	calendar
}


"Reads date-time from JSON into `DateTime`."
since("0.2.0") by("Lis")
DateTime dateTimeFromJSON(JsonObject dateTimeDescr)
	=> dateTime (
		dateTimeDescr.getInteger(Chime.date.year), calendar.monthFromJson(dateTimeDescr, Chime.date.month),
		dateTimeDescr.getInteger(Chime.date.dayOfMonth), dateTimeDescr.getInteger(Chime.date.hours),
		dateTimeDescr.getInteger(Chime.date.minutes), dateTimeDescr.getInteger(Chime.date.seconds)
	);
