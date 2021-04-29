SELECT
	CV1.CODE_VALUE
	,CV1.DISPLAY
	,CV1.CDF_MEANING
	,CV1.DESCRIPTION
	,CV1.DISPLAY_KEY
	,CV1.CKI
	,CV1.DEFINITION
 FROM CODE_VALUE CV1
WHERE CV1.CODE_SET =  88 AND CV1.ACTIVE_IND = 1
WITH  FORMAT, TIME = 60