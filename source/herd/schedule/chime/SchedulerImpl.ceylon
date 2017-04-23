import ceylon.time {
	DateTime
}
import io.vertx.ceylon.core.eventbus {
	EventBus,
	Message
}
import ceylon.json {
	JSON=Object
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
	
	
	"Fills timer general description by data."
	JSON timerGeneral (
		String? name, Boolean paused, Boolean publish, Integer? maxCount,
		DateTime? startDate, DateTime? endDate, String? timeZone
	) {
		JSON timer = JSON {
			Chime.key.operation -> Chime.operation.create,
			Chime.key.publish -> publish
		};
		if ( exists n = name ) {
			timer.put( Chime.key.name, n );
		}
		if ( paused ) {
			timer.put( Chime.key.state, Chime.state.paused );
		}
		if ( exists n = maxCount ) {
			timer.put( Chime.key.maxCount, n );
		}
		if ( exists n = startDate ) {
			timer.put (
				Chime.key.startTime,
				JSON {
					Chime.date.seconds -> n.seconds,
					Chime.date.minutes -> n.minutes,
					Chime.date.hours -> n.hours,
					Chime.date.dayOfMonth -> n.day,
					Chime.date.month -> n.month.integer,
					Chime.date.year -> n.year
				}
			);
		}
		if ( exists n = endDate ) {
			timer.put (
				Chime.key.endTime,
				JSON {
					Chime.date.seconds -> n.seconds,
					Chime.date.minutes -> n.minutes,
					Chime.date.hours -> n.hours,
					Chime.date.dayOfMonth -> n.day,
					Chime.date.month -> n.month.integer,
					Chime.date.year -> n.year
				}
			);
		}
		if ( exists n = timeZone ) {
			timer.put( Chime.key.timeZone, n );
		}
		return timer;
	}
	
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
	
	
	shared actual void createIntervalTimer (
		Anything(Timer|Throwable) handler, Integer delay, String? timerName,
		Boolean paused, Boolean publish, Integer? maxCount, DateTime? startDate, DateTime? endDate, String? timeZone
	) {
		JSON timer = timerGeneral( timerName, paused, publish, maxCount, startDate, endDate, timeZone );
		timer.put (
			Chime.key.description,
			JSON {
				Chime.key.type -> Chime.type.interval,
				Chime.key.delay -> delay
			}
		);
		sendTimerCreateRequest( timer, handler );
	}
	
	shared actual void createCronTimer (
		Anything(Timer|Throwable) handler, String seconds, String minutes, String hours, String daysOfMonth,
		String months, String? daysOfWeek, String? years,
		String? timerName, Boolean paused, Boolean publish, Integer? maxCount,
		DateTime? startDate, DateTime? endDate, String? timeZone
	) {
		JSON timer = timerGeneral( timerName, paused, publish, maxCount, startDate, endDate, timeZone );
		JSON descr = JSON {
			Chime.key.type -> Chime.type.cron,
			Chime.date.seconds -> seconds,
			Chime.date.minutes -> minutes,
			Chime.date.hours -> hours,
			Chime.date.daysOfMonth -> daysOfMonth,
			Chime.date.months -> months,
			Chime.date.daysOfWeek -> "*",
			Chime.date.years -> "2015-2019"			
		};
		if ( exists d = daysOfWeek, !d.empty ) {
			descr.put( Chime.date.daysOfWeek, d );
		}
		if ( exists d = years, !d.empty ) {
			descr.put( Chime.date.years, d );
		}
		timer.put( Chime.key.description, descr );
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
