## Case study {#intro.study}

During the development of EverBEEN, several use cases were considered and this section describes the ones that BEEN was specifically designed for.

### Regression benchmarking {#intro.study.regression}

Regression benchmarking is a technique mostly aimed at discovering negative performance impact of a newly added feature, an upgrade or a single patch in the source code. This usually involves performing the same set of benchmarks against various versions of the same software. Often, even individual revisions of the source tree are tested. When the benchmark is stable enough to result in consistent data, it is easy to immediately see which commits had an impact on performance.

While performance degradation is obviously an undesired effect, unplanned performance increase can also be an indicative of a problem. This can easily happen when an expensive check (e.g. for security purposes) is unintentionally removed or bypassed. Whether performance fluctuations be positive or negative, regression benchmarking provides the development team with crucial information which not only denotes the actutal performance change, but also points to the exact code modification that caused it.

### Pull-oriented benchmarking {#intro.study.pull}

Consider the following case: We have access to a source code repository with version history of a software product, whose developers don't do any regular benchmarking. Suddenly, they realize that their software behaves much slower than a year ago. Although the performance degradation is probably caused by several factors, the developers would like to determine major slowdown culprits and eliminate them.

If this software were a standalone desktop application, the obvious solution would be to build all the revisions of the software since last year and benchmark them. Writing a script automating this task would be straightforward. When the software in question is distributed middleware, even setting up a benchmarking environment could be a costly task.

This task can be generalized into a problem of running a benchmark over a set of parameters. The parameters are known in advance and the benchmark is by necessity a user-written code. A generic benchmarking framework should therefore simplify both parameter specification *and* the process of writing benchmark code. The user's options must be flexible enough to support many possible configurations of the benchmark --- one might want to benchmark a single piece of software with various configurations.

A benchmark iterating over a predefined set of parameters is called a **pull-oriented benchmark**. The details of EverBEEN's support for this use case are discussed later along with [project goals](#user.poutput.regression).

### Push-oriented benchmarking {#intro.study.push}

Another practical use case is the incorporation of benchmarking into a **continuous integration environment**. Such environments usually perform a large suite of unit tests whenever a commit into the repository is made. The results (especially failed tests) are then shown either on a project status web page or sent via email to the developers.

Deploying a *continuous regression testing* suite into such a system would then be a matter of integrating a benchmarking framework in such a way that a suite of prepared benchmarks would be run every time a new commit is made. We call this case **push-oriented benchmarking**, because there is no predefined set of items to benchmark. Instead, a *push event* should be dispatched that would cause the newly created revision to be tested.
