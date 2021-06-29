select distinct	; Clinical Event details	; 'distinct' used for multiple URNs on one patient
	UR_number = ea_URN.alias
    , p.name_full_formatted	
	; patient_name = "xxxx"	
	, patient_id = ce.person_id	
	, visit_no = ea_visit.alias	
	, ce.encntr_id	
	, result_valid_dates = if(ce.valid_until_dt_tm > sysdate)	
	concat(format(ce.valid_from_dt_tm, "dd/mm/yy hh:mm"), " - ")	
	else concat(format(ce.valid_from_dt_tm, "dd/mm/yy hh:mm"), " - ", format(ce.valid_until_dt_tm, "dd/mm/yy hh:mm"))	
	endif	
	, collection_dt_tm = format(ce.event_end_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, result_type = evaluate(ce.event_class_cd	
	, 223, "Date"	
	, 224, "DOC (comment/report)"	
	, 225, "Done"	
	, 226, "GRP"	
	, 228, "Immunization"	
	, 231, "mdoc"	
	, 232, "MED"	
	, 233, "NUM"	
	, 234, "Radiology"	
	, 236, "TXT (discrete)"	
	, 4091465, "IO"	
	, 654645, "Place Holder"	
	)	
	, discrete_result_value = ce.result_val	
	, discrete_result_unit = uar_get_code_display(ce.result_units_cd)	
	, discrete_result_time_unit = uar_get_code_display(ce.result_time_units_cd)	
	, report_title = ce.event_title_text	
;	, report_contents = substring(1,50,ce_b.blob_contents)	; extracts errors out if this field is included…
	, ce_contributor_system = uar_get_code_display(ce.contributor_system_cd)	
	, associated_EMR_orderable = uar_get_code_display(ce.catalog_cd)	
	, associated_EMR_order_ID = ce.order_id	
;	, associated_task_assay = uar_get_code_display(ce.task_assay_cd)	
	, result_name = uar_get_code_display(ce.event_cd)	
	, result_code = ce.event_cd	
	, clinical_event_last_update = format(ce.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, clinical_event_last_updater = if(ce.clinical_event_id > 0 and ce.updt_id = 0) "0"	
	else  p_ce.name_full_formatted	
	endif	
	, ce.event_id	
	, ce.clinical_event_id	
	, ce.reference_nbr	
		
from		
	clinical_event   ce	
	, (left join prsnl p_ce on p_ce.person_id = ce.updt_id)	
	, (left join person p on ce.person_id = p.person_id)	
	, (left join encntr_alias ea_URN on ea_URN.encntr_id = ce.encntr_id	
	and ea_URN.encntr_alias_type_cd = 1079	; URN
	and ea_URN.active_ind = 1	; active URNs only
	and ea_URN.end_effective_dt_tm > sysdate	; effective URNs only
	)	
	, (left join encntr_alias ea_visit on ea_visit.encntr_id = ce.encntr_id	
	and ea_visit.encntr_alias_type_cd = 1077	; 'FIN NBR' from code set 319
	and ea_visit.active_ind = 1	; active FIN NBRs only
	and ea_visit.end_effective_dt_tm > sysdate	; effective FIN NBRs only
	)	
;	, (left join ce_blob ce_b on ce_b.event_id = ce.event_id	
;	and ce_b.valid_from_dt_tm = ce.valid_from_dt_tm	
;	and ce_b.valid_until_dt_tm  = ce.valid_until_dt_tm	
;	)	
		
plan	ce	
where	ce.view_level = 1	; only show events visible to endusers
and	ce.valid_until_dt_tm > sysdate	; only show events that are still 'valid' (modified results show only the latest value as 'valid')
and	ce.contributor_system_cd = 86524974	; WH_LAB (Pathology results only)
and	ce.updt_dt_tm between cnvtdatetime("14-JUN-2021") and cnvtdatetime("16-JUN-2021")	; enter update dates here
;and	ce.updt_dt_tm between cnvtdatetime("03-NOV-2020") and cnvtdatetime("05-NOV-2020")	; enter update dates here
;and	ce.updt_dt_tm between cnvtdatetime("05-NOV-2020") and cnvtdatetime("07-NOV-2020")	; enter update dates here
;and	ce.event_cd = 12345678	; enter event code here…
;and	ce.event_cd in (select code_value	
;	from code_value cv	
;	where cv.code_set = 72	; 'Event Code'
;	and cv.data_status_cd = 39	; 'Unauth' from code set 8
;	and cv.data_status_prsnl_id = 11599692	; only show AoFs from 'CONTRIBUTOR_SYSTEM, WH_RAD'
;	and cv.data_status_prsnl_id = 11599690	; only show AoFs from 'CONTRIBUTOR_SYSTEM, WH_LAB'
;	)	
;and	ce.catalog_cd in ()	; enter associated orderables here
;and	ce.event_end_dt_tm between cnvtdatetime("02-FEB-2020") and cnvtdatetime("15-JUL-2020")	; enter event dates here
join	p_ce	
join	p	
join	ea_URN	
;where	ea_URN.alias = "123456"	; enter URN here…
join	ea_visit	
;where	ea_visit.alias = "IPE123456"	; enter visit number here
;join	ce_b	
		
order by		
	ce.updt_dt_tm	
	, ce.event_end_dt_tm	
	, ce.event_id	
	, ce.valid_from_dt_tm	
	, uar_get_code_display(ce.event_cd)	
;	, ce.clinical_event_id	; returns multiple rows if an event has been updated
	, 0	
		
with	time = 60	
