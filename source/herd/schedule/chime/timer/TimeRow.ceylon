import ceylon.time {

	DateTime
}


"Time row interface. Acts like _iterator_ but might be restarted from any date."
since( "0.1.0" ) by( "Lis" )
shared interface TimeRow
{
	
	"Starts the timer using  [[current]] time.  
	 Returns next fire time if successfull or null if completed."
	shared formal DateTime? start( "current time" DateTime current );
	
	"Shifts time to the next one.  
	 Returns next fire time if successfull and null if completed."
	shared formal DateTime? shiftTime();
	
}
