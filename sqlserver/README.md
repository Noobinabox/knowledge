# SQL Server
Here is some of my knowledge collected about SQL Server during my time as a database administrator. Please be aware that I'm an "accidental" dba and not a "real" dba.

## SQL Server Query Collection
* [Change DBOwner to SA SID](scripts/changedbownertosasid.sql)
* [Change JobOwner to SA SID](scripts/changejobownertosasid.sql)
* [Advanced sp_who2](scripts/advancedspwho2.sql)
* [Current Locks in the Database](scripts/currentlocksindatabase.sql)
* [IO Bottleneck](scripts/iobottleneck.sql)
* [Current Thread Waits](scripts/currentthreadwaits.sql)
* [Check Windows Group Membership](scripts/checkgroupmembership.sql)
* [Get Accounts with SA Access](scripts/getaccountswithsaaccess.sql)
* [Setup Encryption](scripts/encryptionsetup.sql)
* [Create Database Snapshot](scripts/createdatabasesnapshot.sql)
* [Row Level Security](scripts/rowlevelsecurity.sql)
* [Autofix Drop Orphan Users](scripts/autofixdroporphanusers.sql) - I didn't create this, but it's extremely useful
* [Get Table Sizes](scripts/gettablesizes.sql)

## SQL Server Maintenance Scripts
* [Database Backups](scripts/usp-database-backup.sql)
* [Index Rebuild & Reorganize](scripts/usp-index-maintenance.sql)
* [Statistics Maintenance](scripts/usp-statistics-maintenance.sql)
* [Setup SQL Server Agent Alerts](scripts/sqlserveragentalerts.sql)
* [Setup SQL Server Agent Jobs for Maintenance](scripts/setupsqlagentjobsonnewserver.sql)

## SQL Server Documentation
* [Changing Standard or Enterprise SQL to Developer Edition](docs/downgradeedition.md)
* [How to Properly Uninstall SQL Server](docs/howtouninstallsqlserver.md)
* [Renaming a Server that has a Stand-Alone Instance of SQL Server](docs/renaminghostwithsql.md)

