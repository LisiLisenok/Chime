import ceylon.json {
	JSON=Object
}


"Info on the scheduler."
see( `interface Scheduler`, `class TimerInfo`, `function schedulerInfo` )
since( "0.2.0" ) by( "Lis" )
shared final class SchedulerInfo {
	
	"Scheduler name." shared String name;
	"Scheduler state at the request moment." shared State state;
	"List of the timers. Actual at the request moment." shared TimerInfo[] timers;
	
	"Instantiates `SchedulerInfo` with the given parameters."
	shared new (
		"Scheduler name." String name,
		"Scheduler state at the request moment." State state,
		"List of the timers. Actual at the request moment." TimerInfo[] timers
	) {
		this.name = name;
		this.state = state;
		this.timers = timers;
	}
	
	"Instantiates `SchedulerInfo` from JSON description as send by _Chime_."
	shared new fromJSON( "Scheduler info received from _Chime_." JSON schedulerInfo ) {
		this.name = schedulerInfo.getString( Chime.key.name );
		"Scheduler info replied from _Chime_ has to contain state field."
		assert( exists state = stateByName( schedulerInfo.getString( Chime.key.state ) ) );
		this.state = state;
		if ( exists arr = schedulerInfo.getArrayOrNull( Chime.key.timers ) ) {
			timers = arr.narrow<JSON>().map( TimerInfo.fromJSON ).sequence();
		}
		else {
			timers = [];
		}
	}
	
	shared actual String string => "Scheduler ``name``, ``state``";
	
}
