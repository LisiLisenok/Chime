import ceylon.json {
	JsonObject,
	ObjectValue
}
import herd.schedule.chime {

	Chime,
	TimerFire
}
import herd.schedule.chime.service {
	ChimeServices,
	Extension
}


"Factory to create message source which returns message given in timer create request.  
 This is default message source factory."
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class DirectMessageSourceFactory satisfies MessageSourceFactory
{
	
	"Default message source - applies `onMessage` with given event message."
	shared static object directMessageSource satisfies MessageSource {
		shared actual void extract(TimerFire event, Anything(ObjectValue?) onMessage)
			=> onMessage(event.message);
	}
	
	"New `DirectMessageSourceFactory` instance."
	shared new () {}
	
	
	shared actual MessageSource|<Integer->String> create(ChimeServices services, JsonObject config)
		=> directMessageSource;
	
	shared actual String type => Chime.messageSource.direct;
	
}
