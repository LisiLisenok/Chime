import ceylon.time.base {
	Month,
	monthOf
}
import ceylon.time {
	Date
}
import ceylon.json {
	JsonObject
}
import herd.schedule.chime {
	Chime
}
import herd.schedule.chime.cron {
	calendar
}


"Contains day, month and optional year."
since("0.3.0") by("Lis")
class DayMonth extends Object {
	
	shared static DayMonth fromJson(JsonObject descr) {
		"Year has to be Integer or undefined."
		assert (is Integer? y = descr[Chime.date.year]);
		return DayMonth.with(descr.getInteger(Chime.date.dayOfMonth), calendar.monthFromJson(descr, Chime.date.month), y);
	}
	
	
	Integer day;
	Month month;
	Integer? year;
	
	shared new fromDate(Date date) extends Object() {
		this.day = date.day;
		this.month = date.month;
		this.year = date.year;
	}
	
	shared new with(Integer day, Month|Integer month, Integer? year = null) extends Object() {
		this.day = day;
		this.month = monthOf(month);
		this.year = year;
	}
	
	shared actual Boolean equals(Object obj) {
		if (is DayMonth obj) {
			if (day == obj.day && month == obj.month) {
				if (exists y = year, exists objy = obj.year) {
					return y == objy;
				}
				else {
					return true;
				}
			}
			else {
				return false;
			}
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash {
		variable value hash = 1;
		hash = 31*hash + day;
		hash = 31*hash + month.hash;
		return hash;
	}
	
}
