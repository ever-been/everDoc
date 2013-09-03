## Project Goals {#user.pgoals}
This section contains text copied directly from the Project Committee's web site.

[http://ksvi.mff.cuni.cz/~holan/SWP/zadani/ebeen.txt](http://ksvi.mff.cuni.cz/~holan/SWP/zadani/ebeen.txt)

### Overview {#user.pgoals.overview}
> *"The Been framework automatically executes software performance measurements in a heterogeneous networked environment.  The basic architecture of the Been framework consists of a host runtime capable of executing arbitrary tasks, a task manager that relies on the host runtime to distribute and execute scheduled sequences of tasks, and a benchmark manager that creates the sequences of tasks to execute and measure benchmarks.  Other components include a software repository, a results repository, and a graphical user interface."*

The Been framework has been developed as a part of a student project between 2004-2006, and substantially modified as a part of another student project between 2009-2010.


### Goals {#user.pgoals.goals}
The overall goal of this project is to modify the Been framework to facilitate truly continuous execution. In particular, this means:

* Reviewing the code responsible for communication between hosts, setting up rules that prevent the communication from creating orphan references (and therefore memory leaks), and rules that make the communication robust in face of network and host failures.

* Reviewing the code responsible for logging, setting up rules that govern all log storage (and prevent uncontrolled growth of logs).

* Reviewing the code responsible for temporary data storage, setting up rules that enforce reliable temporary data storage cleanup while preserving enough data for post mortem inspection of failed tasks and hosts.

* Reviewing the code responsible for measurement result storage, setting up rules for archival and cleanup that would make it possible to store recent results in detail and older results for overview purposes.

* Generally clean up any reliability related bugs.

### How we met the goals {#user.pgoals.approach}

The following overview takes into account goals set for the project as submitted to the Project Committee. The overall changes were much more substantial than anticipated. 

*Reviewing the code responsible for communication between hosts ...*
:	A completely new architecture and communication protocol was introduced based on scalable, redundant data distribution.

*Reviewing the code responsible for logging ...*
:	Both user code API and framework code were ported under a unified logging system compliant to latest Java development standards.

*Reviewing the code responsible for temporary data storage ...*
:	A deletion policy was set up for all leftover user task data (working directories, logs, results), enforcing automatic cleanup after a configurable expiration period or possibility of easy manual deletion.

*Reviewing the code responsible for measurement result storage ...*
:	A complete overhaul of the component responsible for result storage and retrieval was made.

*Generally clean up any reliability related bugs.*
:	Adoption of standard development techniques and usage of third party components resulted in a much smaller and compact code base. 

## Project Output {#user.poutput}

The initial assignment of the EverBEEN project mainly focuses on delivering a more usable, stable and scalable product. That being said, it was assumed that the development team will work on existing codebase and refactor it instead of starting from scratch.

There were, however, multiple design flaws refactoring alone could not remedy. The *RMI* library was too deeply embedded into the codebase to be simply replaced. The individual modules of WillBEEN were cross-linked and couldn't be separated by well-defined interfaces. Multiple implementations of the same functionality (e.g. logging) made the codebase scattered and inconsistent. Also, the WillBEEN implemented several custom facilities which are, as of toady, standard issue among external Java libraries.

To meet stability and scalability requirements, the team decided to rewrite BEEN from scratch, only preserving the concept and several design decision, e.g. the choice of most components and their purpose. Subsequently, the team could focus on creating a scalable, usable product from the first moment.

Therefore the project goals were extended to include:

* Preserving the basic concept of the whole environment
* Innovating the codebase by use modern technologies and practices
* Delivering a highly scalable and stable product
* Reducing the number of *single points of failure*
* Making the framework easy to deploy
* Improving usability by simplifying task and benchmark creation and debugging

### Distributed nature of EverBEEN {#user.poutput.distributed}

One of WillBEEN's major issues was reliance on network stability. The framework required that all involved computers be running and available. Disconnecting some of the core services caused the whole framework to hang or crash, and recovery was often impossible. Also, the core EverBEEN components were required to be running for the whole time, which created a lot of *single points of failure*. That aggravated common situations like short-term network outages to irrecoverable system failures.

Such fragile *client-server architecture* seemed inappropriate for a framework supposedly tailored for large and heterogeneous networks. That is why EverBEEN is built on *Hazelcast* -- a decentralized, highly scalable platform for distributed data sharing. Hazelcast is a Java-based library that implements peer-to-peer communication over TCP/IP, featuring redundant data sharing, transparent replication and automatic peer discovery. This platform realizes distributed maps, queues, lists, locks, topics, transactions and synchronization mechanisms using distributed hashing tables.

<!-- TODO refactor following two paragraphs -->

Hazelcast supports data redundancy and fail-over mechanisms. Using these, BEEN is able to present a decentralized environment for the benchmarks. Each connected node is equal to each, and the framework can run as long as each node can communicate with the rest of the network. When a node gets disconnected (for whatever reason), the cluster is notified about this and stops using this node.

For this fail-redundancy to work properly, most of the core components now function in a decentralized manner and are present in many instances. For example the *Task Manager* is present in all *DATA nodes* and each such instance manages only a subset of all present tasks. When a node is disconnected, it's instance of the Task Manager is no longer functional and it's data is redistributed to the rest of the network. Most of the used internal data is not stored autonomously on a node, but it's rather shared in Hazelcast's distributed data structures.

This architecture of BEEN transformed the project into a fully distributed platform with high availability and scalability, while minimizing bottlenecks and the number of critical components.

### EverBEEN's Support for Regression Benchmarking {#user.poutput.regression}

<!-- TODO -->

BEEN's has been designed to cover both these use cases and still have only a single user-friendly API. The API for writing benchmarks is a unified mean to create and submit a benchmarkable item. Every benchmark consists of a user-written class which has a method `generateTaskContext`, which should return a new item to be benchmarked (called *task context*). When a benchmark doesn't have any item to submit, it can simply wait for an event (to support the push-oriented case). This method is called by the framework in a loop, so the benchmark can generate as many items as it wants. The benchmark can run indefinitely or it can mark itself as finished by returning `null` from the method. The BEEN cluster itself calls the method when it is capable of running a new item.

During the development, we have considered implementing a *descriptive language* that would specify which items are to be benchmarked. This would however only support the pull-oriented case and would require a different API for push-oriented benchmarking. The unified API offers unlimited flexibility, because the code that generates the benchmarkable items is written by the user.

This also means that the running benchmark can take the current (incomplete) results into account and modify the progress of the benchmark. E.g. this might be necessary to refine granularity of the benchmarked items when it detects an anomaly in the results.

For details about the API for writing tasks and benchmarks, see the [Task and Benchmark API](#user.taskapi) section.
