import ceylon.json {

	JsonObject,
	ObjectValue
}
import ceylon.time {

	DateTime
}
import herd.schedule.chime.service.timer {
	TimeRow
}


"Posses timer."
since("0.1.0") by("Lis")
class TimerContainer (
	"Timer full name, which is **scheduler name:timer name**." shared String name,
	"Timer `JsonObject` description" JsonObject description,
	"Timer within this container." TimeRow timer,
	"Max count or null if not specified." Integer? maxCount,
	"Timer start time or null if to be started immediately." DateTime? startTime,
	"Timer end time or null if not specified." DateTime? endTime,
	"Message to be attached to the timer fire event." ObjectValue? message,
	"Timer services: time zone, message source, event producer, calendar."
	TimeServices services
) {
	
	"Timer fire counting."
	shared variable Integer count = 0;
	
	"Timer state."
	shared variable State state = State.paused;

	"Next fire timer in remote TZ or null if completed."
	variable DateTime? nextRemoteFireTime = null;
	
	"Next fire timer in machine local TZ or null if completed."
	shared DateTime? localFireTime => if (exists d = nextRemoteFireTime) then services.toLocal(d) else null;
	
	"Time zone ID."
	shared String timeZoneID => services.timeZoneID;


	"Timer name + state."
	shared JsonObject stateDescription() {
		return JsonObject {
			Chime.key.name -> name,
			Chime.key.state -> state.string
		};
	}
	
	"Returns _full_ timer description."
	shared JsonObject fullDescription() {
		JsonObject descr = JsonObject {
			Chime.key.name -> name,
			Chime.key.state -> state.string,
			Chime.key.count -> count,
			Chime.key.description -> description,
			Chime.key.timeZone -> timeZoneID
		};
		
		if (exists d = maxCount) {
			descr.put(Chime.key.maxCount, d);
		}
		
		if (exists d = startTime) {
			descr.put (
				Chime.key.startTime,
				JsonObject {
					Chime.date.seconds -> d.seconds,
					Chime.date.minutes -> d.minutes,
					Chime.date.hours -> d.hours,
					Chime.date.dayOfMonth -> d.day,
					Chime.date.month -> d.month.string,
					Chime.date.year -> d.year
				}
			);
		}
		
		if (exists d = endTime) {
			descr.put (
				Chime.key.endTime,
				JsonObject {
					Chime.date.seconds -> d.seconds,
					Chime.date.minutes -> d.minutes,
					Chime.date.hours -> d.hours,
					Chime.date.dayOfMonth -> d.day,
					Chime.date.month -> d.month.string,
					Chime.date.year -> d.year
				}
			);
		}
		
		return descr;
	}
	
	"Creates timer fire event for the next fire date time and using extracted message."
	shared void timerFireEvent() {
		if (state == State.running, exists at = nextRemoteFireTime) {
			TimerFire event = TimerFire(name, count, timeZoneID, at, message);
			services.extract(event, sendTimerFireEvent(event));
		}
	}
	
	void sendTimerFireEvent(TimerFire event)(ObjectValue? message)
		=> services.send(TimerFire(event.timerName, event.count, event.timeZone, event.date, message));
	
	
	"Starts the timer."
	shared void start(DateTime currentLocal) {
		DateTime currentRemote = services.toRemote(currentLocal);
		// check if max count has been reached before
		if (exists c = maxCount) {
			if (count >= c) {
				complete();
				return;
			}
		}
		// check if start time is after current
		DateTime beginning;
		if (exists st = startTime) {
			if (st > currentRemote) {
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
		if (exists date = calendarDate(timer.start(beginning))) {
			if (exists ed = endTime) {
				if (date > ed) {
					complete();
					return;
				}
			}
			state = State.running;
			count ++;
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
		services.send(TimerCompleted(name, count));
	}
	
	"Shifts timer to the next time."
	shared void shiftTime() {
		if (state == State.running) {
			if (exists date = calendarDate(timer.shiftTime())) {
				// check on complete
				if (exists ed = endTime) {
					if (date > ed) {
						complete();
						return;
					}
				}
				if (exists c = maxCount) {
					if (count >= c) {
						complete();
						return;
					}
				}
				count ++;
				nextRemoteFireTime = date;
			}
			else {
				complete();
			}
		}
	}
	
	"Returns date bounds by calendar."
	DateTime? calendarDate(variable DateTime? date) {
		while (exists cur = date) {
			if (services.inside(cur)) {
				if (services.calendarIgnorance) {
					date = timer.shiftTime();
				}
				else {
					date = services.nextOutside(cur);
				}
			}
			else {
				return cur;
			}
		}
		return null;
	}
}
