import ceylon.json {
	JsonObject
}


"Creates message source."
since( "0.3.0" ) by( "Lis" )
shared interface MessageSourceFactory satisfies Extension
{
	"Creates new message source."
	shared formal MessageSource create (
		"Provides Chime services." ChimeServices services,
		"Message source configuration came with scheduler or timer create request." JsonObject? config
	);
}
