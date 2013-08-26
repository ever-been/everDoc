## Web Interface {#user.webinterface}

The Web Interface provides everything you need to work with the BEEN cluster.
   

### Connecting to the cluster {#user.webinterface.connecting}
When the web interface starts, it knows nothing about cluster. You have to provide cluster connection credentials to connect web interface with BEEN. If you run your nodes with default configuration, default username, port and password is prefilled in the login form. Click on **connect** to connect web interface with the cluster.

![Login](images/wi/login_page_01.png)



### Cluster overview {#user.webinterface.overview}
Overview page tends quick overview about connected nodes, node resources, running or failed tasks/task contexs/benchmarks and current logs from tasks and services.

![Cluster overview](images/wi/overview_01.png)



### Packages listig and package uploading {#user.webinterface.packages}
If the software repository is connected, you can list and download already uploaded packages, otherwise you will see notification about disconnected repository.

![Uploaded packages](images/wi/packages_listing_01.png)

Also, if the software repository running and connected, you can upload new BPK packages directly through web interface.

![Uploading new package](images/wi/packages_uploading_01.png)



### Cluster info and service logs {#user.webinterface.clusterinfo}
On the cluster info page you can information about connected services and their state. You can also find here list of connected cluster member. Beware, cluster member means node connected to the hazelcast cluster. Cluster member is not synonym of BEEN member.

![Cluster info](images/wi/cluster_01.png)

You can download service logs from any period on service logs page.

![Service logs](images/wi/service_logs_01.png)




### Runtimes {#user.webinterface.runtimes}
You can see all connected host runtimes on this page in well-aranged table with some more basic information about each runtime. 

![Listing runtimes](images/wi/runtimes_01.png)


### Benchmarks and tasks {#user.webinterface.tasktree}
If you want to run some task/task context/benchmark, you can do it on this page. You can se here informations about running tasks/task contexts/ benchmarks and you can kill them or remove them from the BEEN cluster. When you want to kill benchmark, click on **kill** button next to the *benchmark id*. If you do this, all running tasks will be finished and no new tasks and contexts will be started. When the benchmark is killed or finished, you can remove it from the cluster by clicking on **remove** button next to the benchmark id. If you do it, all entities related to this benchmark and it's task contexts and contexts and all persisted records from this benchmark will be deleted, including logs and results. If you want to remove all **finished** benchmarks, you can use button **remove finished benchmarks** int rhe right top corner of the page.

![Benchmark tree](images/wi/benchmark_tasks__benchmark_tree_01.png)




<!--
![Benchmark detail](images/wi/benchmark_detail_01.png)
![Submit new item](images/wi/benchmark_tasks__submit_new_item_01.png)
![Listing task contexts](images/wi/benchmark_tasks__task_contexts_01.png)
![Listing tasks](images/wi/benchmark_tasks__tasks_01.png)
![Debugged tasks](images/wi/debug_01.png)
![Result display example](images/wi/evaluator_result_example_01.png)
![Debugging BEEN](images/wi/example_been_debug_page_01.png)
![Example of error page](images/wi/example_error_page_01.png)
![Listing evaluated results](images/wi/results_01.png)
![Runtime detail](images/wi/runtime_detail_01.png)
![Task context detail](images/wi/task_context_detail_01.png)
![Task detail](images/wi/task_detail_01.png)
![Task logs](images/wi/task_logs_detail_01.png)
-->


## EverBEEN controls
* overview description
* viewing service status
* how to submit task to SW repo
* how to submit task/context/benchmark
* viewing outcomes & getting to logs
* explain how to clean up after something (& what does it delete)
* ...
* any other tutorials that come to mind



