
"Returns timer state by name: 
 * \"paused\" - timerPaused
 * \"running\" - timerRunning
 * \"completed\" - timerCompleted
 * otherwise - null
 "
since( "0.2.0" ) by( "Lis" )
State? stateByName( String name ) {
	if ( name == State.paused.string ) {
		return State.paused;
	}
	else if ( name == State.running.string ) {
		return State.running;
	}
	else if ( name == State.completed.string ) {
		return State.completed;
	}
	else {
		return null;
	}
}


"Timer or scheduler state - running, paused or completed."
since( "0.2.0" ) by( "Lis" )
shared class State of running | paused | completed
{
	
	shared actual String string;
	
	shared new running {
		string = Chime.state.running;
	}
	
	shared new paused {
		string = Chime.state.paused;
	}
	
	shared new completed {
		string = Chime.state.completed;
	}

}
