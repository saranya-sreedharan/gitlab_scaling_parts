#!/bin/bash

# Define colors
RED='\033[0;31m'   # Red color
NC='\033[0m'       # No Color, resets color
YELLOW='\033[33m'  # Yellow color
GREEN='\033[32m'   # Green color

# Function to handle errors and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" 1>&2
    exit 1
}

# Trap errors and call error_exit
trap 'error_exit "An error occurred at line $LINENO."' ERR

# Prompt user for backup directory
echo -e "${YELLOW}Enter the directory where the backup is stored:${NC}"
read -r backup_dir

# Check if the backup directory exists
if [ ! -d "$backup_dir" ]; then
    error_exit "Backup directory not found at $backup_dir"
fi

# Find the latest backup file in the specified directory
latest_backup=$(find "$backup_dir" -maxdepth 1 -type f -name "*.tar" -printf "%T@ %p\n" | sort -n | tail -1 | cut -f2- -d' ')


# Restore GitLab from the latest backup
echo -e "${YELLOW}Restoring GitLab from backup file: $latest_backup${NC}"
sudo docker exec -it gitlab gitlab-backup restore BACKUP=$(basename "$latest_backup" .tar) || error_exit "Failed to restore GitLab from backup."

echo -e "${GREEN}GitLab data restored successfully!${NC}"
