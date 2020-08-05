provider "aws" {
  region = "us-east-1"
}
resource "aws_iam_role" "kuberole" {
  name = "kuberole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "kuberole"
  }
}
resource "aws_iam_instance_profile" "kube_profile" {
  name = "kube_profile"
  role = "${aws_iam_role.kuberole.name}"
}
resource "aws_iam_role_policy" "kube_policy" {
  name = "kube_policy"
  role = "${aws_iam_role.kuberole.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
     },
     {
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
     },
     {
      "Effect": "Allow",
      "Action": "autoscaling:*",
      "Resource": "*"
     }
  ]
}
EOF
}
resource "aws_key_pair" "terraform_ec2_key" {
  key_name = "terraform_ec2_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCamhVhO/NYiQ76reZFinEmQvqwf8zglJz+nxHpKNg7GVYnvfUrAxVFy2ZTvXyYjbsbmHfs068SUAhcD7uHAmAzxQEyDCA1RBaFZ2QFV0kX3MbwOlG++abpvZUTkh+PHTRRgPn+vKRYmw5fjzmkZxtiecF2sWNT9XlJOOhiH9lB1zJ8PnEIT5Sgtx6LqKIoNn5VxS2IfRw+AVzdMJEnb+PBXWcOy3q4TOjM6ygMA1WqLGIzkBOdIMXP/IPG3AXmBYk3Ly7veumaWp8CBZVIq9te9TlHCM4po6c6M3509n80w04SDkMl6qfjxBx3b3cEwSEA7yCMgo6fsZS52WUmiS0b root@DESKTOP-0M019OH"
}
resource "aws_instance" "kubernetestest" {
  ami           = "ami-085925f297f89fce1"
  instance_type = "t2.xlarge"
  subnet_id              = "ubnet-0fb0975c17535f05"
  vpc_security_group_ids = ["sg-0f4a2163489fed087"]
  iam_instance_profile = "${aws_iam_instance_profile.kube_profile.name}"
  count = 4
  associate_public_ip_address = true
  root_block_device {
  volume_type = "gp2"
  volume_size = "100"
  delete_on_termination = "true"
}
  key_name = "${aws_key_pair.terraform_ec2_key.key_name}"
  tags = {
   "kubernetes.io/cluster/liminkube" = "owned"
 }
}
