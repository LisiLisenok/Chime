import ceylon.json {

	JSON=Object
}
import herd.schedule.chime.cron {

	parseCron
}
import herd.schedule.chime {

	errorMessages,
	Chime
}


"Standard time factory. Creates:
 * cron-like timer [[herd.schedule.chime.timer::TimerCronStyle]]
 * incremental timer [[herd.schedule.chime.timer::TimerInterval]]
 "
since( "0.1.0" ) by( "Lis" )
shared class StandardTimerFactory( "max year limitation" Integer maxYearPeriod = 10 ) extends FactoryJSONBase()
	satisfies TimerFactory
 {
	
	
	"Initializes factory - to be called before using (creators adding is performed here)."
	shared TimerFactory initialize() {
		addCreator( Chime.type.cron, createCronTimer );
		addCreator( Chime.type.interval, createIntervalTimer );
		return this;
	}
	
	
	// timer creators
	
	"Creates cron style timer."
	Timer|String createCronTimer( "Timer description." JSON description ) {	 		
		if ( is String seconds = description.get( Chime.date.seconds ),
			is String minutes = description.get( Chime.date.minutes ),
			is String hours = description.get( Chime.date.hours ),
			is String daysOfMonth = description.get( Chime.date.daysOfMonth ),
			is String months = description.get( Chime.date.months )
		) {
			// days of week - nonmandatory
			String? daysOfWeek;
			if ( is String str = description.get( Chime.date.daysOfWeek ) ) {
				daysOfWeek = str;
			}
			else {
				daysOfWeek = null;
			}
			
			// years - nonmandatory
			String? years;
			if ( is String str = description.get( Chime.date.years ) ) {
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
		if ( is Integer delay = description.get( Chime.key.delay ) ) {
			if ( delay > 0 ) {
				return TimerInterval( delay * 1000 );
			}
			else {
				return errorMessages.delayHasToBeGreaterThanZero;
			}
		}
		return errorMessages.delayHasToBeSpecified;
	}
	
}
