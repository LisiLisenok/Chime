import io.vertx.ceylon.core.eventbus {
	Message
}
import ceylon.json {
	JsonObject,
	JsonArray
}
import herd.schedule.chime {
	Chime
}
import io.vertx.ceylon.core {
	DeploymentOptions,
	vertx
}


shared void run() {
	String timerName = "scheduler:timer";
	value v = vertx.vertx();
	Chime c = Chime();
	// deploy Chime using config with search service providers module list 
	c.deploy (
		v,
		DeploymentOptions (
			JsonObject {
				// module to search custom timer
				Chime.configuration.services -> JsonArray{"herd.examples.schedule.chime/0.3.0"}
			}
		), 
		(String|Throwable res) {
			if (is String res) {
				// print installed extension
				v.eventBus().send<JsonObject> (
					"chime",
					JsonObject {
						Chime.key.operation -> Chime.operation.info
					},
					(Throwable|Message<JsonObject?> msg) {
						if (is Message<JsonObject?> msg, exists body = msg.body()) {
							if (exists services = body.getArrayOrNull(Chime.configuration.services)) {
								for (item in services) {
									print(item);
								}
							}
							else {
								print("extensions are not given");
							}
						}
						else {
							print(msg);						
						}
					}
				);
				// listen timer messages
				v.eventBus().consumer (
					timerName,
					(Throwable|Message<JsonObject?> msg) {
						if (is Message<JsonObject?> msg, exists body = msg.body()) {
							if (is String event = body[Chime.key.event]) {
								if (event == Chime.event.complete) {
									print("completed");
									v.close();
								}
								else if (event == Chime.event.fire) {
									print("fire at ``body[Chime.key.time] else "<null>"`` with ``body[Chime.key.message] else "<null>"``");
								}
								else {
									print("undefined event: ``event``");
									v.close();
								}
							}
							else {
								print("no event in ``msg``");
								v.close();
							}
						}
						else {
							print(msg);
							v.close();
						}
					}
				);
				// create custom timer
				v.eventBus().send (
					"chime",
					JsonObject {
						Chime.key.operation -> Chime.operation.create,
						Chime.key.name -> timerName,
						Chime.key.maxCount -> 3,
						Chime.key.description -> JsonObject {
							// the same type as factory marked with
							Chime.key.type -> CustomIntervalTimerFactory.timerType,
							Chime.key.delay -> 1
						},
						Chime.key.message -> "timer message"
					}
				);
			}
			else {
				print("deploying error: ``res``");
				v.close();
			}
		}
	);    
	
}
