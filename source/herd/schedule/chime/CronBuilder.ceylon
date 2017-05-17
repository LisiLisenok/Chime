import ceylon.json {
	
	JsonObject
}
import herd.schedule.chime.cron {
	cron,
	calendar,
	parseCron
}
import ceylon.time.base {
	DayOfWeek,
	Month
}


"Builds cron timer `JsonObject` description.  
 
 The builder has a number of function to add particular cron record to the description.
 The function may be called in any order and any number of times.  
 Finally, [[CronBuilder.build]] has to be called to build the timer `JsonObject` description.  
 
  > Note that 'seconds', 'minutes', 'hours', 'days of month' and 'month' are required fields.
   While 'years' and 'days of week' are optional.  

 Example:  
 	JsonObject cron = CronBuilder().withSeconds(3).withMinutes(0).withHours(1).withAllDays().withAllMonths().build();	
 Leads to the following cron description:
  		JsonObject {  
 			\"type\" -> \"cron\",  
 			\"seconds\" -> \"3\",  
 			\"minutes\" -> \"0\",  
 			\"hours\" -> \"1\",  
 			\"days of month\" -> \"*\",  
 			\"months\" -> \"*\"  
 		}  
 
 "
tagged( "Builder" )
see( `function every`, `class UnionBuilder` )
since( "0.2.1" ) by( "Lis" )
shared class CronBuilder {
	
	StringBuilder seconds = StringBuilder();
	StringBuilder minutes = StringBuilder();
	StringBuilder hours = StringBuilder();
	StringBuilder daysOfWeek = StringBuilder();
	StringBuilder daysOfMonth = StringBuilder();
	StringBuilder months = StringBuilder();
	StringBuilder years = StringBuilder();
	
	"Instantiates new empty cron builder."
	shared new () {}
	
	"Instatiates new builder and copy data from `other`."
	shared new fromBuilder( "Builder to copy data from." CronBuilder other ) {
		seconds.append( other.seconds.string );
		minutes.append( other.minutes.string );
		hours.append( other.hours.string );
		daysOfWeek.append( other.daysOfWeek.string );
		daysOfMonth.append( other.daysOfMonth.string );
		months.append( other.months.string );
		years.append( other.years.string );
	}
	
	
	void appendString( StringBuilder builder, String str ) {
		if ( builder.empty ) {
			builder.append( str );
		}
		else {
			builder.append( cron.delimiter.string + str );
		}
	}
	
	
	"Builds `JsonObject` description of cron timer.  
	 > Seconds, minutes, hours, days of month and months are required fields and to be set before building.  
	 > Days of week aand years are optional fields.  
	 "
	throws (
		`class AssertionError`,
		"Invalid cron expression, generally when one of seconds, minutes, hours, days of month or months are not defined."
	)
	shared JsonObject build() {
		"Invalid cron expression."
		assert (
			exists cronExpr = parseCron (
				seconds.string, minutes.string, hours.string, daysOfMonth.string,
				months.string, daysOfWeek.string, years.string
			)
		);
		JsonObject ret = JsonObject {
			Chime.type.key -> Chime.type.cron,
			Chime.date.seconds -> seconds.string,
			Chime.date.minutes -> minutes.string,
			Chime.date.hours -> hours.string,
			Chime.date.daysOfMonth -> daysOfMonth.string,
			Chime.date.months -> months.string
		};
		if ( !daysOfWeek.empty ) {
			ret.put( Chime.date.daysOfWeek, daysOfWeek.string );
		}
		if ( !years.empty ) {
			ret.put( Chime.date.years, years.string );
		}
		return ret;
	}
	
	
	"Adds all possible seconds."
	shared CronBuilder withAllSeconds() {
		appendString( seconds, cron.allValues.string );
		return this;
	}
	
	"Adds a list of seconds to the cron expression."
	throws( `class AssertionError`, "Any second in seconds list is < 0 || >= 60." )
	shared CronBuilder withSeconds( "List of the seconds to be added." Integer+ seconds ) {
		for ( sec in seconds ) {
			"Second has to be >= 0 && < 60. Actually is ``sec``."
			assert( sec > -1 && sec < 60 );
			appendString( this.seconds, sec.string );
		}
		return this;
	}
	
	"Adds range of seconds to the cron expression."
	throws( `class AssertionError`, "From, to or step is < 0 || >= 60." )
	shared CronBuilder withSecondsRange (
		"Start second." Integer from,
		"Optional end second." Integer? to = null,
		"Step, default is 1 second." Integer step = 1
	) {
		"Start second has to be >= 0 && < 60. Actually is ``from``."
		assert( from > -1 && from < 60 );
		"Step second has to be > 0 && < 60. Actually is ``step``."
		assert( step > 0 && step < 60 );
		if ( exists to ) {
			"End second has to be >= 0 && < 60 && >= start second."
			assert( to > -1 && to < 60 && to >= from );
			if ( step == 1 ) {
				appendString( this.seconds, from.string + cron.range.string + to.string );
			}
			else {
				appendString( this.seconds, from.string + cron.range.string + to.string + cron.increments.string + step.string );
			}
		}
		else {
			appendString( this.seconds, from.string + cron.increments.string + step.string );
		}
		return this;
	}
	
	
	"Adds all possible minutes."
	shared CronBuilder withAllMinutes() {
		appendString( minutes, cron.allValues.string );
		return this;
	}
	
	"Adds a list of minutes to the cron expression."
	throws( `class AssertionError`, "Any minute in minutes list is < 0 || >= 60." )
	shared CronBuilder withMinutes( "List of the minutes to be added." Integer+ minutes ) {
		for ( min in minutes ) {
			"Minute has to be >= 0 && < 60. Actually is ``min``."
			assert( min > -1 && min < 60 );
			appendString( this.minutes, min.string );
		}
		return this;
	}
	
	"Adds range of minutes to the cron expression."
	throws( `class AssertionError`, "From, to or step is < 0 || >= 60." )
	shared CronBuilder withMinutesRange (
		"Start minute." Integer from,
		"Optional end minute." Integer? to = null,
		"Step, default is 1 minute." Integer step = 1
	) {
		"Start minute has to be >= 0 && < 60. Actually is ``from``."
		assert( from > -1 && from < 60 );
		"Step minute has to be > 0 && < 60. Actually is ``step``."
		assert( step > 0 && step < 60 );
		if ( exists to ) {
			"End minute has to be >= 0 && < 60 && >= start minute."
			assert( to > -1 && to < 60 && to >= from );
			if ( step == 1 ) {
				appendString( this.minutes, from.string + cron.range.string + to.string );
			}
			else {
				appendString( this.minutes, from.string + cron.range.string + to.string + cron.increments.string + step.string );
			}
		}
		else {
			appendString( this.minutes, from.string + cron.increments.string + step.string );
		}
		return this;
	}

	
	"Adds all possible hours."
	shared CronBuilder withAllHours() {
		appendString( hours, cron.allValues.string );
		return this;
	}
	
	"Adds a list of hours to the cron expression."
	throws( `class AssertionError`, "Any hour in hours list is < 0 || >= 24." )
	shared CronBuilder withHours( "List of the hours to be added." Integer+ hours ) {
		for ( hour in hours ) {
			"Hour has to be >= 0 && < 24. Actually is ``hour``."
			assert( hour > -1 && hour < 24 );
			appendString( this.hours, hour.string );
		}
		return this;
	}
	
	"Adds range of hours to the cron expression."
	throws( `class AssertionError`, "From, to or step is < 0 || >= 24." )
	shared CronBuilder withHoursRange (
		"Start hour." Integer from,
		"Optional end hour." Integer? to = null,
		"Step, default is 1 hour." Integer step = 1
	) {
		"Start hour has to be >= 0 && < 24. Actually is ``from``."
		assert( from > -1 && from < 24 );
		"Step hour has to be > 0 && < 24. Actually is ``step``."
		assert( step > 0 && step < 24 );
		if ( exists to ) {
			"End hour has to be >= 0 && < 24 && >= start hour."
			assert( to > -1 && to < 24 && to >= from );
			if ( step == 1 ) {
				appendString( this.hours, from.string + cron.range.string + to.string );
			}
			else {
				appendString( this.hours, from.string + cron.range.string + to.string + cron.increments.string + step.string );
			}
		}
		else {
			appendString( this.hours, from.string + cron.increments.string + step.string );
		}
		return this;
	}
	
	
	"Adds all possible days of month."
	shared CronBuilder withAllDays() {
		appendString( daysOfMonth, cron.allValues.string );
		return this;
	}
	
	"Adds a list of days of month to the cron expression."
	throws( `class AssertionError`, "Any days of month in daysOfMonth list is < 0 || >= 31." )
	shared CronBuilder withDays( "List of the days of month to be added." Integer+ daysOfMonth ) {
		for ( dayOfMonth in daysOfMonth ) {
			"Day of month has to be >=0 && < 31. Actually is ``dayOfMonth``."
			assert( dayOfMonth > -1 && dayOfMonth < 31 );
			appendString( this.daysOfMonth, dayOfMonth.string );
		}
		return this;
	}
	
	"Adds range of days of month to the cron expression."
	throws( `class AssertionError`, "From, to or step is < 0 || >= 31." )
	shared CronBuilder withDaysRange (
		"Start day of month." Integer from,
		"Optional end day of month." Integer? to = null,
		"Step, default is 1 day." Integer step = 1
	) {
		"Start day of month has to be >= 0 && < 31. Actually is ``from``."
		assert( from > -1 && from < 31 );
		"Step day of month has to be > 0 && < 31. Actually is ``step``."
		assert( step > 0 && step < 31 );
		if ( exists to ) {
			"End day of month has to be >= 0 && < 31 && >= start day of month."
			assert( to > -1 && to < 31 && to >= from );
			if ( step == 1 ) {
				appendString( this.daysOfMonth, from.string + cron.range.string + to.string );
			}
			else {
				appendString( this.daysOfMonth, from.string + cron.range.string + to.string + cron.increments.string + step.string );
			}
		}
		else {
			appendString( this.daysOfMonth, from.string + cron.increments.string + step.string );
		}
		return this;
	}
	
	
	"Adds all possible days of week."
	shared CronBuilder withAllDaysOfWeek() {
		appendString( daysOfWeek, cron.allValues.string );
		return this;
	}
	
	"Adds a list of days of week to the cron expression."
	throws( `class AssertionError`, "each given item has to be a valid day of week" )
	shared CronBuilder withDaysOfWeek (
		"List of the days of week to be added.  
		 > Sunday is the first day of week."
		<Integer|DayOfWeek|String>+ daysOfWeek
	) {
		for ( item in daysOfWeek ) {
			appendString( this.daysOfWeek, calendar.digitalDayOfWeek( item ).string );
		}
		return this;
	}
	
	"Adds range of days of week to the cron expression."
	throws( `class AssertionError`, "From, to or step is < 1 || > 7." )
	shared CronBuilder withDaysOfWeekRange (
		"Start day of week.  
		 > Sunday is the first day of week."
		Integer|DayOfWeek|String from,
		"Optional end day of week.  
		 > Sunday is the first day of week."
		Integer|DayOfWeek|String? to = null,
		"Step, default is 1 day." Integer step = 1
	) {
		Integer from_ = calendar.digitalDayOfWeek( from );
		"Step day of week has to be > 0 && < 8."
		assert( step > 0 && step < 8 );
		if ( exists to ) {
			Integer to_ = calendar.digitalDayOfWeek( to );
			if ( step == 1 ) {
				appendString( this.daysOfWeek, from_.string + cron.range.string + to_.string );
			}
			else {
				appendString( this.daysOfWeek, from_.string + cron.range.string + to_.string + cron.increments.string + step.string );
			}
		}
		else {
			appendString( this.daysOfWeek, from_.string + cron.increments.string + step.string );
		}
		return this;
	}
	
	"Adds _the last xxx day of the month_ to the cron expression.  
	 Where xxx is avalid day of week.  
	 For example, if 6 is passed then _the last Friday of the month_ is to be added."
	throws( `class AssertionError`, "each given item has to be a valid day of week" )
	shared CronBuilder withLastDayOfWeek (
		"List of the days of week to be added with last mark.  
		 > Sunday is the first day of week."
		<Integer|DayOfWeek|String>+ daysOfWeek
	) {
		for ( item in daysOfWeek ) {
			appendString( this.daysOfWeek, calendar.digitalDayOfWeek( item ).string + cron.last.string );
		}
		return this;
	}
	
	"Adds _the y'th x day of the month_.  
	 For example, if `dayOfWeek` is Friday and `order` is 3 then _the third Friday of the month_
	 is to be added to the cron expression."
	throws( `class AssertionError`, "dayOfWeek has to be a valid day of week" )
	shared CronBuilder withGivenDayOfWeek (
		"Day of week to be added.  
		 > Sunday is the first day of week."
		Integer|DayOfWeek|String dayOfWeek,
		"The order of the added day." Integer order
	) {
		"Valid order is > 0 and < 6 while given is ``order``."
		assert( order > 0 && order < 6 );
		appendString( this.daysOfWeek, calendar.digitalDayOfWeek( dayOfWeek ).string + cron.nth.string + order.string );
		return this;
	}
		
	"Adds all possible months."
	shared CronBuilder withAllMonths() {
		appendString( months, cron.allValues.string );
		return this;
	}
	
	"Adds a list of months to the cron expression."
	throws( `class AssertionError`, "each given item has to be a valid month" )
	shared CronBuilder withMonths( "List of the days of week to be added." <Integer|Month|String>+ months ) {
		for ( item in months ) {
			appendString( this.months, calendar.digitalMonth( item ).string );
		}
		return this;
	}
	
	"Adds range of months to the cron expression."
	throws( `class AssertionError`, "From, to or step is < 1 || > 12." )
	shared CronBuilder withMonthsRange (
		"Start month." Integer|Month|String from,
		"Optional end month." Integer|Month|String? to = null,
		"Step, default is 1 month." Integer step = 1
	) {
		Integer from_ = calendar.digitalMonth( from );
		"Step month has to be > 0 && < 8."
		assert( step > 0 && step < 8 );
		if ( exists to ) {
			Integer to_ = calendar.digitalMonth( to );
			if ( step == 1 ) {
				appendString( this.months, from_.string + cron.range.string + to_.string );
			}
			else {
				appendString( this.months, from_.string + cron.range.string + to_.string + cron.increments.string + step.string );
			}
		}
		else {
			appendString( this.months, from_.string + cron.increments.string + step.string );
		}
		return this;
	}
	
	
	"Adds all possible years."
	shared CronBuilder withAllYears() {
		appendString( years, cron.allValues.string );
		return this;
	}
	
	"Adds a list of years to the cron expression."
	shared CronBuilder withYears( "List of the years to be added." Integer+ years ) {
		for ( year in years ) {
			appendString( this.years, year.string );
		}
		return this;
	}
	
	"Adds range of years to the cron expression."
	throws( `class AssertionError`, "end year has to be >= start year." )
	throws( `class AssertionError`, "step has to be > 0." )
	shared CronBuilder withYearsRange (
		"Start year." Integer from,
		"Optional end year." Integer? to = null,
		"Step, default is 1 year." Integer step = 1
	) {
		"Step year has to be > 0. Actually is ``step``."
		assert( step > 0 );
		if ( exists to ) {
			"End year has to be >= start year."
			assert( to >= from );
			if ( step == 1 ) {
				appendString( this.years, from.string + cron.range.string + to.string );
			}
			else {
				appendString( this.years, from.string + cron.range.string + to.string + cron.increments.string + step.string );
			}
		}
		else {
			appendString( this.years, from.string + cron.increments.string + step.string );
		}
		return this;
	}
	
}
