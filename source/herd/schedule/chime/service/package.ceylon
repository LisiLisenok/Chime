"Chime extensions with service providers.
 
 > See also `ceylon.language.service` annotation.  
 
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
 
 Following services are available:  
 * timer - [[package herd.schedule.chime.service.timer]]  
 * time zone - [[package herd.schedule.chime.service.timezone]]  
 * message source - [[package herd.schedule.chime.service.message]]  
 * calendar - [[package herd.schedule.chime.service.calendar]]   
 
 "
since("0.3.0") by("Lis")
shared package herd.schedule.chime.service;
