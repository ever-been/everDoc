## EverBEEN services

EverBEEN services are functional bundles run on cluster nodes in addition to the common core bundle. They are configured 'per-node' at boot time and define the node's role in the cluster.

### Host Runtime {#devel.services.hostruntime}
The Host Runtime is the service responsible for managing running tasks. It also functions as a gateway between its tasks and the rest of the framework.

The service was completely rewritten since the code quality was poor. The rewrite enabled the EverBEEN team to do necessary refactoring as well as to introduce libraries, such as [Apache Commons Exec](#devel.techno.exec) producing more modular and maintainable code.

Even though the service was completely rewritten, its purpose and basic functions remain similar to previous BEEN versions.

A Host Runtime can run on any type of [EverBEEN node](#user.concepts.nodes). It makes sense to run it on a *NATIVE* node in order to avoid costs associated with running a *DATA* node. Typically, deployment will have a few DATA nodes and as many NATIVE nodes with Host Runtime instances as needed.

Available configuration options are listed in the [Configuration](#user.configuration) chapter.

#### Host Runtime overview {#devel.services.hostruntime.overview}

Responsibilities of a Host Runtime include

* Task environment setup (working directory, environment properties, command line etc.).
* Downloading packages from the Software Repository (on a task's behalf).
* Running and managing a task (spawning a process, changing task's state, exit code, etc.).
* Mediating data transfer between tasks and the rest of the framework (logs, results, etc.).
* Cleanup after tasks.
* Monitoring the host it runs on.

Each Host Runtime manages only its own tasks -- it remains oblivious to the rest.

The implementation can be found in the *host-runtime* module within the `cz.cuni.mff.d3s.been.hostruntime` package.

#### Local task management {#devel.services.hostruntime.management}

The Host Runtime interacts with the rest of the framework primarily by listening for messages ([HostRuntimeMessageListener](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/hostruntime/HostRuntimeMessageListener.html) through a distributed topic. Messages contain requests which are dispatched to appropriate message handlers ([ProcessManager](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/hostruntime/ProcessManager.html)).

A task begins its life on a Host Runtime with incoming [RunTaskMessage](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/protocol/messages/RunTaskMessage.html) message. The Host Runtime can either accept the task or return it to the Task Manager. In former case a complete environment is prepared and a new process is spawned ([TaskProcess](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/hostruntime/task/TaskProcess.html)). This process includes:

* Downloading task BPK ([SoftwareResolver](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/hostruntime/SoftwareResolver.html))
* Creating a working directory and unpacking the BPK into it ([ProcessManager](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/hostruntime/ProcessManager.html))
* Preparing environment properties and command line ([CmdLineBuilderFactory](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/hostruntime/task/CmdLineBuilderFactory.html))
 

The task is supervised in a separate thread, waiting for the task to either finish or be aborted by a user generated request. Task state changes are propagated through the [TaskEntry](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/task/TaskEntry.html) structure associated with the given task through [TaskHandle](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/hostruntime/task/TaskHandle.html).

#### Interaction with tasks {#devel.services.hostruntime.tasks}

Any communication between a task and the rest of the framework is mediated by the task's Host Runtime. This includes:

* Logs, output from standard output and standard error ([TaskLogHandler](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/hostruntime/tasklogs/TaskLogHandler.html))
* Results, result queries
* Task context related operations (Checkpoints, latches, etc.)

The communication protocol is based on [0MQ](#devel.techno.zmq) and messages are encoded in JSON. This allows implementing the [Task API](#user.taskapi) in different languages. The EverBEEN project currently implements extensive support for JVM based languages.

The output a of task is dispatched to the appropriate destination through Hazelcast distributed structures. The Host Runtime routes this information to its correct destination, but is otherwise oblivious to how such data is actually processed.

#### Task protocol

Follows overview of the protocol between Host Runtime and a task. 

As was mentioned above the protocol is based on 0MQ with messages encoded in JSON format. 

A task must send appropriate messages through 0MQ ports in order to communicate with its Host Runtime. Connection details are passed as environment properties upon task process spawning. Names of these environment properties are specified in [NamedSockets](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/socketworks/NamedSockets.html). Message serialization to JSON is handled in the [Task API](#user.taskapi) -- the current implementation uses the [Jackson](#devel.techno.jackson) library to serialize/deserialize messages from/to *Plain Old Java Objects*.

There are currently four types of messages recognized by the framework. For the sake of brevity, Java implementation classes are mentioned here. If the need for different implementation of the TASK API arises the message format can be inferred from their direct mapping to JSON.


Log Messages - *TaskLogs* - `LogMessage`

Example message:

	LOG_MESSAGE#{
		"created":1378147630541,
		"taskId":"4b7c3169-7a30-4ca7-8ac1-ebb973ac0b4d",
		"contextId":"16f50281-0bb5-44d8-ab33-eea33e895b31",
		"benchmarkId":"",
		"message":{
			"name":"com.example.been.ExampleTask",
			"level":1,
			"message":"Mae govannen!",
			"errorTrace":null,
			"threadName":"main"
		}
	}

Notice that there currently is *LOG_MESSAGE#* before the actual message.

Check Points - *TaskCheckpoints* - [CheckpointRequest](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/task/checkpoints/CheckpointRequest.html) 

Examples of CheckPoint messages:

The first example shows the "Check Point Get" message: 

	{
		"selector":"checkpoint",
		"value":null,
		"timeout":0,
		"type":"GET",
		"taskId":"272028b5-9cba-4730-b672-385469efa7e3",
		"taskContextId":"ebbae46a-ad8f-4653-9225-49df327cb90e"
	}

The format is the same for all types of CheckPoint messages:

`selector`
:	name of the requested entity

`value`
:	string representation of value to be passed, applicable according to message type, e.g. value of a CheckPoint to set 

`timeout`
:	timeout in milliseconds of the request if applicable, zero means infinity

`type`
:	defines type of the request, supported types are to be found in [CheckpointRequestType](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/task/checkpoints/CheckpointRequestType.html)

`taskId`
:	taskId of the requesting task 

`taskContextId`
: task context id of the requesting entity

The response might look like this:

	{
		"replyType":"OK",
		"value":"42"
	}

`replyType`
:	it's either *OK* if operation succeeded or *ERROR* otherwise 

`value`
:	value returned from the operation, in case of ERROR reason why the operation failed

Here is the request for Count Down Latch wait with 1s timeout:

	{
		"selector":"example-latch",
		"value":null,
		"timeout":1000,
		"type":"LATCH_WAIT",
		"taskId":"272028b5-9cba-4730-b672-385469efa7e3",
		"taskContextId":"ebbae46a-ad8f-4653-9225-49df327cb90e"
	}

And the reply after the timeout occurred:

	{
		"replyType":"ERROR",
		"value":"TIMEOUT"
	}

See [CheckpointController](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/taskapi/CheckpointController.html) implementation details of other operations. 

Results - *TaskResults* - [Result](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/results/Result.html) along with [EntityID](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/persistence/EntityID.html) wrapped in [EntityCarrier](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/persistence/EntityCarrier.html)

Let us use following example result in Java:

	public class ExampleResult extends Result {
		public int data;
		public String name;

		/** Results must have non-parametric constructor.*/
		public ExampleResult() {}
	}


Example result corresponding to the Java class:

	{
		"created":1378149926777,
		"taskId":"1dc48ac8-8a7f-42aa-a57c-f38b8c449864",
		"contextId":"762187bb-448e-42ba-9c3e-421091553c58",
		"benchmarkId":"",
		"data":47
	}


`created`
:	is time when the result was created (UNIX time)

`taskId`, `contextId`, `benchmarkId`
: are IDs of the task

`data`
:	corresponds to the result's `data` field


Result queries - *TaskResultQueries* - [FetchQuery](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/persistence/FetchQuery.html)

Queries are a little complicated - since they allow filtering and selecting of data.

Example of a query

`Query query = new ResultQueryBuilder().on(GROUP_ID).with("taskId", getId()).with("name", "Name42").retrieving("data").fetch();`

The query is translated into

	{
		"@class":"cz.cuni.mff.d3s.been.persistence.FetchQuery",
		"id":"1ad39fd6-172a-47c7-908e-4acc1bb66414",
		"entityID":{
			"kind":"result",
			"group":"example-data"
	}, "selectors":{
			"taskId":{
				"@class":"cz.cuni.mff.d3s.been.persistence.EqAttributeFilter",
				"values":{
					"@eq":"e1df89e9-b893-4099-ad21-f1eb5291a48b"
				}
			},"name":{
				"@class":"cz.cuni.mff.d3s.been.persistence.EqAttributeFilter",
				"values":{
					"@eq":"Name42"
				}
			}
		},
		"mappings":["data"]
	}

The `@class` fields are a bit unfortunate since they refer to Java implementation classes. We acknowledge this as awkward, yet necessary -- the Jackson deserializer to recognize the proper runtime type for unmarshalling.

The details of note are:

* The specification of [EntityID](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/persistence/EntityID.html)
* Selectors which filter fields
* Mappings which select which fields to fetch.

The `mappings` field is a JSON array of attribute names that should be retrieved from the persistence layer. The resulting data will only contain these fields. This feature is primarily intended for saving network traffic by limiting queries to minimal necessary information.


The `selectors` field is a JSON map containing *filters* identified by retrieved object attribute names. The filters can be any of the following:

@class                                  expected attributes                       meaning
----------------------                  ---------------------                     ----------
EqAttributeFilter                       @eq                                       `v == @eq`
NotEqAttributeFilter                    @eq                                       `v != @eq`
PatternAttributeFilter                  @like                                     `v` matches the pattern in `@like`
IntervalAttributeFilter                 @lo                                       `v >= @lo`
                                        @hi                                       `v < @hi`
                                        @lo, @hi                                  `@lo <= v < @hi`

In the above table, `v` represents the value of the filtered attribute. All the mentioned classes are taken from the `cz.cuni.mff.d3s.been.persistence` package, so their fully qualified name needs to be prefixed accordingly. For the sake of implementation simplicity, the number of filters is limited to one per attribute.

Results might look something like this:

	{
		"@class":"cz.cuni.mff.d3s.been.persistence.DataQueryAnswer",
		"status":"OK",
		"objects":[
			"{ \"data\" : 42}"
		]
	}

Notice that `object` is an array of returned entities.


#### Host Runtime monitoring {#devel.services.hostruntime.monitoring}
Monitoring samples are taken through the [Sigar library](#devel.techno.sigar) which uses native libraries to gather system information. The period of sampling is [configurable](#user.configuration.monitoring). Samples are persisted through the Object Repository.

In case Sigar native library is not available for a platform (as is currently the case for FreeBSD 8 and later) Java fallback is provided. The Java implementation does not supply as much information as Sigar does (the striking example is information about system free memory which cannot be obtained, as far as we know, directly from Java standard libraries).
 
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

The most important characteristic of the Task Manger is that the computation is event-driven and distributed among the *DATA*  nodes. The implication from such approach is that there is no central authority, bottleneck or single point of failure. If a data node disconnects (or crashes), its responsibilities (along with related data) are transparently taken over by the rest of the cluster.

Distributed architecture is the major difference from previous versions of the BEEN framework.

#### Implementation {#devel.services.taskmanager.implementation}
The implementation of the Task Manager is heavily dependent on [Hazelcast](#devel.techno.hazelcast) distributed data structures and its semantics, especially the [`com.hazelcast.core.IMap`](http://www.hazelcast.com/javadoc/com/hazelcast/core/IMap.html).

#### Workflow {#devel.services.taskmanager.workflow}
The basic event-based work flow:

 1. Receive asynchronous Hazelcast event
 2. Generate appropriate message describing the event
 3. Generate appropriate action from the message
 4. Execute the action


Internal message handling is also message-driven, based on the [0MQ](#devel.techno.zmq) library, somewhat resembling the Actor model. The advantage resides in separating message reception and deserialization from actual handling logic. Internal messages are executed in one thread, which also removes the need for explicit locking and synchronization (which happens, but is not responsibility of the Task Manager developer). A more detailed description of the *message/action* is a part of the source code and associated [JavaDoc](http://www.everbeen.cz/javadoc/everBeen/index.html), and can be found in the `cz.cuni.mff.d3s.been.manager.msg` and `cz.cuni.mff.d3s.been.manager.action` packages.

#### Data ownership {#devel.services.taskmanager.ownership}
An important concept to remember is that an instance of the Task Manager only handles entries it owns whenever possible (e.g. task entries). Data ownership means that the object in question is stored in local memory and the node is responsible for it. The design of Task Manager takes advantage of the locality and most operations are local with regard to data ownership. This approach is highly desirable for the Task Manger to scale.

#### Main distributed structures {#devel.services.taskmanager.structures}

* BEEN_MAP_TASKS - map containing runtime task information
* BEEN_MAP_TASK_CONTEXTS - map containing runtime context information
* BEEN_MAP_BENCHMARKS - map containing runtime context information

These distributed data structures are also backed by the [MapStore](#devel.services.mapstore) (enabled by default).

#### Task scheduling {#devel.services.taskmanager.tasks}
The following section discusses task states, which are described in detail in ["Basic concepts"](#user.concepts.tasks) section of the user manual.

The Task Manager is responsible for scheduling tasks, which boils down to finding a Host Runtime on which the task can run. The description of possible restrictions can be found in the [Host Runtime](#devel.services.hostruntime) section.

A [distributed query](http://hazelcast.com/docs/2.6/manual/single_html/#MapQuery) is used to find suitable Host Runtimes, spreading the load among `DATA` nodes.

An appropriate Host Runtime is also chosen based on Host Runtime utilization, less loaded Host Runtimes are preferred. Among equal hosts a Host Runtime is chosen randomly.

The lifecycle of a task is commenced by inserting a [TaskEntry](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/task/TaskEntry.html) in `SUBMITTED` state into the task map under a random key. Inserting a new entry to the map causes an event which is handled by the owner of the key --- the Task Manager responsible for the key. The event is converted to a [`NewTaskMessage`](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/manager/msg/NewTaskMessage.html) object and sent to the processing thread. The handling logic is separated in order not to block the Hazelcast service threads. In this regard, message handling is serialized on the particular node. The message then generates [`ScheduleTaskAction`](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/manager/action/ScheduleTaskAction.html), which is responsible for figuring out what to do. Several things might happen 

* the task cannot be run because it's waiting on another task, the state is changed to WAITING
* the task cannot be run because there is no suitable Host Runtime for it, the state is changed to WAITING
* the task can be scheduled on a chosen Host Runtime, the state is changed to SCHEDULED and the runtime is notified. 

If the task is accepted the chosen Host Runtime is responsible for the task until it finishes or fails.

`WAITING` tasks remain under the responsibility of the Task Manager, which can try to reschedule when an event occurs, e.g.:

 * another tasks is removed from a Host Runtime
 * a new Host Runtime is connected

#### Benchmark Scheduling {#devel.services.taskmanager.benchmarks}

Benchmark tasks are scheduled in the same fashion as other tasks. The main difference is that if a benchmark task fails (host failure, programming error, etc.), the framework can re-schedule the task on a different Host Runtime.

A problem can arise from re-scheduling an incorrectly written benchmark which fails too often. There is a [configuration option](#user.configuration.taskmanager) which limits how many re-submits are allowed for a benchmark task.


#### Context Handling {#devel.services.taskmanager.contexts}

Contexts are not scheduled as an entity on Host Runtimes, as they are mere containers for related tasks. The Task Manager handles detection of contexts state changes. The state of a contexts is decided from the states of its tasks.

Possible task context states:

 * WAITING -- for future use
 * RUNNING -- contained tasks are running, scheduled or waiting to be scheduled
 * FINISHED -- all contained tasks finished without an error
 * FAILED -- at least one task from the context failed

Future improvements may include heuristics for scheduling contexts as an entity (i.e. detection that the context can not be scheduled at the moment), which is difficult because of the distributed nature of scheduling -- any information gathered might be obsolete by the time it is read.

#### Handling exceptional events {#devel.services.taskmanager.errors}

The current Hazelcast implementation (as of version 2.6) has one limitation. When a key [migrates](http://hazelcast.com/docs/2.5/manual/single_html/#InternalsDistributedMap) the new owner does not receive any event ([com.hazelcast.partition.MigrationListener](http://www.hazelcast.com/javadoc/com/hazelcast/partition/MigrationListener.html) is not very useful in this regard, since it does not contain enough information). This might be a problem, for example when a node crashes and an event of type "new task added" is lost. To mitigate the problem the Task Manager periodically scans ([LocalKeyScanner](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/manager/LocalKeyScanner.html)) its *local keys* looking for irregularities. If an anomaly is found, a message is created to remedy the problem.

There are several situations where similar problems might arise:

* Host Runtime failure
* Key migration
* Cluster restart

Note that the `LocalKeyScanner` solution is mainly a safety net -- most of the time the framework will receive an event on which it can react appropriately (e.g. Host Runtime failed).

In the case of cluster restart, there might be stale tasks which do not run anymore. In such cases, the task state information loaded from the [MapStore] (#devel.services.mapstore) will be inconsistent. Such situation are recognized and corrected by the scan.

#### Hazelcast events {#devel.services.taskmanager.events}
These are main sources of cluster-wide events, received from Hazelcast:

* Task Events -- in [LocalTaskListener](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/manager/LocalTaskScanner.html)
* Host Runtime events -- in [LocalRuntimeListener](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/manager/LocalRuntimeScanner.html)
* Contexts events -- in [LocalContextListener](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/manager/LocalContextScanner.html)

#### Locking {#devel.services.taskmanager.locking}

Certain EverBEEN objects are possibly concurrently modified by different services (and possibly different nodes). One of such objects is the `TaskEntry`, which is accessed by both a Task Manager and a Host Runtime. Unfortunately, such cases must be be resolved through the usage of distributed Hazelcast locks. Such locking costly, so we tried to avoid it on performance critical paths. Moreover, the number of parties trying to obtain the lock is never high. In the case of `TaskEntry`, concurrent accesses are attempted by one Host Runtime and at most two Task Manager instances (two in case of a key migration), and the locks are owned by the task's current Task Manager.

The recently released Hazelcast 3.0 introduced the [Entry Processor](http://hazelcast.com/docs/3.0/manual/single_html/#MapEntryProcessor) feature that could help improve throughput, should the need arise.


### Software Repository {#devel.services.swrepo}

From users perspective, the software repository is a black box to which you can upload and from which you can download standalone BPK packages with task, task context and benchmark definitions and sources and all interaction is done through web interface. 

From developers perspective, the architecture of software repository is based on file system storage and very simple message protocol over HTTP. 

Description of HTTP protocol:

* *get* **/bpk** - download BPK from software repository 
    * request header: `Bpk-Identifier`, value: [cz.cuni.mff.d3s.been.bpk.BpkIdentifier](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/bpk/BpkIdentifier.html) (JSON), unique identifier of BPK to be downloaded
    * valid response status codes: *2XX*
    * response body: binary content of the requested BPK file
* *put* **/bpk** - upload BPK to software repository 
    * request header: `Bpk-Identifier`, value: `BpkIdentifier` (JSON), unique identifier of BPK to be uploaded
    * request body: binary content of the uploaded BPK file
    * valid response status codes: *2XX*
* *get* **/bpklist** - list all BPKs stored in software repository
    * valid response status codes: *2XX*
    * response body: `List<BpkIdentifier>` (JSON) 
* *get* **/tdlist** - list all [task descriptors](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/task/TaskDescriptor.html) for BPK stored in software repository and identified by given `BpkIdentifier` 
    * request header: `Bpk-Identifier`, value: `BpkIdentifier` (JSON), unique identifier of BPK for which the list of available descriptors should be returned
    * valid response status codes: *2XX*
    * response body: `Map<String, TaskDescriptor>` (JSON), key is task descriptor filename
* *get* **/tcdlist** - list all [task context descriptors](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/task/TaskContextDescriptor.html) for BPK stored in software repository and identified by given `BpkIdentifier` 
    * request header: `Bpk-Identifier`, value: `BpkIdentifier` (JSON), unique identifier of BPK for which the list of available descriptors should be returned
    * valid response status codes: *2XX*
    * response body: `Map<String, TaskContextDescriptor>` (JSON), key is task context descriptor filename

If response is marked with other than valid status code, standard HTTP response reason phrase will contain reason of the failure. For JSON serialization and deserialization is used ObjectMapper provided by [Jackson](#devel.techno.jackson) library.

We chose HTTP protocol because it is adapted for transfer of large files and is easy to use.   

Software repository stores uploaded BPKs in `bpks` subdirectory of SR working directory. Each uploaded BPK is stored in subfolder `{groupId}/{bpkId}/{version}` under the name `{bpkId}-{version}.bpk` where *{groupId}* stands for fully qualified groupId of BPK name where dots are replaced by slashes, *{bpkId}* stands for bpkId of BPK and *{version}* stands for version of BPK. Follows example of the directory structure:

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


### Software Repository client {#devel.services.swrepocache}

Because some BPKs can be used multiple times on single host runtime, each host runtime has its own software repository cache. This cache uses same file store as software repository and saves bandwidth and I/O resources.



### Object Repository {#devel.services.objectrepo}

The purpose of the *Object Repository* is to service user data persistence. While the actual persistence and querying code is isolated from the *Object Repository* by the [Storage](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/storage/Storage.html) interface module and is database-dependent (the default MongoDB implementation can be found in the `mongo-storage` module), the *Object Repository* operates without any knowledge of user types or concrete database storage implementation. The main portion of its work is to communicate with the rest of the EverBEEN cluster, collect objects sent by other nodes for persistence, collect queries from other nodes and dispatch answers. The communication with the rest of the cluster is realized through shared queues and maps (distributed cluster-wide memory).

The *Object Repository* also features a *Janitor* sub-service, which is responsible for cleaning up old data once it's deemed unnecessary. The *Janitor* works on its local *Storage* instance and therefore doesn't partake in any cluster-wide activities.

#### Queue drains

As mentioned above, the *Object Repository*'s communication with the rest of the EverBEEN cluster is mostly based on distributed queues. The *Object Repository* continuously drains these queues using special *consumer* threads (spawned dynamically based on load-balancing heuristics). This idea is revisited in both persist requests and querying.

#### Persist request queue

The object persisting mechanism is simple:

* A node serializes its object `o` ([Entity](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/persistence/Entity.html)) into JSON. Let's call the resulting string `ojson`.
* The node creates an special wrapper ([EntityCarrier](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/persistence/EntityCarrier.html)) which combines the serialized object with a destination id ([EntityID](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/core/persistence/EntityID.html)) - let's call the specific id instance `oid`.
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

* EverBEEN features two configurable TTL properties:
    * `been.objectrepository.janitor.finished-longevity`
    * `been.objectrepository.janitor.failed-longevity`
* For successfully finished *tasks* and *contexts* past *finished longevity*, configurations (*descriptors*), results and evaluations thereof are kept, but service information (logs) are deleted
* For failed *tasks* and *contexts* past *failed longevity*, all entries are deleted

All of these deletes are implemented using queries similar to `DELETE FROM xyz AS o WHERE o.att='abcd'`, so even if multiple instances of *Janitor* are running and they all attempt to perform cleanup after the same *task* or *context*, the deletes do not result in failures.

There is a hypothetical case when the *Janitor component* performs a sweep which successfully deletes leftover information about a *task* or *context* and is followed by a persist of leftover data for that same *task* (*context*). This would mean that the late persisted object will never be deleted. It would take the following for this case to occur:

* Both the initial and terminal states of the *task* (*context*) get persisted, but some leftover data doesn't. That can happen due to a persist queue reorder (potentially due to a temporary *Storage* failure resulting in a requeue).
* *Object Repository* gets disconnected after the initial and terminal state has been drained, but before the late persisted object has been drained
* *Object Repository* doesn't get reconnected for at least  
`been.objectrepository.janitor.finished-longevity`  
(or `been.objectrepository.janitor.failed-longevity`, depending on the terminal state of the *task*/*context*), but keeps running (or gets restarted with a bad network configuration).

This case is not handled, mainly because the default values for both longevities are in the order of days, and it would take the user not noticing an invalid cluster configuration for this long.


### Map Store {#devel.services.mapstore}

The MapStore allows the EverBEEN to persist runtime information, which can be restored after restart or crash of the framework.

#### Role of the MapStore {#devel.services.mapstore.role}

EverBEEN runtime information (such as tasks, contexts and benchmarks, etc.) are persisted through the MapStore. This adds overhead to working with the distributed objects, but allows restoring of the state after a cluster restart, providing an user with more concise experience.

The implementation is build atop of Hazelcast Map Store - mechanism for storing/loading of Hazelcast distributed objects to/from a persistence layer. The EverBEEN team implemented a mapping to the MongoDB.

The main advantage of using the MapStore is transparent and easy access to Hazelcast distributed structures with the ability to persist them - no explicit actions are needed.

#### Difference between the MapStore and the Object repository {#devel.services.mapstore.difference}
Both mechanism are used to persist objects - the difference is in the type of objects being persisted. The [Object repository](#devel.services.objectrepo) stores user generated information, whereas the MapStore handles (mainly) EverBEEN runtime information - information essential to proper working of the framework. 

The difference is also in level of transparency for users. Object persistence happens on behalf of an user explicit request, the MapStore works "behind the scene".

Even though both implementations currently us MongoDB, in future the team envisage implementations serving different needs (such as load balancing, persistence guarantees, data ownership, data access, etc.)

#### Extension point {#devel.services.mapstore.extension}
Adapting the layer to different persistence layer (such as relational database) is relatively easy. By implementing the `com.hazelcast.core.MapStore` interface and specifying the implementation to use at runtime, an user of the framework has ability to change behavior of the layer.

#### Configuration {#devel.services.mapstore.configuration}
The layer can be configured to accommodate different needs:

* specify connection options (hostname, user, etc.)
* enable/disable
* change implementation
* write-through and write-back modes

Detailed description of configuration can be found at [Configuration](#user.configuration).

### Web Interface {#devel.services.webinterface}
Web interface is sophisticated utility to monitor and control the EverBEEN cluster. It is not actually a real service but rather a standalone client, nevertheless it is an indispensable part of the framework. Implementation is based on [Tapestry5](http://tapestry.apache.org/) framework and its extension [Tapestry5-jquery](http://tapestry5-jquery.com/). Describing the principles and conventions of Tapestry framework is not part of the EverBEEN documentation but it can be found on the framework official site. We would like to include only few information which could be helpful when extending the web interface.

#### Dependency Injection
Tapestry uses its own implementation of dependency injection container called Tapestry IoC (Inversion of Control) – this container is responsible for managing dependencies among pages, components, services and other parts of the application. Tapestry has several of its own services and we added two more. First, the most important, is [`BeenApiService`](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/web/services/BeenApiService.html) which is responsible for connecting to the cluster. The second service is [`LiveFeedService`](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/web/services/LiveFeedService.html) which is responsible for communication with web browsers through web sockets. When defined, these services are fully integrated to the whole Tapestry web application life cycle and can be injected to pages and components through standard Tapestry annotations.

#### Pages and Components
All pages are inherited from base [`Page`](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/web/pages/Page.html) class. This class contains injected `BeenApiService` from which you can obtain instance of [BeenApi](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/api/BeenApi.html) through which you can manage the whole EverBEEN cluster. Global layout is defined by [`Layout`](http://www.everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/web/components/Layout.html) component and all JavaScript and CSS can be found in `src/main/webapp` subdirectory of `web-interface` module.

#### Connecting WI to the cluster
Web interface is connected to the cluster using Hazelcast native client. It means that the WI does not store any data and does not manage any keys of Hazelcast maps.
