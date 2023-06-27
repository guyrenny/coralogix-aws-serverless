#!/bin/bash
apt-get install moreutils -y

file=$1

declare -i lambda_counter=0
declare -i CustomResourceLambdaTriggerFunction_counter=0
if grep -q "LambdaFunction" "$file"; then
    let lambda_counter++
fi
if grep -q "LambdaFunctionSSM" "$file"; then
    let lambda_counter++
fi
if grep -q "CustomResourceLambdaTriggerFunction" "$file"; then
    let CustomResourceLambdaTriggerFunction_counter++
fi
echo $lambda_counter
echo $CustomResourceLambdaTriggerFunction_counter

lambda_replacement="CodeUri: \n        Bucket: !Sub \'coralogix-serverless-repo-\${AWS::Region}\' \n        S3Key: \'cloudtrail.zip\'"
custom_resource_replacement="CodeUri: \n        Bucket: !Sub \'coralogix-serverless-repo-\${AWS::Region}\' \n        S3Key: \'helper.zip\'"

if [[ $CustomResourceLambdaTriggerFunction_counter -eq 0 ]]; then
    sed -i.bak "s/CodeUri: \./$lambda_replacement/g" "$file"

elif [[ $lambda_counter -eq 2 ]] && [[ $CustomResourceLambdaTriggerFunction_counter -eq 1 ]]; then
    tr '\n' '@' < "$file" | sed "s/CodeUri: \./$lambda_replacement/1" | tr '@' '\n' | sponge "$file"
    tr '\n' '@' < "$file" | sed "s/CodeUri: \./$lambda_replacement/1" | tr '@' '\n' | sponge "$file"
    tr '\n' '@' < "$file" | sed "s/CodeUri: \./$custom_resource_replacement/1" | tr '@' '\n' | sponge "$file"

elif [[ $lambda_counter -eq 1 ]] && [[ $CustomResourceLambdaTriggerFunction_counter -eq 1 ]]; then
    tr '\n' '@' < "$file" | sed "s/CodeUri: \./$lambda_replacement/1" | tr '@' '\n' | sponge "$file"
    tr '\n' '@' < "$file" | sed "s/CodeUri: \./$custom_resource_replacement/1" | tr '@' '\n' | sponge "$file"
fi
