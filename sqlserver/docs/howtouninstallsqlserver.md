# How to Properly Uninstall SQL Server
This page describes how to uninstall a stand-alone instance of SQL Server.
> **IMPORTANT!** To uninstall an instance of SQL Server, you must be a local administrator with permissions to log on as a service.
## Before you Uninstall
1. **Back up your data.** Although this is not a required step, you might want to save the databases in their present state. You might also want to save changes that were made to the system databases. If either scenarios are true, make sure to back up the data before uninstalling SQL Server. Alternatively, save a copy of all the data and log files in a folder other than the MSSQL folder. The MSSQL folder is deleted during the un-installation.

The files that you must save include the following database files:
* master.mdf
* mastlog.ldf
* model.mdf
* modellog.ldf
* msdbdata.mdf
* msdblog.ldf
* ReportServer[InstanceName] --This is the Reporting Service default databases.

2. **Delete the local security groups.** Before you uninstall SQL Server, delete the local security groups for SQL Server Components.
3. **Stop all services.** I recommend that you stop all SQL Server services before you uninstall SQL Server compoments. (Active connections can prevent successful uninstalls.)
4. **Use an account that has appropriate permissions.**

## To Uninstall an Instance of SQL Server
1. To begin the uninstall process, go to **Control Panel** and then **Programs and Features**, or **Start** -> **Run** -> appwiz.cpl
2. Right click on **SQL Server (Version)** and select **Uninstall**. Then click **Remove**. This will start the SQL Server Installation Wizard.
3. On the Select Instace page, use the drop-down box to specify an instance of SQL Server to remove, or specify the option to remove only the SQL Server shared features and management tools. To continue, click **Next**.
4. On the Select Features page, specify the features to remove from the specified instance of SQL Server.
  1. Removal rules runs to verify that the operation can complete successfully.
5. On the **Ready to Remove** page, review the list of components and features that will be uninstalled. Click **Remove** to begin uninstalling.
6. Immediately after you uninstall the last SQL Server instance, to other programs associated with SQL Server will still be visible in the list of programs in **Programs and Features**. However, if you close **Programs and Features**, the next time you open **Programs and Features**, it will refresh the list of programs, to show only the ones that are actually installed.
