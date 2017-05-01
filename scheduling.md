---
title: Time scheduling with Chime
template: post.html
date: 2017-05-01
author: LisiLisenok
---

## Time scheduling.  

Executing periodic or delayed actions in Vert.x is performed with
[one-shot and periodic timers](http://vertx.io/docs/vertx-core/java/#_executing_periodic_and_delayed_actions).
This is the base for time scheduling and reach feature extension must be rather interesting.
Be notified at certain date / time, take into account holidays,
repeat notifications until a given date, apply time zone,
take into account daylight saving time etc.
There are a lot of useful features time scheduler may provide.


## Chime.  

 [Chime](https://github.com/LisiLisenok/Chime) is time scheduler verticle which works on _Vert.x_ event bus and provides:  
 * scheduling with _cron-style_, _interval_ or _union_ timers:
 	* at a certain time of day (to the second)  
 	* on certain days of the week, month or year  
 	* with a given time interval  
 	* with nearly any combination of all of above  
 	* repeating a given number of times  
 	* repeating until a given time / date  
 	* repeating infinitely  
 * proxying event bus with conventional interfaces  
 * applying time zones available on _JVM_  
 * flexible timers management system:  
 	* grouping timers  
 	* defining a timer start or end times  
 	* pausing / resuming  
 	* fire counting  
 * listening and sending messages via event bus with _JSON_  
 * _publishing_ or _sending_ timer fire event to the address of your choice  

[INFO _Chime_ is written in [Ceylon](https://ceylon-lang.org).]  


## Running.  

### Ceylon users.  

Deploy _Chime_ using `Verticle.deployVerticle` method.  

```Ceylon
import io.vertx.ceylon.core {vertx}
import herd.schedule.chime {Chime}
Chime c = Chime().deploy(vertx.vertx());
```

### Java users.  

1. Ensure that Ceylon verticle factory is available at class path.  
2. Put Ceylon versions to consistency.
   For instance, Vert.x 3.4.1 depends on Ceylon 1.3.0 while Chime 0.2.0 depends on Ceylon 1.3.2. 
3. [Deploy verticle](http://vertx.io/docs/vertx-core/java/#_deploying_verticles_programmatically), like:  
```Java
vertx.deployVerticle("ceylon:herd.schedule.chime/0.2.0")
```

See [example with Maven](https://github.com/LisiLisenok/ChimeJavaExample)  


## Schedulers.  

Well, _Chime_ verticle is deployed. Can scheduling be started? Not yet.
The next step is to create one or several schedulers.
Basically, scheduler is a set or group of timers and provides:    
* creating and deleting timers  
* pausing / resuming all timers working within the scheduler  
* info on the running timers  
* default time zone  
* listening event bus at the given scheduler address  

This two level (scheduler-timer) architecture is very flexible and provides broad ways
to manage timers.  

When _Chime_ verticle is deployed it starts listen event bus at **chime** address (can be configured).
In order to create scheduler send to this address a JSON message.  

**in Ceylon:**
```Ceylon
JSON request = JSON {
	"operation" -> "create",
	"name" -> "scheduler name"
};
```
**in Java:**
```Java
JsonObject request = new JsonObject();
request.put("operation", "create")
	.put("name", "scheduler name");
```

Once scheduler is created it starts listen event bus at **scheduler name** address.
Sending messages to **chime** address or to **scheduler name** address are rather equivalent,
excepting that chime address provides services for every scheduler, while scheduler address
provides services for this particular scheduler only.  
The request sent to the _Chime_ has to contain **operation** and **name** keys.
Name key provides scheduler or timer name. While operation key shows an action _Chime_ has to perform.
There are only four possible operations:  
* create - create new scheduler or timer.  
* delete - delete scheduler with all its timers.  
* info - request info on _Chime_ or on a particular scheduler or timer.  
* state - set or get scheduler or timer state (running, paused or completed).  


## Timers.  

Now we have scheduler created and timers can be run within. There are two ways to access a given timer:  
1. Sending message to **scheduler name** address using **timer name**.  
2. Sending message to **chime** address using full timer name which is **scheduler name:timer name**.  

Timer request is rather complicated and contains a lot of features.
Look [Chime documentation](https://herd.ceylon-lang.org/modules/herd.schedule.chime) for the details.
In this article only basic features are considered:  
**in Ceylon:**  
```Ceylon
JSON request = JSON {
	"operation" -> "create",
	"name" -> "scheduler name:timer name",
	"description"-> JSON {...} // timer description
};
```
**in Java:**  
```Java
JsonObject request = new JsonObject();
JsonObject description = new JsonObject();
request.put("operation", "create")
	.put("name", "scheduler name:timer name")
	.put("description", description);
```
This is rather similar to request sent to create scheduler.
The difference is only **description** field is added.
This description identifies particular timer type and details.  
The other fields not shown here are optional and includes:  
* initial timer state (paused or running)  
* start or end date-time  
* number of repeating times  
* is timer message to be published or sent  
* time zone  

Currently three timer types are supported:  
* __Interval timer__. Timer which fires after each given time period (minimum 1 second):  
```Ceylon
JSON {  
	// timer type, mandatory  
	"type" -> "interval",  
	// timer delay in seconds, if <= 0 timer fires only once, mandatory  
	"delay" -> Integer,  
	// message which added to timer fire event, optional  
	"message" -> String|Boolean|Integer|Float|JSON|JSONArray,  
	// delivery options the timer fire event is sent with, optional  
	"delivery options\" -> JSON  
};
``` 
* __Cron style timer__. Timer which is defined like cron:  
```Ceylon
JSON {  
	 // timer type, mandatory  
	"type" -> "cron",  
	// seconds in cron style, mandatory, nonempty
	"seconds" -> String,  
	// minutes in cron style, mandatory, nonempty  
	"minutes" -> String,  
	// hours in cron style, mandatory, nonempty  
	"hours" -> String,  
	// days of month in cron style, mandatory, nonempty  
	"days of month" -> String,  
	// months in cron style, mandatory, nonempty  
	"months" -> String,  
	// days of week in cron style, L means last, # means nth of month, optional  
	"days of week" -> String,  
	// year in cron style, optional  
	"years" -> String,  
	// message which added to timer fire event, optional  
 	"message" -> String|Boolean|Integer|Float|JSON|JSONArray,
 	// delivery options the timer fire event is sent with, optional  
 	"delivery options" -> JSON  
};
```  
Cron timer is rather powerful and flexible.
See specification details in [Chime documentation](https://herd.ceylon-lang.org/modules/herd.schedule.chime).  
* __Union timer__. Combines a number of timers into a one:  
```Ceylon
JSON {  
	// timer type, mandatory  
	"type" -> "union",  
	// list of the timers, each item is JSON according to its description, mandatory  
	"timers" -> JSONArray,  
	// message which added to timer fire event, optional  
	"message" -> String|Boolean|Integer|Float|JSON|JSONArray,  
	// delivery options the timer fire event is sent with, optional
	"delivery options" -> JSON  
};
```  
Union timer may be useful to fire at a list of specific dates / times.


## Timer events.  

Once timer is started it sends or publishes messages to **scheduler name:timer name** address in JSON format.
Two types of events are sent:
* fire event  
```Ceylon
JSON {  
	// timer name  
	"name" -> String,  
	"event" -> "fire",  
	// total number of fire times  
	"count" -> Integer,  
	// ISO formated time / date  
	"time" -> String,  
	// number of seconds since last minute  
	"seconds" -> Integer,  
	// number of minutes since last hour  
	"minutes" -> Integer,  
	// hour of day	"day of month" -> Integer, day of month  
	"hours" -> Integer,  
	// month  
	"month" -> Integer,  
	// year  
	"year" -> Integer,  
	// time zone the timer works in
	"time zone" -> String,  
	// message given at a timer create request  
	"message" -> String|Boolean|Integer|Float|JSON|JSONArray  
};
```  
* complete event  
```Ceylon
JSON {  
	// timer name  
	"name" -> String,  
	"event" -> "complete",  
	// total number of fire times  
	"count" -> Integer  
};
```


## Ceylon example.  

Lets consider timer has fire every month at 16-30 last Sunday.  

```Ceylon
// listen the timer events
eventBus.consumer (
	"scheduler:timer",
	(Throwable|Message<JSON?> msg) {
		if (is Message<JSON?> msg) {
			assert(exists body = msg.body());
			// prints timer message
			print(body);
		}
		else {
			// error occurred!
			print(msg);
		}	
	}
);
// create timer
eventBus.send<JSON>(
	"chime",
	JSON {
		"operation" -> "create",
		"name" -> "scheduler:timer",
		"description" -> JSON {
			"type" -> "cron",
			"seconds" -> "0",
			"minutes" -> "30",
			"hours" -> "16",
			// any day
			"days of month" -> "*",
			// any month
			"months" -> "*",
			// means last Sunday of the month
			"days of week" -> "SundayL"
		}
	}
);

```


## Java example.  

Lets consider a timer which has to fire at 8-30 every Monday and at 17-30 every Friday.  

```Java
// listen the timer events
MessageConsumer<JsonObject> consumer = eventBus.consumer("scheduler:timer");
consumer.handler (
	message -> {
		System.out.println(message.body());
  	}
);

// description of timers
JsonObject mondayTimer = (new JsonObject()).put("type", "cron")
	.put("seconds", "0").put("minutes", "30").put("hours", "8")
	.put("days of month", "*").put("months", "*")
	.put("days of week", "Monday");
JsonObject fridayTimer = (new JsonObject()).put("type", "cron")
	.put("seconds", "0").put("minutes", "30").put("hours", "17")
	.put("days of month", "*").put("months", "*")
	.put("days of week", "Friday");
// union timer - combines mondayTimer and fridayTimer
JsonArray combination = (new JsonArray()).add(mondayTimer)
	.add(fridayTimer);
JsonObject timer = (new JsonObject()).put("type", "union")
	.put("timers", combination);

// create timer
eventBus.send (
	"chime",
	(new JsonObject()).put("operation", "create")
		.put("name", "scheduler:timer")
		.put("description", timer)
);
```  

[IMPORTANT Ensure that Ceylon verticle factory with right version is available at class path.]  


## At the end.  

Thank's for the reading. This is very quick introduction to the _Chime_ and if you are interested in you may read
more at [Chime documentation](https://herd.ceylon-lang.org/modules/herd.schedule.chime) or even [contribute](https://github.com/LisiLisenok/Chime) to.  

Enjoy with coding!  
