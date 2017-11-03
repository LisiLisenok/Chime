import ceylon.json {

	JsonObject
}
import ceylon.time {

	dateTime,
	DateTime
}
import herd.schedule.chime.service {
	ChimeServices
}
import herd.schedule.chime.service.timer {
	TimeRowFactory,
	TimeRow
}
import herd.schedule.chime.cron {

	calendar
}


"Uses `JSON` description to creates [[TimerContainer]] with timer [[TimeRow]] created by timer factory."
see(`interface TimeRowFactory`, `interface TimeRow`, `class TimerContainer`)
since("0.1.0") by("Lis")
class TimerCreator (
	"Services Chime provides." ChimeServices services
) {
	
	"Creates timer from creation request."
	shared TimerContainer|<Integer->String> createTimer (
			"Timer name." String name,
			"Request with timer description." JsonObject request,
			"Default time services." TimeServices defaultServices
		) {
		if (is JsonObject description = request[Chime.key.description]) {
			value timer = services.createTimeRow(description);
			if (is TimeRow timer) {
				return createTimerContainer(request, description, name, timer, defaultServices);
			}
			else {
				return timer;
			}
		}
		else {
			// timer description to be specified
			return Chime.errors.codeTimerDescriptionHasToBeSpecified->Chime.errors.timerDescriptionHasToBeSpecified;
		}
	}
	
	
	"Creates timer container by container and creation request."
	TimerContainer|<Integer->String> createTimerContainer (
		"Request on timer creation." JsonObject request,
		"Timer description." JsonObject description,
		"Timer name." String name,
		"Timer." TimeRow timer,
		"Default time services." TimeServices defaultServices
	) {
		// extract start date if exists
		DateTime? startDate;
		if (is JsonObject startTime = request[Chime.key.startTime]) {
			if (exists st = extractDate(startTime)) {
				startDate = st;
			}
			else {
				return Chime.errors.codeIncorrectStartDate->Chime.errors.incorrectStartDate;
			}
		}
		else {
			startDate = null;
		}
		
		// extract end date if exists
		DateTime? endDate;
		if (is JsonObject endTime = request[Chime.key.endTime]) {
			if (exists st = extractDate(endTime)) {
				endDate = st;
			}
			else {
				return Chime.errors.codeIncorrectEndDate->Chime.errors.incorrectEndDate;
			}
		}
		else {
			endDate = null;
		}
		
		// end date has to be after start!
		if (exists st = startDate, exists et = endDate) {
			if (et <= st) {
				return Chime.errors.codeEndDateToBeAfterStartDate->Chime.errors.endDateToBeAfterStartDate;
			}
		}
		
		value exactServices = servicesFromRequest (
			request, services, defaultServices
		);
		if (is TimeServices exactServices) {
			return TimerContainer (
				name, description, timer,
				extractMaxCount(request), startDate, endDate,
				request.get(Chime.key.message), exactServices
			);
		}
		else {
			return exactServices;
		}
	}
	
	"Extracts month from field with key key. The field can be either integer or string (like JAN, FEB etc, see [[calendar]])."
	Integer? extractMonth(JsonObject description, String key) {
		if (is Integer val = description[key]) {
			if (val > 0 && val < 13) {
				return val;
			}
			else {
				return null;
			}
		}
		else if (is String val = description[key]) {
			if (exists ret = calendar.monthFullMap[val]) {
				return ret;
			}
			return calendar.monthShortMap[val];
		}
		else {
			return null;
		}
	}
	
	"Extracts date from `JSON`, key returns `JSON` object with date."
	DateTime? extractDate(JsonObject date) {
		if (is Integer seconds = date[Chime.date.seconds],
			is Integer minutes = date[Chime.date.minutes],
			is Integer hours = date[Chime.date.hours],
			is Integer dayOfMonth = date[Chime.date.dayOfMonth],
			is Integer year = date[Chime.date.year],
			exists month = extractMonth(date, Chime.date.month)
		) {
			try {
				return dateTime(year, month, dayOfMonth, hours, minutes, seconds);
			}
			catch (Throwable err) {
				return null;
			}
		}
		return null;
	}
	
	"`maxCount` - nonmandatory field, if not specified - infinitely."
	Integer? extractMaxCount(JsonObject description) {
		if (is Integer c = description[Chime.key.maxCount]) {
			if (c > 0) {
				return c;
			}
			else {
				return 1;
			}
		}
		else {
			return null;
		}
	}
	
}
