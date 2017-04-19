import ceylon.json {

	JSON=Object
}
import io.vertx.ceylon.core.eventbus {

	Message,
	EventBus,
	MessageConsumer
}


"Provides basic operations with [[JSON]] message."
see( `class SchedulerManager`, `class TimeScheduler` )
since( "0.1.0" ) by( "Lis" )
abstract class Operator( "EventBus to pass messages." shared EventBus eventBus )
{
	variable MessageConsumer<JSON?>? consumer = null; 
			
	"Operators map."	
	variable Map<String, Anything(Message<JSON?>)>? operators = null;
	
	"creates operators map."
	shared formal Map<String, Anything(Message<JSON?>)> createOperators();
	
	
	"Returns operator by operation code."
	shared Anything(Message<JSON?>)? getOperator( "operation code" String code ) {
		if ( !operators exists ) {			
			// create operators map if doesn't exists
			operators = createOperators();
		}
		return operators?.get( code );
	}

	
	"Extracts state from request, helper method."
	shared State? extractState( JSON request ) {
		if ( is String state = request[Chime.key.state] ) {
			return stateByName( state );
		}
		else {
			return null;
		}
	}
		
	"Message has been received from event bus - process it!."
	void onMessage( "Message from event bus." Message<JSON?> msg ) {
		if ( exists request = msg.body(), is String operation = request[Chime.key.operation] ) {
			// depending on operation code
			if ( exists operator = getOperator( operation ) ) {
				operator( msg );
			}
			else {
				msg.fail( errorMessages.codeUnsupportedOperation, errorMessages.unsupportedOperation );
				
			}
		}
		else {
			// response with wrong format error
			msg.fail( errorMessages.codeOperationIsNotSpecified, errorMessages.operationIsNotSpecified );
		}
	}
	
	"Connects to event bus, returns promise resolved when event listener registered."
	shared default void connect( "Address to listen to." String address ) {
		"Already connected."
		assert( !consumer exists );
		// setup event bus listener
		consumer = eventBus.consumer( address, onMessage );
	}
	
	shared default void stop() {
		consumer?.unregister();
		consumer = null;
	}

}
