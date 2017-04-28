import ceylon.time {
	DateTime
}
import io.vertx.ceylon.core.eventbus {
	EventBus,
	Message,
	DeliveryOptions
}
import ceylon.json {
	JSON=Object,
	ObjectValue
}


"Internal implementation of [[Scheduler]]."
see( `function connectToScheduler` )
since( "0.2.0" ) by( "Lis" )
class SchedulerImpl (
	shared actual String name,
	EventBus eventBus
)
		satisfies Scheduler
{
	
	variable Boolean alive = true;
	
	
	"Sends timer create request and responds to handler."
	void sendTimerCreateRequest( JSON timer, Anything(Timer|Throwable) handler ) {
		eventBus.send<JSON>(
			name, timer,
			( Throwable | Message<JSON?> msg ) {
				if ( is Throwable msg ) {
					handler( msg );
				}
				else {
					"Timer create request has to respond with body."
					assert( exists rep = msg.body() );
					handler( TimerImpl( rep.getString( Chime.key.name ), name, eventBus ) );
				}
			}
		);	
	}
	
	
	shared actual void createTimer (
		Anything(Timer|Throwable) handler, JSON description, String? timerName,
		Boolean paused, Boolean publish, Integer? maxCount, DateTime? startDate,
		DateTime? endDate, String? timeZone, ObjectValue? message, DeliveryOptions? options
	) {
		JSON timer = JSON {
			Chime.key.operation -> Chime.operation.create,
			Chime.key.publish -> publish
		};
		if ( exists timerName ) {
			timer.put( Chime.key.name, timerName );
		}
		if ( paused ) {
			timer.put( Chime.key.state, Chime.state.paused );
		}
		if ( exists maxCount ) {
			timer.put( Chime.key.maxCount, maxCount );
		}
		if ( exists startDate ) {
			timer.put (
				Chime.key.startTime,
				JSON {
					Chime.date.seconds -> startDate.seconds,
					Chime.date.minutes -> startDate.minutes,
					Chime.date.hours -> startDate.hours,
					Chime.date.dayOfMonth -> startDate.day,
					Chime.date.month -> startDate.month.integer,
					Chime.date.year -> startDate.year
				}
			);
		}
		if ( exists endDate ) {
			timer.put (
				Chime.key.endTime,
				JSON {
					Chime.date.seconds -> endDate.seconds,
					Chime.date.minutes -> endDate.minutes,
					Chime.date.hours -> endDate.hours,
					Chime.date.dayOfMonth -> endDate.day,
					Chime.date.month -> endDate.month.integer,
					Chime.date.year -> endDate.year
				}
			);
		}
		if ( exists timeZone ) {
			timer.put( Chime.key.timeZone, timeZone );
		}
		if ( exists message ) {
			timer.put( Chime.key.message, message );
		}
		if ( exists options ) {
			timer.put( Chime.key.deliveryOptions, options.toJson() );
		}
		timer.put( Chime.key.description, description );
		sendTimerCreateRequest( timer, handler );
	}
	

	shared actual void delete() {
		if ( alive ) {
			alive = false;
			eventBus.send (
				name,
				JSON {
					Chime.key.operation -> Chime.operation.delete,
					Chime.key.name -> name
				}
			);
		}
	}
	
	shared actual void pause() {
		if ( alive ) {
			eventBus.send (
				name,
				JSON {
					Chime.key.operation -> Chime.operation.state,
					Chime.key.name -> name,
					Chime.key.state -> Chime.state.paused
				}
			);
		}
	}
	
	shared actual void resume() {
		if ( alive ) {
			eventBus.send (
				name,
				JSON {
					Chime.key.operation -> Chime.operation.state,
					Chime.key.name -> name,
					Chime.key.state -> Chime.state.running
				}
			);
		}
	}
	
	shared actual void info( Anything(Throwable|SchedulerInfo) info ) {
		eventBus.send (
			name,
			JSON {
				Chime.key.operation -> Chime.operation.info
			},
			( Throwable|Message<JSON?> msg ) {
				if ( is Message<JSON?> msg ) {
					"Reply from scheduler request has not to be null."
					assert( exists ret = msg.body() );
					info( SchedulerInfo.fromJSON( ret ) );
				}
				else {
					info( msg );
				}
			}
		);
	}		
	
}
