select	; 'Personnel Alias Type' code set alignment	
	cv.code_set	
	, code_set_name = cvs.display	
	, code_set_rank = dense_rank() over (partition by 0	; no logical database field partition
	order by 	
	cv.code_set	
	)	
	, cv.display	
	, cv.description	
	, cv.definition	
	, collation_seq = if(cv.code_value > 0) cnvtstring(cv.collation_seq)	
	else ""	
	endif	
	, cv.cdf_meaning	
	, cv.cki	
	, active_ind = if(cv.code_value > 0) cnvtstring(cv.active_ind)	
	else ""	
	endif	
	, beg_date = format(cv.begin_effective_dt_tm, "dd/mm/yyyy")	
	, end_date = format(cv.end_effective_dt_tm, "dd/mm/yyyy")	
	, data_status = uar_get_code_display(cv.data_status_cd)	
	, data_status_last_date = format(cv.data_status_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, data_status_last_updater = if(cv.code_value > 0 and p_cv_ds.name_full_formatted = null) cnvtstring(cv.data_status_prsnl_id)	
	else p_cv_ds.name_full_formatted	
	endif	
	, personnel_using = if(aliases.count > "0") aliases.count	
	else "0"	
	endif	
	, code_value_last_update = format(cv.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, code_value_last_updater = if(cv.code_value > 0 and p_cv.name_full_formatted = null) cnvtstring(cv.updt_id)	
	else p_cv.name_full_formatted	
	endif	
	, cv.code_value	
	, contributor_source_inbound = uar_get_code_display(cva.contributor_source_cd)	
	, alias_inbound = if (cva.contributor_source_cd > 0 and cva.alias = " ") "<sp>"	
	else cva.alias	
	endif	
	, alias_in_type_meaning_inbound = cva.alias_type_meaning	
	, alias_in_last_update = format(cva.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, alias_in_last_updater = if(cva.code_value > 0 and p_cva.name_full_formatted = null) cnvtstring(cva.updt_id)	
	else p_cva.name_full_formatted	
	endif	
	, contributor_source_outbound = uar_get_code_display(cvo.contributor_source_cd)	
	, alias_outbound = if (cvo.contributor_source_cd > 0 and cvo.alias = " ") "<sp>"	
	else cvo.alias	
	endif	
	, alias_out_type_meaning_outbound = cvo.alias_type_meaning	
	, alias_out_last_update = format(cvo.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, alias_out_last_updater = if(cvo.code_value > 0 and p_cvo.name_full_formatted = null) cnvtstring(cvo.updt_id)	
	else p_cvo.name_full_formatted	
	endif	
	, PROVIDER_OCX_IND = cve_PROVIDER_OCX_IND.field_value	
	, PROVIDER_OCX_IND_last_update = format(cve_PROVIDER_OCX_IND.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, PROVIDER_OCX_IND_last_updater = if(cve_PROVIDER_OCX_IND.code_value > 0 and p_cve_PROVIDER_OCX_IND.name_full_formatted = null) cnvtstring(cve_PROVIDER_OCX_IND.updt_id)	
	else p_cve_PROVIDER_OCX_IND.name_full_formatted	
	endif	
	, domain_alignment_comparison_text  = if ( cv.active_ind = 1)	
	build(cv.code_set	
	, "|", cvs.display	
	, "|", cv.display	
	, "|", cv.description	
	, "|", cv.collation_seq	
	, "|", cv.definition	
	, "|", cv.cdf_meaning	
	, "|", cv.cki	
	, "|", uar_get_code_display(cva.contributor_source_cd)	
	, "|", cva.alias	
	, "|", cva.alias_type_meaning	
	, "|", uar_get_code_display(cvo.contributor_source_cd)	
	, "|", cvo.alias	
	, "|", cvo.alias_type_meaning	
	, "|", cve_PROVIDER_OCX_IND.field_value	
	)	
	else ""	
	endif	
	, code_value_rank = dense_rank() over (partition by 0	; no logical database field partition
	order by 	
	cv.code_set	
	, nullval(cv.collation_seq,0)	; 'nullval' used as dense_rank fails when cv.collation_seq = null
	, cv.display_key	
	, cv.code_value	
	)	
		
from		
	code_value cv	
	, (left join prsnl p_cv_ds on p_cv_ds.person_id = cv.data_status_prsnl_id)	
	, (left join prsnl p_cv on p_cv.person_id = cv.updt_id)	
	, (left join code_value_set cvs on cvs.code_set = cv.code_set)	; to determine code set name
	, (left join code_value_alias cva on cva.code_value = cv.code_value)	; Code value alias tab in Corecodebuilder
	, (left join prsnl p_cva on p_cva.person_id = cva.updt_id)	
	, (left join code_value_outbound cvo on cvo.code_value = cv.code_value	; Code value outbound tab in Corecodebuilder
	and (cvo.contributor_source_cd = cva.contributor_source_cd	; Match cvo with cva, to minimise duplicated alias rows
	or 	
	cvo.contributor_source_cd not in (select cva2.contributor_source_cd from code_value_alias cva2 where cva2.code_value = cvo.code_value)	; unless no match with cva exists
	)	
	)	
	, (left join prsnl p_cvo on p_cvo.person_id = cvo.updt_id)	
	, (left join code_value_extension cve_PROVIDER_OCX_IND on cve_PROVIDER_OCX_IND.code_value = cv.code_value	; Code value extension tab in Corecodebuilder
	and cve_PROVIDER_OCX_IND.field_name = "PROVIDER_OCX_IND"	
	)	
	, (left join prsnl p_cve_PROVIDER_OCX_IND on p_cve_PROVIDER_OCX_IND.person_id = cve_PROVIDER_OCX_IND.updt_id)	
	, (left join (select pa.prsnl_alias_type_cd, count = count(*) from prsnl_alias pa group by pa.prsnl_alias_type_cd) aliases on aliases.prsnl_alias_type_cd = cv.code_value)	
		
plan	cv	
where	cv.code_set = 320	; 'Personnel Alias Type' code set
join	p_cv_ds	
join	p_cv	
join	cvs	
join	cva	
join	p_cva	
join	cvo	
join	p_cvo	
join	cve_PROVIDER_OCX_IND	
join	p_cve_PROVIDER_OCX_IND	
join	aliases	
		
order by		
	cv.code_set	
	, cv.collation_seq	
	, cv.display_key	
	, cv.code_value	
	, build(uar_get_code_display(cva.contributor_source_cd),cva.alias)	
	, build(uar_get_code_display(cvo.contributor_source_cd),cvo.alias)	
	, 0	
		
with	time = 60	
