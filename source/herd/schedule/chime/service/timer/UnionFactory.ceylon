import ceylon.collection {
	ArrayList
}
import ceylon.json {
	JsonObject,
	JsonArray
}
import herd.schedule.chime {
	Chime
}
import herd.schedule.chime.service {
	ChimeServices,
	Extension
}


"Factory to create union timers."
service(`interface Extension`)
since("0.3.0") by("Lis")
shared class UnionFactory() satisfies TimeRowFactory
{
	
	shared actual String type => Chime.type.union;

	shared actual TimeRow|<Integer->String> create(ChimeServices services, JsonObject description) {
		if (is JsonArray timers = description[Chime.key.timers]) {
			ArrayList<TimeRow> timeRows = ArrayList<TimeRow>();
			for (timer in timers) {
				if (is JsonObject timer) {
					value ret = services.createTimeRow(timer);
					if (is TimeRow ret) {
						timeRows.add(ret);
					}
					else {
						return ret;
					}
				}
				else {
					return Chime.errors.codeNotJSONTimerDescription->Chime.errors.notJSONTimerDescription;
				}
			}
			if (nonempty unionRows = timeRows.sequence()) {
				return TimeRowUnion(unionRows);
			}
			else {
				return Chime.errors.codeTimersListHasToBeSpecified->Chime.errors.timersListHasToBeSpecified;
			}
		}
		else {
			return Chime.errors.codeTimersListHasToBeSpecified->Chime.errors.timersListHasToBeSpecified;
		}
	}
	
	shared actual String string => "union time row factory";
	
}
