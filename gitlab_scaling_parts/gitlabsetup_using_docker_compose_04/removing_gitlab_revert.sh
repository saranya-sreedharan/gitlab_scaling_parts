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

# Prompt user for base directory used during the setup
echo -e "${YELLOW}Enter the base directory used for GitLab setup (e.g., /home/operators/Documents/infra/gitlab):${NC}"
read -r base_dir

# Define the subdirectories within the base directory
config_dir="$base_dir/config"
logs_dir="$base_dir/logs"
data_dir="$base_dir/data"
runner_data_dir="$base_dir/gitlab_runner_data"
backup_dir="$base_dir/backups"
compose_file="$base_dir/docker-compose.yml"

# Check if the docker-compose file exists
if [ ! -f "$compose_file" ]; then
    error_exit "The docker-compose.yml file does not exist in the specified base directory."
fi

# Stop and remove the containers using Docker Compose
echo -e "${YELLOW}Stopping and removing GitLab and GitLab Runner containers...${NC}"
sudo docker-compose -f "$compose_file" down || error_exit "Failed to stop and remove containers using Docker Compose."

# Remove the subdirectories
echo -e "${YELLOW}Removing configuration, logs, data, and backup directories...${NC}"
sudo rm -rf "$config_dir" "$logs_dir" "$data_dir" "$runner_data_dir" "$backup_dir" || error_exit "Failed to remove one or more directories."

# Remove the docker-compose.yml file
echo -e "${YELLOW}Removing the docker-compose.yml file...${NC}"
sudo rm -f "$compose_file" || error_exit "Failed to remove the docker-compose.yml file."

# Output success message
echo -e "${GREEN}Reversion completed successfully! All resources have been cleaned up.${NC}"


