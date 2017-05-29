import herd.schedule.chime.service {
	Extension,
	ChimeServices
}
import ceylon.json {
	JsonObject
}


"Time zone provider - creates [[TimeZone]]."
since("0.3.0") by("Lis")
shared interface TimeZoneFactory satisfies Extension<TimeZone>
{
	"Creates new time zone with the given time zone name.  
	 Returns created [[TimeZone]] or error code -> message pair if some error occured."
	shared actual formal TimeZone|<Integer->String> create (
		"Provides Chime services." ChimeServices services,
		"Options with \"time zone\" key given." JsonObject options
	);
		
}
