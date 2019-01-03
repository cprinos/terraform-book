output "public_ip" {
    value = "${aws_elb.example.dns_name}"
}
