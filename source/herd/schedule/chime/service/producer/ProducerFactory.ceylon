import herd.schedule.chime.service {
	Extension,
	ChimeServices
}
import ceylon.json {
	JsonObject
}


"Factory to crshared eate [[EventProducer]]."
since("0.3.0") by("Lis")
shared interface ProducerFactory satisfies Extension<EventProducer>
{
	"Creates new event producer."
	shared actual formal EventProducer|<Integer->String> create (
		"Provides Chime services." ChimeServices services,
		"Producer options." JsonObject options
	);	
}
