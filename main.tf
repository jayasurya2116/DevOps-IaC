terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}



provider "aws" {
  region = "eu-west-1"
}



resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!$%&*()-_=+[]{}<>:?"
}

resource "random_string" "unique_suffix" {
  length  = 6
  special = false
}



resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier = "tf-redshift-cluster"
  database_name      = "mydb"
  master_username    = "admin"
  master_password    = random_password.password.result
  node_type          = "dc2.large"
  cluster_type       = "single-node"

  skip_final_snapshot = true
}

resource "aws_secretsmanager_secret" "redshift_connection" {
  description = "Redshift connect details"
  name        = "redshift_secret_${random_string.unique_suffix.result}"
}

resource "aws_secretsmanager_secret_version" "redshift_connection" {
  secret_id = aws_secretsmanager_secret.redshift_connection.id
  secret_string = jsonencode({
    username            = aws_redshift_cluster.redshift_cluster.master_username
    password            = aws_redshift_cluster.redshift_cluster.master_password
    engine              = "redshift"
    host                = aws_redshift_cluster.redshift_cluster.endpoint
    port                = "5439"
    dbClusterIdentifier = aws_redshift_cluster.redshift_cluster.cluster_identifier
  })
}


resource "aws_mwaa_environment" "example_mwaa" {
  name          = "my-airflow-environment"
  execution_role_arn = "arn:aws:iam::123456789012:role/service-role/AWSMWAAService-ExecutionRole"
  max_workers   = 5
  network_configuration {
    security_group_ids = ["sg-0123456789abcdef0"]  
    subnet_ids         = ["subnet-0123456789abcdef0"]  
  }
}

resource "aws_iam_policy_attachment" "mwaa_execution_role_policy" {
  name       = "mwaa_execution_role_policy_attachment"
  roles      = [aws_iam_role.mwaa_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"  
}

resource "aws_iam_role" "mwaa_execution_role" {
  name = "my-mwaa-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "airflow.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "mwaa_execution_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonMWAAEnvironmentRole"  
  role       = aws_iam_role.mwaa_execution_role.name
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "Dataredshiftsurya" 
  acl    = "private" 


  versioning {
    enabled = true
  }

 
  tags = {
    Name = "MyExampleBucket"
    Environment = "Development"
  }
}

resource "aws_mwaa_web_login" "example_web_login" {
  name = aws_mwaa_environment.example_mwaa.name
}

