#!/bin/bash

# Update and install required packages
sudo yum update -y

# Install Java 17
sudo yum install -y java-17-amazon-corretto-devel

# Install Git
sudo yum install git -y

# Install Maven
sudo yum install maven -y

# Install yt-dlp
sudo yum install python3-pip -y
pip3 install yt-dlp

# Install Nginx
sudo yum install nginx -y

# Remove existing project directory if it exists
if [ -d "Video_Downloader" ]; then
    echo "Directory 'Video_Downloader' already exists. Removing it..."
    rm -rf Video_Downloader
fi

# Clone the repository
git clone -b main https://github.com/PurandharAdigarla/Video_Downloader.git

# Navigate to the project directory
cd Video_Downloader || { echo "Directory 'Video_Downloader' does not exist"; exit 1; }

# Build the project using Maven
mvn clean package

# Copy the JAR file to a convenient location
mkdir -p /home/ec2-user/app
cp target/YouTube-downloader-0.0.1-SNAPSHOT.jar /home/ec2-user/app/YouTube-downloader.jar

# Prompt user for server name or IP address
read -p "Enter the server name or IP address to include in nginx.conf: " server_name

# Configure Nginx
sudo bash -c "cat > /etc/nginx/nginx.conf <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;
    server_names_hash_bucket_size 128;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen 80;
        listen [::]:80;

        server_name $server_name;

        location / {
            proxy_pass http://127.0.0.1:8080;  # Ensure the correct port number is set here
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        access_log /var/log/nginx/your-app-access.log;
        error_log /var/log/nginx/your-app-error.log;
    }
}
EOF"

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Run the application in the background
cd /home/ec2-user/app || { echo "Directory '/home/ec2-user/app' does not exist"; exit 1; }
nohup java -jar YouTube-downloader.jar > /home/ec2-user/app/app.log 2>&1 &

echo "Setup complete. Your application is running and Nginx is configured."