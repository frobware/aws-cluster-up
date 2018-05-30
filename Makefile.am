EXTRA_DIST =					\
	README.md				\
	bootstrap.sh				\
	libexec

# Should really use $(program-prefix) for all the aws- entries but
# that means the the pkglibexec_SCRIPTS also get changed.

dist_bin_SCRIPTS =				\
	bin/acu-destroy				\
	bin/acu-generate-inventory		\
	bin/acu-generate-ssh-config		\
	bin/acu-launch

nobase_dist_pkgdata_DATA =				\
	examples/aws/ocp-3.10/multi-master.inventory	\
	examples/aws/ocp-3.10/multi-master.tf		\
	examples/aws/ocp-3.10/single-master-asg.tf	\
	examples/aws/ocp-3.10/single-master.inventory	\
	examples/aws/ocp-3.10/single-master.tf		\
	examples/aws/us-east-1.bash

pkglibexec_SCRIPTS =				\
	libexec/aws-cluster-up/common.bash	\
	libexec/aws-cluster-up/self-check
