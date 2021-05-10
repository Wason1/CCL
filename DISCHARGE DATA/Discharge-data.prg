select	; Recorded Clinical Notes	
	UR_number = ea_URN.alias	
	, patient_name = p.name_full_formatted ; "xxxx"	
	, patient_id = ce.person_id
;	, v500_event_code.event_cd
;	, v500_event_code.event_cd_descr
	, visit_no = ea_visit.alias	
	, ce.encntr_id
	, ce.event_cd	
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
	, ce_contributor_system = uar_get_code_display(ce.contributor_system_cd)	
	, event_valid_dates = if(ce.valid_until_dt_tm > sysdate)	
	concat(format(ce.valid_from_dt_tm, "dd/mm/yy hh:mm"), " - ")	
	else concat(format(ce.valid_from_dt_tm, "dd/mm/yy hh:mm"), " - ", format(ce.valid_until_dt_tm, "dd/mm/yy hh:mm"))	
	endif	
	, service_date_time = format(ce.event_end_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, subject = ce.event_title_text	
	, type = uar_get_code_display(ce.event_cd)	
	, associated_event_code = ce.event_cd	
;	, report_contents = substring(1,50,ce_b.blob_contents)	; extracts errors out if this field is included…
	, clinical_event_last_update = format(ce.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, author = if(ce.clinical_event_id > 0 and ce.updt_id = 0) "0"	
	else  p_ce.name_full_formatted	
	endif	
	, status = uar_get_code_display(ce.result_status_cd)	
	, ce.event_id	
	, ce.clinical_event_id	
	, note_rank = dense_rank() over (partition by 0	; no logical database field partition
	order by	
	ce.event_end_dt_tm	
	, cv_ec.display_key	
	)	
		
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
	, (left join ce_blob ce_b on ce_b.event_id = ce.event_id	
	and ce_b.valid_from_dt_tm = ce.valid_from_dt_tm	
	and ce_b.valid_until_dt_tm  = ce.valid_until_dt_tm	
	)	
	, (left join code_value cv_ec on cv_ec.code_value = ce.event_cd)
;	, (left join v500_event_code on v500_event_code.event_cd = ce.event_cd)
		
plan	ce	
where	ce.view_level = 1	; only show events visible to endusers
;and	ce.valid_until_dt_tm > sysdate	; only show events that are still 'valid' (modified results show only the latest value as 'valid')
;and	ce.event_cd  = 12345678	; enter event code here…
and	ce.event_cd in (select ese_es.event_cd	
	from v500_event_set_code es_g2	
	, v500_event_set_explode ese_es	
	where es_g2.event_set_cd_disp = "ClinicalDoc"	
	and ese_es.event_set_cd = es_g2.event_set_cd	
	)	
and	ce.event_end_dt_tm between cnvtdatetime("05-MAY-2021") and cnvtdatetime("10-MAY-2021")	; enter event dates here - optional
join	p_ce	
join	p	
join	ea_URN	
;where	ea_URN.alias = "123456"	; enter URN here… - optional
join	ea_visit	
;where	ea_visit.alias = "IPE123456"	; enter visit number here
join	ce_b	
join	cv_ec
;join	v500_event_code

where
	dis
		
order by		
	ce.event_end_dt_tm	
	, cv_ec.display_key	
	, ce.updt_dt_tm	
	, ce.valid_from_dt_tm	
	, ce.clinical_event_id	; returns multiple rows if an event has been updated
	, 0	
		
with	time = 10000
	, maxrex=100