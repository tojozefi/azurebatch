# Running custom code in parallel with Batch Explorer
The exercise shows how to run a custom program code at scale on Azure Batch, using Batch Explorer and job templates.   
Job templates are part of [Azure Batch CLI extension](https://github.com/Azure/azure-batch-cli-extensions/blob/master/README.rst) package, see [here](https://github.com/Azure/azure-batch-cli-extensions/blob/master/doc/templates.md) for more information. 


## Preparation
1. Create a Batch account as described [here](https://docs.microsoft.com/en-us/azure/batch/batch-account-create-portal#create-a-batch-account).   
Use "Batch service" pool allocation mode in step f.

2. Install Batch Explorer   

a. Goto [Batch Explorer](https://azure.github.io/BatchExplorer/) webpage and download the Batch Explorer installer package adequate for your OS system.
![batchexplorer](screenshots/batchexplorer.png)   

b. Install Batch Explorer package (action is OS-dependent)
Tip: You may want to download a portable zip package and unzip instead of performing a full install.   

c. Start Batch Explorer (run BatchExplorer.exe or its Linux/iOS equivalent) and login to your Azure account:
![accountlogin](screenshots/accountlogin.png)
You should now see your Batch account on the Dashboard pane and the linked storage account in the top-right corner:
![batchexplorer-dashboard](screenshots/batchexplorer-dashboard.png)

## Custom code execution
### 1. Build the custom program
The custom code used in our example is a simple C program [factorize.c](factorize.c) calculating factorization of integer numbers. 
The program reads integers from an input file provided as the first command-line argument and stores the result to an output file provided as the 2nd command-line argument.

Compile the source code e.g. on a Linux system and get familiar with the program operation:
```bash
$ gcc -o factorize factorize.c
$ ./factorize
Missing command-line argument, syntax: ./factorize <input> <output>
```
Tip: If you don't have a working Linux system at hand, you may want to use [Azure cloud shell](https://shell.azure.com) in your Azure account (select Bash)

As an example, let's calculate factorization of all numbers from 1 to 100:
```bash
$ seq 1 100 > inputfile
$ ./factorize inputfile outputfile
$ less outputfile
```
### 2. Create application package
1. Compress the program executable with zip:
```bash
$ zip factorize.zip factorize
```
Download the zip package to your local system.

2. Create an Azure Batch application package

Goto *Packages* tab in Batch Explorer and click '+' icon:
![packages](screenshots/batchexplorer-packages.png)

Fill out the create apppackage form fields and click *Select a package* button to upload the program zip file:
![apppackage](screenshots/batchexplorer-apppackage.png)

Click *Save and close* button to save the application package. 

### 3. Create an input file group

Generate the input fileset for parallel calculation. In our example we're generating 10 identical input files with numbers from 1 to 500000:  
```bash
$ mkdir input; cd input
$ seq 1 500000 > input1
$ for i in `seq 2 10`; do cp input1 input$i; done
$ cd ..; zip input.zip input
```
Download the zip file to your local system and uncompress. You should have a folder *input* with 10 input files inside. 

Goto *Data* tab in Batch Explorer and click '+' icon to create a new file group, selecting *From local folder (filegroup)*:
![input-filegroup](screenshots/input-filegroup.png)

Provide a name for the filegroup (e.g. *fgrp-input*), the path to *input* folder on your local system and confirm with *Create and close* button:
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

Select OS image (equivalent to the Linux distribution that you used to build *factorize* program) and virtual machine size for the pool e.g. *Standard_F1*:
![pool-form-2](screenshots/pool-form-2.png)

Select application package *factorize v1.0* and click *Save and close* button to create the pool.
![pool-form-3](screenshots/pool-form-3.png)

### 6. Run the *factorize* job using a job template 
The job template used in our example implements a task-per-file task factory which generates a task for each file in the defined input filegroup. See [here](https://github.com/Azure/azure-batch-cli-extensions/blob/master/doc/taskFactories.md) for more information about task factories.   

The tasks will process all files in the input filegroup in parallel and generate the relevant output files with names appended by defined extension.

#### 6a. Run the job using a local template
a. Download the *factorize* program's [job template](factorize-job.json) to the local filesystem.

b. Load the *factorize* program's job template into Batch Explorer.

Goto *Gallery* tab in Batch Explorer and click *Pick a local template* button: 
![gallery-localtemplate](screenshots/gallery-picklocaltemplate.png)

c. In the job template form that opens select the pool and provide a name for the job:
![mylibrary-jobtemplate-runform](screenshots/mylibrary-jobtemplate-runform.png)
Output extension is appended to the name of the input file to construct an output filename.

You may want to modify the output extension or input and output filegroups in the appropriate fields, or you may just leave the default values. 

Click *Run and close* button and wait for the job to start.

#### 6b. Run the job using Batch Explorer local gallery template
a. Create a local folder in your system for storing Batch Explorer templates an unzip [factorize-template.zip](factorize-template.zip) package to this folder.

b. Load the *factorize* program's job template into Batch Explorer local gallery.

Goto *Gallery* tab in Batch Explorer and click *My library* button: 
![gallery-mylibrary](screenshots/gallery-mylibrary.png)

Add your template folder to the library:
![gallery-mylibrary-addfolder](screenshots/gallery-mylibrary-addfolder.png)

Find *job.template.json* template under *factorize* folder the left pane and open it:
![mylibrary-jobtemplate](screenshots/mylibrary-jobtemplate.png)

c. Run the job template by clicking the green arrow button in the top-right corner:
![mylibrary-jobtemplate-run](screenshots/mylibrary-jobtemplate-run.png)

d. In the job template form that opens select the pool and provide a name for the job:
![mylibrary-jobtemplate-runform](screenshots/mylibrary-jobtemplate-runform.png)
Output extension is appended to the name of the input file to construct an output filename.

You may want to modify the output extension or input and output filegroups in the appropriate fields, or you may just leave the default values. 

Click *Run and close* button and wait for the job to start.

### 7. Monitor the job execution
Once the job is started Batch Explorer should open the job status page where you can monitor live the job progress:
![job-status](screenshots/job-status.png)
You can observe all the tasks created in the job and monitor their status.  
Hint: You may want to check the status of the pool executing the job by clicking its link under the job name.

After the job is finished goto *Data* tab and open the output filegroup:
![job-output](screenshots/job-output.png)
You can find the output and stdout+stderr log files of all tasks in *outputs* and *logs* folders under the job folder.  
Hint: You can display the file content directly in Batch Explorer or download the files to your local system with the right-click download context command.
