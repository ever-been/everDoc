## Task and Benchmark API {#user.taskapi}

One of the main goals of the EverBEEN project was to make the task API as simple as possible and to minimize the amount of work needed to create a benchmark.

EverBEEN works with three concepts of user-supplied code and configuration:

* **Task**, is an elementary unit of code that can be submitted to and run by EverBEEN. Tasks are created by subclassing the abstract `Task` class and implementing appropriate methods. Each task has to be described by a XML **task descriptor** which specifies the main class to run and parameters of the task.

* **Task context** is a container for multiple tasks. Containers can interact, pass data to each other and synchronize among themselves. Tasks contexts do not contain any user-written code, they only serve as wrappers for the contained tasks. Each task context is described by a XML **task context descriptor** that specifies which tasks should be contained within the context.

* **Benchmark** is a first-class object that *generates* task contexts based on its **generator task**, which is again a user-written code created by subclassing the abstract `Benchmark` class. Each benchmark is described by a XML **benchmark descriptor** which specifies the main class to run and parameters of the benchmark. A benchmark is different from a task, because its API provides features for generating task contexts and it can also persist its state so it can be re-run when an error occurs and the generator task fails.

All these three concepts can be submitted to EverBEEN and run individually, e.g. if you only want to test a single task, you can submit it without providing a task context or benchmark.

### Maven Plugin and Packaging {#user.bpkplugin}

The easiest way to create a submittable item (e.g. a task) is by creating a Maven project and adding a dependency on the appropriate EverBEEN module (e.g. `task-api`) in the `pom.xml` of the project:

	<dependency>
		<groupId>cz.cuni.mff.d3s.been</groupId>
		<artifactId>task-api</artifactId>
		<version>3.0.0-SNAPSHOT</version>
	</dependency>

Tasks, contexts and benchmark must be packaged into a BPK file, which can then be uploaded to EverBEEN. Each BPK package can contain multiple submittable items and multiple XML descriptors. The problem of packaging is made easier by the supplied `bpk-maven-plugin` Maven plugin. The preferred way to use it is to add the plugin to the `package` Maven goal in `pom.xml` of the project:

	<plugin>
		<groupId>cz.cuni.mff.d3s.been</groupId>
		<artifactId>bpk-maven-plugin</artifactId>
		<version>1.0.0-SNAPSHOT</version>
		<executions>
			<execution>
				<goals>
					<goal>buildpackage</goal>
				</goals>
			</execution>
		</executions>
		<configuration>
			...
		</configuration>
	</plugin>

In the plugin's configuration the user must specify at least one descriptor of a task, context or benchmark. To add a descriptor into the BPK, it should be added as a standard Java resource file and then referenced in the plugin configuration by using a `<taskDescriptors>` or `<taskContextDescriptors>` element. For example, the provided sample benchmark called `nginx-benchmark` uses this configuration:

	<configuration>
		<taskDescriptors>
			<param>src/main/resources/cz/cuni/mff/d3s/been/nginx/NginxBenchmark.td.xml</param>
		</taskDescriptors>
	</configuration>

This specifies that the package should publish a single descriptor named `NginxBenchmark.td.xml` which is located in the specified resource path. With such a configuration, creating the BPK package is simply a matter of invoking `mvn package` on the project --- it will produce a `.bpk` file that can be uploaded to EverBEEN.

#### Maven repositories

Maven repositories are available. Put the following declarations into the `pom.xml` to transparently resolve dependencies:


	<pluginRepositories>
		<pluginRepository>
			<id>everbeen.cz-plugins-snapshots</id>
			<url>http://everbeen.cz/artifactory/plugins-snapshot-local</url>
		</pluginRepository>
	</pluginRepositories>

	<repositories>
		<repository>
			<id>everbeen.cz-snapshots</id>
			<url>http://everbeen.cz/artifactory/libs-snapshot-local</url>
		</repository>
	</repositories>

The current version of the `bpk-maven-plugin` is `1.0.0-SNAPSHOT`.

### Descriptor Format {#user.taskapi.descriptors}

There are two types of descriptors, task descriptors and task context descriptors. Note that benchmarks don't have a special descriptor format, instead you only provide a task descriptor for a generator task of the benchmark. These descriptors are written in XML and they must conform to the supplied XSD definitions ([task-descriptor.xsd](http://www.everbeen.cz/xsd/task-descriptor.xsd) and [task-context-descriptor.xsd](http://www.everbeen.cz/xsd/task-context-descriptor.xsd)).

The recommended naming practice is to name your task descriptors with the filename ending with `.td.xml` and your task context descriptors ending with `.tcd.xml`.

A simple task descriptor for a single task can look like this:

	<?xml version="1.0"?>
	<taskDescriptor xmlns="http://been.d3s.mff.cuni.cz/task-descriptor"
					groupId="my.sample.benchmark" bpkId="hello-world" version="3.0.0-SNAPSHOT"
					name="hello-world-task" type="task">
		<java>
			<mainClass>my.sample.benchmark.HelloWorldTask</mainClass>
		</java>
	</taskDescriptor>

It specifies the main class and package that should be used to run the task. Apart from this, you can specify what parameters the task should receive and their default values:

	<properties>
		<property name="key">value</property>
	</properties>

These properties will be presented to the user in the web interface before submitting the task and the user can modify them. Next, you can specify command line arguments passed to Java:

	<arguments>
		<argument>-Xms4m</argument>
		<argument>-Xmx8m</argument>
	</arguments>

For debugging purposes, you can specify the `<debug>` element which will enable remote debugging when running the task (also available from the Web Interface).
 
#### Host Runtime selection {#user.taskapi.descriptors.selection}

With the `<hostRuntimes>` element you can constrain the Host Runtimes the task can be run on. The value of this setting is an expression in [XML Path Language (XPath) Version 1.0](http://www.w3.org/TR/xpath).

The most useful options for host selection are presented here. For full specification see [runtime-info.xsd](http://www.everbeen.cz/xsd/runtime-info.xsd), [hardware-info.xsd](http://www.everbeen.cz/xsd/hardware-info.xsd), [monitor.xsd](http://www.everbeen.cz/xsd/monitor.xsd)

*Basic Information about a Host Runtime*

	/id
	/port
	/host
	
*Java runtime specification*

	/java/version
	/java/vendor
	/java/runtimeName
	/java/VMVersion
	/java/VMVendor
	/java/runtimeVersion
	/java/specificationVersion

*Operation system information*

	/operatingSystem/name
	/operatingSystem/version
	/operatingSystem/arch
	/operatingSystem/vendor
	/operatingSystem/vendorVersion
	/operatingSystem/dataModel
	/operatingSystem/endian

*CPU information* (there can be multiply CPUs)

	/hardware/cpu/vendor
	/hardware/cpu/model
	/hardware/cpu/mhz
	/hardware/cpu/cacheSize

*File system information* (there can be multiply file systems)

	/filesystem/deviceName
	/filesystem/directory
	/filesystem/type
	/filesystem/free
	/filesystem/total


*Network information* (there can be multiply network interfaces)

	/hardware/networkInterface/name
	/hardware/networkInterface/hwaddr
	/hardware/networkInterface/type
	/hardware/networkInterface/mtu
	/hardware/networkInterface/netmask
	/hardware/networkInterface/broadcast
	/hardware/networkInterface/address

*Main memory information*

	/hardware/memory/ram
	/hardware/memory/swap

*Examples*

The following example will select the Host Runtime with host name `eduroam40.ms.mff.cuni.cz`.

	<hostRuntimes>
		<xpath>host = "eduroam40.ms.mff.cuni.cz"</xpath>
	</hostRuntimes>


	<hostRuntimes>
		<xpath>//networkInterface[address = "195.113.16.40"]</xpath>
	</hostRuntimes>

Selects the Host Runtime with an IPv4 address of `195.113.16.40`.

	<hostRuntimes>
		<xpath>/hardware/networkInterface[contains(address,"195.113.16")]</xpath>
	</hostRuntimes>

Selects all Host Runtimes whose IP address contains "195.113.16".

	<hostRuntimes>
		<xpath>contains(/operatingSystem/name, "Linux")</xpath>
	</hostRuntimes>

Selects all Linux operating systems.

Selection expression can be tested on the `runtime/list` page in the Web Interface.

### Task API {#user.taskapi.api}

To create a task submittable into EverBEEN, you should start by subclassing the [`Task`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/taskapi/Task.html) abstract class. The `run` method needs to be overridden.

EverBEEN uses [SLF4J](http://www.slf4j.org/) as its logging mechanism and provides a logging backend for all user-written code. This means that you can simply use the standard loggers and any logs will be automatically stored through EverBEEN.

Knowing this, the simplest task that will only log a message looks like this:

	package my.sample.benchmark;

	import cz.cuni.mff.d3s.been.taskapi.Task;
	import org.slf4j.Logger;
    import org.slf4j.LoggerFactory;

	public class HelloWorldTask extends Task {
		private static final Logger log = LoggerFactory.getLogger(HelloWorldTask.class);

		@Override
		public void run(String[] args) {
			log.info("Hello, world!");
		}
	}

If this class is in a Maven project as described in the [\ref*{user.bpkplugin} (Maven Plugin and Packaging)](#user.bpkplugin) section, it can be packaged into a BPK package by invoking `mvn package`. This package can be uploaded and run from the Web Interface.

BEEN provides several APIs for user-written tasks:

* *Properties* --- Tasks are configurable either from their descriptors or by the benchmark that generated them. These properties are again configurable by the user before submitting the task. All properties have a name and a simple string value and these can be accessed via the `getTaskProperty` method of the abstract `Task` class.

* *Result storing* --- Each task can persist a result that it has gathered by using the API providing access to the persistence layer. To store a result, use a `Persister` object, which can be created by using the method `createResultPersister` from the `Task` abstract class.

* *Synchronization and communication* --- When multiple tasks run in a task context, they can interact with each other either for synchronization purposes or to exchange data. API is provided by the [`CheckpointController`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/taskapi/CheckpointController.html) class. EverBEEN provides the concepts of **checkpoints** and **latches**. Latches serve as context-wide atomic numbers with the methods for setting a value, decreasing the value by one and waiting until the latch reaches zero. Checkpoints are also waitable objects that store a value.

### Task Properties {#user.taskapi.properties}

Every task has a key-value property storage. These properties can be set from various places: From the XML descriptor, from user input when submitting, inherited from a task context or set from a benchmark when it generates a task context. To access these values, you can use the `getTaskProperty` method of the `Task` class:

	int numberOfClients = Integer.parseInt(this.getTaskProperty("numberOfClients"));

These properties are inherited, in the sense that that when a task context has a property, the task can see it as well. But when a task has the same property with a different value, the task's value will be override the previous one.

One important property recognized by the Task API is `task.log.level` which sets the log level for a task. The property can have the following values (in increasing severity):

* TRACE
* DEBUG
* INFO
* WARN
* ERROR

The default log level is INFO.


*Warning* for the TRACE log level
:	Note that the TRACE log level is used by the Task API (instead of the DEBUG level which is reserved for user code). Setting the TRACE level will print Task API debug messages.

### Persisting Results {#user.taskapi.results}

The persistence layer provided by EverBEEN is capable of storing user-supplied types and classes. To create a class that can be persisted, simply create a subclass of the [`Result`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/results/Result.html) class and ensure that all contained fields are serializable. Also make sure to include a default non-parameterized constructor so that the object can be deserialized.


Each result type is identified with a string `Group ID` (we recommend to create a constant). The Group ID is an identification of a group of related results - each benchmark should use its unique own `Group ID(s)`. A naming convection is recommended to distinguish between multiple types of results. An example of a result:

	public class SampleResult extends Result {
		public static final String GROUP_ID = "example-data";

		public int data;

		public SampleResult() {}
	}

All fields will be stored (even private). Setters and getters are not necessary but still recommended.

Persisting the result is then only a simple matter of creating the appropriate object, instantiating the [`Persister`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/taskapi/Persister.html) class through the supplied `results` field and calling `persist` on it:

	SampleResult result = results.createResult(SampleResult.class);
	Persister persister = results.createResultPersister(SampleResult.GROUP_ID));
	persister.persist(result);

The `results.createResult(SampleResult.class)` call properly initializes results with *taskId*, *contextId* and (if running as part of a benchmark) *benchmarkId*. These parameters are useful in identifying results.

The `Persister` can be reused, but the `close()` method should be called once you are done with it. The best way to achieve this is to use the try-with-resources statement (the Persister implements `AutoCloseable`):

	try (Persister persister = results.createResultPersister(SampleResult.GROUP_ID)) {
		persister.persist(result);
	} 

### Querying Results {#user.taskapi.querying}
Tasks can also query stored results. Note that results storage is asynchronous and may take some time. Usually this is not a problem. Blocking results persistence is a planned feature. 

First a [`Query`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/persistence/Query.html) specifying what results to select must be built using the [`ResultQueryBuilder`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/persistence/ResultQueryBuilder.html). The ResultQueryBuilder uses a fluent API to build a query.

Following example creates a query which will fetch results from the SampleResult.GROUP_ID group, requesting that the *taskId* property is set to the ID of the current task and data property is 47;

	Query query = new ResultQueryBuilder().on(SampleResult.GROUP_ID)
		.with("taskId", getId()).with("data", 47).fetch();


The query can be now used to fetch a collection of results, again using the `results` helper object which is part of the `Task` object:

	Collection<ExampleResult> taskResults = results.query(query, ExampleResult.class);

Currently tasks can only fetch results, not delete them (this is design decision, the code is fully capable of issuing deletes).

An overview of the ResultQueryBuilder API follows:

`public ResultQueryBuilder on(String group)`
:	Sets the Group ID of the results to fetch.

`public ResultQueryBuilder with(String attribute, Object value)`
:	Adds a criterion to the query, where the `attribute` is the name of the property, and `value` is the expected value of the property.

`	public ResultQueryBuilder without(String attribute)`
:	Removes a criterion from the query, the value of `attribute` will not be fetched (beware of NullPointerExceptions).

`public ResultQueryBuilder retrieving(String... attributes)`
:	 Sets attributes to fetch. Other attributes will be omitted  and will not be set.

### Checkpoints and Latches {#user.taskapi.checkpoints}

Checkpoints provide a powerful mechanism for synchronization and communication among tasks contained in a single context. Tasks can wait for the value of a Checkpoint (most usually set by another task). This waiting is passive and once a value is assigned to a checkpoint, the waiter will receive it.

To use checkpoints, create a [`CheckpointController`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/taskapi/CheckpointController.html), which is an [`AutoCloseable`](http://docs.oracle.com/javase/7/docs/api/java/lang/AutoCloseable.html) object so the preferred way to use it is inside the try-with-resources block to ensure the object will be properly destroyed:

	try (CheckpointController requestor = CheckpointController.create()) {
		...
	} catch (MessagingException e) {
        ...
    }

Each checkpoint has a name, which is context-wide. You don't have to explicitly create a checkpoint, it will be created automatically once a task uses it. Setting a value to a checkpoint can be done with:

	requestor.checkPointSet("mycheckpoint", "the value");

A typical scenario is that one tasks wants to wait for another to pass a value. To wait until a value is set and also to receive the value you can use:

	String value = requestor.checkPointWait("mycheckpoint");

This call passively waits (possibly indefinitely) until a value is set to the checkpoint. There is also a variant of this method that takes another argument specifying a timeout, after which the call will throw an exception. Another method called `checkPointGet` can be used to retrieve the current value of a checkpoint without waiting.

Checkpoints initially do not have any value, and once a value is set, it cannot be changed. They work as a proper synchronization primitive, and setting a value is an atomic operation. The semantics don't change if you start waiting before or after the value is set.

Another provided synchronization primitive is a *latch*. Latches work best for implementing rendez-vous synchronization. A latch provides a method to set an integer value:

	requestor.latchSet("mylatch", 5);

Another task can then call an atomic method to decrease the value of the latch:

	requestor.latchCountDown("mylatch");

You can then wait until the value reaches zero:

	requestor.latchWait("mylatch");

All operations on latches are atomic and the waiting is passive. Latches has to be created (by the set method) before calling the count down or wait operation.

### Benchmark API {#user.taskapi.benchmarkapi}

Writing a benchmark's generator task is similar to writing an ordinary task in the sense that you have to write a subclass, package it and run it on a Host Runtime. However, the benchmark API is different, because the purpose of the benchmark is to provide long-running code that will eventually generate new task contexts.

To create a benchmark, subclass the abstract [`Benchmark`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/benchmarkapi/Benchmark.html) class and implement appropriate methods. The main method to implement is the `generateTaskContext` which is called periodically by EverBEEN `Benchmark API` and it is expected to return a newly generated task context. This context is then submitted and run. When the context finishes, this method is called again. The loop ends whenever the method returns `null`.

This approach is chosen to cover several possible use cases. When the benchmark does not have data for a new task context, it can simply block until it is possible to create a new context. On the other hand, the benchmark cannot overhaul the cluster by submitting too many contexts. Instead, it's up to the cluster to call the `generateTaskContext` method whenever it seems fit.

For creating task contexts you should use the provided [`ContextBuilder`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/benchmarkapi/ContextBuilder.html) class. This supports loading a task context from a XML file, modifying it and setting values of properties inside the context descriptor. If you have a prepared `.tcd` file with a context descriptor, a sample benchmark that will indefinitely generate this context can look like this:

	package my.sample.benchmark;

	import cz.cuni.mff.d3s.been.benchmarkapi.Benchmark;
	import cz.cuni.mff.d3s.been.benchmarkapi.BenchmarkException;
	import cz.cuni.mff.d3s.been.benchmarkapi.ContextBuilder;
	import cz.cuni.mff.d3s.been.core.task.TaskContextDescriptor;
	import cz.cuni.mff.d3s.been.core.task.TaskContextState;

	public class HelloWorldBenchmark extends Benchmark {
		@Override
		public TaskContextDescriptor generateTaskContext() throws BenchmarkException {
			ContextBuilder contextBuilder =
				ContextBuilder.createFromResource(HelloWorldBenchmark.class, "context.tcd.xml");
			TaskContextDescriptor taskContextDescriptor = contextBuilder.build();
			return taskContextDescriptor;
		}

		@Override
		public void onResubmit() { }

		@Override
		public void onTaskContextFinished(String s, TaskContextState taskContextState) { }
	}

Notice the methods `onResubmit` and `onTaskContextFinished` which are used as notifications for the benchmark. You can use these methods for whatever error handling or logging you need.

You are supposed to implement the logic for generating the contexts. When your benchmark is done and it will not generate any more contexts, return `null` from the `generateTaskContext` method.

### Creating Task Contexts {#user.taskapi.contexts}

The preferred way of creating task contexts is to use the `ContextBuilder` class to load a XML file representing the context descriptor from a resource. This class also provides various methods for modifying the context descriptor and the contained tasks.

You can add tasks into the context via the `addTask` method, these tasks can be created using the `newEmptyTask` method. The context descriptor can also provide *task templates* which can be used to create tasks.

Preferably you should create the whole descriptor in the XML file and only use the `setProperty` method to set the parameters to the task contexts. When the descriptor is ready call the `build` method to generate object representation of the descriptor which can be returned to the framwork.

### Resubmitting and Benchmark Storage

Benchmarks are supposed to be long-running and EverBEEN provides a mechanism to keep benchmarks running even after a failure occurs. When a generator task exits with an error (e.g. power outage), it will get resubmitted and the benchmark will continue. To support this behavior, you should use the provided benchmark key-value storage for the internal state of the benchmark and avoid using instance variables.

The `Benchmark` abstract class provides methods `storageGet` and `storageSet` which will use the cluster storage for the benchmark state. This storage will be restored whenever the generator task is resubmitted. The implementation of a benchmark that uses this storage can look like this:

	@Override
	public TaskContextDescriptor generateTaskContext() throws BenchmarkException {
		int currentRun = Integer.parseInt(this.storageGet("i", "0"));
		TaskContextDescriptor taskContextDescriptor;
		if (currentRun < 5) {
			// generate a regular context
			taskContextDescriptor = ...;
		} else {
			// we're done
			taskContextDescriptor = null;
		}

		currentRun++;
		this.storageSet("i", Integer.toString(currentRun));

		return taskContextDescriptor;
	}

### Evaluators {#user.taskapi.evaluators}

EverBEEN provides a special task type called **evaluator**. The purpose of such a task is to query the stored results, perform statistical analyses and return an interpretation of the data that can be shown back to the user via the Web Interface. Evaluators are again tasks and they can be run manually (as a single task) or within a benchmark or a context. It's up to the user when and how to run an evaluator.

To create an evaluator, subclass the abstract class [`Evaluator`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/taskapi/Evaluator.html) and implement the method `evaluate`. This method is supposed to return an [`EvaluatorResult`](http://everbeen.cz/javadoc/everBeen/cz/cuni/mff/d3s/been/evaluators/EvaluatorResult.html) object which will be stored through the persistence layer. The object holds a byte array of data and its MIME type. EverBEEN supports a few MIME types which can be displayed in the Web Interface, e.g. a JPEG image.

An evaluator needs to retrieve data from the persistence layer, and it can do so using the provided `ResultFacade` interface. This object is available as an instance method on the `Task` superclass. Queries can be build using the `QueryBuilder` object which supports various conditions and query parameters. A simple query that will retrieve a collection of results can have this form:

	Query query = new QueryBuilder().on(...).with(...).fetch();
	Collection<MyResult> data = results.query(query, MyResult.class);

For an example of a simple evaluator that output a plot chart with the measured data and error intervals, see the sample `nginx-benchmark`.
