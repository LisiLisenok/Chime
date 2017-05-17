import ceylon.json {
	JsonObject
}
import io.vertx.ceylon.core {
	
	Vertx
}


"Provides Chime services:  
 * creating [[TimeRow]] by the given timer description  
 * creating [[TimeZone]] with the given provider and the given time zone  
 "
see( `interface TimeRowFactory` )
since( "0.3.0" ) by( "Lis" )
shared interface ChimeServices
{
	"Creates time row by timer description.  See about description in [[module herd.schedule.chime]]."
	shared formal TimeRow|<Integer->String> createTimeRow( "Timer description." JsonObject description );
	
	"Creates time zone with given provider and for the given time zone name."
	shared formal TimeZone|<Integer->String> createTimeZone (
		"Type of the time zone provider." String providerType,
		"Time zone name." String timeZone
	);
	
	shared formal MessageSource|<Integer->String> createMessageSource (
		"Type of the message source provider." String providerType,
		"Message source configuration came with scheduler or timer create request." JsonObject? config
	);
	
	"Time zone local to running machine."
	shared formal TimeZone localTimeZone;
	
	"Vertx instance the _Chime_ is running within."
	shared formal Vertx vertx;
	
	"Event bus address the _Chime_ listens to."
	shared formal String address;
}
