import io.vertx.ceylon.core.eventbus {
	EventBus,
	MessageConsumer,
	Message,
	deliveryOptions
}
import ceylon.json {
	JSON=Object
}


"Internal implementation of [[Timer]]."
see( `interface Scheduler`, `class SchedulerImpl` )
since( "0.2.0" ) by( "Lis" )
class TimerImpl (
	shared actual String name,
	String schedulerAddress,
	EventBus eventBus
)
		satisfies Timer
{
	
	variable Anything(TimerEvent)? eventHandler = null;
	MessageConsumer<JSON?> consumer = eventBus.consumer<JSON>( name );
	variable Boolean alive = true;
	
	"Redirects message to `eventHandler`."
	void onMessage( Message<JSON?> message ) {
		if ( exists h = eventHandler ) {
			"Message from timer has to containe body."
			assert( exists body = message.body() );
			value eventType = body.getString( Chime.key.event );
			if ( eventType == Chime.event.fire ) {
				h (
					TimerFire (
						name, body.getInteger( Chime.key.count ), body.getString( Chime.key.time ),
						body.getString( Chime.key.timeZone ), dateTimeFromJSON( body ),
						body.get( Chime.key.message ),
						if ( exists options = body.getObjectOrNull( Chime.key.deliveryOptions ) )
						then deliveryOptions.fromJson( options ) else null
					)
				);
			}
			else if ( eventType == Chime.event.complete ) {
				unregister();
				alive = false;
				h( TimerCompleted( name, body.getInteger( Chime.key.count ) ) );
			}
			else {
				throw AssertionError( "timer event has to be one of 'fire' or 'complete'" );
			}
		}
	}

	
	shared actual void handler( Anything(TimerEvent) handler ) {
		if ( alive ) {
			eventHandler = handler;
			if ( !consumer.isRegistered() ) {
				consumer.handler( onMessage );
			}
		}
	}
	
	shared actual void unregister() {
		consumer.unregister();
		eventHandler = null;
	}
		
	shared actual void delete( Anything(Throwable|String)? reply ) {
		if ( alive ) {
			unregister();
			alive = false;
			if ( exists reply ) {
				eventBus.send (
					schedulerAddress,
					JSON {
						Chime.key.operation -> Chime.operation.delete,
						Chime.key.name -> name
					},
					( Throwable|Message<JSON?> msg ) {
						if ( is Message<JSON?> msg ) {
							"Reply from scheduler request has not to be null."
							assert( exists ret = msg.body() );
							reply( ret.getString( Chime.key.name ) );
						}
						else {
							reply( msg );
						}
					}
				);
			}
			else {
				eventBus.send (
					schedulerAddress,
					JSON {
						Chime.key.operation -> Chime.operation.delete,
						Chime.key.name -> name
					}
				);
			}
		}
	}
	
	shared actual void pause( Anything(Throwable|State)? reply ) {
		if ( alive ) {
			if ( exists reply ) {
				eventBus.send (
					schedulerAddress,
					JSON {
						Chime.key.operation -> Chime.operation.state,
						Chime.key.name -> name,
						Chime.key.state -> Chime.state.paused
					},
					( Throwable|Message<JSON?> msg ) {
						if ( is Message<JSON?> msg ) {
							"Reply from scheduler request has not to be null."
							assert( exists ret = msg.body() );
							"Timer info replied from scheduler has to contain state field."
							assert( exists state = stateByName( ret.getString( Chime.key.state ) ) );
							reply( state );
						}
						else {
							reply( msg );
						}
					}
				);
			}
			else {
				eventBus.send (
					schedulerAddress,
					JSON {
						Chime.key.operation -> Chime.operation.state,
						Chime.key.name -> name,
						Chime.key.state -> Chime.state.paused
					}
				);
			}
		}
	}
	
	shared actual void resume( Anything(Throwable|State)? reply ) {
		if ( alive ) {
			if ( exists reply ) {
				eventBus.send (
					schedulerAddress,
					JSON {
						Chime.key.operation -> Chime.operation.state,
						Chime.key.name -> name,
						Chime.key.state -> Chime.state.running
					},
					( Throwable|Message<JSON?> msg ) {
						if ( is Message<JSON?> msg ) {
							"Reply from scheduler request has not to be null."
							assert( exists ret = msg.body() );
							"Timer info replied from scheduler has to contain state field."
							assert( exists state = stateByName( ret.getString( Chime.key.state ) ) );
							reply( state );
						}
						else {
							reply( msg );
						}
					}
				);
			}
			else {
				eventBus.send (
					schedulerAddress,
					JSON {
						Chime.key.operation -> Chime.operation.state,
						Chime.key.name -> name,
						Chime.key.state -> Chime.state.running
					}
				);
			}
		}
	}
	
	shared actual void info( "Info handler." Anything(Throwable|TimerInfo) info ) {
		eventBus.send (
			schedulerAddress,
			JSON {
				Chime.key.operation -> Chime.operation.info,
				Chime.key.name -> name
			},
			( Throwable|Message<JSON?> msg ) {
				if ( is Message<JSON?> msg ) {
					"Reply from scheduler request has not to be null."
					assert( exists ret = msg.body() );
					info( TimerInfo.fromJSON( ret ) );
				}
				else {
					info( msg );
				}
			}
		);
	}
	
}
