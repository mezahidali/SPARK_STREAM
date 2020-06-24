aws sts assume-role \
    --role-arn arn:aws:iam::711451427668:role/AWSGlueCICD-CodePipelineServiceRole-REX9XUCQD8RZ \
    --role-session-name deploy \
    --query 'Credentials.{AWS_ACCESS_KEY_ID:AccessKeyId, AWS_SECRET_ACCESS_KEY:SecretAccessKey, AWS_SESSION_TOKEN:SessionToken}'  | grep AWS | tr -d ' ",' | tr : = | sed -e 's/^/export /' > /tmp/creds

echo -n creds are; cat /tmp/creds


#sh ./deploy_glue.sh
