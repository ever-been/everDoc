## Project history

### BEEN

The original BEEN project was started in Fall 2004 and it was finished at the turn of 2006 and 2007, it was supervised by Tomas Kalibera and developed by Jakub Lehotsky, David Majda, Branislav Repcek, Michal Tomcanyi, Antonin Tomecek and Jaroslav Urban. This project's assignment was:

> The aim of the project will be to create a highly configurable and modular environment
> for benchmarking of applications, with special focus on middleware benchmarks.

The team that worked on the project created the whole architecture and individual component of the framework and eventually implemented a functional benchmarking environment in Java, using RMI as the main mean of communication among it's individual parts.

### WillBEEN

The second incarnation of the framework was called *WillBEEN* and it mainly continued development of the original project. Its goal was to extend BEEN, mainly focusing on adding support for non-Java user tasks (scripts) and creating a modular results repository component. 

This project was supervised by Petr Tuma and developed by Andrej Podzimek, Jan Tattermusch and Jiri Tauber. The team started working in 2009 and finished the project in March 2010. During the development, several components were redesigned and reimplemented and the project integrated several new technologies, such as JAXB and Derby database.

### State of WillBEEN in 2012

In 2011, the faculty decided to create another assignment for BEEN, as it was an ambitious project, but the state of it was still far from ideal. Since the original team started working on the project more that 7 years before, it's codebase used obsolete technologies and the legacy of the initial architecture decisions were causing issues both with stability and performance. Especially the choice of RMI for component communication was deemed as the main source of problems. The project had also many *single points of failure*, e.g. disconnecting a single component rendered the whole environment unusable.

WillBEEN's development team had to cope with large, old and fragile codebase. While changes introduced during the development where of good to high quality, the team lacked necessary resources to radically change or rewrite all parts of the framework.

The deployment of BEEN was yet another problematic part, when installing and configuring the environment takes a tremendous amount of effort. Last but not least, the API for tasks and benchmarks is very complicated and writing and debugging of user code of a benchmark was almost impossible.

The new team was therefore supposed to eliminate some of these shortcomings, while stabilizing the framework even further. Thus the goals set where to rewrite the oldest parts of the framework, while maintaining the rest, along with finding better approach to component communication based on asynchronous message passing. The work load were estimated to +20,000 LOC.


### EverBEEN

It took another two years to assemble a group of students to fulfill the goals. In the meantime almost no maintenance work was done. Attempts to introduce the framework to corporate environment failed miserably. <!-- TODO link to j.t. thesis -->

After several months of code reviewing and attempts to modularize the framework, the EverBEEN team had to come to a decision - if the goals of the project are to be fulfilled, complete rewrite is necessary. The decision was done after careful consideration of all options and was not easy to make. 

EverBEEN, the current version (3.0) of the BEEN project, is an almost-complete rewrite of the whole framework. BEEN now has a fundamentally different, decentralized architecture. Also, the rewrite was an opportunity to introduce standard technologies and libraries instead of using of non-standard (and often duplicate) code. Many aspects of the project were simplified by usage of popular 3rd party Java libraries which makes the whole framework more stable and standardized. However, most of the the individual BEEN subsystems, their purpose and naming were preserved, therefore users familiar with previous BEEN implementations should recognize the whole system easily.

EverBEEN is supervised by Andrej Podzimek and Petr Tuma, and developed by Martin Sixta, Tadeas Palusga, Radek Macha and Jakub Brecka. The work on the project started in Fall 2012 and is believed to be finished in September 2013.

### Distributed nature of EverBEEN

One of the biggest issues with the original BEEN project was stability of the computer network (both network itself and individual machines) and the framework required that all the involved computer were running and available. Disconnecting some of the core services caused the whole network to hang or crash and recovery of this situation was often impossible. Also, the core components of BEEN had to be running for the whole time, which created a lot of *single points of failure*. Many common situation, like a short-term network outage, made the whole system fail and all of its components had to be rebooted.

Such a *client-server architecture* seemed inappropriate for a framework that is supposed to run in a large and heterogeneous network. The current version of BEEN is built on *Hazelcast*, a decentralized, highly scalable platform for distributed data sharing. Hazelcast is a Java-based library that implements peer-to-peer communication over TCP/IP, with automatic discovery of other nodes. This platform offers very user-friendly implementations of distributed maps, queues, lists, locks, topics, transactions and many other data structures and synchronization mechanisms.

Hazelcast supports data sharding with redundancy and fail-over mechanisms. Using these, BEEN is able to present a decentralized environment for the benchmarks, with almost no single point of failure. Each connected node is equal to each, and the framework can run as long as each node can communicate with the rest of the network. When a node gets disconnected (for whatever reason), the cluster is notified about this and stops using this node.

For this fail-redundancy to work properly, most of the core components now function in a decentralized manner and are present in many instances. For example the *Task Manager* is present in all *DATA nodes* and each such instance manages only a subset of all present tasks. When a node is disconnected, it's instance of the Task Manager is no longer functional and it's data is redistributed to the rest of the network. Most of the used internal data is not stored autonomously on a node, but it's rather shared in Hazelcast's distributed data structures.

This architecture of BEEN transformed the project into a fully distributed platform with high availability and scalability, while minimizing bottlenecks and the number of critical components.
