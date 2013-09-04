## Basic concepts {#user.concepts}
Before dwelling into the deployment process a few concepts must be explained. The concepts are explored and further explained in the following chapters.


### BEEN services {#user.concepts.services}
An EverBEEN service is a component that runs indefinitely and processes requests. Essential services include:

* Host Runtime --- executes tasks
* Task Manager --- schedules tasks
* Software Repository --- serves packages
* Object Repository ---	 provides persistence layer


### Tasks {#user.concepts.tasks}
An EverBEEN task is a basic executable unit of the framework. Tasks are user written code which the framework runs on Host Runtimes.

Tasks are distributed in the form of package files called *BPK*s (from `BEEN package`). BPKs are uploaded to the Software Repository and are uniquely identified by *groupId*, *bpkId* and *version*.

*Task Descriptors* are XML files describing which package to use, where and how to run a task. Task Descriptors are submitted to a Task Manager which schedules and instantiates the task on a Host Runtime which meets user-defined constraints.

Tasks have states:

*CREATED*
:	Initial state of the task.

*SUBMITTED*
:	The state after the task is submitted to a Task Manager.

*ACCEPTED*
:	The state after a task is accepted on a Host Runtime to be run.

*RUNNING*
:	The state indicates that the task is running on a Host Runtime.

*FINISHED*
:	Indicates successful completion of the task.

*ABORTED*
:	Indicates that the task failed while running or cannot be run at all (for example because of a missing BPK).

### Contexts {#user.concepts.contexts}
EverBEEN contexts group related tasks to achieve a shared goal. Contexts are not runnable entities, their life cycle is derived from states of contained tasks. Contexts are described by *Task Context Descriptor* XML files.

Task context states:

 *RUNNING*
:	 Contained tasks are running, scheduled or waiting to be scheduled.

 *FINISHED*
:	All contained tasks finished without an error.

 *FAILED*
:	At least one task from the context failed.

### Benchmarks {#user.concepts.benchmarks}

Benchmark are user-written tasks with additional capabilities (in form of the *Benchmark API*). Benchmark tasks generate task contexts which are submitted to the framework.

### Results {#user.concepts.results}
Results are task generated objects representing certain values --- for example measured code characteristics.

### Evaluators {#user.concepts.evaluators}
Evaluators are special purpose tasks which generate *evaluator results* the framework knows how to interpret, for example a graph image.
 
### Node types  {#user.concepts.nodes} 
In EverBEEN `node` is a program capable of running BEEN services. The node must be able to interact with other nodes through a computer network. Type of a node determines the mechanism used to connect to other nodes. Since EverBEEN uses [Hazelcast](#devel.techno.hazelcast) as its means of connecting nodes, node types follow a design pattern from Hazelcast. Currently two types are supported:

`DATA node`
:	Data nodes form a cluster that *share distributed data*. The cluster can be formed either through broadcasting or by directly contacting existing nodes, see [Cluster Configuration](#user.configuration.cluster). The Task Manager service must be run on each DATA node (this requirement is enforced by the framework). Be aware that DATA nodes incur overhead due to sharing data.

`NATIVE node`
:	Native nodes can be though of as cluster clients. They *do not* participate in sharing of distributed data and therefore do not incur overhead from it. NATIVE nodes connect directly to DATA nodes (failures are transparently handled). This also means that at all times at least one DATA node must be running in order for the framework to work. For configuration details see [Cluster Client Configuration](#user.configuration.client)  


All services except the Task Manager can run on both node types.

