import ceylon.json {

	JSON=Object,
	ObjectValue
}
import ceylon.time {

	DateTime
}
import herd.schedule.chime.timer {
	TimeRow
}
import io.vertx.ceylon.core.eventbus {
	DeliveryOptions
}


"Posses timer."
since( "0.1.0" ) by( "Lis" )
class TimerContainer (
	"Timer full name, which is *'scheduler name':'timer name'*." shared String name,
	"Timer [[JSON]] description" shared JSON description,
	"`true` if message to be published and `false` if message to be send" shared Boolean publish,
	"Timer within this container." TimeRow timer,
	"Remote-local date-time converter." TimeConverter converter,
	"Max count or null if not specified." shared Integer? maxCount,
	"Timer start time or null if to be started immediately." shared DateTime? startTime,
	"Timer end time or null if not specified." shared DateTime? endTime,
	"Message given at request level and to be attached to the timer fire event." ObjectValue? requestMessage,
	"Delivery options given at request level and message has to be sent with." DeliveryOptions? requestOptions
) {
	
	"Timer fire counting."
	shared variable Integer count = 0;
	
	"Timer state."
	shared variable State state = State.paused;

	"Next fire timer in remote TZ or null if completed."
	variable DateTime? nextRemoteFireTime = null;
	
	"Next fire timer in remote TZ or null if completed."
	shared DateTime? remoteFireTime => nextRemoteFireTime;
	
	"Next fire timer in machine local TZ or null if completed."
	shared DateTime? localFireTime => if ( exists d = nextRemoteFireTime ) then converter.toLocal( d ) else null;
	
	"Time zone ID."
	shared String timeZoneID => converter.timeZoneID;

	"Message to be attached to the timer fire event."
	shared ObjectValue? message => timer.message else requestMessage;
	
	"Delivery options message has to be sent with."
	shared DeliveryOptions? options => timer.options else requestOptions;

	"Timer name + state."
	shared JSON stateDescription() {
		return JSON {
			Chime.key.name -> name,
			Chime.key.state -> state.string
		};
	}
	
	"Returns _full_ timer description."
	shared JSON fullDescription() {
		JSON descr = JSON {
			Chime.key.name -> name,
			Chime.key.state -> state.string,
			Chime.key.count -> count,
			Chime.key.description -> description,
			Chime.key.publish -> publish,
			Chime.key.timeZone -> timeZoneID
		};
		
		if ( exists d = maxCount ) {
			descr.put( Chime.key.maxCount, d );
		}
		
		if ( exists d = startTime ) {
			descr.put (
				Chime.key.startTime,
				JSON {
					Chime.date.seconds -> d.seconds,
					Chime.date.minutes -> d.minutes,
					Chime.date.hours -> d.hours,
					Chime.date.dayOfMonth -> d.day,
					Chime.date.month -> d.month.string,
					Chime.date.year -> d.year
				}
			);
		}
		
		if ( exists d = endTime ) {
			descr.put (
				Chime.key.endTime,
				JSON {
					Chime.date.seconds -> d.seconds,
					Chime.date.minutes -> d.minutes,
					Chime.date.hours -> d.hours,
					Chime.date.dayOfMonth -> d.day,
					Chime.date.month -> d.month.string,
					Chime.date.year -> d.year
				}
			);
		}
		
		if ( exists m = requestMessage ) {
			descr.put( Chime.key.message, m );
		}
		if ( exists m = requestOptions ) {
			descr.put( Chime.key.deliveryOptions, m.toJson() );
		}
		
		return descr;
	}
	
	"Starts the timer."
	shared void start( DateTime currentLocal ) {
		DateTime currentRemote = converter.toRemote( currentLocal );
		// check if max count has been reached before
		if ( exists c = maxCount ) {
			if ( count >= c ) {
				complete();
				return;
			}
		}
		// check if start time is after current
		DateTime beginning;
		if ( exists st = startTime ) {
			if ( st > currentRemote ) {
				beginning = st;
			}
			else {
				beginning = currentRemote;
			}
		}
		else {
			beginning = currentRemote;
		}
		// start timer
		if ( exists date = timer.start( beginning ) ) {
			if ( exists ed = endTime ) {
				if ( date > ed ) {
					complete();
					return;
				}
			}
			state = State.running;
			nextRemoteFireTime = date;
		}
		else {
			complete();
		}
	}
	
	"Sets timer completed."
	shared void complete() {
		nextRemoteFireTime = null;
		state = State.completed;
	}
	
	"Shifts timer to the next time."
	shared void shiftTime() {
		if ( state == State.running ) {
			count ++;
			if ( exists date = timer.shiftTime() ) {
				// check on complete
				if ( exists ed = endTime ) {
					if ( date > ed ) {
						complete();
						return;
					}
				}
				if ( exists c = maxCount ) {
					if ( count >= c ) {
						complete();
						return;
					}
				}
				nextRemoteFireTime = date;
			}
		}
	}
	
}
