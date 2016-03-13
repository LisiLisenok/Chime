
"Cron expression parsed by items."
by( "Lis" )
shared class CronExpression (
	"Set of exoression seconds, 0-59." shared Set<Integer> seconds,
	"Set of exoression minutes, 0-59." shared Set<Integer> minutes,
	"Set of exoression hours, 0-23." shared Set<Integer> hours,
	"Set of exoression days of month, 1-31." shared Set<Integer> daysOfMonth,
	"Set of exoression months, 1-12." shared Set<Integer> months,
	"Days of week." shared DaysOfWeekList daysOfWeek,
	"Set of exoression years, can be empty." shared Set<Integer> years
 )
{}
