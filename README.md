# aws-cluster-up

Define and deploy AWS infrastructure; generate OpenShift ansible inventories.

# Install

	git clone https://github.com/frobware/aws-cluster-up.git
	./bootstrap.sh
	./configure
	sudo make install

## Dependencies

	# Install jq(1), aws-cli(1), terraform(1).

# Usage

### Required Environment variables

	source /usr/local/share/aws-cluster-up/examples/aws/us-east-1.env

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

### Define and provision a simple cluster that has one master, one infra and one node

	acu-launch ~/amcdermo-triage /usr/local/share/aws-cluster-up/examples/aws/ocp-3.10/single-master.tf

The basename of the output directory `~/amcdermo-triage` becomes the
name of the cluster.

### Generate inventory based on deployed cluster

	acu-generate-inventory ~/amcdermo-triage /usr/local/share/aws-cluster-up/examples/aws/ocp-3.10/single-master.inventory > ~/amcdermo-triage/ocp.ini

### Generate ssh/config based on deployed cluster

	mkdir -p $HOME/.ssh/aws-cluster-up/conf.d
	acu-generate-ssh-config ~/amcdermo-triage > ~/.ssh/conf.d/aws-cluster-up/amcdermo-triage.conf
	chmod 600 ~/.ssh/conf.d/aws-cluster-up/amcdermo-triage.conf

You will need the following `Include` directive at the beginning of
your `.ssh/config` for tab completion and for running the
anisble-playbook:

	Include conf.d/aws-cluster-up/*.conf

### Deploy OpenShift using openshift ansible

	git clone https://github.com/openshift/openshift-ansible.git
	cd ~/openshift-ansible
	git checkout openshift-ansible-3.10.0-0.53.0

	ansible-playbook -i ~/amcdermo-triage/ocp.ini ~/openshift-ansible/playbooks/prerequisites.yml
	ansible-playbook -i ~/amcdermo-triage/ocp.ini ~/openshift-ansible/playbooks/deploy_cluster.yml

### Tear down cluster and tag node names with -terminate

	acu-destroy ~/amcdermo-triage

# Extend the cluster definitions and the sample inventory files

The example terraform cluster definitions and inventory files are just
examples. You can copy these and modify them to support a different
set of configurations.

	cp /usr/local/share/share/examples/aws/ocp-3.10/single-master.tf my-cluster.tf
	# Make modificiations to my-cluster.tf
	acu-launch ~/amcdermo-demo /path/to/my-cluster.tf

	cp /usr/local/share/share/examples/aws/ocp-3.10/single-master.inventory
	# Make modificiations to my-cluster.inventory
	acu-generate-inventory ~/amcdermo-demo /path/to/my-cluster.inventory

The `acu-`scripts export pertinent information through environment
variables that all begin with `ACU_`.
