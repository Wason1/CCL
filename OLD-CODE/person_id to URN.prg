select
                URN = pa_URN.alias
                , p.name_full_formatted
                , p.person_id
                
from person p
                , (left join person_alias pa_URN on pa_URN.person_id = p.person_id    
                and pa_URN.person_alias_type_cd = 10        ; 'URN' from code set 4
                and pa_URN.active_ind = 1                   ; active URNs only
                and pa_URN.end_effective_dt_tm > sysdate    ; effective URNs only
                )              

plan       p
where   p.person_id = 11768480                              ; insert person_id here

join pa_URN
;where pa_URN.alias = "710414"                              ; insert URN here