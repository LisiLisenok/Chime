
"Parses Integer from String?."
since( "0.1.0" ) by( "Lis" )
Integer? parseStringToInteger( String? str ) {
	if ( exists parsing = str ) {
		if ( is Integer ret = Integer.parse( parsing ) ) {
			return ret;
		}
		else {
			return null;
		}
	}
	else {
		return null;
	}
}
