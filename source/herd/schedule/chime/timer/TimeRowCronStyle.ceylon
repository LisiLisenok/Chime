import ceylon.time {

	DateTime,
	dateTime
}

import ceylon.time.chronology {

	gregorian
}
import herd.schedule.chime.cron {

	CronExpression
}


"Ccron-like timer."
since( "0.1.0" ) by( "Lis" )
class TimeRowCronStyle (
	"Cron expression rules the timer." CronExpression expression
)
		satisfies TimeRow
{
	
	// indexies of current time
	variable Iterator<Integer> secondIndex = expression.seconds.iterator();
	variable Iterator<Integer> minuteIndex = expression.minutes.iterator();
	variable Iterator<Integer> hourIndex = expression.hours.iterator();
	variable Iterator<Integer> dayIndex = expression.daysOfMonth.iterator();
	variable Iterator<Integer> monthIndex = expression.months.iterator();
	variable Iterator<Integer> yearIndex = expression.years.iterator();
	
	// current time
	variable Integer currentYear = 0;
	variable Integer currentMonth = 1;
	variable Integer currentDay = 1;
	variable Integer currentHour = 0;
	variable Integer currentMinute = 0;
	variable Integer currentSecond = 0;
	
	"current date and time"
	variable DateTime currentDate = dateTime( 0, 1, 1 );
	
	variable Boolean completed = false;
	
	
	"Completes the timer."
	void completeTimer() {
		completed = true;
		currentDate = dateTime( 0, 1, 1 );
		secondIndex = expression.seconds.iterator();
		minuteIndex = expression.minutes.iterator();
		hourIndex = expression.hours.iterator();
		dayIndex = expression.daysOfMonth.iterator();
		monthIndex = expression.months.iterator();
		yearIndex = expression.years.iterator();
	}
	
	"Starts seconds from beginning."
	void resetSeconds() {
		secondIndex = expression.seconds.iterator();
		if ( is Integer val = secondIndex.next() ){
			currentSecond = val;
		}
		else {
			currentSecond = 0;
		}
	}
	
	"Starts minutes from beginning and reset seconds."
	void resetMinutes() {
		minuteIndex = expression.minutes.iterator();
		if ( is Integer val = minuteIndex.next() ){
			currentMinute = val;
		}
		else {
			currentMinute = 0;
		}
		resetSeconds();
	}
	
	"Starts hours from beginning and reset minutes."
	void resetHours() {
		hourIndex = expression.hours.iterator();
		if ( is Integer val = hourIndex.next() ){
			currentHour = val;
		}
		else {
			currentHour = 0;
		}
		resetMinutes();
	}
	
	"Start. days from beginning and reset hours."
	void resetDays() {
		dayIndex = expression.daysOfMonth.iterator();
		if ( is Integer val = dayIndex.next() ){
			currentDay = val;
		}
		else {
			currentDay = 1;
		}
		resetHours();
	}
	
	"Starts days from beginning and reset and reset days."
	void resetMonth() {
		monthIndex = expression.months.iterator();
		if ( is Integer val = monthIndex.next() ){
			currentMonth = val;
		}
		else {
			currentMonth = 1;
		}
		resetDays();
	}
	
	"Returns `true` if data is accepted and `false` otherwise."
	Boolean isDateAcepted() {
		value converted = gregorian.dateFrom( gregorian.fixedFrom( [currentYear, currentMonth, currentDay] ) );
		return converted[0] == currentYear && converted[1] == currentMonth && converted[2] == currentDay;
	}
	
	"Shifts year to next after the latest fire. Next year is one from specified in [[CronExpression.years]].
	 If all years scooped out timing is completed.  
	 Returns `true` if completed."
	Boolean shiftYear() {
		// shift to next year
		if ( !expression.years.empty ) {
			if ( is Integer item = yearIndex.next() ) {
				currentYear = item;
			}
			else {
				return true;
			}
		}
		else {
			currentYear ++;
		}
		return false;
	}
	
	"Shifts month to next after the latest fire. Next month is one from specified in [[CronExpression.months]].  
	 If all months scooped out shifts year - [[shiftYear]].  
	 Returns `true` if completed and `false` otherwise."
	Boolean shiftMonth() {
		// shift to next month
		if ( is Integer item = monthIndex.next() ) {
			currentMonth = item;
			if ( isDateAcepted() ) {
				return false;
			}
			else {
				resetMonth();
				return shiftYear();
			}
		}
		else {
			resetMonth();
			return shiftYear();
		}
	}
	
	"Shifts day to next after the latest fire. Next day is one from specified in [[CronExpression.daysOfMonth]]. 
	 If all days scooped out shifts month - [[shiftMonth]].  
	 Returns `true` if completed and `false` otherwise."
	Boolean shiftDay() {
		// shift to next day
		if ( is Integer item = dayIndex.next() ) {
			currentDay = item;
			if ( isDateAcepted() ) {
				return false;
			}
			else {
				resetDays();
				return shiftMonth();
			}
		}
		else {
			resetDays();
			return shiftMonth();
		}
	}
	
	"Shifts hours to next after the latest fire. Next hours are one from specified in [[CronExpression.hours]]. 
	 If all hours scooped out shifts day - [[shiftDay]].  
	 Returns `true` if completed and `false` otherwise."
	Boolean shiftHour() {
		// shift to next hour
		if ( is Integer item = hourIndex.next() ) {
			currentHour = item;
			return false;
		}
		else {
			resetHours();
			return shiftDay();
		}
	}
	
	"Shifts minutes to next after the latest fire. Next minutes are one from specified in [[CronExpression.minutes]].  
	 If all minutes scooped out shifts hours - [[shiftHour]].  
	 Returns `true` if completed and `false` otherwise."
	Boolean shiftMinute() {
		// shift to next minute
		if ( is Integer item = minuteIndex.next() ) {
			currentMinute = item;
			return false;
		}
		else {
			resetMinutes();
			return shiftHour();
		}
	}
	
	"Shifts seconds to next after the latest fire. Next seconds are one from specified in [[CronExpression.seconds]]. 
	 If all seconds scooped out shifts minutes - [[shiftMinute]]. 
	 Returns `true` if completed and `false` otherwise."
	Boolean shiftSecond() {
		if ( is Integer item = secondIndex.next() ) {
			currentSecond = item;
			return false;
		}
		else {
			resetSeconds();
			return shiftMinute();
		}
		
	}
	
	"Considers weekdays in the [[currentDate]]. I.e. shifts days while [[currentDay]] is not within [[CronExpression.daysOfWeek]].  
	 Returns `false` if timer to be completed and `true` otherwise."
	Boolean considerWeekdays() {
		try {
			variable DateTime date = dateTime( currentYear, currentMonth, currentDay, currentHour, currentMinute, currentSecond );
			// shift to appropriate day of week
			variable Boolean reset = true;
			while ( !expression.daysOfWeek.falls( date.date ) && date != currentDate ) {
				if ( reset ) {
					resetHours();
					reset = false;
				}
				if ( shiftDay() ) {
					completeTimer();
					return false;
				}
				date = dateTime( currentYear, currentMonth, currentDay, currentHour, currentMinute, currentSecond );
			}
			if ( date != currentDate ) {
				currentDate = date;
				return true;
			}
			else {
				completeTimer();
				return false;
			}
		}
		catch ( Throwable err ) {
			completeTimer();
			return false;
		}
	}
	
	
	"Starts timing from specified UTC time. 
	 Returns `true` if started and `false` if completed."
	Boolean startCron( DateTime current ) {
		// find nearest time
		
		// year
		if ( expression.years.empty ) {
			currentYear = current.year;
		}
		else {
			currentYear = 0;
			yearIndex = expression.years.iterator();
			while ( is Integer item = yearIndex.next() ) {
				if ( item >= current.year ) {
					currentYear = item;
					break;
				}
			}
			if ( currentYear == 0 ) {
				completeTimer();
				return false;
			}
			else if ( currentYear > current.year ) {
				resetMonth();
				return considerWeekdays();
			}
		}
		
		// month
		currentMonth = 0;
		monthIndex = expression.months.iterator();
		while ( is Integer item = monthIndex.next() ) {
			if ( item >= current.month.integer ) {
				currentMonth = item;
				break;
			}
		}
		if ( currentMonth == 0 ) {
			resetMonth();
			if ( shiftYear() ) {
				completeTimer();
				return false;
			}
			else {
				return considerWeekdays();
			}
		}
		if ( currentMonth > current.month.integer ) {
			resetDays();
			return considerWeekdays();
		}
		
		// day
		currentDay = 0;
		dayIndex = expression.daysOfMonth.iterator();
		while ( is Integer item = dayIndex.next() ) {
			if ( item >= current.day ) {
				currentDay = item;
				break;
			}
		}
		if ( currentDay == 0 ) {
			resetDays();
			if ( shiftMonth() ) {
				completeTimer();
				return false;
			}
			else {
				return considerWeekdays();
			}
		}
		if ( currentDay > current.day ) {
			resetHours();
			return considerWeekdays();
		}
		
		// hour
		currentHour = -1;
		hourIndex = expression.hours.iterator();
		while ( is Integer item = hourIndex.next() ) {
			if ( item >= current.hours ) {
				currentHour = item;
				break;
			}
		}
		if ( currentHour == -1 ) {
			resetHours();
			if ( shiftDay() ) {
				completeTimer();
				return false;
			}
			else {
				return considerWeekdays();
			}
		}
		if ( currentHour > current.hours ) {
			resetMinutes();
			return considerWeekdays();
		}
		
		// minutes
		currentMinute = -1;
		minuteIndex = expression.minutes.iterator();
		while ( is Integer item = minuteIndex.next() ) {
			if ( item >= current.minutes ) {
				currentMinute = item;
				break;
			}
		}
		if ( currentMinute == -1 ) {
			resetMinutes();
			if ( shiftHour() ) {
				completeTimer();
				return false;
			}
			else {
				return considerWeekdays();
			}
		}
		if ( currentMinute > current.minutes ) {
			resetSeconds();
			return considerWeekdays();
		}
		
		// seconds
		currentSecond = -1;
		secondIndex = expression.seconds.iterator();
		while ( is Integer item = secondIndex.next() ) {
			if ( item >= current.seconds ) {
				currentSecond = item;
				break;
			}
		}
		if ( currentSecond == -1 ) {
			resetSeconds();
			if ( shiftMinute() ) {
				completeTimer();
				return false;
			}
		}
		
		// shift to appropriate day of week
		return considerWeekdays();
		
	}
	
	"Calculates next local time and stores it in [[currentDate]]. 
	 Returns `true` if successfully shifted and `false` if to be completed."
	Boolean shiftCronTime() {
		if ( shiftSecond() ) {
			completeTimer();
			return false;
		}
		else {
			return considerWeekdays();
		}
	}
	
	
	/* Timer interface */
	
	shared actual DateTime? start( DateTime current ) {
		if ( startCron( current ) ) {
			return currentDate;
		}
		else {
			return null;
		}
	}
	
	shared actual DateTime? shiftTime() {
		if ( shiftCronTime() ) {
			return currentDate;
		}
		else {
			return null;
		}
	}
	
}
