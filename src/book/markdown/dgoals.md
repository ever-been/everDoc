## Design goals
The original goal of the EverBEEN project (as set up in the [former assignment](http://ksvi.mff.cuni.cz/~holan/SWP/zadani/ebeen.txt)) was mainly to perform cleanup on the existing [WillBEEN](http://been.ow2.org/) project and replace the [RMI framework](http://en.wikipedia.org/wiki/Java_remote_method_invocation) framework by a more robust networking solution.

However, feedback from previous attempts of deployment in the corporate sector showed that framework stability was not the only issue. The tools for easy creation of WillBEEN jobs were lacking at best, and we experienced reported difficulties in WillBEEN deployment first-hand. Furthermore, experience showed that some advanced features of WillBEEN (namely the Results Repository) had poor real-case use. Jiri Tauber's [master thesis](https://is.cuni.cz/webapps/zzp/detail/78663/4417375/?q=a%3A4%3A%7Bs%3A25%3A%22______searchform___search%22%3Bs%3A6%3A%22tauber%22%3Bs%3A28%3A%22______searchform___butsearch%22%3Bs%3A8%3A%22Vyhledat%22%3Bs%3A35%3A%22______facetform___facets___workType%22%3Ba%3A1%3A%7Bi%3A0%3Bs%3A2%3A%22DP%22%3B%7Ds%3A20%3A%22PNzzpSearchListbasic%22%3Bi%3A1%3B%7D&lang=cs), aimed at analyzing real case WillBEEN deployment, clearly marks these issues as a major factor of WillBEEN's failure in the corporate sector.

These findings made us focus not only on technological modifications of WillBEEN, but also on the user facet of BEEN deployment and regression benchmarking in general. As a result, we set up several goals which we tried to stand up to during EverBEEN design and development.

### Scalability, Redundancy, Reliability

As we were deciding which networking technology EverBEEN will use, we were driven to make EverBEEN as robust as possible in face of potential network failures and OS freezes. The choice of Hazelcast as a networking technology took this idea to new heights, enabling us to build EverBEEN as a truly distributed system, rather than just a set of interconnected nodes.

<!-- TODO check link addr -->
As a result, we decentralized all EverBEEN decision-making. All decisions are made on the basis of network-shared memory, so as long as multiple [data nodes](#user.concepts.nodes) are running, the danger of a single point of failure is eliminated. The failure of a single partaking host was seen as an eventuality, rather than an unrecoverable error, and was accounted with from the start of EverBEEN development, as was the case of a temporary disconnection of the persistence layer.

### Modularity 

Modularity was the first code characteristic we noted as lacking in WillBEEN. Although some pseudo-modules were present, the entire codebase was compiled together, leading to frequent cross-references in the project. Not only does this pose an issue with code maintainability, but it also makes component overrides very demanding on the user's knowledge of the entire system. With the aid of modern building tools (mostly Apache Maven), we made EverBEEN a modular project, where component overriding is possible.

In reaction to previous problems with WillBEEN's result storage, we specifically interfaced the *Object Repository* (formerly *Results Repository*) database connector out of the project, thus making it easily replaceable in case of need (see [extension points](#user.extension) for a guide).

### Ease of use

When we started attempts at refactoring WillBEEN code, we were told that it took several dozen to a few hundred hours to deploy WillBEEN and get some basic benchmarks working. We saw this quantity of time as unacceptable, hence the major focus of our works on making EverBEEN project easier to use.

Firstly, we decided to completely invert the way EverBEEN services are programmed. WillBEEN services were tailored to work with each other, compiled together, but launched separately. In EverBEEN, we developed services separately, and only fused them together in the final assembly step. Thus, the communication between services only happens on the basis of a small common codebase containing relevant protocol objects. As opposed to WillBEEN, the order in which EverBEEN services are launched is not critical to the correct functioning of the clusters. We believe this considerably limits hassle with EverBEEN deployment, and reduces necessary study-time before the application can successfully run.

Second, we decided to simplify the process of task creation as much as possible. The decisions we had to make towards the realization of this goal were particularly difficult, as the concept of facilitation directly opposes the genericity the rest of the framework had to offer. We came to a similar conclusion as WillBEEN authors did, and picked one technology we support to full extent - Java in combination with Apache Maven. As arbitrary as this decision may seem, it comes with huge benefits - the user can have a simple EverBEEN task up and running in the matter of minutes.

