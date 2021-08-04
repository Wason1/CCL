select ;distinct	; user extract script	
	p.username	
	, user_create = format(p.create_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, user_creator = if(p.person_id > 0 and p.create_prsnl_id = 0) "0"	
	else p_create.name_full_formatted	
	endif	
	, p.active_ind	
	, beg_date = format(p.beg_effective_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, end_date = format(p.end_effective_dt_tm, "dd/mm/yyyy hh:mm:ss")                	
;	, p.name_first	
;	, p.name_last	
	, p.name_full_formatted	
	, position = uar_get_code_display(p.position_cd)	
	, user_last_update = format(p.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, user_last_updater = if(p.person_id > 0 and p.updt_id = 0) "0"	
	else p_update.name_full_formatted	
	endif	
	, prsnl_id = p.person_id	
	, organistion = org.org_name	
;	, organistions = listagg(org.org_name, "; ") over (partition by p.person_id	; doesn't work because some users are assigned to all orgs, `~250 in total
;	;, p_org_r.organization_id	
;	, p_org_set_r.org_set_id	
;	, cred.credential_id	
;	order by org.org_name	
;	)	
	, org_count = count (distinct p_org_r.organization_id) over (partition by p.person_id)	
	, org_last_update = format(p_org_r .updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, org_last_updater = if(p_org_r.prsnl_org_reltn_id > 0 and p_org_r .updt_id = 0) "0"	
	else p_p_org_r .name_full_formatted	
	endif	
	, prsnl_org_reltn_id = if(p_org_r.prsnl_org_reltn_id > 0) cnvtstring(p_org_r.prsnl_org_reltn_id)	
	else ""	
	endif	
	, org_group = org_s.name	
;	, org_groups = listagg(org_s.name, "; ") over (partition by p.person_id	; doesn't work for some reason, probably a user assigned to too many org groups
;	, p_org_r.organization_id	
;	;, p_org_set_r.org_set_id	
;	, cred.credential_id	
;	order by org_s.name	
;	)	
	, org_group_count = count (distinct p_org_set_r.org_set_id) over (partition by p.person_id)	
	, org_grp_last_update = format(p_org_set_r.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, org_grp_last_updater = if(p_org_set_r.org_set_prsnl_r_id > 0 and p_org_set_r .updt_id = 0) "0"	
	else p_p_org_set_r .name_full_formatted	
	endif	
	, org_set_prsnl_r_id = if(p_org_set_r.org_set_prsnl_r_id > 0) cnvtstring(p_org_set_r.org_set_prsnl_r_id)	
	else ""	
	endif	
	, credential = uar_get_code_display(cred.credential_cd)	
	, cred_count = count (distinct cred.credential_cd) over (partition by p.person_id)	
	, cred_last_update = format(cred.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, cred_last_updater = if(cred.credential_id > 0 and cred.updt_id = 0) "0"	
	else p_cred.name_full_formatted	
	endif	
	, credential_id = if(cred.credential_id > 0) cnvtstring(cred.credential_id)	
	else ""	
	endif	
	, extract_testing = ""	; blank column just for etxract testing
	, prsnl_rank = dense_rank() over (partition by 0	; no logical database field partition
	order by 	
	cnvtupper(p.name_full_formatted)	
	, p.person_id	
	)	
		
from	prsnl p	
	, (left join prsnl p_create on p.create_prsnl_id = p_create.person_id)	
	, (left join prsnl p_update on p.updt_id = p_update.person_id)	
	, (left join prsnl_org_reltn p_org_r on p_org_r.person_id = p.person_id	
	and p_org_r.active_ind = 1	
	and p_org_r.beg_effective_dt_tm < sysdate	
	and p_org_r.end_effective_dt_tm > sysdate	
	)	
	, (left join prsnl p_p_org_r on p_p_org_r.person_id = p_org_r .updt_id)	
	, (left join organization org on org.organization_id = p_org_r.organization_id)	
	, (left join org_set_prsnl_r p_org_set_r on p_org_set_r.prsnl_id = p.person_id	
	and p_org_set_r.active_ind = 1	
	and p_org_set_r.beg_effective_dt_tm < sysdate	
	and p_org_set_r.end_effective_dt_tm > sysdate	
	)	
	, (left join prsnl p_p_org_set_r on p_p_org_set_r.person_id = p_org_set_r .updt_id)	
	, (left join org_set org_s on org_s.org_set_id = p_org_set_r.org_set_id)	
	, (left join credential cred on cred.prsnl_id = p.person_id	
	and cred.active_ind = 1	
	and cred.beg_effective_dt_tm < sysdate	
	and cred.end_effective_dt_tm > sysdate	
	)	
	, (left join prsnl p_cred on p_cred.person_id = cred .updt_id)	
		
plan	p	
where	p.person_id != 0	
;and	p.person_id = 12345678	
join	p_create	
join	p_update	
join	p_org_r	
join	p_p_org_r	
join	org	
join	p_org_set_r	
join	p_p_org_set_r	
join	org_s	
join	cred	
join	p_cred	
		
order by		
	cnvtupper(p.name_full_formatted)	
	, p.person_id	
	, org.org_name	
	, org_s.name	
	, uar_get_code_display(cred.credential_cd)	
	, 0	
		
with		
	time = 60	
	, maxrec = 1000	