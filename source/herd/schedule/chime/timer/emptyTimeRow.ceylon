import ceylon.time {
	DateTime
}


"`TimeRow` which return `null`."
object emptyTimeRow satisfies TimeRow {
	shared actual DateTime? shiftTime() => null;
	shared actual DateTime? start(DateTime current) => null;
}
