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
	createScheduler,
	schedulerInfo,
	delete,
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
	JsonObject
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
		createScheduler (
			( Throwable|Scheduler msg ) {
				if ( is Scheduler msg ) {
					context.assertThat( msg.name, EqualTo( schedulerName ) );
					msg.delete();
					eventBus.send (
						chime,
						JsonObject {
							Chime.key.operation -> Chime.operation.info,
							Chime.key.name -> schedulerName
						},
						( Throwable|Message<JsonObject?> msg ) {
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
		createScheduler (
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
			JsonObject {
				Chime.key.operation -> Chime.operation.create,
				Chime.key.name -> schedulerName + Chime.configuration.nameSeparator + timerName,
				Chime.key.state -> Chime.state.running,
				Chime.key.publish -> false,
				Chime.key.description -> JsonObject {
					Chime.key.type -> Chime.type.interval,
					Chime.key.delay -> delay
				}
			}
		);
	}
	
	
	test shared void deleteTimers( AsyncTestContext context ) {
		String scheduler1 = "scheduler1";
		String scheduler2 = "scheduler2";
		String timer1 = "timer1";
		String timer2 = "timer2";
		String timer1Full = scheduler1 + ":" + timer1;
		String timer2Full = scheduler2 + ":" + timer2;
		
		// deletes all schedulers if created before this test
		delete( chime, eventBus );
		
		createTimer( scheduler1, timer1, 5 );
		createTimer( scheduler1, timer2, 7 );
		createTimer( scheduler2, timer1, 4 );
		createTimer( scheduler2, timer2, 9 );
		
		delete (
			chime, eventBus, { timer1Full, timer2Full },
			( Throwable|{String*} msg ) {
				if ( is Throwable msg ) {
					delete( chime, eventBus );
					context.fail( msg );
					context.complete();
				}
				else {
					context.assertThat( msg, SizeOf( 2 ) );
					if ( exists timer1Name = msg.first, exists timer2Name = msg.last ) {
						context.assertThat( timer1Name, EqualTo( timer1Full ) );
						context.assertThat( timer2Name, EqualTo( timer2Full ) );
					}
					else {
						context.fail( AssertionError( "Returned list of deleted items is empty." ) );
					}
					delete( chime, eventBus );
					context.complete();
				}
			}
		);
	}
	
	
	test shared void deleteSchedulers( AsyncTestContext context ) {
		String scheduler1 = "scheduler1";
		String scheduler2 = "scheduler2";
		String timer1 = "timer1";
		String timer2 = "timer2";
		
		// deletes all schedulers if created before this test
		delete( chime, eventBus );
		
		createTimer( scheduler1, timer1, 5 );
		createTimer( scheduler1, timer2, 7 );
		createTimer( scheduler2, timer1, 4 );
		createTimer( scheduler2, timer2, 9 );
		
		delete (
			chime, eventBus, { scheduler1, scheduler2 },
			( Throwable|{String*} msg ) {
				if ( is Throwable msg ) {
					delete( chime, eventBus );
					context.fail( msg );
					context.complete();
				}
				else {
					context.assertThat( msg, SizeOf( 2 ) );
					if ( exists scheduler1Name = msg.first, exists scheduler2Name = msg.last ) {
						context.assertThat( scheduler1Name, EqualTo( scheduler1 ) );
						context.assertThat( scheduler2Name, EqualTo( scheduler2 ) );
					}
					else {
						context.fail( AssertionError( "Returned list of deleted items is empty." ) );
					}
					delete( chime, eventBus );
					context.complete();
				}
			}
		);
	}

	
	test shared void getSchedulerInfo( AsyncTestContext context ) {
		String scheduler1 = "info1";
		String scheduler2 = "info2";
		String timer1 = "timer1";
		String timer2 = "timer2";
		
		// deletes all schedulers if created before this test
		delete( chime, eventBus );
		
		createTimer( scheduler1, timer1, 5 );
		createTimer( scheduler1, timer2, 7 );
		createTimer( scheduler2, timer1, 4 );
		createTimer( scheduler2, timer2, 9 );
		
		schedulerInfo (
			( Throwable|SchedulerInfo[] msg ) {
				if ( is Throwable msg ) {
					delete( chime, eventBus );
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
					delete( chime, eventBus );
					context.complete();
				}
			},
			chime, eventBus
		);
	}
	
	test shared void timerMessage( AsyncTestContext context ) {
		String schedulerName = "TimerMessage";
		String timerMessage = "message";
		createScheduler (
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
