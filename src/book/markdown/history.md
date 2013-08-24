## Project history

### BEEN

The original BEEN project was started in Fall 2004 and it was finished at the turn of 2006 and 2007, it was supervised by Tomáš Kalibera and developed by Jakub Lehotsky, David Majda, Branislav Repcek, Michal Tomcanyi, Antonin Tomecek and Jaroslav Urban. This project's assignment was:

> The aim of the project will be to create a highly configurable and modular environment
> for benchmarking of applications, with special focus on middleware benchmarks.

The team that worked on the project created the whole architecture and individual component of the framework and eventually implemented a functional benchmarking environment in Java, using RMI as the main mean of communication between its individual parts.

### WillBEEN

The second incarnation of this project was called *WillBEEN* and it mainly continued development of the original project. Its goal was to extend BEEN, mainly focusing on adding support for non-Java user tasks (scripts) and creating a modular results repository component. 

This project was supervised by Petr Tuma and developed by Andrej Podzimek, Jiri Svoboda, Jan Tattermusch and Jiri Tauber. During the development, several components were redesigned and reimplemented and the project integrated several new technologies, such as JAXB and Derby database.

### State of WillBEEN in 2012

In 2012, the faculty decided to create another assignment for BEEN, as it was an ambitious project, but the state of it was still far from ideal. Since the original team started working on the project more that 7 years before, it's codebase used obsolete technologies and the legacy of the initial architecture decisions were causing issues both with stability and performance. The choice of RMI for component communication causes lots of trouble and the project in its current state has many *single points of failure*, when disconnecting a single component renders the whole environment unusable.

WillBEEN's upgrades were mostly criticized for lack of technological innovation and for maintaining deprecated and obsolete code instead of rewriting it or refactoring. Many of its feature were written from scratch instead of using modern standardized libraries.

The deployment of BEEN is yet another problematic part, when installing and configuring the environment takes a tremendous amount of effort. Last but not least, the API for tasks and benchmarks is very complicated and writing and debugging of user code ever for a very simple task takes several hours.

There are features, for which there is no clear use case, obsolete code of poor quality and many other issues with the codebase. Therefore the new BEEN implementation should focus mostly on maintenance, usability, stability and scalability of the framework.

### EverBEEN

EverBEEN, the current version (3.0) of the BEEN project, is an almost-complete rewrite of the whole framework. BEEN now has a fundamentally different architecture and its components have a decentralized nature. Thus the authors of this version chose to rewrite the project from scratch instead of continuing development on the original codebase. Also, many aspects of the project were simplified and the usage of popular 3rd party Java modules and technologies makes the whole framework more stable and standardized. However, most of the the individual BEEN subsystems, their purpose and naming were preserved, therefore users familiar with previous BEEN implementations should recognize the whole system easily.

EverBEEN is supervised by Andrej Podzimek and Petr Tuma, and developed by Martin Sixta, Tadeas Palusga, Radek Macha and Jakub Brecka. The work on the project started in Fall 2012 and is believed to be finished in September 2013.
