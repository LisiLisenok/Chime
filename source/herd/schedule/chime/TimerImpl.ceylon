import io.vertx.ceylon.core.eventbus {
	EventBus,
	MessageConsumer,
	Message
}
import ceylon.json {
	JsonObject
}


"Internal implementation of [[Timer]]."
see(`interface Scheduler`, `class SchedulerImpl`)
since("0.2.0") by("Lis")
class TimerImpl extends Sender satisfies Timer
{
	
	shared static void replyWithInfo( Anything(Throwable|TimerInfo[]) info)
		(Throwable|Message<JsonObject?> msg)
	{
		if (is Message<JsonObject?> msg) {
			"Reply from scheduler request has not to be null."
			assert (exists ret = msg.body());
			info(ret.getArray(Chime.key.timers).narrow<JsonObject>().map(TimerInfo.fromJSON).sequence());
		}
		else {
			info(msg);
		}
	}
	
	
	variable Anything(TimerEvent)? eventHandler = null;
	MessageConsumer<JsonObject?> consumer;
	variable Boolean alive = true;
	shared actual String name;
	
	shared new (String name, String schedulerAddress, EventBus eventBus, Integer? sendTimeout)
			extends Sender(schedulerAddress, eventBus, sendTimeout)
	{
		this.name = name;
		consumer = eventBus.consumer<JsonObject>(name);
	}
	
	
	"Redirects message to `eventHandler`."
	void onMessage(Message<JsonObject?> message) {
		if (exists h = eventHandler) {
			"Message from timer has to containe body."
			assert (exists body = message.body());
			value eventType = body.getString(Chime.key.event);
			if (eventType == Chime.event.fire) {
				h (
					TimerFire (
						name, body.getInteger(Chime.key.count),
						body.getString(Chime.key.timeZone),
						dateTimeFromJSON(body),
						body.get(Chime.key.message)
					)
				);
			}
			else if (eventType == Chime.event.complete) {
				unregister();
				alive = false;
				h(TimerCompleted(name, body.getInteger(Chime.key.count)));
			}
			else {
				throw AssertionError("timer event has to be one of 'fire' or 'complete'");
			}
		}
	}

	
	shared actual void handler(Anything(TimerEvent) handler) {
		if (alive) {
			eventHandler = handler;
			if (!consumer.isRegistered()) {
				consumer.handler(onMessage);
			}
		}
	}
	
	shared actual void unregister() {
		consumer.unregister();
		eventHandler = null;
	}
		
	shared actual void delete(Anything(Throwable|String)? reply) {
		if (alive) {
			unregister();
			alive = false;
			if (exists reply) {
				sendRepliedRequest (
					JsonObject {
						Chime.key.operation -> Chime.operation.delete,
						Chime.key.name -> name
					},
					SchedulerImpl.replyWithName(reply)
				);
			}
			else {
				sendRequest (
					JsonObject {
						Chime.key.operation -> Chime.operation.delete,
						Chime.key.name -> name
					}
				);
			}
		}
	}
	
	shared actual void pause(Anything(Throwable|State)? reply) {
		if (alive) {
			if (exists reply) {
				sendRepliedRequest (
					JsonObject {
						Chime.key.operation -> Chime.operation.state,
						Chime.key.name -> name,
						Chime.key.state -> Chime.state.paused
					},
					SchedulerImpl.replyWithState(reply)
				);				
			}
			else {
				sendRequest (
					JsonObject {
						Chime.key.operation -> Chime.operation.state,
						Chime.key.name -> name,
						Chime.key.state -> Chime.state.paused
					}
				);
			}
		}
	}
	
	shared actual void resume(Anything(Throwable|State)? reply) {
		if (alive) {
			if (exists reply) {
				sendRepliedRequest (
					JsonObject {
						Chime.key.operation -> Chime.operation.state,
						Chime.key.name -> name,
						Chime.key.state -> Chime.state.running
					},
					SchedulerImpl.replyWithState(reply)
				);
			}
			else {
				sendRequest (
					JsonObject {
						Chime.key.operation -> Chime.operation.state,
						Chime.key.name -> name,
						Chime.key.state -> Chime.state.running
					}
				);
			}
		}
	}
	
	shared actual void info("Info handler." Anything(Throwable|TimerInfo) info) {
		sendRepliedRequest (
			JsonObject {
				Chime.key.operation -> Chime.operation.info,
				Chime.key.name -> name
			},
			(Throwable|Message<JsonObject?> msg) {
				if (is Message<JsonObject?> msg) {
					"Reply from scheduler request has not to be null."
					assert (exists ret = msg.body());
					info( TimerInfo.fromJSON( ret ));
				}
				else {
					info(msg);
				}
			}
		);
	}
	
	shared actual String string => "Timer ``name``";
	
}
