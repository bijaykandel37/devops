#!/bin/bash

# Determine the environment

USERNAME=$REALM_USERNAME
PASSWORD=$REALM_PASSWORD
KEYCLOAK_CLIENT_ID=$REALM_CLIENT_ID
KEYCLOAK_CLIENT_SECRET=$REALM_CLIENT_SECRET
VAULT_ADDR="https://vault.com"
OIDC_TOKEN_URL="https://keycloak.com/realms/occs/protocol/openid-connect/token"
VAULT_LOGIN_URL="https://vault.com/v1/auth/oidc/login"
ROLE="reader"

apt install jq -y

# Get OIDC token from Keycloak
OIDC_RESPONSE=$(curl -s -X POST "$OIDC_TOKEN_URL" \
  -d "grant_type=password" \
  -d "client_id=$KEYCLOAK_CLIENT_ID" \
  -d "client_secret=$KEYCLOAK_CLIENT_SECRET" \
  -d "username=$USERNAME" \
  -d "password=$PASSWORD" \
  -d "scope=openid")

ACCESS_TOKEN=$(echo "$OIDC_RESPONSE" | jq -r .access_token)

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "Failed to get OIDC access token."
  exit 1
fi

# Log in to Vault using the JWT token and get the Vault token
VAULT_RESPONSE=$(curl -s -X POST "$VAULT_LOGIN_URL" \
  -H "Content-Type: application/json" \
  -d "{\"role\": \"$ROLE\", \"jwt\": \"$ACCESS_TOKEN\"}")

VAULT_TOKEN=$(echo "$VAULT_RESPONSE" | jq -r .auth.client_token)

if [ "$VAULT_TOKEN" == "null" ] || [ -z "$VAULT_TOKEN" ]; then
  echo "Failed to log in to Vault."
  exit 1
fi

echo $VAULT_TOKEN