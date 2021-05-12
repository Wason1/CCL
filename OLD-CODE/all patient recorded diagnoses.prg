select	; patient diagnoses	
;	facility = uar_get_code_display(e.loc_facility_cd)	
	UR_number = ea_URN.alias	
	, patient_name = prsn.name_full_formatted ; "xxxx"	
;	, patient_id = pw.person_id	
	, encntr_dates = concat(format(e_orig.arrive_dt_tm, "dd/mm/yyyy"), " - ", format(e_orig.depart_dt_tm, "dd/mm/yyyy"))	
	, visit_no = ea_visit.alias	
	, pathway = pw.description	
	, pathway_ordered = format(pw_a.action_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, pathway_orderer = p_pw_a_order.name_full_formatted	
	, pw.pathway_id	
	, diagnosis = n.source_string	
	, diagnosis_active = d.active_ind 	
	, diagnosis_start = format(d.active_status_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, diagnosis_end = format(d.end_effective_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, diagnosis_active_status_updater = p_d_act_stat.name_full_formatted	
	, d.diagnosis_id	
	, enctr_rank = dense_rank() over (partition by 0	
	order by 	
	e_orig.arrive_dt_tm	
	, ea_URN.alias	
	)	
		
from		
	pathway pw	
	, (left join pathway_action pw_a on pw_a.pathway_id = pw.pathway_id	
	and pw_a.action_type_cd = 10752	; 'Order' from code set 16809
	)	
	, (left join prsnl p_pw_a_order on p_pw_a_order.person_id = pw_a.action_prsnl_id)	
	, (left join person prsn on prsn.person_id = pw.person_id)	
	, (left join encounter e_orig on e_orig.encntr_id = pw.encntr_id)	
	, (left join encntr_alias ea_URN on ea_URN.encntr_id = pw.encntr_id	
	and ea_URN.encntr_alias_type_cd = 1079	; URN
	and ea_URN.active_ind = 1	; active URNs only
	)	
	, (left join encntr_alias ea_visit on ea_visit.encntr_id = pw.encntr_id	
	and ea_visit.encntr_alias_type_cd = 1077	; 'FIN NBR' from code set 319
	and ea_visit.active_ind = 1	; active FIN NBRs only
	and ea_visit.end_effective_dt_tm > sysdate	; effective FIN NBRs only
	)	
	, (inner join diagnosis d on d.encntr_id = pw.encntr_id 	
	and d.diag_type_cd = 3538766	; 'Principwl Dx' from code set 17
;	and d.active_ind = 1	; active disgnoses only
;	and d.end_effective_dt_tm > sysdate	; effective disgnoses only
	)	
	, (left join prsnl p_d_act_stat on p_d_act_stat.person_id = d.active_status_prsnl_id)	
		
		
		
	, (left join nomenclature n on n.nomenclature_id = d.nomenclature_id)	
		
plan	pw	
where	pw.description = "ED Adult Interim Admission (4 hour plan)"	
and	pw.person_id not in (12921277, 13103607)	; 'TESTHTS, Joanne' and 'TESTWHS, Demonstration'
join	pw_a	
join	p_pw_a_order	
join	prsn	
join	e_orig	
join	ea_URN	
join	ea_visit	
join	d	
join	p_d_act_stat	
join	n	
		
order by		
	e_orig.arrive_dt_tm	
	, ea_URN.alias	
	, pw_a.action_dt_tm	
	, pw.pathway_id	
	, d.active_status_dt_tm	
		
with	time = 300 	
