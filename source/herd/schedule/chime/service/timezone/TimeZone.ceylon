import ceylon.time {
	DateTime
}


"Convertes date-time according to rule (timezone).  
 Generally, a time zone is instantiated by [[TimeZoneFactory]] given as service provider,
 see [[package herd.schedule.chime.service]]."
see(`interface TimeZoneFactory`)
since("0.3.0") by("Lis")
shared interface TimeZone {
	
	"Converts remote (this time zone) date-time to local (for the current machine) one."
	shared formal DateTime toLocal("Date-time to convert from." DateTime remote);
	
	"Converts local (for the current machine) date-time to remote (to this time zone) one."
	shared formal DateTime toRemote("Date-time to convert from." DateTime local);
	
	"Returns time zone id."
	shared formal String timeZoneID;
}
