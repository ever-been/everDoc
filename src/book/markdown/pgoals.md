## Project goals

The assignment of the current incarnation of the BEEN project are mainly focused on delivering a more usable, stable and scalable product. This meant that the development team should work on the current codebase and refactor it instead of starting from scratch.

There were however too many architectural and design points where refactoring simply couldn't get rid of the problems. The usage of RMI was too deep and too embedded into the whole codebase that replacing it with a more scalable middleware technology was not an option. The individual modules of BEEN were cross-linked and couldn't be separated by well-defined interfaces. Multiple implementations of the same functionality (e.g. logging) made the codebase scattered and inconsistent. Also, the project implemented several custom facilities that can be done better by using an external library.

This caused the team to reevaluate the requirements and they decided to rewrite BEEN from scratch, only preserving the concept and several design decision, e.g. the choice of components and their purpose. Because of this, the team could focus on creating a scalable, deployable and usable product from the first moment.

Therefore the goals were adapted and mainly contain:

* Preserving the basic concept of the whole environment
* Innovation of the codebase to use modern technologies and practices
* Delivering a highly scalable and stable product
* Reducing the number of *single points of failure* to a minimum
* Making the framework easily deployable
* Improving usability to simplify writing and debuggin tasks and benchmarks
* Implement asynchronous and distributed communication
