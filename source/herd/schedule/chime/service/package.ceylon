"Chime extensions with service providers.
 
 > See also `ceylon.language.service` annotation.  
 
 
 ## Service providers.  
 
 Chime searches service providers only in modules specified in verticle deployed configuration:  
  		JsonObject modulesWithProviders = JsonObject {
 			\"services\" -> [
 				\"module 1 name/module 1 version\",
 				\"module nth name/module nth version\"
 			]
 		};
 		Chime().deploy (
 			vertx.vertx(),
 			DeploymentOptions(modulesWithProviders)
 		);

 
 Each service provider has to satisfy mark interface [[Extension]].  
 
 
 ## Time row.  
 
 Provides built-in and custom timers through [[TimeRow]] interface.  
 The interface is similar to time enumerator, but allows to restart enumeration from some time.  
 [[TimeRow]] is created using service provider represented with [[TimeRowFactory]] interface.  
 
 Built-in time rows and factories:  
 * cron-style time row created by [[CronFactory]]  
 * interval time row created by [[IntervalFactory]]  
 * union time row created by [[UnionFactory]]  
 
 To build your own [[TimeRow]] (i.e. timer) follow the steps:  
 1. Implement [[TimeRowFactory]].  
 2. Mark the class from 1. with `service(`\` `interface TimeRowFactory`\` `)`.  
 3. Deploy _Chime_ with configuration provided modules to serach the services:  
 		JsonObject {
 			\"services\" -> [\"module name/module version\"]
 		}
 
 
 ## Time zone.  
 
 [[TimeZone]] provides converting time from / to the given time zone.  
 
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
 
 
 ## Message source.  
 
 A timer may fire with a message attached to the fire event. The message and message headers may be extracted from some source.  
 [[MessageSource]] provides a way to extract messages. A service provider implementing [[MessageSourceFactory]]
 is responsible to instantiate particular [[MessageSource]].    
 
 built-in message sources:  
 * direct source, which attaches to the fire event a message given at timer create request,
   created by [[DirectMessageSourceFactory]].  
 
 To build your own [[MessageSource]] follow the steps:  
 1. Implement [[MessageSourceFactory]].  
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
since( "0.3.0" ) by( "Lis" )
shared package herd.schedule.chime.service;
