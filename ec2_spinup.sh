#!/usr/bin/env bash

# AWS options:  https://docs.docker.com/machine/drivers/aws/

# CLI option                                Environment variable	Default
#
# --amazonec2-access-key                    AWS_ACCESS_KEY_ID	        -
# --amazonec2-ami                           AWS_AMI	                ami-c60b90d1
# --amazonec2-block-duration-minutes	    -	                        -
# --amazonec2-device-name	            AWS_DEVICE_NAME	        /dev/sda1
# --amazonec2-endpoint	                    AWS_ENDPOINT	        -
# --amazonec2-iam-instance-profile	    AWS_INSTANCE_PROFILE	-
# --amazonec2-insecure-transport	    AWS_INSECURE_TRANSPORT	-
# --amazonec2-instance-type	            AWS_INSTANCE_TYPE	        t2.micro
# --amazonec2-keypair-name	            AWS_KEYPAIR_NAME	        -
# --amazonec2-monitoring	            -	                        false
# --amazonec2-open-port	                    -	                        -
# --amazonec2-private-address-only	    -	                        false
# --amazonec2-region	                    AWS_DEFAULT_REGION	        us-east-1
# --amazonec2-request-spot-instance	    -	                        false
# --amazonec2-retries	                    -	                        5
# --amazonec2-root-size	                    AWS_ROOT_SIZE	        16
# --amazonec2-secret-key	            AWS_SECRET_ACCESS_KEY       -
# --amazonec2-security-group	            AWS_SECURITY_GROUP	        docker-machine
# --amazonec2-security-group-readonly	    AWS_SECURITY_GROUP_READONLY	false
# --amazonec2-session-token	            AWS_SESSION_TOKEN	        -
# --amazonec2-spot-price	            -	                        0.50
# --amazonec2-ssh-keypath	            AWS_SSH_KEYPATH	        -
# --amazonec2-ssh-user	                    AWS_SSH_USER	        ubuntu
# --amazonec2-subnet-id	                    AWS_SUBNET_ID	        -
# --amazonec2-tags	                    AWS_TAGS	                -
# --amazonec2-use-ebs-optimized-instance    -	                        false
# --amazonec2-use-private-address	    -	                        false
# --amazonec2-userdata                      AWS_USERDATA	        -
# --amazonec2-volume-type   	            AWS_VOLUME_TYPE	        gp2
# --amazonec2-vpc-id	                    AWS_VPC_ID	                -
# --amazonec2-zone	                    AWS_ZONE	                a

SCRIPT_PATH=$(dirname "$0")
SCRIPT_PATH=$(readlink -f "$SCRIPT_PATH")

if ! command -v jq > /dev/null; then
  # Install jq (JSON Query)
  curl -o jq-linux64 -sSL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
  mv jq-linux64 /usr/local/bin/jq
  chmod a+x /usr/local/bin/jq
  jq --version
fi

if ! command -v aws > /dev/null; then
  # Install awscli v2
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  sudo ./aws/install --update
  /usr/local/bin/aws --version
fi


export OWNER="dazza-codes"

export AWS_TAGS="Owner,${OWNER}"

export AWS_ROOT_SIZE=60
export AWS_INSTANCE_TYPE=${AWS_INSTANCE_TYPE:-'t3.small'}


# The key pairs are not working with an existing key pair
# export KEY_PATH="${HOME}/.aws"
# export AWS_KEYPAIR_NAME="${OWNER}-${AWS_DEFAULT_REGION}"
# export AWS_SSH_KEYPATH="${KEY_PATH}/${AWS_KEYPAIR_NAME}"


#
# https://cloud-images.ubuntu.com/locator/ec2/
#
if [ "$AWS_DEFAULT_REGION" == "us-east-1" ]; then
    # ubuntu-focal-20.04-amd64-server-20210511
    export AWS_AMI='ami-02069978db500a511'
fi
if [ "$AWS_DEFAULT_REGION" == "us-west-2" ]; then
    # ubuntu-focal-20.04-amd64-server-20210511
    export AWS_AMI='ami-09c3a3d3af3a0bd2e'
fi

export AWS_USERDATA="${SCRIPT_PATH}/ec2_cloud_init.sh"

# Try to count the number of similar named EC2 instances
instance_count=$(aws ec2 describe-instances \
  | jq ".Reservations[].Instances[].KeyName | select(. != null) | select(. | contains(\"${OWNER}\"))" \
  | wc -l)

instance_n=$(printf "%03d" $((instance_count + 1)))

export MACHINE_NAME="${OWNER}-${AWS_DEFAULT_REGION}-ec2-${instance_n}"

docker-machine create --driver amazonec2 "$MACHINE_NAME"

