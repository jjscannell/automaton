#!/bin/bash
# Script to create SSH credentials in n8n via API

echo "Setting up n8n SSH credentials..."

# Wait for n8n to be ready
sleep 5

# Get the SSH credentials from environment
SSH_USER="${SSH_USERNAME:-automaton}"
SSH_PASS="${SSH_PASSWORD:-automaton}"

# Create credential via n8n API
# Note: This requires n8n_USER_MANAGEMENT_DISABLED=true
curl -X POST http://localhost:5678/rest/credentials \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Claude Runner SSH\",
    \"type\": \"sshPassword\",
    \"data\": {
      \"host\": \"claude-runner\",
      \"port\": 22,
      \"username\": \"${SSH_USER}\",
      \"password\": \"${SSH_PASS}\"
    }
  }"

echo ""
echo "SSH credentials created!"
