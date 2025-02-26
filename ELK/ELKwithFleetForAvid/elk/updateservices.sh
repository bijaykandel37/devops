#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <replica_count>"
    exit 1
fi

# Extract replica_count
replica_count=$1

# Check if replica_count is either 0 or 1
if [ "$replica_count" -ne 0 ] && [ "$replica_count" -ne 1 ]; then
    echo "Replica count must be 0 or 1"
    exit 1
fi

# Use xargs to take input Docker services and update replicas
docker service ls --format '{{.Name}}' | xargs -I {} docker service scale {}="$replica_count"

