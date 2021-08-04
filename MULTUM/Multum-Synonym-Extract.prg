select	; synonym - Multum comparison	
	primary_DNUM = oc.cki	
	, multum_DNUM = if(mocl.catalog_cki != null) mocl.catalog_cki	; if mocl.catalog_cki exists, return mocl.catalog_cki
	elseif (mul_dn_map.drug_identifier != null) mul_dn_map.drug_identifier	; if mltmmdc.drug_identifier exists, return mltmmdc.drug_identifier
	else "-"	; if neither mocl.catalog_cki nor mltmmdc.drug_identifier, return "-"
	endif	
	, DNUM_match =  if (mocl.catalog_cki != null)	; if mocl.catalog_cki exists
	if (mocl.catalog_cki = oc.cki) "1"	; if mocl.catalog_cki exists and oc.cki matches mocl.catalog_cki, return "1"
	else "0"	; if mocl.catalog_cki exists but oc.cki does not match mocl.catalog_cki, return "0"
	endif	
	elseif (mul_dn_map.drug_identifier != null)	; if mltmmdc.drug_identifier exists
	if (findstring(mul_dn_map.drug_identifier,oc.cki) > 0) "1"	; if mltmmdc.drug_identifier exists and mltmmdc.drug_identifier is found within oc.cki, return "1"
	else "0"	; if mltmmdc.drug_identifier exists but mltmmdc.drug_identifier is not found within oc.cki, return "0"
	endif	
	elseif (oc.cki not in (null,"IGNORE") and ocs.mnemonic_type_cd = 2583) "0"	; if DNUM exists, and synonym is a primary, return "0"
	else "-"	; if neither mocl.catalog_cki nor mltmmdc.drug_identifier exist, return "-"
	endif	
	, ignore_DNUM_mapping = if (b_dnum_ig.br_name_value_id > 0) 1	
	else 0	
	endif	
	, primary_mnemonic = oc.primary_mnemonic	
	, primary_catalog_cd = oc.catalog_cd	
	, synonym_CNUM = ocs.cki	
	, ignore_CNUM_mapping = if (b_cnum_ig.br_name_value_id > 0) 1	
	else 0	
	endif	
	, CNUM_count = count(ocs.synonym_id) over (partition by ocs.cki)	
	, multum_syn_cki_status = if (ocs.cki in (""," ",null)) "-"	; if CNUM is not populated, return "-"
 	elseif (mul_dn.is_obsolete = "F") "current"	
 	elseif (mul_dn.is_obsolete = "T") "obsolete"	
 	elseif (mul_dn.drug_synonym_id = 0) "invalid"	; if CNUM does not create a join on mul_dn, return "invalid"
 	endif	
 	, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd)	
	, multum_type = if (mocl.mnemonic_type != null) mocl.mnemonic_type	; if mocl.mnemonic_type exists, return mocl.mnemonic_type
	elseif (mul_dn_map.function_id != null) evaluate (mul_dn_map.function_id	; if mul_dn_map.function_id exists, evaluate mul_dn_map.function_id
	, 16, "Primary"	
	, 29, "Brand Drug Name"	
	, 17, "Brand Name"	
	, 26, "C - Dispensable Drug Names"	
	, 19, "Drug Nickname"	
	, 62, "E - IV Fluids and Nicknames"	
	, 61, "IV Fluid"	
	, 59, "M - Generic Miscellaneous Products/Y - Generic Products"	
	, 64, "Multivitamin Name"	
	, 60, "N - Trade Miscellaneous Products/Z - Trade Products"	
	, 0, "-synonym not found on mul_dn_map table-"	
	)	
 	else "-"	; if neither mocl.mnemonic_type nor mul_dn_map.function_id exists, return "-"
	endif	
 	, type_match = if (ocs.active_ind = 1 and mocl.mnemonic_type != null)	; if mocl.mnemonic_type exists
	if (uar_get_code_display(ocs.mnemonic_type_cd) = mocl.mnemonic_type) "1"	; if mocl.mnemonic_type exists and ocs.mnemonic_type matches mocl.mnemonic_type, return "1"
	else "0"	; if mocl.mnemonic_type exists but ocs.mnemonic_type does not match mocl.mnemonic_type, return "0"
	endif	
	elseif (ocs.active_ind = 1 and mul_dn_map.function_id != null)	; if mul_dn_map.function_id exists
	if(findstring(trim(uar_get_code_display(ocs.mnemonic_type_cd)), evaluate(mul_dn_map.function_id	; and 'ocs.mnemonic_type' string is found within the 'multum function' string
	, 16, "Primary"	
	, 29, "Brand Drug Name"	
	, 17, "Brand Name"	
	, 26, "C - Dispensable Drug Names"	
	, 19, "Drug Nickname"	
	, 62, "E - IV Fluids and Nicknames"	
	, 61, "IV Fluid"	
	, 59, "M - Generic Miscellaneous Products/Y - Generic Products"	
	, 64, "Multivitamin Name"	
	, 60, "N - Trade Miscellaneous Products/Z - Trade Products"	
	)	
	)	
	 > 0) "1"	; , return "1"
	else "0"	; if mul_dn_map.function_id exists but 'ocs.mnemonic_type' string is not found within the 'multum function' string, return "0"
	endif	
	else "-"	; if neither mocl.mnemonic_type nor mul_dn_map.function_id exists, return "-"
	endif	
 	, synonym_mnemonic = ocs.mnemonic	
	, duplicate_mnemonic_count = count(ocs.synonym_id) over (partition by ocs.mnemonic)	
 	, multum_mnemonic = if (mul_manf_dn.manufacturer_ordered_drug_name != null) mul_manf_dn.manufacturer_ordered_drug_name	; if mul_manf_dn.manufacturer_ordered_drug_name exists for this CNUM, return mul_manf_dn.manufacturer_ordered_drug_name
	elseif (mul_dn.drug_name != null) mul_dn.drug_name	; if mul_manf_dn.manufacturer_ordered_drug_name does not exist for this CNUM, but mul_dn.drug_name exists, return mul_dn.drug_name
	else "-"	; if neither mul_manf_dn.manufacturer_ordered_drug_name nor mul_dn.drug_name exist for this CNUM, return "-"
	endif	
 	, mnemonic_match = if (ocs.active_ind = 1 and mul_manf_dn.manufacturer_ordered_drug_name != null)	; if mul_manf_dn.manufacturer_ordered_drug_name exists for this CNUM
	if (textlen(mul_manf_dn.manufacturer_ordered_drug_name) > 100) "Multum mnemonic > 100 characters"	; if mul_manf_dn.manufacturer_ordered_drug_name exists for this CNUM but is greater than 100 characters, return "Multum mnemonic > 100 characters"
	elseif (ocs.mnemonic = mul_manf_dn.manufacturer_ordered_drug_name != null) "1"	; if mul_manf_dn.manufacturer_ordered_drug_name exists for this CNUM and ocs.mnemonic matches mul_manf_dn.manufacturer_ordered_drug_name, return "1"
	else "0"	; if mul_manf_dn.manufacturer_ordered_drug_name exists for this CNUM but ocs.mnemonic does not match mul_manf_dn.manufacturer_ordered_drug_name, return "0"
	endif	
	elseif  (ocs.active_ind = 1 and mul_dn.drug_name != null)	; if mul_dn.drug_name exists for this CNUM
	if (textlen(mul_dn.drug_name) > 100) "Multum mnemonic > 100 characters"	; if mul_dn.drug_name exists for this CNUM but is greater than 100 characters, return "Multum mnemonic > 100 characters"
	elseif (ocs.mnemonic = mul_dn.drug_name) "1"	; if mul_dn.drug_name exists for this CNUM and ocs.mnemonic matches mul_dn.drug_name, return "1"
	else "0"	; if mul_dn.drug_name exists for this CNUM but ocs.mnemonic does not match mul_dn.drug_name, return "0"
	endif	
	else "-"	; if neither mul_manf_dn.manufacturer_ordered_drug_name nor mul_dn.drug_name exist for this CNUM, return "-"
	endif	
	, eService_logged = "=IF(ISNA(VLOOKUP(INDIRECT(CHAR(36)&CHAR(72)&ROW()),'Multum SRs'!$B:$B,1,FALSE))=TRUE,0,1)"	
	, synonym_active = ocs.active_ind	
	, synonym_hide = ocs.hide_flag	
	, multum_hide = if (ocs.cki = "MUL*" and ocs.cki = mocl.synonym_cki) cnvtstring (mocl.hide_ind)	; if CNUM is populated and a valid Multum CNUM, return Multum hide
	else "-"	; if CNUM is not populated or valid, return "-"
	endif	
	, hide_match = if (ocs.active_ind = 1 and ocs.cki = "MUL*" and ocs.cki = mocl.synonym_cki)	; if CNUM is populated and a valid Multum CNUM
	if (mocl.hide_ind = ocs.hide_flag) "1"	; if ocs.hide matches Multum hide, return "1"
	else "0"	; if ocs.hide does not match Multum hide, return "0"
	endif	
	else "-"	; if CNUM is not populated or valid, return "-"
	endif	
	, synonym_id = ocs.synonym_id	
	, oc_rank = dense_rank() over (partition by 0	; no logical database field partition
	order by cv_cat.display_key	
	, cv_act.display_key	
	, cv_sub.display_key	
	, cnvtupper(oc.primary_mnemonic)	
	)	
		
from	order_catalog  oc	
	, (left join code_value cv_cat on cv_cat.code_value = oc.catalog_type_cd)	
	, (left join code_value cv_act on cv_act.code_value = oc.activity_type_cd)	
	, (left join code_value cv_sub on cv_sub.code_value = oc.activity_subtype_cd)	
	, (left join br_name_value b_dnum_ig on cnvtint(b_dnum_ig.br_value) = oc.catalog_cd	
	and b_dnum_ig.br_nv_key1 = "MLTM_IGN_DNUM"	
	)	
 	, (left join order_catalog_synonym ocs on ocs.catalog_cd =  oc.catalog_cd	
	and ocs.mnemonic_type_cd not in (2584)	; exclude RxMnemonics
	)	
	, (left join br_name_value b_cnum_ig on cnvtint(b_cnum_ig.br_value) = ocs.synonym_id	
	and b_cnum_ig.br_nv_key1 = "MLTM_IGN_CNUM"	
	)	
	, (left join mltm_drug_name mul_dn on concat("MUL.ORD-SYN!",cnvtstring(mul_dn.drug_synonym_id)) = ocs.cki)	
	, (left join mltm_manufact_drug_name mul_manf_dn on concat("MUL.ORD-SYN!",cnvtstring(mul_manf_dn.drug_synonym_id)) = ocs.cki)	
	, (left join mltm_drug_name_map mul_dn_map on concat("MUL.ORD-SYN!",cnvtstring(mul_dn_map.drug_synonym_id)) = ocs.cki	
	and mul_dn_map.function_id != 29	; exclude 'Brand Drug Name' mappings as these create duplicates
	)	
 	, (left join mltm_order_catalog_load mocl on mocl.synonym_cki = ocs.cki)	
		
plan	oc 	
where	oc.catalog_type_cd = 2516	; code value for 'Pharmacy' from code set 6000
and	oc.orderable_type_flag not in (6,8)	; exclude care sets and IV sets
join	cv_cat	
join	cv_act	
join	cv_sub	
join	b_dnum_ig	
join	ocs 	
join	b_cnum_ig	
join	mul_dn	
join	mul_manf_dn	
join	mul_dn_map	
join	mocl	
		
order by		
	cv_cat.display_key	
	, cv_act.display_key	
	, cv_sub.display_key	
	, cnvtupper(oc.primary_mnemonic)	
	, evaluate(ocs.mnemonic_type_cd	; synonym_type custom list with "Primary" first, as per DCP tools.
	, 2583, 01	; "Primary"
	, 2579, 02	; "Ancillary"
	, 2580, 03	; "Brand Name"
	, 614542, 04	; "C - Dispensable Drug Names"
	, 2581, 05	; "Direct Care Provider"
	, 614543, 06	; "E - IV Fluids and Nicknames"
	, 2582, 07	; "Generic Name"
	, 614544, 08	; "M - Generic Miscellaneous Products"
	, 614545, 09	; "N - Trade Miscellaneous Products"
	, 614546, 10	; "Outreach"
	, 614547, 11	; "PathLink"
	, 2584, 12	; "Rx Mnemonic"
	, 2585, 13	; "Surgery Med"
	, 614548, 14	; "Y - Generic Products"
	, 614549, 15	; "Z - Trade Products"
	)	
	, ocs.mnemonic_key_cap	
	, ocs.synonym_id	; in case 'select distinct' is used
	, 0	; in case 'select distinct' is used
		
with	time = 60