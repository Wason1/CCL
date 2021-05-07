SELECT
	PERSON.PERSON_ID
    , PERSON.NAME_FIRST
    , PERSON.NAME_LAST
	, ORDERS.*
;	, FACILITY_AT_TIME_OF_ORDER = UAR_GET_CODE_DISPLAY(E_ORIG.LOC_FACILITY_CD)	
;	, UNIT_AT_TIME_OF_ORDER = 
;		IF(ENCNTR_LOC_HIST.LOC_NURSE_UNIT_CD > 0) UAR_GET_CODE_DISPLAY(ENCNTR_LOC_HIST.LOC_NURSE_UNIT_CD)	
;		ELSE UAR_GET_CODE_DISPLAY(E_ORIG.LOC_NURSE_UNIT_CD)	
;		ENDIF
FROM
    ORDERS
    , (LEFT JOIN PERSON ON ORDERS.PERSON_ID = PERSON.PERSON_ID)
PLAN
    ORDERS
JOIN
    PERSON
WITH
    MAXREC=5
    TIME=20
