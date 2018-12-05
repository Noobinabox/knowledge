# Changing Standard or Enterprise SQL to Developer Edition
The following is a downgrade trick to change the SQL Server edition to Developer from Standard and/or Enterprise.

Before attempting these steps you should take backups of ALL databases (system and user). Make a note of the location of various components (system databases and shared components) in the operating system. This will only work if the paths are not changed.

* Open Reporting Service Configuration and take a backup of the encrypted keys.
* Use SSMS and connect to SQL, you'll need to run teh following query for EACH database.
```sql
	SELECT * FROM sys.dm_db_persisted_sku_features;
```
* The above DMV will tell us if the database is utilizing any of the "Enterprise Only" features (like partitioning, compression, etc). If there is any such feature which is not support on the destination editions, you should remove it, otherwise the database will not come online afterwards.
* Run ``SELECT @@VERSION`` and make note of the exact version and build number (such as 11.00.3000 - which is SQL 2012 SP1). This is needed because you have to upgrade the newly install SQL instance to the exact same build later.
* Stop SQL Server services and copy all the database files. YOu need to copy all mdf, ldf, and ndf files for system and user databases.
* Now you can safetly uninstall SQL Server. You should take a screenshot of the "Select Features" screen while uninstalling so you can be certain to install the correct features when installing again in the later steps.
* Reboot, if necessary.
* Now, install the new SQL Server instance having the SAME name and SAME path as the earlier instance.
* Since you'll want to reuse teh databases, we need to apply SQL Server patches so that the version matches with what you had earlier. (11.00.3000 in the example above)
* Take a backup of the current database to make sure you can revert to this state.
* Stop SQL Server services.
* Move all the database files back to their original locations, you'll also need to replace the system database files with their previous path.
* Start SQL Server services back up.
* Verify that all the databases are online and healthy again with the new Developer Edition.
