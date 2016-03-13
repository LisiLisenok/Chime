import ceylon.json {

	JSON=Object
}
import herd.schedule.chime.cron {

	calendar,
	parseCron
}
import herd.schedule.chime {

	errorMessages
}


"Standard time factory. Creates:
 * cron-like timer [[herd.schedule.chime.timer::TimerCronStyle]]
 * incremental timer [[herd.schedule.chime.timer::TimerInterval]]
 "
shared class StandardTimerFactory( "max year limitation" Integer maxYearPeriod = 10 ) extends FactoryJSONBase()
	satisfies TimerFactory
 {
	
	
	"Initializes factory - to be called before using (creators adding is performed here)."
	shared TimerFactory initialize() {
		addCreator( timerDefinitions.typeCronStyle, createCronTimer );
		addCreator( timerDefinitions.typeInterval, createIntervalTimer );
		return this;
	}
	
	
	// timer creators
	
	"Creates cron style timer."
	Timer|String createCronTimer( "Timer description." JSON description ) {	 		
		if ( is String seconds = description.get( calendar.seconds ),
			is String minutes = description.get( calendar.minutes ),
			is String hours = description.get( calendar.hours ),
			is String daysOfMonth = description.get( calendar.daysOfMonth ),
			is String months = description.get( calendar.months )
		) {
			// days of week - nonmandatory
			String? daysOfWeek;
			if ( is String str = description.get( calendar.daysOfWeek ) ) {
				daysOfWeek = str;
			}
			else {
				daysOfWeek = null;
			}
			
			// years - nonmandatory
			String? years;
			if ( is String str = description.get( calendar.years ) ) {
				years = str;
			}
			else {
				years = null;
			}

			if ( exists cronExpr = parseCron( seconds, minutes, hours, daysOfMonth, months, daysOfWeek, years, maxYearPeriod ) ) {
				return TimerCronStyle( cronExpr );
			}
			else {
				return errorMessages.incorrectCronTimerDescription;
			}
			
		}
		else {
			return errorMessages.incorrectCronTimerDescription;
		}
	}
	
	
	"Creates interval timer."
	Timer|String createIntervalTimer( "Timer description." JSON description ) {
		if ( is Integer interval = description.get( timerDefinitions.intervalSeconds ) ) {
			
			if ( interval > 0 ) {
				return TimerInterval( interval * 1000 );
			}
			else {
				return errorMessages.intervalHasToBeGreaterThanZero;
			}
		}
		return errorMessages.intervalHasToBeSpecified;
	}
	
}
