#!/bin/bash
# Enable logging for troubleshooting
exec > /tmp/update_env.log 2>&1
set -e
# Create directory if it doesn't exist
mkdir -p /opt/csye6225/webapp/
# Database variables
DB_HOST=${DB_HOST}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
PORT=${PORT}
AWS_S3_BUCKET_NAME=${AWS_S3_BUCKET_NAME}
# AWS Credentials
AWS_REGION=${AWS_REGION}
AWS_ACCESS_KEY=${AWS_ACCESS_KEY}
AWS_SA_KEY=${AWS_SA_KEY}
# Log variables for debugging
echo "DB_HOST=${DB_HOST}"
echo "DB_USERNAME=${DB_USERNAME}"
echo "DB_PASSWORD=${DB_PASSWORD}"
echo "DB_NAME=${DB_NAME}"
echo "PORT=${PORT}"
echo "AWS_S3_BUCKET_NAME=${AWS_S3_BUCKET_NAME}"
echo "AWS_REGION=${AWS_REGION}"
echo "AWS_ACCESS_KEY=${AWS_ACCESS_KEY}"
echo "AWS_SA_KEY=${AWS_SA_KEY}"
# Update .env file in /opt/csye6225/webapp/
sudo -u rohith bash -c "sed -i '/^DB_HOST=/d' /opt/csye6225/webapp/.env && echo \"DB_HOST=${DB_HOST}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^DB_USERNAME=/d' /opt/csye6225/webapp/.env && echo \"DB_USERNAME=${DB_USERNAME}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^DB_PASSWORD=/d' /opt/csye6225/webapp/.env && echo \"DB_PASSWORD=${DB_PASSWORD}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^DB_NAME=/d' /opt/csye6225/webapp/.env && echo \"DB_NAME=${DB_NAME}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^DB_PORT=/d' /opt/csye6225/webapp/.env && echo \"DB_PORT=5432\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^PORT=/d' /opt/csye6225/webapp/.env && echo \"PORT=${PORT}\" >> /opt/csye6225/webapp/.env"
# Add AWS credentials to .env
sudo -u rohith bash -c "sed -i '/^AWS_REGION=/d' /opt/csye6225/webapp/.env && echo \"AWS_REGION=${AWS_REGION}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^AWS_ACCESS_KEY=/d' /opt/csye6225/webapp/.env && echo \"AWS_ACCESS_KEY=${AWS_ACCESS_KEY}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^AWS_SA_KEY=/d' /opt/csye6225/webapp/.env && echo \"AWS_SA_KEY=${AWS_SA_KEY}\" >> /opt/csye6225/webapp/.env"
sudo -u rohith bash -c "sed -i '/^AWS_S3_BUCKET_NAME=/d' /opt/csye6225/webapp/.env && echo \"AWS_S3_BUCKET_NAME=${AWS_S3_BUCKET_NAME}\" >> /opt/csye6225/webapp/.env"
# Set proper permissions
sudo chown rohith:csye6225_cloud /opt/csye6225/webapp/.env
sudo chmod 600 /opt/csye6225/webapp/.env
# Restart web application
sudo systemctl daemon-reload
sudo systemctl restart healthz.service