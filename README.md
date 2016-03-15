## Chime.

_Chime_ is time scheduler which works on _Vert.x_ event bus and provides:  

* scheduling with _cron-style_ and _interval_ timers  
* applying time zones available on _JVM_  

Available on [Ceylon Herd](https://herd.ceylon-lang.org/modules/herd.schedule.chime)

>Runs with Ceylon 1.2.0 and Vert.x 3.2.1

 
## Dependences.

* ceylon.language/1.2.0  
* ceylon.time/1.2.0  
* io.vertx.ceylon.core/3.2.1


## Usage and documentation.

1. Deploy _Chime_ verticle programmatically using `Vertx.deployVerticle("ceylon:herd.schedule.chime/0.1.0")` or using Vert.x CLI with corresponding command. Vert.x downloads the module from [Ceylon Herd](https://herd.ceylon-lang.org) and deploys it.
2. Create and listen timers on _EventBus_, see details in [API docs](https://modules.ceylon-lang.org/repo/1/herd/schedule/chime/0.1.0/module-doc/api/index.html)

Also, see [example](examples/herd/examples/schedule/chime)
