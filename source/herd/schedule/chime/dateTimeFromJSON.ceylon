import ceylon.json {
	JSON=Object
}
import ceylon.time {
	dateTime,
	DateTime
}


"Reads date-time from JSON into `DateTime`."
since( "0.2.0" ) by( "Lis" )
DateTime dateTimeFromJSON( JSON dateTimeDescr )
	=> dateTime (
		dateTimeDescr.getInteger( Chime.date.year ), dateTimeDescr.getInteger( Chime.date.month ),
		dateTimeDescr.getInteger( Chime.date.dayOfMonth ), dateTimeDescr.getInteger( Chime.date.hours ),
		dateTimeDescr.getInteger( Chime.date.minutes ), dateTimeDescr.getInteger( Chime.date.seconds )
	);
