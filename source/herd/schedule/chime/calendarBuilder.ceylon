import ceylon.time.base {
	Month,
	DayOfWeek
}
import ceylon.json {
	JsonObject,
	JsonArray
}
import herd.schedule.chime.service.calendar {
	AnnuallyFactory,
	DailyFactory,
	DativityFactory,
	LastDayOfWeekFactory,
	MonthlyFactory,
	WeekdayOfMonthFactory,
	WeeklyFactory,
	IntersectionFactory,
	UnionFactory
}
import ceylon.time {
	Time
}


"Builds calendar Json descriptions."
tagged("Builder")
see(`package herd.schedule.chime.service.calendar`)
since("0.3.0") by("Lis")
shared object calendar
{
	
	"Builds annually calendar Json desciption.  
	 Annually calendar excludes a given list of months."
	see(`class AnnuallyFactory`)
	shared JsonObject annually("Months the calendar excludes." Month+ months)
		=> JsonObject {
			Chime.calendar.type -> Chime.calendar.annually,
			Chime.date.months -> JsonArray {for (item in months) item.integer}
		};
	
	"Builds daily calendar Json description.  
	 Daily calendar excludes _from - to_ time of day."
	see(`class DailyFactory`)
	shared JsonObject daily (
		"Time the calendar excludes from." Time from,
		"Time the calendar excludes to." Time to,
		"Tolerance in second applied to shift the calendar out the restrictions, default is 1s." Integer tolerance = 1
	) {
		value ret = JsonObject {
			Chime.calendar.type -> Chime.calendar.daily,
			Chime.calendar.from -> JsonObject {
				Chime.date.seconds -> from.seconds,
				Chime.date.minutes -> from.minutes,
				Chime.date.hours -> from.hours
			},
			Chime.calendar.to -> JsonObject {
				Chime.date.seconds -> to.seconds,
				Chime.date.minutes -> to.minutes,
				Chime.date.hours -> to.hours
			}
		};
		if (tolerance > 0) {
			ret.put(Chime.calendar.tolerance, tolerance);
		}
		return ret;
	}
	
	"Builds dativity calendar Json desciption.  
	 Dativity calendar excludes a given list of dates."
	see(`class DativityFactory`)
	shared JsonObject dativity (
		"Dates calendar excludes.  
		 If it is `[Integer, Month]` then date with the given day and month and with any year is excluded.  
		 If it is `[Integer, Month, Integer]` then date with the given day, month and year is excluded"
		[Integer, Month]|[Integer, Month, Integer]+ dates
	)
		=> JsonObject {
			Chime.calendar.type -> Chime.calendar.dativity,
			Chime.calendar.dates -> JsonArray {
				for (item in dates) if (is [Integer, Month] item) then
					JsonObject {
						Chime.date.dayOfMonth -> item[0],
						Chime.date.month -> item[1].integer
					}
				else
				JsonObject {
					Chime.date.dayOfMonth -> item[0],
					Chime.date.month -> item[1].integer,
					Chime.date.year -> item[2]
				}
			}
		};

	"Builds last day of week calendar Json description.  
	 Last day of week calendar excludes only a last day of week in each month."
	see(`class LastDayOfWeekFactory`)
	shared JsonObject lastDayOfWeek("Day of week calenda excludes. Only last day of week." DayOfWeek dayOfWeek)
		=> JsonObject {
			Chime.calendar.type -> Chime.calendar.lastDayOfWeek,
			Chime.date.dayOfWeek -> dayOfWeek.successor.integer
		};
	
	"Builds monthly calendar Json description.  
	 Monthly calendar excludes a given list of days for every month."
	see(`class MonthlyFactory`)
	shared JsonObject monthly("Days calendar excludes." Integer+ days)
		=> JsonObject {
			Chime.calendar.type -> Chime.calendar.monthly,
			Chime.date.months -> JsonArray(days)
		};
	
	"Builds weekday of month calendar Json description.  
	 Weekday of month calendar excludes a given weekday with the given order in each month (i.e. excludes nth weekday).
	 "
	see(`class WeekdayOfMonthFactory`)
	shared JsonObject weekdayOfMonth (
		"Day of week to be excluded." DayOfWeek dayOfWeek,
		"Order of the excluded day of week." Integer order
	)
		=> JsonObject {
			Chime.calendar.type -> Chime.calendar.weekdayOfMonth,
			Chime.date.dayOfWeek -> dayOfWeek.successor.integer,
			Chime.date.order -> order
		};

	"Builds weekly calendar Json description.  
	 Weekly calendar excludes a given list of week days every week."
	see(`class WeeklyFactory`)
	shared JsonObject weekly (
		"Days of week to be excluded." DayOfWeek+ dayOfWeeks
	)
		=> JsonObject {
			Chime.calendar.type -> Chime.calendar.monthly,
			Chime.date.months -> JsonArray {for(item in dayOfWeeks) item.successor.integer}
		};

	"Builds calendars intersection."
	see(`class IntersectionFactory`)
	shared JsonObject intersect(JsonObject+ calendars)
		=> JsonObject {
			Chime.calendar.type -> Chime.calendar.intersection,
			Chime.date.months -> JsonArray(calendars)
		};
		
	"Builds calendars union."
	see(`class UnionFactory`)
	shared JsonObject union(JsonObject+ calendars)
		=> JsonObject {
			Chime.calendar.type -> Chime.calendar.union,
			Chime.date.months -> JsonArray(calendars)
		};

}
