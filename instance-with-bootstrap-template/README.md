This folder contains the bootstrap template of the instance which will automatically update all the steps mentioned in the "Step1" of the main README.md.

It will setup all the 1-10.

If you want to use this to reduce the admin overhead, you can move back the current instance folder "Kubeadm-aws/instance", and rename the folder "Kubeadm-aws/instance-with-bootstrap-template" to "Kubeadm-aws/instance", because the init.sh script will only initiate the terraform under the folder name "instance" in-order to create the instances.

Once you rename the folder , initiate the init.sh script under "Kubeadm-aws/"

Once the instances are created, you only have to proceed from the "step2" from the main README.md.
