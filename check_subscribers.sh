#!/bin/bash

# Function to log messages
log_message() {
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") - $1"
}

# Get the current time in ISO 8601 format
current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
log_message "Current Time: $current_time"

# Define a time threshold (e.g., 10 minutes ago)
time_threshold=$(date -u -d "10 minutes ago" +"%Y-%m-%dT%H:%M:%SZ")
log_message "Time Threshold: $time_threshold"

# Authentication credentials from environment variables
tx_auth_credentials="USERNAME:PASSWORD"


# Construct query parameters
query_params="page=1&per_page=100&query=subscribers.created_at%20>%20'$time_threshold'"

# Function to send email based on subscription status
send_email() {
  local email=$1
  local subscription_status=$2
  local template_id

  # Determine the template based on subscription status
  case $subscription_status in
    "unconfirmed")
      template_id=3  # Example template ID for unconfirmed
      ;;
    "confirmed")
      template_id=4  # Example template ID for confirmed
      ;;
    *)
      template_id=5  # Default template ID for other cases
      ;;
  esac

  local json_data=$(cat <<EOF
{
  "subscriber_email": "$email",
  "template_id": $template_id,
  "data": {"order_id": "1234", "date": "2022-07-30", "items": [1, 2, 3]},
  "content_type": "html"
}
EOF
  )
  curl -u "$tx_auth_credentials" "http://localhost:9000/api/tx" -X POST \
       -H 'Content-Type: application/json; charset=utf-8' \
       --data-binary "$json_data"
  log_message "Email sent to $email with template $template_id"
}

# Call the API to get the current list of subscribers
response=$(curl -u "$tx_auth_credentials" -X GET "http://localhost:9000/api/subscribers?$query_params")
if [ $? -ne 0 ]; then
  log_message "Error fetching subscribers"
  exit 1
fi

# Use jq to parse the response and process each subscriber
echo $response | jq -c '.data.results[]' | while read -r subscriber; do
  email=$(echo $subscriber | jq -r '.email')
  subscription_status=$(echo $subscriber | jq -r '.lists[0].subscription_status')

  # Send email based on subscription status
  send_email "$email" "$subscription_status"
done
