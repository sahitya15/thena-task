#!/bin/bash

set -e

REPO_URL=$1
BRANCH_NAME=$2
NOTIFY_EMAIL=$3

if [ -z "$REPO_URL" ] || [ -z "$BRANCH_NAME" ] || [ -z "$NOTIFY_EMAIL" ]; then
  echo "Usage: ./deploy.sh <repo-url> <branch-name> <notification-email>"
  exit 1
fi

REPO_NAME=$(basename -s .git $REPO_URL)
APP_ID="${REPO_NAME}-${BRANCH_NAME}"
SNS_TOPIC_NAME="ephemeral-env-${APP_ID}"

# Clone Repo
echo "🚀 Cloning $REPO_URL (branch: $BRANCH_NAME)..."
git clone --branch "$BRANCH_NAME" "$REPO_URL" "/tmp/${APP_ID}"

# Create SNS Topic
echo "📢 Creating dedicated SNS Topic: $SNS_TOPIC_NAME"
SNS_TOPIC_ARN=$(aws sns create-topic --name "$SNS_TOPIC_NAME" --query 'TopicArn' --output text)

# Save Topic ARN in a temp file for destroy.sh
echo "$SNS_TOPIC_ARN" > sns_topic_arn.txt

# Subscribe email
echo "📧 Subscribing $NOTIFY_EMAIL to $SNS_TOPIC_NAME..."
aws sns subscribe --topic-arn "$SNS_TOPIC_ARN" --protocol email --notification-endpoint "$NOTIFY_EMAIL"

# (User must confirm email once)

# Prepare User Data
cat <<EOF > userdata.sh
#!/bin/bash
yum update -y
yum install -y python3 python3-pip git
python3 -m pip install --upgrade pip
cd /home/ec2-user
git clone $REPO_URL
cd $REPO_NAME
git checkout $BRANCH_NAME
pip3 install -r requirements.txt
python3 run.py &
EOF

# Terraform Variables
export TF_VAR_app_name="$APP_ID"
export TF_VAR_user_data="$(cat userdata.sh)"

# Terraform Apply
echo "⏳ Running Terraform to deploy infrastructure..."
cd terraform
terraform init \
  -backend-config="bucket=thena-task-bucket" \
  -backend-config="key=ephemeral-environments${APP_NAME}/terraform.tfstate" \
  -backend-config="region=ap-south-1" \
  -backend-config="encrypt=true"
terraform apply -auto-approve

APP_URL=$(terraform output -raw app_url)
echo "🌐 Application deployed at: $APP_URL"

# Send Deployment Email
aws sns publish --topic-arn "$SNS_TOPIC_ARN" \
  --message "✅ Deployment Successful!\nApplication: ${APP_ID}\nURL: ${APP_URL}" \
  --subject "✅ Ephemeral Deployment Success"