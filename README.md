# Proxmox Golden Images

This project automates the creation of golden image templates for Ubuntu, Rocky Linux, and CentOS 10 using Packer and GitHub Actions.
## Overview

The goal of this repository is to streamline the creation of standardized Virtual Machine (VM) templates within a Proxmox Virtual Environment. By automating the build process with Packer, we ensure consistent and reproducible images.

## Prerequisites

1.  Access to a Proxmox VE server.
2.  An API Token created in Proxmox with sufficient permissions to create and manage QEMU VMs.

## Token Creation (Proxmox CLI)

To create a dedicated user and API token with full permissions (Administrator) via the Proxmox shell, run the following commands:

1.  **Create a dedicated user:**
    ```bash
    pveum user add packer@pam --comment "User for Packer automation"
    ```

2.  **Assign the Administrator role:**
    ```bash
    pveum acl modify / -user packer@pam -role Administrator
    ```

3.  **Generate the API Token:**
    This command will output the `value` (secret), which you only see once.
    ```bash
    pveum user token add packer@pam packer-token --privsep 0
    ```

    *   **Token ID:** `packer@pam!packer-token`
    *   **Secret:** Copy the `value` from the output immediately.

## Configuration

To enable the automation to interact with your Proxmox server, you must add the following credentials to your GitHub Repository Secrets.

Navigate to **Settings** > **Secrets and variables** > **Actions** > **New repository secret** and add:

| Secret Name            | Description                                      | Example Format                          |
|------------------------|--------------------------------------------------|-----------------------------------------|
| `PROXMOX_URL`          | The full URL to your Proxmox API endpoint.       | `https://proxmox.example.com:8006/api2/json` |
| `PROXMOX_TOKEN_ID`     | The Token ID (User + Token Name).                | `user@pam!token_name`                   |
| `PROXMOX_TOKEN_SECRET` | The secret UUID generated for the token.         | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`  |



## GitHub Runner Setup (Ubuntu)

To execute the Packer builds, this repository requires a self-hosted runner. Below are the steps to set up a runner on Ubuntu and configure it to start automatically as a service.

1.  **Register the Runner:**
    *   Navigate to **Settings** > **Actions** > **Runners** > **New self-hosted runner**.
    *   Select **Linux**.
    *   Follow the instructions provided by GitHub to **Download** and **Configure** the runner agent.

2.  **Install Dependencies:**
    Before starting, ensure required dependencies are installed:
    ```bash
    # Inside the runner directory
    sudo ./bin/installdependencies.sh
    ```

3.  **Configure Auto-Start:**
    Once configured, install the systemd service to ensure the runner starts automatically on boot.

    ```bash
    # Install the service
    sudo ./svc.sh install

    # Start the service
    sudo ./svc.sh start

    # Verify the service is running
    sudo ./svc.sh status
    ```
