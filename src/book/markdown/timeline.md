## Decision timeline

*June 2012*
:	We took over the codebase of WillBEEN and started working on a new incarnation of the project, called EverBEEN.

*July 2012*
:	We decided to use Apache Maven as the build system instead of Apache Ant and to split the project into several modules.

*August 2012*
:	Attempts to "mavenize" the project discovered a lot of mutual dependencies among apparently independent parts of the codebase.
:	We started to consider various communication middleware frameworks as a replacement for RMI.

*September 2012*
:	`SLF4J` is chosen as a logging framework and `Logback` as the basic logging backend. The decision was made to unify all existing logging mechanisms.

*October 2012*
:	We started to implement a basic re-implementation of the project using Hazelcast middleware, which was chosen as the best alternative from among various other candidates, such as JMS and JGroups. Hazelcast offers a great combination of both scalability and decentralization which fitted the project's concept best.

*November 2012*
:	Attempts of incremental refactoring of the existing RMI based code to use Hazelcast were catastrophic and we decided to actually rewrite the project from scratch instead.
:	Current use of One-Jar plugin was dropped in favor of Maven Assembly plugin.
:	Sigar is to be used as the implementation of hardware detectors.

*December 2012*
:	We acknowledged that it's impossible to create a high-level API independent on the low-level transport and communication protocol. We decided to make Hazelcast an integral dependency of EverBEEN.

*February 2013*
:	The software repository component will be implemented as a HTTP server with a REST API. This will allow us to reuse existing libraries for HTTP communication and achieve correct streaming of large file transfers.

*March 2013*
:	For the purposes of both inter- and intra-process communication, we will use 0MQ.
:	We decide to use JSON as a transport format for various inter-component communication, with Jackson as a serialization library. The (de-)serialization is easier and more flexible than XML.

*April 2013*
:	MongoDB is to be used as the default storage engine. Though, the persistence layer is to be implemented with a universal interface that would allow any other common database storage to be use instead. Also, MongoDB has a [lot of features](http://www.youtube.com/watch?v=b2F-DItXtZs) that fit the EverBEEN use case.
:	The web interface will be written in Java using Tapestry5 web framework. This will allow us to reuse existing data structures and classes and will take less time to write than pure JSP.

*May 2013*
:	The API for user-written benchmark is settled to be a special form of task that will be called by EverBEEN and will generate task contexts on demand.

*June 2013*
:	We agreed to open-source the project on GitHub under a LGPL license.

*July 2013*
:	The API for evaluators and showing results in the web interface is settled.

*August 2013*
:	The documentation will be written in Markdown documents and will be compiled using [Pandoc](http://johnmacfarlane.net/pandoc/).
