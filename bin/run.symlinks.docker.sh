#!/bin/bash

# Create symlinks (use absolute paths)
for folder in 'tmp/cache' 'log' 'public/uploads' 'public/system'; do
  rm -rf "/app/$folder"
  mkdir -p "/app/shared/$folder"
  ln -sf "/app/shared/$folder" "/app/$folder"
done

mkdir -p /app/shared/nginx/cache/dragonfly