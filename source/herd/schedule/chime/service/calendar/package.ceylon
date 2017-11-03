"Provides calendar services.  
 
 Calendar restricts date/time a timer fires at.
 So, when calendar is added to timer,
 timer will not fire at dates/time calendar specifies.  
 In order to add calendar to the timer put calendar description to timer
 create request under \"calendar\" key. See desciption details at each given calendar.  
 
 If calendar is applied at scheduler level then each timer within the scheduler
 with unspecified calendar will get the cheduler level calendar.
 
 To build your own [[Calendar]] follow the steps:  
 1. Implement [[CalendarFactory]].  
 2. Mark the class from 1. with `service(`\` `interface Extension`\` `)`.  
 3. Deploy _Chime_ with configuration provided modules to serach the services:  
 		JsonObject {
 			\"services\" -> [\"module name/module version\"]
 		}
 
 "
since("0.3.0") by("Lis")
shared package herd.schedule.chime.service.calendar;
