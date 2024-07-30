#!/bin/bash

# Update and install required packages
sudo yum update -y

# Install Java 11
sudo yum install java-11-openjdk-devel -y

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
if [ -d "YouTube-Downloader" ]; then
    echo "Directory 'YouTube-Downloader' already exists. Removing it..."
    rm -rf YouTube-Downloader
fi

# Clone the repository
git clone -b main https://github.com/PurandharAdigarla/Video_Downloader.git

# Navigate to the project directory
cd YouTube-Downloader/Video_Downloader || { echo "Directory 'Video_Downloader' does not exist"; exit 1; }

# Build the project using Maven
mvn clean package

# Copy the JAR file to a convenient location
mkdir -p /home/ec2-user/app
cp target/youtube-downloader-0.0.1-SNAPSHOT.jar /home/ec2-user/app/youtube-downloader.jar

# Configure Nginx
sudo bash -c 'cat > /etc/nginx/nginx.conf <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

# Load dynamic modules.
include /usr/share/nginx/modules/*.conf;
server {
    listen 80;
    listen [::]:80;
    server_name _;

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
    }

    location /api/ {
        proxy_pass http://localhost:8082/;  # Ensure the correct port number is set here
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    error_page 404 /404.html;
    location = /404.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
EOF'


# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Run the application in the background
cd /home/ec2-user/app || { echo "Directory '/home/ec2-user/app' does not exist"; exit 1; }
nohup java -jar youtube-downloader.jar > /home/ec2-user/app/app.log 2>&1 &

cd /home/ec2-user/app
java -jar youtube-downloader.jar 

echo "Setup complete. Your application is running and Nginx is configured."



