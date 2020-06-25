#!/bin/bash
DIRNAME=$(dirname "$0")
mkdir $DIRNAME/output
$S3_BUCKET="aws-zhidli"
aws cloudformation package --template-file $DIRNAME/template-glue.yaml --s3-bucket $S3_BUCKET --s3-prefix CFT-Folder/ --output-template-file $DIRNAME/output/packaged-template.yaml
