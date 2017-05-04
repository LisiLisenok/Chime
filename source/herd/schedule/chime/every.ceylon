import ceylon.json {
	
	JSON = Object,
	ObjectValue
}
import io.vertx.ceylon.core.eventbus {
	DeliveryOptions
}


"Builds JSON description of an interval timer."
tagged( "Builder" )
see( `class CronBuilder`, `class UnionBuilder` )
since( "0.2.1" ) by( "Lis" )
shared JSON every (
	"Timer interval measured in `timeUnit`." Integer interval,
	"Unit to measure `interval`." TimeUnit timeUnit = TimeUnit.seconds,
	"Optional message to be added to timer fire event." ObjectValue? message = null,
	"Optional delivery options the timer fire event is sent with." DeliveryOptions? options = null
) {
	"Timer interval has to be positive, while given is ``interval``."
	assert( interval > 0 );
	
	JSON ret= JSON {
		Chime.key.type -> Chime.type.interval,
		Chime.key.delay -> interval * timeUnit.secondsIn
	};
	if ( exists message ) {
		ret.put( Chime.key.message, message );
	}
	if ( exists options ) {
		ret.put( Chime.key.deliveryOptions, options.toJson() );
	}
	return ret;
}
