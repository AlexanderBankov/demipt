-- 3. Вливаем данные в хранилище из STG

-- 3.1 Факты
-- 3.1 SCHEDULE_FACT
INSERT INTO DEMIPT.BNSO_DWH_FACT_SCHEDULE ( schedule_fact_id, schedule_id, created, deleted, volume, expenditure )
SELECT 
	schedule_fact_id, schedule_id, created, deleted, volume, expenditure
FROM DEMIPT.BNSO_STG_SCHEDULE_FACT
WHERE schedule_fact_id IN (
	SELECT schedule_fact_id
FROM DEMIPT.BNSO_STG_SCHEDULE_FACT src
WHERE NOT EXISTS (
    SELECT * FROM DEMIPT.BNSO_DWH_FACT_SCHEDULE tgt WHERE 
    tgt.schedule_id=src.schedule_id AND
    tgt.created=src.created AND
    tgt.deleted=src.deleted AND
    tgt.volume=src.volume AND
    tgt.expenditure=src.expenditure
    )
);

-- 3.2 Измерения
-- 3.2.1 SCHEDULE
INSERT INTO DEMIPT.BNSO_DWH_DIM_SCHEDULE_HIST (schedule_id, object_id, parent_id, created, modified, deleted, job_id, volume_actual, expenditure_actual, volume_sum, expenditure_sum, element_id, deleted_flg, effective_from, effective_to )
SELECT
	schedule_id,
	object_id,
	parent_id,
	created,
	modified,
	deleted,
	job_id,
	volume_actual,
	expenditure_actual,
	volume_sum,
	expenditure_sum,
	element_id,
	CASE 
		WHEN deleted IS NOT NULL
		THEN 'Y'
		ELSE 'N'
	END AS deleted_flg,
	COALESCE( modified, created ),
	TO_DATE( '2999-12-31', 'YYYY-MM-DD' )
FROM DEMIPT.BNSO_STG_SCHEDULE
WHERE schedule_id NOT IN (
	SELECT schedule_id FROM (
        SELECT schedule_id, object_id, parent_id, created, modified, deleted, job_id, volume_actual, expenditure_actual, volume_sum, expenditure_sum, element_id
        FROM DEMIPT.BNSO_STG_SCHEDULE
        INTERSECT
        SELECT schedule_id, object_id, parent_id, created, modified, deleted, job_id, volume_actual, expenditure_actual, volume_sum, expenditure_sum, element_id
        FROM DEMIPT.BNSO_DWH_DIM_SCHEDULE_HIST 
        )
);

MERGE INTO DEMIPT.BNSO_DWH_DIM_SCHEDULE_HIST tgt
USING DEMIPT.BNSO_STG_SCHEDULE src
ON ( tgt.schedule_id = src.schedule_id AND tgt.effective_from < coalesce( src.modified, src.created ) )
WHEN matched THEN UPDATE SET 
    tgt.effective_to = COALESCE( src.modified, src.created ) - interval '1' second
		WHERE tgt.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' );


-- 3.2.2 OBJECT
INSERT INTO DEMIPT.BNSO_DWH_DIM_SCHEDULE (schedule_id, object_id, parent_id, created, modified, deleted, job_id, volume_actual, expenditure_actual, volume_sum, expenditure_sum, element_id, deleted_flg, effective_from, effective_to )
SELECT
	schedule_id,
	object_id,
	parent_id,
	created,
	modified,
	deleted,
	job_id,
	volume_actual,
	expenditure_actual,
	volume_sum,
	expenditure_sum,
	element_id,
	CASE 
		WHEN deleted IS NOT NULL
		THEN 'Y'
		ELSE 'N'
	END AS deleted_flg,
	COALESCE( modified, created ),
	TO_DATE( '2999-12-31', 'YYYY-MM-DD' )
FROM DEMIPT.BNSO_STG_SCHEDULE
WHERE schedule_id NOT IN (
	SELECT schedule_id FROM (
        SELECT schedule_id, object_id, parent_id, created, modified, deleted, job_id, volume_actual, expenditure_actual, volume_sum, expenditure_sum, element_id
        FROM DEMIPT.BNSO_STG_SCHEDULE
        INTERSECT
        SELECT schedule_id, object_id, parent_id, created, modified, deleted, job_id, volume_actual, expenditure_actual, volume_sum, expenditure_sum, element_id
        FROM DEMIPT.BNSO_DWH_DIM_SCHEDULE 
        )
);

MERGE INTO DEMIPT.BNSO_DWH_DIM_SCHEDULE tgt
USING DEMIPT.BNSO_STG_SCHEDULE src
ON ( tgt.schedule_id = src.schedule_id AND tgt.effective_from < coalesce( src.modified, src.created ) )
WHEN matched THEN UPDATE SET 
    tgt.effective_to = COALESCE( src.modified, src.created ) - interval '1' second
		WHERE tgt.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' );
