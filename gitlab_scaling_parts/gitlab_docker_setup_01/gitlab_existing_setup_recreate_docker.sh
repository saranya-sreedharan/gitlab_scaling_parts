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
echo -e "${YELLOW}Enter the base directory where GitLab and related files should be stored (e.g., /home/operators/Documents/infra/gitlab):${NC}"
read -r base_dir

# Create necessary subdirectories within the base directory
config_dir="$base_dir/config"
logs_dir="$base_dir/logs"
data_dir="$base_dir/data"
runner_data_dir="$base_dir/gitlab_runner_data"
backup_dir="$base_dir/backups"

echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p "$config_dir" "$logs_dir" "$data_dir" "$runner_data_dir" "$backup_dir" || error_exit "Failed to create necessary directories."

# Run GitLab container
echo -e "${YELLOW}Starting GitLab container...${NC}"
sudo docker run --detach \
  --publish 443:443 --publish 80:80 \
  --name gitlab \
  --restart always \
  --volume "$config_dir":/etc/gitlab \
  --volume "$logs_dir":/var/log/gitlab \
  --volume "$data_dir":/var/opt/gitlab \
  --volume "$backup_dir":/var/opt/gitlab/backups \
  gitlab/gitlab-ee:latest || error_exit "Failed to start GitLab container."

# Run GitLab Runner container
echo -e "${YELLOW}Starting GitLab Runner container...${NC}"
sudo docker run --detach \
  --name gitlab-runner \
  --restart always \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume "$runner_data_dir":/etc/gitlab-runner \
  gitlab/gitlab-runner:latest || error_exit "Failed to start GitLab Runner container."

# Output the success message and instruction for getting the initial root password
echo -e "${GREEN}GitLab and GitLab Runner setup completed successfully!${NC}"
echo -e "${GREEN}To retrieve the initial root password, run:${NC}"
echo -e "sudo docker exec -it gitlab cat /etc/gitlab/initial_root_password"
