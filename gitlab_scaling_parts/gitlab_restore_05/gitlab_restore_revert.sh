#!/bin/bash

# Define colors for terminal output
RED='\033[0;31m'   # Red color for errors
NC='\033[0m'       # No Color, resets color
YELLOW='\033[33m'  # Yellow color for prompts
GREEN='\033[32m'   # Green color for success messages

# Function to display error messages and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" 1>&2
    exit 1
}

# Trap errors and call error_exit
trap 'error_exit "An error occurred at line $LINENO."' ERR

# Prompt user for backup directory
echo -e "${YELLOW}Enter the directory where the backup is stored:${NC}"
read -r backup_dir

# Prompt user for backup file name
echo -e "${YELLOW}Enter the name of the backup file (e.g., 1234567890_2024_06_01_13.0.0_gitlab_backup.tar):${NC}"
read -r backup_file

# Check if the backup file exists
if [ ! -f "$backup_dir/$backup_file" ]; then
    error_exit "Backup file not found at $backup_dir/$backup_file"
fi

# Stop and remove the GitLab container
echo -e "${YELLOW}Stopping and removing the GitLab container...${NC}"
sudo docker stop gitlab || echo -e "${YELLOW}GitLab container not running.${NC}"
sudo docker rm gitlab || echo -e "${YELLOW}GitLab container does not exist.${NC}"

# Remove the backup file from the host system
echo -e "${YELLOW}Deleting the backup file from the host system...${NC}"
sudo rm -f "$backup_dir/$backup_file" || error_exit "Failed to delete backup file from $backup_dir"

# Optionally remove any temporary files or directories created during the process (if any)
# For example, if you created a temporary directory to hold intermediate files, remove it here.

# Output success message
echo -e "${GREEN}Reversion completed successfully! All specified operations have been undone.${NC}"
