## EverBEEN requirements {#user.requirements}

BEEN is designed from the ground up to be a multi-platform software. Currently supported platforms include:

* Linux -- most recent distributions
* Mac OS X 10.8 and later
* Microsoft Windows 7 and later
* FreeBSD

In order to deploy BEEN these software packages need to be installed:

* Java Runtime Environment (JRE) version 1.7

For writing and debugging user-written tasks:

* Apache Maven version 3

For a node that will run the web interface client:

* Java Servlet compatible container (e.g. Tomcat 7, Jetty)

(The container is optional, the Web Interface can be also run in embedded mode.) 

For a node that will run the results repository, the machine needs:

* MongoDB version 2.4

The clients that should be able to access the web interface need to have one of the following web browsers:

* Google Chrome version 29 or newer
* Mozilla Firefox version 22 or newer

The project does not have any explicit hardware requirements, any machine that meets the software requirements listed above, should be able to run BEEN. However, the recommended minimum machine hardware configuration is:

* Modern CPU with at least 2.0 GHz
* 100Mbit network interface
* 4 GB of RAM
* 10 GB of HDD free space
