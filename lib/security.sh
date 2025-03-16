#!/bin/bash

# Function to generate a random salt
generate_salt() {
  openssl rand -base64 $1
}

# Function to hash the password with salt
hash_password() {
  local password="$1"
  local salt="$2"
  echo -n "$password$salt" | openssl dgst -sha256
}

# Function to verify the password
verify_password() {
  local password="$1"
  local stored_hash="$2"
  local salt=$(echo "$stored_hash" | cut -d':' -f2)
  local new_hash=$(hash_password "$password" "$salt")
  new_hash=$(echo "$new_hash" | cut -d' ' -f2) # Extract hash value

  stored_hash_value=$(echo "$stored_hash" | cut -d':' -f1)

  if [ "$new_hash" == "$stored_hash_value" ]; then
    return 0  # Passwords match
  else
    return 1  # Passwords do not match
  fi
}
