

"Defines scheduler constants."
by( "Lis" )
shared object definitions
{	
		
	// configuration
	
	"default listening address"
	shared String defaultAddress = "chime";
	
	
	// configuration names
	
	"listening address"
	shared String address = "address";
	
	"max year period limit"
	shared String maxYearPeriodLimit = "max year period limit"; 
	
	"tolerance to compare fire time and current time in miliseconds"
	shared String tolerance = "tolerance";
	
	
	"separator of manager and timer name"
	shared String nameSeparator = ":";
	
	
	
	// time scheduler command / return fields
	
	"operation - to contain operation code"
	shared String fieldOperation = "operation";
	
	"timer name"
	shared String fieldName = "name";
	
	"timer state"
	shared String fieldState = "state";
	
	"response code"
	shared String fieldResponse = "response";
	
	"error field - contains error description, fieldResponse to be `error`"
	shared String fieldError = "error";
	
	"timer description"
	shared String fieldDescription = "descirption";
	
	"time field"
	shared String fieldTime = "time";
	
	"time count"
	shared String fieldCount = "count";
	
	"field with schedulers array"
	shared String fieldSchedulers = "schedulers";
	
	"field with timers array"
	shared String fieldTimers = "timers";
	
	
	"field max count"
	shared String fieldMaxCount = "max count";
	
	"publish field"
	shared String fieldPublish = "publish";
	
	"start time field"
	shared String fieldStartTime = "start time";
	"end time field"
	shared String fieldEndTime = "end time";

	
	// time zone
	shared String timeZoneID = "time zone";
	
	
	// delay in seconds
	shared String delay = "delay";
	
	// timer types
	shared String typeCronStyle = "cron";
	shared String typeInterval = "interval";	
	
	// operation codes
	
	"create timer"
	shared String opCreate = "create";
	"delete timer"
	shared String opDelete = "delete";
	"get or modify shceduler or timer state (pause, run)"
	shared String opState = "state";
	"get total or scheduler info"
	shared String opInfo = "info";

	"get state"
	shared String stateGet = "get";
	
	"timer description type field"
	shared String type = "type";

	// response codes
	
	"operation accepted"
	shared String responseOK = "ok";
	"error has been occured during operation execution - see `error` field"
	shared String responseError = "error";
	
}
