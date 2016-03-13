import ceylon.json {

	JSON=Object
}
import io.vertx.ceylon.core.eventbus {

	Message,
	EventBus
}
import herd.schedule.chime.timer {
	definitions
}


"Provides basic operations with [[JSON]] message."
see( `class SchedulerManager`, `class TimeScheduler` )
by( "Lis" )
abstract class Operator( "EventBus to pass messages." shared EventBus eventBus )
{
	
	"Operators map."	
	variable Map<String, Anything(Message<JSON>)>? operators = null;
	
	"creates operators map."
	shared formal Map<String, Anything(Message<JSON>)> createOperators();
	
	
	"Returns operator by operation code."
	shared Anything(Message<JSON>)? getOperator( "operation code" String code ) {
		if ( !operators exists ) {			
			// create operators map if doesn't exists
			operators = createOperators();
		}
		return operators?.get( code );
	}
	
	"Responds on message. 
	 respond format: 
	 	{ 
	 		response -> String // response code
	 		error -> String // error description 
	 		name -> String // item name
	 		state -> String // item state
	 		description -> JSON // item description
	 	}
	 "
	shared void respondMessage( "Message to respond on." Message<JSON> msg, "Rreply to be send" JSON reply ) {
		reply.put( definitions.fieldResponse, definitions.responseOK );
		msg.reply( reply );
	}
	
	"Fails message with message."
	shared void failMessage (
		"Message to be responded with failure." Message<JSON> msg,
		"Error to fail with." String errorMessage )
	{
		msg.reply (
			JSON {
				definitions.fieldResponse -> definitions.responseError,
				definitions.fieldError -> errorMessage
			}
		);
	}
	
	"Extracts state from request, helper method."
	shared TimerState? extractState( JSON request ) {
		if ( is String state = request.get( definitions.fieldState ) ) {
			return timerRunning.byName( state );
		}
		else {
			return null;
		}
	}
		
	"Message has been received from event bus - process it!."
	void onMessage( "Message from event bus." Message<JSON> msg ) {
		if ( exists request = msg.body(), is String operation = request.get( definitions.fieldOperation ) ) {
			// depending on operation code
			if ( exists operator = getOperator( operation ) ) {
				operator( msg );
			}
			else {
				failMessage( msg, errorMessages.unsupportedOperation );
			}
		}
		else {
			// response with wrong format error
			failMessage( msg, errorMessages.operationIsNotSpecified );
		}
	}
	
	"Connects to event bus, returns promise resolved when event listener registered."
	shared default void connect( "Address to listen to." String address ) {
		// setup event bus listener
		eventBus.consumer( address, onMessage );
	}

}
