select
ecn.organization_id
,org.org_name
;,p.person_id
,p.name_full_formatted
;,ce.CLINICAL_EVENT_ID
,ce.ENCNTR_ID
;,ce.EVENT_START_DT_TM
,startevent = format(ce.EVENT_START_DT_TM , "dd/mm/yy hh:mm")
;,ce.EVENT_END_DT_TM
;, endevent = format(ce.EVENT_END_DT_TM , "dd/mm/yy hh:mm")
,cdl.LABEL_NAME ;,ce.EVENT_TAG ;,ce.RESULT_VAL
,Event_Result = if ( ce.RESULT_VAL = ce.EVENT_TAG) ce.EVENT_TAG else concat(trim(ce.EVENT_TAG,5)," ", ce.RESULT_VAL) endif
;,dsr.DOC_SET_NAME
;,dsr.DOC_SET_NAME_KEY
 from clinical_event CE
; ,(left join CE_EVENT_ACTION cea on cea.event_id = ce.event_id)
 ,(left join CE_DYNAMIC_LABEL CDL ON CE.CE_DYNAMIC_LABEL_ID = CDL.CE_DYNAMIC_LABEL_ID)
 ,(left join DYNAMIC_LABEL_TEMPLATE DLT on DLT.LABEL_TEMPLATE_ID = CDL.LABEL_TEMPLATE_ID)
 ,(LEFT JOIN DOC_SET_REF DSR ON DSR.DOC_SET_REF_ID = DLT.DOC_SET_REF_ID )
 ,(left join encounter ecn on ce.encntr_id = ecn.encntr_id)
 ,(left join organization org on ecn.organization_id = org.organization_id)
 ,(inner join person p on p.person_id = ce.person_id ;and p.person_id = 12630809
 and p.ACTIVE_IND = 1  )
plan CE
join cdl
join dlt
join dsr
join ecn
join org
join p
where 1=1
and dsr.DOC_SET_NAME_KEY IN ("PERIPHERAL IV RG","CENTRAL LINE RG")
and year(ce.event_start_dt_tm) = 2021
and month(ce.event_start_dt_tm) = 5
and day(ce.event_start_dt_tm) >= 5
and (	cnvtlower(ce.EVENT_TAG) like "*remove*" or cnvtlower(ce.EVENT_TAG) like "*insert*"
		or cnvtlower(ce.RESULT_VAL) like "*remove*" or cnvtlower(ce.RESULT_VAL) like "**insert*" )
with time = 600, maxrec = 10000