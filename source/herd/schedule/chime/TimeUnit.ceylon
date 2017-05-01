

"Unit of time."
since( "0.2.1" ) by( "Lis" )
shared class TimeUnit of hours | minutes | seconds
{
	"Number of seconds in the unit."
	shared Integer secondsIn;
	
	"Unit of hour."
	shared new hours { secondsIn = 3600; }
	"Unit of minutes."
	shared new minutes { secondsIn = 60; }
	"Unit of seconds."
	shared new seconds { secondsIn = 1; }
}
