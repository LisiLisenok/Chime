import herd.schedule.chime {
	TimerEvent
}


"Produces timer events."
since("0.3.0") by("Lis")
shared interface EventProducer
{
	"Sends timer event."
	shared formal void send(TimerEvent event);
}
