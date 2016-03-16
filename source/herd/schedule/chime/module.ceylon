
"
 _Chime_ is time scheduler which works on _Vert.x_ event bus and provides:
 * scheduling with _cron-style_ and _interval_ timers
 * applying time zones available on _JVM_
 
 >Compiled for Ceylon 1.2.2 and Vert.x 3.2.2
 
 
 ## Running.
 
 Deploy _Chime_ using `Vertx.deployVerticle` method.  
 
 		import io.vertx.ceylon.core { vertx }
 
 		vertx.vertx().deployVerticle (
 			\"ceylon:herd.schedule.chime/0.1.1\",
 			(String|Throwable res) {
 				...
 			}
 		);

 
 >_Chime_ exchanges events with customers via event bus with `JSON` messages.  
 
 
 ## Configuration.
 
 Following parameters could be specified in `JSON` verticle configuration:
 
 * \"address\" -> address _Chime_ is listen to, `String`, default is \"chime\"
 * \"max year period limit\" -> limiting scheduling period in years, `Integer`, default is 10 years
 * \"tolerance\" -> tolerance in milliseconds used to compare actual and requested times,
   `Integer`, default is 10 milliseconds
 
 
 ## Scheduling.
 
 _Chime_ operates by two structures: _timer_ and _scheduler_.  
 _Scheduler_ is a set or group of timers. At least one _scheduler_ has to be created before creating _timers_.
 
 
 ### _Scheduler_.
 
 ##### Scheduler messages.
 
 In order to maintain _schedulers_ send `JSON` message on _Chime_ address (specified in configuration, \"chime\" is default)
 in the following format:
 		{
 			\"operation\" -> String // operation code, mandatory  
 			\"name\" -> String // scheduler name, mandatory   
 			\"state\" -> String // state, mandatory only if operation = 'state'   
 		}
 
 >_Chime_ listens event bus on \"scheduler name\" address with messages for the given _scheduler_.  
  
 
 ##### Scheduler operation codes.
  
 * \"create\" - create new scheduler with specified name, state and description,
   if state is not specified, scheduler is put to running state.
 * \"delete\" - delete scheduler with name `name`. All timers within _scheduler_ will be canceled.
 * \"info\" - requesting info on _Chime_ or specific scheduler (scheduler name to be provided)
 * \"state\":
 	* if is \"get\" state is to be returned
 	* if is \"running\" scheduler is to be set to _running_, which leads all non paused timers are _running_
 	* if is \"paused\" scheduler is to be set to _paused_, which leads all timers are _paused_
 	* otherwise error is returned
 
 
 ##### Scheduler examples.
 
 	// create new scheduler with name \"scheduler name\"
 	JSON message = JSON { 
 		\"operation\" -> \"create\", 
 		\"name\" -> \"scheduler name\" 
 	} 
  	
  	// change state of scheduler with \"scheduler name\" on paused
 	JSON message = JSON { 
 		\"operation\" -> \"state\", 
 		\"name\" -> \"scheduler name\",  
 		\"state\" -> \"paused\"
 	} 
 	
 	
 ##### Scheduler response.
 
 _Chime_ responds on messages in `JSON` format:  
 		{
 			\"response\" -> String // response code - one of \"ok\" or \"error\"  
 			\"name\" -> String // scheduler name  
 			\"state\" -> String // scheduler state  
 			\"schedulers\" -> JSONArray // scheduler names, exists as response on \"info\" operation with no \"name\" field  
 			\"error\" -> String // error description, exists only if response == \"error\"
 		}

 
 ### _Timer_.
 
 Once _shceduler_ is created _timers_ can be run within.  
 
 There are two ways to access specific timer:
 * sending message on \"scheduler name\" address using timer short name \"timer name\"
 * sending message on _Chime_ address using full timer name which is \"scheduler name:timer name\"
 
 
 >Timer full name is _scheduler name_ and _timer name_ separated with ':', i.e. \"scheduler name:timer name\".
 
 
 >Request on _Chime_ address with _timer full name_ and request on _scheduler_ address with timer full or short name
  are equivalent.  
 
 
 ##### Timer request.
 
 Request has to be sent in `JSON` format on _scheduler name_ address with _timer short name_
 or on _Chime_ address with _timer full name_.  
 Request format:
 
 	{  
 		\"operation\" -> String // operation code, mandatory  
 		\"name\" -> String // timer short or full name, mandatory  
 		\"state\" -> String // state, nonmandatory, except if operation = 'sate'  
 		
 		// fields for create operation:
 		\"maximum count\" -> Integer // maximum number of fires, default - unlimited  
 		\"publish\" -> Boolean // if true message to be published and to be sent otherwise, nonmandatory  
 
 		\"start time\" -> JSON // start time, nonmadatory, if doesn't exist timer will start immediately  
 		{  
 			\"seconds\" -> Integer // seconds, mandatory  
 			\"minutes\" -> Integer // minutes, mandatory  
 			\"hours\" -> Integer // hours, mandatory  
 			\"day of month\" -> Integer // days of month, mandatory  
 			\"month\" -> Integer or String // months, mandatory  
 			\"year\" -> Integer // year, mandatory  
 		}  
 
 		\"end time\" -> `JSON` // end time, nonmadatory, default no end time  
 		{  
 			\"seconds\" -> Integer // seconds, mandatory  
 			\"minutes\" -> Integer // minutes, mandatory  
 			\"hours\" -> Integer // hours, mandatory  
 			\"day of month\" -> Integer // days of month, mandatory  
 			\"month\" -> Integer or String // months, mandatory  
 			\"year\" -> Integer // year, mandatory  
 		}  
 
 		\"time zone\" -> String // time zone ID, nonmandatory, default server local  
 
 		\"description\" -> JSON // timer desciption, mandatoty for create operation  
 	}  
 
 
 >_Chime_ address could be specified in `verticle` configuration, default is \"chime\".  
 
 
 ##### Timer operation codes.
   
 * \"create\" - create new timer with specified name, state and description
 * \"delete\" - delete timer with name `name`
 * \"info\" - get information on timer (if timer name is specified) or scheduler (if timer name is not specified)
 * \"state\":
 	* if state field is \"get\" timer state is to be returned
 	* if state field is \"running\" timer state is to be set to _running_
 	* if state field is \"paused\" timer state is to be set to _paused_
 	* otherwise error is returned
 
 >Timer fires only if both _timer_ and _scheduler_ states are _running_.   
 
 
 ##### Supported timers.
 
 Timer is specified within _description_ field of timer creation request.  
  
 * __Cron style timer__. Timer which is defined like _cron_, but with some simplifications  
 		{  
 			\"type\" -> \"cron\" // timer type, mandatory  	
 
 			\"seconds\" -> String // seconds in cron style, mandatory  
 			\"minutes\" -> String // minutes in cron style, mandatory  
 			\"hours\" -> String // hours in cron style, mandatory  
 			\"days of month\" -> String // days of month in cron style, mandatory  
 			\"months\" -> String // months in cron style, mandatory  
 			\"days of week\" -> String // days of week in cron style, L means last, # means nth of month, nonmandatory  
 			\"years\" -> String // year in cron style, nonmandatory   		
 		}  
   All fields can be specified using following notations:
     * `FROM`-`TO`/`STEP`
     * `FROM`/`STEP`
     * `FROM`-`TO`
     * '*' means any allowed
     * month can be specified using digits (1 is for January) or using names (like 'jan' or 'january', case insensitive)
     * day of week can be specified using digits (1 is for Sunday) or using names (like 'sun' or 'sunday', case insensitive)  
   
 ------------------------------------------  
   
 * __Interval timer__. Timer which fires after each given time period (minimum 1 second)
 		{  
 			\"type\" -> \"interval\" // timer type, mandatory  	
 			\"delay\" -> Integer // timer delay in seconds, if <= 0 timer fires only once, mandatory
 		}
 
 >Interval timer delay is in _seconds_
 
 
 ##### Scheduler response on timer request.
 
 _Chime_ responds on each request in `JSON` format:  
 	{  
 		\"response\" -> String // response code - one of `ok` or `error`  
 		\"name\" -> String //  timer name  
 		\"state\" -> String // state  
 		
 		\"error\" -> String // error description, exists only if response == `error`
 		\"timers\" -> JSONArray // list of timer names currently scheduled - response on info operation with no name field specified
 		
 		// 'Info' operation returns fields from 'create' operation
 	}  
 
 
 ##### Timer firing.
 
 When _timer_ fires it sends or publishes `JSON` message on _full timer name_ address in the following format:
 
 		{  
 			\"name\" -> String, timer name
 			\"count\" -> Integer, total number of fire times
 			\"state\" -> String, timer state, one of 'running', 'paused' or 'completed'
 			\"time\" -> String formated time / date
 			\"seconds\" -> Integer, number of seconds since last minute
 			\"minutes\" -> Integer, number of minutes since last hour
 			\"hours\" -> Integer, hour of day
 			\"day of month\" -> Integer, day of month
 			\"month\" -> Integer, month
 			\"year\" -> Integer, year
 			\"time zone\" -> String, time zone ID
 		}
 
 
 >_Timer full name_ is _scheduler name_ and _timer name_ separated with ':', i.e. \"scheduler name:timer name\".  
 
 
 >Timer _sends_ or _publishes_ message depending on \"publish\" field in timer description (passed at timer creation request).  
  
 
 >String formatted time / date is per [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601).  
 
 
 ##### Time zones.
 
 [list of available time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones),
 actual availability may depend on particular JVM installation.  
 
 see also [time zones and JRE](http://www.oracle.com/technetwork/java/javase/dst-faq-138158.html).
 
 
 ##### Timer example.
 
 		// creat new Scheduler with name \"schedule manager\" at first and then the timer
 		eventBus.send<JSON> (
 			\"chime\",
 			JSON {
 				\"operation\" -> \"create\",
 				\"name\" -> \"schedule manager\",
 				\"state\" -> \"running\"
 			},
 			(Throwable|Message<JSON> msg) {
 				if (is Message<JSON> msg) {
 					// create timer
 					eventBus.send<JSON>(
 						\"chime\",
 						JSON {
 							\"operation\" -> \"create\",
 							\"name\" -> \"schedule manager:scheduled timer\", // full timer name == address to listen timer
 							\"state\" -> \"running\",
 							\"publish\" -> false, // timer will send messages
 							\"max count\" -> 3,
 							\"time zone\" -> \"Europe/Paris\",
 							\"descirption\" -> JSON {
 								\"type\" -> \"cron\", // timer type is 'cron'
 								\"seconds\" -> \"27/30\", // 27 with step 30 leads to fire at 27 and 57 seconds
 								\"minutes\" -> \"*\", // every minute
 								\"hours\" -> \"0-23\", // every hour
 								\"days of month\" -> \"1-31\", // every day
 								\"months\" -> \"january-OCTOBER\", // from January and up to October
 								\"days of week\" -> \"sat#2,sunday\", // at second Saturday and at each Sunday 
 								\"years\" -> \"2015-2019\"
 							}
 						},
 						(Throwable|Message<JSON> msg) {
 							print(msg); // Chime replies if timer successfully created or some error occured
 						}
 					);
 				}
 				else {
 					print(\"time scheduler creation error: \`\`msg\`\`\");
 				}
 			}
 		);
 		
 		// listen timer
 		eventBus.consumer (
 			\"schedule manager:scheduled timer\",
 			(Throwable | Message<JSON> msg) {
 				...
 			}
 		);
 
 
 ### Error messages.
 
 When error occured _Chime_ replies on corresponding message with error:
 		{
 			\"response\" -> \"error\"  
 			\"error\" -> String with error description
 		}
 
 possible errors (see [[value errorMessages]]):
 * \"unsupported operation\"
 * \"operation has to be specified\"
 * \"scheduler doesn't exist\"
 * \"scheduler name has to be specified\"
 * \"scheduler state has to be one of - 'get', 'paused', 'running'\"
 * \"state has to be specified\"
 * \"timer already exists\"
 * \"timer doesn't exist\"
 * \"timer name has to be specified\"
 * \"timer type has to be specified\"
 * \"unsupported timer type\"
 * \"incorrect start date\"
 * \"incorrect end date\"
 * \"end date has to be after start date\"
 * \"unsupported time zone\"
 * \"timer description has to be specified\"
 * \"timer state has to be one of - 'get', 'paused', 'running'\"
 * \"delay has to be specified\"
 * \"delay has to be greater than zero\"
 * \"incorrect cron timer description\"
 
 
 ## Cron expressions.
 
 
 ##### Expression fields.
 
 * _seconds_, mandatory
 	* allowed values: 0-59
 	* allowed special characters: , - * /
 * _minutes_, mandatory
 	* allowed values: 0-59
 	* allowed special characters: , - * /
 * _hours_, mandatory
 	* allowed values: 0-23
 	* allowed special characters: , - * /
 * _days of month_, mandatory
 	* allowed values 1-31
 	* allowed special characters: , - * /
 * _months_, mandatory
 	* allowed values 1-12, Jan-Dec, January-December
 	* allowed special characters: , - * /
 * _days of week_, nonmandatory
 	* allowed values 1-7, Sun-Sat, Sunday-Saturday
 	* allowed special characters: , - * / L #
 * _years_, nonmandatory
 	* allowed values 1970-2099
 	* allowed special characters: , - * /

 
 >Names of months and days of the week are _not_ case sensitive.
 
 
 ##### Special characters.
 
 * '*' means all values
 * ',' separates list items
 * '-' specifies range, for example, '10-12' means '10, 11, 12'
 * '/' specifies increments, for example, '0/15' in seconds field means '0,15,30,45',
   '0-30/15' means '0,15,30'
 * 'L' has to be used after digit and means _the last xxx day of the month_,
   for example, '6L' means _the last friday of the month_
 * '#' has to be used with digits before and after: 'x#y' and means _the y'th x day of the month_,
   for example, '6#3' means _the third Friday of the month_ 
 
 "
license (
	"The MIT License (MIT)
	 
	 Permission is hereby granted, free of charge, to any person obtaining a copy
	 of this software and associated documentation files (the \"Software\"), to deal
	 in the Software without restriction, including without limitation the rights
	 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	 copies of the Software, and to permit persons to whom the Software is
	 furnished to do so, subject to the following conditions:
	 
	 The above copyright notice and this permission notice shall be included in all
	 copies or substantial portions of the Software.
	 
	 THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	 SOFTWARE."
)
by( "Lis" )
native( "jvm" )
module herd.schedule.chime "0.1.1" {
	shared import io.vertx.ceylon.core "3.2.2";
	import ceylon.time "1.2.2";
}
