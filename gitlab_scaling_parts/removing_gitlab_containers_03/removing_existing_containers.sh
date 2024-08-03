#!/bin/bash

# Define colors
RED='\033[0;31m'   # Red color
NC='\033[0m'       # No Color
YELLOW='\033[33m'  # Yellow color
GREEN='\033[32m'   # Green color

# Function to handle errors
error_exit() {
    echo -e "${RED}Error: $1${NC}" 1>&2
    exit 1
}

# Trap errors and call error_exit
trap 'error_exit "An error occurred at line $LINENO."' ERR

# Prompt user for base directory
echo -e "${YELLOW}Enter the base directory where GitLab data is stored (e.g., /home/operators/Documents/infra/gitlab):${NC}"
read -r base_dir

# Stop and remove GitLab and GitLab Runner containers
echo -e "${YELLOW}Stopping and removing GitLab and GitLab Runner containers...${NC}"
sudo docker stop gitlab gitlab-runner || error_exit "Failed to stop GitLab and GitLab Runner containers."
sudo docker rm gitlab gitlab-runner || error_exit "Failed to remove GitLab and GitLab Runner containers."

# Remove existing files and folders
echo -e "${YELLOW}Removing existing GitLab files and folders...${NC}"
sudo rm -rf "$base_dir" || error_exit "Failed to remove existing files and folders."

echo -e "${GREEN}Containers and files removed successfully!${NC}"
