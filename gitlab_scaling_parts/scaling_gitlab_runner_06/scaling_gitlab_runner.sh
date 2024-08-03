#!/bin/bash

# Define colors for terminal output
RED='\033[0;31m'   # Red color for errors
NC='\033[0m'       # No Color, resets color
YELLOW='\033[33m'  # Yellow color for prompts
GREEN='\033[32m'   # Green color for success messages

# Function to handle errors and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" 1>&2
    exit 1
}

# Trap errors and call error_exit
trap 'error_exit "An error occurred at line $LINENO."' ERR

# Prompt user for base directory containing the docker-compose.yml file
echo -e "${YELLOW}Enter the base directory containing the docker-compose.yml file (e.g., /path/to/gitlab):${NC}"
read -r base_dir

# Navigate to the directory containing the docker-compose.yml file
cd "$base_dir" || error_exit "Failed to navigate to $base_dir"

# Scale the GitLab Runner to 4 instances
echo -e "${YELLOW}Scaling GitLab Runner to 4 instances...${NC}"
sudo docker-compose up -d --scale gitlab-runner=4 || error_exit "Failed to scale GitLab Runner to 4 instances."

# Output success message
echo -e "${GREEN}GitLab Runner scaled to 4 instances successfully!${NC}"
