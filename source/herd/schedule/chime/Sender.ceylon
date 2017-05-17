import io.vertx.ceylon.core.eventbus {
	EventBus,
	DeliveryOptions,
	Message
}
import ceylon.json {
	JsonObject
}


"Base class for event bus senders."
since( "0.3.0" ) by( "Lis" )
class Sender (
	"Address to send." shared String address,
	"EB" shared EventBus eventBus,
	"Timeout to send message with." shared Integer? sendTimeout
) {
	
	DeliveryOptions? options = if ( exists sendTimeout ) then DeliveryOptions( null, null, sendTimeout ) else null;
	
	shared void sendRequest( JsonObject request ) {
		if ( exists options ) {
			eventBus.send( address, request, options );
		}
		else {
			eventBus.send( address, request );
		}
	}
	
	shared void sendRepliedRequest( JsonObject request, Anything(Throwable|Message<JsonObject?>) rep ) {
		if ( exists options ) {
			eventBus.send<JsonObject>( address, request, options, rep );
		}
		else {
			eventBus.send<JsonObject>( address, request, rep );
		}
	}
	
}
