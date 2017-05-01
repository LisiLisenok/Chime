import herd.asynctest {

	AsyncTestContext,
	AsyncPrePostContext
}
import io.vertx.ceylon.core {

	Vertx,
	vertx
}
import io.vertx.ceylon.core.eventbus {

	EventBus,
	Message
}
import ceylon.test {

	test,
	afterTestRun,
	beforeTestRun
}
import ceylon.json {

	JSON=Object,
	JSONArray=Array
}
import herd.asynctest.match {

	EqualTo
}
import herd.schedule.chime {

	Chime
}


since( "0.2.0" ) by( "Lis" )
shared class SimpleTimers()
{
	
	String chime = "chime";
	
	String scheduler = "scheduler";
	
	String interval = "scheduler:interval";
	String cron = "scheduler:cron";
	String union = "scheduler:union";

	
	Vertx v = vertx.vertx();
	EventBus eventBus = v.eventBus();
	
	
	shared afterTestRun void dispose() {
		v.close();
	}
	
	shared beforeTestRun void initialize( AsyncPrePostContext initContext ) {
		Chime c = Chime();
		c.deploy (
			v, null, 
			( String|Throwable res ) {
				if ( is String res ) {
					setupScheduler( initContext );
				}
				else {
					initContext.abort( res, "Chime starting" );
				}
			}
		); 
		
	}
	
	void setupScheduler( AsyncPrePostContext initContext ) {
		eventBus.send<JSON> (
			chime,
			JSON {
				Chime.key.operation -> Chime.operation.create,
				Chime.key.name -> scheduler,
				Chime.key.state -> Chime.state.running
			},
			( Throwable | Message<JSON?> msg ) {
				if ( is Message<JSON?> msg ) {
					initContext.proceed();
				}
				else {
					initContext.abort( msg, "Scheduler creation" );
				}
			}
		);
		
	}
	
	
	Anything( Throwable | Message<JSON?> ) timerValidation (
		String timerName, Integer delay, Integer max, AsyncTestContext context
	) {
		variable Integer fireCount = 0;
		variable Integer? previousTime = null;
		variable Integer totalDelay = 0;
		return ( Throwable | Message<JSON?> msg ) {
			if ( is Message<JSON?> msg ) {
				if ( exists body = msg.body() ) {
					if ( is String event = body[Chime.key.event] ) {
						if ( event == Chime.event.complete ) {
							context.assertThat( fireCount, EqualTo( max ), "Total number of fires for ``timerName``" );
							context.assertThat( totalDelay, EqualTo( delay * ( max - 1 ) ), "Total delay seconds for ``timerName``" );
							context.complete();
						}
						else if ( event == Chime.event.fire ) {
							fireCount ++;
							if ( is Integer seconds = body[Chime.date.seconds] ) {
								if ( exists prev = previousTime ) {
									if ( seconds > prev ) {
										totalDelay += seconds - prev; 
									}
									else {
										totalDelay += seconds + 60 - prev;
									}
								}
								previousTime = seconds;
							}
							else {
								context.fail (
									Exception( "Chime timer fires without timer seconds ('seconds' field)" ),
									"Chime timer ``timerName`` fire"
								);
								context.complete();
							}
						}
						else {
							context.fail (
								Exception( "Chime timer event has to be one of FIRE or COMPLETE" ),
								"Chime timer ``timerName`` fire"
							);
							context.complete();
						}
					}
					else {
						context.fail (
							Exception( "Chime timer event without timer event specification ('event' field)" ),
							"Chime timer ``timerName`` event"
						);
						context.complete();
					}
				}
				else {
					context.fail (
						Exception( "Chime timer fires with null message" ),
						"Chime timer ``timerName`` fire"
					);
					context.complete();
				}
			}
			else {
				context.fail( msg );
				context.complete();
			}
		};
	}
	
	
	test shared void intervalTimer( AsyncTestContext context ) {

		Integer timerDelay = 1;

		eventBus.consumer (
			interval,
			timerValidation( interval, timerDelay, 3, context )
		);
		
		eventBus.send<JSON>(
			chime,
			JSON {
				Chime.key.operation -> Chime.operation.create,
				Chime.key.name -> interval,
				Chime.key.state -> Chime.state.running,
				Chime.key.publish -> false,
				Chime.key.maxCount -> 3,
				Chime.key.description -> JSON {
					Chime.key.type -> Chime.type.interval,
					Chime.key.delay -> timerDelay
				}
			},
			( Throwable | Message<JSON?> msg ) {
				if ( is Throwable msg ) {
					context.fail( msg, "Interval timer setup" );
					context.complete();
				}
				else {
					if ( !msg.body() exists ) {
						context.fail( Exception( "Chime rejects to setup interval timer" ), "Interval timer setup" );
						context.complete();
					}
				}
			}
		);		
		
	}
	
	test shared void cronTimer( AsyncTestContext context ) {
		
		eventBus.consumer (
			cron,
			timerValidation( cron, 1, 3, context )
		);
		
		eventBus.send<JSON>(
			chime,
			JSON {
				Chime.key.operation -> Chime.operation.create,
				Chime.key.name -> cron,
				Chime.key.state -> Chime.state.running,
				Chime.key.publish -> false,
				Chime.key.maxCount -> 3,
				Chime.key.description -> JSON {
					Chime.key.type -> Chime.type.cron,
					Chime.date.seconds -> "0-59",
					Chime.date.minutes -> "*",
					Chime.date.hours -> "0-23",
					Chime.date.daysOfMonth -> "1-31",
					Chime.date.months -> "*",
					Chime.date.daysOfWeek -> "*",
					Chime.date.years -> "2015-2019"
				}
			},
			( Throwable | Message<JSON?> msg ) {
				if ( is Throwable msg ) {
					context.fail( msg, "Cron timer setup" );
					context.complete();
				}
				else {
					if ( !msg.body() exists ) {
						context.fail( Exception( "Chime rejects to setup cron timer" ), "Cron timer setup" );
						context.complete();
					}
				}
			}
		);		
		
	}

	test shared void unionTimer( AsyncTestContext context ) {
		
		eventBus.consumer (
			union,
			timerValidation( union, 1, 3, context )
		);
		
		eventBus.send<JSON>(
			chime,
			JSON {
				Chime.key.operation -> Chime.operation.create,
				Chime.key.name -> union,
				Chime.key.state -> Chime.state.running,
				Chime.key.publish -> false,
				Chime.key.maxCount -> 3,
				Chime.key.description -> JSON {
					Chime.key.type -> Chime.type.union,
					Chime.key.timers -> JSONArray {
						JSON {
							Chime.key.type -> Chime.type.cron,
							Chime.date.seconds -> "0-59/3",
							Chime.date.minutes -> "*",
							Chime.date.hours -> "*",
							Chime.date.daysOfMonth -> "*",
							Chime.date.months -> "*"
						},
						JSON {
							Chime.key.type -> Chime.type.cron,
							Chime.date.seconds -> "1-59/3",
							Chime.date.minutes -> "*",
							Chime.date.hours -> "*",
							Chime.date.daysOfMonth -> "*",
							Chime.date.months -> "*"
						},
						JSON {
							Chime.key.type -> Chime.type.cron,
							Chime.date.seconds -> "2-59/3",
							Chime.date.minutes -> "*",
							Chime.date.hours -> "*",
							Chime.date.daysOfMonth -> "*",
							Chime.date.months -> "*"
						}
					}
				}
			},
			( Throwable | Message<JSON?> msg ) {
				if ( is Throwable msg ) {
					context.fail( msg, "Union timer setup" );
					context.complete();
				}
				else {
					if ( !msg.body() exists ) {
						context.fail( Exception( "Chime rejects to setup union timer" ), "Union timer setup" );
						context.complete();
					}
				}
			}
		);		
		
	}
	
}
