## Modular approach

* module interactions
* * this will need a lot of cool pictures

From the start, EverBEEN was developped as a modular project, and we backed our decision by using [Apache Maven](http://maven.apache.org/) as EverBEEN's building tool from day one. The major benefit of this decision is easier code maintenance in the futeure, and cleaner code in general. 

### Module overview
EverBEEN's modules can be categorized as follows.

#### Service modules

A subset of EverBEEN's modules corresponds exactly to the set of former WillBEEN services. The main motivation for such separation is to bar any potential in-code dependencies between services. That takes any cross service bug propagation (common with the use of RMI) out of the equation, making EverBEEN much less error-prone.

* host-runtime
* object-repository
* socketworks-clients
* socketworks-servers
* software-repository
* software-repository-client
* software-repository-server
* task-manager
* web-interface



#### Internal API modules

Most of the places where EverBEEN bridges with a major piece of third-party technology are separated by an internal API.

* been-api
* mapstore
* storage
* service-logger
* software-repository-store



#### Internal API default implementations

Of course, implementations of the internal API modules are extracted to separate modules as well. With the exception of `service-logger-handler`, none of these are hardcoded to EverBEEN. Various means are used instead to inject the implementations at runtime.

* logback-appender
* mongo-storage
* mongodb-mapstore
* service-logger-handler
* software-repository-fsbasedstore



#### System modules

Some of EverBEEN's modules provide additional functionality to existing EverBEEN components, and therefore do not quite make the case for an internal API.

* core-cluster
* debug-assistant
* detectors



#### Protocol object modules

As mentioned before, EverBEEN services do not communicate directly. Instead, they do so by placing well-known object into well-known data structures within cluster-wide shared memory. These modules contain the definitions of types transfered between services.

* bpk-conventions
* checkpoints
* core-data
* core-protocol
* persistence
* results



#### User API modules

The EverBEEN environment expects to run user code. Therefore, some modules need to provide a separate API which enables the user-programmed runtime to interact with the system.

* benchmark-api
* bpk-plugin
* task-api



#### Utility modules

As virtually any project, even EverBEEN has its own flavor of utilities.

* util
* xsd-catalog-resolver
* xsd-export



#### Deployment modules

Some EverBEEN modules were created with the sole purpose of deploying existing modules in some particular way.

* node
* node-deploy
* web-interface-standalone
* mongo-storage-standalone



#### Debugging tools

EverBEEN features a pair of modules that provide command-line debugging tools.

* client-shell
* client-submitter



### Module interactions


