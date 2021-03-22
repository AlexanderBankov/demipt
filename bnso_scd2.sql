-- 1. Удаляем данные из стейджинга

DELETE FROM DEMIPT.BNSO_STG_OBJECTS;
DELETE FROM DEMIPT.BNSO_STG_SCHEDULE;
DELETE FROM DEMIPT.BNSO_STG_SCHEDULE_FACT;

-- 2. Захват данных из источника в STG
-- 2.1 SCHEDULE_FACT
INSERT INTO DEMIPT.BNSO_STG_SCHEDULE_FACT ( schedule_fact_id, schedule_id, created, deleted, volume, expenditure )
SELECT 
	schedule_fact_id, schedule_id, created, deleted, volume, expenditure
FROM DEMIPT.BNSO_SRC_SCHEDULE_FACT
WHERE created > (
	SELECT last_update FROM DEMIPT.BNSO_META_LOADING WHERE dbname = 'DEMIPT' AND tablename = 'BNSO_DWH_FACT_SCHEDULE'
	);

-- 2.2 SCHEDULE
INSERT INTO DEMIPT.BNSO_STG_SCHEDULE ( schedule_id, object_id, parent_id, created, modified, deleted, job_id, volume_actual, expenditure_actual, volume_sum, expenditure_sum, element_id )
SELECT 
	schedule_id, object_id, parent_id, created, modified, deleted, job_id, volume_actual, expenditure_actual, volume_sum, expenditure_sum, element_id
FROM DEMIPT.BNSO_SRC_SCHEDULE
WHERE COALESCE ( modified, created ) > (
	SELECT last_update FROM DEMIPT.BNSO_META_LOADING WHERE dbname = 'DEMIPT' AND tablename = 'BNSO_DWH_DIM_SCHEDULE_HIST'
	);

-- 2.3 OBJECT
INSERT INTO DEMIPT.BNSO_STG_OBJECTS ( object_id , project_id , created , modified , deleted , region_id , object_type_id , date_start , date_finish )
SELECT 
	object_id , project_id , created , modified , deleted , region_id , object_type_id , date_start , date_finish 
FROM DEMIPT.BNSO_SRC_OBJECTS
WHERE COALESCE ( modified, created ) > (
	SELECT last_update FROM DEMIPT.BNSO_META_LOADING WHERE dbname = 'DEMIPT' AND tablename = 'BNSO_DWH_DIM_OBJECT_HIST'
	);

-- 3. Вливаем данные в хранилище из STG

-- 3.1 Факты
-- 3.1 SCHEDULE_FACT
INSERT INTO DEMIPT.BNSO_DWH_FACT_SCHEDULE ( schedule_fact_id, schedule_id, created, deleted, volume, expenditure )
SELECT 
	schedule_fact_id, schedule_id, created, deleted, volume, expenditure
FROM DEMIPT.BNSO_STG_SCHEDULE_FACT;

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
FROM DEMIPT.BNSO_STG_SCHEDULE;

MERGE INTO DEMIPT.BNSO_DWH_DIM_SCHEDULE_HIST tgt
USING DEMIPT.BNSO_STG_SCHEDULE src
ON ( tgt.schedule_id = src.schedule_id AND tgt.effective_from < coalesce( src.modified, src.created ) )
WHEN matched THEN UPDATE SET 
    tgt.effective_to = COALESCE( src.modified, src.created ) - interval '1' second
		WHERE tgt.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' );

-- 3.2.2 OBJECT
INSERT INTO DEMIPT.BNSO_DWH_DIM_OBJECT_HIST ( object_id , project_id , created , modified , deleted , region_id , object_type_id , date_start , date_finish , deleted_flg, effective_from, effective_to )
SELECT
	object_id ,
	project_id ,
	created ,
	modified ,
	deleted ,
	region_id ,
	object_type_id ,
	date_start ,
	date_finish ,
	CASE 
		WHEN deleted IS NOT NULL
		THEN 'Y'
		ELSE 'N'
	END AS deleted_flg,
	COALESCE( modified, created ),
	TO_DATE( '2999-12-31', 'YYYY-MM-DD' )
FROM DEMIPT.BNSO_STG_OBJECTS;

MERGE INTO DEMIPT.BNSO_DWH_DIM_OBJECT_HIST tgt
USING DEMIPT.BNSO_STG_OBJECTS src
ON ( tgt.object_id = src.object_id AND tgt.effective_from < coalesce( src.modified, src.created ) )
WHEN matched THEN UPDATE SET 
    tgt.effective_to = COALESCE( src.modified, src.created ) - interval '1' second
		WHERE tgt.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' );

-- 4. Обновляем метаданные - дату максимальной загрузуки
UPDATE DEMIPT.BNSO_META_LOADING 
SET last_update = ( SELECT MAX( created ) FROM DEMIPT.BNSO_STG_SCHEDULE_FACT )
WHERE  dbname = 'DEMIPT' AND tablename = 'BNSO_DWH_FACT_SCHEDULE' AND ( SELECT max( created ) FROM DEMIPT.BNSO_STG_SCHEDULE_FACT ) IS NOT NULL;

UPDATE DEMIPT.BNSO_META_LOADING 
SET last_update = ( SELECT MAX( COALESCE( modified, created ) ) FROM DEMIPT.BNSO_STG_SCHEDULE )
WHERE  dbname = 'DEMIPT' AND tablename = 'BNSO_DWH_DIM_SCHEDULE_HIST' AND ( SELECT max( COALESCE( modified, created ) ) FROM DEMIPT.BNSO_STG_SCHEDULE ) IS NOT NULL;

UPDATE DEMIPT.BNSO_META_LOADING 
SET last_update = ( SELECT max( COALESCE( modified, created ) ) FROM DEMIPT.BNSO_STG_OBJECTS )
WHERE  dbname = 'DEMIPT' AND tablename = 'BNSO_DWH_DIM_OBJECT_HIST' AND ( SELECT MAX( COALESCE( modified, created ) ) FROM DEMIPT.BNSO_STG_OBJECTS ) IS NOT NULL;

commit
