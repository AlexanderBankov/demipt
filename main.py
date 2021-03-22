#! /usr/bin/env python
import pandas
import jaydebeapi
import os
import datetime
conn = jaydebeapi.connect('oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:demipt/gandalfthegrey@de-oracle.chronosavant.ru:1521/deoracle',['demipt','gandalfthegrey'],'/home/demipt/bnso/ojdbc8.jar')
curs = conn.cursor()

#Функция для выполнения загрузки в DWH в SCD2
def ext_load():
    curs.execute("DELETE FROM DEMIPT.BNSO_STG_OBJECTS")
    curs.execute("DELETE FROM DEMIPT.BNSO_STG_SCHEDULE")
    curs.execute("DELETE FROM DEMIPT.BNSO_STG_SCHEDULE_FACT")    
    df = pandas.read_csv( '/home/demipt/bnso/obj'+var+'.csv', sep=',', header=0, index_col=None, usecols=[ 1, 2, 3, 4, 5, 6, 7, 8, 9] )
    df['created'] = pandas.to_datetime(df['created'])
    df['created'] = df['created'].apply(lambda x: x.strftime('%Y-%m-%d'))
    df['modified'] = pandas.to_datetime(df['modified'])
    df['modified'] = df['modified'].apply(lambda x: x.strftime('%Y-%m-%d'))
    df = df.astype(object).where(pandas.notnull(df),None)
    curs.executemany( """insert into DEMIPT.BNSO_STG_OBJECTS( OBJECT_ID , PROJECT_ID , CREATED , MODIFIED , DELETED , REGION_ID , OBJECT_TYPE_ID , DATE_START , DATE_FINISH  ) values ( ?, ?, to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), ?, ?, ?, to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ) )""", df.values.tolist() )    
    df = pandas.read_csv( '/home/demipt/bnso/schedule'+var+'.csv', sep=',', header=0, index_col=None , usecols=[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
    df['created'] = pandas.to_datetime(df['created'])
    df['created'] = df['created'].apply(lambda x: x.strftime('%Y-%m-%d'))
    df['modified'] = pandas.to_datetime(df['modified'])
    df['modified'] = df['modified'].apply(lambda x: x.strftime('%Y-%m-%d'))
    df = df.astype(object).where(pandas.notnull(df),None)
    curs.executemany( """insert into DEMIPT.BNSO_STG_SCHEDULE( SCHEDULE_ID , OBJECT_ID , PARENT_ID , CREATED , MODIFIED , DELETED , JOB_ID , VOLUME_ACTUAL , EXPENDITURE_ACTUAL , VOLUME_SUM , EXPENDITURE_SUM , ELEMENT_ID ) values ( ?, ?, ?, to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), ?, ?, ?, ?, ?, ?, ? )""", df.values.tolist() )
    df = pandas.read_csv( '/home/demipt/bnso/schedule_fact'+var+'.csv', sep=',', header=0, index_col=None , usecols=[ 1, 2, 3, 5, 6, 7])
    df['created'] = pandas.to_datetime(df['created'])
    df['created'] = df['created'].apply(lambda x: x.strftime('%Y-%m-%d'))
    df = df.astype(object).where(pandas.notnull(df),None)
    curs.executemany( """insert into DEMIPT.BNSO_STG_SCHEDULE_FACT ( SCHEDULE_FACT_ID , SCHEDULE_ID , CREATED , DELETED , VOLUME , EXPENDITURE  ) values ( ?, ?, to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), ?, ?, ?)""", df.values.tolist() )
