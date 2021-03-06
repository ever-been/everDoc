## Glossary {#intro.glossary}

`benchmark`
:	Special-purpose task designed for *task context* generation.

`Benchmark API`
:	API assisting EverBEEN users with writing *benchmarks*.

`BPK`
:	EverBEEN package containing software and metadata necessary for running *tasks*, *benchmarks* and/or *evaluators*.

`BPK Plugin`
:	Apache Maven plugin capable of generating *BPK* bundles.

`checkpoint`
:	Inter-task synchronization primitive.

`DATA node`
:	A `node` instance that participates in distributed data sharing and runs a *Task Manager* service.

`evaluator`
:	Special-purpose task designed to perform presentable evaluations on results generated by other tasks.

`EverBEEN service`
:	A software component that adds extra functionality to an EverBEEN node. Services are launched at node boot time. Node service selection is specified by command-line options.

`Host Runtime`
:	*EverBEEN service* that executes *tasks* and mediates communication between *tasks* and the rest of the EverBEEN cluster.

`NATIVE node`
:	A `node` instance that does not participate in distributed data sharing.

`node`
:	Java application providing clustering functionality and capable of running EverBEEN services.

`Object Repository`
:	Universal storage component for EverBEEN user data.

`Result`
:	User type carrying *task* output data.

`Software Repository`
:	An *EverBEEN service* cabable of distributing *BPK* bundles across the cluster.

`task`
:	Unit of user-written code executable by the EverBEEN framework.

`Task API`
:	API assisting EverBEEN users with writing *tasks*.

`task descriptor`
:	`XML` description of a *task*'s configuration.

`task context`
:	A container grouping multiple tasks into a logical unit.

`task context descriptor`
:	A `XML` representation of a *task context*.

`Task Manger`
:	*EverBEEN service* in charge of *task* scheduling.

