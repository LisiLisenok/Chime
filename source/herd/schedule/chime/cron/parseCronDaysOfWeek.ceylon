import ceylon.collection {

	ArrayList,
	HashSet,
	linked,
	Hashtable
}
import ceylon.time.base {

	dayOfWeek,
	DayOfWeek
}


"Parses days of week from string."
since( "0.1.0" ) by( "Lis" )
DaysOfWeekList? parseCronDaysOfWeek( String expression ) {
	
	// all values
	if ( expression == cron.allValues.string || expression.empty ) {
		return DaysOfWeekList( {DayOrderAll()} );
	}
	
	ArrayList<DayOrder> days = ArrayList<DayOrder>();
	// parse tokens
	{String*} tokens = expression.split( cron.delimiter.equals ).map( String.trimmed );
	for ( token in tokens ) {
		if ( exists parsedToken = parseDayOrder( token ) ) {
			days.add( parsedToken );
		}
		else {
			return null;
		}
	}
	
	if ( days.empty ) {
		return null;
	}
	else {
		return DaysOfWeekList( { for ( item in days ) item } );
	}
	
}


"Parses day order from string."
by( "Lis" )
DayOrder? parseDayOrder( String expression ) {
	if ( expression.contains( cron.nth ) ) {
		{String*} tokens = expression.split( cron.nth.equals );
		if ( tokens.size == 2,
			exists weekday = parseStringToInteger( tokens.first ),
			exists order = parseStringToInteger( tokens.last )
		) {
			if ( weekday > 0 && weekday < 8 && order > 0 && order < 6 ) {
				return DayOrderNth( dayOfWeek( weekday - 1 ), order );
			} 
		}
	}
	else if ( exists last = expression.last, last == cron.last ) {
		if ( exists day = parseStringToInteger( expression.spanTo( expression.size - 2 ) ) ) {
			if ( day > 0 && day < 8 ) {
				return DayOrderLast( dayOfWeek( day - 1 ) );
			}
		}
	}
	else {
		if ( exists daysSet = parseCronRange( expression, 1, 7 ) ) {
			return DayOrderWeek (
				HashSet<DayOfWeek> (
					linked, Hashtable(), daysSet.map( ( Integer element ) => dayOfWeek( element - 1 ) )
				)
			);
		}
	}
	return null;
}
