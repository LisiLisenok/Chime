import ceylon.time {

	DateTime
}
import ceylon.json {
	ObjectValue
}
import io.vertx.ceylon.core.eventbus {
	DeliveryOptions
}


"Time row interface. Acts like _enumerator_ but might be restarted from any date."
since( "0.1.0" ) by( "Lis" )
shared interface TimeRow
{
	
	"Starts the timer using  [[current]] time.  
	 Returns next fire time if successfull or null if completed."
	shared formal DateTime? start( "current time" DateTime current );
	
	"Shifts time to the next one.  
	 Returns next fire time if successfull and null if completed."
	shared formal DateTime? shiftTime();
	
	"Message to be attached to the timer fire event."
	shared formal ObjectValue? message;
	
	"Delivery options message has to be sent with."
	shared formal DeliveryOptions? options;
	
}


"`TimeRow` which return `null`."
object emptyTimeRow satisfies TimeRow {
	shared actual ObjectValue? message => null;
	shared actual DeliveryOptions? options => null;
	shared actual DateTime? shiftTime() => null;
	shared actual DateTime? start(DateTime current) => null;
}
