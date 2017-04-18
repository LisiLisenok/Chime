import ceylon.json {

	JSON=Object
}
import ceylon.time {

	dateTime,
	DateTime
}
import herd.schedule.chime.timer {

	TimerFactory,
	Timer
}
import herd.schedule.chime.cron {

	calendar
}


"Uses [[JSON]] description to creates [[TimerContainer]] with timer [[Timer]] created by timer factory."
see( `interface TimerFactory`, `interface Timer`, `class TimerContainer` )
since( "0.1.0" ) by( "Lis" )
class TimerCreator( "Factory to create timers." TimerFactory factory )
{
		
	"Creates timer from creation request."
	shared TimerContainer|String createTimer( "Timer name." String name, "Request with timer description." JSON request ) {
		if ( is JSON description = request[Chime.key.description] ) {
			value timer = factory.createTimer( description );
			if ( is Timer timer ) {
				return createTimerContainer( request, description, name, timer );
			}
			else {
				return timer;
			}
		}
		else {
			// timer description to be specified
			return errorMessages.timerDescriptionHasToBeSpecified;
		}
	}
	
	
	"Creates timer container by container and creation request."
	TimerContainer|String createTimerContainer (
		"Request on timer creation." JSON request,
		"Timer desciption." JSON description,
		"Timer name." String name,
		"Timer." Timer timer
	) {
		// extract start date if exists
		DateTime? startDate;
		if ( is JSON startTime = request[Chime.key.startTime] ) {
			if ( exists st = extractDate( startTime ) ) {
				startDate = st;
			}
			else {
				return errorMessages.incorrectStartDate;
			}
		}
		else {
			startDate = null;
		}
		
		// extract end date if exists
		DateTime? endDate;
		if ( is JSON endTime = request[Chime.key.endTime] ) {
			if ( exists st = extractDate( endTime ) ) {
				endDate = st;
			}
			else {
				return errorMessages.incorrectEndDate;
			}
		}
		else {
			endDate = null;
		}
		
		// end date has to be after start!
		if ( exists st = startDate, exists et = endDate ) {
			if ( et <= st ) {
				return errorMessages.endDateToBeAfterStartDate;
			}
		}
		
		if ( exists converter = dummyConverter.getConverter( request ) ) {
			return TimerContainer (
				name, description, extractPublish( request ), timer,
				converter, extractMaxCount( request ), startDate, endDate
			);
		}
		else {
			return errorMessages.unsupportedTimezone;
		}
		
	}
	
	"Extracts month from field with key key. The field can be either integer or string (like JAN, FEB etc, see [[calendar]])."
	Integer? extractMonth( JSON description, String key ) {
		if ( is Integer val = description[key] ) {
			if ( val > 0 && val < 13 ) {
				return val;
			}
			else {
				return null;
			}
		}
		else if ( is String val = description[key] ) {
			if ( exists ret = calendar.monthFullMap[val] ) {
				return ret;
			}
			return calendar.monthShortMap[val];
		}
		else {
			return null;
		}
	}
	
	"Extracts date from [[JSON]], key returns [[JSON]] object with date."
	DateTime? extractDate( JSON date ) {
		if ( is Integer seconds = date[Chime.date.seconds],
			is Integer minutes = date[Chime.date.minutes],
			is Integer hours = date[Chime.date.hours],
			is Integer dayOfMonth = date[Chime.date.dayOfMonth],
			is Integer year = date[Chime.date.year],
			exists month = extractMonth( date, Chime.date.month )
		) {
			try {
				return dateTime( year, month, dayOfMonth, hours, minutes, seconds );
			}
			catch ( Throwable err ) {
				return null;
			}
		}
		return null;
	}
	
	"Extracts publish field from description.  
	 `publish` or `send` are nonmandatory field.  
	 If no field extracted - default to be send." 
	Boolean extractPublish( JSON description ) {
		if ( is Boolean b = description[Chime.key.publish] ) {
			return b;
		}
		else {
			return false;
		}
	}
	
	"`maxCount` - nonmandatory field, if not specified - infinitely."
	Integer? extractMaxCount( JSON description ) {
		if ( is Integer c = description[Chime.key.maxCount] ) {
			if ( c > 0 ) {
				return c;
			}
			else {
				return 1;
			}
		}
		else {
			return null;
		}
	}
	
}
