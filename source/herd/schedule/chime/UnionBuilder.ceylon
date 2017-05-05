import ceylon.collection {
	ArrayList
}
import ceylon.json {
	
	JSON = Object,
	JSONArray = Array
}
import ceylon.time {
	DateTime,
	Time
}
import ceylon.time.base {
	DayOfWeek,
	Month
}
import herd.schedule.chime.cron {
	calendar,
	cron
}


"Builds an union timer.  
 The builder has a number of function to add particular timer.
 The function may be called in any order and any number of times.  
 Finally, [[UnionBuilder.build]] has to be called to build the timer JSON description.   
 "
tagged( "Builder" )
see( `class CronBuilder`, `function package.every` )
since( "0.2.1" ) by( "Lis" )
shared class UnionBuilder
{
	
	ArrayList<JSON> union;
	
	
	"Instantiates new empty cron builder."
	shared new () {
		union = ArrayList<JSON>();
	}
	
	"Instatiates new builder and copy data from `other`."
	shared new fromBuilder( "Builder to copy data from." UnionBuilder other ) {
		union = ArrayList<JSON>{ for( item in other.union ) item.clone() };
	}
	
	
	"Builds the timer."
	shared JSON build()
		=> JSON {
			Chime.key.type -> Chime.type.union,
			Chime.key.timers -> JSONArray( union )
		};

	
	"Adds timer by its JSON description."
	shared void timer( "Timer description to be added." JSON timer ) => union.add( timer );
	
	"Fires at the given date / time with year taken into account.
	 So, this timer will fire just a once."
	shared void at( "Date / time to fire at." DateTime time )
		=> union.add (
			JSON {
				Chime.key.type -> Chime.type.cron,
				Chime.date.seconds -> time.seconds.string,
				Chime.date.minutes -> time.minutes.string,
				Chime.date.hours -> time.hours.string,
				Chime.date.daysOfMonth -> time.day.string,
				Chime.date.months -> time.month.string
			}
		);
	
	"Fires every year at the given time, day and month."
	shared void annual (
		"Time to fire at." Time time,
		"Day of month to fire at." Integer dayOfMonth,
		"Month to fire at." Integer|String|Month month,
		"Optional list of days of week to limit fire event to.  
		 > Sunday is the first day of week."
		{Integer|String|DayOfWeek+} daysOfWeek = 1..7
	) => union.add (
		JSON {
			Chime.key.type -> Chime.type.cron,
			Chime.date.seconds -> time.seconds.string,
			Chime.date.minutes -> time.minutes.string,
			Chime.date.hours -> time.hours.string,
			Chime.date.daysOfMonth -> dayOfMonth.string,
			Chime.date.months -> calendar.digitalMonth( month ).string,
			Chime.date.daysOfWeek -> calendar.cronDaysOfWeek( daysOfWeek ),
			Chime.date.years -> cron.allValues.string
		}
	);
	
	"Fires every month at the given time and day of month.  
	 I.e. `monthly(time(0,0,0), 1)` will fire each 1st day of every month at 0:0:0."
	shared void monthly (
		"Time to fire at." Time time,
		"Day of month to fire at." Integer dayOfMonth,
		"Optional list of days of week to limit fire event to.  
		 > Sunday is the first day of week."
		{Integer|String|DayOfWeek+} daysOfWeek = 1..7
	) => union.add (
		JSON {
			Chime.key.type -> Chime.type.cron,
			Chime.date.seconds -> time.seconds.string,
			Chime.date.minutes -> time.minutes.string,
			Chime.date.hours -> time.hours.string,
			Chime.date.daysOfMonth -> dayOfMonth.string,
			Chime.date.months -> cron.allValues.string,
			Chime.date.daysOfWeek -> calendar.cronDaysOfWeek( daysOfWeek ),
			Chime.date.years -> cron.allValues.string
		}
	);
	
	"Fires every given day of week at the given time.  
	 I.e. `weekly(time(0,0,0), monday)` will fire each monday at 0:0:0 time."
	shared void weekly (
		"Time to fire at." Time time,
		"Day of week to fire at.  
		 > Sunday is the first day of week."
		Integer|String|DayOfWeek dayOfWeek
	) => union.add (
		JSON {
			Chime.key.type -> Chime.type.cron,
			Chime.date.seconds -> time.seconds.string,
			Chime.date.minutes -> time.minutes.string,
			Chime.date.hours -> time.hours.string,
			Chime.date.daysOfMonth -> cron.allValues.string,
			Chime.date.months -> cron.allValues.string,
			Chime.date.daysOfWeek -> calendar.digitalDayOfWeek( dayOfWeek ).string,
			Chime.date.years -> cron.allValues.string
		}
	);
	
	"Fires every month at the last day of week and given time.  
	 I.e. `last(time(0,0,0), friday)` will fire every month last friday at 0:0:0 time."
	shared void last (
		"Time to fire at." Time time,
		"Last day of week to fire at.  
		 > Sunday is the first day of week."
		Integer|String|DayOfWeek dayOfWeek
	) => union.add (
		JSON {
			Chime.key.type -> Chime.type.cron,
			Chime.date.seconds -> time.seconds.string,
			Chime.date.minutes -> time.minutes.string,
			Chime.date.hours -> time.hours.string,
			Chime.date.daysOfMonth -> cron.allValues.string,
			Chime.date.months -> cron.allValues.string,
			Chime.date.daysOfWeek -> calendar.digitalDayOfWeek( dayOfWeek ).string + cron.last.string,
			Chime.date.years -> cron.allValues.string
		}
	);
	
	"Fires every month at the n'th day of week and given time.  
	 I.e. `last(time(0,0,0), friday, 3)` will fire every month third friday at 0:0:0 time."
	shared void ordered (
		"Time to fire at." Time time,
		"Day of week to fire at.  
		 > Sunday is the first day of week."
		Integer|String|DayOfWeek dayOfWeek,
		"Theorder of the day of week to fire at." Integer order
	) => union.add (
		JSON {
			Chime.key.type -> Chime.type.cron,
			Chime.date.seconds -> time.seconds.string,
			Chime.date.minutes -> time.minutes.string,
			Chime.date.hours -> time.hours.string,
			Chime.date.daysOfMonth -> cron.allValues.string,
			Chime.date.months -> cron.allValues.string,
			Chime.date.daysOfWeek -> calendar.digitalDayOfWeek( dayOfWeek ).string + cron.nth.string + order.string,
			Chime.date.years -> cron.allValues.string
		}
	);
		
	"Fires daily at the given time.  
	 For example, `daily(Time(12,0,0), 1..5)` will fire at 12:0:0 at working days only."
	shared void daily (
		"Time to fire at." Time time,
		"Optional list of days of week to limit fire event to.  
		 > Sunday is the first day of week."
		{Integer|String|DayOfWeek+} daysOfWeek = 1..7
	) => union.add (
		JSON {
			Chime.key.type -> Chime.type.cron,
			Chime.date.seconds -> time.seconds.string,
			Chime.date.minutes -> time.minutes.string,
			Chime.date.hours -> time.hours.string,
			Chime.date.daysOfMonth -> cron.allValues.string,
			Chime.date.months -> cron.allValues.string,
			Chime.date.daysOfWeek -> calendar.cronDaysOfWeek( daysOfWeek ),
			Chime.date.years -> cron.allValues.string
		}
	);
	
	"Fires every given time interval."
	shared void every (
		"Timer interval measured in `timeUnit`." Integer interval,
		"Unit to measure `delay`." TimeUnit timeUnit = TimeUnit.seconds
	) {
		"Timer interval has to be positive, while given is ``interval``."
		assert( interval > 0 );
		union.add (
			JSON {
				Chime.key.type -> Chime.type.interval,
				Chime.key.delay -> interval * timeUnit.secondsIn
			}
		);
	}
	
}
