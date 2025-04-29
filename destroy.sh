#!/bin/bash

set -e

echo "💥 Destroying infrastructure..."
cd terraform
terraform init \
  -backend-config="bucket=thena-task-bucket" \
  -backend-config="key=ephemeral-environments/${APP_NAME}/terraform.tfstate" \
  -backend-config="region=ap-south-1" \
  -backend-config="encrypt=true"
terraform destroy -auto-approve
echo "✅ Infrastructure destroyed."

# Read SNS Topic ARN from file
SNS_TOPIC_ARN=$(cat ../sns_topic_arn.txt)

# Send Destroy Notification
aws sns publish --topic-arn "$SNS_TOPIC_ARN" \
  --message "❌ Environment Destroyed Successfully." \
  --subject "❌ Ephemeral Environment Destroyed"

# Delete SNS Topic
echo "🗑️ Deleting SNS Topic: $SNS_TOPIC_ARN..."
aws sns delete-topic --topic-arn "$SNS_TOPIC_ARN"

# Cleanup temp file
rm -f ../sns_topic_arn.txt

echo "✅ Cleanup complete."