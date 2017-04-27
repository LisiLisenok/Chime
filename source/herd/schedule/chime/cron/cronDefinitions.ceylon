
"defines some constant used within cron expresion"
since( "0.1.0" ) by( "Lis" )
shared object cron
{	
	
	// cron special symbols
	
	"separators"
	shared {Character*} separators = { ' ', '\t', '\r', '\n' };
	
	"delimiter of fields"
	shared Character delimiter = ',';

	"special symbols in a one token"
	shared {Character*} special = { '/', '-' };
	
	"increments symbol"
	shared Character increments = '/';
	
	"range symbol"
	shared Character range = '-';
	
	"all values symbol"
	shared Character allValues = '*';
	
	"last symbol"
	shared Character last = 'L';
	
	"nth day symbol"
	shared Character nth = '#';
	
}
