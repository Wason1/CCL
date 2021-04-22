SELECT
    ACTIVE_IND, effective_date=format(end_effective_dt_tm,"YYYY-MM-DD"), username
FROM
    prsnl
WHERE
    ; enter the user name you want to have a look at below where "HOMERS8" is.
    username="HOMERS8"
WITH		
	time = 120,
	maxrec = 100