"Provides message source services.  
 
 A timer may fire with a message attached to the fire event. The message and message headers may be extracted from some source.  
 [[MessageSource]] provides a way to extract messages. A service provider implementing [[MessageSourceFactory]]
 is responsible to instantiate particular [[MessageSource]].    
 
 built-in message sources:  
 * direct source, which attaches to the fire event a message given at timer create request,
   created by [[herd.schedule.chime.service.message::DirectMessageSourceFactory]].  
 
 To build your own [[herd.schedule.chime.service.message::MessageSource]] follow the steps:  
 1. Implement [[herd.schedule.chime.service.message::MessageSourceFactory]].  
 2. Mark the class from 1. with `service(`\` `interface MessageSourceFactory`\` `)`.  
 3. Deploy _Chime_ with configuration provided modules to serach the services:  
 		JsonObject {
 			\"services\" -> [\"module name/module version\"]
 		}
  
 In timer or scheduler create request message source can be specified under \"message source\" key.  
 Additional configuration passed to the factory may be given under \"message source configuration\" key.  
  
 > At scheduler level default message source may be specified, which is applied to timer if no message source
   is given at timer create request.  
 "
since("0.3.0") by("Lis")
shared package herd.schedule.chime.service.message;
