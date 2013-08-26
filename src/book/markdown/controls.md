## Web Interface {#user.webinterface}

The Web Interface provides everything you need to work with the BEEN cluster.
   

### Connecting to the cluster {#user.webinterface.connecting}
When the web interface starts, it knows nothing about cluster. You have to provide cluster connection credentials to connect web interface with BEEN. If you run your nodes with default configuration, default username, port and password is prefilled in the login form. Click on **connect** to connect web interface with the cluster.

![Login](images/wi/login_page_01.png)



### Cluster overview {#user.webinterface.overview}
Overview page tends quick overview about connected nodes, node resources, running or failed tasks/task contexs/benchmarks and current logs from tasks and services.

![Cluster overview](images/wi/overview_01.png)



### Package listing and package uploading {#user.webinterface.packages}
Click on the **Packages** tab. If the software repository is connected, you can list and download already uploaded packages, otherwise you will see notification about disconnected repository.

![Uploaded packages](images/wi/packages_listing_01.png)

Also, if the software repository running and connected, you can upload new BPK packages directly through web interface.

![Uploading new package](images/wi/packages_uploading_01.png)



### Cluster info and service logs {#user.webinterface.clusterinfo}
To view cluster info click on **Clusted** tab. On the cluster info page you can information about connected services and their state. You can also find here list of connected cluster member. Beware, cluster member means node connected to the hazelcast cluster. Cluster member is not synonym of BEEN member.

![Cluster info](images/wi/cluster_01.png)

Cick on **Service logs** subtab where you can dow download service logs from any period.

![Service logs](images/wi/service_logs_01.png)




### Runtimes {#user.webinterface.runtimes}
Click on the **Runtimes** tab. Here you can see all connected host runtimes in well-aranged table with basic information about each runtime. 

![Listing runtimes](images/wi/runtimes_01.png)

You can display runtime detail by clicking on runtime id.

![Runtime detail](images/wi/runtime_detail_01.png)




### Benchmarks and tasks {#user.webinterface.tasktree}
If you want to run some task/task context/benchmark, you can do it on the **Benchmarks & Tasks** page. Here you can see information about running tasks, task contexts and benchmarks. You can kill them or remove them from the BEEN cluster. When you want to kill benchmark, click on **kill** button next to the *benchmark id*. If you do this, all running tasks will be finished and no new tasks and contexts will be started. When the benchmark is killed or finished, you can remove it from the cluster by clicking on **remove** button next to the benchmark id. If you do it, all entities related to this benchmark and it's task contexts and contexts and all persisted records from this benchmark will be deleted, including logs and results. If you want to remove all finished benchmarks, you can use button **remove finished benchmarks** in the right top corner of the page.

![Benchmark tree](images/wi/benchmark_tasks__benchmark_tree_01.png)



### Submitting new task, task context or benchmark {#user.webinterface.submititem}
If you want to submit and run new task, task context or benchmark, you can do it by clicking the button **Submit new item** on the **Benchmarks & Tasks** page. Submit page will offer you all possible descriptors from all uploaded BPKs and all saved named descriptors to run.
 
![Submitting new item](images/wi/benchmark_tasks__submit_new_item_01.png)

If you click on the **submit** button, you can edit selected descriptor or just use prepared template. If you want, you can name edited descriptor and save it for future use.

![Submitting benchmark](images/wi/submit_benchmark_01.png)






### Listing tasks and task contexts {#user.webinterface.listingtasks}
Instead of working with benchmark tree, you can list tasks and task contexts independently. Go to tap **Tasks** or **Task contexts** on the **Benchamrks & Tasks** page. 

![Listing tasks](images/wi/benchmark_tasks__tasks_01.png)

&nbsp;&nbsp;&nbsp;&nbsp;<br/>

![Listing task contexts](images/wi/benchmark_tasks__task_contexts_01.png)



### Task, task context and benchmark detail {#user.webinterface.itemdetail}
To see task, task context or benchmark detail, click on its id everywhere on the page. In case the task/context/benchmark is running, you can kill it by clicking on **kill** button in the top right corner of the page. In case the task/context/benchmark is finished or failed, you will see the **remove** button instead of kill button in right top corner of the page. Click on this button to delete all results, logs and all service information about task from the BEEN cluster.

![Task detail](images/wi/task_detail_01.png)

&nbsp;&nbsp;&nbsp;&nbsp;<br/>

![Task context detail](images/wi/task_context_detail_01.png)

&nbsp;&nbsp;&nbsp;&nbsp;<br/>

![Benchmark detail](images/wi/benchmark_detail_01.png)





### Displaying logs from tasks {#user.webinterface.tasklogs}
To display logs from tasks, go to page with task details and click on **show logs** button in the right top corner of the page. 

![Task logs](images/wi/task_logs_detail_01.png)

If you want to see detailed informations (e.g. stack trace), click on the line with appropriate log message.

![Task logs](images/wi/task_log_detail_01.png)




### Listing and displaying evaluated results {#user.webinterface.listingresults}
If you want to list results, switch to tab **Results**. You can see here all results evaluated by evaluators. You can download them and delete them. Beware, only results from evaluators can be displayed and downloaded directly through web interface. Results stored in normal tasks are stored in object repository and their displaying is not supported.

![Listing evaluated results](images/wi/results_01.png)

You can also display evaluation result directly, but it's mime type must be supported. Supported mime types are:

* image/png
* image/jpeg
* image/gif
* text/html
* text/plain
 
![Result display example](images/wi/evaluator_result_example_01.png)


### Debugging tasks {#user.webinterface.debug}
If you want to see which tasks are running in *listen* debug mode, switch to **Debug** tab. Here you can find information about hostname and port, on which the java debugger can be connected. 

![Debugged tasks](images/wi/debug_01.png)



### Handling web interface errors {#user.webinterface.errors}
If something goes wrong or you're trying to invoke some invalid operation, web interface will show you simple error message.

![Example of error page](images/wi/example_error_page_01.png)

If you are intended in stack trace of this error, click on the **show detailed stack trace** link in right bottom corner of the page.

![Debugging Web Interface](images/wi/example_been_debug_page_01.png)
