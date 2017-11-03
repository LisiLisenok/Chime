import ceylon.time {
	DateTime
}
import io.vertx.ceylon.core.eventbus {
	EventBus,
	Message
}
import ceylon.json {
	JsonObject,
	JsonArray,
	ObjectValue
}


"Internal implementation of [[Scheduler]]."
see(`function connectScheduler`, `function createScheduler`)
since("0.2.0") by("Lis")
class SchedulerImpl
	extends Sender satisfies Scheduler
{
	
	shared static void createSchedulerImpl(Anything(Throwable|Scheduler) handler, EventBus eventBus, Integer? sendTimeout)
		(Throwable|Message<JsonObject?> msg)
	{
		if (is Message<JsonObject?> msg) {
			"Reply from scheduler request has not to be null."
			assert (exists ret = msg.body());
			handler(SchedulerImpl(ret.getString(Chime.key.name), eventBus, sendTimeout));
		}
		else {
			handler(msg);
		}
	}

	shared static void replyWithInfo(Anything(Throwable|SchedulerInfo[]) handler)
		(Throwable|Message<JsonObject?> msg)
	{
		if (is Message<JsonObject?> msg) {
			"Reply from scheduler request has not to be null."
			assert (exists ret = msg.body());
			value sch = ret.getArray(Chime.key.schedulers);
			handler([for (item in sch.narrow<JsonObject>()) SchedulerInfo.fromJSON(item)]);
		}
		else {
			handler( msg );
		}
	}
	
	shared static void replyWithList(Anything(Throwable|{String*}) handler, String key)
		(Throwable|Message<JsonObject?> msg)
	{
		if (is Message<JsonObject?> msg) {
			"Reply from scheduler request has not to be null."
			assert (exists ret = msg.body());
			handler (
				ret.getArray(Chime.key.schedulers).narrow<String>()
						.chain(ret.getArray(Chime.key.timers).narrow<String>())
			);
		}
		else {
			handler(msg);
		}
	}
	
	shared static void replyWithState(Anything(Throwable|State) handler)
		(Throwable|Message<JsonObject?> msg)
	{
		if (is Message<JsonObject?> msg) {
			"Reply from scheduler request has not to be null."
			assert (exists ret = msg.body());
			"Timer info replied from scheduler has to contain state field."
			assert (exists state = stateByName(ret.getString(Chime.key.state)));
			handler(state);
		}
		else {
			handler(msg);
		}
	}
	
	shared static void replyWithName(Anything(Throwable|String) handler)
		(Throwable|Message<JsonObject?> msg)
	{
		if (is Message<JsonObject?> msg) {
			"Reply from scheduler request has not to be null."
			assert (exists ret = msg.body());
			handler(ret.getString(Chime.key.name));
		}
		else {
			handler(msg);
		}
	}
	
	shared static void replyWithTimer (
		String? schedulerName, EventBus eventBus, Integer? sendTimeout, Anything(Throwable|TimerImpl) handler
	) (Throwable | Message<JsonObject?> msg)
	{
		if (is Throwable msg) {
			handler(msg);
		}
		else {
			"Timer create request has to respond with body."
			assert (exists rep = msg.body());
			String name = rep.getString(Chime.key.name);
			"Timer full name has to contain scheduler and timer names."
			assert (exists inc = name.firstOccurrence(Chime.configuration.nameSeparatorChar));
			handler(TimerImpl(name, name.spanTo(inc - 1), eventBus, sendTimeout));
		}
	}

	
	variable Boolean alive = true;
	shared actual String name;
	EventBus eventBus;
	"Timeout to send message with." Integer? sendTimeout;
	
	shared new (String name, EventBus eventBus, "Timeout to send message with." Integer? sendTimeout)
		extends Sender(name, eventBus, sendTimeout)
	{
		this.name = name;
		this.eventBus = eventBus;
		this.sendTimeout = sendTimeout;
	}
	
	shared actual void createTimer (
		Anything(Timer|Throwable) handler, JsonObject description, String? timerName,
		Boolean paused, Integer? maxCount, DateTime? startDate,
		DateTime? endDate, String? timeZone, String? timeZoneProvider,
		ObjectValue? message, String? messageSource, JsonObject? messageSourceOptions,
		String? eventProducer, JsonObject? eventProducerOptions

	) {
		JsonObject timer = JsonObject {
			Chime.key.operation -> Chime.operation.create
		};
		if (exists timerName) {
			timer.put( Chime.key.name, timerName );
		}
		if (paused) {
			timer.put(Chime.key.state, Chime.state.paused);
		}
		if (exists maxCount) {
			timer.put(Chime.key.maxCount, maxCount);
		}
		if (exists startDate) {
			timer.put (
				Chime.key.startTime,
				JsonObject {
					Chime.date.seconds -> startDate.seconds,
					Chime.date.minutes -> startDate.minutes,
					Chime.date.hours -> startDate.hours,
					Chime.date.dayOfMonth -> startDate.day,
					Chime.date.month -> startDate.month.integer,
					Chime.date.year -> startDate.year
				}
			);
		}
		if (exists endDate) {
			timer.put (
				Chime.key.endTime,
				JsonObject {
					Chime.date.seconds -> endDate.seconds,
					Chime.date.minutes -> endDate.minutes,
					Chime.date.hours -> endDate.hours,
					Chime.date.dayOfMonth -> endDate.day,
					Chime.date.month -> endDate.month.integer,
					Chime.date.year -> endDate.year
				}
			);
		}
		if (exists timeZone) {
			timer.put(Chime.key.timeZone, timeZone);
		}
		if (exists timeZoneProvider) {
			timer.put(Chime.key.timeZoneProvider, timeZoneProvider);
		}
		if (exists message) {
			timer.put(Chime.key.message, message);
		}
		if (exists messageSource) {
			timer.put( Chime.key.messageSource, messageSource );
		}
		if ( exists messageSourceOptions ) {
			timer.put( Chime.key.messageSourceOptions, messageSourceOptions );
		}
		if ( exists eventProducer ) {
			timer.put(Chime.key.eventProducer, eventProducer);
		}
		if (exists eventProducerOptions) {
			timer.put(Chime.key.eventProducerOptions, eventProducerOptions);
		}
		timer.put(Chime.key.description, description);

		sendRepliedRequest(timer, replyWithTimer(name, eventBus, sendTimeout, handler));
	}
	

	shared actual void delete(Anything(Throwable|String)? reply) {
		if (alive) {
			alive = false;
			if (exists reply) {
				sendRepliedRequest (
					JsonObject {
						Chime.key.operation -> Chime.operation.delete,
						Chime.key.name -> name
					},
					replyWithName(reply)
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
	
	shared actual void pause( Anything(Throwable|State)? reply ) {
		if ( alive ) {
			if ( exists reply ) {
				sendRepliedRequest (
					JsonObject {
						Chime.key.operation -> Chime.operation.state,
						Chime.key.name -> name,
						Chime.key.state -> Chime.state.paused
					},
					replyWithState(reply)
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
					replyWithState(reply)
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
	
	shared actual void info(Anything(Throwable|SchedulerInfo) info) {
		sendRepliedRequest (
			JsonObject {
				Chime.key.operation -> Chime.operation.info
			},
			(Throwable|Message<JsonObject?> msg) {
				if (is Message<JsonObject?> msg) {
					"Reply from scheduler request has not to be null."
					assert(exists ret = msg.body());
					info(SchedulerInfo.fromJSON(ret));
				}
				else {
					info(msg);
				}
			}
		);
	}
	
	shared actual void deleteTimers({String+} timers, Anything(Throwable|{String*})? handler) {
		if (exists handler) {
			sendRepliedRequest (
				JsonObject {
					Chime.key.operation -> Chime.operation.delete,
					Chime.key.name -> JsonArray(timers)
				},
				replyWithList(handler, Chime.key.timers)
			);
		}
		else {
			sendRequest (
				JsonObject {
					Chime.key.operation -> Chime.operation.delete,
					Chime.key.name -> JsonArray(timers)
				}
			);
		}
	}
	
	shared actual void timersInfo({String+} timers, Anything(Throwable|TimerInfo[]) info) {
		sendRepliedRequest (
			JsonObject {
				Chime.key.operation -> Chime.operation.info,
				Chime.key.name -> JsonArray(timers)
			},
			TimerImpl.replyWithInfo(info)
		);
	}
	
	shared actual String string => "Scheduler ``name``";
	
}
