import herd.schedule.chime.service {
	ChimeServices,
	Extension
}
import ceylon.json {
	JsonObject
}
import herd.schedule.chime {
	Chime
}
import io.vertx.ceylon.core.eventbus {
	EventBus,
	deliveryOptions
}


"Factory which creates [[EventBusProducer]]"
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class EBProducerFactory satisfies ProducerFactory
{

	"Creates default producer, which operates via the given event bus and sends events (rather than publishes)."
	shared static EventProducer createDefaultProducer(EventBus eventBus) => EventBusProducer(eventBus, false, null);
	
	"New `ProducerFactory` instance."
	shared new () {}
	
	shared actual EventProducer|<Integer->String> create(ChimeServices services, JsonObject options)
		=> EventBusProducer (
			services.vertx.eventBus(),
			if (is Boolean b = options[Chime.eventProducer.publish]) then b else false,
			if (is JsonObject opts = options[Chime.eventProducer.deliveryOptions]) 
			then deliveryOptions.fromJson(opts) else null
		);
	
	shared actual String type => Chime.eventProducer.eventBus;
	
	shared actual String string => "EventBus producer factory.";
}
