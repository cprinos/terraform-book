#

# set password in env using the following:
# $ export TF_VAR_db_password = "<the_actual_password>"
variable "db_password" {
    description = "the db password"
}

variable "db_name" {
    description = "the db name"
}
