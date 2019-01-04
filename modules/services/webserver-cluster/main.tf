
data "aws_availability_zones" "all" {}
data "terraform_remote_state" "db" {
    backend = "s3"

    config {
        bucket = "${var.db_remote_state_bucket}"
        key = "${var.db_remote_state_key}"
        region = "us-east-1"
    }
}

data "template_file" "user_data" {
    template = "${file("${path.module}/user-data.sh")}"

    vars {
        server_port = "${var.server_port}"
        db_address = "${data.terraform_remote_state.db.address}"
        db_port = "${data.terraform_remote_state.db.port}"
    }
}
resource "aws_launch_configuration" "example-asg" {
    image_id = "ami-40d28157"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.instance.id}"]

    user_data = "${data.template_file.user_data.rendered}"
    name = "${var.cluster_name}-launchconfig"
    
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
    name = "${var.cluster_name}-asg"

    tag {
        key = "Name"
        value = "${var.cluster_name}-asg-example"
        propagate_at_launch = true
    }

}

resource "aws_elb" "example" {
    name  = "${var.cluster_name}-elb"
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

resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-instance-security-group"
    
    

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
    name = "${var.cluster_name}-elb-security-group"


    # for health check
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "http_inbound" {
    type = "ingress"
    security_group_id = "${aws_security_group.elb.id}"

    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   
}

resource "aws_security_group_rule" "http_outbound" {
    type = "egress"
    security_group_id = "${aws_security_group.elb.id}"

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   
}