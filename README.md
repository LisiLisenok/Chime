## Chime.

_Chime_ is time scheduler which works on _Vert.x_ event bus and provides:  

* scheduling with _cron-style_ and _interval_ timers  
* applying time zones available on _JVM_  
* flexible timers management system:  
	* grouping timers  
	* defining timer start or end time  
	* pausing / resuming  
	* fire counting  
* sending messages in _JSON_  
* _publish_ or _send_ timer fire event to the address of your choice  

Available on [Ceylon Herd](https://herd.ceylon-lang.org/modules/herd.schedule.chime)

> Runs with Ceylon 1.3.2 and Vert.x 3.4.0


## Usage and documentation.

1. Deploy _Chime_ verticle.
2. Create and listen timers on _EventBus_, see details in [API docs](https://modules.ceylon-lang.org/repo/1/herd/schedule/chime/0.2.0/module-doc/api/index.html)

Also, see [example](examples/herd/examples/schedule/chime)
