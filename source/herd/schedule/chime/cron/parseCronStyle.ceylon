import ceylon.collection {
	
	HashSet
}


"Parses string expression with cron style time, returns set with all possible values. 
 Supported time in format X,X,... 
 where X to be: 
 * digits greater or equal min and less or equal max,
 * `FROM`-`TO`/`STEP`, `FROM`, `TO` and `STEP` are digits
 * `FROM`/`STEP`, `FROM` and `STEP` are digits, TO eqauls to max possible value
 * `FROM`-`TO`, FROM and TO are digits, step is supposed to be 1
 "
since( "0.1.0" ) by( "Lis" )
Set<Integer> parseCronStyle(
	"expression to be parsed" String expression,
	"min possible value" Integer minValue,
	"max possible value" Integer maxValue )
{
	String trimmedExpr = expression.trimmed;
	HashSet<Integer> ret = HashSet<Integer>();
	
	// all values
	if ( trimmedExpr == cron.allValues.string ) {
		variable Integer storing = minValue;
		while ( storing <= maxValue ) {
			ret.add( storing );
			storing ++;
		}
		return ret;
	}
	
	// parse tokens
	{String*} tokens = trimmedExpr.split( cron.delimiter.equals ).map( String.trimmed );
	for ( token in tokens ) {
		if ( exists tokenSet = parseCronRange( token, minValue, maxValue ) ) {
			ret.addAll( tokenSet );
		}
		else {
			ret.clear();
			break;
		}
	}
	return ret;
}
