# Video Downloader

## Overview

This repository contains the source code for a YouTube video downloader application built with Spring Boot. The application is configured to run on an EC2 instance with Nginx as a reverse proxy.

## Prerequisites

Before you begin, ensure you have the following:

- A GitHub account
- An AWS account
- Basic knowledge of Linux commands

## Setting Up an EC2 Instance

1. **Create an EC2 Instance:**

    - Log in to the [AWS Management Console](https://aws.amazon.com/console/).
    - Navigate to the EC2 Dashboard.
    - Click on "Launch Instance".
    - Choose an Amazon Machine Image (AMI). For example, you can use Amazon Linux 2.
    - Choose an instance type. The `t2.micro` instance type is a good option for testing.
    - Configure instance details, add storage, and configure security groups (ensure port 80 for HTTP and port 22 for SSH are open).
    - Review and launch the instance.
    - Download the `.pem` key pair for SSH access.

2. **Connect to Your EC2 Instance:**

    ```bash
    ssh -i /path/to/your-key.pem ec2-user@your-ec2-public-dns
    ```

## Initial Setup on EC2 Instance

1. **Install Git:**

    ```bash
    sudo yum update -y
    sudo yum install git -y
    ```

2. **Clone the Repository:**

    ```bash
    git clone https://github.com/PurandharAdigarla/Video_Downloader.git
    cd Video_Downloader
    ```

## Running the Setup Script to set up the environment

1. **Run the `setup_linux.sh` Script:**

    Ensure your `setup_linux.sh` script is executable and then execute it:

    ```bash
    chmod +x setup_linux.sh
    ./setup_linux.sh
    ```

    The script will:
    - Update and install required packages
    - Build the Maven project
    - Configure Nginx
    - Run the Java application in the background

## Accessing the Application

1. **Check Application Logs:**

    After running the setup script, check the application logs to ensure it started correctly:

    ```bash
    tail -f /home/ec2-user/app/app.log
    ```

2. **Verify Nginx Configuration:**

    Open a web browser and navigate to `http://your-ec2-public-dns` to see if the Nginx server is serving your application.

## Troubleshooting

- **Port Conflicts:** If you encounter issues with port conflicts, use the following commands to identify and resolve the problem:

    ```bash
    sudo lsof -i :8082
    sudo kill -9 <PID>
    ```

- **Nginx Configuration Issues:** If Nginx fails to start, check the configuration with:

    ```bash
    sudo nginx -t
    ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
