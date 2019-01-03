provider "aws" {
    region = "us-east-1"
}
variable "server_port" {
    description = "the port the server uses for http"
    default = 8080
}

output "public_ip" {
    value = "${aws_elb.example.dns_name}"
}

resource "aws_launch_configuration" "example-asg" {
    image_id = "ami-40d28157"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.instance.id}"]

   user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world" > index.html
        nohup busybox httpd -f -p "${var.server_port}" &
        EOF

    lifecycle {
        create_before_destroy = true
    }

}

resource "aws_autoscaling_group" "example" {
    launch_configuration = "${aws_launch_configuration.example-asg.id}"
    min_size = 2
    desired_capacity = 3
    max_size = 10 
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    load_balancers = ["${aws_elb.example.name}"]
    health_check_type = "ELB"

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }

}

resource "aws_elb" "example" {
    name = "terraform-asg-example"
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    security_groups = ["${aws_security_group.elb.id}"]

    listener {
        lb_port = 80
        lb_protocol = "http"
        instance_port = "${var.server_port}"
        instance_protocol = "http"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout = 3
        interval = 30
        target = "HTTP:${var.server_port}/"
    }
}
data "aws_availability_zones" "all" {}

resource "aws_security_group" "instance" {
    name = "tf-example-instance"

    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "elb" {
    name = "terraform-example-elb"

    ingress = {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # for health check
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}