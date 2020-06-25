
#Capture current AWS credentials stored as environment variables
env | grep AWS_SESSION_TOKEN > /tmp/orig
env | grep AWS_ACCESS_KEY_ID >> /tmp/orig
env | grep AWS_SECRET_ACCESS_KEY >> /tmp/orig

echo -n orig creds are; cat /tmp/orig
#Set variable for AWS Account IDs. Currently set to DaaS Access Accounts for testing purposes
DatalakeDev="315785799772"
DatalakeUAT="435298438412"
DatalakeProd="896163927542"

aws sts assume-role \
    --role-arn arn:aws:iam::711451427668:role/AWSGlueCICD-CodePipelineServiceRole-REX9XUCQD8RZ \
    --role-session-name deploy \
    --query 'Credentials.{AWS_ACCESS_KEY_ID:AccessKeyId, AWS_SECRET_ACCESS_KEY:SecretAccessKey, AWS_SESSION_TOKEN:SessionToken}'  | grep AWS | tr -d ' ",' | tr : = | sed -e 's/^/export /' > /tmp/creds

echo -n creds are; cat /tmp/creds

source /tmp/creds

#Deploy Dev Datalake Account Common Cloudformation Resources Account
set -ex

chmod +x ./deploy_glue.sh
./deploy_glue.sh

ERROR_CODE=$?

echo "Before read"
STDERR=$(( aws cloudformation "$@" ) 2>&1)
echo ${STDERR} 1>&2
echo $ERROR_CODE
echo "After Read"
if [[ "${ERROR_CODE}" eq "255" ]]; then exit 0; fi

set +ex

#source /tmp/orig
#sh ./deploy_glue.sh
