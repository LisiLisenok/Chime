
"Parses Integer from String?."
Integer? parseStringToInteger( String? str ) {
	if ( exists parsing = str ) {
		return parseInteger( parsing );
	}
	else {
		return null;
	}
}
