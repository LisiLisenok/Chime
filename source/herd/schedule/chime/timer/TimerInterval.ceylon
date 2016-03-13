import ceylon.time {

	DateTime,
	dateTime
}


"Incremental timer - starts from specific time date
 and increments on certain miliseconds each time when fired - [[intervalMilliseconds]].    
 [[intervalMilliseconds]] to be >= 0. 
 "
by( "Lis" )
class TimerInterval (
	"Timing interval in miliseconds, to be >= 0." shared Integer intervalMilliseconds
)
		satisfies Timer
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
