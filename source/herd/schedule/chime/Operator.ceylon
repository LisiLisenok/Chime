import ceylon.json {

	JsonObject
}
import io.vertx.ceylon.core.eventbus {

	Message,
	EventBus,
	MessageConsumer
}
import java.util {
	UUID
}


"Provides basic operations with `JsonObject` message."
see(`class SchedulerManager`, `class TimeScheduler`)
since("0.1.0") by("Lis")
abstract class Operator {
	
	"Generates unique string."
	shared static String uuidString() => UUID.randomUUID().string.replace(Chime.configuration.nameSeparator, ".");
	
	"Extracts state from request, helper method."
	shared static State? extractState(JsonObject request) {
		if (is String state = request[Chime.key.state]) {
			return stateByName(state);
		}
		else {
			return null;
		}
	}
	
	
	"Event bus consumer." variable MessageConsumer<JsonObject?>? consumer = null;
	"Address this operator listens to." shared String address;
	"EventBus to pass messages." shared EventBus eventBus;
	
	
	shared new (
		"Address this operator listens to." String address,
		"EventBus to pass messages." EventBus eventBus
	) {
		this.address = address;
		this.eventBus = eventBus;
	}

	
	"Operators map."
	late Map<String, Anything(Message<JsonObject?>)> operators = createOperators();
	
	"Creates operators map."
	shared formal Map<String, Anything(Message<JsonObject?>)> createOperators();
	
		
	"Message has been received from event bus - process it!."
	void onMessage("Message from event bus." Message<JsonObject?> msg) {
		if (exists request = msg.body(), is String operation = request[Chime.key.operation]) {
			// depending on operation code
			if (exists operator = operators[operation]) {
				operator(msg);
			}
			else {
				msg.fail(Chime.errors.codeUnsupportedOperation, Chime.errors.unsupportedOperation);
			}
		}
		else {
			// response with wrong format error
			msg.fail(Chime.errors.codeOperationIsNotSpecified, Chime.errors.operationIsNotSpecified);
		}
	}
	
	"Connects to event bus, returns promise resolved when event listener registered."
	shared default void connect(Boolean local) {
		"Already connected."
		assert(!consumer exists);
		// setup event bus listener
		if (local) {
			consumer = eventBus.localConsumer(address, onMessage);
		}
		else {
			consumer = eventBus.consumer(address, onMessage);
		}
	}
	
	shared default void stop() {
		consumer?.unregister();
		consumer = null;
	}

}
