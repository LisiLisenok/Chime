# Complete list of json messages.  

## Content.  
* [Scheduler](#scheduler-request)  
	* [create scheduler](#create-scheduler)  
	* [delete scheduler](#delete-scheduler)  
	* [get info on all schedulers](#get-info-on-all-schedulers)  
	* [get info on a given list of schedulers](#get-info-on-a-given-list-of-schedulers)  
	* [get scheduler info](#get-scheduler-info)  
	* [get scheduler state](#get-scheduler-state)  
	* [set scheduler to paused state](#set-scheduler-to-paused-state)  
	* [set scheduler to running state](#set-scheduler-to-running-state)  
* [Timer](#timer-request)  
	* [create timer](#create-timer)  
	* [delete timer](#delete-timer)  
	* [get timer info](#get-timer-info)  
	* [get timer state](#get-timer-state)  
	* [set timer to paused state](#set-timer-to-paused-state)  
	* [set timer to running state](#set-timer-to-running-state)  
* [Timer descriptions](#timer-descriptions)  
	* [cron-style timer](#cron-style-timer)  
	* [interval timer](#interval-timer)  
	* [union timer](#union-timer)  
* [Timer events](#timer-events)  
	* [fire event](#fire-event)  
	* [complete event](#complete-event)  
  

## Scheduler request.  

### Create scheduler.  

Sent to _Chime_ address.  

##### Request.
```json
{
	"operation": "create",
	"name": "scheduler name"
}
```  

##### Response.
```json
{
	"name": "scheduler name",
	"state": "running, paused or completed"
}
```  

-------------

### Delete scheduler.  

Sent to _Chime_ address or to _scheduler_ address.  

##### Request.  
```json
{
	"operation": "delete",
	"name": "scheduler name"
}
```

##### Response.
```json
{
	"name": "scheduler name",
	"state": "completed"
}
```  

-------------

### Get info on all schedulers.  

Sent to _Chime_ address.  

##### Request.  
```json
{
	"operation": "info",
	"name": ""
}
```  

##### Response.
```json
{
	"name": "scheduler name",
	"schedulers": []
}
```  
Where "schedulers" array contains `JsonObject`'s of [scheduler info](#get-scheduler-info).  

-------------

### Get info on a given list of schedulers.  

Sent to _Chime_ address.  

##### Request.  
```json
{
	"operation": "info",
	"name": ["name of first scheduler", "name of second scheduler"]
}
```  
Where "names" is array of Strings with names of schedulers info is requested for.  

##### Response.
```json
{
	"name": "scheduler name",
	"schedulers": []
}
```  
Where "schedulers" array contains `JsonObject`'s of [scheduler info](#get-scheduler-info).  

-------------

### Get scheduler info.  

Sent to _Chime_ address or to _scheduler_ address.  

##### Request.  
```json
{
	"operation": "info",
	"name": "scheduler name"
}
```  

##### Response.
```json
{
	"name": "scheduler name",
	"state": "running, paused or completed",
	"time zone": "time zone ID",
	"timers": []
}
```  
Where "timers" array contains `JsonObject`'s of [timer info](#get-timer-info).

-------------

### Get scheduler state.  

Sent to _Chime_ address or to _scheduler_ address.  

##### Request.  
```json
{
	"operation": "state",
	"name": "scheduler name",
	"state": "get"
}
```  

##### Response.
```json
{
	"name": "scheduler name",
	"state": "running, paused or completed"
}
```  

-------------

### Set scheduler to paused state.  

Sent to _Chime_ address or to _scheduler_ address.  

##### Request.  
```json
{
	"operation": "state",
	"name": "scheduler name",
	"state": "paused"
}
```

##### Response.
```json
{
	"name": "scheduler name",
	"state": "paused"
}
```  

-------------

### Set scheduler to running state.  

Sent to _Chime_ address or to _scheduler_ address.  

##### Request.  
```json
{
	"operation": "state",
	"name": "scheduler name",
	"state": "running"
}
```

##### Response.
```json
{
	"name": "scheduler name",
	"state": "running"
}
```  

-------------


## Timer request.  

### Create timer.  

Sent to _Chime_ address with full timer name, i.e. "scheduler name:timer name"
or to _scheduler_ address with either full or short timer name.  

##### Request.  
```json
{
	"operation": "create",
	"name": "scheduler name:timer name",
	"description": {},
	"state": "running, paused or completed",
	"maximum count": "Integer, maximum number of fires",
	"publish": "Boolean, if true message to be published and to be sent otherwise",
	"start time": {
 		"seconds": "Integer",
 		"minutes": "Integer",
 		"hours": "Integer",
 		"day of month": "Integer",
 		"month": "Integer or String",
 		"year": "Integer"
	},
	"end time": {
 		"seconds": "Integer",
 		"minutes": "Integer",
 		"hours": "Integer",
 		"day of month": "Integer",
 		"month": "Integer or String",
 		"year": "Integer"
	},
	"time zone": "String",
	"message": "any Json supports",
	"delivery options": {}
}
```  
Where "description" contains JsonObject with [timer descriptions](#timer-descriptions).  
"operation", "name", and "description" are mandatory fields.  
Other fields are optional, default values are:  
* "state" = "running"  
* "maximum count" = unlimited  
* "publish" = false  
* "start time" = right now  
* "end time" = never  
* "time zone" = local  
* "message" = null  
* "delivery options" = null  

#### Response.  
```json
{
	"name": "scheduler name:timer name",
	"state": "running, paused or completed"
}
```  

-------------

### Delete timer.  

Sent to _Chime_ address with full timer name, i.e. "scheduler name:timer name"
or to _scheduler_ address with either full or short timer name.  

##### Request.  
```json
{
	"operation": "delete",
	"name": "scheduler name:timer name"
}
```

##### Response.
```json
{
	"name": "scheduler name:timer name",
	"state": "completed"
}
```  

-------------

### Get timer info.  

Sent to _Chime_ address with full timer name, i.e. "scheduler name:timer name"
or to _scheduler_ address with either full or short timer name.  

##### Request.  
```json
{
	"operation": "info",
	"name": "scheduler name:timer name"
}
```  

##### Response.
```json
{
	"name": "scheduler name:timer name",
	"state": "running, paused or completed",
	"count": "Integer, total number of fires when request is received",
	"description": {}
}
```  
Response contains all fields set at [timer create request](#create-timer).  
"description" field contains JsonObject with [timer descriptions](#timer-descriptions).  

-------------

### Get timer state.  

Sent to _Chime_ address with full timer name, i.e. "scheduler name:timer name"
or to _scheduler_ address with either full or short timer name.  

##### Request.  
```json
{
	"operation": "state",
	"name": "scheduler name:timer name",
	"state": "get"
}
```

##### Response.
```json
{
	"name": "scheduler name:timer name",
	"state": "running, paused or completed"
}
```  

-------------

### Set timer to running state.  

Sent to _Chime_ address with full timer name, i.e. "scheduler name:timer name"
or to _scheduler_ address with either full or short timer name.  

##### Request.  
```json
{
	"operation": "state",
	"name": "scheduler name:timer name",
	"state": "running"
}
```

##### Response.
```json
{
	"name": "scheduler name:timer name",
	"state": "running"
}
```  

-------------

### Set timer to paused state.  

Sent to _Chime_ address with full timer name, i.e. "scheduler name:timer name"
or to _scheduler_ address with either full or short timer name.  

##### Request.  
```json
{
	"operation": "state",
	"name": "scheduler name:timer name",
	"state": "paused"
}
```  

##### Response.
```json
{
	"name": "scheduler name:timer name",
	"state": "paused"
}
```  

-------------


## Timer descriptions.  

Used in [timer create request](#create-timer).  

### Cron-style timer.  
```json
{
	"type": "cron",
	"seconds": "String in cron-style",
	"minutes": "String in cron-style",
	"hours": "String in cron-style",
	"days of month": "String in cron-style",
	"months": "String in cron-style",
	"days of week": "String in cron-style, optional",
	"years": "String in cron-style, optional",
	"message": "any Json supports",
	"delivery options": {}
}
```  
"type", "seconds", "minutes", "hours", "days of month" and "months" are mandatory.  
"days of week" and "years" are optional.  
"message" and "delivery options" are optional.  

##### Cron specification.  

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
* _days of week_, optional  
	* allowed values 1-7, Sun-Sat, Sunday-Saturday  
	* allowed special characters: , - * / L #  
* _years_, optional  
	* allowed values 1970-2099  
	* allowed special characters: , - * /  
 
> Names of months and days of the week are case insensitive.  
 
> Sunday is the first day of week.  
 
##### Special characters.  

* '*' means all values  
* ',' separates list items  
* '-' specifies range, for example, '10-12' means '10, 11, 12'  
* '/' specifies increments, for example, '0/15' in seconds field means '0,15,30,45',
  '0-30/15' means '0,15,30'  
* 'L' has to be used after digit and means _the last xxx day of the month_,
  where xxx is day of week, for example, '6L' means _the last Friday of the month_  
* '#' has to be used with digits before and after: 'x#y' and means _the y'th x day of the month_,
  for example, '6#3' means _the third Friday of the month_  

-------------

### Interval timer.  
```json
{
	"type": "interval",
	"delay": "Integer > 0",
	"message": "any Json supports",
	"delivery options": {}
}
```  
"message" and "delivery options" are optional.  

-------------

### Union timer.  
```json
{
	"type": "union",
	"timers": [],
	"message": "any Json supports",
	"delivery options": {}
}
```  
Where "timers" array contains `JsonObject`'s of [timer descriptions](#timer-descriptions).  
"message" and "delivery options" are optional.  

-------------


## Timer events.  

Timer event is sent or published by _Chime_ in `JSON` to timer full name ("scheduler name:timer name") address.  

### Fire event.  
```json
{  
	"name": "String, timer name",  
	"event": "fire",
	"count": "Integer, total number of fire times",
	"time": "String formated time / date",
	"seconds": "Integer, number of seconds since last minute",
	"minutes": "Integer, number of minutes since last hour",
	"hours": "Integer, hour of day",
	"day of month": "Integer, day of month",
	"month": "Integer, month",
	"year": "Integer, year",
	"time zone": "String, time zone the timer works in",
	"message": "message given at a timer create request, optional"  
}
```  
"message" is given at [create timer request](#create-timer) in any Json supported type.  

-------------

### Complete event.  
```json
{
	"name": "scheduler name:timer name",
	"event": "complete",
	"count": "Integer, total number of fires"
}
```  
