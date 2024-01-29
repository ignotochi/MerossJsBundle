#!/bin/bash

destination_folder="$(pwd)/merossJsBundle"
docker_scripts_folder="$(pwd)/src/docker-scripts"

merossApi_url="https://github.com/ignotochi/MerossApi.git"
merossJS_url="https://github.com/ignotochi/MerossJS.git"

if [ ! -d "$destination_folder" ]; then
  mkdir -p "$destination_folder"
fi

if [ ! -d "$docker_scripts_folder" ]; then
  mkdir -p "$docker_scripts_folder"
fi

git clone "$merossApi_url" "$destination_folder/merossApi"
cp -r "$docker_scripts_folder/merossApi/"* "$destination_folder/merossApi/"

git clone "$merossJS_url" "$destination_folder/merossJS"
cp -r "$docker_scripts_folder/merossJS/"* "$destination_folder/merossJS/"

echo "Repositories cloned and scripts copied successfully."

cd "$destination_folder/merossApi"
docker-compose up -d

# cd "$destination_folder/merossJS"
# docker-compose up -d