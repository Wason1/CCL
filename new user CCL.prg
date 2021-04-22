UPDATE INTO	persnl

    ACTIVE_IND, end_effective_dt_tm, username
SET
    active_ind = 1,
    end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    ; Audit Trail
    , ec.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , ec.updt_id = reqinfo->updt_id
    , ec.updt_cnt = ec.updt_cnt + 1
WHERE
    username="HOMERS8"
WITH