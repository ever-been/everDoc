## Design goals {#devel.dgoals}
The original goal of the EverBEEN project (as stated in the [former assignment](http://ksvi.mff.cuni.cz/~holan/SWP/zadani/ebeen.txt)) was mainly to cleanup the existing [WillBEEN](http://been.ow2.org/) project and replace the [RMI](http://docs.oracle.com/javase/7/docs/technotes/guides/rmi/index.html) framework by a more robust networking solution.

However, feedback from previous attempts of deployment in the corporate sector showed that framework stability was not the only issue. The tools for easy creation of WillBEEN jobs were lacking at best, and we experienced the reported difficulties in WillBEEN deployment first-hand. Furthermore, experience showed that some advanced features of WillBEEN (namely the Results Repository) had poor real-case use. Jiří Täuber's [master thesis](https://is.cuni.cz/webapps/zzp/detail/78663/4417375), aimed at analyzing real case WillBEEN deployment, clearly marks these issues as a major factor of WillBEEN's failure in a production environment.

These findings made us focus not only on a complete reimplementation of WillBEEN, but also on the user perspective of EverBEEN deployment and regression benchmarking in general. As a result, we set up several goals which we tried to stand up to during EverBEEN design and development.

### Scalability, Redundancy, Reliability {#devel.dgoals.scale}

As we were deciding which networking technology EverBEEN will use, we were driven to make EverBEEN as robust as possible in face of network failures and OS freezes. The choice of Hazelcast as a networking technology took this idea to new heights, enabling us to build EverBEEN as a truly distributed system, rather than just a network of interconnected nodes.

<!-- TODO check link addr -->
As a result, we decentralized all the decision-making in EverBEEN. Decisions are made on the basis of distributed shared memory and as long as multiple [data nodes](#user.concepts.nodes) are running, there is no single point of failure. The failure of a single partaking host was seen as an eventuality, rather than an unrecoverable error, and was counted with from the start of EverBEEN development, as was the case of a temporary disconnection of the persistence layer.

### Modularity {#devel.dgoals.modular}

Modularity was the first code characteristic we noted as lacking in WillBEEN. Although some pseudo-modules were present, the entire codebase was compiled together, leading to frequent cross-references in the project. Not only does this pose an issue with code maintainability, but it also makes component overrides very demanding in terms of the user's knowledge of the entire system. With the aid of modern building tools (mostly Apache Maven), we made EverBEEN a modular project where component overriding is possible.

In reaction to previous problems with WillBEEN's result storage, we specifically interfaced the *Object Repository* (formerly *Results Repository*) database connector out of the project, thus making it easily replaceable if need be (see [extension points](#user.extension) for a guide).

### Ease of use {#devel.goals.easy}

When we started attempts at refactoring the WillBEEN code, we were told that it took tens to hundreds hours to deploy WillBEEN and get some basic benchmarks working. We saw this quantity of time as unacceptable, hence the major focus of our work was on making the EverBEEN project easier to use.

First, we decided to completely invert the way EverBEEN services are programmed. WillBEEN services were tailored to work with each other, compiled together, but launched separately. In EverBEEN, we developed services separately, and only fused them together in the final assembly step. Thus, the communication between services only happens on the basis of a small common codebase containing relevant protocol objects. As opposed to WillBEEN, the order in which EverBEEN services are launched is not critical to the correct function of the cluster. We believe this considerably simplifies EverBEEN deployment, and reduces the study time necessary to make a benchmark run.

Second, we decided to simplify the process of task creation as much as possible. The decisions we had to make to see this goal through were particularly difficult, as simplification directly opposes the generality the rest of the framework had to offer. We came to a similar conclusion as WillBEEN authors did, and picked one technology we fully support --- Java in combination with Apache Maven. As arbitrary as this decision may seem, it comes with huge benefits --- the user can have a simple EverBEEN task up and running within minutes.

