select		
	facility = uar_get_code_display(e.loc_facility_cd)	
	, ordered_by = p1.name_full_formatted	
	, UR_number = ea.alias	
	, orig_order_date = format(o.orig_order_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, order_type = evaluate (o.orig_ord_as_flag,	
	0, "Inpatient",	
	1, "Prescription/Discharge Order",	
	2, "Recorded / Home Meds",	
	3, "Patient Owns Meds",	
	4, "Pharmacy Charge Only",	
	5, "Satellite (Super Bill) Meds")	
	, orderable_type = evaluate (o.orderable_type_flag,	
	0, "Standard",	
	1, "Standard",	
	2, "Supergroup",	
	3, "CarePlan",	
	4, "AP Special",	
	5, "Department Only",	
	6, "Order Set",	
	7, "Home Health Problem",	
	8, "Multi-ingredient",	
	9, "Interval Test",	
	10, "Freetext")	
	, ordered_in_set_or_plan = if (o.cs_order_id + o.pathway_catalog_id > 0) "x"	
	else ""	
	endif	
	, order_primary_mnemonic = o.hna_order_mnemonic	
	, ordered_as_mnemonic = o.ordered_as_mnemonic	
	, order_clinical_display_line = o.clinical_display_line	
	, order_status = uar_get_code_display(o.order_status_cd)	
	, order_id = o.order_id	
	, order_container_id = if (con_e.container_id = 0) ""	
	else cnvtstring(con_e.container_id)	
	endif	
	, collection_accession_class = uar_get_code_display (a.accession_class_cd)	
	, collection_service_resource = uar_get_code_display (osrc.service_resource_cd)	
	, collected_specimen_type = uar_get_code_display (con_e.specimen_type_cd)	
	, collected_collection_method = uar_get_code_display (con_e.collection_method_cd)	
	, collected_volume = if (con_e.container_id = 0) ""	
	else cnvtstring(con_e.volume_nbr)	
	endif	
	, collected_container = uar_get_code_display (con_e.spec_cntntr_cd)	
	, collected_collection_class = uar_get_code_display (con_e.coll_class_cd)	
		
from		
	orders o	
	, encounter e	
;	, clinical_event ce	
	, person p	
	, prsnl p1	
	, encntr_alias ea	
	, order_catalog oc	
	, order_catalog_synonym ocs	
	, order_container_r   o_con_r	
	, container_event   con_e	
	, accession_order_r a_o_r	
	, accession a	
	, order_serv_res_container osrc	
		
plan	o	
where	o.catalog_type_cd = 2513 	; code value for 'Laboratory' from code set 6000
;where 	o.catalog_type_cd = 2517 	; code value for 'Radiology' from code set 6000
and 	o.orig_order_dt_tm between cnvtdatetime ("28-SEP-2015 00:00") 	
	and cnvtdatetime ("28-SEP-2015 23:59")	
;and	o.orig_ord_as_flag in (0	; Normal Order (Inpatient)
;	, 1	; Prescription/Discharge Order
;	, 2	; Recorded / Home Meds
;	, 3	; Patient Owns Meds
;	, 4	; Pharmacy Charge Only
;	, 5	; Satellite (Super Bill) Meds
;	)	
;and	o.orderable_type_flag not in (6)	; no care sets (standard orderables only)
;and	o.order_status_cd in ( 0	
;	, 2542	; Cancelled
;	, 2543	; Completed
;	, 2544	; Deleted
;	, 2545	; Discontinued
;	, 2546	; Future
;	, 2547	; Incomplete
;	, 2548	; InProcess
;	, 2549	; On Hold, Med Student
;	, 2550	; Ordered
;	, 2551	; Pending Review
;	, 2552	; Suspended
;	, 2553	; Unscheduled
;	, 614538	; Transfer/Canceled
;	, 643466	; Pending Complete
;	, 643467	; Deleted With Results
;	)	
;and	o.order_id =   12345678	
		
join	e	
where	e.encntr_id = o.encntr_id	
;and 	e.loc_facility_cd in (4038465)	; DEMO 1 HOSPITAL
and 	e.loc_facility_cd in (	
	9568344	; Austin Hospital
	, 17330537	; FAST
	, 19583771	; NE AH GP Clinic
	, 9571041	; Repat Hospital
	, 9571044	; Royal Talbot
	)	
;and 	e.loc_facility_cd in (	
;	12694306	; CARINYA
;	, 9568350	; FH
;	, 9569502	; FRANKSTON CH
;	, 9569214	; GOLF LINKS RD
;	, 9569514	; HASTINGS CH
;	, 9640896	; MICHAEL COURT
;	, 9569535	; MORNINGTON CH
;	, 9639966	; MORNINGTON CTR
;	, 9569550	; MT ELIZA CENTRE
;	, 9568941	; RH
;	, 9569541	; ROSEBUD CH
;	, 10747992	; RRACS
;	)	
;and 	e.loc_facility_cd in (	
;	6958124	; EHS Angliss
;	, 6954611	; EHS Box Hill
;	, 6960196	; EHS HEALESVILLE
;	, 6956579	; EHS Maroondah
;	, 6960192	; EHS PJC
;	, 6968843	; EHS Wantirna
;	, 6968836	; EHS Yarra Ranges
;	)	
;and 	e.loc_facility_cd in (6967285)	; RVH
		
;join	ce	
;where	ce.order_id = outerjoin(o.order_id)	
		
join	p	
where	p.person_id = outerjoin(o.person_id)	
		
join	p1	
where	p1.person_id = outerjoin(o.active_status_prsnl_id)	
and	p1.person_id != outerjoin(1)	
		
join	ea	
where	ea.encntr_id = outerjoin(e.encntr_id)	
and	ea.encntr_alias_type_cd = outerjoin(1079)	; URN
		
join	oc	
where	oc.catalog_cd = outerjoin(o.catalog_cd)	
;and	oc.primary_mnemonic = "Adrenaline Level"	
		
join	ocs	
where	ocs.synonym_id = outerjoin(o.synonym_id)	
		
join	o_con_r	
where	o_con_r.order_id = outerjoin(o.order_id)	
		
join	con_e	
where	con_e.container_id = outerjoin(o_con_r.container_id)	
and 	con_e.event_sequence in (null,(select max(event_sequence)	; only return most recent container event, or none, if these is no container event.
	from container_event	
	where container_id = o_con_r.container_id))	
		
join	a_o_r	
where	a_o_r.order_id = outerjoin(o.order_id)	
		
join	a	
where	a.accession_id = outerjoin(a_o_r.accession_id)	
		
join	osrc	
where	osrc.order_id = outerjoin(o_con_r.order_id)	
and	osrc.container_id = outerjoin(o_con_r.container_id)	
		
order by		
	o.orig_order_dt_tm	
	, o.order_id	
		
with	time = 180	
