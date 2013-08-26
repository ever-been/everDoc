## Design goals
The original goal of the EverBEEN project (as set up in the [former assignment](http://ksvi.mff.cuni.cz/~holan/SWP/zadani/ebeen.txt)) was mainly to perform cleanup on the existing [WillBEEN](http://been.ow2.org/) project and replace the [RMI framework](http://en.wikipedia.org/wiki/Java_remote_method_invocation) framework by a more robust networking solution.

However, feedback from previous attempts of deployment in the corporate sector showed that framework stability was not the only issue. The tools for easy creation of WillBEEN jobs were lacking at best, and we experienced reported difficulties in WillBEEN deployment first-hand. Furthermore, experience showed that some advanced features of WillBEEN (namely the Results Repository) had poor real-case use. Jiri Tauber's [master thesis](https://is.cuni.cz/webapps/zzp/detail/78663/4417375/?q=a%3A4%3A%7Bs%3A25%3A%22______searchform___search%22%3Bs%3A6%3A%22tauber%22%3Bs%3A28%3A%22______searchform___butsearch%22%3Bs%3A8%3A%22Vyhledat%22%3Bs%3A35%3A%22______facetform___facets___workType%22%3Ba%3A1%3A%7Bi%3A0%3Bs%3A2%3A%22DP%22%3B%7Ds%3A20%3A%22PNzzpSearchListbasic%22%3Bi%3A1%3B%7D&lang=cs), aimed at analyzing real case WillBEEN deployment, clearly marks these issues as a major factor of WillBEEN's failure in the corporate sector.

These findings made us focus not only on technological modifications of WillBEEN, but also on the user facet of BEEN deployment and regression benchmarking in general. As a result, we set up several goals which we tried to stand up to during EverBEEN design and development.

### Scalability, Redundancy, Reliability

* decentralize decision-making
* use a non-SPOF comm protocol (replacing TM and RMI)

### Modularity 

* in reaction to previous experience with RR
* provide extension points

### Ease of use

* heavy Maven integration into Task API (BPK plugin), subsequent Java task focus
* node service composition over separate processes
