## EverBEEN configuration {#user.configuration}
* one configuration file
* how to generate one easily
* distribution via URL

### Configuration options
Follows detailed description of available configuration options of the EverBEEN
framework. Default value for each configuration option is provided

#### Cluster Configuration {#user.configuration.cluster}
Cluster configuration manages how nodes will form a cluster and
how the cluster will behave. The configuration is directly mapped to
Hazelcast configuration. These options are applicable only to *DATA* nodes. <!-- TODO link to DATA node -->

It is essential that cluster nodes use the same configuration for these options, otherwise they may not form a cluster.

`been.cluster.group`=*dev*
:	Group to which the nodes belong. Nodes with different group will not form a cluster.

`been.cluster.password`=*dev-pass*
:	Password for the group. If different password is used among nodes the will not for a cluster.

`been.cluster.join`=*multicast*
:	Manages how nodes form the cluster. Two values are possible:

	* *multicast* - only `been.cluster.multicast.*` options will be used
	* *tcp* - only  `been.cluster.tcp.members` option will be used


`been.cluster.multicast.group`=*224.2.2.3*
:	Specifies multicast group to use


`been.cluster.multicast.port`=*54327*
:	Specifies multicast port to use

`been.cluster.tcp.members`=*localhost:5701*
:	Semicolon separated list of `[ip|host][:port]` nodes to connect to.


`been.cluster.port`=*5701*
:	Port on which the node will listen to.

`been.cluster.interfaces`=
:	Semicolen separated list of interfaces Hazelcast should bind to, '*' wildcard can be use, e.g. *10.0.1.**

`been.cluster.preferIPv4Stack`=*true*
:	Whether to prefer IPv4 stack over IPv6


`been.cluster.backup.count`=*1*
: How many backups should the cluster keep.


`been.cluster.logging`=*false*
: Enables/Disables logging of Hazelcast messages. Note that if enabled messages will not appear among service logs.


`been.cluster.mapstore.use`=*true*
:	Wheather to use [MapStore](#devel.services.mapstore) to persist cluster runtime information

`been.cluster.mapstore.write.delay`=*0*
: Delay in seconds with which to write to the [MapStore](#devel.services.mapstore). *0* means *write-through*, values bigger than zero mean *write-back*. MapStore implementation can optimize *write-back* mode. 

`been.cluster.mapstore.factory`=*cz.cuni.mff.d3s.been.mapstore.mongodb.MongoMapStoreFactory*
:	Implementation of the [MapStore](#devel.services.mapstore), must be on the classpath when starting a node.

`been.cluster.socket.bind.any`=*true*
:	Whether to bind to local interfaces

#### Cluster Client Configuration {#user.configuration.client}
Cluster client configuration options are used when a node is connection to the cluster in *NATIVE* client mode. [Cluster Configuration](#user.configuration.cluster) options are ignored.

`been.cluster.client.members`=*localhost:5701*
:	Semicolon separated list of `[ip|host][:port] cluster members to connect to. At least one member must be available.

`been.cluster.client.timeout`=*120*
:	Inactivity timeout in seconds. The client will disconnect after the timeout.

#### Task Manager Configuration {#user.configuration.taskmanager}
Task Manager configuration options are used to tune the [Task Manager](#devel.services.taskmanager). Use with care!

`been.tm.benchmark.resubmit.maximum-allowed`=*10*
:	Maximum number of resubmits of a failed benchmark task the Task Manager will allow.

`been.tm.scanner.period`=*30*
: Period in second of the Task Manager's [local key scanner](#devel.services.taskmanager.errors)

`been.tm.scanner.delay`=*15*
:	Initial delay in seconds of the Task Manager's [local key scanner](#devel.services.taskmanager.errors)

#### Cluster Persistence Configuration {#user.configuration.objectrepo}
Configuration for persistence transport layer. See [Persistence](#user.persistence) for more details.

`been.cluster.persistence.query-timeout`=*10*
:	The timeout for queries into persistence layer.


`been.cluster.persistence.query-processing-timeout`=*5*
:	The timeout for a query's processing time in the persistence layer. Processing time contains the trip the data has to make back to the requesting host.

#### Persistence Janitor Configuration {#user.configuration.objectrepo.janitor}
Configuration for persistence layer janitor component. See [Persistence](#user.persistence) for more details.

`been.repository.janitor.finished-longevity`=*96*
:	 Number of hours objects with a 'FINISHED' status stay persistent.

`been.repository.janitor.failed-longevity`=*48*
:	Number of hours objects with a `FAILED` status stay persistent.

`been.repository.janitor.cleanup-interval`=*10*
:	Period in minutes of janitor cleanup checks.

#### Monitoring Configuration {#user.configuration.monitoring}
Host Runtime monitoring configuration options.

`been.monitoring.interval`=*5000*
: Interval of Host Runtime system monitoring samples, in milliseconds.

#### Host Runtime Configuration {#user.configuration.hostruntime}
[Host Runtime](#user.hostruntime) configuration options

`hostruntime.tasks.max`=*15*
:	Maximum number of tasks per Host Runtime

`hostruntime.tasks.memory.threshold`=*90*
:	Host Runtime memory threshold in percents. If the threshold is reached no other task will be run on the Host Runtime. The value must be between 20 - 100.  The threshold is compared to the value of '(free memory/available memory)*100'.

`hostruntime.wrkdir.name`=*.HostRuntime*
:	Relative path to the Host Runtime working directory

`hostruntime.tasks.wrkdir.maxHistory`=*4*
:	 Maximum number of task working directories a Host Runtime will keep. When this number is exceeded at the boot of a Host Runtime service, the oldest existing directory is deleted.

#### MapStore Configuration {#user.configuration.mapstore}
[MapStore](#devel.services.mapstore) configuration options.

`been.cluster.mapstore.db.hostname`=*localhost*
:	Hostname (full connection string including port). If no port is specified, default port is used.

`been.cluster.mapstore.db.dbname`=*BEEN_MAPSTORE*
:	Name of the database instance to use.

`been.cluster.mapstore.db.username`=*null*
:	User name to use to connect to the database.

`been.cluster.mapstore.db.password`=*null*
:	Password to use to connect to the database.

#### Mongo Storage Configuration {#user.configuration.mongostorage}
Configuration options for the MongoDB based [Object storage](#user.persistence).

`mongodb.hostname`=*localhost*
: Hostname (full connection string including port). If no port is specified, default port is used.
	
`mongodb.dbname`=*BEEN*
: Name of the database instance to use.

`mongodb.username`=*null*
:	User name to use to connect to the database.

`mongodb.password`=*null*
:	Password to use to connect to the database.

#### Software Repository Configuration {#user.configuration.swrepo}
Configuration for the [Software Repository](#user.swrepository)

`swrepository.port`=*8000*
: Port on which the Software Repository should listen for requests.

#### File System Based Store Configuration {#user.configuration.fsbasedstorage}

`hostruntime.swcache.folder`=*.swcache*
:	Caching directory for downloaded software on Host Runtime, relative to the working directory of a node.

`swrepository.persistence.folder`=*.swrepository*
:	Default storage directory for Software Repository server, relative to the working directory of a node.

`hostruntime.swcache.maxSize`=*1024*
: Maximum size of the software cache in MBytes.	
