import herd.schedule.chime {
	TimerFire
}
import ceylon.json {
	ObjectValue
}


"Extension which provides messages to be added to a timer fire event.  
 Generally, a message source is instantiated by [[MessageSourceFactory]] given as service provider,
 see [[package herd.schedule.chime.service]].  
 
 It is proposed that message attached to the timer create request contains some info for this source.  
 The message source may use this info to extract provided message.  
 "
since("0.3.0") by("Lis")
see(`interface MessageSourceFactory`)
shared interface MessageSource
{
	"Extracts message and message headers from this source.  
	 When message and message headers are ready call `onMessage` handler."
	shared formal void extract (
		"Event the message to be attached to.  
		 [[TimerFire.message]] is taken from timer or scheduler create request.  
		 In the sent event the message is to be replaced with one the given to `onMessage` handler."
		TimerFire event,
		"Handler which takes the message and message headers when ready.  
		 Headers are to be added to a timer delivery options."
		Anything(ObjectValue?, Map<String,String>?) onMessage
	);
}
