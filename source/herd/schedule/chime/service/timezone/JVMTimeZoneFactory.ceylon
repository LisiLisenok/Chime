import herd.schedule.chime {
	Chime
}
import java.util {
	JavaTimeZone=TimeZone
}
import ceylon.json {
	JsonObject
}
import io.vertx.ceylon.core {
	Vertx
}
import herd.schedule.chime.service {
	Extension,
	ChimeServices
}


"Creates [[TimeZone]] using JVM time zones."
service(`interface TimeZoneFactory`)
since("0.3.0") by( "Lis")
shared class JVMTimeZoneFactory() satisfies TimeZoneFactory
{
	
	shared actual void initialize(Vertx vertx, JsonObject config, Anything(Extension|Throwable) handle) {
		handle( this );
	}
		
	shared actual TimeZone|<Integer->String> create(ChimeServices services, String timeZone) {
		JavaTimeZone tz = JavaTimeZone.getTimeZone(timeZone);
		if (tz.id == timeZone) {
			return JVMTimeZone(tz);
		}
		else {
			return Chime.errors.codeUnsupportedTimezone->Chime.errors.unsupportedTimezone;
		}
	}
	
	shared actual String type => Chime.timeZoneProvider.jvm;
	
	shared actual String string => "JVM time zone factory";
	
}
