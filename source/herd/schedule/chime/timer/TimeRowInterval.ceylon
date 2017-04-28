import ceylon.time {

	DateTime,
	dateTime
}
import ceylon.json {
	ObjectValue
}
import io.vertx.ceylon.core.eventbus {
	DeliveryOptions
}


"Incremental timer - starts from specific time date
 and increments on certain miliseconds each time when fired - [[intervalMilliseconds]].    
 [[intervalMilliseconds]] to be >= 0. 
 "
since( "0.1.0" ) by( "Lis" )
class TimeRowInterval (
	"Timing delay in miliseconds, to be >= 0." shared Integer intervalMilliseconds,
	shared actual ObjectValue? message,
	shared actual DeliveryOptions? options
)
		satisfies TimeRow
{
	"Current date and time."
	variable DateTime currentDate = dateTime( 0, 1, 1 );
	
		
	/* Timer interface */
		
	shared actual DateTime? start( DateTime current ) {
		// next fire time
		currentDate = current.plusMilliseconds( intervalMilliseconds );
		return currentDate;
	}
	
	shared actual DateTime? shiftTime() {
		currentDate = currentDate.plusMilliseconds( intervalMilliseconds );
		return currentDate;	
	}

}
