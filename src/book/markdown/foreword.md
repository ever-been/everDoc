## Foreword

Automatic testing of software has become an integral part of software development and software engineering today heavily relies on two levels of testing and verification to ensure the quality of programs:

- **Unit testing** which refers to the process of testing a single isolated component if it behaves according to the specification. Unit tests are usually conducted in a white-box manner and nowadays, software is often engineered in a *test-driven development* environment, where the developers first write unit tests before actually implementing a component.

- **Integration testing** which tries to verify the interaction and integration of multiple components within a system. It is usual to perform this using black-box testing and there are several patterns and approaches for integration testing.

Such testing is not only done in order to hunt bugs and discover non-functional code, but it has found its use in performance testing and evaluation as well. The requirement to focus development on performance is becoming a standard part of software engineering. Performance measuring (benchmarking) can have different goals, e.g.:

- **Regression testing**, when the developer wants to know if a newly implemented feature has any impact on the performance of the system.
- **Measuring scalability**, when the system is measured under an increasing load.
- **Comparison with competing software**
- **Determining the bottleneck**

Despite the fact that performance measuring is definitely useful, it still has quite a low popularity among development teams. Regression benchmarking is uncommon and the implementation of individual benchmarks is usually project-specific. The need for a generic framework for regression benchmarking is obvious for many reasons:

- Benchmarking middleware is hard because of the need for a complex environment. A general environment could simplify the tasks of deployment, configuration and management of a networked system for benchmarking.

- Performing a long-running benchmark on multiple machines requires a significant amount of work to ensure the benchmark will continue even after a failure of one machine. The framework could provide such facilities easily.

- A benchmarking framework could easily make evaluation automatized and integrate it into the development process.

- The environment can offer facilities, such as synchronization, logging and communication mechanisms, that would make the task of creating a benchmark easier.

- Statistics, analysis and visualization are good candidates for having a helpful library instead of writing your own.

### Related works

* Kalibera, T., Lehotsky J., Majda D., Repcek B., Tomcanyi M., Tomecek A., Tuma, P., Urban J.:
[Automated Benchmarking and Analysis Tool](http://d3s.mff.cuni.cz/publications/download/Submitted_1404_BEEN.pdf) (PDF, 149 kB), VALUETOOLS 2006

* Kalibera, T., Bulej, L., Tuma, P.: [Generic Environment for Full Automation of Benchmarking](http://d3s.mff.cuni.cz/publications/download/KaliberaBulejTuma-FullAutomationOfBenchmarking.pdf) (PDF, 84 kB), SOQUA 2004
