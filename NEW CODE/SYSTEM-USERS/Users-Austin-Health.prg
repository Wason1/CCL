select
distinct
credential_prsnl =  c.prsnl_id
, c.credential_id
, c.credential_cd
, Cred_name  	= uar_get_code_display(c.credential_cd)
, c.credential_type_cd
, cred_type 	= uar_get_code_display(c.credential_type_cd)
, cred_state 	= uar_get_code_display(c.state_cd)
, c.active_ind
, c.beg_effective_dt_tm
, c.end_effective_dt_tm
, person_active = p.active_ind
, p.name_full_formatted
, p.username
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
and year(P.CREATE_DT_TM) <= 2017
join por
join o 
join osor
join os
where c.prsnl_id not in 
( 	select distinct person_id
	from prsnl_org_reltn
	where organization_id in 
	(
		select osor.organization_id 
		from ORG_SET_ORG_R osor
		,(left join org_set os on osor.org_set_id = os.org_set_id )
		where os.name = "Western Health"
	)
 )
order by P.CREATE_DT_TM, c.prsnl_id
with ; maxrec = 5000, 
time = 60