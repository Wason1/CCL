select	; Patients created by 'WH_SCH'	
	p.person_id	
	, p.name_first	
	, p.name_middle	
	, p.name_last	
;	, p.name_full_formatted	
	, DoB = format(p.abs_birth_dt_tm, "dd/mm/yyyy")	
	, UR_number = p_a_URN.alias	
	, Medicare_Number = p_a_Medicare.alias	
;	, visit_no = ea_visit.alias	
;	, e.encntr_id	
		
from		
	person p	
	, (left join person_alias p_a_URN on p_a_URN.person_id = p.person_id	
	and p_a_URN.person_alias_type_cd = 10	; URN
;	and p_a_URN.active_ind = 1	; active URNs only
;	and p_a_URN.end_effective_dt_tm > sysdate	; effective URNs only
	)	
	, (left join person_alias p_a_Medicare on p_a_Medicare.person_id = p.person_id	
	and p_a_Medicare.person_alias_type_cd = 18	; Medicare Number
;	and p_a_Medicare.active_ind = 1	; active Medicare Numbers only
;	and p_a_Medicare.end_effective_dt_tm > sysdate	; effective Medicare Numbers only
	)	
;	, (left join encounter e on e.person_id = p.person_id)	
;	, (left join encntr_alias ea_visit on ea_visit.encntr_id = e.encntr_id	
;	and ea_visit.encntr_alias_type_cd = 1077	; 'FIN NBR' from code set 319
;	and ea_visit.active_ind = 1 	; active FIN NBRs only
;	and ea_visit.end_effective_dt_tm > sysdate	; effective FIN NBRs only
;	)	
		
		
plan	 p 	
where	p.contributor_system_cd = 86525020	; 'WH_SCH' from code set 89
and	p.active_ind = 1	
join	p_a_URN	
join	p_a_Medicare	
;join	e	
;where	e.location_cd = 127036765	;  'DAMAC' from codeset 220
;join	ea_visit	
		
;group by		
;	p.person_id	
;	, p.name_first	
;	, p.name_middle	
;	, p.name_last	
;	, p.name_full_formatted	
;	, p.abs_birth_dt_tm	
;	, p_a_URN.alias	
;	, p_a_Medicare.alias	
;	, e.encntr_id	
		
order by		
	p.name_last	
	, p.name_first	
	, p.abs_birth_dt_tm	
		
with	maxrec = 2000	
