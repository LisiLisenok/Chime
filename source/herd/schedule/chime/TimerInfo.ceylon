import ceylon.json {
	
	JSON=Object
}
import ceylon.time {

	DateTime
}


"Info on the timer."
see( `interface Timer`, `class SchedulerInfo`, `function Scheduler.info` )
tagged( "Info" )
since( "0.2.0" ) by( "Lis" )
shared final class TimerInfo {

	"Timer name" shared String name;
	"Timer state at the request moment." shared State state;
	"Number of fires at the request moment." shared Integer count;
	"Maximum allowed number of fires or `null` if unlimited." shared Integer? maxCount;
	"`True` if messages have to be published and `false` if messages have to be send." shared Boolean publish;
	"Time the timer has to be started, or `null` if immediately." shared DateTime? startTime;
	"Optional time the timer has to be completed." shared DateTime? endTime;
	"Time zone the timer works in." shared String timeZone;
	"Timer description." shared JSON description;
	
	
	"Instantiates `TimerInfo` with the given parameters."
	shared new (
		"Timer name" String name,
		"Timer state at the request moment." State state,
		"Number of fires at the request moment." Integer count,
		"Maximum allowed number of fires or `null` if unlimited." Integer? maxCount,
		"`True` if messages have to be published and `false` if messages have to be send." Boolean publish,
		"Time the timer has to be started, or `null` if immediately." DateTime? startTime,
		"Optional time the timer has to be completed." DateTime? endTime,
		"Time zone the timer works in." String timeZone,
		"Timer description." JSON description
	) {
		this.name = name;
		this.state = state;
		this.count = count;
		this.maxCount = maxCount;
		this.publish = publish;
		this.startTime = startTime;
		this.endTime = endTime;
		this.timeZone = timeZone;
		this.description = description;
	}
	
	"Instantiates `TimerInfo` from JSON description as send by _Chime_."
	shared new fromJSON( "Timer info received from _Chime_." JSON timerInfo ) {
		this.name = timerInfo.getString( Chime.key.name );
		"Timer info replied from scheduler has to contain state field."
		assert( exists state = stateByName( timerInfo.getString( Chime.key.state ) ) );
		this.state = state;
		this.count = timerInfo.getInteger( Chime.key.count );
		this.maxCount = timerInfo.getIntegerOrNull( Chime.key.maxCount );
		this.publish = timerInfo.getBoolean( Chime.key.publish );
		this.startTime =
			if ( exists startTimeDescr = timerInfo.getObjectOrNull( Chime.key.startTime ) )
			then dateTimeFromJSON( startTimeDescr )
			else null;
		this.endTime =
			if ( exists endTimeDescr = timerInfo.getObjectOrNull( Chime.key.endTime ) )
			then dateTimeFromJSON( endTimeDescr )
			else null;
		this.timeZone = timerInfo.getString( Chime.key.timeZone );
		this.description = timerInfo.getObject( Chime.key.description );
	}
	
	
	shared actual String string => "Timer ``name``, ``state``, count = ``count``";
	
}
