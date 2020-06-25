#!/bin/bash
DIRNAME=$(dirname "$0")
mkdir $DIRNAME/output
S3_BUCKET="aws-zhidli"
aws cloudformation package --template-file $DIRNAME/template-glue.yaml --s3-bucket $S3_BUCKET --s3-prefix CFT-Folder/ --output-template-file $DIRNAME/output/packaged-template.yaml

STACK_NAME="glue-test"

echo "Checking if stack exists ..."
if ! aws cloudformation describe-stacks --stack-name $STACK_NAME; then
  echo -e "Stack does not exist, creating ..."
  aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file $DIRNAME/output/packaged-template.yaml \
    --tags "whlau:governance:project"="daas" "whlau:governance:company"="WHLAU" "whlau:governance:department"="IT Service"  \
    --capabilities "CAPABILITY_NAMED_IAM" "CAPABILITY_IAM" "CAPABILITY_AUTO_EXPAND" \

  echo "Waiting for stack to be created ..."
  aws cloudformation wait stack-create-complete \
    --stack-name $STACK_NAME
else
  echo -e "Stack exists, attempting update ..."

  set +e
  update_output=$(aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file $DIRNAME/output/packaged-template.yaml \
    --tags "whlau:governance:project"="daas" "whlau:governance:company"="WHLAU" "whlau:governance:department"="IT Service" \
    --capabilities "CAPABILITY_NAMED_IAM" "CAPABILITY_IAM" "CAPABILITY_AUTO_EXPAND" 2>&1)

  status=$?
  set -e

  echo "$update_output"

  if [ $status -ne 0 ] ; then
    # Don't fail for no-op update
    if [[ $update_output == *"ValidationError"* && $update_output == *"No updates"* ]] ; then
      echo -e "\nFinished create/update - no updates to be performed";
      exit 0;
    else
      exit $status;
    fi
  fi

  echo "Waiting for stack update to complete ..."
  wait_output=$(aws cloudformation wait stack-update-complete \
    --stack-name $STACK_NAME 2>&1)

  wait_status=$?
  set -e
  echo "$wait_status"

  if [ $wait_status -ne 0 ] ; then
    # Don't fail for no-op update
    if [[ $wait_output == *"No changes to deploy. Stack glue-test is up to date"* ]] ; then
      echo -e "\nFinished create/update - no changes to be performed";
      exit 0;
    fi
  fi

  if [[ $update_output == "No changes to deploy. Stack glue-test is up to date" ]] ; then
      echo -e "\nFinished create/update - no changes to be performed";
      exit 0;
  fi

  echo "Finished create/update successfully!"
fi
