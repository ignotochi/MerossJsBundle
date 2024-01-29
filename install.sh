#!/bin/bash

# Set the destination and scripts folders
destination_folder="$(pwd)/merossJsBundle"
docker_scripts_folder="$(pwd)/src/docker-scripts"

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
    fi
  else
    print_color "red" "Error: Cloning $repo_name repository failed."
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

# Change directory to merossApi and start Docker containers
cd "$destination_folder/merossApi"
docker-compose up -d

print_color "green" "Docker containers started for merossApi."


# cd "$destination_folder/merossJS"
# docker-compose up -d
