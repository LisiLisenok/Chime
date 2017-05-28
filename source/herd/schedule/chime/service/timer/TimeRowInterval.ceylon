import ceylon.time {

	DateTime,
	dateTime
}


"Incremental timer - starts from specific time date
 and increments on certain miliseconds each time when fired - [[intervalMilliseconds]].    
 [[intervalMilliseconds]] to be >= 0. 
 "
since("0.1.0") by("Lis")
class TimeRowInterval (
	"Timing delay in miliseconds, to be >= 0." shared Integer intervalMilliseconds
)
		satisfies TimeRow
{
	"Current date and time."
	variable DateTime currentDate = dateTime(0, 1, 1);
	
		
	shared actual DateTime? start(DateTime current) => currentDate = current.plusMilliseconds(intervalMilliseconds);
	
	shared actual DateTime? shiftTime() => currentDate = currentDate.plusMilliseconds(intervalMilliseconds);

	shared actual String string => "interval time row with delay of ``intervalMilliseconds`` ms";
	
}
