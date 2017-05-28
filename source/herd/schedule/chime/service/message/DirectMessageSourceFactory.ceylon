import io.vertx.ceylon.core {
	Vertx
}
import ceylon.json {
	JsonObject,
	ObjectValue
}
import herd.schedule.chime {

	Chime,
	TimerFire
}
import herd.schedule.chime.service {
	Extension,
	ChimeServices
}


"Factory to create message source which returns message given in timer create request.  
 This is default message source factory."
service(`interface MessageSourceFactory`)
since("0.3.0") by("Lis")
shared class DirectMessageSourceFactory() satisfies MessageSourceFactory
{
	
	object directMessageSource satisfies MessageSource {
		shared actual void extract(TimerFire event, Anything(ObjectValue?, Map<String,String>?) onMessage)
			=> onMessage(event.message, null);
	}
	
	shared actual void initialize(Vertx vertx, JsonObject config, Anything(Extension|Throwable) complete)
		=> complete( this );
	
	shared actual MessageSource create(ChimeServices services, JsonObject? config)
		=> directMessageSource;
	
	shared actual String type => Chime.messageSource.direct;
	
}
