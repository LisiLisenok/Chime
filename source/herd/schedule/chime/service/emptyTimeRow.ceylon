import ceylon.time {
	DateTime
}


"`TimeRow` which return `null`."
since( "0.3.0" ) by( "Lis" )
object emptyTimeRow satisfies TimeRow {
	shared actual DateTime? shiftTime() => null;
	shared actual DateTime? start(DateTime current) => null;
}
