update into prsnl_alias p_a
set p_a.alias = ""XXXXXXXXXX"" ; whatever is here will be set to the external alias
, p_a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, p_a.updt_id = reqinfo->updt_id
, p_a.updt_cnt = p_a.updt_cnt + 1
where p_a.prsnl_alias_id = XXXXXXXXXX ; ID of user you want update
;"
