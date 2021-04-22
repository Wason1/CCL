SELECT
    ACTIVE_IND, effective_date=format(end_effective_dt_tm,"yyyy-mm-dd"), username
FROM
    prsnl
WHERE
    username="HOMERS8"
WITH		
	time = 120,
	maxrec = 100