select
;count(*)
distinct
  c.prsnl_id
, c.credential_id
, c.credential_cd
, Cred_name  	= uar_get_code_display(c.credential_cd)
, c.credential_type_cd
, cred_type 	= uar_get_code_display(c.credential_type_cd)
, cred_state 	= uar_get_code_display(c.state_cd)
, c.active_ind
, c.beg_effective_dt_tm
, c.end_effective_dt_tm
, p.active_ind
, p.name_full_formatted
, p.beg_effective_dt_tm
, p.end_effective_dt_tm
, o.organization_id
, o.org_name
, os.name
from credential c
, (left join prsnl p on c.prsnl_id = p.person_id )
, (left join prsnl_org_reltn por on por.person_id = p.person_id )
, (left join organization o on o.organization_id = por.organization_id )
, (left join ORG_SET_ORG_R osor on osor.organization_id = o.organization_id )
, (left join org_set os on osor.org_set_id = os.org_set_id )
plan c
where c.credential_id > 0
join p
where p.active_ind = 0
join por
join o
join osor
join os
where o.organization_id not in 	(680563, 680564, 680565, 680566) and os.org_set_id not in (620126, 680584) ;not WHS
order by c.beg_effective_dt_tm asc
with ; maxrec = 5000,
time = 60