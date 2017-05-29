import io.vertx.ceylon.core.eventbus {
	EventBus,
	DeliveryOptions
}
import herd.schedule.chime {
	TimerEvent,
	TimerCompleted
}
import ceylon.json {
	JsonObject
}


"Sends timer events via event bus."
since("0.3.0") by("Lis")
class EventBusProducer (
	EventBus eventBus,
	Boolean publish,
	DeliveryOptions? options
)
		satisfies EventProducer
{
	
	void publishEvent(TimerEvent event) {
		if (exists opt = options) { eventBus.publish(event.timerName, convert(event), opt); }
		else { eventBus.publish(event.timerName, convert(event)); }
	}
	
	void sendEvent(TimerEvent event) {
		if (exists opt = options) { eventBus.send(event.timerName, convert(event), opt); }
		else { eventBus.send(event.timerName, convert(event)); }
	}
	
	"Converts timer event into `JsonObject` which to be send via event bus.  
	 By default applies [[TimerEvent.toJson]]."
	shared default JsonObject convert(TimerEvent event) => event.toJson();
	
	shared actual void send(TimerEvent event) {
		if (publish || event is TimerCompleted) {
			publishEvent(event);
		}
		else {
			sendEvent(event);
		}
	}
}
