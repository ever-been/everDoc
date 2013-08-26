## Persistence layer {#user.persistence}
EverBEEN persistence layer functions as a bridge between EverBEEN distributed memory and a database of choice, rather than a direct storage component. This enables EverBEEN to run without a persistence layer, at the cost of heap space and a risk of data loss in case of an unexpected cluster-wide shutdown. EverBEEN doesn't *need* a persistence layer per-se at any given point in time. User tasks, however, might attempt to work with previously acquired results. Such attempts will result in task-scope failures if the persistence layer is not running. Log archives, too, will be made unavailable if the persistence layer is offline.



### Characteristics {#user.persistence.characteristics}
Follows an overview of the main characteristics of EverBEEN's persistence layer.



#### Bridging {#user.persistence.characteristics.bridging}
The EverBEEN persistence layer doesn't offer any means of storing the objects per se. It only functions as an abstract access layer to an existing storage component (e.g. a database). EverBEEN comes with a default implementation of this bridge for the MongoDB database, but it is possible to port it to a different database (see [extension point](#user.persistence.extension) notes for more details). The user is responsible for setting up, running and maintaining the actual storage software.



#### Eventual persistence {#user.persistence.characteristics.eventual}
As mentioned above, object-persisting commands (result stores, logging) do not, by themselves, execute insertions into the persistence layer. They submit objects into EverBEEN's distributed memory. When a persistence layer node is running, it continually drains this distributed memory, enacting the actual persistence of drained objects. This offers the advantage of being able to pursue persisting operations even in case the persistence layer is currently unavailable.

The downside of the bridging approach is that persisted objects might not find their way into the actual persistence layer immediately. It also means that should a cluster-wide shutdown occur while some objects are still in the shared memory, these objects will get lost. All that can be guaranteed is that submitted objects will eventually be persisted, provided that some data nodes and a persistence layer are running. This being said, experience shows that the transport of objects through the cluster and to the persistence layer is a matter of fractions of a second.



#### Scalability {#user.persistence.characteristics.scalability}
As mentioned above, EverBEEN does not strictly rely on the existence of a persistence node for running user code, only to present the user with the data he requires. That being said, EverBEEN can also run multiple persistence nodes. In such case, it is the user's responsibility to set up these nodes in a way that makes sense.

While running multiple nodes, please keep in mind that these storage components will be draining the shared data structures concurrently and independently. It is entirely possible to setup EverBEEN to run two persistence nodes on two completely separate databases, but it will probably not result in any sensibly expectable behavior, as potentially related data will be scattered randomly across two isolated database instances.

Generally speaking, having multiple persistence layer nodes is only useful if you:

* Have highly limited resources for each persistence node and wish to load-balance accesses to the same database
* Have a synchronization/sharding strategy set up

Additional use-cases may arise if you decide to write your own database adapter. In that case, consult the [extension point](#user.persistence.extension) for more detail.



#### Automatic cleanup {#user.persistence.characteristics.cleanup}
To prevent superfluous information from clogging the data storage, the Object Repository runs a Janitor component that performs database cleanup on a regular basis. The idea is to clean all old data for failed jobs and all metadata for successful jobs after a certain lifecycle period has passed. For lifecycle period and cleanup frequency adjustment, see the [janitor configuration](#user.configuration.objectrepo.janitor) section.



### Components {#user.persistence.components}
Follows a brief description of components that contribute to forming the EverBEEN persistence layer.

* [Object Repository](#user.persistence.components.objectrepo)
* [Storage](#user.persistence.components.storage)
* [MapStore](#user.persistence.components.mapstore)



#### Object Repository {#user.persistence.components.objectrepo}
It goes without saying that EverBEEN needs some place to store all the data your tasks will produce. That's what the Object Repository is for. Each time a task issues a command to submit a result, or logs a message, this information gets dispatched to the cluster, along with the associated object. The Object Repository provides a functional endpoint for this information. It effectively concentrates distributed data to its intended destination (a database, most likely). In addition, the Object Repository is also in charge of dispatching requested user data back.



#### Storage {#user.persistence.components.storage}
The Storage component supplies the concrete database connector implementation. All communication between the Object Repository and the database is done through the Storage API.

The Storage component gets loaded dynamically by the Object Repository at startup. If you want to use a different database than MongoDB, this is the component you'll be replacing (along with the MapStore, potentially).



#### MapStore {#user.persistence.components.mapstore}
Where the ObjectRepository stores user data, the MapStore is used to map EverBEEN cluster memory to a persistent storage, which enables EverBEEN to preserve job state memory through cluster-wide restarts. The MapStore runs on all *data nodes* (see [deployment](#user.deployment.nodes.types) for more information on node types).



### Extension points overview {#user.persistence.extension}
As mentioned above, EverBEEN comes with a default persistence solution for MongoDB. We realize, however, that this might not be the ideal use-case for everyone. Therefore, the MongoDB persistence layer is fully replaceable if you provide your own database implementation.

There are two components you might want to override - the [Storage](#user.persistence.storageex) and the [MapStore](#user.persistence.extension.mapstore).

If your goal is to relocate EverBEEN user data (benchmark results, logs etc.) to your own database and don't mind running a MongoDB as well for EverBEEN service data, you'll be fine just overriding the [Storage](#user.persistence.storageex). If you want to completely port all of EverBEEN's persistence, you'll have to override the [MapStore](#user.persistence.extension.mapstore) as well.

### Storage extension {#user.persistence.storageex}
As declared above, the *Storage* component is fully replacable by a different implementation than the default MongoDB adapter. However, we don't feel comfortable with letting you plunge into this extension point override without a few warnings first.

#### Override warning {#user.persistence.storageex.warning}
 The issue with *Storage* implementation is that the persistence layer is designed to be completely devoid of any type knowledge. The reason for this is that *Storage* is used to persist and retrieve objects from user tasks. Should the *Storage* have any RTTI knowledge of the objects it works with, imagine what problems could arise when two tasks using two different versions of the same objects would attempt to use the same *Storage*.

To avoid this, the *Storage* only receives the object JSON and some information about the object's placement. This being said, the *Storage* still needs to perform effective querying based on some attributes of the objects it is storing.

This is generally not an issue with NoSQL databases or document-oriented stores, but it can be quite hard if you use a traditional ORM. The ORM approach additionally presents the aforementioned class version problem, which you would need to solve somehow. If ORM is the way you want to go, be prepared to run into the following:

* **EverBEEN classes** - You will probably need to map some of these in your ORM
* **User types** - You will likely need to share a user-type library with your co-developers to consent on permitted result objects
* **User type versions** - Should the version of this user-type library change, you will need to restart the *Storage* before running any new tasks on EverBEEN. Restarting EverBEEN will likely result in the dysfunction of tasks using an older version of the user-type library


#### Override implementation overview {#user.persistence.storageex.overview}
If your intention is not to use ORM for *Storage* implementation, or you have really thought the consequences through, keep reading. It is highly recommended that you use [Apache Maven](http://maven.apache.org/) to build your implementation. Extension without Maven is possible, but will not be covered in this booklet. Additionally, you'll need [git](http://git-scm.com/) to check out EverBEEN sources.

Once you've gotten both Maven and git, you'll need to check out the EverBEEN project and install the artifacts to your local repository:

	git clone git@github.com:ever-been/everBeen.git
	mvn install

You will need to import the following EverBEEN modules to provide a *Storage* implementation, as follows:

	<dependency>
	        <groupId>cz.cuni.mff.d3s.been</groupId>
	        <artifactId>core-data</artifactId>
	        <version>${been.version}</version>
	</dependency>
	
	<dependency>
	        <groupId>cz.cuni.mff.d3s.been</groupId>
	        <artifactId>storage</artifactId>
	        <version>${been.version}</version>
	</dependency>

Then create a **been.version** property in your Maven module that corresponds to the EverBEEN version you checked out and installed.

Now that you have your project set up, you can begin to actually code implementation. To successfully replace the *Storage* implementation, you'll need to implement the following:
<!-- TODO javadoc link -->

* [Storage](#) - the main interface providing the actual store management
* [StorageBuilder](#) - an instantiation/configuration tool for your *Storage* implementation
* [SuccessAction\<EntityCarrier\>](#) - an isolated action capable of persisting objects


<!-- TODO javadoc link -->
Additionally, you'll need to create a **META-INF/services** folder in the jar with your implementation, and place a file named **cz.cuni.mff.d3s.been.storage.StorageBuilder** in it. You'll need to put a single line in that file, containing the full class name of your [StorageBuilder](#) implementation.

We also strongly recommend that you implement these as well:

* [QueryRedactorFactory](#) (along with [QueryRedactor](#) implementations)
* [QueryExecutorFactory](#) (along with [QueryExecutor](#) implementations)

The general idea is for you to implement the *Storage* component and to provide the *StorageBuilder* service, which configures and instantiates your *Storage* implementation. The **META-INF/services** entry is for the *ServiceLoader* EverBEEN uses to recognize your *StorageBuilder* implementation on the classpath. EverBEEN will then pass the *Properties* from the *been.conf* file (see [configuration](#user.configuration)) to your *StorageBuilder*. That way, you can use the common property file for your *Storage*'s configuration.

<!-- TODO javadoc link -->
The [Storage](#) interface is the main gateway between the [Object Repository]("user.persistence.components.objectrepo") and the database. When overriding the Storage, there will be two major use-cases you'll have to implement: the [asynchronous persist](#user.persistence.storageex.asyncper) and the [synchronous query](#user.persistence.storageex.qa).

#### Asynchronous persist {#user.persistence.storageex.asyncper}
<!-- TODO javadoc link -->
All *persist* requests in EverBEEN are funneled through the [store](#) method. You'll receive two parameters in this method:

<a id="user.persistence.storageex.asyncper.eid">***entityId***</a>
The *entityId* is meant to determine the location of the stored entity. For example, if you're writing an SQL adapter, it should determine the table where the entity will be stored. For more information on the *entityId*, see [persistent object info](#user.persistence.storageex.objectinfo)


<a id="user.persistence.storageex.asyncper.json">***JSON***</a>
A serialized JSON representation of the object to be stored.

Generally, you'll need to decide where to put the object based on its *entityId* and then somehow map and store it using its *JSON*.

<!-- TODO javadoc link -->
The [store](#) method is asynchronous. It doesn't return any outcome information, but be sure to throw a *DAOException* when the persist attempt fails. That way, you'll make sure the *ObjectRepository* knows that the operation failed and will take action to prevent data loss.

#### Query / Answer {#user.persistence.storageex.qa}
<!-- TODO javadoc link -->
The other type of requests that *Storage* supports are queries. They are synchronous and a *Query* is always answered with a *QueryAnswer*. In order to support queries, you could implement all the querying mechanics by yourself (if you wish to do that, see the [Task API](#user.taskapi.querying) for more details), but that's not necessary. The [QueryTranslator](#) adaptor is designed to help you interpret queries without having to go through all of the query structure.

<!-- TODO javadoc link -->
The preferred way of interpreting queries is to create a [QueryRedactor](#) and implementation (or several, in fact). The *QueryRedactor* class designed to help you construct database-specific query interpretations using callbacks. This way, you instantiate the *QueryTranslator*, call its *interpret* method passing it your instance of the *QueryRedactor* and the *QueryTranslator* calls the appropriate methods on your *QueryRedactor*. Once configured, your *QueryRedactor* can be used to assemble and perform the expected query. There are additional interfaces that can help you in the process ([QueryRedactorFactory](), [QueryExecutor]() and [QueryExecutorFactory]()).

<!-- TODO javadoc link -->
Once you execute the query, you will need to synthesize a [QueryAnswer](), which you can do using the [QueryAnswerFactory](). If there is data associated with the result of the query, you need to create a *data answer* using `QueryAnswerFactory#fetched(...)`. The other *QueryAnswerFactory* methods are used to indicate the query status. See the method in-code comments for more detail about available answer types.

#### Auxiliary methods {#user.persistence.storageex.aux}
In addition to persisting and querying, the *Storage* interface features these auxiliary methods, which you'll need to implement.
<!-- TODO javadoc link -->

* **createPersistAction** - return an instance of your implementation of [SuccessAction\<EntityCarrier\>](#); its *perform* method is presumed to call your `Storage#store()` implementation
* **isConnected** - a situation may occur when the *Object Repository* is running, but the database it uses isn't; this simple method is designed to help EverBEEN detect such a situation by returning `false` should the database connection drop
* **isIdle** - a database usage heuristics function that helps the *Object Repository* janitor better detect cleanup windows (to interfere less with heavy user operations)

#### General persistent object info {#user.persistence.storageex.objectinfo}
Although the *Storage* doesn't implicitly know any RTTI on the object it's working with, there are some safe assumptions you can make based on the *entityId* that comes with the object.

The *entityId* is composed of *kind* and *group*. The *kind* is supposed to represent what the persisted object actually is (e.g. a log message). These kinds are currently recognized by EverBEEN:

* **log** - log messages and host load monitoring
* **result** - stored task results
* **descriptor** - *task*/*context* configurations; used to store parameters with which a *task* or *context* was run
* **named-descriptor** - *task*/*context* configurations; user-stored configuration templates for *task* or *context* runs
<!-- TODO javadoc link -->
* **evaluation** - output of evaluations performed on task results; these objects contain serialized BLOBs - see [evaluations](#) for more detail
* **outcome** - meta-information about the state and outcome of jobs in EverBEEN; these are used in automatic cleanup

The *group* is supposed to provide a more granular grouping of objects and depends entirely on the object's *kind*.

If you need more detail on objects that you can encounter, be sure to also read the [ORM special](#user.persistence.storageex.ormspecial), which denotes what EverBEEN classes can be expected where and what *entityIds* can carry user types.

#### The ORM special {#user.persistence.storageex.ormspecial}
If you're really hell-bent on creating an ORM implementation of the *Storage*, your module will need to know several more EverBEEN classes to be able to perform the mapping. The following table covers their *entityIds*, their meaning and the dependencies you will need to get them.

<!-- TODO javadoc link --><!-- lots of them actually -->
*kind*                  *group*         meaning                                         class                                                   module
----------------        ----------      ----------------------------------              --------------------------                              ------
log                     task            message logged by a task                        [TaskLogMessage]()                                      core-data
log                     service         message logged by a service                     [ServiceLogMessage]()                                   core-data
log                     monitoring      host monitoring sample                          [MonitorSample]()                                       core-data
descriptor              task            task runtime configuration                      [TaskDescriptor]()                                      core-data
descriptor              context         task context runtime configuration              [TaskContextDescriptor]()                               core-data
named-descriptor        task            saved task configuration                        [TaskDescriptor]()                                      core-data
named-descriptor        context         saved task context configuration                [TaskContextDescriptor]()                               core-data
result                  *\**            task result                                     any user class extending [Result]()                     *n/a* (results)
evaluation              *\**            task result evaluation                          [EvaluatorResult]()                                     results
outcome                 task            task state service records                      [PersistentTaskState]()                                 persistence
outcome                 context         task context state service records              [PersistentContextState]()                              persistence

Thus, if you need to infer the knowledge the runtime type of all of these classes to your module, you need to add the following to your module dependencies:

	<dependency>
		<groupId>cz.cuni.mff.d3s.been</groupId>
		<artifactId>persistence</artifactId>
		<version>${been.version}</version>
	</dependency>
	
	<dependency>
		<groupId>cz.cuni.mff.d3s.been</groupId>
		<artifactId>results</artifactId>
		<version>${been.version}</version>
	</dependency>

Additionally, you'll probably need to inject a dependency containing your pre-defined result types (*Result* extenders used by your benchmarks). As mentioned before, you will need to be very careful about the versioning of this module.

#### Replacing the Storage implementation {#user.persistence.storageex.replace}
After you implement your own *Storage* back-end, you need to sew it back into EverBEEN. EverBEEN is bundled using the [Maven Assembly Plugin](http://maven.apache.org/plugins/maven-assembly-plugin/), which unpacks EverBEEN modules along with their dependencies, combines their class files and creates the ultimate jar. That means that to actually swap the *Storage* implementation, you'll need to rebuild EverBEEN with some modifications.

First, build your *Storage* module using `mvn install`. That will deploy your artifact to the local Maven repository, where EverBEEN can see it. For further reference, let's assume your storage artifact identifier is `my.group:my-storage:2.3.4`.

Then, you'll need to rebuild EverBEEN using your *Storage* module instead of the default one. For that, you'll need a deployment project. This project will use `pom` packaging and will only contain the `pom.xml` with instructions for Maven Assembly Plugin. Because writing the assembly descriptor is tedious, we've created the `pom` for you as a quick starter:

	<?xml version="1.0" encoding="UTF-8"?>
	<project xmlns="http://maven.apache.org/POM/4.0.0"
			 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
		<modelVersion>4.0.0</modelVersion>
		<groupId>my.group</groupId>
		<artifactId>my-been-flavor</artifactId>
		<version>1.0.0</version>
		<packaging>pom</packaging>
	
		<properties>
			<been.version>3.0.0</been.version>
		</properties>
	
		<dependencies>
			<dependency>
				<groupId>cz.cuni.mff.d3s.been</groupId>
				<artifactId>node</artifactId>
				<version>${been.version}</version>
	
				<exclusions>
					<exclusion>
						<groupId>cz.cuni.mff.d3s.been</groupId>
						<artifactId>mongo-storage</artifactId>
					</exclusion>
				</exclusions>
			</dependency>
	
			<dependency>
				<groupId>my.group</groupId>
				<artifactId>my-storage</artifactId>
				<version>2.3.4</version>
			</dependency>
		</dependencies>
	
		<build>
			<plugins>
				<plugin>
					<groupId>org.apache.maven.plugins</groupId>
					<artifactId>maven-assembly-plugin</artifactId>
					<version>2.4</version>
	
					<configuration>
						<finalName>myBeenFlavor</finalName>
						<appendAssemblyId>false</appendAssemblyId>
						<archive>
							<manifest>
								<mainClass>cz.cuni.mff.d3s.been.node.Runner</mainClass>
							</manifest>
						</archive>
						<descriptorRefs>
							<descriptorRef>jar-with-dependencies</descriptorRef>
						</descriptorRefs>
					</configuration>
				</plugin>
			</plugins>
		</build>
	</project>

Just to explain what's going on above:

* your deployment project has the `cz.cuni.mff.d3s.been:node` artifact as its dependency; this is the artifact into which we funnel all the runnable EverBEEN modules, so you'll have the entire EverBEEN portfolio in your assembly just by linking that module
* however, in that dependency, you specify that the `cz.cuni.mff.d3s.been:mongo-storage` artifact should be excluded; that is the artifact containing the default MongoDB implementation of *Storage*
* then, you deployment project links the `my.group:my-storage:2.3.4` which you installed earlier in your maven repository; that means **your** *Storage* implementation will be placed in the assembly
* finally, there's the assembly plugin configuration, saying that a `jar` file named `myBeenFlavor.jar` should be deployed into the `target` folder of your deployment project, assembling classes from all dependencies, with `cz.cuni.mff.d3s.been.node.Runner` for main class

Finally, you'll need to create your assembly, which can be done by invoking `mvn assembly:assembly` in the root of your deployment project.

If you followed our instructions carefully, you'll end up with a runnable EverBEEN node `jar`, minus `cz.cuni.mff.d3s.been:mongo-storage`, plus `my.group:my-storage:2.3.4` on the classpath, which will enable *Object Repository* to see **your** implementation and not the default one.



### MapStore extension {#user.persistence.mapstoreex}
EverBEEN uses the *MapStore* to maintain persistent knowledge about the state of your tasks (and other jobs). You'll only need to override the default MongoDB implementation if you need to get rid of Mongo completely.

The EverBEEN *MapStore* is a direct bridge between Hazelcast (the technology EverBEEN uses for clustering) and a persistence layer, so overriding it is pretty straightforward. You need to do the following:

* **Implement the Hazelcast [MapStore](http://www.hazelcast.com/docs/2.5/javadoc/com/hazelcast/core/MapStore.html) interface** - see above for links
* **Implement the Hazelcast [MapStoreFactory](http://www.hazelcast.com/docs/2.5/javadoc/com/hazelcast/core/MapStoreFactory.html) interface** - again, see above for the link. Do not get confused by the fact that *MapStoreFactory* returns a *MapLoader* instance. The *MapStore* extends the *MapLoader* with storing methods, which you will need, so you need to to return an instance of your *MapStore* implementation in `YourMapStoreFactory#newMapStore()`
* **Configure EverBEEN to use your MapStore** - in the `been.conf` (or any other EverBEEN config file you're using), you need to set the `been.cluster.mapstore.factory` property to the **fully qualified class name** of your **MapStoreFactory** implementation
* **Get your package on the EverBEEN classpath** - Make sure to use the same *MapStore* implementation on all EverBEEN cluster nodes, with the same, otherwise you might end up with your job status data being partitioned across two completely different databases
<!-- TODO describe extension point -->
