import ceylon.time {
	dateTime,
	DateTime
}
import herd.schedule.chime.service.timer {
	TimeRowFactory,
	TimeRow
}
import herd.schedule.chime.service {
	ChimeServices,
	Extension
}
import ceylon.json {
	JsonObject
}
import herd.schedule.chime {
	Chime
}


// Custom timer factory
service(`interface Extension`)
shared class CustomIntervalTimerFactory satisfies TimeRowFactory
{
	shared static String timerType = "custom interval";
	
	shared new () {}
	
	// Custom timer
	class TimeRowInterval (
		"Timing delay in miliseconds, to be >= 0." shared Integer intervalMilliseconds
	) satisfies TimeRow {
		"Current date and time."
		variable DateTime currentDate = dateTime(0, 1, 1);
		shared actual DateTime? start(DateTime current) => currentDate = current.plusMilliseconds(intervalMilliseconds);
		shared actual DateTime? shiftTime() => currentDate = currentDate.plusMilliseconds(intervalMilliseconds);
	}
	
	shared actual TimeRow|<Integer->String> create(ChimeServices services, JsonObject description) {
		if (is Integer delay = description[Chime.key.delay]) {
			if (delay > 0) {
				return TimeRowInterval(delay * 1000);
			}
			else {
				return Chime.errors.codeDelayHasToBeGreaterThanZero->Chime.errors.delayHasToBeGreaterThanZero;
			}
		}
		return Chime.errors.codeDelayHasToBeSpecified->Chime.errors.delayHasToBeSpecified;
	}
	
	shared actual String type => timerType;
		
}
