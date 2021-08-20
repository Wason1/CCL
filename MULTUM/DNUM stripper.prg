; DNUM update (non-domain-specific)	"
; replace "sufentanil" with name of the item you wish to alter
; this will disassociate the DNUM with the item, sometimes referring to de-multimising

update into order_catalog oc
set oc.cki = " "
, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, oc.updt_id = reqinfo->updt_id
, oc.updt_cnt = oc.updt_cnt + 1
where oc.primary_mnemonic = "sufentanil"

update into code_value cv
set cv.cki = " "
, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, cv.updt_id = reqinfo->updt_id
, cv.updt_cnt = cv.updt_cnt + 1
where cv.code_value = (select catalog_cd from order_catalog where primary_mnemonic = "sufentanil")

update into order_catalog_synonym ocs
set ocs.cki = null
, ocs.concept_cki = null
, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, ocs.updt_id = reqinfo->updt_id
, ocs.updt_cnt = ocs.updt_cnt + 1
where ocs.mnemonic = "sufentanil"
;"
