
#Capture current AWS credentials stored as environment variables
env | grep AWS_SESSION_TOKEN > /tmp/orig
env | grep AWS_ACCESS_KEY_ID >> /tmp/orig
env | grep AWS_SECRET_ACCESS_KEY >> /tmp/orig

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

../team-pipelines/deploy.sh -n $stack_prefix -s "whlau-daas-dev-$DatalakeDev-cfn" -e $Environment -t $TeamName -p $PipLibrary -d $DlakeLibrary

./deploy.sh -n "$stack_prefix-$PipelineName" -s "whlau-daas-dev-$DatalakeDev-cfn" -e $Environment -b $PreStage  -f $PostStage -x $SnapshotStage -a $StageARepo -c $StageBRepo -y $StageCRepo -t $TeamName -u $PipelineName

set +ex

source /tmp/orig


#sh ./deploy_glue.sh


  
