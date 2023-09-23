# DevOps-IaC
Real time Devops Iac and CI CD Implementation

Hi Team,

I have created Following Resources in aws

1) AWS Redshift - DataWarehouse
2) AWS SecretsManager - To Maintain Access keys
3) AWS Airflow - Data Pipeline
4) AWS S3 Bucket - Data Storage

Data will be loaded in S3, using Datapipeline by Airflow Data from S3 will loaded into staging and Final Table in Redshift

Please refer terraform code to get clear understanding

Steps:

1)terraform init
2)terraform plan
3)terraform apply

If you want to delete the infrastructure, use
terraform destroy
