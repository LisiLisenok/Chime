import ceylon.json {
	JSON=Object
}


"Returns converter by time zone name."
since( "0.2.1" ) by( "Lis" )
TimeConverter? converterFromRequest (
	"Timer description to get time zone name." JSON request,
	"Factory to instantiate converter" TimeConverterFactory factory,
	"Default converter applied if no time zone given." TimeConverter defaultConverter ) {
	if ( is String timeZoneID = request[Chime.key.timeZone] ) {
		return factory.getConverter( timeZoneID );
	}
	else {
		return defaultConverter;
	}
}
