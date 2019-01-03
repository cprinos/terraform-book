provider "aws" {
    region = "us-east-1"
}
variable "server_port" {
    description = "the port the server uses for http"
    default = 8080
}

output "public_ip" {
    value = "${aws_instance.example.public_ip}"
}
resource "aws_instance" "example" {
    ami = "ami-40d28157"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.instance.id}"]

    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world" > index.html
        nohup busybox httpd -f -p "${var.server_port}" &
        EOF

    tags {
        Name = "book-example"
    }
}

resource "aws_security_group" "instance" {
    name = "tf-example-instance"

    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}