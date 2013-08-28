## EverBEEN requirements

BEEN is from the first moment of development a multi-platform software. It's possible to run an installation of BEEN on any of these platforms:

* Linux -- most recent distributions
* Mac OS X 10.8 and later
* Microsoft Windows XP, Windows Vista, Windows 7 and later
* FreeBSD

In order to deploy BEEN, every machine that should be connected into the BEEN cluster, needs:

* Java Runtime Environment (JRE) version 1.7

For writing and debugging user-written tasks, the machine needs:

* Apache Maven version 3

For a node that will run the web interface client, the machine needs:

* Tomcat version 7 // TODO

For a node that will run the results repository, the machine needs:

* MongoDB version 2.4

The clients that should be able to access the web interface need to have one of the following web browsers:

* Google Chrome version 29 or newer
* Mozilla Firefox version 22 or newer

The project doesn't have any explicit hardware requirements, any machine that has the previously mentioned software requirements installed and working, should be able to run BEEN. However, the recommended minimum machine hardware configuration is:

* Modern CPU with at least 2.0 GHz
* 100Mbit network interface
* 4 GB of RAM
* 10 GB of HDD free space
