## Modular approach

From the start, EverBEEN was developped as a modular project, and we backed our decision by using [Apache Maven](http://maven.apache.org/) as EverBEEN's building tool from day one. The major benefit of this decision is easier code maintenance in the futeure, and cleaner code in general. 

### Module overview
EverBEEN's modules can be categorized as follows.

#### Service modules

A subset of EverBEEN's modules corresponds exactly to the set of former WillBEEN services. The main motivation for such separation is to bar any potential in-code dependencies between services. That takes any cross service bug propagation (common with the use of RMI) out of the equation, making EverBEEN much less error-prone.

* **host-runtime** - Lends an EverBEEN node the ability to run tasks and benchmarks. Keeps track of the node's hardware, OS and load. Handles all the house-keeping around task processes.
* **object-repository** - Makes this node a bridge between EverBEEN and a persistence layer. Also gives the node the ability to handle persistence layer requests, run persistence layer cleanup etc.
* **software-repository-server** - Enables the node to store and distribute **BPK** bundles (packages with user software). Needed for EverBEEN to be able to run tasks. At most one should be present in the EverBEEN cluster.
* **task-manager** - Enable task planning on this node. All [data nodes](#user.deployment.nodes.types) run this service.
* **web-interface** - A Java container (e.g. [Apache Tomcat](http://tomcat.apache.org/) webapp able of connecting to the EverBEEN cluster. Serves as the GUI component of the system.



#### Internal API modules

Most of the places where EverBEEN bridges with a major piece of third-party technology are separated by an internal API.

* **been-api** - A general interface that covers interaction between the user and EverBEEN. All operations done through the GUI (web interface) go through the been API.
* **mapstore** - Not an API 'per se', this module contains the definition of EverBEEN configuration properties related to the Hazelcast mapstore implementation used for EverBEEN service data storage.
* **storage** - Generic persistence layer interface that covers user object storage and retrieval. 
* **service-logger** - Simple protocol that covers EverBEEN node log message submission to the cluster. Enables persistent storage of EverBEEN log messages and unified access to the logs of all cluster nodes.
* **software-repository-store** - Persistence layer interface for storing user software bundles. Used by the *Software Repository* service as persistence and by the *Host Runtime* service as a cache.



#### Internal API default implementations

Of course, implementations of the internal API modules are extracted to separate modules as well. None of these are hardcoded to EverBEEN. Various means are used instead to inject the implementations at runtime.

* **logback-appender** - A [Logback appender](http://logback.qos.ch/manual/appenders.html) that pushes local log messages back to the cluster via the interface provided by `service-logger`.
* **mongo-storage** - MongoDB implementation of the `storage` module.
* **mongodb-mapstore** - MongoDB implementation of the Hazelcast [MapStore](http://www.hazelcast.com/javadoc/com/hazelcast/core/MapStore.html) and [MapStoreFactory](http://www.hazelcast.com/javadoc/com/hazelcast/core/MapStoreFactory.html)
* **software-repository-fsbasedstore** - File system based implementation of the `software-repository-store` module.



#### System modules

Some of EverBEEN's modules provide additional functionality to existing EverBEEN components, and therefore do not quite make the case for an internal API.

* **core-cluster**
* **debug-assistant**
* **detectors**
* **service-logger-handler** 
* **socketworks-clients**
* **socketworks-servers**
* **software-repository-client**



#### Protocol object modules

As mentioned before, EverBEEN services do not communicate directly. Instead, they do so by placing well-known object into well-known data structures within cluster-wide shared memory. These modules contain the definitions of types transfered between services.

* **bpk-conventions**
* **checkpoints**
* **core-data**
* **core-protocol**
* **persistence**
* **results**
* **software-repository**



#### User API modules

The EverBEEN environment expects to run user code. Therefore, some modules need to provide a separate API which enables the user-programmed runtime to interact with the system.

* **benchmark-api**
* **bpk-plugin**
* **task-api**



#### Utility modules

As virtually any project, even EverBEEN has its own flavor of utilities.

* **util**
* **xsd-catalog-resolver**
* **xsd-export**



#### Deployment modules

Some EverBEEN modules were created with the sole purpose of deploying existing modules in some particular way.

* **node**
* **node-deploy**
* **web-interface-standalone**
* **mongo-storage-standalone**



#### Debugging tools

EverBEEN features a pair of modules that provide command-line debugging tools.

* **client-shell**
* **client-submitter**



### Module interactions

<!-- TODO describe dependencies between modules (probably a picture) -->
