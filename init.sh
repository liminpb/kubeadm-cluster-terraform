#!/bin/bash
echo "Enter your Region"

read reg

echo "Enter your First Zone"

read zonea

echo "Enter your Second Zone"

read zoneb

echo "Enter your Third Zone"

read zonec
echo "Enter your VPC name"

read vpcname

echo "Enter your clustername for the instance tag"
read clusternamess
echo "Enter your ssh public key"
read mypublic
sed -i "s|REG|$reg|g" aws-vpc/example.tfvars
sed -i "s|REGa|$zonea|g" aws-vpc/example.tfvars
sed -i "s|REGb|$zoneb|g" aws-vpc/example.tfvars
sed -i "s|REGc|$zonec|g" aws-vpc/example.tfvars
sed -i "s|VPCNAME|$vpcname|g" aws-vpc/example.tfvars
sed -i "s|myclustername|$clusternamess|g" instance/main.tf
sed -i "s|mypublicKey|$mypublic|g" instance/main.tf
sed -i "s|REG|$reg|g" aws-vpc/network.tf
sed -i "s|REG|$reg|g" instance/main.tf

cd aws-vpc/
terraform init
terraform apply --var-file example.tfvars -auto-approve
printf "\n"
printf "\n"
echo "Your VPC will be ready in a few minutes"
sleep 5s

terraform output security_group > ../securitygroup.txt
terraform output subnets | awk {'print $1'} | sed '$d' | sed "1d" |  sed 's/^.//' | sed 's/..$//' | sed -n 1p > ../subnet.txt

cd ..

subnetids=$(cat subnet.txt)
securitys=$(cat securitygroup.txt)

sed -i "s|subidsss|$subnetids|g" instance/main.tf
sed -i "s|securitygroupidssss|$securitys|g" instance/main.tf

printf "\n"
printf "\n"
echo "Your instences will be ready in a few minutes"
cd instance/
terraform init
terraform apply -auto-approve

