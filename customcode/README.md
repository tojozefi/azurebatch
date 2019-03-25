# Running custom code in parallel with Batch Explorer
The exercise shows how to run a custom program code at scale on Azure Batch, using Batch Explorer and job templates. 

Job templates are part of [Azure Batch CLI extension](https://github.com/Azure/azure-batch-cli-extensions/blob/master/README.rst) package, see [here](https://github.com/Azure/azure-batch-cli-extensions/blob/master/doc/templates.md) for more information. 


## Preparation
### 1. Create a Batch account
1. Login to [Azure portal](https://portal.azure.com), click on "Create a resource", type "batch service" in the search box and select *Batch service* from the list:
![batchaccount-create](screenshots/batchaccount-create.png)

2. Click "Create" button and fill out the Batch account creation form.
![batchaccount-create-form](screenshots/batchaccount-create-form.png)

3. Click "Select storage account" and create a storage account linked to your Batch account:
![batchaccount-create-storage](screenshots/batchaccount-create-storage.png)

4. Click "Review+create" button and then "Create" to confirm creation of the Batch account:
![batchaccount-create-confirm](screenshots/batchaccount-create-confirm.png)

### 2. Install Batch Explorer
*Note: Instructions below assume version 0.19.2 of Batch Explorer.*

1. Goto [Batch Explorer](https://azure.github.io/BatchExplorer/) webpage and download the Batch Explorer installer package adequate for your OS system.
![batchexplorer](screenshots/batchexplorer.png)

2. Install Batch Explorer package (action is OS-dependent)
Tip: You may want to download a portable zip package and unzip instead of performing a full install.

3. Start Batch Explorer (run BatchExplorer.exe or its Linux/iOS equivalent) and login to your Azure account:
![accountlogin](screenshots/accountlogin.png)
You should now see your Batch account on the Dashboard pane and the linked storage account in the top-right corner:
![batchexplorer-dashboard](screenshots/batchexplorer-dashboard.png)

## Custom code execution
### 1. Build the custom program
The custom code used in our example is a simple C program [factorize.c](factorize.c) calculating factorization of integer numbers. 
The program reads integers from an input file given as the first command-line argument and stores the result to an output file given as the 2nd command-line argument.

Compile the source code e.g. on a Ubuntu 18.04 system and get familiar with the program operation:
```bash
$ gcc -o factorize factorize.c
$ ./factorize
Missing command-line argument, syntax: ./factorize <input> <output>
```
As an example, let's calculate factorization of all numbers from 1 to 500000:
```bash
$ seq 1 500000 > input
$ ./factorize input output
$ less output
```
### 2. Create application package
1. Compress the program executable with zip:
```bash
$ zip factorize.zip factorize
```

2. Create an Azure Batch application package

Goto *Packages* tab in Batch Explorer and click '+' icon:
![packages](screenshots/batchexplorer-packages.png)

Fill out the create apppackage form fields and click *Select a package* button to upload the program zip file:
![apppackage](screenshots/batchexplorer-apppackage.png)

Click *Save and close* button to save the application package. 

### 3. Create an input file group

Generate the input files and download to local folder:
```bash
$ mkdir input
$ for i in `seq 1 10`; do cp input input$i; done
$ zip input.zip input? input10
```
(In this example we're generating 10 identical input files with numbers from 1 to 500000)

Goto *Data* tab in Batch Explorer and create a file group with the generated input files.
![input-filegroup](screenshots/input-filegroup.png)

Hint: You can create a file group and upload the input files directly from a folder on your local system:
![input-fromfolder](screenshots/input-filegroup-fromfolder.png)

### 4. Create an output filegroup 
Goto *Data* tab in Batch Explorer and create an empty file group:
![output-filegroup](screenshots/output-filegroup.png)

Provide a name for the output filegroup, e.g. *output*:
![output-filegroup-name](screenshots/output-filegroup-name.png)

### 5. Create an Azure Batch pool
Goto *Pools* tab in Batch Explorer and click '+' icon to create a new pool. 
Provide the pool name e.g. *factorize-pool* and the amount of nodes e.g. *10*:
![pool-form-1](screenshots/pool-form-1.png)

Select OS image *Ubuntu 18.04* and virtual machine size *Standard_F1*:
![pool-form-2](screenshots/pool-form-2.png)

Select application package *factorize v1.0* and click *Save and close* button to create the pool.
![pool-form-3](screenshots/pool-form-3.png)

### 6. Run the job from the template
a. Create a local folder in your system for storing Batch Explorer templates an unzip [factorize-template.zip](factorize-template.zip) package to this folder.

b. Goto *Gallery* tab in Batch Explorer and click *My library* button: 
![gallery-mylibrary](screenshots/gallery-mylibrary.png)

Add your template folder to the library:
![gallery-mylibrary-addfolder](screenshots/gallery-mylibrary-addfolder.png)
Find *job.template.json* template under *factorize* folder the left pane and open it:
![mylibrary-jobtemplate](screenshots/mylibrary-jobtemplate.png)
The job template used in our example implements a task-per-file task factory which generates a task for each file in the defined input filegroup. See [here](https://github.com/Azure/azure-batch-cli-extensions/blob/master/doc/taskFactories.md) for more information about task factories.   

The tasks will process all files in the input filegroup.

c. Run the job template by clicking the green arrow button in the top-right corner:
![mylibrary-jobtemplate-run](screenshots/mylibrary-jobtemplate-run.png)

d. In the job template form that opens select the pool and provide a name for the job:
![mylibrary-jobtemplate-runform](screenshots/mylibrary-jobtemplate-runform.png)
Output extension is appended to the name of the input file to construct an output filename.

You may want to modify the output extension or select different filegroups for input or output in the appropriate fields, or you may just leave the default values. 

Click *Run and close* button and wait for the job to start.

e. Once the job is started Batch Explorer should open the job status page where you can monitor live the job progress:
![job-status](screenshots/job-status.png)
You can observe all the tasks created in the job and monitor their status.

Hint: You may want to check the status of the pool executing the job by clicking its link under the job name.

f. After the job is finished goto *Data* tab and open the output filegroup:
![job-output](screenshots/job-output.png)
You can find the output and stdout+stderr log files of all tasks in *outputs* and *logs* folders under the job folder 

Hint: You can display the file content directly in Batch Explorer or download the files to your local system with the right-click download context command.
