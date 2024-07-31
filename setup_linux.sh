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
##if [ -d "Video_Downloader" ]; then
##    echo "Directory 'Video_Downloader' already exists. Removing it..."
##    rm -rf Video_Downloader
##fi

# Clone the repository
##git clone -b main https://github.com/PurandharAdigarla/Video_Downloader.git

# Navigate to the project directory
##cd Video_Downloader || { echo "Directory 'Video_Downloader' does not exist"; exit 1; }

# Build the project using Maven
mvn clean package

# Check if port 8082 is in use and kill the process if found
PORT=8082
PROCESS=$(sudo lsof -t -i :$PORT)

if [ -n "$PROCESS" ]; then
    echo "Port $PORT is in use by process $PROCESS. Killing the process..."
    sudo kill -9 $PROCESS
    if [ $? -eq 0 ]; then
        echo "Process $PROCESS killed successfully."
    else
        echo "Failed to kill process $PROCESS."
    fi
else
    echo "Port $PORT is not in use."
fi


# Copy the JAR file to a convenient location
mkdir -p /home/ec2-user/app
cp target/YouTube-downloader-0.0.1-SNAPSHOT.jar /home/ec2-user/app/youtube-downloader.jar

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

# Capture and display the PID of the running Java process
JAVA_PID=$(pgrep -f 'java -jar youtube-downloader.jar')

if [ -n "$JAVA_PID" ]; then
    echo "Java application is running with PID: $JAVA_PID"
else
    echo "Java application failed to start."
fi

##cd /home/ec2-user/app
##java -jar youtube-downloader.jar 

echo "Setup complete. Your application is running and Nginx is configured."
