#!/bin/bash

echo "🔍 Q2: Validating login as developer user..."

# Check current user
CURRENT_USER=$(oc whoami 2>/dev/null)

# Validate login
if [[ "$CURRENT_USER" != "developer" ]]; then
  echo "❌ Error: Not logged in as developer."
  echo "🔧 Please run: oc login -u developer -p developer https://api.ocp4.example.com:6443"
  exit 1
fi

# Check current project is 'production'
CURRENT_PROJECT=$(oc project -q 2>/dev/null)

if [[ "$CURRENT_PROJECT" != "production" ]]; then
  echo "❌ Error: Current project is not 'production'."
  echo "🔧 Please run: oc project production"
  exit 1
fi

echo "✅ Q2 PASSED: Logged in as 'developer' and using 'production' project."

