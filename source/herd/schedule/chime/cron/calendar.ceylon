

"Defines calendar constants."
by( "Lis" )
shared object calendar
{	
	
	// description fields
	
	// cron and date fields
	shared String seconds = "seconds";
	shared String minutes = "minutes";
	shared String hours = "hours";
	shared String daysOfWeek = "days of week";
	
	shared String daysOfMonth = "days of month";
	shared String months = "months";
	shared String years = "years";
	
	shared String dayOfMonth = "day of month";
	shared String month = "month";
	shared String year = "year";
	
	// name to id maps
	
	"mapping of month name to month id"
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
	
	"mapping of day name to day id"
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
	
	"mapping of day name to day id"
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
			=> replaceStringToNumber( replaceStringToNumber( expression, monthFullMap ), monthShortMap );
	
	"Replace all occurancies of weekday names by corresponding number."
	shared String replaceDayOfWeekByNumber( String expression )
			=> replaceStringToNumber( replaceStringToNumber( expression, dayOfWeekFullMap ), dayOfWeekShortMap );
	
	
}
