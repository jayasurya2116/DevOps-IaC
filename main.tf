# main.tf

provider "aws" {
  region = "us-east-1" # Update with your desired AWS region
}

resource "aws_redshift_cluster" "example" {
  cluster_identifier   = "my-redshift-cluster"
  database_name       = "mydb"
  master_username     = "admin"
  master_password     = "YourPassword123" # Replace with a secure password
  node_type           = "dc2.large"
  cluster_type        = "multi-node"
  number_of_nodes     = 2
  publicly_accessible = false

  skip_final_snapshot = true
}

resource "aws_security_group" "redshift" {
  name        = "redshift"
  description = "Redshift Security Group"

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
