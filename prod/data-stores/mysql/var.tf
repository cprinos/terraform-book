module "database" {
    source = "../../../modules/data-stores/mysql"

    db_name = "dbprod"
    db_password = "${var.db_password}"
}

variable "db_password" {
    description = "the database password"
}
