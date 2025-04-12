#!/bin/bash
# Enable logging for troubleshooting
exec > /tmp/update_env.log 2>&1
set -e

# Updating and installing the required packages
echo "installing unzip and curl"
apt-get update -y && apt-get install -y jq unzip curl

# Installing AWS CLI
echo "Installing AWS CLI......"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# Database and AWS variables
DB_HOST=${DB_HOST}
DB_USERNAME=${DB_USERNAME}
DB_NAME=${DB_NAME}
PORT=${PORT}
AWS_S3_BUCKET_NAME=${AWS_S3_BUCKET_NAME}
AWS_REGION=${AWS_REGION}
ENVIRONMENT=${ENVIRONMENT}
SECRET_MANAGER=${SECRET_MANAGER}

# Fetching DB_PASSWORD from Secret Manager
echo "Fetching DB_PASSWORD from Secret Manager"
DB_SECRET_PAYLOAD=$(aws secretsmanager get-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$SECRET_MANAGER" \
  --query SecretString \
  --output text 2>/tmp/aws_error.log) || {
    echo "[ERROR] Failed to fetch secret"
    cat /tmp/aws_error.log
    exit 1
}

DB_PASSWORD=$(echo "$DB_SECRET_PAYLOAD" | jq -r .password)

# Log variables for debugging
echo "DB_HOST=${DB_HOST}"
echo "DB_USERNAME=${DB_USERNAME}"
echo "DB_NAME=${DB_NAME}"
echo "PORT=${PORT}"
echo "AWS_S3_BUCKET_NAME=${AWS_S3_BUCKET_NAME}"
echo "AWS_REGION=${AWS_REGION}"
echo "ENVIRONMENT=${ENVIRONMENT}"

# Create directory if it doesn't exist
mkdir -p /opt/csye6225/webapp/

# Update .env file in /opt/csye6225/webapp/
sudo -u rohith bash -c "sed -i '/^DB_HOST=/d' /opt/csye6225/webapp/.env && echo \"DB_HOST=${DB_HOST}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^DB_USERNAME=/d' /opt/csye6225/webapp/.env && echo \"DB_USERNAME=${DB_USERNAME}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^DB_PASSWORD=/d' /opt/csye6225/webapp/.env && echo \"DB_PASSWORD=$${DB_PASSWORD}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^DB_NAME=/d' /opt/csye6225/webapp/.env && echo \"DB_NAME=${DB_NAME}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^DB_PORT=/d' /opt/csye6225/webapp/.env && echo \"DB_PORT=5432\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^PORT=/d' /opt/csye6225/webapp/.env && echo \"PORT=${PORT}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^AWS_REGION=/d' /opt/csye6225/webapp/.env && echo \"AWS_REGION=${AWS_REGION}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^AWS_S3_BUCKET_NAME=/d' /opt/csye6225/webapp/.env && echo \"AWS_S3_BUCKET_NAME=${AWS_S3_BUCKET_NAME}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^ENVIRONMENT=/d' /opt/csye6225/webapp/.env && echo \"ENVIRONMENT=${ENVIRONMENT}\" >> /opt/csye6225/webapp/.env"

# Set proper permissions
sudo chown rohith:csye6225_cloud /opt/csye6225/webapp/.env
sudo chmod 600 /opt/csye6225/webapp/.env
# Restart web application

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "namespace": "webapp-${ENVIRONMENT}",
    "metrics_collected": {
      "statsd": {
        "service_address": ":8125",
        "metrics_collection_interval": 1,
        "metrics_aggregation_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/aws/ec2/webappGroup",
            "log_stream_name": "webapp/syslog",
            "retention_in_days": 1
          }
        ]
      }
    }
  }
}
EOF

sudo chown cwagent:cwagent /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo chmod 644 /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

sudo chmod 644 /var/log/syslog

sudo systemctl daemon-reload
sudo systemctl restart healthz.service
sudo systemctl restart amazon-cloudwatch-agent