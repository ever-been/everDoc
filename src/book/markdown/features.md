## Principal features {#devel.features}

There are several EverBEEN features we are particularly proud of, mostly because we believe them to be a good match to the [project goals](#user.pgoals.goals) assigned to us at the beginning of the project, or the [design goals](#devel.dgoals) we set up ourselves when considering the deficiencies of previous project incarnations.

*Scalability*
:	Adding nodes to the EverBEEN cluster transparently increases the scale of benchmarks you can perform. There is no master node to bottleneck the decision-making even if you create a large cluster. The assumed (although untested) advantage of using `MongoDB` is its sharding ability, which should provide a database back-end scaling strategy implicitly compatible with EverBEEN.

*Easy deployment*
:	Deploying EverBEEN can be as simple as installing a database and running a few executable `jar`s with a few command-line options. No shady deployment scripts. No installation. Just pure Java, with a database adapter and a synoptic front-end webapp to go with. Configuration is concentrated into one file, which you can load from a *URL* to quicken mass reconfiguration.

*Easy measures*
:	If you use Java, creating a simple EverBEEN *task* is a matter of minutes, rather than hours. All you need is a `pom` file (for Apache Maven), one method override and a *task descriptor*. Once you have that, the `bpk-maven-plugin` will bundle your *BPK* with a simple `mvn package`. Once your *BPK* gets more complex, you can create *task descriptor* and *context descriptor* templates, which you can then tweak from the web interface before you run them. Once you get familiar with *tasks* and *task contexts*, creating a *benchmark* is easy, because you just need to write a *task* that creates *task contexts*, except that you can comfortably modify the *context* XML using Java-to-XML bindings.

*User type transparency*
:	For Java tasks, support for user result types is reduced to extending one class. Once you do that, your result objects are serialized, stored, queried and de-serialized without you needing to do any extra work - the *Task API* does it for you. If you happen to update your *task* code and change a result class's version (add a field, for example), you won't get into trouble if you apply a minimum of caution.

*Extensibility*
:	EverBEEN is modular and therefor extensible. If you don't like `MongoDB`, you can port EverBEEN completely to a different database by implementing two modules and creating one descriptor. Substituting the default `LOGBack` implementation for another `slf4j` implementation is fairly easy, too. Other possible extensions are in store for the future.

*Maintainable code*
:	Using modular design, modern technologies and flexible programming techniques, we managed to shrink the core EverBEEN codebase to under 70,000 lines of code while preserving most of the original project's functionality. Compared to over 160,000 lines of WillBEEN code, we have created an easily maintainable piece of software without sacrificing important features.
