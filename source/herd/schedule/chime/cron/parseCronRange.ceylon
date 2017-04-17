import ceylon.collection {

	HashSet
}


"Parses cron range in format TO-FROM / STEP
  where TO, FROM and STEP: 
 * contains only digits,
 * `FROM`-`TO`/`STEP`, `FROM`, `TO` and `STEP` are digits
 * `FROM`/`STEP`, `FROM` and `STEP` are digits, TO eqauls to max possible value
 * `FROM`-`TO`, FROM and TO are digits, step is supposed to be 1
 * TO and FROM have to be greater or equal min and less or equal max
"
since( "0.1.0" ) by( "Lis" )
Set<Integer>? parseCronRange( String expression, Integer minValue, Integer maxValue ) {
	HashSet<Integer> ret = HashSet<Integer>();
	{String*} ranged = expression.split( cron.special.contains, false ).map( String.trimmed );
	if ( exists from = parseStringToInteger( ranged.first ) ) {
		variable Integer to = from;
		variable Integer step = 1;
		if ( ranged.size == 1 ) {
			if ( from < minValue || from > maxValue ) {
				// 'from' to be within accepted values
				return null;
			}
		}
		else if ( ranged.size == 3 ) {
			if ( exists del = ranged.getFromFirst( 1 ) ) {
				if ( del == cron.range.string ) {
					if ( exists parsed = parseStringToInteger( ranged.getFromFirst( 2 ) ) ) {
						to = parsed;
						if ( to < from || to > maxValue ) {
							// 'to' to be within accepted values
							return null;
						}
					}
					else {
						// not digits
						return null;
					}
				}
				else if ( del == cron.increments.string ) {
					if ( exists parsed = parseStringToInteger( ranged.getFromFirst( 2 ) ) ) {
						if ( parsed < 1 ) {
							// step to be greater zero
							return null;
						}
						step = parsed;
						to = maxValue;
					}
					else {
						// not digits
						return null;
					}
				}
				else {
					// only '-' or '/' supported
					return null;
				}
			}
			else {
				return null;
			}
		} else if ( ranged.size == 5 ) {
			if ( exists del1 = ranged.getFromFirst( 1 ), exists del2 = ranged.getFromFirst( 3 ) ) {
				if ( del1 == cron.range.string && del2 == cron.increments.string ) {
					if ( exists parsedTo = parseStringToInteger( ranged.getFromFirst( 2 ) ),
						exists parsedStep = parseStringToInteger( ranged.getFromFirst( 4 ) ) )
					{
						if ( parsedTo < minValue || parsedTo > maxValue || parsedStep < 1 ) {
							// incorrect values
							return null;
						}
						to = parsedTo;
						step = parsedStep;
					}
					else {
						// not digits
						return null;
					}
				}
				else {
					// incorrect format - to be X-X/X
					return null;
				}
			}
			else {
				return null;
			}
		}
		else {
			// token must be in format X-X/X
			return null;
		}
		if ( step < 1 ) {
			step = 1;
		}
		// store range into set
		variable Integer storing = from;
		while ( storing <= to && storing <= maxValue ) {
			if ( storing >= minValue ) {
				ret.add( storing );
			}
			storing += step;
		}
		if ( ret.empty ) {
			return null;
		}
		else {
			return ret;
		}
	}
	return null;
}
