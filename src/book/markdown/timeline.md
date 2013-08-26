## Decision timeline

*June 2012*
:	The current team took over the codebase of WillBEEN and started work on a new incarnation of the project, called EverBEEN.

*July 2012*
:	We decided to use Maven as a build system instead of Apache Ant and to split the project into several modules.

*August 2012*
:	Attempts to mavenize the project discovered a lot of mutual dependencies among apparently independent parts of the codebase.
:	The team started considering various communication frameworks and middleware as a replacement for RMI.

*September 2012*
:	Slf4j is chosen as a logging framework and logback as the basic logging backend. The decision was made to transform all existing logging mechanism to slf4j.

*October 2012*
:	The team started implementing a basic re-implementation of the project using Hazelcast middleware. This was chosen as the best alternative from various other candidates, such as JMS and JGroups. Hazelcast offered a great combination of both scalability and decentralization what fitted the project's concept best.

*November 2012*
:	Attempts of refactoring existing RMI code to use Hazelcast instead were catastrophic and the team decided to actually rewrite the project from scratch instead of transforming the code incrementally.
:	We will drop the current One-Jar plugin in favor of Maven Assembly plugin.
:	Sigar is to be used as the implementation of hardware detectors.
:	The original data structures and XML formats will be described using JAXB.

*December 2012*
:	The team acknowledged that it's impossible to create a high-level API independent on the low-level transport and communication protocol. We decided to make Hazelcast an integral dependency of BEEN.

*February 2013*
:	The software reposity component will be implemented as a HTTP server with a REST API. This will allow us to reuse existing libraries for HTTP communication and achieve correct streaming of large file transfers.

*March 2013*
:	For the purposes of both inter- and intra-process communication, we will use 0MQ.
:	Jackson will be  usedas a serialization library, and we will use JSON as a transport format for various inter-component communication. The (de-)serialization is easier and more flexible than XML.

*April 2013*
:	MongoDB is to be used as the default storage engine. Though, the persistence layer is to be implemented will a universal interface that would allow any other common database storage to be use instead. Also, MongoDB has a [lot of features](http://www.youtube.com/watch?v=b2F-DItXtZs) that fit the BEEN use case.
:	The web interface will be written in Java using Tapestry web framework. This will allow us to reuse existing data structures and classes and will take less time to write than pure JSP.

*May 2013*
:	The API for user-written benchmark is settled to be a special form of task that will be called by BEEN and will generate task contexts on demand.

*June 2013*
:	The team agrees to open-source the project on GitHub under a LGPL license.

*July 2013*
:	The API for evaluators and showing results in the web interface is settled.

*August 2013*
:	The whole documentation will be written in Markdown documents and will be compiled using a bash script.
