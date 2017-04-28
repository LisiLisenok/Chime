import ceylon.test {
	beforeTestRun,
	afterTestRun,
	test
}
import herd.asynctest {
	AsyncPrePostContext,
	AsyncTestContext
}
import io.vertx.ceylon.core {
	Vertx,
	vertx
}
import herd.schedule.chime {
	Chime,
	Scheduler,
	connectToScheduler,
	schedulerInfo,
	Timer,
	TimerEvent,
	TimerInfo,
	SchedulerInfo,
	TimerFire,
	TimerCompleted
}
import io.vertx.ceylon.core.eventbus {
	EventBus,
	Message
}
import herd.asynctest.match {
	EqualTo,
	ExceptionHasMessage,
	PassType,
	SizeOf
}
import ceylon.json {
	JSON=Object
}


"Testing `Scheduler` and `Timer` interfaces and scheduler top level functions."
since( "0.2.0" ) by( "Lis" )
shared class SchedulerTimer()
{
	String chime = "chime";
	Vertx v = vertx.vertx();
	EventBus eventBus = v.eventBus();
	
	
	shared afterTestRun void dispose() {
		v.close();
	}
	
	shared beforeTestRun void initialize( AsyncPrePostContext initContext ) {
		Chime c = Chime();
		c.deploy (
			v, null, 
			( Throwable|String res ) {
				if ( is String res ) {
					initContext.proceed();
				}
				else {
					initContext.abort( res, "Chime starting" );
				}
			}
		); 
		
	}
	
	test shared void createDeleteScheduler( AsyncTestContext context ) {
		String schedulerName = "createDeleteScheduler";
		connectToScheduler (
			( Throwable|Scheduler msg ) {
				if ( is Scheduler msg ) {
					context.assertThat( msg.name, EqualTo( schedulerName ) );
					msg.delete();
					eventBus.send (
						chime,
						JSON {
							Chime.key.operation -> Chime.operation.info,
							Chime.key.name -> schedulerName
						},
						( Throwable|Message<JSON?> msg ) {
							context.assertThat( msg, PassType( ExceptionHasMessage( Chime.errors.schedulerNotExists ) ) );
							context.complete();
						}
					);
				}
				else {
					context.fail( msg );
					context.complete();
				}
			},
			chime, eventBus, schedulerName
		);
	}
	
	
	test shared void createDeleteTimer( AsyncTestContext context ) {
		String schedulerName = "createDeleteTimer";
		connectToScheduler (
			( Throwable|Scheduler msg ) {
				if ( is Scheduler msg ) {
					msg.createIntervalTimer (
						( Throwable|Timer timer ) {
							if ( is Timer timer ) {
								timer.handler (
									( TimerEvent event ) {
										timer.delete();
										timer.info (
											( Throwable|TimerInfo info ) {
												context.assertThat (
													info, PassType( ExceptionHasMessage( Chime.errors.timerNotExists ) )
												);
												msg.delete();
												context.complete();
											}
										);
									}
								);
							}
							else {
								msg.delete();
								context.fail( timer );
								context.complete();
							}
						},
						1
					);
				}
				else {
					context.fail( msg );
					context.complete();
				}
			},
			chime, eventBus, schedulerName
		);
	}
	
	
	void createTimer( String schedulerName, String timerName, Integer delay ) {
		eventBus.send(
			chime,
			JSON {
				Chime.key.operation -> Chime.operation.create,
				Chime.key.name -> schedulerName + Chime.configuration.nameSeparator + timerName,
				Chime.key.state -> Chime.state.running,
				Chime.key.publish -> false,
				Chime.key.description -> JSON {
					Chime.key.type -> Chime.type.interval,
					Chime.key.delay -> delay
				}
			}
		);
	}
	
	void deleteSchedulerOrTimer( String name ) {
		eventBus.send (
			chime,
			JSON {
				Chime.key.operation -> Chime.operation.delete,
				Chime.key.name -> name
			}
		);
	}
	
	test shared void getSchedulerInfo( AsyncTestContext context ) {
		String scheduler1 = "info1";
		String scheduler2 = "info2";
		String timer1 = "timer1";
		String timer2 = "timer2";
		
		// deletes all schedulers if created before this test
		deleteSchedulerOrTimer( chime );
		
		createTimer( scheduler1, timer1, 5 );
		createTimer( scheduler1, timer2, 7 );
		createTimer( scheduler2, timer1, 4 );
		createTimer( scheduler2, timer2, 9 );
		
		schedulerInfo (
			( Throwable|SchedulerInfo[] msg ) {
				if ( is Throwable msg ) {
					context.fail( msg );
					context.complete();
				}
				else {
					context.assertThat( msg, SizeOf( 2 ) );
					if ( exists sch1 = msg.first, exists sch2 = msg.last ) {
						context.assertThat( sch1.timers, SizeOf( 2 ) );
						context.assertThat( sch2.timers, SizeOf( 2 ) );
						context.assertThat( sch1.name, EqualTo( scheduler1 ) );
						context.assertThat( sch2.name, EqualTo( scheduler2 ) );
					}
					else {
						context.fail( AssertionError( "Returned list of infos is empty." ) );
					}
					deleteSchedulerOrTimer( chime );
					context.complete();
				}
			},
			chime, eventBus
		);
	}
	
	test shared void timerMessage( AsyncTestContext context ) {
		String schedulerName = "TimerMessage";
		String timerMessage = "message";
		connectToScheduler (
			( Throwable|Scheduler msg ) {
				if ( is Scheduler msg ) {
					msg.createIntervalTimer {
						handler = ( Throwable|Timer timer ) {
							if ( is Timer timer ) {
								timer.handler (
									( TimerEvent event ) {
										switch ( event )
										case ( is TimerFire ) {
											context.assertThat (
												event.message, PassType<String>( EqualTo( timerMessage ) )
											);
										}
										case ( is TimerCompleted ) {
											msg.delete();
											context.complete();
										}
										
										timer.delete();
										timer.info (
											( Throwable|TimerInfo info ) {
												context.assertThat (
													info, PassType( ExceptionHasMessage( Chime.errors.timerNotExists ) )
												);
												msg.delete();
												context.complete();
											}
										);
									}
								);
							}
							else {
								msg.delete();
								context.fail( timer );
								context.complete();
							}
						};
						delay = 1;
						maxCount = 1;
						message = timerMessage;
					};
				}
				else {
					context.fail( msg );
					context.complete();
				}
			},
			chime, eventBus, schedulerName
		);
	}
	
}
