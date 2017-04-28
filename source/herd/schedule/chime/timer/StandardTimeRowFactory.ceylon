import ceylon.json {

	JSON=Object
}
import herd.schedule.chime.cron {

	parseCron
}
import herd.schedule.chime {

	Chime
}
import io.vertx.ceylon.core.eventbus {
	deliveryOptions
}


"Standard time factory. Creates:
 * cron-like timer [[herd.schedule.chime.timer::TimeRowCronStyle]]
 * incremental timer [[herd.schedule.chime.timer::TimeRowInterval]]
 "
since( "0.1.0" ) by( "Lis" )
shared class StandardTimeRowFactory( "max year limitation" Integer maxYearPeriod = 10 ) extends FactoryJSONBase()
 {
	
	"Initializes factory - to be called before using (creators adding is performed here)."
	shared TimeRowFactory initialize() {
		addCreator( Chime.type.cron, createCronTimer );
		addCreator( Chime.type.interval, createIntervalTimer );
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
				return TimeRowCronStyle (
					cronExpr, description.get( Chime.key.message ),
					if ( exists options = description.getObjectOrNull( Chime.key.deliveryOptions ) )
					then deliveryOptions.fromJson( options ) else null
				);
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
				return TimeRowInterval (
					delay * 1000, description.get( Chime.key.message ),
					if ( exists options = description.getObjectOrNull( Chime.key.deliveryOptions ) )
					then deliveryOptions.fromJson( options ) else null
				);
			}
			else {
				return Chime.errors.codeDelayHasToBeGreaterThanZero->Chime.errors.delayHasToBeGreaterThanZero;
			}
		}
		return Chime.errors.codeDelayHasToBeSpecified->Chime.errors.delayHasToBeSpecified;
	}
	
}
