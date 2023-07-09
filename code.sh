#!/bin/bash

# template_file=$1

yq eval '.Metadata."AWS::CloudFormation::Interface".ParameterGroups[0].Parameters += "IntegrationId"' -i template.yaml
yq eval --inplace '.Metadata."AWS::CloudFormation::Interface".ParameterLabels += {"IntegrationId": {"default": "Integration ID"}}' template.yaml
yq eval --inplace '.Parameters += {"IntegrationId": {"Type": "String",  "Description": "The integration ID to register."}}' template.yaml

cat s3-resource.txt  >> template.yaml