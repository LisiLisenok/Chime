
"Provides time zone services.  
 
 [[TimeZone]] interface provides converting time from / to the given time zone.  
 
 built-in time zones:  
 * time zones available at jvm, created by [[JVMTimeZoneFactory]].  
 
 To build your own [[TimeZone]] follow the steps:  
 1. Implement [[TimeZoneFactory]].  
 2. Mark the class from 1. with `service(`\` `interface TimeZoneFactory`\` `)`.  
 3. Deploy _Chime_ with configuration provided modules to serach the services:  
 		JsonObject {
 			\"services\" -> [\"module name/module version\"]
 		}
 
 In timer or scheduler create request time zone type can be specified under \"time zone provider\" key.  
 
 > At scheduler level default time zone may be specified, which is applied to timer if no time zone
   is given at timer create request.  
"
since("0.3.0") by("Lis")
shared package herd.schedule.chime.service.timezone;
