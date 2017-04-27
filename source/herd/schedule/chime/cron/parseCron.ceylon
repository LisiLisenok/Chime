import ceylon.time {

	today
}


"Parses cron expression from strings."
since( "0.1.0" ) by( "Lis" )
shared CronExpression? parseCron (
	"cron style string with seconds" String seconds,
	"cron style string with minutes" String minutes,
	"cron style string with hours" String hours,
	"cron style string with daysOfMonth" String daysOfMonth,
	"cron style string with months" String months,
	"cron style string with days of week - optional if not specified all weekdays included" String? daysOfWeek = null,
	"cron style string with years - optional if not specified every year included" String? years = null,
	"maximum year period." Integer maxYearPeriod = 10
) {
	
	// replace month names by numbers
	variable String monthsToInt = calendar.replaceMonthByNumber( months );
	
	// parse mandatory fields
	value secondsSet = parseCronStyle( seconds, 0, 59 );
	value minutesSet = parseCronStyle( minutes, 0, 59 );
	value hoursSet = parseCronStyle( hours, 0, 23 );
	value daysOfMonthSet = parseCronStyle( daysOfMonth, 1, 31 );
	value monthsSet = parseCronStyle( monthsToInt, 1, 12 );
	
	if ( !secondsSet.empty && !minutesSet.empty && !hoursSet.empty && !daysOfMonthSet.empty && !monthsSet.empty ) {
		
		// parse days of week, which is nonmandatory, if doesn't exists all days accepted
		DaysOfWeekList daysOfWeekList;
		if ( exists strDaysOfWeek = daysOfWeek, !strDaysOfWeek.empty ) {
			// replace all weekday names by numbers
			variable String weekdayToInt = calendar.replaceDayOfWeekByNumber( strDaysOfWeek );
			// do parsing
			if ( exists parsedDaysOfWeek = parseCronDaysOfWeek( weekdayToInt ) ) {
				daysOfWeekList = parsedDaysOfWeek;
			}
			else {
				return null;
			}
		}
		else {
			daysOfWeekList = DaysOfWeekList( {DayOrderAll()} );
		}
		
		// parse years, which is nonmandatory, if doesn't exists any year accepted
		Set<Integer> yearsSet;
		if ( exists strYears = years, !strYears.empty ) {
			Integer todayYear = today().year;
			yearsSet = parseCronStyle( strYears, todayYear, todayYear + maxYearPeriod );
			if ( yearsSet.empty ) {
				return null;
			}
		}
		else {
			yearsSet = emptySet;
		}
		
		return CronExpression( secondsSet, minutesSet, hoursSet, daysOfMonthSet, monthsSet, daysOfWeekList, yearsSet );
	}
	else {
		return null;
	}
}
