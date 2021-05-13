#!/usr/bin/env bash

echo "Enable this manually"
exit

export OWNER="dazza-codes"
export KEY_PATH="${HOME}/.aws"

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}
export AWS_KEYPAIR_NAME="${OWNER}-${AWS_DEFAULT_REGION}"
export AWS_SSH_KEYPATH="${KEY_PATH}"/"${AWS_KEYPAIR_NAME}"

aws ec2 create-key-pair \
    --key-name "${AWS_KEYPAIR_NAME}" \
    --query "KeyMaterial" \
    --output text > "${KEY_PATH}"/"${AWS_KEYPAIR_NAME}.pem"

chmod 400 "${KEY_PATH}"/"${AWS_KEYPAIR_NAME}.pem"

ssh-keygen -y -f "${KEY_PATH}"/"${AWS_KEYPAIR_NAME}.pem" > "${KEY_PATH}"/"${AWS_KEYPAIR_NAME}.pub"

chmod 400 "${KEY_PATH}"/"${AWS_KEYPAIR_NAME}.pub"
