#!/bin/bash
cd instance/
terraform destroy  -auto-approve
cd ..
cd aws-vpc/
terraform destroy --var-file example.tfvars -auto-approve
