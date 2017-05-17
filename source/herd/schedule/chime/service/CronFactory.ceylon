import herd.schedule.chime.cron {
	parseCron
}
import ceylon.json {
	JsonObject
}
import herd.schedule.chime {
	Chime
}
import io.vertx.ceylon.core {
	Vertx
}


"Factory to create cron-style timers."
service( `interface TimeRowFactory` )
since( "0.3.0" ) by( "Lis" )
shared class CronFactory() satisfies TimeRowFactory
{
	
	Integer maxYearPeriod = 100;
	
	shared actual String type => Chime.type.cron;
	
	shared actual void initialize( Vertx vertx, JsonObject config, Anything(Extension|Throwable) handle ) {
		handle( this );
	}
	
	shared actual TimeRow|<Integer->String> create( ChimeServices services, JsonObject description ) {	 		
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
	
	shared actual String string => "cron time row factory";	
	
}