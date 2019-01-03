resource "aws_db_instance" "example" {
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    name = "${var.db_name}"
    username = "admin"
    password = "${var.db_password}"
    skip_final_snapshot = true
}
