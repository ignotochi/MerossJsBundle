#!/bin/bash

<<'DOC'
This script performs the following tasks:
1. Clones MerossApi and MerossJS Git repositories.
2. Copies scripts from the docker-scripts folder to the respective repositories.
3. Removes unwanted files from the repositories.
4. Removes existing Docker containers (if any) for merossApi.
5. Starts Docker containers for merossApi.
6. Builds Angular project for merossJS, prompting the user to install npm and Angular CLI if not already installed.
7. Starts Docker containers for merossJS.

Ensure that Docker, Git, npm, and Angular CLI are installed on your system before running this script.

Note: The script checks for successful execution at various stages and exits if any step fails.
DOC

# Set the destination and scripts folders
destination_folder="$(pwd)"
docker_scripts_folder="$(pwd)/docker-scripts"

# URLs for Git repositories
merossApi_url="https://github.com/ignotochi/MerossApi.git"
merossJS_url="https://github.com/ignotochi/MerossJS.git"

# Function to print colored output
print_color() {
  case "$1" in
    red)    echo -e "\e[91m$2\e[0m";;
    green)  echo -e "\e[92m$2\e[0m";;
    yellow) echo -e "\e[93m$2\e[0m";;
    *)     echo "$2";;
  esac

  sleep 2
}

# Function to perform Git clone and copy scripts
clone_and_copy() {
  repo_url="$1"
  repo_name="$2"
  
  print_color "yellow" "Cloning $repo_name repository..."
  git clone "$repo_url" "$destination_folder/$repo_name"
  
  if [ -d "$destination_folder/$repo_name" ]; then
    # Remove unwanted files if necessary (e.g., main.py)
    rm "$destination_folder/$repo_name/main.py" 2>/dev/null
    
    # Copy Docker scripts
    if [ -d "$docker_scripts_folder/$repo_name" ]; then
      cp -r "$docker_scripts_folder/$repo_name/"* "$destination_folder/$repo_name/"
      print_color "green" "Scripts copied for $repo_name."
    else
      print_color "red" "Error: Docker scripts folder not found for $repo_name."
      exit 1
    fi
  else
    print_color "red" "Error: Cloning $repo_name repository failed."
    exit 1
  fi
}

# Ensure destination and scripts folders exist
if [ ! -d "$destination_folder" ]; then
  mkdir -p "$destination_folder"
fi

if [ ! -d "$docker_scripts_folder" ]; then
  mkdir -p "$docker_scripts_folder"
fi

# Clone and copy MerossApi repository
clone_and_copy "$merossApi_url" "merossApi"

# Clone and copy MerossJS repository
clone_and_copy "$merossJS_url" "merossJS"

print_color "green" "Repositories cloned and scripts copied successfully."

# Change directory to merossApi
cd "$destination_folder/merossApi"

# Check if the "merossApi" container already exists and remove it
if docker ps -a --format '{{.Names}}' | grep -q '^merossApi$'; then
  print_color "yellow" "Removing existing merossApi container..."
  docker rm -f merossApi
  print_color "green" "Existing merossApi container removed."
fi

# Start Docker containers
docker-compose up -d

# Check if "merossApi" container is running
if docker ps --format '{{.Names}}' | grep -q '^merossApi$'; then
  print_color "green" "Docker containers started for merossApi."
else
  print_color "red" "Error: Docker containers failed to start for merossApi."
  exit 1
fi

########################################################################
########################################################################
##################### Build Angular application ########################
########################################################################
########################################################################

node_version="18"

# Function to build Angular project
build_angular_project() {
  repo_name="merossJS"  

  cd "$destination_folder/$repo_name"

  print_color "yellow" "Building Angular project for $repo_name..."
  
  if ! command -v npm >/dev/null; then
    read -p "npm is not installed. Do you want to install it along with Node.js version $node_version? (y/n): " install_npm
    if [ "$install_npm" = "y" ]; then

      if ! command -v nvm >/dev/null; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
        source ~/.bashrc  # or restart your shell
      fi

      nvm install "$node_version"
      nvm use "$node_version"

      npm install -g npm --yes
    else
      print_color "red" "Error: npm is required but not installed. Exiting."
      exit 1
    fi
  fi

  if ! command -v ng >/dev/null; then
    read -p "Angular CLI is not installed. Do you want to install it? (y/n): " install_ng
    if [ "$install_ng" = "y" ]; then
      npm install -g @angular/cli --yes --no-interactive
    else
      print_color "red" "Error: Angular CLI is required but not installed. Exiting."
      exit 1
    fi
  fi

  npm install --yes

  ng build --configuration production --base-href "/$repo_name/" --deploy-url "/$repo_name/"

  if [ $? -eq 0 ]; then
    print_color "green" "Angular project for $repo_name built successfully."
  else
    print_color "red" "Error: Angular project for $repo_name failed to build."
    exit 1
  fi
}

build_angular_project

print_color "green" "merossJS compiled with success!"

# Start Docker containers for merossJS
docker-compose up -d

# Check if "merossJS" container is running
if docker ps --format '{{.Names}}' | grep -q '^merossJS$'; then
  print_color "green" "Docker containers started for merossJS."
else
  print_color "red" "Error: Docker containers failed to start for merossJS."
  exit 1
fi

