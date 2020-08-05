output "vpc" {
  value = "${module.vpc.vpc_id}"
}

output "subnets" {
  value = "${module.vpc.subnet_ids}"
}

output "security_group" {
  value = "${aws_security_group.kubernetes.id}"
}
