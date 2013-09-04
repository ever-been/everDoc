## Used technologies

Follows overview of used technologies in EverBEEN.

### Hazelcast {#devel.techno.hazelcast}
[Hazelcast](http://www.hazelcast.com/) is the most important third-party framework used by our project. It is a highly scalable and configurable in-memory data grid. We chose the framework mostly because :

* provides automatic memory load ballancing between connected nodes
* provides failover data redundancy
* provides atomic acces to objects stored in the cluster
* provides SQL selectors for filtering stored data
* is highly scalable and configurable
* is fast and tested by many developers

We use the Community edition, which is open-source but has some (minor) limitations:

* All data are stored on the JVM heap of connected nodes - this may cause OutOfMemory problems when storing big amounts of data. In enterprise edition the off-heap technology can be used.
* Hazelcast Management Center (web console) is restricted to two nodes maximum.
* The Community Edition does not contain cluster security features.


### 0MQ {#devel.techno.zmq}
[0MQ](http://zeromq.org/) is a message passing library which can also
act as a concurrency framework. It supports many advanced features. Best
source to learn more about the library is the official [0MQ Guide](http://zguide.zeromq.org/):

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

As an experiment the [Task Manager](#devel.services.taskmanager) internal communication
has been implemented on top of the library as well using the inter-process communication
protocol, somewhat resembling the Actor concurrency model.

### Apache Maven {#devel.techno.maven}
[Apache Maven](http://maven.apache.org/) is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can manage a project's build, reporting and documentation from a central piece of information.

### Apache Commons {#devel.techno.commons}
Instead of re-inventing the wheel once more our team decided to use time-proven [Apache Commons](http://commons.apache.org) set of libraries for various purposes.
    

### Apache HTTP Core/Components {#devel.techno.http}
[Apache HTTP components](http://hc.apache.org/) is a library focused on HTTP and associated protocols. The Software Repository server and client is based on this library.

### Jackson {#devel.techno.jackson}
[Jackson](http://jackson.codehaus.org/) is a fast, zero-dependency, lightweight and powerful Java library for processing JSON data. 


### JAXB {#devel.techno.jaxb}
JAXB - Java XML Binding is standard which specifies how to map Java classes to XML representations. We use [Maven 2 JAXB 2.x Plugin](https://java.net/projects/maven-jaxb2-plugin/pages/Home) which generates Java classes from XSDs.


### Logback (logging implementarion) {#devel.techno.logback}
[Logback](http://logback.qos.ch/) is Java logging framework. It is intended as a successor to the popular "log4j" project. EverBEEN uses it as the logging mechanism.

### MongoDB {#devel.techno.mongodb}
[MongoDB](http://www.mongodb.org/) is a cross-platform document-oriented database system which classifies as a "NoSQL" database. Persistence layer backend of EverBEEN is built on top of it. 

### SLF4J (logging interface) {#devel.techno.slf4j}
The Simple Logging Facade for Java ([SLF4J](http://www.slf4j.org/) ) serves as a simple facade or abstraction for various logging frameworks (e.g. java.util.logging, logback, log4j) allowing the end user to plug in the desired logging framework at deployment time. The SLF4J is extensively used in EverBEEN as the logging facade.
 

### Tapestry5 {#devel.techno.tapestry}
[Apache Tapestry](http://tapestry.apache.org/) is an open-source framework for creating dynamic, robust, highly scalable web applications in Java or other JVM languages. Tapestry complements and builds upon the standard Java Servlet API, and so it works in any servlet container or application server. The Web Interface is build on top of it.

### Twitter Bootstrap {#devel.techno.bootstrap}
[Twitter Bootstrap](http://getbootstrap.com) is sleek, intuitive, and powerful front-end framework for faster and easier web development. Used in EverBEEN for the Web Interface design. 
