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

# Set install mode
install_mode="cloning"

# Set projects folder
project_folder_merossJS="merossJS"
project_folder_merossApi="merossApi"

# Set the destination and scripts folders
destination_folder="$(pwd)"
docker_scripts_folder="$(pwd)/docker-scripts"

# Set merossApi.conf.json folders
config_file="merossApi.conf.json"
config_file_path="dist/meross-js/assets/$config_file"

# URLs for Git repositories
merossApi_url="https://github.com/ignotochi/MerossApi.git"
merossJS_url="https://github.com/ignotochi/MerossJS.git"

# Function to print colored output
print_color() {

  case "$1" in
    red)    echo -e "\e[91m$2\e[0m";;
    green)  echo -e "\e[92m$2\e[0m";;
    yellow) echo -e "\e[93m$2\e[0m";;
    blue)   echo -e "\e[94m$2\e[0m";;  
    magenta) echo -e "\e[95m$2\e[0m";; 
    cyan)   echo -e "\e[96m$2\e[0m";; 
    white)  echo -e "\e[97m$2\e[0m";;  
    *)     echo "$2";;
  esac

  sleep 1
}

# Function to perform Git clone and copy scripts
clone_and_copy() {
  repo_url="$1"
  repo_name="$2"

  print_color "white" "------------------------------------------------------"

  destination_path="$destination_folder/$repo_name"

  if [ -d "$destination_path" ]; then

    install_mode="pulling"
    cd "$destination_path"

    print_color "yellow" "Pulling latest changes for $repo_name repository..." 
    git pull

    if [ $? -ne 0 ]; then
      print_color "red" "Error: Pulling changes for $repo_name repository failed."
      exit 1
    else
      print_color "green" "Successfully pulled latest changes for $repo_name."
    fi
  else
    print_color "yellow" "Cloning $repo_name repository..."
    git clone "$repo_url" "$destination_path"

    if [ $? -ne 0 ]; then
      print_color "red" "Error: Cloning $repo_name repository failed."
      exit 1
    else
      print_color "green" "Successfully cloned $repo_name repository."
    fi
  fi

  # Copy Docker scripts
  if [ -d "$docker_scripts_folder/$repo_name" ]; then

    cp -r "$docker_scripts_folder/$repo_name/"* "$destination_path/"
    print_color "green" "Scripts copied for $repo_name."

  else
    print_color "red" "Error: Docker scripts folder not found for $repo_name."
    exit 1
  fi
}

print_color "white" ""
print_color "white" "##################### Welcome to #####################"
print_color "white" "############## Meross Bundle installation ############"
print_color "white" "######################################################"
print_color "white" ""

# Ensure destination and scripts folders exist
if [ ! -d "$destination_folder" ]; then
  mkdir -p "$destination_folder"
fi

if [ ! -d "$docker_scripts_folder" ]; then
  mkdir -p "$docker_scripts_folder"
fi

# Clone and copy MerossApi repository
clone_and_copy "$merossApi_url" "$project_folder_merossApi"

# Clone and copy MerossJS repository
clone_and_copy "$merossJS_url" "$project_folder_merossJS"

print_color "green" "Repositories cloned and scripts copied successfully."

# Change directory to merossApi
cd "$destination_folder/merossApi"

if [ ! -d "logs" ]; then
  mkdir -p "logs"
fi

print_color "white" "------------------------------------------------------"

# Check if the "merossApi" container already exists and remove it
if docker ps -a --format '{{.Names}}' | grep -q '^merossApi$'; then

  print_color "magenta" "Removing existing merossApi container..."
  docker rm -f merossApi > /dev/null
  print_color "green" "Existing merossApi container removed."
fi

# Start Docker containers
docker-compose up -d > /dev/null

print_color "white" "------------------------------------------------------"

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

save_merossJS_config() {

  repo_name="$1"
  print_color "blue" "Preserving $config_file from $config_file_path"
  print_color "blue" "To $destination_folder/$config_file"

  if [ -f "$config_file_path" ]; then
    mv -f "$config_file_path" "$destination_folder/$config_file"
  fi

  print_color "green" "Preserved $config_file"
}

restore_merossJS_config() {

  repo_name="$1"
  print_color "blue" "Restoring $config_file from $destination_folder/$config_file"
  print_color "blue" "To $config_file_path"

  if [ -f "$destination_folder/$config_file" ]; then
    mv -f "$destination_folder/$config_file" "$config_file_path"
  fi

  print_color "green" "Restoring of $config_file done!"
}

# Function to build Angular project

build_angular_project() {

  repo_name="$project_folder_merossJS"  
  cd "$destination_folder/$repo_name"

  if [ "$install_mode" == "pulling" ]; then
    save_merossJS_config "$project_folder_merossJS"
  fi

  print_color "white" "------------------------------------------------------"

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

      npm install -g npm --yes > /dev/null
    else
      print_color "red" "Error: npm is required but not installed. Exiting."
      exit 1
    fi
  fi

  if ! command -v ng >/dev/null; then
    read -p "Angular CLI is not installed. Do you want to install it? (y/n): " install_ng
    if [ "$install_ng" = "y" ]; then
      npm install -g @angular/cli --yes > /dev/null
    else
      print_color "red" "Error: Angular CLI is required but not installed. Exiting."
      exit 1
    fi
  fi

  npm install --yes > /dev/null

  ng build --configuration production --base-href "/"

  print_color "white" "------------------------------------------------------"

  if [ $? -eq 0 ]; then
    if [ "$install_mode" == "pulling" ]; then
      restore_merossJS_config "$project_folder_merossJS"
    fi
    print_color "green" "Angular project for $repo_name built successfully."
  else
    print_color "red" "Error: Angular project for $repo_name failed to build."
    exit 1
  fi
}

build_angular_project

# create symlink for merossJS configuration
ln -sf "$destination_folder/merossJS/dist/meross-js/assets/merossApi.conf.json"  .

# Check if the "merossJS" container already exists and remove it
if docker ps -a --format '{{.Names}}' | grep -q '^merossJS$'; then
  print_color "magenta" "Removing existing merossJs container..."
  docker rm -f merossJS > /dev/null
  print_color "green" "Existing merossJs container removed."
fi

# Start Docker containers for merossJS
docker-compose up -d > /dev/null

# Check if "merossJS" container is running
print_color "white" "------------------------------------------------------"

if docker ps --format '{{.Names}}' | grep -q '^merossJS$'; then
  print_color "green" "Docker containers started for merossJS."
else
  print_color "red" "Error: Docker containers failed to start for merossJS."
  exit 1
fi
