import ceylon.time {
	Instant,
	DateTime
}
import java.util {
	JavaTimeZone=TimeZone
}


"Converts date/time using time zones available at JVM according to specified remote time zone."
since("0.1.0") by("Lis")
class JVMTimeZone satisfies TimeZone {
	
	static JavaTimeZone localtz = JavaTimeZone.default;
	
	JavaTimeZone remoteTimeZone;
	
	shared new ("Time zone to link this one to." JavaTimeZone remoteTimeZone) {
		this.remoteTimeZone = remoteTimeZone;
	}
	
	shared actual DateTime toLocal(DateTime remote) {
		Integer remoteTime = remote.instant().millisecondsOfEpoch;
		Integer utcTime = remoteTime - remoteTimeZone.getOffset(remoteTime);
		Integer localUTCOffset = localtz.getOffset(utcTime + localtz.getOffset(utcTime));
		return Instant(utcTime + localUTCOffset).dateTime();
	}
	
	shared actual DateTime toRemote(DateTime local) {
		Integer localTime = local.instant().millisecondsOfEpoch;
		Integer utcTime = localTime - localtz.getOffset(localTime);
		Integer remoteUTCOffset = remoteTimeZone.getOffset(utcTime + remoteTimeZone.getOffset(utcTime));
		return Instant(utcTime + remoteUTCOffset).dateTime();
	}
	
	shared actual String timeZoneID => remoteTimeZone.id;
	
	shared actual String string => timeZoneID;
}
