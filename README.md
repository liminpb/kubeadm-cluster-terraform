# Terraform-aws-kubeadm

OS : ubuntu 18

The folder "yamls" contains the yaml files es,kibana,wordpress,storageclass and kubeadm init config

The folder "aws-vpc" contains terraform files to build a VPC

The folder "instance" contains terraform files to build 4 instances with below 7 changes:
 
 1: Assign VPC and security group.
 
 2: Creates a IAM role with EC2 full access and assign to the instances.
 
 4: Add the below tags for all the instances :
 
  Key : kubernetes.io/cluster/clustername (you can enter the cluster name while initiating the init.sh script)
  Value: owned 

  5: 100 GB volume

  6: Adds key using the ssh public key which you update while initiating the init.sh script

  7: instance_type = t2.xlarge
 
 The folder "instance-with-bootstrap-template" contains the terraform files to build 4 instances with above 7 changes and also it includes a template file which will automatically install all the 1-10 procedure mentioned in the "step1" in this md file. 
 
NB: You can either use "instance" folder to create the instances and  do the all steps manually, or you can use the "instance-with-bootstrap-template" to create the instances and skip the step1 of this page. If you are using the "instance-with-bootstrap-template", please read the README.md under "instance-with-bootstrap-template".
 


************************************************************************************************************

Make sure your bastion host have the aws cli configured and  Terraform v0.12.26 installed, if not kindly install the same.


* Clone the git repo to the bastion host:

		https://github.com/liminpb/kubeadm-cluster-terraform.git

cd Kubeadm-aws


* Initiate the init.sh script:

       ./init.sh

           The script will ask you to enter region,AZ, your ssh public key,clustername,vpc name etc. Kindly enter those details. Once you give complete details, the script will start to build the VPC and instances using terraform.


#      Lets start to setup the cluster:


# Step1 (setup the below 1-10 in master and worker nodes):

  1: Kindly login to the instances (both master and worker) and Set the hostname of the EC2 instances to the private DNS hostname of the instance:
 
      sudo hostnamectl set-hostname $(curl -s http://169.254.169.254/latest/meta-data/local-hostname)
 
 Install docker-ce, kubelet, kubeadm and kubectl in master and worker nodes, proceed below steps for that:
 
  2: Get the Docker gpg key:

      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  3: Add the Docker repository:

     sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  
  
   4: Get the Kubernetes gpg key:

    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

   5: Add the Kubernetes repository:

    cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
    EOF

   6: Update your packages:

    sudo apt-get update

   7: Install Docker, kubelet, kubeadm, and kubectl:
  
     sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu kubelet=1.15.7-00 kubeadm=1.15.7-00 kubectl=1.15.7-00

   8: Hold them at the current version:

    sudo apt-mark hold docker-ce kubelet kubeadm kubectl

   9: Add the iptables rule to sysctl.conf:

    echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf

   10: Enable iptables immediately:

    sudo sysctl -p

---------------------------------------------------------------

By default kubeadm does not support cloud providers, so that we need to pass the --cloud-provider=aws argument while initializing the kubeadm, otherwise we wont able to integrate the cluster with the AWS.

--cloud-provider=aws command-line flag should be present for for the API server, controller manager, and every Kubelet in the cluster.

# Step 2:

For kubelet, the service will be run based on the kubeadm conf file "/etc/systemd/system/kubelet.service.d/10-kubeadm.conf", so please add the flag "--cloud-provider=aws" in the ExecStart field of the kubeadm conf file in all the instances (master and worker).

regarding the  API server, controller manager, we have to create the yaml configuration file and add the --cloud-provider=aws option to use while running the kubeadm command (kubeconf-init.yaml) from the master.

Please run the kubeadm init from the master with configuration file : 

    sudo kubeadm init --config kubeconf-init.yaml
    
(The yaml file present under yamls/kubeadm-init, please replace "privatehostnameofyourmasterinstance" with your master private DNS name in kubeconf-init.yaml)

Once the initialization completed, you will get the join URL with the apiendpoint, token,  caCertHashes to add the worker nodes to the cluster

eg:   kubeadm join 10.0.1.32:6443 --token 633733.1pguylfrm3ux5n70 --discovery-token-ca-cert-hash sha256:90f95a3fbb60ff12091192c99eb7903d89b45abbffb1e74862459360239749f7

# Step3:


Set up local kubeconfig (run only on the master):

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config




Install CNI plugins(Weave) :

Download the CNI Plugins required for weave on each of the worker nodes

    wget https://github.com/containernetworking/plugins/releases/download/v0.7.5/cni-plugins-amd64-v0.7.5.tgz

Extract it to /opt/cni/bin directory

    sudo tar -xzvf cni-plugins-amd64-v0.7.5.tgz --directory /opt/cni/bin/

Deploy Weave Network

Deploy weave network. Run only once on the master node.

     kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"




# Step4 :

Once the CNI is ready and the master status is ready, we can join the worker nodes using the join URL which was generated while running the kubeadm init.

    kubeadm join 10.0.1.32:6443 --token 633733.1pguylfrm3ux5n70 --discovery-token-ca-cert-hash    sha256:90f95a3fbb60ff12091192c99eb7903d89b45abbffb1e74862459360239749f7




check the node status:

    kubectl get nodes


Once the nodes and master are available, you can deploy the wordpress and EFK. Since we integrate the AWS with the cluster, the pv,pvc,loadbalancer etc will be created automatically in the AWS.

NB: Please run the storageclass yaml "storage.yaml" first. because ,I have mentioned that storageclass in the pvc.

Go to the yamls folder.
    
    kubectl apply -f storage.yaml

Then deploy the reset of them:

    kubect apply -f wordpress/
    kubect apply -f es/
    kubect apply -f kibana/
    
 Wait for a few minutes, until the instances are get healthy in service Loadbalancer . Then you can access the Kibana with 5601 port, and wordpress with port 80.
 
 Get the service list:
    
    kubect get svc
# Kubeadm-Cluster-Spinnup
