## Project history

### BEEN

The original BEEN project was started in Fall 2004 and finished at the turn of 2006 and 2007 It was supervised by Tomáš Kalibera and developed by Jakub Lehotský, David Majda, Branislav Repček, Michal Tomčányi, Antonín Tomeček and Jaroslav Urban. This project's assignment was:

> *"The aim of the project will be to create a highly configurable and modular environment for benchmarking of applications, with special focus on middleware benchmarks."*

The team that worked on the project created the whole architecture and individual components of the framework and eventually implemented a functional benchmarking environment in Java, using *RMI* as the main mean of communication among its individual parts.

### WillBEEN

The second incarnation of the framework was called *WillBEEN* and it mainly continued development of the original project. Its goal was to extend BEEN, mainly focusing on adding support for non-Java user tasks (scripts), creating a modular results repository component and devising a fast and reliable command-line user interface for the framework.

This project was supervised by Petr Tůma and developed by Andrej Podzimek, Jan Tattermusch and Jiří Täuber. The team started working in 2009 and finished the project in March 2010. During the development, several components were redesigned and reimplemented and the project integrated several new technologies, such as [JAXB](http://jaxb.java.net/) and [Apache Derby](http://db.apache.org/derby/).

### State of WillBEEN in 2012

In 2011, the faculty decided to create another assignment for BEEN as its state was still far from ideal. Since the original team started working on the project more that 7 years before, its codebase used obsolete technologies and the legacy of the initial architecture was causing issues with both stability and performance. The choice of *RMI* for component communication was deemed to be the main culprit. WillBEEN also had many *single points of failure*, e.g., disconnecting a single component rendered the whole environment unusable.

WillBEEN's development team had to cope with a large, old and fragile codebase. While changes introduced during the development were of good to high quality, the team lacked necessary resources to radically change or rewrite all parts of the framework.

WillBEEN deployment was yet another problematic part. Installing and configuring the environment took a tremendous amount of effort. Last but not least, the user API for writing benchmarks was very complicated, and user benchmark code was almost impossible to debug.

The new team was therefore supposed to eliminate some of these shortcomings, while stabilizing the framework even further. Thus the goals set were to rewrite the oldest parts of the framework, while maintaining the rest, along with finding a better approach to component communication based on asynchronous message passing. The work load was estimated to +20,000 LOC.


### EverBEEN

EverBEEN is a complete rewrite of the BEEN framework from scratch. It took into account [previous experience](https://is.cuni.cz/webapps/zzp/detail/78663/4417375/) with WillBEEN deployment and exploited current technologies and software development standards.

EverBEEN has a fundamentally different, decentralized architecture. Many aspects of the project were simplified by virtue of popular 3rd party Java libraries, which makes the whole framework more stable and compliant to modern development techniques. However, the naming of individual BEEN components and work units was preserved. Therefore, users familiar with previous BEEN implementations should have no trouble adapting to the new system implementation.

The decision to do a complete rewrite was made after careful consideration of all options. The incompatibility of project goals with the state of WillBEEN's codebase was the key piece that tipped the odds in favor of restarting from scratch.

EverBEEN is supervised by Andrej Podzimek and Petr Tůma, and developed by Martin Sixta, Tadeáš Palusga, Radek Mácha and Jakub Břečka. The work on the project started in Fall 2012 and its first stage is aimed to finish in September 2013.


