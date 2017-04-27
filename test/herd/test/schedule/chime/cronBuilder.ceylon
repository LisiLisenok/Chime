import ceylon.test {
	test
}
import herd.asynctest {
	AsyncTestContext
}
import herd.schedule.chime {
	CronBuilder,
	Chime
}
import ceylon.json {
	
	JSON = Object
}
import herd.asynctest.match {
	ItemByKey,
	ExceptionHasType
}


shared test void cronBuilderWith( AsyncTestContext context ) {
	JSON cron = CronBuilder().withSeconds(1,2).withMinutes(1,2).withHours(1,2)
			.withDays(1,2).withMonths(1,2).withYears(2017).withDaysOfWeek(1,2).build();
	context.assertThat (
		cron,
		ItemByKey( "type", Chime.type.cron )
	);
	context.assertThat (
		cron,
		ItemByKey( "seconds", "1,2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "minutes", "1,2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "hours", "1,2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "days of month", "1,2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "months", "1,2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "years", "2017" )
	);
	context.assertThat (
		cron,
		ItemByKey( "days of week", "1,2" )
	);
	context.complete();
}

shared test void cronBuilderWithAll( AsyncTestContext context ) {
	JSON cron = CronBuilder().withAllSeconds().withAllMinutes().withAllHours()
			.withAllDays().withAllMonths().withAllYears().withAllDaysOfWeek().build();
	context.assertThat (
		cron,
		ItemByKey( "type", Chime.type.cron )
	);
	context.assertThat (
		cron,
		ItemByKey( "seconds", "*" )
	);
	context.assertThat (
		cron,
		ItemByKey( "minutes", "*" )
	);
	context.assertThat (
		cron,
		ItemByKey( "hours", "*" )
	);
	context.assertThat (
		cron,
		ItemByKey( "days of month", "*" )
	);
	context.assertThat (
		cron,
		ItemByKey( "months", "*" )
	);
	context.assertThat (
		cron,
		ItemByKey( "years", "*" )
	);
	context.assertThat (
		cron,
		ItemByKey( "days of week", "*" )
	);
	context.complete();
}

shared test void cronBuilderWithRange( AsyncTestContext context ) {
	JSON cron = CronBuilder().withSecondsRange(1,5,2).withMinutesRange(1,5,2).withHoursRange(1,5,2)
			.withDaysRange(1,5,2).withMonthsRange(1,5,2).withYearsRange(2017,2021,2).withDaysOfWeekRange(1,5,2).build();
	context.assertThat (
		cron,
		ItemByKey( "type", Chime.type.cron )
	);
	context.assertThat (
		cron,
		ItemByKey( "seconds", "1-5/2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "minutes", "1-5/2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "hours", "1-5/2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "days of month", "1-5/2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "months", "1-5/2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "years", "2017-2021/2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "days of week", "1-5/2" )
	);
	context.complete();
}

shared test void cronBuilderFromBuilder( AsyncTestContext context ) {
	CronBuilder cronBuilder = CronBuilder().withSeconds(1,2).withMinutes(1,2).withHours(1,2);
	JSON cron = CronBuilder.fromBuilder(cronBuilder).withDays(1,2).withMonths(1,2).build();
	context.assertThat (
		cron,
		ItemByKey( "type", Chime.type.cron )
	);
	context.assertThat (
		cron,
		ItemByKey( "seconds", "1,2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "minutes", "1,2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "hours", "1,2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "days of month", "1,2" )
	);
	context.assertThat (
		cron,
		ItemByKey( "months", "1,2" )
	);
	context.complete();
}
shared test void cronBuilderIncomplete( AsyncTestContext context ) {
	CronBuilder cron = CronBuilder().withSecondsRange(1,5,2);
	context.assertThatException (
		cron.build,
		ExceptionHasType<AssertionError>()
	);
	context.complete();
}
