SELECT
	P.BEG_EFFECTIVE_DT_TM
	, P.USERNAME
    ; DATE FORMAT SHOWN BELOW
	, DATE = P.BEG_EFFECTIVE_DT_TM "YYYY-DD-MM HH:MM:SS;;D"

FROM
	PRSNL   P

WITH MAXREC = 100, NOCOUNTER, SEPARATOR=" ", FORMAT



/* OPTION 2 USING BETWEEN 
WHERE 
    O.ORDER_MNEMONIC = "CMP" OR O.ORDER_MNEMONIC = "BUN"
    AND 
    O.ORIG_ORDER_DT_TM BETWEEN 
        CNVTDATETIME("01-JAN-2014 00:00:00.00")
        AND
        CNVTDATETIME("31-JAN-2014 23:59:59:.00")
 */