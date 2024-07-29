#!/bin/bash

# Function to check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null
    then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
}

# Function to install packages using Homebrew
install_packages() {
    echo "Updating Homebrew..."
    brew update

    echo "Installing dependencies..."
    brew install nginx yt-dlp git
}

# Function to configure nginx
configure_nginx() {
    echo "Configuring nginx..."

    # Backup existing nginx.conf
    sudo cp /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.bak

    cat <<EOL | sudo tee /usr/local/etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /usr/local/var/log/nginx/error.log;
pid /usr/local/var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /usr/local/var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;
    server_names_hash_bucket_size 128;

    include             /usr/local/etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /usr/local/etc/nginx/conf.d/*.conf;

    server {
        listen 80;

        server_name your-server-domain-or-ip;

        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        access_log /usr/local/var/log/nginx/your-app-access.log;
        error_log /usr/local/var/log/nginx/your-app-error.log;
    }
}
EOL

    echo "Starting nginx..."
    sudo brew services start nginx
}

# Function to clone the project repository
clone_repository() {
    echo "Cloning the project repository..."
    cd /usr/local/var/www || exit
    git clone https://github.com/PurandharAdigarla/Video_Downloader.git
}

# Function to install Java (OpenJDK 17)
install_java() {
    echo "Installing Java (OpenJDK 17)..."
    brew tap adoptopenjdk/openjdk
    brew install --cask adoptopenjdk17
}

# Function to install Maven
install_maven() {
    echo "Installing Maven..."
    brew install maven
}

# Main script execution
check_homebrew
install_packages
configure_nginx
clone_repository
install_java
install_maven

echo "macOS setup complete!"