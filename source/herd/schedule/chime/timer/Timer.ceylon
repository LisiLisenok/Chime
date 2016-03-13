import ceylon.time {

	DateTime
}


"Timer interface."
by( "Lis" )
shared interface Timer
{
	
	"Starts the timer using  [[current]] time.
	 Returns next fire time if successfull or null if completed."
	shared formal DateTime? start( "current time" DateTime current );
	
	"Shifts time to next one.
	 Returns next fire time if successfull and null if completed."
	shared formal DateTime? shiftTime();
	
}
