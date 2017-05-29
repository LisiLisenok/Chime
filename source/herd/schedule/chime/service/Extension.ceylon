import io.vertx.ceylon.core {
	Vertx
}
import ceylon.json {
	
	JsonObject
}


"Extension (given as service providers) which acts as factory for some _Chime_ structural elements."
since("0.3.0") by("Lis")
shared interface Extension<out Element>
{
	"Type of service the extension provides."
	shared formal String type;
	
	"Initializes the extension.  
	 Has to call `complete` when initialization is completed.  
	 By default immediately calls `complete`."
	shared default void initialize (
		"Vertx instance the _Chime_ is starting within."
		Vertx vertx,
		"Configuration the _Chime_ is starting with."
		JsonObject config,
		"Handler which has to be called when the extension initialization is completed.  
		 The handler takes extension to be added to the _Chime_
		 or an error occured during initialization."
		Anything(Extension<Anything>|Throwable) complete
	) => complete(this);
	
	"Creates new strucutral element."
	shared formal Element|<Integer->String> create (
		"Provides Chime services." ChimeServices services,
		"Options applied to the factory." JsonObject options
	);
	
}
