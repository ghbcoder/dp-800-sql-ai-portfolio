
-- View the current blocking and waiting requests in the system
SELECT
    r.session_id,
    r.status,
    r.command,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.wait_resource
FROM sys.dm_exec_requests AS r
WHERE r.session_id <> @@SPID
  AND
  (
      r.blocking_session_id <> 0
      OR r.session_id IN
      (
          SELECT blocking_session_id
          FROM sys.dm_exec_requests
          WHERE blocking_session_id <> 0
      )
  )
ORDER BY r.session_id;
GO
