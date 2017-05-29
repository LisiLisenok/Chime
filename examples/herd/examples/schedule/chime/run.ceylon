import io.vertx.ceylon.core.eventbus {

	EventBus,
	Message
}
import ceylon.json {

	JsonObject
}
import io.vertx.ceylon.core {

	Vertx,
	vertx
}
import herd.schedule.chime {
	Chime
}


"Runs the module `herd.examples.schedule.chime`."
shared void run() {
	value v = vertx.vertx();
	Chime c = Chime();
	c.deploy (
		v, null, 
		(String|Throwable res) {
			if (is String res) {
				value scheduler = Scheduler(v);
				scheduler.initialize();
			}
			else {
				print("deploying error: ``res``");
				v.close();
			}
		}
	);    
}


"Performs scheduler run. Creates cron-style timer and listens it."
class Scheduler(Vertx v, String address = Chime.configuration.defaultAddress)
{
	EventBus eventBus = v.eventBus();
	
	
	"Initializes testing - creates schedule manager and timer."
	shared void initialize() {
		eventBus.send<JsonObject> (
			address,
			JsonObject {
				Chime.key.operation -> Chime.operation.create,
				Chime.key.name -> "scheduler",
				Chime.key.state -> Chime.state.running,
				Chime.key.timeZone -> "Europe/Paris"
			},
			(Throwable | Message<JsonObject?> msg) {
				if (is Message<JsonObject?> msg) {
					schedulerCreated(msg);
				}
				else {
					print("error when creating scheduler: ``msg``");
					v.close();
				}
			}
		);
	}
	
	
	void printMessage(Throwable|Message<JsonObject?> msg) {
		if (is Message<JsonObject?> msg) {
			if (exists body = msg.body()) {
				print(body);
				if (is String event = body[Chime.key.event], event == Chime.event.complete) {
					v.close();
				}
			}
			else {
				print("no body in the message");
				v.close();
			}
		}
		else {
			print("error: ``msg``");
			v.close();
		}
	}
	
	
	void schedulerCreated(Message<JsonObject?> msg) {
		
		eventBus.consumer("scheduler:timer", printMessage);
		
		eventBus.send<JsonObject> (
			address,
			JsonObject {
				Chime.key.operation -> Chime.operation.create,
				Chime.key.name -> "scheduler:timer",
				Chime.key.maxCount -> 5,
				//Chime.key.timeZone -> "Europe/Paris",
				Chime.key.description -> JsonObject {
					Chime.key.type -> Chime.type.cron,
					Chime.date.seconds -> "20/15",
					Chime.date.minutes -> "*",
					Chime.date.hours -> "0-23",
					Chime.date.daysOfMonth -> "1-31",
					Chime.date.months -> "*",
					Chime.date.daysOfWeek -> "*",
					Chime.date.years -> "2015-2019"
				}
			},
			printMessage
		);
	}
	
}