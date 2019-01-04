provider "aws" {
    region = "us-east-1"
}

resource "aws_autoscaling_schedule" "scale_out_bus_hours" {
    scheduled_action_name = "scale-out-bus-hours"
    min_size = 2
    max_size = 10
    desired_capacity = 4
    recurrence = "0 9 * * *"

    autoscaling_group_name = "${module.webserver_cluster.asg_name}"
}

resource "aws_autoscaling_schedule" "scale_in_night" {
    scheduled_action_name = "scale-in-night"
    min_size = 2
    max_size  = 10
    desired_capacity = 2
    recurrence = "0 17 * * *"

    autoscaling_group_name = "${module.webserver_cluster.asg_name}"

}
terraform {
  backend "s3" {
    bucket = "cjpzip-terraform-up-and-running-state"
    key    = "prod/services/webserver"
    region = "us-east-1"
    encrypt = true
  }
}