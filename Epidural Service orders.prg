select ;distinct	; orders using specific order detail	
	facility_at_time_of_order = uar_get_code_display(e_orig.loc_facility_cd)	
	, unit_at_time_of_order = if(elh.loc_nurse_unit_cd > 0) uar_get_code_display(elh.loc_nurse_unit_cd)	
	else uar_get_code_display(e_orig.loc_nurse_unit_cd)	
	endif	
;	, med_service_at_time_of_order = uar_get_code_display(elh.med_service_cd)	
	, UR_number = ea_URN.alias	
	, patient_name = p.name_full_formatted	
	, patient_id = o.person_id	
	, order_date = format(o.orig_order_dt_tm, "dd/mm/yyyy hh:mm")	
	, order_synonym  = o.ordered_as_mnemonic	
	, ordered_by = p_o_a.name_full_formatted	
	, original_order_status = uar_get_code_display(o.order_status_cd)	
	, order_status_last_update = format(o.status_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, order_status_last_updater = if(o.order_id > 0 and o.status_prsnl_id = 0) "0"	
	else p_o_stat.name_full_formatted	
	endif	
	, order_detail_label = oef_fields.label_text	
	, order_detail_recorded_value = o_d.oe_field_display_value	
	, order_detail_last_update = format(o_d.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, order_detail_last_updater = if(o_d.order_id > 0 and o_d.updt_dt_tm = 0) "0"	
	else p_o_d.name_full_formatted	
	endif	
	, order_detail_recorded_code = o_d.oe_field_value	
	, order_detail_action_seq = o_d.action_sequence	
	, order_detail_detail_seq = o_d.detail_sequence	
	, o.order_id	
		
from		
	orders o	
	, (left join order_detail o_d on o_d.order_id = o.order_id)	
	, (left join prsnl p_o_d on p_o_d.person_id = o_d.updt_id)	
	, (left join oe_format_fields oef_fields on oef_fields.oe_format_id = o.oe_format_id	
	and oef_fields.oe_field_id = o_d.oe_field_id	
	)	
	, (left join encounter e_orig on e_orig.encntr_id = o.encntr_id)	
	, (left join encntr_alias ea_URN on ea_URN.encntr_id = o.encntr_id	
	and ea_URN.encntr_alias_type_cd = 1079	; URN
	and ea_URN.active_ind = 1	; active URNs only
	and ea_URN.end_effective_dt_tm > sysdate	; effective URNs only
	)	
	, (left join encntr_loc_hist elh on elh.encntr_id = o.encntr_id	
	and elh.active_ind = 1	; to remove inactive rows that seem to appear for unknown reason(s)
	and elh.pm_hist_tracking_id > 0	; to remove duplicate row that seems to occur at discharge
	and elh.beg_effective_dt_tm < o.orig_order_dt_tm	; encounter location began before order was placed
	and elh.end_effective_dt_tm >  o.orig_order_dt_tm	; encounter location ended after order was placed
	)	
	, (left join prsnl p_o_stat on p_o_stat.person_id = o.status_prsnl_id)	
	, (left join order_action o_a on o_a.order_id = o.order_id	
	 and o_a.action_type_cd = 2534	; 'order' from codeset 6003
	)	
	, (left join prsnl p_o_a on p_o_a.person_id = o_a.action_personnel_id)	
	, (left join person p on p.person_id = o.person_id)	
		
plan	o	
;where	o.catalog_cd in ()	
;where	o.synonym_id in ()	
;and	o.order_status_cd not in (2544, 2545)	; 'Deleted', 'Discontinued' from codeset 6004
;and	o.orig_order_dt_tm between cnvtdatetime("01-MAR-2020") and cnvtdatetime("01-JUL-2020")	
join	o_d	
where	o_d.oe_field_value in (116420686)	; 'Epidural Service'
join	p_o_d	
join	oef_fields	
join	e_orig	
join	ea_URN	
join	elh	
join	p_o_stat	
join	o_a	
join	p_o_a	
join	p	
		
order by		
	o.orig_order_dt_tm	
	, cnvtupper(p.name_full_formatted)	
	, p.person_id	
	, o.ordered_as_mnemonic	
	, 0	; 'select distinct' requires this value, in order function correctly
		
with		
	time = 300