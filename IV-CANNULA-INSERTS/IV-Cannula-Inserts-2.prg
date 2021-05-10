; Note this does not work yet. It won't do what you think it does

SELECT 
	CV1.CODE_VALUE
	,CV1.DISPLAY
	,CV1.CDF_MEANING
	,CV1.DESCRIPTION
	,CV1.DISPLAY_KEY
	,CV1.CKI
	,CV1.DEFINITION
FROM CODE_VALUE CV1

WHERE
    CV1.CODE_SET =  72 AND
    CV1.ACTIVE_IND = 1 AND
    CV1.CODE_VALUE IN(6775376, 26785572, 79849891, 86303711)
    ;Peripheral IV Insertion/Resite, Peripheral IV Insertion, ED Peripheral IV Insertion, Peripheral IV Insertion Date/Time:
WITH  FORMAT
, TIME = 60