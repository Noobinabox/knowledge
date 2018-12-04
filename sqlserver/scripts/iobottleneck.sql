 /*****************************************************************************************
** File:	iobottleneck.sql
** Name:	IO Bottle Neck
** Desc:	Gets the current IO counters in all databases to determine if there is a disk issue
** Auth:	NoobInABox
** Date:	Mar 1, 2016
********************************************************
** Change History
********************************************************
** PR	Date		Author			Description	
** --	----------	------------	------------------------------------
** 1	3/1/2016	NoobInABox		Created
*****************************************************************************************/

SELECT
	 DB_NAME(fs.database_id) AS [DatabaseName]
	,mf.physical_name
	,io_stall_read_ms
	,num_of_reads
	,CAST(io_stall_read_ms / (1.0 + num_of_reads) AS NUMERIC(10, 1)) AS [avg_read_stall_ms]
	,io_stall_write_ms
	,num_of_writes
	,CAST(io_stall_write_ms / (1.0 + num_of_writes) AS NUMERIC(10, 1)) AS [avg_write_stall_ms]
	,io_stall_read_ms + io_stall_write_ms AS [io_stalls]
	,num_of_reads + num_of_writes AS [total_io]
	,CAST((io_stall_read_ms + io_stall_write_ms) / (1.0 + num_of_reads + num_of_writes) AS NUMERIC(10, 1)) AS [avg_io_stall_ms]
FROM
	sys.dm_io_virtual_file_stats(NULL, NULL) AS fs
		INNER JOIN
	sys.master_files AS mf WITH (NOLOCK)
		ON fs.database_id = mf.database_id AND fs.[file_id] = mf.[file_id]
ORDER BY
	avg_io_stall_ms DESC
OPTION (RECOMPILE);

