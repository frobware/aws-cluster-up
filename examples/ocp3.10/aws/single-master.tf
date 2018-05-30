#!/bin/bash

set -u

cat <<EOF
provider "aws" {
  region = "$ACU_REGION"
}

resource "aws_instance" "master" {
  ami = "$ACU_AMI_IMAGE_MASTER"
  associate_public_ip_address = true
  instance_type = "$ACU_INSTANCE_TYPE"
  key_name = "$ACU_KEY_NAME"
  subnet_id = "$ACU_SUBNET_ID"
}

resource "aws_instance" "infra" {
  ami = "$ACU_AMI_IMAGE_INFRA"
  associate_public_ip_address = true
  instance_type = "$ACU_INSTANCE_TYPE"
  key_name = "$ACU_KEY_NAME"
  subnet_id = "$ACU_SUBNET_ID"
}

resource "aws_instance" "node" {
  ami = "$ACU_AMI_IMAGE_NODE"
  associate_public_ip_address = true
  instance_type = "$ACU_INSTANCE_TYPE"
  key_name = "$ACU_KEY_NAME"
  subnet_id = "$ACU_SUBNET_ID"
}
EOF
