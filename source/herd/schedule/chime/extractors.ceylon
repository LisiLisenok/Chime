import herd.schedule.chime.service {
	ChimeServices
}
import herd.schedule.chime.service.message {
	MessageSource
}
import herd.schedule.chime.service.timezone {
	TimeZone
}
import herd.schedule.chime.service.producer {
	EventProducer
}
import herd.schedule.chime.service.calendar {
	Calendar
}
import ceylon.json {
	JsonObject
}


"Extract services (time zone and message source) from timer or scheduler request."
since("0.3.0") by("Lis")
TimeServices|<Integer->String> servicesFromRequest (
	"Timer description to get time zone name." JsonObject request,
	"Services Chime provides." ChimeServices services,
	"Default time services." TimeServices defaultServices
) {
	value converter = timeZoneFromRequest(request, services, defaultServices.timeZone);
	if (is TimeZone converter) {
		value messageSource = messageSourceFromRequest(request, services, defaultServices.messageSource);
		if (is MessageSource messageSource) {
			value eventProducer = eventProducerFromRequest(request, services, defaultServices.eventProducer);
			if (is EventProducer eventProducer) {
				value calendar = calendarFromRequest(request, services, defaultServices.calendar);
				if (is CalendarService calendar) {
					return TimeServices (
						converter, messageSource, eventProducer, calendar
					);
				}
				else {
					return calendar;
				}
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


"Extracts Calendar from timer or scheduler request."
since("0.3.0") by("Lis")
CalendarService|<Integer->String> calendarFromRequest (
	"Timer description to get time zone name." JsonObject request,
	"Services Chime provides." ChimeServices services,
	"Default calendar applied if no one given at timer create request."
	CalendarService defaultCalendar
) {
	if (is JsonObject calendarRequest = request[Chime.calendar.key]) {
		value cl = services.createCalendar(calendarRequest);
		if (is Calendar cl) {
			return CalendarServiceImpl (
				if (is Boolean ignore = calendarRequest[Chime.calendar.ignoreEvent]) then ignore else true,
				cl
			);
		}
		else {
			return cl;
		}
	}
	else {
		return defaultCalendar;
	}
}
