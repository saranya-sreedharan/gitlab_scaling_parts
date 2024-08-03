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
echo -e "${YELLOW}Enter the base directory where GitLab and related files are stored (e.g., /home/operators/Documents/infra/gitlab):${NC}"
read -r base_dir

# Define subdirectories within the base directory
config_dir="$base_dir/config"
logs_dir="$base_dir/logs"
data_dir="$base_dir/data"
runner_data_dir="$base_dir/gitlab_runner_data"
backup_dir="$base_dir/backups"

# Stop and remove GitLab and GitLab Runner containers
echo -e "${YELLOW}Stopping and removing GitLab and GitLab Runner containers...${NC}"
sudo docker stop gitlab gitlab-runner || error_exit "Failed to stop GitLab and GitLab Runner containers."
sudo docker rm gitlab gitlab-runner || error_exit "Failed to remove GitLab and GitLab Runner containers."

# Remove directories
echo -e "${YELLOW}Removing directories...${NC}"
sudo rm -rf "$config_dir" "$logs_dir" "$data_dir" "$runner_data_dir" "$backup_dir" || error_exit "Failed to remove directories."

# Remove docker-compose.yml file if it exists
if [ -f "$base_dir/docker-compose.yml" ]; then
    echo -e "${YELLOW}Removing docker-compose.yml file...${NC}"
    sudo rm -f "$base_dir/docker-compose.yml" || error_exit "Failed to remove docker-compose.yml file."
fi

# Output the success message
echo -e "${GREEN}Reversion completed successfully!${NC}"
