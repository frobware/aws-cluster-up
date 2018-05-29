$ACU_TOPDIR/../libexec/aws-cluster-up/self-check

export ACU_SHARE_DIR=$ACU_TOPDIR/../share

acu_die() {
    echo "error:" "$@"
    exit 1
}

acu_get_resource_attribute() {
    echo $(jq -r -c ".modules[].resources[\"aws_instance.$1\"].primary.attributes[\"$2\"]" $3)
}

acu_get_resource_attribute() {
    # $1: resource name
    # $2: attribute name
    # $3: terraform state file
    echo $(jq -r -c ".modules[].resources[\"$1\"].primary.attributes[\"$2\"]" $3)
}

acu_get_public_ip() {
    acu_get_resource_attribute "$1" "public_ip" $2
}

# Convenience functions

acu_get_private_ip() {
    acu_get_resource_attribute "$1" "private_ip" $2
}

acu_get_public_dns() {
    acu_get_resource_attribute "$1" "public_dns" $2
}

acu_get_instance_id() {
    acu_get_resource_attribute "$1" "id" $2
}

acu_get_instances() {
    echo $(jq -r -c ".modules[].resources | keys[]" $1)
}

acu_terraform_state_file() {
    echo $ACU_CLUSTER_DIR/terraform/terraform.tfstate
}

acu_aws_instance_nodename() {
    echo "${1/aws_instance\./}"
}
