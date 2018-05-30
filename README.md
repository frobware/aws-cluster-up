# aws-cluster-up

Define and deploy AWS infrastructure; generate OpenShift ansible inventories.

# Install

	git clone https://github.com/frobware/aws-cluster-up.git
	cd aws-cluster-up
	./bootstrap.sh
	./configure
	sudo make install

## Dependencies

Three external tools are required:

1. `sudo dnf install -y jq`
2. `sudo dnf install -y awscli`
3. [terraform](https://www.terraform.io/intro/getting-started/install.html#installing-terraform)

# Usage

The general usage pattern is:

1. Setup the environment
2. Generate and provision a cluster using `acu-launch(1)`.
3. Generate an OpenShift Ansible inventory file using `acu-generate-inventory(1)`.
4. Generate an ssh configuration file using `acu-generate-ssh-config(1)`.
5. Run the ansible playbooks against the deployed cluster
6. Teardown the cluster using `acu-destroy(1)`.

## 1. Setup the Environment

	source /usr/local/share/aws-cluster-up/examples/aws/us-east-1.bash

If you don't already have AWS or OREG credentials create them as:

	cat <<EOF > ~/.oreg-credentials
	export OREG_AUTH_USER=abc
	export OREG_AUTH_PASSWORD=def
	EOF

	cat <<EOF > ~/.aws-credentials
	export AWS_ACCESS_KEY=abc
	export AWS_SECRET_KEY=def
	EOF

	source ~/.aws-credentials
	source ~/.oreg-credentials

I have these files GPG encrypted so my usage is as follows:

	source <(less ~/.aws-credentials.gpg)
	source <(less ~/.oreg-credentials.gpg)

## 2. Generate and provision a cluster using `acu-launch(1)`.

	acu-launch ~/amcdermo-triage /usr/local/share/aws-cluster-up/examples/aws/ocp-3.10/single-master.tf

The `basename` of the output directory `~/amcdermo-triage` becomes the
name of the cluster when viewed in the EC2 dashboard. In this example
you would have nodes named `acmdermo-triage-master`,
`acmdermo-triage-infra` and `acmdermo-triage-node`.

## 3. Generate an OpenShift Ansible inventory file using `acu-generate-inventory(1)`.

	acu-generate-inventory ~/amcdermo-triage /usr/local/share/aws-cluster-up/examples/aws/ocp-3.10/single-master.inventory > ~/amcdermo-triage/ocp.ini

## 4. Generate an ssh configuration file using `acu-generate-ssh-config(1)`.

	mkdir -p $HOME/.ssh/aws-cluster-up/conf.d
	acu-generate-ssh-config ~/amcdermo-triage > ~/.ssh/conf.d/aws-cluster-up/amcdermo-triage.conf
	chmod 600 ~/.ssh/conf.d/aws-cluster-up/amcdermo-triage.conf

You will need the following `Include` directive at the beginning of
your `.ssh/config` for tab completion and for running the
anisble-playbook:

	Include conf.d/aws-cluster-up/*.conf

Verify that tab completion works for the instances in your cluster:

	ssh amcdermo-triage-<TAB><TAB>

The generated ssh config entries should allow you to login without
requiring a password (assuming you have the correct key).

## 5. Run the ansible playbooks against the deployed cluster

	git clone https://github.com/openshift/openshift-ansible.git
	cd ~/openshift-ansible
	git checkout openshift-ansible-3.10.0-0.53.0

	ansible-playbook -i ~/amcdermo-triage/ocp.ini ~/openshift-ansible/playbooks/prerequisites.yml
	ansible-playbook -i ~/amcdermo-triage/ocp.ini ~/openshift-ansible/playbooks/deploy_cluster.yml

## 6. Teardown the cluster using `acu-destroy(1)`.

	acu-destroy ~/amcdermo-triage

This will automatically retag the instances names with `-terminate` so
they get garbage collected.

# Creating custom cluster definitions and ansible inventories

The example terraform cluster definitions and inventory files are just
examples. You can copy these and modify them to support a different
set of configurations.

	#
	# Take copies
	#
	cp /usr/local/share/examples/aws/ocp-3.10/single-master.tf ~/autoscale-group-cluster.tf
	cp /usr/local/share/examples/aws/ocp-3.10/single-master.inventory ~/autoscale-group.inventory

	#
	# Make modificiations, then launch based on the new configuration
	#
	acu-launch ~/amcdermo-ASG ~/autoscale-group.tf

	#
	# Make modificiations, then generate the inventory definition
	#
	acu-generate-inventory ~/amcdermo-ASG ~/autoscale-group.inventory

	#
	# Run ansible playbooks
	#
	ansible-playbook -i ~/autoscale-group.inventory ~/openshift-ansible/playbooks/prerequisites.yml
	ansible-playbook -i ~/autoscale-group.inventory ~/openshift-ansible/playbooks/deploy_cluster.yml

The `acu-`scripts export pertinent information through environment
variables that all begin with `ACU_`.
