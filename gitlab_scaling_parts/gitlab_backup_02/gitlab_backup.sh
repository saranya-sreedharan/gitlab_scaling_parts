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

# Prompt user for container name
echo -e "${YELLOW}Enter the GitLab container name:${NC}"
read -r container_name

# Prompt user for backup directory
echo -e "${YELLOW}Enter the directory where the backup should be stored:${NC}"
read -r backup_dir

# Ensure the backup directory exists
mkdir -p "$backup_dir"

# Create GitLab backup
echo -e "${YELLOW}Creating GitLab backup...${NC}"
sudo docker exec -it "$container_name" gitlab-backup create STRATEGY=copy || error_exit "Failed to create GitLab backup."

# Find the latest backup created in the container
LATEST_BACKUP=$(sudo docker exec -it "$container_name" ls /var/opt/gitlab/backups/ | grep tar | tail -1 | tr -d '\r')

# Copy the backup file from the container to the host
echo -e "${YELLOW}Copying backup to host...${NC}"
sudo docker cp "$container_name:/var/opt/gitlab/backups/$LATEST_BACKUP" "$backup_dir/$LATEST_BACKUP" || error_exit "Failed to copy backup to host."

echo -e "${GREEN}Backup completed successfully and stored at $backup_dir/$LATEST_BACKUP${NC}"
