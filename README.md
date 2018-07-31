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

- `sudo dnf install -y jq`
- `sudo dnf install -y awscli`
- [terraform](https://www.terraform.io/intro/getting-started/install.html#installing-terraform)

# Usage

The general usage pattern is:

1. Setup the environment
2. Generate and provision a cluster
3. Generate an OpenShift Ansible inventory
4. Generate ssh/config entries
5. Run the OpenShift ansible playbooks
6. Destroy the cluster

## 1. Setup the environment

```bash
source /usr/local/share/aws-cluster-up/examples/aws/us-east-1.bash
```

This defines defaults for the subnet to use, the instance type to
provision, the region the instances should run in, et al.

We'll also need AWS credentials and OpenShift registry credentials set
in the environment. If you don't already have AWS or OREG credentials
defined you can create and store them as follows:

```bash
cat <<EOF > ~/.oreg-credentials
export OREG_AUTH_USER=abc
export OREG_AUTH_PASSWORD=def
EOF

cat <<EOF > ~/.aws-credentials
export AWS_ACCESS_KEY_ID=abc
export AWS_SECRET_ACCESS_KEY=def
EOF
```

Now source these into the current environment:

```bash
source ~/.aws-credentials
source ~/.oreg-credentials
```

I have these files GPG encrypted so my usage is as follows:

```bash
source <(less ~/.aws-credentials.gpg)
source <(less ~/.oreg-credentials.gpg)
```

All these environment variables are substituted into the terraform
definition and the OpenShift ansible inventory file.

## 2. Generate and provision a cluster

```bash
acu-launch ~/amcdermo-triage /usr/local/share/aws-cluster-up/examples/aws/ocp-3.10/single-master.tf
```

The `basename` of the output directory `~/amcdermo-triage` becomes the
name of the cluster when viewed in the EC2 dashboard. In this example
you would have nodes named `acmdermo-triage-master`,
`acmdermo-triage-infra` and `acmdermo-triage-node`.

## 3. Generate an OpenShift Ansible inventory

```bash
acu-generate-inventory ~/amcdermo-triage /usr/local/share/aws-cluster-up/examples/aws/ocp-3.10/single-master.inventory > ~/amcdermo-triage/ocp.ini
```

## 4. Generate ssh/config entries

```bash
mkdir -p $HOME/.ssh/aws-cluster-up/conf.d
acu-generate-ssh-config ~/amcdermo-triage > ~/.ssh/conf.d/aws-cluster-up/amcdermo-triage.conf
chmod 600 ~/.ssh/conf.d/aws-cluster-up/amcdermo-triage.conf
```

You will need the following `Include` directive at the beginning of
your `.ssh/config` for tab completion and for running the
anisble-playbook:

	Include conf.d/aws-cluster-up/*.conf

Verify that tab completion works for the instances in your cluster:

```bash
ssh amcdermo-triage-<TAB><TAB>
```

The generated ssh config entries should allow you to login without
requiring a password (assuming you have the correct key).

## 5. Run the OpenShift ansible playbooks

```bash
git clone https://github.com/openshift/openshift-ansible.git
cd ~/openshift-ansible
git checkout openshift-ansible-3.10.0-0.53.0

ansible-playbook -i ~/amcdermo-triage/ocp.ini ~/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i ~/amcdermo-triage/ocp.ini ~/openshift-ansible/playbooks/deploy_cluster.yml
```

## 6. Destroy the cluster

```bash
acu-destroy ~/amcdermo-triage
```

This will automatically retag the instance names with `-terminate` so
they get garbage collected.

# Creating custom definitions and inventories

The example terraform cluster definitions and inventory files are just
examples. You can copy these and modify them to support a different
set of configurations.

```bash
#
# Take copies
#
cp /usr/local/share/examples/aws/ocp-3.10/single-master.tf ~/autoscale-group.tf
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
```

The `acu-`scripts export pertinent information through environment
variables that all begin with `ACU_`.
