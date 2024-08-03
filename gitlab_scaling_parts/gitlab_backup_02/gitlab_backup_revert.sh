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

# Prompt user for container name and backup directory
echo -e "${YELLOW}Enter the GitLab container name:${NC}"
read -r container_name

echo -e "${YELLOW}Enter the directory where the backup is stored:${NC}"
read -r backup_dir

# Verify if the backup directory exists
if [ ! -d "$backup_dir" ]; then
    error_exit "Backup directory $backup_dir does not exist."
fi

# Prompt user for the specific backup file to delete
echo -e "${YELLOW}Enter the backup filename to delete (without the path):${NC}"
read -r backup_filename

# Construct the full path to the backup file
backup_file_path="$backup_dir/$backup_filename"

# Check if the specified backup file exists
if [ ! -f "$backup_file_path" ]; then
    error_exit "Backup file $backup_file_path does not exist."
fi

# Remove the backup file from the host
echo -e "${YELLOW}Deleting the backup file from the host...${NC}"
sudo rm -f "$backup_file_path" || error_exit "Failed to delete backup file from the host."

# Ask the user if they want to delete the backup file from the GitLab container as well
echo -e "${YELLOW}Do you want to remove the backup file from the GitLab container as well? (yes/no):${NC}"
read -r remove_from_container

if [ "$remove_from_container" == "yes" ]; then
    echo -e "${YELLOW}Removing the backup file from the GitLab container...${NC}"
    sudo docker exec -it "$container_name" rm -f "/var/opt/gitlab/backups/$backup_filename" || error_exit "Failed to delete backup file from the container."
fi

# Stop and remove the GitLab container
echo -e "${YELLOW}Stopping and removing the GitLab container...${NC}"
sudo docker stop "$container_name" || error_exit "Failed to stop the container."
sudo docker rm "$container_name" || error_exit "Failed to remove the container."

# Output success message
echo -e "${GREEN}Reversion and cleanup completed successfully!${NC}"
