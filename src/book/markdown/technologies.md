## Used technologies
The reasoning why we chose this or that tech is already done in the decision timeline, this should be more of a list of all the stuff we used and what we used it for (including the technologies that have no real repercussions on the project but we just needed them). Consider a table with a lot of fancy logos...

### Hazelcast {#devel.techno.hazelcast}

### 0MQ {#devel.techno.zmq}
[0MQ](http://zeromq.org/) is a message passing library which can also
act as a concurrency framework. It supports many advanced features. Best
source to learn more about the library is the [0MQ Guide](http://zguide.zeromq.org/):

The EverBEEN team chose the library as the primary communication technology between a Host Runtime and its tasks, especially because of:

* focus on message passing
* multi-platform support
* ease-of-use compared to plain sockets
* extensive list of language bindings
* support for different message passing patters
* extensive documentation

We decided to use the [Pure Java implementation of libzmq](https://github.com/zeromq/jeromq)
because of easier integration with the project without the need to either compile
the C library for each supported platform or add external dependency on it.

As an experiment the [Task Manager](#devel.services.taskmanager)'s internal communication
has been implemented on top of the library as well using the inter-process communication
protocol, somewhat resembling the Actor concurrency model.

### Apache Maven {#devel.techno.maven}

### Apache Commons Exec {#devel.techno.exec}
The previous version of the BEEN framework chose to implement executing of tasks
using basic primitives found in the Java SE (which is known to be hard).
The realization was buggy, confusing and fragile. Instead of re-inventing the
wheel once more the team decided to use time-proven [Apache Commins Exec](http://commons.apache.org/proper/commons-exec/) library.

### Apache Commons {#devel.techno.commons}

*  (virtually everything around IO and compression)

### Apache HTTP Core/Components {#devel.techno.http}

*  (HTTP server)

### Bootstrap {#devel.techno.bootstrap}

* (cool skins, save time)


### Jackson {#devel.techno.jackson}

* (JSON serialization for inter-process data transport and user type abstraction)

### JAXB {#devel.techno.jaxb}

*  (serializable POJO generation)

### Logback (logging impl) {#devel.techno.logback}
### MongoDB {#devel.techno.mongodb}

*  (store all kinds of stuff)

### SLF4J {#devel.techno.slf4j}

* (logging unification of custom logging implementations and standard libraries)

### Tapestry {#devel.techno.tapestry}

### Other
* I definitely forgot about a half of these, feel free to complete this, just maintain the cool alphabetic ordering