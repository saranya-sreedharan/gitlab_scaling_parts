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
echo -e "${YELLOW}Enter the base directory where GitLab should be set up (e.g., /home/operators/Documents/infra/gitlab):${NC}"
read -r base_dir

# Create necessary subdirectories within the base directory
config_dir="$base_dir/config"
logs_dir="$base_dir/logs"
data_dir="$base_dir/data"
runner_data_dir="$base_dir/gitlab_runner_data"
backup_dir="$base_dir/backups"

echo -e "${YELLOW}Creating necessary directories...${NC}"
mkdir -p "$config_dir" "$logs_dir" "$data_dir" "$runner_data_dir" "$backup_dir" || error_exit "Failed to create necessary directories."

# Create docker-compose.yml file
echo -e "${YELLOW}Creating docker-compose.yml file...${NC}"
cat <<EOF > "$base_dir/docker-compose.yml"
version: '3'

services:
  gitlab:
    image: gitlab/gitlab-ee:latest
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./config:/etc/gitlab
      - ./logs:/var/log/gitlab
      - ./data:/var/opt/gitlab
      - ./backups:/var/opt/gitlab/backups

  gitlab-runner:
    image: gitlab/gitlab-runner:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./gitlab_runner_data:/etc/gitlab-runner
EOF

# Navigate to the directory with the docker-compose.yml file
cd "$base_dir" || error_exit "Failed to navigate to $base_dir"

# Start GitLab and GitLab Runner using Docker Compose
echo -e "${YELLOW}Starting GitLab and GitLab Runner with Docker Compose...${NC}"
sudo docker-compose up -d || error_exit "Failed to start GitLab and GitLab Runner with Docker Compose."

echo -e "${GREEN}GitLab and GitLab Runner setup completed successfully!${NC}"
