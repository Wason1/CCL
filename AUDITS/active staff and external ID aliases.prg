select	; active staff and 'External ID' aliases	
	p.name_full_formatted	
	, p.username	
	, postion = uar_get_code_display(p.position_cd)	
	, physician = p.physician_ind	
	, prsnl_active = p.active_ind	
	, prsnl_active_status_dt = format(p.active_status_dt_tm, "dd/mm/yyyy")	
	, prsnl_beg_dt = format(p.beg_effective_dt_tm, "dd/mm/yyyy")	
	, prsnl_end_dt = format(p.end_effective_dt_tm, "dd/mm/yyyy")	
	, p.person_id	
	, org_group = org_s.name	
	, p_a.alias	
	, alias_pool = uar_get_code_display(p_a.alias_pool_cd)	
	, alias_pool_cd = if(p_a.prsnl_alias_id > 0) cnvtstring(p_a.alias_pool_cd)	
	else ""	
	endif	
	, alias_type = uar_get_code_display(p_a.prsnl_alias_type_cd)	
	, alias_type_cd = if(p_a.prsnl_alias_id > 0) cnvtstring(p_a.prsnl_alias_type_cd)	
	else ""	
	endif	
	, alias_active = if(p_a.prsnl_alias_id > 0) cnvtstring(p_a.active_ind)	
	else ""	
	endif	
	, alias_active_status = uar_get_code_display(p_a.active_status_cd)	
	, alias_active_status_cd = if(p_a.prsnl_alias_id > 0) cnvtstring(p_a.active_status_cd)	
	else ""	
	endif	
	, alias_beg_dt = format(p_a.beg_effective_dt_tm, "dd/mm/yyyy")	
	, alias_end_dt = format(p_a.end_effective_dt_tm, "dd/mm/yyyy")	
	, contributor_system_cd = if(p_a.prsnl_alias_id > 0) cnvtstring(p_a.contributor_system_cd)	
	else ""	
	endif	
;	, alias_count = count(p_a.alias_pool_cd) over (partition by p.person_id)	
	, alias_id = if(p_a.prsnl_alias_id > 0) cnvtstring(p_a.prsnl_alias_id)	
	else ""	
	endif	
		
from		
	prsnl p	
	, (left join prsnl_alias p_a on p_a.person_id = p.person_id	
;	and p_a.active_ind = 1	
	and p_a.alias_pool_cd = 683991	; 'External Id' from code set 263
	)	
	, (left join org_set_prsnl_r p_org_set_r on p_org_set_r.prsnl_id = p.person_id	
	and p_org_set_r.active_ind = 1	
	and p_org_set_r.beg_effective_dt_tm < sysdate	
	and p_org_set_r.end_effective_dt_tm > sysdate	
	and p_org_set_r.org_set_id = 620126	; "Western Health"
	)	
	, (left join org_set org_s on org_s.org_set_id = p_org_set_r.org_set_id)	
		
plan	p	
;where	p.active_ind = 1	
where	p.position_cd > 0	
and	p.position_cd != 6797458	; "Non System"
and	p.position_cd not in (select code_value from code_value	
	where code_set = 88	
	and display_key = "ZZ*"	
	)	
and	p.username > " "	
and	p.username != "AHS*"	
and	p.username != "PEN*"	
;and	p.person_id in (select p_org_set_r.prsnl_id	
;	from org_set_prsnl_r p_org_set_r	
;	where p_org_set_r.	
join	p_a	
join	p_org_set_r	
join	org_s	
		
order by		
	p.active_status_dt_tm	
	, p.name_full_formatted	
	, p.person_id	
	, uar_get_code_display(p_a.alias_pool_cd) 	
		
with		
	time = 120	
	, maxrec = 100000	
