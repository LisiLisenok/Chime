import ceylon.json {
	
	JsonObject
}


"Creates [[TimeRow]]."
since( "0.1.0" ) by( "Lis" )
shared interface TimeRowFactory satisfies Extension
{
	
	"Creates new time row.  Returns created [[TimeRow]] or error code -> message pair if some error occured."
	shared formal TimeRow|<Integer->String> create (
		"Provides Chime services." ChimeServices services,
		"Timer description." JsonObject description
	);
	
	"Timer type provided with timer create request, see [[module herd.schedule.chime]]."
	shared actual formal String type;
	
}
