## EverBEEN services

### Host Runtime {#devel.services.hostruntime}
The Host Runtime is the service responsible for managing running tasks. It also functions as a gateway for its tasks and the rest of the framework.

The service was completely rewritten since the quality of the code was poor. The rewrite enabled the EverBEEN team to do necessary refactoring as well as to introduce libraries, such as [Apache Commons Exec](#devel.techno.exec) producing more modular and maintainable code.

Even though the service was completely rewritten the basic functions remain more or less the same compared to previous versions.

A Host Runtime can run on any type of a BEEN node <!-- TODO link to node types -->. It makes sense to run it on a *NATIVE* node in order not to incur costs associated with running a *DATA* node. Typically a deployment will have a few DATA nodes and as many NATIVE nodes with a Host Runtime as needed.

Available configuration options are listed in [Configuration](#uses.configuration)  

#### Host Runtime overview {#devel.services.hostruntime.overview}

Responsibilities of a Host Runtime include

* creating an environment for a task (working directory, environment properties, command line etc.)
* downloading BPKs from the Software Repository on behalf of a task
* running and managing a task (spawning a process, changing task's state, exit code, etc.)
* passing task's data to and from a task (logs, results, etc.)
* cleaning up after a task
* monitoring the host it runs on

Each Host Runtime manages only its tasks and doest not know nor care about the rest.

The implementation can be found in the *host-runtime* module within the `cz.cuni.mff.d3s.been.hostruntime` package.

#### Tasks management {#devel.services.hostruntime.management}

The Host Runtime interacts with the rest of the framework primarily by listening for messages (`HostRuntimeMessageListener`) through a distributed topic. Messages contain request which are dispatched to appropriate message handlers (`ProcessManager`).

A task begins its life on a Host Runtime with incoming `RunTaskMessage` message. The Host Runtime can either accept the task or return it to the Task Manager. In former case a complete environment is prepared and a new process is spawned (`task.TaskProcess`). This process includes:

* downloading task's BPK (`SoftwareResolver`)
* creating working directory and unpacking the BPK into it (`ProcessManager`)
* preparing environment properties and command line (`task.CmdLineBuilderFactory`)
 

The task is supervised in a separate thread, waiting either for the task to finish or an user generated request to abort it. The state changes are propagated through the TaskEntry structure associated with the task (`TaskHandle`).

#### Interaction with tasks {#devel.services.hostruntime.tasks}

Any output and communication of a task related to the framework must go through the Host Runtime, including:

* logs, output from standard output and standard error (`tasklogs.TaskLogHandler`)
* results, result queries
* task context related operations (Checkpoints, latches, etc.)

The communication protocol is based on [0MQ](#devel.techno.zmq) and messages are encoded in JSON. This allows to implement the [Task API](#user.taskapi) in different languages. The EverBEEN project currently implements extensive support for JVM based languages.

The output a of task is dispatched to appropriate destination with the help of Hazelcast distributed structures - the Host Runtime does not know how the output is processed it just know where to store it.

#### Task protocol {#devel.services.hostruntime.protocol}

Follows overview of the protocol between Host Runtime and a task. 

As was mentioned above the protocol is based on 0MQ with messages encoded in JSON format. 

A task in order to communicate with its Host Runtime must send appropriate messages through 0MQ ports - connection details are passed as environment properties, names of the properties are specified in `cz.cuni.mff.d3s.been.socketworks.NamedSockets`. How are messages encoded in JSON is responsibility of the [Task API](#user.taskapi) - the current implementation uses the [Jackson](#devel.techno.jackson) library to serialize/deserialize messages from/to *Plain Old Java Objects*.

There are currently four types of messages recognized by the framework. For the sake of brevity Java implementation classes are mentioned here. If the need for different implementation of the TASK API arises message, format can be inferred from them (direct mapping to JSON).  

<!-- TODO better format -->
LogMessages - *TaskLogs* - cz.cuni.mff.d3s.been.logging.LogMessage

Check Points - *TaskCheckpoints* - `cz.cuni.mff.d3s.been.task.checkpoints.CheckpointRequest`, request type specified by `cz.cuni.mff.d3s.been.task.checkpoints.CheckpointRequestType`

Results - *TaskResults* - `cz.cuni.mff.d3s.been.results.Result` along with `cz.cuni.mff.d3s.been.core.persistence.EntityID` wrapped in `cz.cuni.mff.d3s.been.core.persistence.EntityCarrier`  

Result queries - *TaskResultQueries* - `cz.cuni.mff.d3s.been.persistence.Query`



#### Host Runtime monitoring {#devel.services.hostruntime.management}
<!-- TODO -->
 
### Task Manager {#devel.services.taskmanager}
The Task Manager is at the heart of the EverBEEN framework, its responsibilities include:

* task scheduling
* context scheduling
* benchmark scheduling
* context state changes
* detection and correction of error states (benchmark failures, Host Runtimes failures, etc.)

Main characteristic:

* event-driven
* distributed
* redundant (in default configuration)

#### Distributed approach to scheduling   {#devel.services.taskmanager.distributed}

The most important characteristic of the Task Manger is that the computation is event-driven
and distributed among the *DATA* <!-- TODO link to types --> nodes. The implication
from such approach is that there is no central authority, bottleneck or single point
of failure. If a data node disconnects (or crashes) its responsibilities,along with
data, are transparently taken over by the rest of the cluster.

Distributed architecture is the major difference from previous versions
of the BEEN framework.

#### Implementation {#devel.services.taskmanager.implementation}
The implementation of the Task Manager is heavily dependent on [Hazelcast](#devel.techno.hazelcast)
distributed data structures and its semantics, especially the `com.hazelcast.core.IMap`.

#### Workflow {#devel.services.taskmanager.workflow}
The basic event-based workflow

 1. Receiving asynchronous Hazelcast event
 2. Generating appropriate message describing the event
 3. Generating appropriate action from the message
 4. Executing the action


Handling of internal messages is also message-driven, based on the [0MQ](#devel.techno.zmq)
library, somewhat resembling the Actor model. This has the advantage of separating
logic of message receiving and handling. Internal messages are executed in one thread,
which also removes the need for explicit locking and synchronization (which happens,
but is not responsibility of the Task Manager developer).


#### Data ownership {#devel.services.taskmanager.ownership}
An important notion to remember is that an instance of the Task Manager handles
only entries which it owns, whenever possible (e.g. task entries). Ownership of data
means that it is stored in local memory and the node is responsible for it.
The design of Task Manager takes advantage of the locality and most operations
are local with regard to data ownership. This is highly desirable for the Task Manger to scale.

#### Main distributed structures {#devel.services.taskmanager.structures}

* BEEN_MAP_TASKS - map containing runtime task information
* BEEN_MAP_TASK_CONTEXTS - map containing runtime context information
* BEEN_MAP_BENCHMARKS - map containing runtime context information

These distributed data structures are also backed by the [MapStore](#devel.services.mapstore)
(if enabled).

#### Task scheduling {#devel.services.taskmanager.tasks}
<!-- TODO reference task states -->

The Task Manager is responsible for scheduling tasks - finding a Host Runtime
on which the task can run. Description of possible restrictions can be found at
[Host Runtime] <!-- TODO should point to user documentation for Host Runtime? -->.

A [distributed query](http://hazelcast.com/docs/2.6/manual/single_html/#MapQuery)
is used to find suitable Host Runtimes, spreading the load among `DATA` nodes.

An appropriate Host Runtime is also chosen based on Host Runtime utilization, less
overloaded Host Runtimes are preferred. Among equal hosts a Host Runtime is chosen
randomly.

The lifecycle of a task is commenced by inserting a `cz.cuni.mff.d3s.been.core.task.TaskEntry`
into the task map with a random UUID as the key and in the SUBMITTED state <!-- TODO link -->.
Inserting a new entry to the map causes an event which is handled by the owner
of the key - the Task Manager responsible for the key. The event is
converted to the `cz.cuni.mff.d3s.been.manager.msg.NewTaskMessage` and sent
to the processing thread. The handling logic is separated in order not to block
the Hazelcast service threads. In this regard handling of messages is serialized on the particular
node. The message then generates `cz.cuni.mff.d3s.been.manager.action.ScheduleTaskAction`
which is responsible for figuring out what to do. Several things might happen

* the task cannot be run because it's waiting on another task, the state is changed to WAITING
* the task cannot be run because there is no suitable Host Runtime for it, the state is changed to WAITING
* the task can be scheduled on a chosen Host Runtime, the state is changed to SCHEDULED and the runtime is notified.

If the task is scheduled, the chosen Host Runtime is responsible for the task until it finishes or fails.

WAITING tasks are still responsibility of the Task Manager which can try
to reschedule when an event happen, e.g.:

 * another tasks is removed from a Host Runtime
 * a new Host Runtime is connected

#### Benchmark Scheduling {#devel.services.taskmanager.benchmarks}
Benchmark tasks are scheduled the same way as other tasks. The main difference is
that if a benchmark task fails (i.e. Host Runtime failure, but also programming error)
the framework can re-schedule the task on a different Host Runtime.


A problem can arise from re-scheduling an incorrectly written benchmark which fails
too often. There is a [configuration option](#user.configuration.taskmanager) which
controls how many re-submits to allow for a benchmark task.

Future implementation could deploy different heuristics to detect defective benchmark
tasks, such as failure-rate.


#### Context Handling {#devel.services.taskmanager.contexts}

Contexts are not scheduled as an entity on Host Runtimes as they are containers
for related tasks. The Task Manager handles detection of contexts state changes.
The state of a contexts is decided from the states of its tasks.

<!-- TODO this should (also) be in user documentation? -->
Task context states:

 * WAITING - for future use
 * RUNNING - contained tasks are running, scheduled or waiting to be scheduled
 * FINISHED - all contained tasks finished without an error
 * FAILED - at least one task from the context failed

Future improvements may include heuristics for scheduling contexts as an entity (i.e. detection
that the context can not be scheduled at the moment, which is difficult because of the
distributed nature of scheduling. Any information gathered might be obsolete by the time
its read).

#### Handling exceptional events {#devel.services.taskmanager.errors}

The current Hazelcast implementation (as of version 2.6) has one limitation.
When a key [migrates](http://hazelcast.com/docs/2.5/manual/single_html/#InternalsDistributedMap)
the new owner does not receive any event (`com.hazelcast.partition.MigrationListener` is not much useful
in this regard since it does not contain enough information). This might be a problem if e.g.
a node crashes and an event of type "new task added" is lost. To mitigate the problem
the Task Manager periodically scans (`cz.cuni.mff.d3s.been.manager.LocalKeyScanner`) its *local
keys* looking for irregularities. If it finds one it creates a message to fix it.

There are several situations this might happen:

* Host Runtime failure
* key migration
* cluster restart

Note that this is a safe net - most of the time the framework will receive an event
on which it can react appropriately (e.g. Host Runtime failed).

In the case of cluster restart there might be stale tasks which does not run anymore, but
the state loaded from the [MapStore](#devel.services.mapstore) is inconsistent. Such
situation will be recognized and corrected by the scan.

#### Hazelcast events {#devel.services.taskmanager.events}
These are main sources of cluter-wide events, received from Hazelcast:

* Task Events - `cz.cuni.mff.d3s.been.manager.LocalTaskListener`
* Host Runtime events - `cz.cuni.mff.d3s.been.manager.LocalRuntimeListener`
* Contexts events - `cz.cuni.mff.d3s.been.manager.LocalContextListener`

#### Task Manger messages {#devel.services.taskmanager.messages}
Main interface `cz.cuni.mff.d3s.been.manager.msg.TaskMessage`, messages are
created through the `cz.cuni.mff.d3s.been.manager.msg.Messages` factory.

Overview of main messages:

* `AbortTaskMessage`
* `ScheduleTaskMessage`
* `CheckSchedulabilityMessage`
* `RunContextMessage`

Detailed description is part of the source code nad Javadoc.


#### Task Manager actions {#devel.services.taskmanager.actions}
Main interface `cz.cuni.mff.d3s.been.manager.action.TaskAction`, actions are
created through the `cz.cuni.mff.d3s.been.manager.action.Action` factory.

Overview of actions

* `AbortTaskAction`
* `ScheduleTaskAction`
* `RunContextAction`
* `NullAction`

Detailed description is part of the source code and Javadoc.

#### Locking {#devel.services.taskmanager.locking}
<!-- TODO description -->



### Software Repository {#devel.services.swrepo}

From users perspective, the software repository is a black box to which you can upload and from which you can download standalone BPK packages with task, task context and benchmark definitions and sources and all interaction is done through web interface. 

From developers perspective, the architecture of software repository is based on file system storage and very simple message protocol over HTTP. 

Description of HTTP protocol:

* *get* **/bpk** - download BPK from software repository 
    * request header: **Bpk-Identifier**, value: cz.cuni.mff.d3s.been.bpk.BpkIdentifier (JSON), unique identifier of BPK to be downloaded
    * valid response status codes: **2XX**
    * response body: binary content of the requested BPK file
* *put* **/bpk** - upload BPK to software repository 
    * request header: **Bpk-Identifier**, value: cz.cuni.mff.d3s.been.bpk.BpkIdentifier (JSON), unique identifier of BPK to be uploaded
    * request body: binary content of the uploaded BPK file
    * valid response status codes: **2XX**
* *get* **/bpklist** - list all BPKs stored in software repository
    * valid response status codes: **2XX**
    * response body: java.util.List&lt;cz.cuni.mff.d3s.been.bpk.BpkIdentifier&gt; (JSON) 
* *get* **/tdlist** - list all task descriptors for BPK stored in software repository and identified by given BpkIdentifier 
    * request header: **Bpk-Identifier**, value: cz.cuni.mff.d3s.been.bpk.BpkIdentifier (JSON), unique identifier of BPK for which the list of available descriptors should be returned
    * valid response status codes: **2XX**
    * response body: java.util.Map&lt;java.lang.String, cz.cuni.mff.d3s.been.core.task.TaskDescriptor&gt; (JSON), key is task descriptor filename
* *get* **/tcdlist** - list all task context descriptors for BPK stored in software repository and identified by given BpkIdentifier 
    * request header: **Bpk-Identifier**, value: cz.cuni.mff.d3s.been.bpk.BpkIdentifier (JSON), unique identifier of BPK for which the list of available descriptors should be returned
    * valid response status codes: **2XX**
    * response body: java.util.Map&lt;java.lang.String, cz.cuni.mff.d3s.been.core.task.TaskContextDescriptor&gt; (JSON), key is task context descriptor filename

If response is marked with other than valid status code, standard HTTP response reason phrase will contain reason of the failure. For JSON serialization and deserialization is used ObjectMapper provided by [Jackson](#devel.techno.jackson) library.

We chose HTTP protocol because it is adapted for transfer of large files and is easy and use.   

Software repository stores uploaded BPKs in subdirectory **bpks** in SR working directory. Each uploaded bpk is stored in subfolder **GROUP_ID/BPK_ID/VERSION** under the name **BPK_ID-VERSION.bpk** where GROUP_ID stands for fully qualified groupId of BPK name where dots are replaced by slashes, BPK_ID stands for bpkId of BPK and VERSION stands for version of BPK. See following example for understanding directory structure.

```    
SR working directory (WD): 
    e.g. /home/been/swrepository on Linux systems
    e.g. C:\been\swrepository on Windows systems

BPK store directory: 
    {WD}/bpks
    
uploaded example BPK 1:
    filename: example.bpk
    groupId:  cz.cuni.mff.d3s.been.example
    bpkId:    example-bpk
    version:  1.1.beta-02
    
uploaded example BPK 2:
    filename: alpmexa.bpk
    groupId:  cz.cuni.mff.d3s.been.example
    bpkId:    alpmexa-bpk
    version:  0.1-SNAPSHOT

example BPK 1 will be stored in:
    {WD}/bpks/cz/cuni/mff/d3s/been/example/example-bpk/
                      1.1.beta-02/example-bpk-1.1.beta-02.bpk    
    
example BPK 2 will be stored in: 
    {WD}/bpks/cz/cuni/mff/d3s/been/example/alpmexa-bpk/0.1-SNAPSHOT/
                      alpmexa-bpk-0.1-SNAPSHOT.bpk    
```

Some limitations:

* Software repository does not support reuploading of already uploaded BPKs with same groupId, bpkId and version except BPKs with version suffixed by **-SNAPSHOT**
* You have to start software repository on node visible for all other nodes and on port which is not blocked by firewall.

*(You can find another directory called **artifacts** in software repository working directory. We intended to implement another type of files which can be stored. Imagine task which needs tons of resource files. Now, you have to store these resources directly in BPK package. And what if you want to upload newer task with different version but using the same resources? You have to store them again in the BPK. So this feature was intended to store shared resources between tasks, bat due to lack of time was not implemented.)*


### Software Repository cache {#devel.services.swrepocache}



### Object Repository {#devel.services.objectrepo}

The purpose of the *Object Repository* is to service user data persistence. While the actual persistence and querying code is isolated from the *Object Repository* by the [Storage](<!-- TODO javadoc link -->) interface module and is database-dependent (the default MongoDB implementation can be found in the `mongo-storage` module), the *Object Repository* operates without any knowledge of user types or concrete database storage implementation. The main portion of its work is to communicate with the rest of the EverBEEN cluster, collect objects sent by other nodes for persistence, collect queries from other nodes and dispatch answers. The communication with the rest of the cluster is realized through shared queues and maps (distributed cluster-wide memory).

The *Object Repository* also features a *Janitor* sub-service, which is responsible for cleaning up old data once it's deemed unnecessary. The *Janitor* works on its local *Storage* instance and therefore doesn't partake in any cluster-wide activities.

#### Queue drains

As mentioned above, the *Object Repository*'s communication with the rest of the EverBEEN cluster is mostly based on distributed queues. The *Object Repository* continuously drains these queues using special *consumer* threads (spawned dynamically based on load-balancing heuristics). This idea is revisited in both persist requests and querying.

#### Persist request queue

The object persisting mechanism is simple:

* A node serializes its object `o` ([Entity](<!-- TODO javadoc link -->)) into JSON. Let's call the resulting string `ojson`.
* The node creates an special wrapper ([EntityCarrier](<!-- TODO javadoc link -->)) which combines the serialized object with a destination id ([EntityID](<!-- TODO javadoc link -->)) - let's call the specific id instance `oid`.
* The wrapper, containing both `ojson` and `oid`, gets submitted into a distributed queue.
* A few moments later, an *Object Repository* drains the wrapper from the distributed queue.
* The repository unpacks the wrapper and passes both `ojson` and `oid` to its *Storage* implementation.
* The locating conventions of the *Storage* implementation are transparent to the *Object Repository*.

If the *Storage* implementation refuses to store `ojson` for any reason, the *Object Repository* resubmits the wrapper, containing `ojson` and `oid`, back to the shared queue to prevent data loss.

From the above principle, it is obvious that multiple *Object Repository* instances can operate concurrently, without a negative impact on data integrity or performance. The condition is, however, that all of the *Object Repository* instances be accessing either the same database, or that the databases so accessed have a full data-sharing policy of their own.

Persist requests in EverBEEN are asynchronous, and no notification is sent back after a persist is done. Although this approach may limit the user's knowledge about the current state of his data, it comes at a considerable advantage: The shared memory can function as a buffer through *Object Repository* disconnects. This enables a hassle-free means of reconfiguring the *Object Repository* if need be.

#### Query queue & Answer map

A similar approach regarding queues is taken for persistence layer queries. Just as serialized persistent objects do, queries get submitted to a distributed queue, where they wait for the *Object Repository* to process them. However, queries naturally need to provide an answer to the requesting party, so an object needs to be sent back. This is realized through a distributed map with listeners. To facilitate control flow for the requesting party, we made the query calls synchronous. The querying process is as follows:

* The requesting party creates a query.
* If the requesting party is a *task*, the query is serialized, sent to the corresponding *Host Runtime*, deserialized. The *Host Runtime* becomes the new requesting party while the *task* blocks in wait for an answer from the *Host Runtime*.
* The requesting party registers a listener on the query's ID in the distributed answer map.
* The requesting party submits the query to the distributed query queue.
* The requesting party blocks in wait for the answer to its query.
* Once the answer appears in the distributed answer map, the requesting party picks it up, removes it from the answer map and resumes processing.

Of course, such blocking behavior is prone to potential infinite waits in various corner-cases. To prevent that from happening, queries are subject to two types of timeout:

*Query timeout*
:	The requesting party only waits for this period of time for an answer to appear in the distributed answer map. If the answer doesn't appear in time, the requesting party attempts to cancel the query altogether by withdrawing it from the distributed query queue to prevent clotting the answer map with unused answers.

*Processing timeout*
:	If the answer doesn't appear in time, but the query can not be withdrawn from the distributed queue, it is assumed that an *Object Repository* instance has picked the query up, but did not yet process it. In such case, the requesting party waits for the *processing timeout* duration to give the *Object Repository* time to process the request. If the *Object Repository* responds within that interval, the answer it provided is returned normally. If the *processing timeout* is hit instead, a special timeout answer is returned instead.

Both of these timeouts are implemented on the client side to ensure that the requesting party always gets a valid answer or a timeout, even in case of unpredictable situations. Clearly, the maximum waiting time before the requesting party is guaranteed to receive an answer is `total_timeout = query_timeout + processing_timeout`.

For cases when the `total_timeout` is systematically being hit (as unlikely as they may be), there is a local eviction policy on answers submitted to the map, with `TTL = 5 * total_timeout`. That means answers submitted to the distributed answer map will be automatically deleted once the TTL expires.

#### Janitor
<!-- TODO description -->
Every instance of *Object Repository* has its own *Janitor* thread that periodically checks the *Storage* for old objects and removes them. To enable this kind of cleanup, EverBEEN stores some service entries about *task* and *context* states, which are deleted once the cleanup of all other entries related to that *task* or *context* has been performed. The cleanup rules are as follows:

* EverBEEN features two configurable TTL properties: `been.objectrepository.janitor.finished-longevity` and `been.objectrepository.janitor.failed-longevity`
* For successfully finished *tasks* and *contexts* past *finished longevity*, configurations (*descriptors*), results and evaluations thereof are kept, but service information (logs) are deleted
* For failed *tasks* and *contexts* past *failed longevity*, all entries are deleted

All of these deletes are implemented using queries similar to `DELETE FROM xyz AS o WHERE o.att='abcd'`, so even if multiple instances of *Janitor* are running and they all attempt to perform cleanup after the same *task* or *context*, the deletes do not result in failures.

There is a hypothetical case when the *Janitor component* performs a sweep which successfully deletes leftover information about a *task* or *context* and is followed by a persist of leftover data for that same *task* (*context*). This would mean that the late persisted object will never be deleted. It would take the following for this case to occur:

* Both the initial and terminal states of the *task* (*context*) get persisted, but some leftover data doesn't. That can happen due to a persist queue reorder (potentially due to a temporary *Storage* failure resulting in a requeue).
* *Object Repository* gets disconnected after the initial and terminal state has been drained, but before the late persisted object has been drained
* *Object Repository* doesn't get reconnected for at least `been.objectrepository.janitor.finished-longevity` (or `been.objectrepository.janitor.failed-longevity`, depending on the terminal state of the *task*/*context*), but keeps running (or gets restarted with a bad network configuration).

This case is not handled, mainly because the default values for both longevities are in the order of days, and it would take the user not noticing an invalid cluster configuration for this long.


### Map Store {#devel.services.mapstore}

The MapStore allows the EverBEEN to persist runtime information, which can
be restored after restart or crash of the framework.

#### Role of the MapStore {#devel.services.mapstore.role}

EverBEEN runtime information (such as tasks, contexts and benchmarks, etc.) are
persisted through the MapStore. This adds overhead to working with the distributed
objects, but allows restoring of the state after a cluster restart, providing an
user with more concise experience.

The implementation is build atop of Hazelcast Map Store - mechanism for storing/loading
of Hazelcast distributed objects to/from a persistence layer. The EverBEEN
team implemented a mapping to the MongoDB.

The main advantage of using the MapStore is transparent and easy access to Hazelcast
distributed structures with the ability to persist them - no explicit actions are
needed.

#### Difference between the MapStore and the Object repository {#devel.services.mapstore.difference}
Both mechanism are used to persist objects - the difference is in the type of objects
being persisted. The [Object repository](#devel.services.objectrepo) stores
user generated information, whereas the MapStore handles (mainly) BEEN runtime
information - information essential to proper working of the framework.

The difference is also in level of transparency for users. Object persistence
happens on behalf of an user explicit request, the MapStore works "behind the scene".

Even though both implementations currently us MongoDB, in future the team envisage
implementations serving different needs (such as load balancing, persistence
guarantees, data ownership, data access, etc.)

#### Extension point {#devel.services.mapstore.extension}
Adapting the layer to different persistence layer (such as relational database)
is relatively easy. By implementing the `com.hazelcast.core.MapStore` interface
and specifying the implementation to use at runtime, an user of the framework
has ability to change behavior of the layer.

#### Configuration {#devel.services.mapstore.configuration}
The layer can be configured to accommodate different needs:

* specify connection options (hostname, user, etc.)
* enable/disable
* change implementation
* write-through and write-back modes

Detailed description of configuration can be found at [Configuration](#user.configuration).

### Web Interface {#devel.services.webinterface}
* why it's not actually a service (but more like a client)
* cluster client connection mechanism
