import ceylon.time {

	Date
}
import ceylon.time.base {

	DayOfWeek
}


"Checks order of day of week."
since( "0.1.0" ) by( "Lis" )
shared interface DayOrder
{
	"`true` if data falls on a one of ordered day and `false` otherwise."
	shared formal Boolean falls( Date date );
}


"Cheks if date falls on a one from day of week list."
by( "Lis" )
shared class DaysOfWeekList( "set of day order" shared {DayOrder*} orderedDays ) satisfies DayOrder
{
	"`true` if one of ordered days returns `true` and `false` if all of them returns `false`."
	shared actual Boolean falls( Date date ) {
		for ( item in orderedDays ) {
			if ( item.falls( date ) ) {
				return true;
			}
		}
		return false;
	}	
}


"All days are accepted."
class DayOrderAll() satisfies DayOrder
{
	shared actual Boolean falls( Date date ) => true;
}

"Checks if data falls on one of specified day of week."
class DayOrderWeek( "Set of accepted days of week, if empty all days are rejected." shared Set<DayOfWeek> daysOfWeek )
		satisfies DayOrder
{
	shared actual Boolean falls( Date date ) =>  daysOfWeek.contains( date.dayOfWeek );
}

"Checks if date is nth day of week."
class DayOrderNth( "Accepted day of week." shared DayOfWeek day, "'nth' order of day of week." Integer order )
		satisfies DayOrder
{
	shared actual Boolean falls( Date date ) => ( date.dayOfWeek == day ) && ( order == date.day / 7 + 1 );
}

"Checks if date is last day of week in the month."
class DayOrderLast( "Accepted day of week." shared DayOfWeek day )
		satisfies DayOrder
{
	shared actual Boolean falls( Date date ) => ( date.dayOfWeek == day ) && ( date.plusDays( 7 ).month != date.month );
}

