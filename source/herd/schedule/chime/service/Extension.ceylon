import io.vertx.ceylon.core {
	Vertx
}
import ceylon.json {
	
	JsonObject
}
import herd.schedule.chime.service.timer {
	TimeRowFactory
}
import herd.schedule.chime.service.timezone {
	TimeZoneFactory
}
import herd.schedule.chime.service.message {
	MessageSourceFactory
}


"Mark interface for the extensions (given as service providers)."
since("0.3.0") by("Lis")
shared interface Extension of TimeRowFactory|TimeZoneFactory|MessageSourceFactory
{
	"Type of service the extension provides."
	shared formal String type;
	
	"Initializes the extension.  
	 Has to call `complete` when initialization is completed."
	shared formal void initialize (
		"Vertx instance the _Chime_ is starting within."
		Vertx vertx,
		"Configuration the _Chime_ is starting with."
		JsonObject config,
		"Handler which has to be called when the extension initialization is completed.  
		 The handler takes extension to be added to the _Chime_
		 or an error occured during initialization."
		Anything(Extension|Throwable) complete
	);
	
}
