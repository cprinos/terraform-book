output "public_dns" {
    value = "${aws_elb.example.dns_name}"
}
