
"Defines error messages."
by( "Lis" )
shared object errorMessages {
	
	shared String unsupportedOperation = "unsupported operation";
	
	shared String operationIsNotSpecified = "operation has to be specified";

		
	shared String schedulerNotExists = "scheduler doesn't exist";
		
	shared String schedulerNameHasToBeSpecified = "scheduler name has to be specified";
		
	shared String incorrectSchedulerState = "scheduler state has to be one of - 'get', 'paused', 'running'";
		
	shared String stateToBeSpecified = "state has to be specified";


	shared String timerAlreadyExists = "timer already exists";
	
	shared String timerNotExists = "timer doesn't exist";
	
	shared String timerNameHasToBeSpecified = "timer name has to be specified";
	
	shared String timerTypeHasToBeSpecified = "timer type has to be specified";
	
	shared String unsupportedTimerType = "unsupported timer type";
	
	shared String incorrectStartDate = "incorrect start date";
	
	shared String incorrectEndDate = "incorrect end date";
	
	shared String endDateToBeAfterStartDate = "end date has to be after start date";
	
	shared String unsupportedTimezone = "unsupported time zone";
	
	shared String timerDescriptionHasToBeSpecified = "timer description has to be specified";
	
	shared String incorrectTimerState = "timer state has to be one of - 'get', 'paused', 'running'";
	
	shared String delayHasToBeSpecified = "delay has to be specified";
	
	shared String delayHasToBeGreaterThanZero = "delay has to be greater than zero";
	
	shared String incorrectCronTimerDescription = "incorrect cron timer description";
	
}
