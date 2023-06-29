#!/bin/bash
# This script will change the codeUri in a given template, so that the template will be validate
# for cloudformation.

template_file=$1
puckage_name=$2
README_file=$3
bucket_string="!Sub coralogix-serverless-repo-\${AWS::Region}"

if grep -q "LambdaFunction" "$template_file"; then
    yq eval '.Resources.LambdaFunction.Properties.CodeUri = {"Bucket": "'"$bucket_string"'", "S3Key": "'"$puckage_name"'.zip"}' -i $template_file
    sed -i '' "s/'!Sub coralogix-serverless-repo-\${AWS::Region}/!Sub 'coralogix-serverless-repo-\${AWS::Region}/g" $template_file
fi
if grep -q "LambdaFunctionSSM" "$template_file"; then
    yq eval '.Resources.LambdaFunctionSSM.Properties.CodeUri = {"Bucket": "'"$bucket_string"'", "S3Key": "'"$puckage_name"'.zip"}' -i $template_file
    sed -i '' "s/'!Sub coralogix-serverless-repo-\${AWS::Region}/!Sub 'coralogix-serverless-repo-\${AWS::Region}/g" $template_file
fi
if grep -q "CustomResourceLambdaTriggerFunction" "$template_file"; then
    yq eval '.Resources.CustomResourceLambdaTriggerFunction.Properties.CodeUri = {"Bucket": "'"$bucket_string"'", "S3Key": "helper.zip"}' -i $template_file
    sed -i '' "s/'!Sub coralogix-serverless-repo-\${AWS::Region}/!Sub 'coralogix-serverless-repo-\${AWS::Region}/g" $template_file
fi

sed -i '' '1s/^/#created automatically from coralogix\/coralogix-aws-serverless\n/' $template_file

# sed -i '' '/^## AWS Resource Manager Template Deployment$/,/^## Fields/c\
# ## Fields 
# ' $README_file

sed -i '' '3s/^/This template were created automatically from coralogix\/coralogix-aws-serverless.\nTo make a change in the template go to the serverless repo and change he file from there.\n\n/' $README_file
