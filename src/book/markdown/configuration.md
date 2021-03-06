## EverBEEN configuration {#user.configuration}
Configuration of the framework is done through a single, standard property file. The configuration is propagated to all services, each service uses a subset of the options.

A user property file is supplied to EverBEEN by the `-cf [file|URL]` (or `--config-file`) command line option. The value can be either a file or a URL pointing to the file. Using configuration by specifying a URL simplifies deployment in large environments, by reducing the need to distribute the file among the machines on which the framework runs.

To check the values in effect use `-dc` (or `--dump-config`) command line option (possibly along with the `-cf` option). It prints the configuration which will be used --- the output provides a basic configuration file (options with default value are commented out with `#`).

Default configuration values are supplied, before you change any of them, consult documentation and make sure you understand the implications.

### Configuration options
A detailed description of available configuration options of the EverBEEN framework follows. The default value for each configuration option is provided.

#### Cluster Configuration {#user.configuration.cluster}
Cluster configuration describes how nodes will form a cluster and how the cluster will behave. The configuration is directly mapped to Hazelcast configuration. These options are applicable only to DATA nodes.

It is *essential* that all cluster nodes use the same configuration for these options, otherwise they may not form a cluster.

`been.cluster.group`=*dev*
:	Group to which the nodes belong. Nodes whose group settings differ will not form a cluster

`been.cluster.password`=*dev-pass*
:	Password for the group. Nodes whose group password settings differ will not form a cluster

`been.cluster.join`=*multicast*
:	Manages how nodes form the cluster. Two values are possible: `multicast` which implies only `been.cluster.multicast.*` options will be used, and `tcp` which implies only  `been.cluster.tcp.members` option will be used.

`been.cluster.multicast.group`=*224.2.2.3*
:	Specifies the multicast group to use.

`been.cluster.multicast.port`=*54327*
:	Specifies the multicast port to use.

`been.cluster.tcp.members`=*localhost:5701*
:	Semicolon separated list of `[ip|host][:port]` nodes to connect to.

`been.cluster.port`=*5701*
:	The port on which the node will listen.

`been.cluster.interfaces`=
:	Semicolon separated list of interfaces Hazelcast should bind to, the '*' wildcard can be used, e.g. `10.0.1.*`.

`been.cluster.preferIPv4Stack`=*true*
:	Whether to prefer the IPv4 stack over IPv6.

`been.cluster.backup.count`=*1*
:	The number of backups the cluster should keep.

`been.cluster.logging`=*false*
:	Enables/Disables logging of Hazelcast messages. Note that Hazalcast log messages are not persisted as other service logs.

`been.cluster.mapstore.use`=*true*
:	Wheather to use MapStore to persist cluster runtime information.

`been.cluster.mapstore.write.delay`=*0*
:	Delay in seconds with which to write to the MapStore. *0* means *write-through*, values bigger than zero mean *write-back*. Certain Map Store implementations will be more efficient in write-back mode.

`been.cluster.mapstore.factory`=*cz.cuni.mff.d3s.been.mapstore.mongodb.MongoMapStoreFactory*
:	Implementation of MapStore, must be on the classpath when starting a node.

`been.cluster.socket.bind.any`=*true*
:	Whether to bind to local interfaces.

#### Cluster Client Configuration {#user.configuration.client}
Cluster client configuration options are used when a node is connected to the cluster in *NATIVE* client mode. Cluster Configuration options are ignored in that case.

`been.cluster.client.members`=*localhost:5701*
:	Semicolon separated list of `[ip|host][:port] cluster members to connect to. At least one member must be available.

`been.cluster.client.timeout`=*120*
:	Inactivity timeout in seconds. The client will disconnect after the timeout.

#### Task Manager Configuration {#user.configuration.taskmanager}
Task Manager configuration options are used to tune the Task Manager. Use with care!

`been.tm.benchmark.resubmit.maximum-allowed`=*10*
:	Maximum number of resubmits of a failed benchmark task the Task Manager will allow.

`been.tm.scanner.period`=*30*
:	Period in second of the Task Manager's local key scanner.

`been.tm.scanner.delay`=*15*
:	Initial delay in seconds of the Task Manager's local key scanner.

#### Cluster Persistence Configuration {#user.configuration.objectrepo}
Configuration for the persistence transport layer. See chapter [\ref*{user.persistence} (Persistence)](#user.persistence) for more details.

`been.cluster.persistence.query-timeout`=*10*
:	The timeout for queries into the persistence layer.


`been.cluster.persistence.query-processing-timeout`=*5*
:	The timeout for a query's processing time in the persistence layer. Processing time includes the trip the data has to make back to the requesting host.

#### Persistence Janitor Configuration {#user.configuration.objectrepo.janitor}
Configuration for the persistence layer janitor component. See [\ref*{user.persistence} (Persistence)](#user.persistence) for more details.

`been.objectrepository.janitor.finished-longevity`=*168*
:	 Number of hours objects with a `FINISHED` status stay persistent.

`been.objectrepository.janitor.failed-longevity`=*96*
:	Number of hours objects with a `FAILED` status stay persistent.

`been.objectrepository.janitor.service-log-longevity`=*168*
:	Number of hours EverBEEN service logs stay persistent.

`been.objectrepository.janitor.load-sample-longevity`=*168*
:	Number of hours EverBEEN node load monitor samples stay persistent. If set to `0`, load sample cleanup will be disabled.

`been.objectrepository.janitor.cleanup-interval`=*10*
:	Period in minutes of janitor cleanup checks.

#### Monitoring Configuration {#user.configuration.monitoring}
Host Runtime monitoring configuration options.

`been.monitoring.interval`=*5000*
:	Interval of Host Runtime system monitoring samples, in milliseconds.

#### Host Runtime Configuration {#user.configuration.hostruntime}
Host Runtime configuration options.

`hostruntime.tasks.max`=*15*
:	Maximum number of tasks per Host Runtime.

`hostruntime.tasks.memory.threshold`=*90*
:	Host Runtime memory threshold in percent. If the threshold is reached no other task will be run on the Host Runtime. The value must be between 20% - 100&.  The threshold is compared to the value of '(free memory/available memory)*100'.

`hostruntime.wrkdir.name`=*.HostRuntime*
:	Relative path to the Host Runtime working directory.

`hostruntime.tasks.wrkdir.maxHistory`=*4*
:	 Maximum number of task working directories a Host Runtime will keep. When this number is exceeded at the boot of a Host Runtime service, the oldest existing directory is deleted.

#### MapStore Configuration {#user.configuration.mapstore}
MapStore configuration options.

`been.cluster.mapstore.db.hostname`=*localhost*
:	Host name (full connection string including port). If no port is specified, default port is used.

`been.cluster.mapstore.db.dbname`=*BEEN_MAPSTORE*
:	Name of the database instance to use.

`been.cluster.mapstore.db.username`=*null*
:	User name to use to connect to the database.

`been.cluster.mapstore.db.password`=*null*
:	Password to use to connect to the database.

#### Mongo Storage Configuration {#user.configuration.mongostorage}
Configuration options for the MongoDB based Object Storage.

`mongodb.hostname`=*localhost*
:	Host name (full connection string including port). If no port is specified, default port is used.
	
`mongodb.dbname`=*BEEN*
:	Name of the database instance to use.

`mongodb.username`=*null*
:	User name to use to connect to the database.

`mongodb.password`=*null*
:	Password to use to connect to the database.

#### Software Repository Configuration {#user.configuration.swrepo}

`swrepository.port`=*8000*
:	Port on which the Software Repository should listen for requests.

#### File System Based Store Configuration {#user.configuration.fsbasedstorage}

`hostruntime.swcache.folder`=*.swcache*
:	Caching directory for downloaded software on Host Runtimes, relative to the working directory of a node.

`swrepository.persistence.folder`=*.swrepository*
:	Default storage directory for Software Repository server, relative to the working directory of a node.

<!-- not used
`hostruntime.swcache.maxSize`=*1024*
:	Maximum size of the software cache in MBytes.	
-->
