
"Defines error messages."
since( "0.1.0" ) by( "Lis" )
shared object errorMessages {
	
	shared Integer codeUnsupportedOperation = 1; 
	shared String unsupportedOperation = "unsupported operation";
	
	shared Integer codeOperationIsNotSpecified = 2;
	shared String operationIsNotSpecified = "operation has to be specified";

	shared Integer codeSchedulerNotExists = 3;
	shared String schedulerNotExists = "scheduler doesn't exist";
	
	shared Integer codeSchedulerNameHasToBeSpecified = 4;
	shared String schedulerNameHasToBeSpecified = "scheduler name has to be specified";
	
	shared Integer codeIncorrectSchedulerState = 5;	
	shared String incorrectSchedulerState = "scheduler state has to be one of - 'get', 'paused', 'running'";
	
	shared Integer codeStateToBeSpecified = 6;
	shared String stateToBeSpecified = "state has to be specified";


	shared Integer codeTimerAlreadyExists = 7;
	shared String timerAlreadyExists = "timer already exists";
	
	shared Integer codeTimerNotExists = 8;
	shared String timerNotExists = "timer doesn't exist";
	
	shared Integer codeTimerNameHasToBeSpecified = 9;
	shared String timerNameHasToBeSpecified = "timer name has to be specified";
	
	shared Integer codeTimerTypeHasToBeSpecified = 10;
	shared String timerTypeHasToBeSpecified = "timer type has to be specified";
	
	shared Integer codeUnsupportedTimerType = 11;
	shared String unsupportedTimerType = "unsupported timer type";
	
	shared Integer codeIncorrectStartDate = 12;
	shared String incorrectStartDate = "incorrect start date";
	
	shared Integer codeIncorrectEndDate = 13;
	shared String incorrectEndDate = "incorrect end date";
	
	shared Integer codeEndDateToBeAfterStartDate = 14;
	shared String endDateToBeAfterStartDate = "end date has to be after start date";
	
	shared Integer codeUnsupportedTimezone = 15;
	shared String unsupportedTimezone = "unsupported time zone";
	
	shared Integer codeTimerDescriptionHasToBeSpecified = 16;
	shared String timerDescriptionHasToBeSpecified = "timer description has to be specified";
	
	shared Integer codeIncorrectTimerState = 17;
	shared String incorrectTimerState = "timer state has to be one of - 'get', 'paused', 'running'";
	
	shared Integer codeDelayHasToBeSpecified = 18;
	shared String delayHasToBeSpecified = "delay has to be specified";
	
	shared Integer codeDelayHasToBeGreaterThanZero = 19;
	shared String delayHasToBeGreaterThanZero = "delay has to be greater than zero";
	
	shared Integer codeIncorrectCronTimerDescription = 20;
	shared String incorrectCronTimerDescription = "incorrect cron timer description";
	
}
