import ceylon.json {
	JsonObject
}
import io.vertx.ceylon.core {
	
	Vertx
}
import herd.schedule.chime.service.timer {
	TimeRow,
	TimeRowFactory
}
import herd.schedule.chime.service.timezone {
	TimeZone
}
import herd.schedule.chime.service.message {
	MessageSource
}
import herd.schedule.chime.service.producer {
	EventProducer
}
import herd.schedule.chime {
	Chime
}


"Provides Chime services:  
 * creating [[TimeRow]] by the given timer description  
 * creating [[TimeZone]] with the given provider and the given time zone  
 * creating [[MessageSource]] with the given provider and the given details of the source  
 "
see(`interface TimeRowFactory`)
since("0.3.0") by("Lis")
shared interface ChimeServices
{
	
	shared formal Service|<Integer->String> createService<Service> (
		"Type of the service provider." String providerType,
		"Options passed to service provider." JsonObject options
	);
	
	"Creates time row by timer description.  See about description in [[module herd.schedule.chime]]."
	shared default TimeRow|<Integer->String> createTimeRow("Timer description." JsonObject description) {
		if (is String type = description[Chime.key.type]) {
			return createService<TimeRow>(type, description);
		}
		else {
			return Chime.errors.codeTimerTypeHasToBeSpecified->Chime.errors.timerTypeHasToBeSpecified;
		}		
	}
	
	"Creates time zone with given provider and for the given time zone name."
	shared default TimeZone|<Integer->String> createTimeZone (
		"Type of the time zone provider." String providerType,
		"Time zone options." JsonObject options
	) => createService<TimeZone>(providerType, options);
	
	"Creates new message source."
	shared default MessageSource|<Integer->String> createMessageSource (
		"Type of the message source provider." String providerType,
		"Message source options." JsonObject options
	) => createService<MessageSource>(providerType, options);
	
	"Creates new event producer."
	shared default EventProducer|<Integer->String> createEventProducer (
		"Type of the event producer provider." String providerType,
		"Event producer options." JsonObject options
	) => createService<EventProducer>(providerType, options);
	
	"Time zone local to running machine."
	shared formal TimeZone localTimeZone;
	
	"Vertx instance the _Chime_ is running within."
	shared formal Vertx vertx;
	
	"Event bus address the _Chime_ listens to."
	shared formal String address;
}
