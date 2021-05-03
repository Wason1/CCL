SELECT
    P.name_first,
    P.name_last,
    P.username,
    P.ACTIVE_IND,
    P.END_DATE=format(end_effective_dt_tm,"YYYY-MM-DD"),
FROM
    prsnl   P,
    EA_USER   E
PLAN E

WHERE
    ; enter the user names you want to have a look at below.
    username IN("HOMERS8", "HOMERS9", "KARADUH", "WHITTLJ2")

JOIN P WHERE P.USERNAME = E.USERNAME
ORDER BY name_last
WITH		
	time = 120,
	maxrec = 100