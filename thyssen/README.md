# BatchLabs template for ThyssenKrupp custom code

## Create Azure Batch application package with custom code
Compile the source code on Ubuntu system:
```bash
$ gcc -o thyssen thyssen.c
```
Compress with zip:
```bash
$ zip thyssen.zip thyssen
```

Create an application package in BatchLabs and upload the zip file:
![apppackage](screenshots/apppackage.PNG)
