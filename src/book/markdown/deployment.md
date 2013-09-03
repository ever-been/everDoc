## Deployment process


### Running BEEN
The deployment process assumes a set of interconnected computers on which the framework is supposed to be run and running MongoDB instance. See [Requirements](#user.requirements) and [http://docs.mongodb.org/manual/installation/](http://docs.mongodb.org/manual/installation/)

* Copy BEEN onto each machine - single executable jar file is provided

* Create clustering configurations

The exact configuration is highly dependent on the network topology. In following example configuration two scenarios will be presented depending on how the cluster will be formed.

We will also assume that MongoDB instance is running on `mongodb.example.com`. All nodes must use the same *group* and *group password*.

#### Broadcasting scenario

The cluster is formed through broadcasting.

	been.cluster.mapstore.db.hostname=mongodb.example.com
	mongodb.hostname=mongodb.example.com
	
	been.cluster.multicast.group=224.2.2.4
	been.cluster.multicast.port=54326
	
	been.cluster.group=dev
	been.cluster.password=dev-pass

Only the first two configuration options are needed, rest of options have sane defaults.


#### Direct connect scenario

The cluster will be formed by directly connection nodes.

	been.cluster.mapstore.db.hostname=mongodb.example.com
	mongodb.hostname=mongodb.example.com

	been.cluster.join=tcp
	been.cluster.tcp.members=195.113.16.40:5701;host1.example.com;host2.example.com

	been.cluster.group=dev
	been.cluster.password=dev-pass

The `been.cluster.tcp.members` option specifies (a potentially partial) list of nodes to which the connecting node will try to connect. If no node in the list is responding a new cluster will be formed.

#### Connecting NATIVE nodes

NATIVE nodes must be informed to which DATA nodes to connect:

	been.cluster.client.members=host1.example.com:5701;host2.example.com
	been.cluster.group=dev
	been.cluster.password=dev-pass
 
The important is the `been.cluster.client.members` option, again specifying (a potentially partial) list of DATA nodes to which to connect. 

The configuration can be copied directly onto the hosts or can be referenced by an URL (which is the preferred way).

#### Configuring BEEN services

The next step is to decide which BEEN services will be run and where. In the simplest and most straight forward case one node will be running *Software repository*, *Object repository*, *Host Runtime* and implicitly the *Task Manager* service.

`java -jar been.jar -r -sw -rr -cf http://been.example.com/been.properties`

Other nodes thus can run only the *Host Runtime* service.

`java -jar been.jar -t NATIVE -r -cf http://been.example.com/been-clients.properties`
:	for NATIVE nodes

`java -jar been.jar -r  http://been.example.com/been-broadcast.properties`
:	in case of broadcasting scenario

`java -jar been.jar -r -sw -rr -cf http://been.example.com/been-direct.properties`
:	in case of direct scenario

#### Running Web Interface

The last step consists of deploying and running *the Web Interface*. The supplied war file can be deployed to a standard Java Servlet container (e.g. Tomcat). Or can be run directly by

`java -jar web-interface-3.0.0-SNAPSHOT.war`

which will use an embedded container.

### Node directory structure
Node working directory is created on first startup. 
       
    1.  .HostRuntime/
    2.      \___ tasks/
    3.          \___ 1378031207851/
    4.          \___ 1378038338005/
    5.          \___ 1378038763308/
    6.          \___ 1378040071618/
    7.              \___ example-task-a_1bdcaeb4/
    8.              |   \___ config.xml
    9.              |   \___ files/
    10.             |   \___ lib/
    11.             |   \___ stderr.log
    12.             |   \___ stdout.log
    13.             |   \___ tcds/
    14.             |   \___ tds/
    15.             \___ example-task-b_6a2ccc11/
    16.             \___ ...
    17.             \___ ...
                
* **.HostRuntime** directory (1) - Host Runtime global working directory. It can be configured by changing property `hostruntime.wrkdir.name`. Default name is `.HostRuntime`.
* Each separate run of the been creates its own working directory for its tasks in the **tasks** subdirectory (2).
* On each node restart is created new working directory for tasks running on this node (3,4,5,6). Names of these directories are based on actual time when node starts. BEEN on each start checks these directories and if their number exceeds 4 by default, the oldest one is deleted. This prevents unexpected growth of Host Runtime working directory size, but allows debugging failed tasks, when underlying Host Runtime is terminated and restarted. Count of backuped directories is configurable by property `hostruntime.tasks.wrkdir.maxHistory`.
* Working directories of single tasks (7,15,16,17) contains files from extracted BPK (8,9,10,13,14) and log files for error output (11) and standard output (12).

Working directory of single tasks is deleted only in case that this task finished its execution without error, otherwise the directory remains unchanged. If you want to cleanup directory manually, you can, or you can do it through web interface.



### Limitations
* If you want to run more more Host Runtimes on same machine you can, but we **strongly recommend you** to start each node with different working directory name. Host Runtime is not intended to run on single machine multiple times at the same time.
* Running BEEN for a long time without clearing directories after failed tasks can result in low disk space. If you tasks are failing, we can't easily know whenever we can delete them or not.
