import herd.asynctest {
	
	async
}


"_Chime_ unit testing."
since("0.2.0") by("Lis")
native("jvm") async
module herd.test.schedule.chime "0.3.0" {
	import herd.schedule.chime "0.3.0";
	shared import ceylon.test "1.3.3.1";
	shared import herd.asynctest "0.7.1";
	shared import io.vertx.ceylon.core "3.4.2";
}
