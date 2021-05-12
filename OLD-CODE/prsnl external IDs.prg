select	; staff and aliases	
	p.name_full_formatted	
	, p.username	
	, postion = uar_get_code_display(p.position_cd)	
	, physician = p.physician_ind	
	, prsnl_active = p.active_ind	
	, prsnl_active_status_dt = format(p.active_status_dt_tm, "dd/mm/yyyy")	
	, prsnl_beg_dt = format(p.beg_effective_dt_tm, "dd/mm/yyyy")	
	, prsnl_end_dt = format(p.end_effective_dt_tm, "dd/mm/yyyy")	
	, p.person_id	
	, p_a.alias	
	, alias_pool = uar_get_code_display(p_a.alias_pool_cd)	
	, alias_pool_cd = p_a.alias_pool_cd	
	, alias_type = uar_get_code_display(p_a.prsnl_alias_type_cd)	
	, alias_type_cd = p_a.prsnl_alias_type_cd	
	, alias_active = p_a.active_ind	
	, alias_beg_dt = format(p_a.beg_effective_dt_tm, "dd/mm/yyyy")	
	, alias_end_dt = format(p_a.end_effective_dt_tm, "dd/mm/yyyy")	
;	, alias_count = count(p_a.alias_pool_cd) over (partition by p.person_id)	
	, alias_id = if(p_a.prsnl_alias_id > 0) cnvtstring(p_a.prsnl_alias_id)	
	else ""	
	endif	
		
from		
	prsnl p	
	, (inner join prsnl_alias p_a on p_a.person_id = p.person_id	
;	and p_a.active_ind = 1	
;	and p_a.alias_pool_cd in (87458279	; 'WHS FOOTSCRAY PROVIDER NUMBER' from code set 263
;	, 87458285	; 'WHS SUNSHINE PROVIDER NUMBER' from code set 263
;	, 87458288	; 'WHS WILLIAMSTOWN PROVIDER NUMBER' from code set 263
;	, 87458282	; 'WHS SUNBURY PROVIDER NUMBER' from code set 263
;	)	
	)	
		
plan	p	
where	p.active_ind = 0	
;and	p.position_cd > 0 ; 9655109	; 'Medical Officer' from code set 88
join	p_a	
		
order by		
	p.active_status_dt_tm	
	, p.name_full_formatted	
	, p.person_id	
	, uar_get_code_display(p_a.alias_pool_cd) 	
		
with		
	time = 120	
	, maxrec = 100000	
