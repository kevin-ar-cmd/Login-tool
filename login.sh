#!/bin/bash

# Configuration
BASE_DIR="$HOME/.termux_login"
CREDENTIALS_FILE="$BASE_DIR/.login_credentials"
LOCKOUT_FILE="$BASE_DIR/.login_lockout"
FAILED_ATTEMPTS_FILE="$BASE_DIR/.failed_attempts"
LIB_DIR="$BASE_DIR/lib"
SECURITY_SCRIPT="$LIB_DIR/security.sh"

SALT_LENGTH=16
MAX_ATTEMPTS=3
LOCKOUT_DURATION=60  # Lockout duration in seconds

# Source security functions
if [ -f "$SECURITY_SCRIPT" ]; then
  source "$SECURITY_SCRIPT"
else
  echo "Error: Security script not found at $SECURITY_SCRIPT"
  exit 1
fi

# Function to check if the account is locked out
is_locked_out() {
  if [ -f "$LOCKOUT_FILE" ]; then
    lockout_time=$(cat "$LOCKOUT_FILE")
    if [ $(date +%s) -lt "$lockout_time" ]; then
      return 0  # Account is locked out
    else
      rm "$LOCKOUT_FILE" # Remove lockout file if time has passed
      return 1  # Account is not locked out
    fi
  else
    return 1  # Account is not locked out
  fi
}

# Function to lock the account
lock_account() {
  lockout_time=$(( $(date +%s) + LOCKOUT_DURATION ))
  echo "$lockout_time" > "$LOCKOUT_FILE"
  chmod 600 "$LOCKOUT_FILE"
  echo "Account locked out for $LOCKOUT_DURATION seconds."
}

# Function to increment the failed attempts count
increment_failed_attempts() {
  local attempts=0
  if [ -f "$FAILED_ATTEMPTS_FILE" ]; then
    attempts=$(cat "$FAILED_ATTEMPTS_FILE")
  fi
  attempts=$((attempts + 1))
  echo "$attempts" > "$FAILED_ATTEMPTS_FILE"
  chmod 600 "$FAILED_ATTEMPTS_FILE"
}

# Function to reset the failed attempts count
reset_failed_attempts() {
  rm -f "$FAILED_ATTEMPTS_FILE"
}

# Main login logic
if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "Credentials not set up.  Run $BASE_DIR/setup_credentials.sh first."
  exit 1
fi

# Check if the account is locked out
if is_locked_out; then
  lockout_time=$(cat "$LOCKOUT_FILE")
  remaining_time=$(( $lockout_time - $(date +%s) ))
  echo "Account is locked out. Please try again in $remaining_time seconds."
  exit 1
fi

# Check failed attempts
if [ -f "$FAILED_ATTEMPTS_FILE" ]; then
  attempts=$(cat "$FAILED_ATTEMPTS_FILE")
  if [ "$attempts" -ge "$MAX_ATTEMPTS" ]; then
    lock_account
    exit 1
  fi
fi

read -s -p "Enter password: " input_password
echo

# Read stored credentials
stored_credentials=$(cat "$CREDENTIALS_FILE")
if verify_password "$input_password" "$stored_credentials"; then
  clear
  echo "Login successful!"
  reset_failed_attempts
else
  echo "Login failed."
  increment_failed_attempts
  attempts_remaining=$((MAX_ATTEMPTS - $(cat "$FAILED_ATTEMPTS_FILE")))
  echo "Attempts remaining: $attempts_remaining"
  if [ "$attempts_remaining" -le 0 ]; then
    lock_account
  fi
  exit 1
fi
