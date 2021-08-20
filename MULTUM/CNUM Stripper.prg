; CNUM update (non-domain-specific)	"
; replace "sufentanil with the item you wish to alter"
update into order_catalog_synonym ocs
set ocs.cki = null
, ocs.concept_cki = null
, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, ocs.updt_id = reqinfo->updt_id
, ocs.updt_cnt = ocs.updt_cnt + 1
where ocs.mnemonic = "sufentanil"
;"
