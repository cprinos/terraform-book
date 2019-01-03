variable "server_port" {
    description = "the port the server uses for http"
    default = 8080
}

variable "cluster_name" {
    description = "name to use for all cluster resources"
}

variable "db_remote_state_bucket" {
    description = "name of the s3 bucket for the db remote state"
}

variable "db_remote_state_key" {
  description = "path for the db remote state in s3"
}
