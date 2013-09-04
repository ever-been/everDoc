## EverBEEN architecture {#devel.architecture}

<!-- FIGREF -->
Differently from its predecessor, [WillBEEN](http://been.ow2.org/), EverBEEN was designed as a fully distributed application from the start. Despite the differences this implies on the design process and the overall system architecture, we tried to stick to the time-proven [concept of the original BEEN](http://d3s.mff.cuni.cz/publications/download/Submitted_1404_BEEN.pdf) as much as possible. The EverBEEN architecture is best explained on [**figure 3.1**](#devel.architecture.fig_archi).

<!-- FIGURE -->
[devel.architecture.fig_archi]: images/architecture/everbeen.png "EverBEEN architecture"
![EverBEEN architecture][devel.architecture.fig_archi]



### Cluster {#devel.architecture.cluster}

A major defining characteristic of EverBEEN is its clustered (distributed) nature. EverBEEN is designed to be run on an open network of interconnected nodes (EverBEEN JVM processes, presumably on different computers). These nodes serve as platform for launching user code or EverBEEN services on them.



### Services {#devel.architecture.services}

Probably the most notable fact in the above schema is the presence of some clustered services, namely:

* **Software Repository** - Handle user code package distribution
* **Host Runtime** - Run user code
* **Object Repository** - Store user code outputs
* **User Interface** - Generate cluster control-flow, display cluster state

These services are run on EverBEEN cluster nodes, by configuring the node at launch time. While EverBEEN relies on the eventual availability of its services, it remains oblivious to their actual location, as long as they're reachable within the cluster. The only exception to this is the *Software Repository*, which emits its location to the cluster to provide software packages via a simple HTTP protocol.

However, the overview of EverBEEN services would not be complete without *Task Manager*, not seen on this diagram. The *Task Manager* is a component responsible for all the house-keeping around scheduling user code execution. As such, it plays an essential role in the EverBEEN coordination. This led us to make its decision-making process decentralized and ensure that multiple *Task Manager* instances could co-exist in the cluster. The *Task Manager* is run on every [DATA node](#devel.architecture.nodes), which represents a transparent fail-over strategy in case one of multiple data nodes has to terminate.



### Native Nodes, Data Nodes {#devel.architecture.nodes}

As mentioned above, EverBEEN is based around the idea of cluster nodes. Because it may be in the best interest to limit unnecessary load on nodes running EverBEEN services, we enabled EverBEEN nodes to run in two modes:

`Data Nodes`
:	Take full part in cluster-wide data sharing. All data nodes run a *Task Manager* instance. These nodes add an extra point of fail-over, but need to perform additional house-keeping, which heightens the load they generate.

`Native Nodes`
:	Low-profile nodes that run without a *Task Manager* instance. Have access to all shared data, but are not responsible for any shared objects. Grant no fail-over, but generate less load and are more suitable for running EverBEEN services.



### User code {#devel.architecture.usercode}

Another factor that needs to be taken into consideration is the execution of user code in cooperation with the system. For security reasons, user code is always launched in a separate process in EverBEEN. As opposed to a thread-based solution, this approach offers better memory management and error handling. Moreover, it alleviates the restriction of user logic to JVM code.



### User code zone {#devel.architecture.userzone}

The clear separation of user and framework code zones is one of the major features introduced with EverBEEN. The motivation for this division is the absence of RTTI in system processes. WillBEEN's handling of user types involved these:

* Forcing the user to describe the data he persists using a Java-based meta-language
* Class bytecode generation based on meta-language description
* ORM mapping of so generaged classes using the [Hibernate](http://www.hibernate.org/) framework

This approach to persistence leads to several problems:

* To enact the ORM mapping, the generated class must be loaded. Once that happens, it cannot be unloaded using conventional means.
* Having multiple versions of meta-language description for the same ORM binding leads to conflicts (both classpath and SQL table)
* The user is forced to duplicate the definition of his data structures, which gives more room for errors.

In order to avoid this kind of hassle, we strove to rid the EverBEEN framework of all knowledge of user types, which ultimately leads to the code zone division discussed above.



### User Interface

The EverBEEN cluster is commanded through a web interface, deployable to standard Java Servlet containers. To do that, it connects to the cluster as a native node, and issues commands through a facade called `BeenApi`. In that sense, the web interface component is both a client (cluster scope) and a server (user scope). Any number of web interface instances can run on an EverBEEN cluster.

