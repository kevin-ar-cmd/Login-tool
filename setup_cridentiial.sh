#!/bin/bash

# Configuration
BASE_DIR="$HOME/.termux_login"
CREDENTIALS_FILE="$BASE_DIR/.login_credentials"
LIB_DIR="$BASE_DIR/lib"
SECURITY_SCRIPT="$LIB_DIR/security.sh"
SALT_LENGTH=16

# Source security functions
if [ -f "$SECURITY_SCRIPT" ]; then
  source "$SECURITY_SCRIPT"
else
  echo "Error: Security script not found at $SECURITY_SCRIPT"
  exit 1
fi

# Function to set up new credentials (only run once)
setup_credentials() {
  if [ -f "$CREDENTIALS_FILE" ]; then
    echo "Credentials file already exists.  Remove it to reset."
    return 1
  fi

  read -s -p "Enter new password: " new_password
  echo
  read -s -p "Confirm new password: " confirm_password
  echo

  if [ "$new_password" != "$confirm_password" ]; then
    echo "Passwords do not match."
    return 1
  fi

  salt=$(generate_salt $SALT_LENGTH)
  hashed_password=$(hash_password "$new_password" "$salt")
  hashed_password=$(echo "$hashed_password" | cut -d' ' -f2)  # Extract hash value

  # Store hash:salt in credentials file
  mkdir -p "$BASE_DIR" # Ensure the directory exists
  echo "$hashed_password:$salt" > "$CREDENTIALS_FILE"
  chmod 600 "$CREDENTIALS_FILE" # Protect the file

  echo "Credentials set up successfully."
}

setup_credentials # Run the setup function

