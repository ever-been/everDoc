## Used technologies
The reasoning why we chose this or that tech is already done in the decision timeline, this should be more of a list of all the stuff we used and what we used it for (including the technologies that have no real repercussions on the project but we just needed them). Consider a table with a lot of fancy logos...

### Hazelcast {#devel.techno.hazelcast}
[Hazelcast](http://www.hazelcast.com/) is the most important third-party framework used by our project. It is a highly scalable and configurable in-memory clustered data grid. We use this framework as basic stone over almost all BEEN components. We chose the framework because of its positives:

* provides automatic memory load ballancing between connected nodes
* provides failover data redundancy
* provides atomic acces to objects stored in grid
* provides SQL selectors to filtering stored data
* preserves the linked objects
* is highly scalable and configurable
* is fast and tested by many developers

We use community edition, which is open-source but has some limitation:

* All data are stored at JVM heaps of connected nodes - this may cause OutOfMemory problems when storing tons of gigabytes. In enterprise edition the off-heap technology is used.
* Hazelcast Management Center (web console) us restricted to use only on clusters with 2 nodes.
* Community edition does not contains cluster security feature.


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
As already mentioned in the introductory chapters, we decided to use some software project management technology instead of Ant, which is not maintainable on large projects. [Maven](http://maven.apache.org/) is robust software project management and comprehension tool based on XML descriptors representing project object model (POM). Maven takes care about project external dependencies and about dependencies between separate been modules. This avoids problems with version mismatch between various libraries.

### Apache Commons {#devel.techno.commons}
The previous team of the BEEN developers chose to implement almost everything about process execution, IO processing, collection processing, compression, serialization and so on ourselves. It could be due to lack of quality libraries at the time when they worked on the project. Unfortunatelly, the realization was buggy, confusing and fragile. Instead of re-inventing the wheel once more our team decided to use time-proven [Apache Commons](http://commons.apache.org) set of libraries.
    

### Apache HTTP Core/Components {#devel.techno.http}
[Apache HTTP components](http://hc.apache.org/) is library focused on low lever Java development over HTTP and associated protocols. In our project, we use it to implement simple HTTP server and HTTP protocol for storing and retrieving artifacts to and from software repository. 


### Jackson {#devel.techno.jackson}
We intensively use JSON for inter-process data communication and user type abstraction. Instead of writing our own implementation we used [Jackson](http://jackson.codehaus.org/) which is a fast, zero-dependency, lightweight and powerful Java library for processing JSON data. 


### JAXB {#devel.techno.jaxb}
JAXB - Java XML Binding is standard which specify how to map Java classes to XML representations. We use [Maven 2 JAXB 2.x Plugin](https://java.net/projects/maven-jaxb2-plugin/pages/Home) which generates Java classes in compile time. This plugin internally uses [reference JAXB implementation](http://jaxb.java.net/).


### Logback (logging implementarion) {#devel.techno.logback}
[Logback](http://logback.qos.ch/) is logging implementation. It is intended as as a successor to the popular "log4j" projects. Whe decided to use because it natively implements [SLF4J](#devel.techno.slf4j) logging interface. If for any reason you wanted to switch to another logging implementation implementing SLF4J interface, you could do so within seconds by changing few lines of xml in Maven POM descriptors.


### MongoDB {#devel.techno.mongodb}

*  (store all kinds of stuff)

### SLF4J (logging interface) {#devel.techno.slf4j}
Old incarnation of the BEEN framework has been messed up with at least four implementations of logging. Because we are holding modern standards we uniform all logging under the [SLF4J](http://www.slf4j.org/) logging interface. This decision has positives in very simple change of logging implementation.  


### Tapestry5 {#devel.techno.tapestry}
In previous versions of been developers decided to use JSP (JavaServer Pages) as basic building stone of the web interface. We decided to use [Tapestry5](http://tapestry.apache.org/), which is very flexible component based framework for creating robust and dynamic java web applications and also, what is most important, simply expansible and maintainable. We also used [Tapestry5-jquery](http://tapestry5-jquery.com/) extension, which replaces [Prototype](http://prototypejs.org/) for [jQuery](http://jquery.com/), the most popular JavaScript framework for dynamic web applications and [Tapestry5 CometD](https://github.com/uklance/tapestry-cometd), more and more popular web-socket extension.


### Twitter Bootstrap {#devel.techno.bootstrap}
Instead of writing tons of CSS, we chose to use [Twitter Bootstrap](http://getbootstrap.com) to design web interface. Although none of us is pure web designer, we were able to create uniform design in a very short time.

### Other
* I definitely forgot about a half of these, feel free to complete this, just maintain the cool alphabetic ordering