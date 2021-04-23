
UPDATE INTO prsnl
SET
    active_ind = 1,
    end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    ; Audit Trail
    , updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , updt_id = reqinfo->updt_id
    , updt_cnt = updt_cnt + 1
WHERE;
    username="HOMERS8"

UPDATE INTO prsnl
SET
    active_ind = 1,
    end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    ; Audit Trail
    , updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , updt_id = reqinfo->updt_id
    , updt_cnt = updt_cnt + 1
WHERE;
    username="HOMERS9"

UPDATE INTO prsnl
SET
    active_ind = 1,
    end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    ; Audit Trail
    , updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , updt_id = reqinfo->updt_id
    , updt_cnt = updt_cnt + 1
WHERE;
    username="BARB1"
