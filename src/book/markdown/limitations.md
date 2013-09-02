## Current limitations and future work {#devel.limitations}
The EverBEEN project, as any big project, has some limitations and opportunities for improvement. This chapter summarizes them and suggests possible directions which might be explored in future.
 
*Support for non JVM-based tasks*
:	The EverBEEN framework is fully capable of running non-JVM based tasks, such as scripts and binaries. What is missing is fully integrated environment for such tasks in form of `native` [Task API](#user.taskapi). The implementation of a native Task API should be strait forward. The protocol is described in the [Host Runtime](#devel.services.hostruntime.protocol) documentation. Preliminary work has begun on support for scripts, in form of a Python script - due to time constraints the support is in incubator phase. On the other hand the integration and support for JVM-based tasks is so extensive that most tasks can be easily implemented in it (including running of native binaries, commands and scripts)   

*BPK and artifact dependencies*
:	Currently BPKs are created as self-contained. The original plan was to resolve dependencies as part of the task initialization process (similar to the Maven way of resolving and downloading dependencies). The success of the `bpk-maven-plugin` pushed such feature more or less aside as it was deemed not necessary at the moment. Implementation of such feature could reduce size of BPKs and decrease network usage (which is currently of no concern, since BPKs are relatively small). 

*Command-line client*
:	The command line client introduced in the WillBEEN project is not supported. The so called `bcmd` client and its accompanied service were sophisticated pieces of code. Porting the code to current architecture would amount to time consuming work which we lacked. The client could be for example implemented in Java using the BEEN API (the same API the Web Interface uses). Preliminary work has been done in this area (`client-shell` module) - the code is in incubator phase. While interesting feature, real use case should also be presented

*Results triggers are not supported*
:	We feel that the removal of Result triggers introduced in WillBEEN is for the better. The fundamental problem with triggers was that there was no way how to debug/test them - the same problem as with old Benchmark Manager API. In EverBEEN evaluators are normal tasks which can be run through the Benchmark API. If there is a real use case, trigges could be implemented using Hazelcast events. 

*Support for big files*
:	Because the architecture of the EverBEEN framework depends on in-memory storage of data, transferring of big files is not recommended. We assume that benchmarking will be done in controlled environment, where the deployment of a network file system is not a problem if need be. Recently released version 3.0 of Hazelcast contains features which might be useful in implementing such feature. Or a separate service could be implemented - in which case we opt for usage of network file system. 

*Database backend for the Software Repository*
:	Interesting improvement might be adding database backend for the Software Repository. The feature is on the TODO list but due to lack of time and resources was not implemented. The Software Repository was design to easily change backends.

*Decentralized Software Repository*
:	Currently the Software Repository is centralized service. It might be interesting to explore new features in recently released [Hazalcast 3.0](http://hazelcast.com/docs/3.0/manual/single_html/) to allow cluster wide file distribution.