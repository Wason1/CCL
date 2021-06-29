select	; Multum Drug table (for package Multum installations)		; This is not domain specific. This is Multum package specific.
	multum_drug.drug_identifier		
	, multum_drug.synonym_type		
	, multum_drug.drug_name		
	, multum_drug.is_obsolete		
	, multum_alignment_comparision_text = build(multum_drug.drug_identifier		
	, "|", multum_drug.drug_name		
	, "|", if(multum_drug.synonym_type = "Primary*") "1"		
	else "0"		
	endif		
	, "|", multum_drug.is_obsolete		
	, "|", cnvtint(multum_drug.drug_synonym_id)		
	)		
	, drug_synonym_id = if(multum_drug.synonym_type = "*(manufacturer ingredient order)") concat(trim(cnvtstring(multum_drug.drug_synonym_id))," (manufacturer ingredient order)")		
	else cnvtstring(multum_drug.drug_synonym_id)		
	endif		
	, primary_rank = dense_rank() over (partition by 0		; no logical database field partition
	order by multum_drug.drug_identifier)		
			
from			
(	(		
	select		; This is not domain specific, it is Multum package specific.
		drug_identifier = mul_dn_map.drug_identifier	
		, synonym_type = evaluate(mul_dn_map.function_id	
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
		, 0, ""	
		)	
		, drug_name = mul_dn.drug_name	
		, mul_dn.is_obsolete	
		, mul_dn.drug_synonym_id	
			
	from		
		mltm_drug_name mul_dn	
		, mltm_drug_name_map mul_dn_map	
			
	where	mul_dn_map.drug_synonym_id = mul_dn.drug_synonym_id	
	and	mul_dn_map.function_id in (16, 17) ;, 26)	; Primary, Brand Name ;and C-Dispensables synonyms only
			
	union (		
	select		; This is not domain specific, it is Multum package specific
		drug_identifier = mul_manf_dn_map.drug_identifier	
		, synonym_type = evaluate(mul_manf_dn_map.function_id	
		, 16, "Primary (manufacturer ingredient order)"	
		, 29, "Brand Drug Name (manufacturer ingredient order)"	
		, 17, "Brand Name (manufacturer ingredient order)"	
		, 26, "C - Dispensable Drug Names (manufacturer ingredient order)"	
		, 19, "Drug Nickname (manufacturer ingredient order)"	
		, 62, "E - IV Fluids and Nicknames (manufacturer ingredient order)"	
		, 61, "IV Fluid (manufacturer ingredient order)"	
		, 59, "M - Generic Miscellaneous Products/Y - Generic Products (manufacturer ingredient order)"	
		, 64, "Multivitamin Name (manufacturer ingredient order)"	
		, 60, "N - Trade Miscellaneous Products/Z - Trade Products (manufacturer ingredient order)"	
		, 0, ""	
		)	
		, drug_name = mul_manf_dn.manufacturer_ordered_drug_name	
		, mul_manf_dn.is_obsolete	
		, mul_manf_dn.drug_synonym_id	
			
	from		
		mltm_manufact_drug_name mul_manf_dn	
		, mltm_drug_name_map mul_manf_dn_map	
			
	where	mul_manf_dn_map.drug_synonym_id = mul_manf_dn.drug_synonym_id	
	and	mul_manf_dn_map.function_id in (16, 17) ;, 26)	; Primary, Brand Name ;and C-Dispensables synonyms only
	)		
			
	with	rdbunion 	
		, sqltype("vc12", "vc100", "vc100", "vc1", "f8")	
			
	) multum_drug		
)			
			
order by			
	multum_drug.drug_identifier		
	, evaluate (multum_drug.synonym_type		
	, "Primary", 1		; Primary
	, "Primary (manufacturer ingredient order)", 2		; followed by Primary (manufacturer ingredient order)
	, "Brand Name*", 3		; followed by Brand Name or C-Dispensable equally.
	, "C - Dispensable Drug Names*", 3		
	)		
	, cnvtupper(multum_drug.drug_name)		
	, multum_drug.drug_name		; to cater for Tallman duplicates
	, 0		
