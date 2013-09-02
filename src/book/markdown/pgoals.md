## Project Goals {#user.pgoals}
This section contains text copied directly from the Project Committee's web site.

[http://ksvi.mff.cuni.cz/~holan/SWP/zadani/ebeen.txt](http://ksvi.mff.cuni.cz/~holan/SWP/zadani/ebeen.txt)

### Overview {#user.pgoals.overview}
The Been framework automatically executes software performance measurements in a heterogeneous networked environment.  The basic architecture of the Been framework consists of a host runtime capable of executing arbitrary tasks, a task manager that relies on the host runtime to distribute and execute scheduled sequences of tasks, and a benchmark manager that creates the sequences of tasks to execute and measure benchmarks.  Other components include a software repository, a results repository, and a graphical user interface.

The Been framework has been developed as a part of a student project between 2004-2006, and substantially modified as a part of another student project between 2009-2010.


### Goals {#user.pgoals.goals}
The overall goal of this project is to modify the Been framework to facilitate truly continuous execution. In particular, this means:

* Reviewing the code responsible for communication between hosts, setting up rules that prevent the communication from creating orphan references (and therefore memory leaks), and rules that make the communication robust in face of network and host failures.

* Reviewing the code responsible for logging, setting up rules that govern all log storage (and prevent uncontrolled growth of logs).

* Reviewing the code responsible for temporary data storage, setting up rules that enforce reliable temporary data storage cleanup while preserving enough data for post mortem inspection of failed tasks and hosts.

* Reviewing the code responsible for measurement result storage, setting up rules for archival and cleanup that would make it possible to store recent results in detail and older results for overview purposes.

* Generally clean up any reliability related bugs.

### How we met the goals {#user.pgoals.approach}

The following overview takes into account goals set for the project as submitted to the Project Commission. The overall changes were much more substantial then anticipated. 

*Reviewing the code responsible for communication between hosts ...*
:	Completely new architecture and way of communication was introduced based on scalable, redundant data distribution.

*Reviewing the code responsible for logging ...*
:	Unified logging system was introduced based on standard Java logging mechanism, for tasks as well as the framework itself.

*Reviewing the code responsible for temporary data storage ...*
: TODO

*Reviewing the code responsible for measurement result storage ...*
:	Complete overhaul of the component responsible for result storage and retrieval was made.

*Generally clean up any reliability related bugs.*
: Adoption of standard development techniques and usage of 3rd party components resulted in much smaller and compact code base. 

## Project Output {#user.poutput}

The assignment of the current incarnation of the BEEN project are mainly focused on delivering a more usable, stable and scalable product. This meant that the development team should work on the current codebase and refactor it instead of starting from scratch.

There were however too many architectural and design points where refactoring simply couldn't get rid of the problems. The usage of RMI was too deep and too embedded into the whole codebase that replacing it with a more scalable middleware technology was not an option. The individual modules of BEEN were cross-linked and couldn't be separated by well-defined interfaces. Multiple implementations of the same functionality (e.g. logging) made the codebase scattered and inconsistent. Also, the project implemented several custom facilities that can be done better by using an external library.

This caused the team to reevaluate the requirements and they decided to rewrite BEEN from scratch, only preserving the concept and several design decision, e.g. the choice of components and their purpose. Because of this, the team could focus on creating a scalable, deployable and usable product from the first moment.

Therefore the goals were adapted to also contain:

* Preserving the basic concept of the whole environment
* Innovation of the codebase to use modern technologies and practices
* Delivering a highly scalable and stable product
* Reducing the number of *single points of failure*
* Making the framework easily deployable
* Improving usability to simplify writing and debugging tasks and benchmarks

### Distributed nature of EverBEEN {#user.poutput.distributed}

One of the biggest issues with the original BEEN project was stability of the computer network (both network itself and individual machines) and the framework required that all involved computers were running and available. Disconnecting some of the core services caused the whole network to hang or crash and recovery of this situation was often impossible. Also, the core components of BEEN had to be running for the whole time, which created a lot of *single points of failure*. Many common situation, like a short-term network outage, made the whole system fail and all of its components had to be rebooted.

Such a *client-server architecture* seemed inappropriate for a framework that is supposed to run in a large and heterogeneous network. The current version of BEEN is built on *Hazelcast*, a decentralized, highly scalable platform for distributed data sharing. Hazelcast is a Java-based library that implements peer-to-peer communication over TCP/IP, with automatic discovery of other nodes. This platform offers very user-friendly implementations of distributed maps, queues, lists, locks, topics, transactions and many other data structures and synchronization mechanisms.

Hazelcast supports data redundancy and fail-over mechanisms. Using these, BEEN is able to present a decentralized environment for the benchmarks. Each connected node is equal to each, and the framework can run as long as each node can communicate with the rest of the network. When a node gets disconnected (for whatever reason), the cluster is notified about this and stops using this node.

For this fail-redundancy to work properly, most of the core components now function in a decentralized manner and are present in many instances. For example the *Task Manager* is present in all *DATA nodes* and each such instance manages only a subset of all present tasks. When a node is disconnected, it's instance of the Task Manager is no longer functional and it's data is redistributed to the rest of the network. Most of the used internal data is not stored autonomously on a node, but it's rather shared in Hazelcast's distributed data structures.

This architecture of BEEN transformed the project into a fully distributed platform with high availability and scalability, while minimizing bottlenecks and the number of critical components.

### EverBEEN's Support for Regression Benchmarking {#user.poutput.regression}

<!-- TODO -->

BEEN's has been designed to cover both these use cases and still have only a single user-friendly API. The API for writing benchmarks is a unified mean to create and submit a benchmarkable item. Every benchmark consists of a user-written class which has a method `generateTaskContext`, which should return a new item to be benchmarked (called *task context*). When a benchmark doesn't have any item to submit, it can simply wait for an event (to support the push-oriented case). This method is called by the framework in a loop, so the benchmark can generate as many items as it wants. The benchmark can run indefinitely or it can mark itself as finished by returning `null` from the method. The BEEN cluster itself calls the method when it is capable of running a new item.

During the development, we have considered implementing a *descriptive language* that would specify which items are to be benchmarked. This would however only support the pull-oriented case and would require a different API for push-oriented benchmarking. The unified API offers unlimited flexibility, because the code that generates the benchmarkable items is written by the user.

This also means that the running benchmark can take the current (incomplete) results into account and modify the progress of the benchmark. E.g. this might be necessary to refine granularity of the benchmarked items when it detects an anomaly in the results.

For details about the API for writing tasks and benchmarks, see the [Task and Benchmark API](#user.taskapi) section.
