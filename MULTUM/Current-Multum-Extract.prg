select	; current Multum	
	mocl_DNUM = mocl.catalog_cki	
	, mocl_primary_mnemonic = mocl.description	
	, mocl_synonym_type = mocl.mnemonic_type	
	, mocl_synonym_mnemonic = mocl.mnemonic	
	, mocl_active = mocl.active_ind	
	, mocl_hide = mocl.hide_ind	
	, mocl_CNUM = mocl.synonym_cki	
	, synonym_built = if (ocs.cki = mocl.synonym_cki) 1	; use curdomain, if possible for column header: "synonym_exists_in_[curdomain]"
	else 0	
	endif	
	, ignore_build_table = if (b.br_name_value_id > 0) 1	
	else 0	
	endif	
	, ignore_build_discrepancy = if (b.br_name_value_id = 0) "-"	
	elseif (b.br_name_value_id > 0 and ocs.cki = mocl.synonym_cki) "0"	
	else "1"	
	endif	
	  	
from 	mltm_order_catalog_load mocl	
	, (left join order_catalog_synonym ocs on ocs.cki = mocl.synonym_cki)	
	, (left join br_name_value b on b.br_value = mocl.synonym_cki	
	and b.br_nv_key1 = "MLTM_IGN_CONTENT"	
	)	
		
plan	mocl	
		
join	ocs	
join	b	
		
order by	cnvtupper(mocl.description)	
	, evaluate(mocl.mnemonic_type	; synonym_type custom list with "Primary" first
	, "Primary", 1	
	, "Ancillary", 2	
	, "Brand Name", 3	
	, "C - Dispensable Drug Names", 4	
	, "Direct Care Provider", 5	
	, "E - IV Fluids and Nicknames", 6	
	, "Generic Name", 7	
	, "M - Generic Miscellaneous Products", 8	
	, "N - Trade Miscellaneous Products", 9	
	, "Outreach", 10	
	, "PathLink", 11	
	, "Rx Mnemonic", 12	
	, "Surgery Med", 13	
	, "Y - Generic Products", 14	
	, "Z - Trade Products", 15	
	)	
	, mocl.mnemonic_key_cap