import herd.schedule.chime.service {
	ChimeServices,
	MessageSource,
	TimeZone
}
import ceylon.json {
	JsonObject
}


"Extract services (time zone and message source) from timer or scheduler request."
since( "0.3.0" ) by( "Lis" )
[TimeZone, MessageSource]|<Integer->String> servicesFromRequest (
	"Timer description to get time zone name." JsonObject request,
	"Services Chime provides." ChimeServices services,
	"Default time zone applied if no time zone name is given." TimeZone defaultTimeZone,
	"Default time zone applied if no time zone name is given." MessageSource defaultMessageSource
) {
	value converter = timeZoneFromRequest( request, services, defaultTimeZone );
	if ( is TimeZone converter ) {
		value messageSource = messageSourceFromRequest( request, services, defaultMessageSource );
		if ( is MessageSource messageSource ) {
			return [converter, messageSource];
		}
		else {
			return messageSource;
		}
	}
	else {
		return converter;
	}
	
}


"Extract time zone from timer or scheduler request."
since( "0.3.0" ) by( "Lis" )
TimeZone|<Integer->String> timeZoneFromRequest (
	"Timer description to get time zone name." JsonObject request,
	"Services Chime provides." ChimeServices services,
	"Default time zone applied if no time zone name is given." TimeZone defaultTimeZone
) {
	String providerType = if ( is String t = request[Chime.timeZoneProvider.key] ) then t else Chime.timeZoneProvider.jvm;
	if ( is String timeZoneID = request[Chime.key.timeZone] ) {
		return services.createTimeZone( providerType, timeZoneID );
	}
	else {
		return defaultTimeZone;
	}
}


"Extract message source from timer or scheduler request."
since( "0.3.0" ) by( "Lis" )
MessageSource|<Integer->String> messageSourceFromRequest (
	"Timer description to get time zone name." JsonObject request,
	"Services Chime provides." ChimeServices services,
	"Default time zone applied if no time zone name is given." MessageSource defaultMessageSource
) {
	if ( is String providerType = request[Chime.messageSource.key] ) {
		return services.createMessageSource( providerType, request.getObjectOrNull( Chime.key.messageSourceConfig ) );
	}
	else {
		return defaultMessageSource;
	}
}
