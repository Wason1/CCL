select

;Number of IV cannula inserted in ED per day over the past 6 months
;Sort into 3 ED’s
;•	SH, FH, WTN

org.org_name
,enct_code = uar_get_code_display(ecn.encntr_type_cd)
,enct_histy_code = uar_get_code_display(ELH.encntr_type_cd)
,encntr_type_cd = nullval(ELH.encntr_type_cd,ECN.encntr_type_cd) 
;,ECN_encntr_type_cd = ECN.encntr_type_cd ;,ELH_encntr_type_cd = ELH.encntr_type_cd

,ecn.organization_id 
,org.org_name
,location_facility = uar_get_code_display(ecn.loc_facility_cd)
, urn_alias = ea_URN.alias
, FIN_number =  ea_visit.alias
,p.name_full_formatted 
,ce.ENCNTR_ID 
,startevent = format(ce.EVENT_START_DT_TM , "dd/mm/yyyy hh:mm:ss")
;, endevent = format(ce.EVENT_END_DT_TM , "dd/mm/yy")
,cdl.LABEL_NAME 
,Event_resul2 = Concat	(
						trim(uar_get_code_display(ce.EVENT_CD))," ",
						if ( ce.RESULT_VAL = ce.EVENT_TAG) ce.EVENT_TAG else concat(trim(ce.EVENT_TAG,5)," ", ce.RESULT_VAL) endif
						)

 
 from clinical_event CE
 ,(left join V500_EVENT_CODE ec on ce.EVENT_CD = ec.EVENT_CD)
 ,(left join CE_EVENT_ACTION cea on cea.event_id = ce.event_id)
 ,(left join CE_DYNAMIC_LABEL CDL ON CE.CE_DYNAMIC_LABEL_ID = CDL.CE_DYNAMIC_LABEL_ID)
 ,(left join DYNAMIC_LABEL_TEMPLATE DLT on DLT.LABEL_TEMPLATE_ID = CDL.LABEL_TEMPLATE_ID)
 ,(LEFT JOIN DOC_SET_REF DSR ON DSR.DOC_SET_REF_ID = DLT.DOC_SET_REF_ID )
 
 
 
 ,(left join encounter ecn on ce.encntr_id = ecn.encntr_id) 
 , (left join encntr_loc_hist elh on elh.encntr_id = CE.encntr_id	
	and elh.active_ind = 1	; to remove inactive rows that seem to appear for unknown reason(s)
	and elh.pm_hist_tracking_id > 0	; to remove duplicate row that seems to occur at discharge
	and elh.beg_effective_dt_tm <= ce.EVENT_START_DT_TM	; encounter location began before order was placed
	and elh.end_effective_dt_tm >= ce.EVENT_START_DT_TM	; encounter location ended after order was placed
	)	
	
	
	
	
	 
 , (left join encntr_alias ea_URN on ea_URN.encntr_id = ce.encntr_id	
	and ea_URN.encntr_alias_type_cd = 1079	; 'URN' from code set 319
	and ea_URN.active_ind = 1	; active URNs only
	and ea_URN.end_effective_dt_tm > sysdate	; effective URNs only
	)	
, (left join encntr_alias ea_visit on ea_visit.encntr_id = ce.encntr_id	
	and ea_visit.encntr_alias_type_cd = 1077	; 'FIN NBR' from code set 319
	and ea_visit.active_ind = 1	; active FIN NBRs only
	and ea_visit.end_effective_dt_tm > sysdate	; effective FIN NBRs only
	)	
 ,(left join organization org on ecn.organization_id = org.organization_id)
 ,(	inner join person p on p.person_id = ce.person_id ;and p.person_id = 12630809 
 	and p.ACTIVE_IND = 1 and p.NAME_LAST_KEY != "TESTWHS"
   )
 
plan CE
join ec
join cea
join cdl
join dlt
join dsr 
join ecn
join elh
;join ea
join ea_URN
join ea_visit
join org
join p 

 
where dsr.DOC_SET_NAME_KEY IN ("PERIPHERAL IV RG","CENTRAL LINE RG")
and cnvtlower(ea_visit.alias) like "emg*" 
and cnvtlower(cdl.LABEL_NAME) like "*cannula*"
and ce.event_cd = 79847746 ;Peripheral IV Activity only
and (	cnvtlower(ce.EVENT_TAG) like "*insert*" or cnvtlower(ce.RESULT_VAL) like "**insert*" 	)
and ce.event_start_dt_tm >= CNVTDATETIME("01-NOV-2020")
and ce.event_start_dt_tm < CNVTDATETIME("01-MAY-2021")

and nullval(ELH.encntr_type_cd,ECN.encntr_type_cd) = 309310   ;Emergency encounter type
AND CE.PUBLISH_FLAG = 1 ;published events only
AND CE.RESULT_STATUS_CD != 31 	;Unknown variables, from dashboard code
AND CE.authentic_flag = 1 		;Unknown variables, from dashboard code
AND CE.CE_DYNAMIC_LABEL_ID > 0 	;Unknown variables, from dashboard code

order by p.name_full_formatted, org.org_name, year(ce.event_start_dt_tm), month(ce.event_start_dt_tm), day(ce.event_start_dt_tm)
with time = 600, maxrec = 999999