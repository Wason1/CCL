SELECT
	D.DIAGNOSIS_ID
	, D.DIAGNOSIS_GROUP
	, D.DIAGNOSIS_DISPLAY
	, D.PERSON_ID
	, D_DIAG_TYPE_DISP = UAR_GET_CODE_DISPLAY(D.DIAG_TYPE_CD)
	, D.ACTIVE_IND
	, D.ENCNTR_ID

FROM
	DIAGNOSIS   D

WHERE
	D.PERSON_ID = XXXXX ; Enter patient ID here
	AND (
    D.DIAG_TYPE_CD = 3538765 ;additional dx
    OR 
    D.DIAG_TYPE_CD = 3538766 ;principal dx
  )

WITH MAXREC = 1000, NOCOUNTER, SEPARATOR=" ", FORMAT
