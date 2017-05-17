import ceylon.json {
	JsonObject
}
import herd.schedule.chime {
	Chime
}
import io.vertx.ceylon.core {
	Vertx
}


"Factory to create interval timers."
service( `interface TimeRowFactory` )
since( "0.3.0" ) by( "Lis" )
shared class IntervalFactory() satisfies TimeRowFactory
{
	
	shared actual String type => Chime.type.interval;
	
	shared actual void initialize( Vertx vertx, JsonObject config, Anything(Extension|Throwable) handle ) {
		handle( this );
	}
	
	shared actual TimeRow|<Integer->String> create( ChimeServices services, JsonObject description ) {
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
	
	shared actual String string => "interval time row factory";
	
}

