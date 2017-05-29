import herd.schedule.chime {
	Chime
}
import java.util {
	JavaTimeZone=TimeZone
}
import herd.schedule.chime.service {
	ChimeServices,
	Extension
}
import ceylon.time {
	DateTime
}
import ceylon.json {
	JsonObject
}


"Creates [[TimeZone]] using JVM time zones."
service(`interface Extension`)
since("0.3.0") by( "Lis")
shared class JVMTimeZoneFactory satisfies TimeZoneFactory
{
	
	"Defines time zone which does no convertion."
	shared static object localTimeZone satisfies TimeZone {
		shared actual DateTime toLocal(DateTime remote) => remote;
		shared actual DateTime toRemote(DateTime local) => local;
		shared actual String timeZoneID => JavaTimeZone.default.id;
	}
	
	"New `JVMTimeZoneFactory`."
	shared new () {}
	
	shared actual TimeZone|<Integer->String> create(ChimeServices services, JsonObject options) {
		if (is String timeZone = options[Chime.key.timeZone]) {
			JavaTimeZone tz = JavaTimeZone.getTimeZone(timeZone);
			if (tz.id == timeZone) {
				return JVMTimeZone(tz);
			}
			else {
				return Chime.errors.codeUnsupportedTimezone->Chime.errors.unsupportedTimezone;
			}
		}
		else {
			return localTimeZone;
		}
		
	}
	
	shared actual String type => Chime.timeZoneProvider.jvm;
	
	shared actual String string => "JVM time zone factory";
	
}
