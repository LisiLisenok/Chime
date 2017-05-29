"Provides timer services.  
 
 Built-in and custom timers are provided with [[TimeRow]] interface.  
 The interface is similar to time enumerator, but allows to restart enumeration from some time.  
 [[TimeRow]] is created using service provider represented with [[TimeRowFactory]] interface.  
 
 Built-in time rows and factories:  
 * cron-style time row created by [[CronFactory]]  
 * interval time row created by [[IntervalFactory]]  
 * union time row created by [[UnionFactory]]  
 
 To build your own [[TimeRow]] (i.e. timer) follow the steps:  
 1. Implement [[TimeRowFactory]].  
 2. Mark the class from 1. with `service(`\` `interface Extension`\` `)`.  
 3. Deploy _Chime_ with configuration provided modules to serach the services:  
 		JsonObject {
 			\"services\" -> [\"module name/module version\"]
 		}

 "
since("0.3.0") by("Lis")
shared package herd.schedule.chime.service.timer;
