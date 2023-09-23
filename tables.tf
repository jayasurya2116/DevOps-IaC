# tables.tf

resource "aws_redshift_parameter_group" "example" {
  name = "example-redshift-parameter-group"

  parameter {
    name  = "query_group"
    value = "default"
  }
}

resource "aws_redshift_parameter_group" "example" {
  name = "example-redshift-parameter-group"

  parameter {
    name  = "query_group"
    value = "default"
  }
}

resource "aws_redshift_database" "example" {
  name     = "mydb"
  cluster_identifier = aws_redshift_cluster.example.id
}

resource "aws_redshift_table" "example" {
  count = length(fileset(path.module, "create.sql"))

  schema = aws_redshift_database.example.name
  name   = replace(element(fileset(path.module, "create.sql"), count.index), ".sql", "")
  database_name = aws_redshift_database.example.name
  cluster_identifier = aws_redshift_cluster.example.id

  column {
    name = "id"
    type = "integer"
  }

  # Define other columns as needed based on your SQL file.
}
