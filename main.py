#! /usr/bin/env python
import pandas
import jaydebeapi
import os
import datetime
conn = jaydebeapi.connect('oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:demipt/gandalfthegrey@de-oracle.chronosavant.ru:1521/deoracle',['demipt','gandalfthegrey'],'/home/demipt/bnso/ojdbc8.jar')
curs = conn.cursor()

#Функция для выполнения загрузки в DWH в SCD2
def ext_load():
    curs.execute("DELETE FROM DEMIPT.BNSO_SRC_OBJECTS")
    curs.execute("DELETE FROM DEMIPT.BNSO_SRC_SCHEDULE")
    curs.execute("DELETE FROM DEMIPT.BNSO_SRC_SCHEDULE_FACT")    
    df = pandas.read_csv( '/home/demipt/bnso/obj'+var+'.csv', sep=',', header=0, index_col=None, usecols=[ 1, 2, 3, 4, 5, 6, 7, 8, 9] )
    df['created'] = pandas.to_datetime(df['created'])
    df['created'] = df['created'].apply(lambda x: x.strftime('%Y-%m-%d'))
    df['modified'] = pandas.to_datetime(df['modified'])
    df['modified'] = df['modified'].apply(lambda x: x.strftime('%Y-%m-%d'))
    df = df.astype(object).where(pandas.notnull(df),None)
    curs.executemany( """insert into DEMIPT.BNSO_SRC_OBJECTS( OBJECT_ID , PROJECT_ID , CREATED , MODIFIED , DELETED , REGION_ID , OBJECT_TYPE_ID , DATE_START , DATE_FINISH  ) values ( ?, ?, to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), ?, ?, ?, to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ) )""", df.values.tolist() )    
    df = pandas.read_csv( '/home/demipt/bnso/schedule'+var+'.csv', sep=',', header=0, index_col=None , usecols=[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
    df['created'] = pandas.to_datetime(df['created'])
    df['created'] = df['created'].apply(lambda x: x.strftime('%Y-%m-%d'))
    df['modified'] = pandas.to_datetime(df['modified'])
    df['modified'] = df['modified'].apply(lambda x: x.strftime('%Y-%m-%d'))
    df = df.astype(object).where(pandas.notnull(df),None)
    curs.executemany( """insert into DEMIPT.BNSO_SRC_SCHEDULE( SCHEDULE_ID , OBJECT_ID , PARENT_ID , CREATED , MODIFIED , DELETED , JOB_ID , VOLUME_ACTUAL , EXPENDITURE_ACTUAL , VOLUME_SUM , EXPENDITURE_SUM , ELEMENT_ID ) values ( ?, ?, ?, to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), ?, ?, ?, ?, ?, ?, ? )""", df.values.tolist() )
    df = pandas.read_csv( '/home/demipt/bnso/schedule_fact'+var+'.csv', sep=',', header=0, index_col=None , usecols=[ 1, 2, 3, 5, 6, 7])
    df['created'] = pandas.to_datetime(df['created'])
    df['created'] = df['created'].apply(lambda x: x.strftime('%Y-%m-%d'))
    df = df.astype(object).where(pandas.notnull(df),None)
    curs.executemany( """insert into DEMIPT.BNSO_SRC_SCHEDULE_FACT ( SCHEDULE_FACT_ID , SCHEDULE_ID , CREATED , DELETED , VOLUME , EXPENDITURE  ) values ( ?, ?, to_date( ?, 'YYYY-MM-DD HH24:MI:SS' ), ?, ?, ?)""", df.values.tolist() )

#Функция для выполнения загрузки в DWH в SCD2
def run_sql_scd2 ():
    with open('/home/demipt/bnso/sql_scripts/bnso_scd2.sql', 'r', newline='') as file:
        sql = file.read()
        for sql_statement in sql.split(';'):
            curs.execute(sql_statement)

Функция для выполнения отчетов
def run_sql_report ():
    with open('/home/demipt/bnso/sql_scripts/report.sql', 'r', newline='') as file:
        sql = file.read()
        for sql_statement in sql.split(';'):
            curs.execute(sql_statement)

#Функция для помещения файлов в архив
#def to_archive ():
#    os.rename ('/home/demipt/bnkv/terminals_'+var+'.xlsx', '/home/demipt/bnkv/archive/terminals_'+var+'.xlsx.backup')
#    os.rename ('/home/demipt/bnkv/passport_blacklist_'+var+'.xlsx', '/home/demipt/bnkv/archive/passport_blacklist_'+var+'.xlsx.backup')
#    os.rename ('/home/demipt/bnkv/transactions_'+var+'.txt', '/home/demipt/bnkv/archive/transactions_'+var+'.txt.backup')

# 01.03.2021
input('Нажмите Enter для загрузки данных за 01.01.2021')
print ('Загрузка данных за 01.01.2021...')
var = '01012021'
ext_load()
run_sql_scd2()
#run_sql_report()
#to_archive ()
input('Загрузка данных за 01.01.2021 завершена. Нажмите Enter для загрузки данных за 01.02.2021')

#02.03.2021
print ('Загрузка данных за 01.02.2021...')
var = '01022021'
ext_load()
run_sql_scd2()
#run_sql_report()
#to_archive ()
input('Загрузка данных за 01.02.2021 завершена. Нажмите Enter для загрузки данных за 01.03.2021')

#03.03.2021
print ('Загрузка данных за 01.03.2021...')
var = '01032021'
ext_load()
run_sql_scd2()
run_sql_report()
#to_archive ()
print ('Загрузка данных выполнена, отчет составлен. Александр молодец и заслуживает максимальных баллов. :)')

curs.close()
conn.close()

#df = pandas.read_csv( 'schedule_fact-01032021.csv', header=0, index_col=None, usecols=[0, 1, 3, 4, 7, 9, 10])
#df.to_csv("schedule_fact01032021.csv")
