select	; Patients created by 'WH_SCH'	
	p.person_id
    , URN = pa_URN.alias	
	, p.name_first
	, p.name_middle	
	, p.name_last
	, DoB = format(p.abs_birth_dt_tm, "dd/mm/yyyy")

from person p
                , (left join person_alias pa_URN on pa_URN.person_id = p.person_id    
                and pa_URN.person_alias_type_cd = 10        ; 'URN' from code set 4
                and pa_URN.active_ind = 1                   ; active URNs only
                and pa_URN.end_effective_dt_tm > sysdate    ; effective URNs only
                )     
		
plan p 	
where
    p.contributor_system_cd = 86525020	; 'WH_SCH' from code set 89
    and	p.active_ind = 1	
join	pa_URN

order by		
	p.name_last	
	, p.name_first

with
    maxrec = 50000
    , time = 100