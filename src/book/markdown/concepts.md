## Basic concepts
Before dwelling into the deployment process a few concepts must be explained. The concepts are explored and further explained in following chapters.


### BEEN services
A BEEN service is a component which carries out a particular function. Essential services include:

* Host Runtime - executes tasks
* Task Manager - schedules tasks
* Software Repository - serves packages
* Object Repository - provides persistence layer


### Tasks
A BEEN task is basic executable unit of the framework. Tasks are run on Host Runtimes.

Tasks are distributed in form of a package - which are called *BPK*s (from `BEEN package`). BPKs are uploaded to the Software Repository and are uniquely identified by *groupId*, *bpkId* and *version*.

*Task Descriptors* are XML files describing which package to use, where and how to run a task. Task Descriptors are submitted to a Task Manager which schedules it on a Host Runtime if possible.

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
:	Indicates that the task failed while running or cannot be run at all (for example bacause of a missing BPK).

### Contexts
BEEN contexts group together related tasks usually for achieving shared goal. 

Task context states:

 *RUNNING*
:	 Contained tasks are running, scheduled or waiting to be scheduled.

 *FINISHED*
:	All contained tasks finished without an error.

 *FAILED*
:	At least one task from the context failed

### Benchmarks

### Node types {#user.deployment.nodes.types}
In EverBEEN `node` is a program capable of running BEEN services. The node must be able to interact with other nodes through a computer network. Type of a node determines mechanism used to connect to other nodes. Since EverBEEN uses [Hazelcast](#devel.techno.hazelcast) as it means of connection nodes, types resemble those in Hazelcast. Currently two types are supported:

`DATA node`
:	Data nodes form a cluster which *share distributed data*. The cluster can be formed either through broadcasting or by directly connection nodes, see [Cluster Configuration](#user.configuration.cluster). The Task Manager service must be run on each DATA node (This requirement is enforced by the Node Runner). Be aware that DATA nodes incur overhead due to sharing data.

`NATIVE node`
:	Native nodes can be though of as cluster clients. They *do not* participate in sharing of distributed data and therefore do not incur overhead from it. NATIVE nodes connect directly to DATA nodes (failures are transparently handled). This also means that at all times at least one DATA node must be running in order for the framework to work. For configuration details see [Cluster Client Configuration](#user.configuration.client)  


Except of the Task Manager currently every other service can run on both types.

