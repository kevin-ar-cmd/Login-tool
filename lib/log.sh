
#!/bin/bash

# log.sh

# Function to log messages
log_message() {
  local log_file="$HOME/.termux_login/login.log"
    local message="$1"
      local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

        # Ensure the log file exists
          touch "$log_file"
            chmod 600 "$log_file"

              # Append the log message to the log file
                echo "[$timestamp] $message" >> "$log_file"
                }

                # Usage examples
                # log_message "Login successful"
                # log_message "Login failed: Incorrect password"