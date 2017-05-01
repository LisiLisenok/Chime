import ceylon.time.base {
	DayOfWeek,
	Month
}


"Defines calendar constants."
since( "0.1.0" ) by( "Lis" )
shared object calendar
{	
	
	"Mapping month short name to month id."
	shared Map<String, Integer> monthShortMap =
		map<String, Integer> {
			"JAN" -> 1,
			"FEB" -> 2,
			"MAR" -> 3,
			"APR" -> 4,
			"MAY" -> 5,
			"JUN" -> 6,
			"JUL" -> 7,
			"AUG" -> 8,
			"SEP" -> 9,
			"OCT" -> 10,
			"NOV" -> 11,
			"DEC" -> 12
		};
	
	"Mapping month name to month id."
	shared Map<String, Integer> monthFullMap = 
		map<String, Integer> {
			"JANUARY" -> 1,
			"FEBRUARY" -> 2,
			"MARCH" -> 3,
			"APRIL" -> 4,
			"MAY" -> 5,
			"JUNE" -> 6,
			"JULY" -> 7,
			"AUGUST" -> 8,
			"SEPTEMBER" -> 9,
			"OCTOBER" -> 10,
			"NOVEMBER" -> 11,
			"DECEMBER" -> 12
		};
	
	"Mapping day of week short name to day of week id."
	shared Map<String, Integer> dayOfWeekShortMap =
		map<String, Integer> {
			"SUN" -> 1,
			"MON" -> 2,
			"TUE" -> 3,
			"WED" -> 4,
			"THU" -> 5,
			"FRI" -> 6,
			"SAT" -> 7
		};
	
	"Mapping day of week name to day of week id."
	shared Map<String, Integer> dayOfWeekFullMap =
		map<String, Integer> {
			"SUNDAY" -> 1,
			"MONDAY" -> 2,
			"TUESDAY" -> 3,
			"WEDNESDAY" -> 4,
			"THURSDAY" -> 5,
			"FRIDAY" -> 6,
			"SATURDAY" -> 7
		};
	
	
	String replaceStringToNumber( String expression, Map<String, Integer> map ) {
		variable String ret = expression;
		for ( key -> item in map ) {
			ret = ret.replace( key, item.string );
		}
		return ret;
	}
	
	"Replace all occurancies of month names by corresponding number."
	shared String replaceMonthByNumber( String expression )
			=> replaceStringToNumber( replaceStringToNumber( expression.trimmed.uppercased, monthFullMap ), monthShortMap );
	
	"Replace all occurancies of weekday names by corresponding number."
	shared String replaceDayOfWeekByNumber( String expression )
			=> replaceStringToNumber( replaceStringToNumber( expression.trimmed.uppercased, dayOfWeekFullMap ), dayOfWeekShortMap );

	
	"Integer representation of a day of week."
	shared Integer digitalDayOfWeek( Integer|DayOfWeek|String dayOfWeek ) {
		switch ( dayOfWeek )
		case ( is Integer ) {
			"Has to be a valid day of week. Actually is ``dayOfWeek``."
			assert ( dayOfWeek > 0 && dayOfWeek < 8 );
			return dayOfWeek;
		}
		case ( is DayOfWeek ) {
			return dayOfWeek.successor.integer;
		}
		case ( is String ) {
			"Has to be a valid day of week. Actually is ``dayOfWeek``."
			assert ( is Integer ret = Integer.parse( calendar.replaceDayOfWeekByNumber( dayOfWeek ) ) );
			return ret;
		}
	}
	
	"Integer representation of a list of day of week."
	shared {Integer+} digitalDaysOfWeekList( {Integer|DayOfWeek|String+} daysOfWeek ) {
		return { for ( item in daysOfWeek ) digitalDayOfWeek( item ) };
	}
	
	shared String cronDaysOfWeek( {Integer|DayOfWeek|String+} daysOfWeek ) {
		StringBuilder builder = StringBuilder();
		for ( item in daysOfWeek.exceptLast ) {
			builder.append( digitalDayOfWeek( item ).string + "," );
		}
		builder.append( digitalDayOfWeek( daysOfWeek.last ).string );
		return builder.string;
	}
	
	"Integer representation of a month."
	shared Integer digitalMonth( Integer|Month|String month ) {
		switch ( month )
		case ( is Integer ) {
			"Has to be a valid month. Actually is ``month``."
			assert ( month > 0 && month < 13 );
			return month;
		}
		case ( is Month ) {
			return month.integer;
		}
		case ( is String ) {
			"Has to be a valid month. Actually is ``month``."
			assert ( is Integer ret = Integer.parse( calendar.replaceMonthByNumber( month ) ) );
			return ret;
		}
	}
	
}
