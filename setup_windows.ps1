# setup_windows.ps1

# Function to install Chocolatey (if not already installed)
function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Output "Chocolatey not found. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri https://chocolatey.org/install.ps1 -UseBasicP
        roxy -OutFile install.ps1
        & .\install.ps1
    } else {
        Write-Output "Chocolatey is already installed."
    }
}

# Function to install packages using Chocolatey
function Install-Packages {
    Write-Output "Installing dependencies..."

    choco install -y nginx yt-dlp jdk17 maven git
}

# Function to configure nginx
function Configure-Nginx {
    Write-Output "Configuring nginx..."

    $nginxConfPath = "C:\ProgramData\chocolatey\lib\nginx\tools\nginx.conf"

    # Backup existing nginx.conf
    Copy-Item -Path $nginxConfPath -Destination "$nginxConfPath.bak"

    @"
user nginx;
worker_processes auto;
error_log C:/ProgramData/chocolatey/lib/nginx/tools/logs/error.log;
pid C:/ProgramData/chocolatey/lib/nginx/tools/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  C:/ProgramData/chocolatey/lib/nginx/tools/logs/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;
    server_names_hash_bucket_size 128;

    include             C:/ProgramData/chocolatey/lib/nginx/tools/conf/mime.types;
    default_type        application/octet-stream;

    include C:/ProgramData/chocolatey/lib/nginx/tools/conf.d/*.conf;

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

        access_log C:/ProgramData/chocolatey/lib/nginx/tools/logs/your-app-access.log;
        error_log C:/ProgramData/chocolatey/lib/nginx/tools/logs/your-app-error.log;
    }
}
"@ | Set-Content -Path $nginxConfPath

    Write-Output "Starting nginx..."
    Start-Service nginx
}

# Function to clone the project repository
function Clone-Repository {
    Write-Output "Cloning the project repository..."
    Set-Location -Path "C:\inetpub\wwwroot"
    git clone https://github.com/PurandharAdigarla/Video_Downloader.git
}

# Main script execution
Install-Chocolatey
Install-Packages
Configure-Nginx
Clone-Repository

Write-Output "Windows setup complete!"