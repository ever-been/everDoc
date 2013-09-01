## EverBEEN architecture

Differently from its predecessor, [WillBEEN](http://been.ow2.org/), EverBEEN was designed as a fully distributed application from the start. Despite the differences this implies on the design process and the overall system architecture, we tried to stick to the time-proven [concept of the original BEEN](http://d3s.mff.cuni.cz/publications/download/Submitted_1404_BEEN.pdf) as much as possible. The EverBEEN architecture is best explained by the following schema.

![EverBEEN architecture](images/architecture/everbeen.png)

The first fact of note is the separation of user and system space.
<!-- TODO explain why & how -->


* mostly true to the original BEEN
* * principal components stayed the same (SWRepository, RRepository, HostRuntimes)
* * Tasks are still separate processes
* * Put some cool pictures and thesis links here
* cluster adaptation
* * TaskManager ascended to hive-mind
* * SWRepository emits its location to the cluster
* * RRepository is not centralized anymore (can run on multiple nodes if need be)
