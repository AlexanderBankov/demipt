-- Обновляем мета данные - дата создания отчета
UPDATE DEMIPT.BNSO_META_REPORT 
SET previous_report_dt = current_report_dt,
    current_report_dt = (SELECT max(last_update) FROM DEMIPT.BNSO_META_LOADING);


-- Отчет о возможных ошибках ввода
INSERT INTO DEMIPT.BNSO_REP_MISTAKE_ALERT ( event_dt , object_id , type , cur_input , last_input , report_dt ) 
WITH lag_1_table AS (
    SELECT
        t1.schedule_fact_id,
        t1.volume,
        LAG (t1.volume,1) OVER (PARTITION BY t1.schedule_id ORDER BY t1.created) AS tv_min1
    FROM DEMIPT.BNSO_DWH_FACT_SCHEDULE t1
    )
SELECT
    t1.created AS event_dt,
    t3.object_id AS object_id,
    'Input alert' as type,
    t1.volume AS cur_input,
    t4.tv_min1 AS last_input,
    (SELECT current_report_dt FROM DEMIPT.bnso_meta_report where REPORT_NAME = 'MISTAKE_ALERT') AS report_dt
FROM DEMIPT.BNSO_DWH_FACT_SCHEDULE t1
INNER JOIN DEMIPT.BNSO_DWH_DIM_SCHEDULE_HIST t2
ON t1.schedule_id = t2.schedule_id AND
    t2.effective_to = TO_DATE ('2999-12-31', 'YYYY-MM-DD') AND
    t2.deleted_flg = 'N' 
INNER JOIN DEMIPT.BNSO_DWH_DIM_OBJECT_HIST t3
ON t2.object_id = t3.object_id AND
    t3.effective_to = TO_DATE ('2999-12-31', 'YYYY-MM-DD') AND
    t3.deleted_flg = 'N'
INNER JOIN lag_1_table t4
ON t1.schedule_fact_id = t4.schedule_fact_id
WHERE 1 = 1 AND
    t1.volume > (t4.tv_min1 * 1000) 
    AND t4.tv_min1 > 0;

COMMIT
