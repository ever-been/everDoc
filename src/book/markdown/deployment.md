## Deployment process

#### Basic concepts
Before dwelling into the deployment process a few concepts must be explained.


#### BEEN services
A BEEN service is a component which carries out a particular function. Follows brief overview of available services:

* Host Runtime - executes tasks
* Task Manager - scheduling of tasks
* Software Repository - BPK's
* Object Repository - persistence

#### Node types {#user.deployment.nodes.types}
In EverBEEN `node` is a program capable of running BEEN services. The node must be able to interact with other nodes through a computer network. Type of a node determines mechanism used to connect to other nodes. Since EverBEEN uses [Hazelcast](#devel.techno.hazelcast) as it means of connection nodes, types resemble those in Hazelcast. Currently two types are supported:

`DATA node`
:	Data nodes form a cluster which *share distributed data*. The cluster can be formed either through broadcasting or by directly connection nodes, see [Cluster Configuration](#user.configuration.cluster). The Task Manager service must be run on each DATA node (This requirement is enforced by the Node Runner). Be aware that DATA nodes incur overhead due to sharing data.

`NATIVE node`
:	Native nodes can be though of as cluster clients. They *do not* participate in sharing of distributed data and therefore do not incur overhead from it. NATIVE nodes connect directly to DATA nodes (failures are transparently handled). This also means that at all times at least one DATA node must be running in order for the framework to work. For configuration details see [Cluster Client Configuration](#user.configuration.client)  


Except of the Task Manager currently every other service can run on both types.

### Running BEEN
The deployment process assumes a set of interconnected computers on which the framework is supposed to be run and running MongoDB instance. See [Requirements](#user.requirements) and [http://docs.mongodb.org/manual/installation/](http://docs.mongodb.org/manual/installation/)

* Copy BEEN onto each machine - single executable jar file is provided

* Create clustering configurations

The exact configuration is highly dependent on the network topology. In following example configuration two scenarios will be presented depending on how the cluster will be formed.

We will also assume that MongoDB instance is running on `mongodb.example.com`. All nodes must use the same *group* and *group password*.

*Broadcasting scenario*
:	The cluster is formed through broadcasting.

	been.cluster.mapstore.db.hostname=mongodb.example.com
	mongodb.hostname=mongodb.example.com
	
	been.cluster.multicast.group=224.2.2.4
	been.cluster.multicast.port=54326
	
	been.cluster.group=dev
	been.cluster.password=dev-pass

Only the first two configuration options are needed, rest of options have sane defaults.


*Direct connect scenario*
:	The cluster will be formed by directly connection nodes.

	been.cluster.mapstore.db.hostname=mongodb.example.com
	mongodb.hostname=mongodb.example.com

	been.cluster.join=tcp
	been.cluster.tcp.members=195.113.16.40:5701;host1.example.com;host2.example.com

	been.cluster.group=dev
	been.cluster.password=dev-pass

The `been.cluster.tcp.members` option specifies (a potentially partial) list of nodes to which the connecting node will try to connect. If no node in the list is responding a new cluster will be formed.

*Connecting NATIVE nodes*
: NATIVE nodes must be informed to which DATA nodes to connect:

	been.cluster.client.members=host1.example.com:5701;host2.example.com
	been.cluster.group=dev
	been.cluster.password=dev-pass
 
The important is the `been.cluster.client.members` option, again specifying (a potentially partial) list of DATA nodes to which to connect. 

The configuration can be copied directly onto the hosts or can be referenced by an URL (which is the preferred way).

The next step is to decide which BEEN services will be run and where. In the simplest and most strait forward case one node will be running *Software repository*, *Object repository*, *Host Runtime* and implicitly the *Task Manager* service.

`java -jar been.jar -r -sw -rr -cf http://been.example.com/been.properties`

Other nodes thus can run only the *Host Runtime* service.

`java -jar been.jar -t NATIVE -r -cf http://been.example.com/been-clients.properties`
: for NATIVE nodes

`java -jar been.jar -r  http://been.example.com/been-broadcast.properties`
: in case of broadcasting scenario

`java -jar been.jar -r -sw -rr -cf http://been.example.com/been-direct.properties`
: in case of direct scenario

The last step consists of deploying and running *the Web Interface*. The supplied war file can be deployed to a standard Java Servlet container (e.g. Tomcat). Or can be run directly by

`java -jar web-interface-3.0.0-SNAPSHOT.war`

which will use an embedded container.

