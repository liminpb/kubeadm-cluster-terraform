provider "aws" {
  region = "REG"
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
  public_key = "mypublicKey"
}
resource "aws_instance" "kubernetestest" {
  ami           = "ami-085925f297f89fce1"
  instance_type = "t2.xlarge"
  subnet_id              = "subidsss"
  vpc_security_group_ids = ["securitygroupidssss"]
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
   "kubernetes.io/cluster/myclustername" = "owned"
 }
}
