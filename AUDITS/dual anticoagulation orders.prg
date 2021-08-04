select	; dual active orders	
	UR_number = ea_URN.alias	
	, patient_name = p.name_full_formatted  ;"xxxx"	
	, patient_id = o.person_id	
	, encntr_dates = concat(format(e_orig.arrive_dt_tm, "dd/mm/yy hh:mm"), " - ", format(e_orig.depart_dt_tm, "dd/mm/yy hh:mm"))	
	, visit_no = ea_visit.alias	
	, o.encntr_id	
	, facility_at_time_of_o1 = uar_get_code_display(e_orig.loc_facility_cd)	
	, unit_at_time_of_o1 = if(elh.loc_nurse_unit_cd > 0) uar_get_code_display(elh.loc_nurse_unit_cd)	
	else uar_get_code_display(e_orig.loc_nurse_unit_cd)	
	endif	
	, o1_order_type = evaluate (o.orig_ord_as_flag,	
	0, "Normal Order",	
	1, "Prescription/Discharge Order",	
	2, "Recorded / Home Meds",	
	3, "Patient Owns Meds",	
	4, "Pharmacy Charge Only",	
	5, "Satellite (Super Bill) Meds"	
	)	
	, o1_med_order_type = uar_get_code_display(o.med_order_type_cd)	
	, o1_original_order_date = format(o.orig_order_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, o1_current_status = uar_get_code_display(o.order_status_cd)	
	, o1_projected_stop_date = format(o.projected_stop_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, o1_clinical_display_line = o.clinical_display_line	
	, o1_ordered_as_menonic = o.ordered_as_mnemonic	
	, o1_order_id = o.order_id	
	, o2_order_type = evaluate (o2.orig_ord_as_flag,	
	0, "Normal Order",	
	1, "Prescription/Discharge Order",	
	2, "Recorded / Home Meds",	
	3, "Patient Owns Meds",	
	4, "Pharmacy Charge Only",	
	5, "Satellite (Super Bill) Meds"	
	)	
	, o2_med_order_type = uar_get_code_display(o2.med_order_type_cd)	
	, o2_original_order_date = format(o2.orig_order_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, o2_current_status = uar_get_code_display(o2.order_status_cd)	
	, o2_projected_stop_date = format(o2.projected_stop_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, o2_clinical_display_line = o2.clinical_display_line	
	, o2_ordered_as_menonic = o2.ordered_as_mnemonic	
	, o2_order_id = o2.order_id	
	, URN_rank = dense_rank() over (partition by 0	
	order by	
	ea_URN.alias	
	)	
		
from		
	orders o	
	, (left join prsnl p_o on p_o.person_id = o.updt_id)	
	, (left join prsnl p_o_stat on p_o_stat.person_id = o.status_prsnl_id)	
	, (left join encounter e_orig on e_orig.encntr_id = o.encntr_id)	
	, (left join encntr_alias ea_URN on ea_URN.encntr_id = o.encntr_id	
	and ea_URN.encntr_alias_type_cd = 1079	; 'URN' from code set 319
	and ea_URN.active_ind = 1	; active URNs only
	and ea_URN.end_effective_dt_tm > sysdate	; effective URNs only
	)	
	, (left join encntr_alias ea_visit on ea_visit.encntr_id = o.encntr_id	
	and ea_visit.encntr_alias_type_cd = 1077	; 'FIN NBR' from code set 319
	and ea_visit.active_ind = 1	; active FIN NBRs only
	and ea_visit.end_effective_dt_tm > sysdate	; effective FIN NBRs only
	)	
	, (left join encntr_loc_hist elh on elh.encntr_id = o.encntr_id	
	and elh.active_ind = 1	; to remove inactive rows that seem to appear for unknown reason(s)
	and elh.pm_hist_tracking_id > 0	; to remove duplicate row that seems to occur at discharge
	and elh.beg_effective_dt_tm < o.orig_order_dt_tm	; encounter location began before order was placed
	and elh.end_effective_dt_tm >  o.orig_order_dt_tm	; encounter location ended after order was placed
	)	
	, (left join order_action o_a on o_a.order_id = o.order_id	
	 and o_a.action_type_cd = 2534	; 'order' from codeset 6003
	)	
	, (left join prsnl p_o_a on p_o_a.person_id = o_a.action_personnel_id)	
	, (left join person p on p.person_id = o.person_id)	
	, (left join order_catalog_synonym ocs on ocs.synonym_id = o.synonym_id)	
	, (inner join orders o2 on o2.encntr_id = o.encntr_id	; inner join to only return patients with dual orders
	and o2.catalog_cd in (select oc.catalog_cd	
	from order_catalog oc	
	where oc.primary_mnemonic in (	
	"apixaban"	
	, "bivalirudin"	
	, "dabigatran"	
	, "dalteparin"	
	, "danaparoid"	
	, "enoxaparin"	
	, "fondaparinux"	
	, "heparin"	
	, "nadroparin"	
	, "rivaroxaban"	
	, "warfarin"	
	)	
	)	
	and o2.catalog_cd != o.catalog_cd	; ignore matches for the same order.
	and o.template_order_id = 0	; template orders only (ie not exploded orders based on frequency)
	and o2.order_status_cd in (	
	2546	; Future
	, 2547	; Incomplete
	, 2548	; InProcess
	, 2549	; On Hold, Med Student
	, 2550	; Ordered
	, 2551	; Pending Review
	, 2552	; Suspended
	, 2553	; Unscheduled
	, 614538	; Transfer/Canceled
	, 643466	; Pending Complete
	)	
	and o2.active_ind = 1	; active orders only
	and (	
	o2.projected_stop_dt_tm > sysdate	; current orders only (future stop date or no stop date)
	or	
	o2.projected_stop_dt_tm = null	
	)	
	)	
		
plan	o	
where	o.template_order_id = 0	; template orders only (ie not exploded orders based on frequency)
and	o.order_status_cd in (	
	2546	; Future
	, 2547	; Incomplete
	, 2548	; InProcess
	, 2549	; On Hold, Med Student
	, 2550	; Ordered
	, 2551	; Pending Review
	, 2552	; Suspended
	, 2553	; Unscheduled
	, 614538	; Transfer/Canceled
	, 643466	; Pending Complete
	)	
and	o.active_ind = 1	; active orders only
and	(	
	o.projected_stop_dt_tm > sysdate	; current orders only (future stop date or no stop date)
	or	
	o.projected_stop_dt_tm = null	
	)	
;and	o.orig_ord_as_flag = 0	; inpatient orders only
;and	o.orig_ord_as_flag = 1	; discharge prescriptions only
;and	o.orig_ord_as_flag = 2	; Recorded / Home Meds only
;and	o.orig_order_dt_tm > cnvtdatetime("01-DEC-2020")	
and	o.catalog_cd in (select oc.catalog_cd	
	from order_catalog oc	
	where oc.primary_mnemonic in (	; enter the primary name here
	"apixaban"	
	, "bivalirudin"	
	, "dabigatran"	
	, "dalteparin"	
	, "danaparoid"	
	, "enoxaparin"	
	, "fondaparinux"	
	, "heparin"	
	, "nadroparin"	
	, "rivaroxaban"	
	, "warfarin"	
	)	
	)	
;and	o.synonym_id = (select ocs.synonym_id 	
;	from order_catalog_synonym ocs	
;	where ocs.mnemonic = "paracetamol 500 mg oral tablet"	; enter the synonym name here
;	)	
join	p_o	
join	p_o_stat	
join	e_orig	
join	ea_URN	
join	ea_visit	
join	elh	
join	o_a	
;where	o_a.updt_id = 1235678	; orders placed by…
join	p_o_a	
join	p	
join	ocs	
join	o2	
		
order by		
	ea_URN.alias	
	, o.orig_order_dt_tm	
	, o2.orig_order_dt_tm	
	, o.status_dt_tm	
	, o.order_id	
		
with	time = 1200	
