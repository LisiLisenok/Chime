import io.vertx.ceylon.core.eventbus {

	EventBus,
	Message
}
import ceylon.json {

	JSON=Object
}
import io.vertx.ceylon.core {

	Vertx,
	vertx
}


"Runs the module `herd.examples.schedule.chime`."
shared void run() {
	value v = vertx.vertx();
	v.deployVerticle (
		"ceylon:herd.schedule.chime/0.1.1",
		( String|Throwable res ) {
			if ( is String res ) {
				value scheduler = Scheduler( v );
				scheduler.initialize();
			}
			else {
				print( "deploying error ``res``");
			}
		}
	);    
}


"Performs scheduler run. Creates cron-style timer and listens it."
class Scheduler( Vertx v, String address = "chime" )
{
	EventBus eventBus = v.eventBus();
	
	
	"Initializes testing - creates schedule manager and timer."
	shared void initialize() {
		eventBus.send<JSON> (
			address,
			JSON {
				"operation" -> "create",
				"name" -> "scheduler",
				"state" -> "running"
			},
			( Throwable | Message<JSON> msg ) {
				if ( is Message<JSON> msg ) {
					schedulerCreated( msg );
				}
				else {
					print( "error in onConnect ``msg``" );
					v.close();
				}
			}
		);
	}
	
	
	void printMessage( Throwable | Message<JSON> msg ) {
		if ( is Message<JSON> msg ) {
			if ( exists body = msg.body() ) {
				print( body );
				if ( is String state = body.get( "state" ), state == "completed" ) {
					v.close();
				}
			}
			else {
				print( "no body in the message" );
				v.close();
			}
		}
		else {
			print( "error: ``msg``" );
		}
	}
	
	
	void schedulerCreated( Message<JSON> msg ) {
		
		eventBus.consumer( "scheduler:timer", printMessage );
		
		eventBus.send<JSON>(
			address,
			JSON {
				"operation" -> "create",
				"name" -> "scheduler:timer",
				"state" -> "running",
				"publish" -> false,
				"max count" -> 3,
				"time zone" -> "Europe/Paris",
				/*"descirption" -> JSON {
					"type" -> "interval",
					"delay" -> 10
				}*/
				"descirption" -> JSON {
					"type" -> "cron",
					"seconds" -> "20/15",
					"minutes" -> "*",
					"hours" -> "0-23",
					"days of month" -> "1-31",
					"months" -> "*",
					"days of week" -> "*",
					"years" -> "2015-2019"
				}
			},
			printMessage
		);		
	}
	
}