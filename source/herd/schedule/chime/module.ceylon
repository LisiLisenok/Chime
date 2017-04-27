
"
 _Chime_ is time scheduler which works on _Vert.x_ event bus and provides:  
 * scheduling with _cron-style_ or _interval_ timers  
 * applying time zones available on _JVM_  
 * flexible timers management system:  
 	* grouping timers  
 	* defining timer start or end time  
 	* pausing / resuming  
 	* fire counting  
 * sending messages in _JSON_  
 * _publish_ or _send_ timer fire event to the address of your choice  
 
 
 ## Running.
 
 Deploy _Chime_ using `Verticle.deployVerticle` method.  
 
 		import io.vertx.ceylon.core {vertx}
 		import herd.schedule.chime {Chime}
 		Chime c = Chime().deploy(vertx.vertx());
 
 > _Chime_ exchanges events with customers via event bus using `JSON` messages.  
 
 
 ## Configuration.
 
 Following parameters could be specified in `JSON` verticle configuration:
 
 * **\"address\"** - address _Chime_ is listen to, `String`, default is **\"chime\"**
 * **\"max year period limit\"** - limiting scheduling period in years, `Integer`, default is 10 years
 * **\"tolerance\"** - tolerance in milliseconds used to compare actual and requested times,
   `Integer`, default is 10 milliseconds
 
 
 ## Scheduling.
 
 _Chime_ operates by two structures: _timer_ and _scheduler_.  
 Scheduler is a set or group of timers. At least one scheduler has to be created before creating timers.  
 Each timer operates within some particular scheduler.  
 All messages _Chime_ listens are to be sent to _Chime_ address or to scheduler address.
 
 
 ### _Scheduler_.
 
 #### Scheduler messages.
 
 In order to maintain schedulers send `JSON` message to _Chime_ address (specified in configuration, \"chime\" is default)
 in the following format:
 		{
 			\"operation\" -> String // operation code, mandatory  
 			\"name\" -> String // scheduler name, mandatory   
 			\"state\" -> String // state, mandatory only if operation = 'state'   
 		}
 
 > _Chime_ listens event bus at \"scheduler name\" address with messages for the given scheduler.  
 
 
 #### Scheduler operation codes.
  
 * **\"create\"** - create new scheduler with specified name, state and description,
   if state is not specified, scheduler is put to running state.
 * **\"delete\"** - delete scheduler with name `name`. All timers belong to the scheduler are deleted.
 * **\"info\"** - request info on _Chime_ or on a particular scheduler (scheduler name to be provided)
 * **\"state\"**:
 	* if set to **\"get\"** then state has to be returned
 	* if set to **\"running\"** then scheduler is to be set to _running_, which leads all non paused timers are _running_
 	* if set to **\"paused\"** then scheduler is to be set to _paused_, which leads all timers are _paused_
 	* otherwise error is returned
 
 
 #### Scheduler request examples.
 
 	// create new scheduler with name \"scheduler name\"
 	JSON message = JSON { 
 		\"operation\" -> \"create\", 
 		\"name\" -> \"scheduler name\" 
 	} 
  	
  	// change state of scheduler with \"scheduler name\" to paused
 	JSON message = JSON { 
 		\"operation\" -> \"state\", 
 		\"name\" -> \"scheduler name\",  
 		\"state\" -> \"paused\"
 	} 
 	
 
 #### Scheduler response.
 
 _Chime_ responds on messages in `JSON` format:  
 		{
 			\"name\" -> String // scheduler name  
 			\"state\" -> String // scheduler state  
 		}
 		
 or on **\"info\"** request with no or empty **\"name\"** field
 
 		{
 			\"schedulers\" -> JSONArray // Schedulers info. Each item contains name, state and a list of timers.  
 		}
 where each item of the array is in format:
 		{
 			\"name\" -> String // scheduler name  
 			\"state\" -> String // scheduler state  
 			\"timers\" -> JSONArray // list of scheduler timers
 		} 
 Where each item of the 'timers' array contains the same fields as provided with timer 'create' request (see below).
 Except:
 * 'state' which contains current state
 * 'count' which contains current number of fires.
 
 
 #### Error response.  
 
 The error response is sent using `Message.fail` with corresponding code and message, see [[Chime.errors]]. 
 
 
 #### Requesting info for a number of schedulers.  
 
 Send message: 
 		JSON message = JSON { 
 			\"operation\" -> \"info\", 
 			\"name\" -> JSONArray{\"name1\", ...} 
 		} 
 
 I.e. name field contains JSON array with list of schedulers name.
 _Chime_ responds with:
 		JSON {
 			\"schedulers\" -> JSONArray{...} 
 		}
 
 Where returned JSON array contains info for all schedulers the info is requested for.  
 
 
 #### Deleting all schedulers / timers
 
 Send delete message to the _Chime_ address with empty name or name equal to _Chime_ address:
 		eventBus.send (
 			chimeAddress,
 			JSON {
 				Chime.key.operation -> Chime.operation.delete,
 				Chime.key.name -> \"\"
 			}
 		);
 
 
 ### _Timer_.
 
 Once shceduler is created timers can be run within.  
 
 There are two ways to access a given timer:
 * sending message to \"scheduler name\" address using timer short name \"timer name\"
 * sending message to _Chime_ address using full timer name which is \"scheduler name:timer name\"
 
 
 > Timer full name is _scheduler name_ and _timer name_ separated with ':', i.e. \"scheduler name:timer name\".  
 
 > Timer fire message is sent to _timer full name_ address.  
 
 
 #### Timer request.
 
 Request has to be sent in `JSON` format to _scheduler name_ address with _timer short name_
 or to _Chime_ address with _timer full name_.  
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
 
 
 > _Chime_ address could be specified in `verticle` configuration, default is \"chime\".  
 
 
 #### Timer operation codes.
   
 * **\"create\"** - create new timer with specified name, state and description
 * **\"delete\"** - delete timer with name `name`
 * **\"info\"** - get information for timer (if timer name is specified) or scheduler (if timer name is not specified)
 * **\"state\"**:
 	* if set to **\"get\"** timer state has to be returned
 	* if set to **\"running\"** timer state is to be set to _running_
 	* if set to **\"paused\"** timer state is to be set to _paused_
 	* otherwise error is returned
 
 > Timer fires only if both timer and scheduler states are _running_.   
 
 
 #### Unique timer name.  
 
 The _Chime_ may generate unique timer name automatically. Just follow next steps:  
 1. Set **\"operation\"** field to **\"create\"**.  
 2. Set **\"name\"** field to scheduler name (i.e. omit timer name).  
 3. Fill **\"description\"** field with required timer data.  
 4. Send message to _Chime_ or scheduler address.  
 5. Take the unique timer name from the response.  
 
 
 #### Supported timers.
 
 Timer is specified within _description_ field of timer creation request.  
  
 * __Cron style timer__. Timer which is defined like cron:  
 		{  
 			\"type\" -> \"cron\" // timer type, mandatory  	
 
 			\"seconds\" -> String // seconds in cron style, mandatory, nonempty  
 			\"minutes\" -> String // minutes in cron style, mandatory, nonempty  
 			\"hours\" -> String // hours in cron style, mandatory, nonempty  
 			\"days of month\" -> String // days of month in cron style, mandatory, nonempty  
 			\"months\" -> String // months in cron style, mandatory, nonempty  
 			\"days of week\" -> String // days of week in cron style, L means last, # means nth of month, nonmandatory  
 			\"years\" -> String // year in cron style, nonmandatory   		
 		}  
   Following notations are applicable:
     * `FROM`-`TO`/`STEP`
     * `FROM`/`STEP`
     * `FROM`-`TO`
     * '*' means any allowed
     * month can be specified using digits (1 is for January) or using names (like 'jan' or 'january', case insensitive)
     * day of week can be specified using digits (1 is for Sunday) or using names (like 'sun' or 'sunday', case insensitive)  
 
 > Month and day of week are case insensitive.  
 
 [[CronBuilder]] may help to build JSON description of a cron timer.  
 
 ------------------------------------------  
   
 * __Interval timer__. Timer which fires after each given time period (minimum 1 second):
 		{  
 			\"type\" -> \"interval\" // timer type, mandatory  	
 			\"delay\" -> Integer // timer delay in seconds, if <= 0 timer fires only once, mandatory
 		}
 
 > Interval timer delay is in _seconds_
 
 
 #### Response on a timer request.  
 
 > Remember: timer request has to be sent to _scheduler name_ address with _timer short name_
 or to _Chime_ address with _timer full name_.  

 _Chime_ responds on each request to a scheduler in `JSON` format:  
 	{  
 		\"name\" -> String //  timer name  
 		\"state\" -> String // state  
 		
 		// 'Info' request also returns fields from timer 'create' request
 	}  

 or as response on 'info' request with no or empty 'name' field specified - info for all timers is returned
 
 	{
 		\"timers\" -> JSONArray // list of timer infos currently scheduled
 	}
 
 Where each item of the array contains the same fields as provided with timer 'create' request.
 Except:
 * 'state' which contains current state
 * 'count' which contains current number of fires.
 
 
 #### Error response.  
 
 The error response is sent using `Message.fail` with corresponding code and message, see [[Chime.errors]].
 

 #### Timer events
 
 Timer sends or publishes to _full timer name_ address two types of events in `JSON`:
 * fire event  
 		{  
 			\"name\" -> String, timer name
 			\"event\" -> \"fire\"
 			\"count\" -> Integer, total number of fire times
 			\"time\" -> String formated time / date
 			\"seconds\" -> Integer, number of seconds since last minute
 			\"minutes\" -> Integer, number of minutes since last hour
 			\"hours\" -> Integer, hour of day
 			\"day of month\" -> Integer, day of month
 			\"month\" -> Integer, month
 			\"year\" -> Integer, year
 			\"time zone\" -> String, time zone ID
 		}  
 * complete event  
 		{  
 			\"name\" -> String, timer name
 			\"event\" -> \"complete\"
 			\"count\" -> Integer, total number of fire times
 		}   
 
 > Complete event is always published in order every listener receives it.  
   While fire event may be either published or send depending on 'publish' field in timer create request.  
 
 > The value at the 'event' key indicates the event type (fire or complete).  
 
 > _Timer full name_ is _scheduler name_ and _timer name_ separated with ':', i.e. \"scheduler name:timer name\".  
 
 > String formatted time / date is per [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601).  
 
 
 #### Time zones.
 
 [Available time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones),
 actual availability may depend on particular JVM installation.  
 
 See also [time zones and JRE](http://www.oracle.com/technetwork/java/javase/dst-faq-138158.html).
 
 
 #### Timer example.
 
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
 						(Throwable|Message<JSON?> msg) {
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
 			(Throwable | Message<JSON?> msg) {
 				...
 			}
 		);
 
 
 ### Scheduler and Timer interfaces.
 
 [[Scheduler]] interface provides a convenient way to exchange messages with particular scheduler.  
 In order to connect to already existed scheduler or to create new one [[connectToScheduler]]
 function can be used. The function sends create scheduler request to the _Chime_ and wraps
 the event bus with implementation of [[Scheduler]] interface.  
 
 [[Timer]] interface provides a convenient way to exchange messages with particular scheduler.  
 To get an instance of the [[Timer]] call [[Scheduler.createIntervalTimer]]
 or  [[Scheduler.createCronTimer]].  
 
 Example:
 
 		connectToScheduler (
 			(Throwable|Scheduler scheduler) {
 				if (is Scheduler scheduler) {
 					scheduler.createIntervalTimer (
 						(Throwable|Timer timer) {
 							if (is Timer timer) {
 								timer.handler (
 									(TimerEvent event) {...}
 								);
 							}
 							else {
 								// error while creating timer
 							}
 						},
 						5 // fires each 5 seconds
 					);
 				}
 				else {
 					// error while creating / connecting to scheduler
 				}
 			},
 			\"chime\", eventBus, \"scheduler name\"
 		);
 
 
 ### Error messages.
 
 The error is sent using `Message.fail` with corresponding code and message, see [[Chime.errors]].
 
 possible errors (see [[Chime.errors]]):
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
 
 #### Expression fields.
 
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
 
 
 > Names of months and days of the week are case insensitive.
 
 
 #### Special characters.
 
 * '*' means all values
 * ',' separates list items
 * '-' specifies range, for example, '10-12' means '10, 11, 12'
 * '/' specifies increments, for example, '0/15' in seconds field means '0,15,30,45',
   '0-30/15' means '0,15,30'
 * 'L' has to be used after digit and means _the last xxx day of the month_,
   where xxx is day of week, for example, '6L' means _the last Friday of the month_
 * '#' has to be used with digits before and after: 'x#y' and means _the y'th x day of the month_,
   for example, '6#3' means _the third Friday of the month_ 
 
 
 #### Cron expression builder.  
 
 [[CronBuilder]] may help to build JSON description of a cron timer.
 The builder has a number of function to add particular cron record to the description.
 The function may be called in any order and any number of times.  
 Finally, [[CronBuilder.build]] has to be called to build the timer JSON description.  
 
 Example:  
 		JSON cron = CronBuilder().withSeconds(3).withMinutes(0).withHours(1).withAllDays().withAllMonths().build();
 
 > Note that 'seconds', 'minutes', 'hours', 'days of month' and 'month' are required fields.
   While 'years' and 'days of week' are optional.  
 
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
module herd.schedule.chime "0.2.1" {
	shared import io.vertx.ceylon.core "3.4.1";
	shared import ceylon.time "1.3.2";
	import ceylon.json "1.3.0";
}