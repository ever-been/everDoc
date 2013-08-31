## Case study

During the development of EverBEEN, several use cases were considered and this section describes the ones that BEEN was specifically designed for.

### Regression benchmarking

Regression benchmarking is a technique mostly aimed to discover negative performance impact of a newly added feature, an upgrade or a single patch in the source code. This usually involves performing the same set of benchmarks against various versions of the same software, and often it tests even individual revisions of the source tree. When the benchmark is stable enough to result in consistent data, it is easy to immediately see which commits had impact on performance.

While performance degradation is obviously an undesired effect, unplanned performance increase can also be an indicator of a problem. This can easily happen when an expensive check (e.g. for security purposes) is unintentionally removed or bypassed. Both positive and negative changes can serve as a valuable input for the development team, because it not only denotes the change, but also points to the exact code that caused the change.

### Pull-oriented benchmarking

Consider the case that we have access to the source code repository with version history of a software product. Suppose the developers don't do any regular benchmarking and suddenly they realize that their software behaves much slower than a year ago. Although the performance degradation is probably caused by several factors, the developers would like to know, what exact change caused the biggest slowdown, so they can focus on improving.

If this software was a standalone desktop application, the obvious solution would be to build all the revisions of the software since the last year and benchmark them. Writing a script automating this task would be straightforward, but when the software we are talking about is a distributed middleware, even setting a benchmarking environment could be a costly task.

This task can be generalized into a problem of running a benchmark over a set of parameters. The parameters are known in advance and the benchmark is by necessity a user-written code. If a general framework for benchmarking should be helpful, it would need to simplify the issues of writing the code *and* of specifying the set of parameters. The user's options must be flexible enough to support many possible configurations of the benchmark. One might want to benchmark software with various configurations.

When the benchmark is to work over an already-known set of parameters, we call it **pull-oriented benchmarking**. The details of BEEN's support for this use case are discussed later.

### Push-oriented benchmarking

Another practical use case is implementing benchmarking into a **continuous integration environment**. Such environments usually perform a large suite of unit tests whenever a commit into the repository is made. The results (especially failed tests) are then shown either on a project status web page or sent via email to the developers.

Deploying a *continuous regression testing* suite into such a system would then be a matter of integrating a benchmarking framework in such a way that a suite of prepared benchmarks would be run every time a new commit is made. We call this case **push-oriented benchmarking**, because there is no predefined set of items to benchmark. Instead, a *push event* should be dispatched what would cause the newly created item to be tested.
