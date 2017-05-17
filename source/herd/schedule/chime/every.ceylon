import ceylon.json {
	
	JsonObject
}


"Builds `JsonObject` description of an interval timer."
tagged( "Builder" )
see( `class CronBuilder`, `class UnionBuilder` )
since( "0.2.1" ) by( "Lis" )
shared JsonObject every (
	"Timer interval measured in `timeUnit`." Integer interval,
	"Unit to measure `interval`." TimeUnit timeUnit = TimeUnit.seconds
) {
	"Timer interval has to be positive, while given is ``interval``."
	assert( interval > 0 );
	
	JsonObject ret= JsonObject {
		Chime.key.type -> Chime.type.interval,
		Chime.key.delay -> interval * timeUnit.secondsIn
	};
	return ret;
}
