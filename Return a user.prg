SELECT
    name_first, name_last, username, ACTIVE_IND, END_DATE=format(end_effective_dt_tm,"YYYY-MM-DD")
FROM
    prsnl
WHERE
    ; enter the user names you want to have a look at below.
    username IN("HOMERS8", "HOMERS9", "BARB1", "WHITTLJ2")
    
ORDER BY name_last
WITH		
	time = 120,
	maxrec = 100