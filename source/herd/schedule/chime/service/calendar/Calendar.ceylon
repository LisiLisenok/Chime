import ceylon.time {
	DateTime
}


"Restricts timer fire date - time."
since("0.3.0") by("Lis")
shared interface Calendar
{
	"`true` if given date - time is inside the calendar and `false` if outside."
	shared formal Boolean inside(DateTime date);
	
	"Returns next date - time outside the calendar."
	shared formal DateTime nextOutside(DateTime date);
}
