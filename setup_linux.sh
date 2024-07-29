#!/bin/bash

# Function to install packages
install_packages() {
    echo "Updating package list..."
    sudo apt-get update -y

    echo "Installing dependencies..."
    sudo apt-get install -y \
        nginx \
        yt-dlp \
        git \
        openjdk-17-jdk \
        maven \
        curl \
        software-properties-common

    echo "Installing additional tools..."
    sudo apt-get install -y \
        build-essential \
        unzip
}

# Function to configure nginx
configure_nginx() {
    echo "Configuring nginx..."

    # Backup existing nginx.conf
    sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

    # Create a new nginx.conf with placeholder
    sudo tee /etc/nginx/nginx.conf > /dev/null <<EOL
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

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

        server_name __SERVER_ADDRESS__;

        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        access_log /var/log/nginx/your-app-access.log;
        error_log /var/log/nginx/your-app-error.log;
    }
}
EOL

    # Prompt for server address
    read -p "Enter your server domain or IP address: " server_address

    # Replace placeholder with actual server address
    sudo sed -i "s/__SERVER_ADDRESS__/$server_address/g" /etc/nginx/nginx.conf

    echo "Starting nginx..."
    sudo systemctl start nginx
    sudo systemctl enable nginx
}

# Function to install Java (OpenJDK 17)
install_java() {
    echo "Installing Java (OpenJDK 17)..."
    sudo apt-get install -y openjdk-17-jdk
}

# Function to install Maven
install_maven() {
    echo "Installing Maven..."
    sudo apt-get install -y maven
}

# Function to clone the project repository
clone_repository() {
    echo "Cloning the project repository..."
    cd /var/www || exit
    sudo git clone https://github.com/PurandharAdigarla/Video_Downloader.git
}

# Function to set up project files
setup_project_files() {
    echo "Setting up project files..."

    # Navigate to project directory
    cd /var/www/Video_Downloader || exit

    # Install project dependencies if needed
    # Example: for a Maven project, you might need to build it
    # Uncomment if your project uses Maven
    # mvn clean install
}

# Main script execution
install_packages
configure_nginx
install_java
install_maven
clone_repository
setup_project_files

echo "Linux setup complete!"