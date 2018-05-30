#!/bin/bash

# Infrastructure that will be Auto Scale Group aware.

set -u

cat <<EOF
provider "aws" {
  region = "$ACU_REGION"
}

resource "aws_instance" "master" {
  ami = "$ACU_AMI_IMAGE_MASTER"
  associate_public_ip_address = true
  iam_instance_profile = "$ACU_IAM_INSTANCE_PROFILE_MASTER"
  instance_type = "$ACU_INSTANCE_TYPE"
  key_name = "$ACU_KEY_NAME"
  subnet_id = "$ACU_SUBNET_ID"
}

resource "aws_instance" "infra" {
  ami = "$ACU_AMI_IMAGE_INFRA"
  associate_public_ip_address = true
  iam_instance_profile = "aos-pod-cluster-autoscaler-minimal"
  instance_type = "$ACU_INSTANCE_TYPE"
  key_name = "$ACU_KEY_NAME"
  subnet_id = "$ACU_SUBNET_ID"
}

resource "aws_instance" "node" {
  ami = "ami-083d1a2a697915450"
  associate_public_ip_address = true
  iam_instance_profile = "$ACU_IAM_INSTANCE_PROFILE_NODE"
  instance_type = "$ACU_INSTANCE_TYPE"
  key_name = "$ACU_KEY_NAME"
  subnet_id = "$ACU_SUBNET_ID"
}
EOF
