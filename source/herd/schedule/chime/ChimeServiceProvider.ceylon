import herd.schedule.chime.service {
	ChimeServices,
	Extension
}
import herd.schedule.chime.service.timer {
	TimeRow,
	TimeRowFactory
}
import herd.schedule.chime.service.timezone {
	TimeZone,
	TimeZoneFactory
}
import herd.schedule.chime.service.message {
	MessageSource,
	MessageSourceFactory
}
import ceylon.collection {
	HashMap
}
import ceylon.json {
	JsonObject,
	JsonArray
}
import java.util {
	JavaTimeZone=TimeZone
}
import ceylon.time {
	DateTime
}
import ceylon.language.meta {
	modules,
	classDeclaration
}
import ceylon.language.meta.declaration {
	Module
}
import ceylon.language.meta.model {
	ClassOrInterface
}
import io.vertx.ceylon.core {
	Vertx,
	Future,
	future,
	compositeFuture,
	CompositeFuture
}


"Provides Chime services."
since("0.3.0") by("Lis")
class ChimeServiceProvider satisfies ChimeServices
{
	
	static String[2]? moduleNameAndVersion(String fullName) {
		value r = fullName.split('/'.equals);
		if (r.size == 2) {
			return [r.first.normalized, r.last.normalized];
		}
		else {
			return null;
		}
	}
	
	"Defines time converter which does no convertion."
	static object emptyConverter satisfies TimeZone {
		shared actual DateTime toLocal(DateTime remote) => remote;
		shared actual DateTime toRemote(DateTime local) => local;
		shared actual String timeZoneID => JavaTimeZone.default.id;
	}
	
	"Collects service providers from the given module."
	static void collectFromModule<Provider> (
		"Module to extract service provider from." Module m,
		"Interface represented service." ClassOrInterface<Provider> providerType,
		"Map to collect providers. `key` is given with [[Extension.type]]." HashMap<String, Provider> map
	) given Provider satisfies Extension {
		value services = m.findServiceProviders<Provider>(providerType);
		for (serv in services) {
			if (!map.contains(serv.type)) {
				map.put(serv.type, serv);
			}
			else {
				// TODO: log the extension hasn't been added
			}
		}
	}
	
	"Collects time row service providers."
	static {Provider*} collectServices<Provider> (
		"module name + version" {String*} moduleNames,
		"Service type." ClassOrInterface<Provider> providerType
	)
			given Provider satisfies Extension
	{
		HashMap<String, Provider> providers = HashMap<String, Provider>();
		collectFromModule(`module`, providerType, providers);
		for (moduleName in moduleNames) {
			if (exists splitName = moduleNameAndVersion(moduleName),
				exists m = modules.find(splitName[0], splitName[1])
			) {
				collectFromModule(m, providerType, providers);
			}
			else {
				// TODO: log the module hasn't been found
			}
		}
		return providers.items;
	}
	

	"Factories to create time rows."
	HashMap<String, TimeRowFactory> timeRowProviders = HashMap<String, TimeRowFactory>();
	"Factories to create time zones."
	HashMap<String, TimeZoneFactory> timeZoneProviders = HashMap<String, TimeZoneFactory>();
	"Factories to create message source."
	HashMap<String, MessageSourceFactory> messageSourceProviders = HashMap<String, MessageSourceFactory>();

	shared actual Vertx vertx;
	shared actual String address;
	
	"Instantiates new Chime service provider."
	shared new (
		"Vertx the Chime is run within." Vertx vertx,
		"Event bus address the _Chime_ is listens to." String address
	) {
		this.vertx = vertx;
		this.address = address;
	}
	
	"Initializes the given list of extensions."
	Future<Anything> initializeExtensions<Provider> (
		"Configuration the _Chime_ is started with." JsonObject config,
		"List of the providers to be initialized." {Provider*} uninitialized,
		"Map to add successfully initialized providers." HashMap<String, Provider> toAddProviders
	)
			given Provider satisfies Extension
	{
		Integer total = uninitialized.size;
		if (total > 0) {
			variable Integer initialized = 0;
			Future<Anything> ret = future.future<Anything>();
		
			value added = (Extension|Throwable provider) {
				if (is Provider provider) {
			  		toAddProviders.put(provider.type, provider);
				}
				else {
					// TODO: log the extension hasn't been initialized
				}
				initialized ++;
				if (initialized >= total) {
					ret.complete();
				}
			};
		
			for (provider in uninitialized) {
				provider.initialize(vertx, config, added);
			}
			return ret;
		}
		else {
			return future.succeededFuture<Anything>();
		}
	}
	
	"Initializes all external service providers."
	shared void initialize (
		"Configuration the _Chime_ is started with." JsonObject config,
		"Completion handler." Anything(Throwable|CompositeFuture) complete
	) {
		{String*} services = if (is JsonArray servicesArray = config.get(Chime.configuration.services))
			then servicesArray.narrow<String>() else {};
		value c = compositeFuture.any (
			initializeExtensions(config, collectServices(services, `TimeRowFactory`), timeRowProviders),
			initializeExtensions(config, collectServices(services, `TimeZoneFactory`), timeZoneProviders),
			initializeExtensions(config, collectServices(services, `MessageSourceFactory`), messageSourceProviders)
		);
		c.setHandler(complete);
	}

	JsonObject providerInfo({Extension*} providers)
		=> JsonObject {
			for (item in providers) item.type -> classDeclaration(item).qualifiedName
		};
	
	"Returns info on the extensions."
	shared JsonObject extensionsInfo()
		=> JsonObject {
			Chime.extension.timers -> providerInfo(timeRowProviders.items),
			Chime.extension.timeZones -> providerInfo(timeZoneProviders.items),
			Chime.extension.messageSources -> providerInfo(messageSourceProviders.items)
		};
	
	
	shared actual TimeRow|<Integer->String> createTimeRow(JsonObject description) {
		if (is String type = description[Chime.key.type]) {
			if (exists service = timeRowProviders[type]) {
				return service.create(this, description);
			}
			else {
				return Chime.errors.codeUnsupportedTimerType->Chime.errors.unsupportedTimerType;
			}
		}
		else {
			return Chime.errors.codeTimerTypeHasToBeSpecified->Chime.errors.timerTypeHasToBeSpecified;
		}		
	}
		
	shared actual TimeZone|<Integer->String> createTimeZone(String providerType, String timeZone) {
		if (exists service = timeZoneProviders[providerType]) {
			return service.create(this, timeZone);
		}
		else {
			return Chime.errors.codeUnsupportedTimeZoneProviderType->Chime.errors.unsupportedTimeZoneProviderType;
		}
	}
	
	shared actual MessageSource|<Integer->String> createMessageSource(String providerType, JsonObject? config) {
		if (exists service = messageSourceProviders[providerType]) {
			return service.create(this, config);
		}
		else {
			return Chime.errors.codeUnsupportedMessageSourceProviderType->Chime.errors.unsupportedMessageSourceProviderType;
		}
	}
	
	shared actual TimeZone localTimeZone => emptyConverter;

}
