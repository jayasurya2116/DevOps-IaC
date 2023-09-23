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


resource "aws_redshift_database" "example_database" {
  cluster_identifier = aws_redshift_cluster.redshift_cluster.id
  name              = "mydb" # Change this to your desired database name

 
  provisioner "local-exec" {
    command = "psql -h ${aws_redshift_cluster.redshift_cluster.endpoint} -U ${aws_redshift_cluster.redshift_cluster.master_username} -d ${aws_redshift_database.example_database.name} -f create.sql"
  }

  depends_on = [aws_redshift_cluster.redshift_cluster]
}


resource "null_resource" "create_sql_file" {
  triggers = {
    content = file("${path.module}/create.sql")
  }
}

# Define a dependency between create_sql_file and aws_redshift_database to ensure SQL is executed after database creation
resource "aws_redshift_database" "example_database" {
  depends_on = [null_resource.create_sql_file]
}
