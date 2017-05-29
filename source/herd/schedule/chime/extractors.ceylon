import herd.schedule.chime.service {
	ChimeServices
}
import herd.schedule.chime.service.message {
	MessageSource
}
import herd.schedule.chime.service.timezone {
	TimeZone
}
import ceylon.json {
	JsonObject
}
import herd.schedule.chime.service.producer {
	EventProducer
}


"Services extracted from request."
since("0.3.0") by("Lis")
final class ExtractedServices (
	shared TimeZone timeZone,
	shared MessageSource messageSource,
	shared EventProducer eventProducer
) {}


"Extract services (time zone and message source) from timer or scheduler request."
since("0.3.0") by("Lis")
ExtractedServices|<Integer->String> servicesFromRequest (
	"Timer description to get time zone name." JsonObject request,
	"Services Chime provides." ChimeServices services,
	"Default time zone applied if no time zone name is given." TimeZone defaultTimeZone,
	"Default time zone applied if no time zone name is given." MessageSource defaultMessageSource,
	"Default event producer applied if no one given at timer create request."
	EventProducer defaultProducer
) {
	value converter = timeZoneFromRequest(request, services, defaultTimeZone);
	if (is TimeZone converter) {
		value messageSource = messageSourceFromRequest(request, services, defaultMessageSource);
		if (is MessageSource messageSource) {
			value eventProducer = eventProducerFromRequest(request, services, defaultProducer);
			if (is EventProducer eventProducer) {
				return ExtractedServices(converter, messageSource, eventProducer);
			}
			else {
				return eventProducer;
			}
		}
		else {
			return messageSource;
		}
	}
	else {
		return converter;
	}
	
}


"Extracts time zone from timer or scheduler request."
since("0.3.0") by("Lis")
TimeZone|<Integer->String> timeZoneFromRequest (
	"Timer description to get time zone name." JsonObject request,
	"Services Chime provides." ChimeServices services,
	"Default time zone applied if no time zone name is given." TimeZone defaultTimeZone
) {
	if (is String providerType = request[Chime.timeZoneProvider.key]) {
		return services.createTimeZone(providerType, request);
	}
	else if (is String timeZone = request[Chime.key.timeZone]) {
		return services.createTimeZone(Chime.timeZoneProvider.jvm, request);
	}
	else {
		return defaultTimeZone;
	}
}


"Extracts message source from timer or scheduler request."
since("0.3.0") by("Lis")
MessageSource|<Integer->String> messageSourceFromRequest (
	"Timer description to get time zone name." JsonObject request,
	"Services Chime provides." ChimeServices services,
	"Default time zone applied if no time zone name is given." MessageSource defaultMessageSource
) {
	if (is String providerType = request[Chime.messageSource.key]) {
		return services.createMessageSource (
			providerType,
			request.getObjectOrNull(Chime.key.messageSourceOptions) else JsonObject{}
		);
	}
	else {
		return defaultMessageSource;
	}
}


"Extracts Event producer from timer or scheduler request."
since("0.3.0") by("Lis")
EventProducer|<Integer->String> eventProducerFromRequest (
	"Timer description to get time zone name." JsonObject request,
	"Services Chime provides." ChimeServices services,
	"Default event producer applied if no one given at timer create request."
	EventProducer defaultProducer
) {
	if (is String providerType = request[Chime.eventProducer.key]) {
		return services.createEventProducer (
			providerType,
			request.getObjectOrNull(Chime.key.eventProducerOptions) else JsonObject{}
		);
	}
	else {
		if (exists opts = request.getObjectOrNull(Chime.key.eventProducerOptions)) {
			return services.createEventProducer(Chime.eventProducer.eventBus, opts);
		}
		else {
			return defaultProducer;
		}
	}
}