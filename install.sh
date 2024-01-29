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

print_color "green" "Docker containers started for merossApi."

########
########
# Build Angular application
########
########

# Funzione per compilare il progetto Angular
build_angular_project() {
  repo_name="merossJS"  # Il nome del repository è fisso
  base_url="$1"

  print_color "yellow" "Building Angular project for $repo_name with base_url: $base_url..."
  
  cd "$destination_folder/$repo_name"
  
  # Installa npm se non è già installato
  if ! command -v npm >/dev/null; then
    # Chiedi all'utente se vuole installare npm con yum
    read -p "npm is not installed. Do you want to install it? (y/n): " install_npm
    if [ "$install_npm" = "y" ]; then
      # Installa npm con yum (assumendo un sistema basato su yum)
      sudo yum install npm
    else
      print_color "red" "Error: npm is required but not installed. Exiting."
      exit 1
    fi
  fi
  
  # Continua con l'installazione delle dipendenze e la build del progetto Angular
  npm install
  ng build --prod --base-href "/$base_url/"
  
  print_color "green" "Angular project for $repo_name built successfully."
}

# Build del progetto Angular con il base_url fornito dall'utente
read -p "Enter the base_url for Angular project (e.g., myapp): " user_base_url

# Build del progetto Angular con i valori forniti dall'utente
build_angular_project "$user_base_url"

# Aggiungi un ritardo
sleep 1

# Cambia la directory al progetto merossJS e avvia il container Docker con httpd
cd "$destination_folder/merossJS"

# Avvia il container Docker con l'immagine di httpd
docker-compose up -d

# Aggiungi un ritardo
sleep 1

print_color "green" "Docker container started for merossJS with httpd image."


