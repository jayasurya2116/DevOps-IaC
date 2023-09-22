provider "aws" {
  region = "YOUR_AWS_REGION"
}

# Create a Redshift cluster for the Data Warehouse
module "redshift" {
  source         = "./modules/data_warehouse"
  cluster_name   = "my-data-warehouse"
  master_user    = "admin"
  master_password = "your-password"
  node_type      = "dc2.large"
  number_of_nodes = 2
  # Other Redshift configuration variables
}

# Create an Airflow server
module "airflow" {
  source           = "./modules/airflow"
  airflow_version  = "2.0.1"
  ec2_instance_type = "t2.micro"
  # Other Airflow configuration variables
}

# Define IAM roles and policies for Airflow to access AWS resources
resource "aws_iam_role" "airflow" {
  name = "AirflowExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "redshift-access" {
  name = "RedshiftAccessPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "redshift:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "redshift-access" {
  policy_arn = aws_iam_policy.redshift-access.arn
  roles      = [aws_iam_role.airflow.name]
}

resource "aws_iam_instance_profile" "airflow" {
  name = "AirflowInstanceProfile"

  role = aws_iam_role.airflow.name
}

