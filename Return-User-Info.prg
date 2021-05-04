SELECT
    P.name_first
    , P.name_last
    , P.username
    , E.DIRECTORY_IND
    , END_DATE = format(P.end_effective_dt_tm, "YYYY-MM-DD")
FROM
    prsnl	P
    , (LEFT JOIN ea_user	E ON E.username = P.username)
PLAN
	P
WHERE
    ;Enter the user names you want to have a look at below.
    P.username IN ("HOMERS8", "HOMERS9", "KARADUH", "WHITTLJ2")

JOIN
	E
ORDER BY
	P.name_last
WITH
	time = 120
	, maxrec = 100