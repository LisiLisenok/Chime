import ceylon.time {
	DateTime
}
import ceylon.collection {
	ArrayList
}


"Represents a union of the time rows."
since( "0.2.1" ) by( "Lis" )
shared class TimeRowUnion satisfies TimeRow {
	
	static class InternalRow( TimeRow row ) satisfies TimeRow {
		variable DateTime? currentDate_ = null;
		shared DateTime? currentDate => currentDate_;
		shared actual DateTime? shiftTime() {
			return ( currentDate_ = row.shiftTime() );
		}
		shared actual DateTime? start( DateTime current ) {
			return ( currentDate_ = row.start( current ) );
		}
		shared actual String string => row.string;
	}
	
	static object emptyInternalRow extends InternalRow( emptyTimeRow ) {}
	
	
	"Currently selected row, i.e. with min date. Selected at [[shiftTime]] or [[start]]."
	variable InternalRow currentRow = emptyInternalRow;
	"List of currently active time rows."
	ArrayList<InternalRow> timeRows;
	
	
	"Instantiates new time row union from a list of time rows."
	shared new ( "Time rows for union." {TimeRow+} rows ) {
		timeRows = ArrayList<InternalRow>{ for ( item in rows ) InternalRow( item ) };
	}
	
	
	"Removes completed time rows from [[timeRows]] list."
	void removeCompleted() {
		value toRemove = [for ( item in timeRows ) if ( !item.currentDate exists ) item];
		timeRows.removeAll( toRemove );
		if ( timeRows.empty ) {
			currentRow = emptyInternalRow;
		}
	}
	
	
	shared actual DateTime? shiftTime() {
		currentRow.shiftTime();
		currentRow = emptyInternalRow;
		for ( item in timeRows ) {
			if ( exists n = currentRow.currentDate ) {
				if ( exists itemDate = item.currentDate, itemDate < n ) {
					currentRow = item;
				}
			}
			else {
				currentRow = item;
			}
		}
		value ret = currentRow.currentDate;
		removeCompleted();
		return ret;
	}
	
	shared actual DateTime? start( DateTime current ) {
		currentRow = emptyInternalRow;
		for ( item in timeRows ) {
			if ( exists itemDate = item.start( current ) ) {
				if ( exists l = currentRow.currentDate ) {
					if ( itemDate < l ) {
						currentRow = item;
					}
				}
				else {
					currentRow = item;
				}
			}
		}
		value ret = currentRow.currentDate;
		removeCompleted();
		return ret;
	}
	
	shared actual String string => "union time row: ``timeRows``";
	
}
