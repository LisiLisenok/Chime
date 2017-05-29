import ceylon.json {
	JsonObject
}
import herd.schedule.chime.service {
	Extension,
	ChimeServices
}


"Creates message source."
since("0.3.0") by("Lis")
shared interface MessageSourceFactory satisfies Extension<MessageSource>
{
	"Creates new message source."
	shared actual formal MessageSource|<Integer->String> create (
		"Provides Chime services." ChimeServices services,
		"Message source configuration came with scheduler or timer create request." JsonObject config
	);
}
