import ceylon.json {

	JSON=Object,
	JSONArray=Array
}
import herd.schedule.chime.cron {

	parseCron
}
import herd.schedule.chime {

	Chime
}
import ceylon.collection {
	ArrayList
}


"Standard time factory. Creates:
 * cron-like timer [[herd.schedule.chime.timer::TimeRowCronStyle]]
 * incremental timer [[herd.schedule.chime.timer::TimeRowInterval]]
 * union timer [[herd.schedule.chime.timer::TimeRowUnion]]
 "
since( "0.1.0" ) by( "Lis" )
shared class StandardTimeRowFactory( "max year limitation" Integer maxYearPeriod = 10 ) extends FactoryJSONBase()
 {
	
	"Initializes factory - to be called before using (creators adding is performed here)."
	shared TimeRowFactory initialize() {
		addCreator( Chime.type.cron, createCronTimer );
		addCreator( Chime.type.interval, createIntervalTimer );
		addCreator( Chime.type.union, createUnionTimer );
		return this;
	}
	
	
	// timer creators
	
	"Creates cron style timer."
	TimeRow|<Integer->String> createCronTimer( "Timer description." JSON description ) {	 		
		if ( is String seconds = description[Chime.date.seconds],
			is String minutes = description[Chime.date.minutes],
			is String hours = description[Chime.date.hours],
			is String daysOfMonth = description[Chime.date.daysOfMonth],
			is String months = description[Chime.date.months]
		) {
			// days of week - nonmandatory
			String? daysOfWeek;
			if ( is String str = description[Chime.date.daysOfWeek] ) {
				daysOfWeek = str;
			}
			else {
				daysOfWeek = null;
			}
			
			// years - nonmandatory
			String? years;
			if ( is String str = description[Chime.date.years] ) {
				years = str;
			}
			else {
				years = null;
			}

			if ( exists cronExpr = parseCron( seconds, minutes, hours, daysOfMonth, months, daysOfWeek, years, maxYearPeriod ) ) {
				return TimeRowCronStyle( cronExpr );
			}
			else {
				return Chime.errors.codeIncorrectCronTimerDescription->Chime.errors.incorrectCronTimerDescription;
			}
			
		}
		else {
			return Chime.errors.codeIncorrectCronTimerDescription->Chime.errors.incorrectCronTimerDescription;
		}
	}
	
	
	"Creates interval timer."
	TimeRow|<Integer->String> createIntervalTimer( "Timer description." JSON description ) {
		if ( is Integer delay = description[Chime.key.delay] ) {
			if ( delay > 0 ) {
				return TimeRowInterval( delay * 1000 );
			}
			else {
				return Chime.errors.codeDelayHasToBeGreaterThanZero->Chime.errors.delayHasToBeGreaterThanZero;
			}
		}
		return Chime.errors.codeDelayHasToBeSpecified->Chime.errors.delayHasToBeSpecified;
	}
	
	
	"Creates union timer."
	TimeRow|<Integer->String> createUnionTimer( "Timer description." JSON description ) {
		if ( is JSONArray timers = description[Chime.key.timers] ) {
			ArrayList<TimeRow> timeRows = ArrayList<TimeRow>();
			for ( timer in timers ) {
				if ( is JSON timer ) {
					 value ret = createTimer( timer );
					 if ( is TimeRow ret ) {
					 	timeRows.add( ret );
					 }
					 else {
					 	return ret;
					 }
				}
				else {
					return Chime.errors.codeNotJSONTimerDescription->Chime.errors.notJSONTimerDescription;
				}
			}
			if ( nonempty unionRows = timeRows.sequence() ) {
				return TimeRowUnion( unionRows );
			}
			else {
				return Chime.errors.codeTimersListHasToBeSpecified->Chime.errors.timersListHasToBeSpecified;
			}
		}
		else {
			return Chime.errors.codeTimersListHasToBeSpecified->Chime.errors.timersListHasToBeSpecified;
		}
	}
	
}
