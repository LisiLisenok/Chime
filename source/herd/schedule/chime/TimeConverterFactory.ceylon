

"Creates time converters."
since( "0.2.1" ) by( "Lis" )
interface TimeConverterFactory
{
	shared formal TimeConverter? getConverter( "Time zone name." String timeZone );
	
}
