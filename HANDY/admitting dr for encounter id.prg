SELECT
	 E_ENCNTR_PRSNL_R_DISP = UAR_GET_CODE_DISPLAY(E.ENCNTR_PRSNL_R_CD)
	, ADMITTING_DR_PID = E.PRSNL_PERSON_ID
	, E.ENCNTR_ID
	, E.ACTIVITY_DT_TM
	, E_ENCNTR_TYPE_DISP = UAR_GET_CODE_DISPLAY(E.ENCNTR_TYPE_CD)


FROM
	ENCNTR_PRSNL_RELTN   E

WHERE
	E.encntr_id = XXXXXXX ; Enter Encounter Id
	AND
	ENCNTR_PRSNL_R_CD = 1116 ; this filters for addmitting Dr

ORDER BY
	E.UPDT_DT_TM   DESC

WITH MAXREC = 100, NOCOUNTER, SEPARATOR=" ", FORMAT
