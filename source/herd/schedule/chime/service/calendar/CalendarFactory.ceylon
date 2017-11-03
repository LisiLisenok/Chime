import herd.schedule.chime.service {
	ChimeServices,
	Extension
}
import ceylon.json {
	JsonObject
}


"Calendar provider - creates [[Calendar]]."
since("0.3.0") by("Lis")
shared interface CalendarFactory satisfies Extension<Calendar>
{
	"Creates new calendar with the given description.  
	 Returns created [[Calendar]] or error code -> message pair if some error occured."
	shared actual formal Calendar|<Integer->String> create (
		"Provides Chime services." ChimeServices services,
		"Options with \"calendar\" description." JsonObject options
	);
	
}
