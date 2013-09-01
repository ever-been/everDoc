## Project history

### BEEN

The original BEEN project was started in Fall 2004 and it was finished at the turn of 2006 and 2007, it was supervised by Tomáš Kalibera and developed by Jakub Lehotský, David Majda, Branislav Repček, Michal Tomčányi, Antonín Tomeček and Jaroslav Urban. This project's assignment was:

> The aim of the project will be to create a highly configurable and modular environment
> for benchmarking of applications, with special focus on middleware benchmarks.

The team that worked on the project created the whole architecture and individual component of the framework and eventually implemented a functional benchmarking environment in Java, using RMI as the main mean of communication among it's individual parts.

### WillBEEN

The second incarnation of the framework was called *WillBEEN* and it mainly continued development of the original project. Its goal was to extend BEEN, mainly focusing on adding support for non-Java user tasks (scripts) and creating a modular results repository component. 

This project was supervised by Petr Tůma and developed by Andrej Podzimek, Jan Tattermusch and Jiří Tauber. The team started working in 2009 and finished the project in March 2010. During the development, several components were redesigned and reimplemented and the project integrated several new technologies, such as JAXB and Derby database.

### State of WillBEEN in 2012

In 2011, the faculty decided to create another assignment for BEEN, as it was an ambitious project, but the state of it was still far from ideal. Since the original team started working on the project more that 7 years before, it's codebase used obsolete technologies and the legacy of the initial architecture decisions were causing issues both with stability and performance. Especially the choice of RMI for component communication was deemed as the main source of problems. The project had also many *single points of failure*, e.g. disconnecting a single component rendered the whole environment unusable.

WillBEEN's development team had to cope with large, old and fragile codebase. While changes introduced during the development where of good to high quality, the team lacked necessary resources to radically change or rewrite all parts of the framework.

The deployment of BEEN was yet another problematic part, when installing and configuring the environment takes a tremendous amount of effort. Last but not least, the API for tasks and benchmarks is very complicated and writing and debugging of user code of a benchmark was almost impossible.

The new team was therefore supposed to eliminate some of these shortcomings, while stabilizing the framework even further. Thus the goals set where to rewrite the oldest parts of the framework, while maintaining the rest, along with finding better approach to component communication based on asynchronous message passing. The work load were estimated to +20,000 LOC.


### EverBEEN

EverBEEN is a complete rewrite of the framework. It took into account previous experience with WillBEEN deployment  <!-- TODO link to j.t. thesis --> and introduced current technologies and standards for software development.   

BEEN now has a fundamentally different, decentralized architecture. Many aspects of the project were simplified by usage of popular 3rd party Java libraries which makes the whole framework more stable and standardized. However, most of the the individual BEEN subsystems, their purpose and naming were preserved, therefore users familiar with previous BEEN implementations should recognize the whole system easily.

The decision to do a complete rewrite was made after careful consideration of all options - mainly state of the code and goals set for the framework.

EverBEEN is supervised by Andrej Podzimek and Petr Tůma, and developed by Martin Sixta, Tadeáš Palusga, Radek Mácha and Jakub Břečka. The work on the project started in Fall 2012 and is believed to be finished in September 2013.


