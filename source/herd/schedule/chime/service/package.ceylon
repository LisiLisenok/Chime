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

 
 Each service provider has to satisfy [[Extension]] interface
 and be marked with `service(`\` `interface Extension`\` `)` annotation.  
 
 Following services are available:  
 * timer ([[package herd.schedule.chime.service.timer]]) - instantiating built-in or custom timers  
 * time zone ([[package herd.schedule.chime.service.timezone]]) - extracting time zone  
 * message source ([[package herd.schedule.chime.service.message]]) - extracting messages applied to timer fire event  
 * calendar ([[package herd.schedule.chime.service.calendar]]) - creating calendars which can be applied to bound eventing date/time  
 * event producer ([[package herd.schedule.chime.service.producer]]) - creating a producer applied to send timer event  
 
 "
since("0.3.0") by("Lis")
shared package herd.schedule.chime.service;
