# my_dag.py

from airflow import DAG
from airflow.providers.amazon.aws.transfers.s3_to_redshift import S3ToRedshiftOperator
from datetime import datetime

default_args = {
    'owner': 'your_name',
    'start_date': datetime(2023, 9, 22),
    # Define other DAG options here
}

dag = DAG('my_dag', default_args=default_args)

s3_to_redshift_task = S3ToRedshiftOperator(
    task_id='s3_to_redshift',
    schema='your_redshift_schema',
    table='your_redshift_table',
    copy_options=['CSV'],
    aws_conn_id='aws_default',
    s3_bucket='your_s3_bucket',
    s3_key='your_s3_key',
    schema_location='s3://your_s3_bucket/schema/',
    copy_options=["csv"],
    aws_conn_id="aws_default",
    task_id="copy_csv_to_redshift",
    dag=dag,
)
