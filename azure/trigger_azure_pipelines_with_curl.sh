#!/bin/bash

# Define your credentials and variables
ORGANIZATION="OrgName"
USER=$(az account show | jq -r .user.name)
PROJECT="projectname"

if [[ -f .env ]]; then
  echo ".env file found. Loading variables from .env..."
  # This will ignore commented lines
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found. Please enter the personal access token"
  read -sp "Enter your Personal Access Token: " PAT
fi

# Define arrays for frontend and backend pipelines in "Name:PipelineID" format
frontend_pipelines=(
    "FrontendPipelineOne:101"
    "FrontendPipelineTwo:102"
)

backend_pipelines=(
    "BackendPipelineOne:201"
    "BackendPipelineTwo:202"
)

# Function to trigger a pipeline given a pipeline name and id
trigger_pipeline() {
  local pipeline_name=$1
  local pipeline_id=$2
  
  echo "Running pipeline: $pipeline_name (ID: $pipeline_id)"
  
  curl -s -u "$USER:$PAT" -X POST \
       -d '{"stagesToSkip":[],"resources":{"repositories":{"self":{"refName":"refs/heads/yml-pipelines"}}},"variables":{}}' \
       -H "Content-Type: application/json" \
       "https://dev.azure.com/$ORGANIZATION/$PROJECT/_apis/pipelines/$pipeline_id/runs?api-version=6.0-preview.1"
  
  echo -e "\n----------------------\n"
}

# Function to trigger pipelines from a given array
run_pipelines() {
  local pipelines=("$@")
  
  for pipeline in "${pipelines[@]}"; do
    # Extract the pipeline name and ID using the colon delimiter
    local name
    local id
    name=$(echo "$pipeline" | cut -d':' -f1)
    id=$(echo "$pipeline" | cut -d':' -f2)
    
    trigger_pipeline "$name" "$id"
  done
}

# Ask the user if they want to run frontend pipelines
read -p "Do you want to run frontend pipelines? [y/n]: " run_frontend
if [[ "$run_frontend" =~ ^[Yy]$ ]]; then
  echo "Triggering frontend pipelines..."
  run_pipelines "${frontend_pipelines[@]}"
else
  echo "Skipping frontend pipelines."
fi

# Ask the user if they want to run backend pipelines
read -p "Do you want to run backend pipelines? [y/n]: " run_backend
if [[ "$run_backend" =~ ^[Yy]$ ]]; then
  echo "Triggering backend pipelines..."
  run_pipelines "${backend_pipelines[@]}"
else
  echo "Skipping backend pipelines."
fi

