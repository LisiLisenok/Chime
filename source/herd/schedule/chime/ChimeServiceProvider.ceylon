import herd.schedule.chime.service {
	ChimeServices,
	Extension
}
import herd.schedule.chime.service.timezone {
	TimeZone,
	JVMTimeZoneFactory
}
import ceylon.collection {
	HashMap
}
import ceylon.json {
	JsonObject,
	JsonArray
}
import ceylon.language.meta {
	modules,
	type
}
import ceylon.language.meta.declaration {
	Module
}
import ceylon.language.meta.model {
	ClassOrInterface,
	Type
}
import io.vertx.ceylon.core {
	Vertx,
	Future,
	future
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

	
	"Collects service providers from the given module."
	static void collectFromModule (
		"Module to extract service provider from." Module m,
		"Interface represented service." ClassOrInterface<Extension<Anything>> providerType,
		"Map to collect providers. `key` is given with [[Extension.type]]." HashMap<String, Extension<Anything>> map
	) {
		value services = m.findServiceProviders<Extension<Anything>>(providerType);
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
	static {Extension<Anything>*} collectServices (
		"module name + version" {String*} moduleNames,
		"Service type." ClassOrInterface<Extension<Anything>> providerType
	) {
		HashMap<String, Extension<Anything>> providers = HashMap<String, Extension<Anything>>();
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
		

	"Factories to create extension."
	HashMap<Type<>, HashMap<String, Extension<Anything>>> providers
			= HashMap<Type<>, HashMap<String, Extension<Anything>>>();

	shared actual Vertx vertx;
	shared actual String address;
	
	
	"Instantiates new Chime service provider."
	shared new (
		"Vertx the Chime is run within." Vertx vertx,
		"Event bus address the _Chime_ listens to." String address
	) {
		this.vertx = vertx;
		this.address = address;
	}
	
	"Initializes the given list of extensions."
	Future<Anything> initializeExtensions (
		"Configuration the _Chime_ is started with." JsonObject config,
		"List of the providers to be initialized." {Extension<Anything>*} uninitialized,
		"Map to add successfully initialized providers."
		HashMap<Type<>, HashMap<String, Extension<Anything>>> toAddProviders
	) {
		Integer total = uninitialized.size;
		if (total > 0) {
			variable Integer initialized = 0;
			Future<Anything> ret = future.future<Anything>();
		
			value added = (Extension<Anything>|Throwable provider) {
				if (is Extension<Anything> provider) {
					if (exists m = toAddProviders[provider.parameter]) {
						m.put(provider.type, provider);
					}
					else {
						value m = HashMap<String, Extension<Anything>>();
						m.put(provider.type, provider);
						toAddProviders.put(provider.parameter, m);
					}
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
		"Completion handler." Anything(Anything) complete
	) {
		{String*} services = if (is JsonArray servicesArray = config.get(Chime.configuration.services))
			then servicesArray.narrow<String>() else {};
		initializeExtensions(config, collectServices(services, `Extension<Anything>`), providers).setHandler(complete);
	}
	
	"Returns info on the extensions."
	shared JsonArray extensionsInfo() {
		return JsonArray {
			for (m in providers)
				for (item in m.item.items) 
					JsonObject {
						Chime.key.service -> m.key.string,
						item.type -> type(item).declaration.qualifiedName
					}
		};
	}
	
	shared actual Service|<Integer->String> createService<Service> (
		String providerType, JsonObject options
	) {
		if (is Extension<Service> service = providers[`Service`]?.get(providerType)) {
			return service.create(this, options);
		}
		else {
			return Chime.errors.codeUnsupportedServiceProviderType->Chime.errors.unsupportedServiceProviderType;
		}
	}
		
	shared actual TimeZone localTimeZone => JVMTimeZoneFactory.localTimeZone;
	
}
