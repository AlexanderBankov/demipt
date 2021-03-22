--------------------------------------------------------
-- DDLs for staging
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table OBJECTS
--------------------------------------------------------
-- Нужны поля 0, 2, 3, 4, 7, 12, 15, 17, 18
CREATE TABLE DEMIPT.BNSO_STG_OBJECTS (
	object_id integer,
	-- 1 object_guid uuid,
	project_id integer,
	created date,
	modified date,
	--5 created_by integer,
	--6 modified_by integer,
	deleted integer,
	--8 name_ru varchar(255),
	--9 description_ru text,
	--10 address varchar(255),
	--11 geo_coord point,
	region_id integer,
	--13 meta jsonb,
	--14 external_data jsonb,
	object_type_id integer,
	--16 broadcast_url varchar(255),
	date_start date,
	date_finish date
	--19 name_en varchar(255),
	--20 description_en text,
	--21 passport_data_ru jsonb,
	--22 passport_data_en jsonb,
	--23 calculation_method "public".guntt_calculatio n_method,
	--24 weighting_factor numeric(4,3),
	--25 status_data jsonb,
	--26 settings jsonb
);

--------------------------------------------------------
--  DDL for Table SCHEDULE
--------------------------------------------------------
-- Нужны поля 0, 1, 3, 4, 5, 8, 10, 12, 13, 18, 19, 20
CREATE TABLE DEMIPT.BNSO_STG_SCHEDULE (
	schedule_id integer,
	object_id integer,
	--2 schedule_guid uuid
	parent_id integer,
	created date,
	modified date,
	--6 created_by integer
	--7 modified_by integer
	deleted integer,
	--9 name varchar(255)
	job_id integer,
	--11 job_unit pkg_reference.job_unit
	volume_actual numeric,
	expenditure_actual numeric,
	--14 meta jsonb
	--15 external_data jsonb
	--16 sort_order integer
	--17 parent_path ltree
	volume_sum numeric,
	expenditure_sum numeric,
	element_id integer
	--21 weighting_factor numeric
	--22 comment varchar(150)
);

--------------------------------------------------------
--  DDL for Table SCHEDULE_FACT
--------------------------------------------------------
-- Нужны поля 0, 1, 3, 4, 7, 9, 10
CREATE TABLE DEMIPT.BNSO_STG_SCHEDULE_FACT (
	schedule_fact_id integer,
	schedule_id integer,
	--2 schedule_fact_group_id integer
	created date,
	--5 created_by integer
	--6 modified_by integer
	deleted integer,
	--8 fact_type "public".fact
	volume numeric,
	expenditure numeric
	--11 comment varchar(255)
	--12 schedule_fact_guid uuid
	--13 external_data jsonb
	--14 fact_source "public".fact_source
	--15 schedule_fact_correction_data_id integer
	--16 created_original timestamp
	--17 employee integer
	--18 image_count integer
);

--------------------------------------------------------
-- DDLs for DWH
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table SCHEDULE_FACT
--------------------------------------------------------

CREATE TABLE DEMIPT.BNSO_DWH_FACT_SCHEDULE (
	schedule_fact_id integer,
	schedule_id integer,
	created date,
	deleted integer,
	volume numeric,
	expenditure numeric
);

--------------------------------------------------------
--  DDL for Table SCHEDULE
--------------------------------------------------------

CREATE TABLE DEMIPT.BNSO_DWH_DIM_SCHEDULE_HIST (
	schedule_id integer,
	object_id integer,
	parent_id integer,
	created date,
	modified date,
	deleted integer,
	job_id integer,
	volume_actual numeric,
	expenditure_actual numeric,
	volume_sum numeric,
	expenditure_sum numeric,
	element_id integer,
	deleted_flg char( 1 byte ),
	effective_from date, 
	effective_to date
);

--------------------------------------------------------
--  DDL for Table OBJECT
--------------------------------------------------------

CREATE TABLE DEMIPT.BNSO_DWH_DIM_OBJECT_HIST (
	object_id integer,
	project_id integer,
	created date,
	modified date,
	deleted integer,
	region_id integer,
	object_type_id integer,
	date_start date,
	date_finish date,
	deleted_flg char( 1 byte ),
	effective_from date, 
	effective_to date
);

--------------------------------------------------------
-- DDL and first input for META
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table META
--------------------------------------------------------
CREATE TABLE DEMIPT.BNSO_META_LOADING (
	DBNAME VARCHAR2(100),
	TABLENAME VARCHAR2(100),
	LAST_UPDATE DATE  
);

--------------------------------------------------------
-- First input for META
--------------------------------------------------------
INSERT INTO DEMIPT.BNSO_META_LOADING( DBNAME, TABLENAME, LAST_UPDATE ) 
VALUES ( 'DEMIPT', 'BNSO_DWH_FACT_SCHEDULE', to_date( '1800-01-01', 'YYYY-MM-DD' ) );
INSERT INTO DEMIPT.BNSO_META_LOADING( DBNAME, TABLENAME, LAST_UPDATE ) 
VALUES ( 'DEMIPT', 'BNSO_DWH_DIM_SCHEDULE_HIST', to_date( '1800-01-01', 'YYYY-MM-DD' ) );
INSERT INTO DEMIPT.BNSO_META_LOADING( DBNAME, TABLENAME, LAST_UPDATE ) 
VALUES ( 'DEMIPT', 'BNSO_DWH_DIM_OBJECT_HIST', to_date( '1800-01-01', 'YYYY-MM-DD' ) );

COMMIT
/*
SELECT * FROM DEMIPT.BNSO_STG_OBJECTS;
SELECT * FROM DEMIPT.BNSO_STG_SCHEDULE;
SELECT * FROM DEMIPT.BNSO_STG_SCHEDULE_FACT;
SELECT * FROM DEMIPT.BNSO_DWH_FACT_SCHEDULE;
SELECT * FROM DEMIPT.BNSO_DWH_DIM_SCHEDULE;
SELECT * FROM DEMIPT.BNSO_DWH_DIM_OBJECT;
SELECT * FROM DEMIPT.BNSO_META_LOADING;

DELETE FROM DEMIPT.BNSO_STG_OBJECTS;
DELETE FROM DEMIPT.BNSO_STG_SCHEDULE;
DELETE FROM DEMIPT.BNSO_STG_SCHEDULE_FACT;
DELETE FROM DEMIPT.BNSO_DWH_FACT_SCHEDULE;
DELETE FROM DEMIPT.BNSO_DWH_DIM_SCHEDULE;
DELETE FROM DEMIPT.BNSO_DWH_DIM_OBJECT;
DELETE FROM DEMIPT.BNSO_META_LOADING;

DROP TABLE DEMIPT.BNSO_STG_OBJECTS;
DROP TABLE DEMIPT.BNSO_STG_SCHEDULE;
DROP TABLE DEMIPT.BNSO_STG_SCHEDULE_FACT;
DROP TABLE DEMIPT.BNSO_DWH_FACT_SCHEDULE;
DROP TABLE DEMIPT.BNSO_DWH_DIM_SCHEDULE;
DROP TABLE DEMIPT.BNSO_DWH_DIM_OBJECT;
DROP TABLE DEMIPT.BNSO_META_LOADING;
*/
