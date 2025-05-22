#!/bin/sh

# Configuration (update with your values)
position_file_path="/root/notifyAndRemoveMembersFromLDAP/position.txt"
log_file_path="//root/notifyAndRemoveMembersFromLDAP/combinedlog.log"
webhook_url="https://chat.googleapis.com/v1/spaces/ARersc/messages?key=theKey"

target_text="curl"

main() {
    # Get the last known position from the position file
    last_known_position=$(get_last_known_position)

    # Get the current size of the log file
    current_size=$(wc -c < "$log_file_path")

    # Read the new content from the log file
    new_content=$(tail -c +$last_known_position "$log_file_path")

    # Update the last known position in the position file
    update_last_known_position "$current_size"

    # Check if the target text is present in the new content
    if echo "$new_content" | grep -q "$target_text"; then
        echo "Target text '$target_text' appended to the log file."
        send_alert "Alert: There might be error while running '$target_text' command. Please check the logs at /root/notifyAndRemoveMembersFromLDAP/combinedlog.log"
    else
        echo "Target text '$target_text' not found in the appended content."
    fi
}

get_last_known_position() {
    if [ -e "$position_file_path" ]; then
        cat "$position_file_path" | tr -d '\n' 
    else
        echo 0
    fi
}

update_last_known_position() {
    echo "$1" > "$position_file_path"
}

send_alert() {
    local message="$1"
    local alert_data="{\"text\":\"$message\"}"
    local response=$(curl -s -X POST -H "Content-Type: application/json" -d "$alert_data" "$webhook_url")

    if [ "$response" = "200" ]; then
        echo "Alert sent successfully!"
    else
        echo "Failed to send alert with status code $response"
    fi
}

main

