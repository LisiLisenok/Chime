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

	JSON=Object
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
					if ( exists body = msg.body(), is String resp = body.get( Chime.key.response ), resp == Chime.response.ok ) {
						initContext.proceed();
					}
					else {
						initContext.abort( Exception( "Chime fails to create scheduler" ), "Scheduler creation" );
					}
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
		variable Integer fireCount = 1;
		variable Integer? previousTime = null;
		variable Integer totalDelay = 0;
		return ( Throwable | Message<JSON?> msg ) {
			if ( is Message<JSON?> msg ) {
				if ( exists body = msg.body() ) {
					if ( is String event = body.get( Chime.key.event ) ) {
						if ( event == Chime.event.complete ) {
							context.assertThat( fireCount, EqualTo( max + 1 ), "Total number of fires for ``timerName``" );
							context.assertThat( totalDelay, EqualTo( delay * ( max - 1 ) ), "Total delay seconds for ``timerName``" );
							context.complete();
						}
						else if ( event == Chime.event.fire ) {
							fireCount ++;
							if ( is Integer seconds = body.get( "seconds" ) ) {
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

		eventBus.consumer (
			interval,
			timerValidation( interval, 10, 3, context )
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
					Chime.key.delay -> 10
				}
			},
			( Throwable | Message<JSON?> msg ) {
				if ( is Throwable msg ) {
					context.fail( msg, "Interval timer setup" );
					context.complete();
				}
				else {
					if ( exists body = msg.body(), is String resp = body.get( Chime.key.response ),
						resp == Chime.response.ok
					) {}
					else {
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
			timerValidation( cron, 10, 3, context )
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
					Chime.date.seconds -> "0,10,20,30,40,50",
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
					if ( exists body = msg.body(), is String resp = body.get( Chime.key.response ),
						resp == Chime.response.ok
					) {}
					else {
						context.fail( Exception( "Chime rejects to setup cron timer" ), "Cron timer setup" );
						context.complete();
					}
				}
			}
		);		
		
	}
	
}
