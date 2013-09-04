## EverBEEN best practices

To avoid potential problems please keep in mind the following recommendations:

* Read the documentation.
* Check network and firewall settings.
* Do not run EverBEEN instances with shared working directory.
* Use provided tools (such as the `bpb-maven-plugin`).
* Start with fewer `DATA` nodes, use `NATIVE` nodes to run the Host Runtime service.
* MongoDB instance is needed to properly use the framework.
* If a host has more network interfaces, configure the one(s) you want to use. See [Cluster Configuration](#user.configuration.cluster).
* If writing a task or benchmark see provided examples. 