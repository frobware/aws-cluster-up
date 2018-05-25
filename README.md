# aws-cluster-up
Define and deploy AWS infrastructure; generate OpenShift ansible inventories

# Install

    $ git clone https://github.com/frobware/aws-cluster-up.git

## Dependencies

	# Install jq(1), aws-cli(1), terraform(1).
	
# Usage

### Define and deploy a cluster on AWS

    $ ~/aws-cluster-up/bin/acu-launch -a ~/amcdermo-ASG ~/aws-cluster-up/share/terraform/3node-cluster

### Generate inventory based on deployed cluster

    $ ~/aws-cluster-up/bin/acu-generate-inventory ~/amcdermo-ASG ~/aws-cluster-up/share/inventory/ocp3.10 > ~/amcdermo-ASG/inventory/ocp3.10.ini

### Generate ssh/config based on deployed cluster

	$ ~/aws-cluster-up/bin/acu-generate-ssh-config ~/amcdermo-ASG > ~/.ssh/conf.d/aws-cluster-up/amcdermo-ASG.conf

### Deploy using openshift ansible against generated inventory

    $ cd ~/openshift-ansible
	$ git checkout openshift-ansible-3.10.0-0.51.0

    $ ansible-playbook -v -i ~/amcdermo-ASG/inventory/ocp3.10.ini ~/openshift-ansible/playbooks/prerequisites.yml 
    $ ansible-playbook -v -i ~/amcdermo-ASG/inventory/ocp3.10.ini ~/openshift-ansible/playbooks/deploy_cluster.yml

### Tear down cluster and mark nodes with <INSTANCE-NAME>-terminate

    $ ~/aws-cluster-up/bin/acu-destroy -a ~/amcdermo-ASG  
