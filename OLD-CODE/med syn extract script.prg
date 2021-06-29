select	; medication synonyms (for Multum package installations)	
	primary_cki = oc.cki	
	, primary_mnemonic = oc.primary_mnemonic	
	, oc_last_update = format(oc.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, oc_last_updater = if(oc.catalog_cd > 0 and oc.updt_id = 0) "0"	
	else p_oc.name_full_formatted	
	endif	
	, synonym_cki = ocs.cki	
	, synonym_cki_status = if (ocs.cki in (""," ",null)) "-"	; if CNUM is not populated, return "-"
 	elseif (syn_mltmdn.is_obsolete = "F") "current"	
 	elseif (syn_mltmdn.is_obsolete = "T") "obsolete"	
 	elseif (syn_mltmdn.drug_synonym_id = 0) "invalid"	; if CNUM does not create a join on mltmdn, return "invalid"
 	endif	
	, synonym_type = uar_get_code_display( ocs.mnemonic_type_cd )	
	, synonym_mnemonic = ocs.mnemonic	
	, synonym_active = ocs.active_ind	
	, synonym_oef = oef.oe_format_name	
	, synonym_hide = ocs.hide_flag	
	, synonym_rxmask = ocs.rx_mask	
	, titrateable = if (ocs.ingredient_rate_conversion_ind = 1) "x"	
	else ""	
	endif	
	, med_admin_witness = if (ocs.witness_flag = 1) "Required"	
	else "Not Required"	
	endif	
	, ocs_last_update = format(ocs.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, ocs_last_updater = if(ocs.synonym_id > 0 and ocs.updt_id = 0) "0"	
	else p_ocs.name_full_formatted	
	endif	
	, domain_alignment_comparison_text = if (ocs.active_ind = 1)	
	build (oc.cki	
	, "|", oc.primary_mnemonic	
	, "|", ocs.cki	
	, "|", cnvtstring(ocs.mnemonic_type_cd)	
	, "|", ocs.mnemonic	
	, "|", evaluate(oef.oe_format_name	
	, "Pharmacy Strength Med", "Strngth"	
	, "Pharmacy Volume Med", "Vol"	
	, "Pharmacy DPCS Warrant Strength Med", "DPCSStrngth"	
	, "Pharmacy DPCS Warrant Volume Med", "DPCSVol"	
	, "Pharmacy Additional Task", "AddTask"	
	, "Pharmacy IV", "IV"	
	, "Pharmacy Freetext Med", "Freetxt"	
	, "Blood Bank Administration", "Blood"	
	, "Pharmacy - Warfarin", "Warf"	
	, "Primary Pharmacy", "Prim"	
	, "Pharmacy TPN admixture", "TPNadmix"	
	)	
	, "|", ocs.hide_flag	
	, "|", ocs.rx_mask	
	, "|", ocs.ingredient_rate_conversion_ind	
	, "|", ocs.witness_flag	
	)	
	else "-"	
	endif	
	, synonym_id = ocs.synonym_id	
	, oc_rank = dense_rank() over (partition by 0	; no logical database field partition
	order by cnvtupper(oc.primary_mnemonic)	
	)	
	, synonym_id_exists_before = build("=IF(INDIRECT(CHAR(36)&CHAR(74)&ROW())=1,"	; Requires a different extract for 'before' and 'after' for this to work...
	,"IF(ISNA(VLOOKUP(INDIRECT(CHAR(36)&CHAR(83)&ROW()),'med syn before'!$S:$S,1,FALSE))=FALSE"	
	,",1,0),CHAR(45))"	
	)	
	, aligned_with_before = build("=IF(INDIRECT(CHAR(36)&CHAR(74)&ROW())=1,"	
	,"IF(ISNA(VLOOKUP(INDIRECT(CHAR(36)&CHAR(82)&ROW()),'med syn before'!$R:$R,1,FALSE))=FALSE"	
	,",1,0),CHAR(45))"	
	)	
		
from		
	order_catalog_synonym ocs	
	, (left join prsnl p_ocs on p_ocs.person_id = ocs.updt_id)	
	, (inner join order_catalog oc on oc.catalog_cd = ocs.catalog_cd	
	 and oc.orderable_type_flag not in (2,3,6)	
	)	
	, (left join prsnl p_oc on p_oc.person_id = oc.updt_id)	
	, (left join order_entry_format oef on oef.oe_format_id = ocs.oe_format_id	
	and oef.action_type_cd =2534	;oef for 'Order' to prevent duplicate rows created by the other order actions
	)	
	, (left join mltm_drug_name syn_mltmdn on concat("MUL.ORD-SYN!",cnvtstring(syn_mltmdn.drug_synonym_id)) = ocs.cki)	
		
plan	ocs	
where	ocs.catalog_type_cd = 2516	; code value for 'Pharmacy' from code set 6000
join	p_ocs	
join	oc	
join	p_oc	
join 	oef	
join	syn_mltmdn	
		
order by	cnvtupper(uar_get_code_display(oc.catalog_type_cd))	
	, cnvtupper(uar_get_code_display(oc.activity_type_cd))	
	, cnvtupper(uar_get_code_display(oc.activity_subtype_cd))	
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
	, cnvtupper(ocs.mnemonic)	
		
with	time = 180	
