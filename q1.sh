#!/bin/bash

echo "🔍 Q1: Validating output of 'oc get all'..."

# Step 1: Ask user to paste 'oc get all' output (OR capture directly if you want)
echo "⚠️  Checking if user executed 'oc get all'..."

# Try running 'oc get all' to check user's live cluster
USER_OUTPUT=$(oc get all 2>/dev/null)

# Step 2: Check if user_output contains required keywords (pod, svc, deployment, replicaset)
if [[ -z "$USER_OUTPUT" ]]; then
  echo "❌ Error: Please run 'oc get all' before validation."
  exit 1
fi

# Step 3: Validate presence of essential components
CHECKS_PASSED=true

echo "$USER_OUTPUT" | grep -qE '^pod/.+\s+1/1\s+Running' || {
  echo "❌ Pod is not running (not found or not in Running state)"
  CHECKS_PASSED=false
}

echo "$USER_OUTPUT" | grep -qE '^service/' || {
  echo "❌ Service not found"
  CHECKS_PASSED=false
}

echo "$USER_OUTPUT" | grep -qE '^deployment.apps/' || {
  echo "❌ Deployment not found"
  CHECKS_PASSED=false
}

echo "$USER_OUTPUT" | grep -qE '^replicaset.apps/' || {
  echo "❌ ReplicaSet not found"
  CHECKS_PASSED=false
}

# Step 4: Also check ImageStream and Route via oc separately
IS=$(oc get is 2>/dev/null)
echo "$IS" | grep -qE '^etherpad\s' || {
  echo "❌ ImageStream 'etherpad' not found"
  CHECKS_PASSED=false
}

ROUTE=$(oc get route 2>/dev/null)
echo "$ROUTE" | grep -qE '^etherpad\s' || {
  echo "❌ Route 'etherpad' not found"
  CHECKS_PASSED=false
}

# Final Result
if [ "$CHECKS_PASSED" = true ]; then
  echo "✅ Q1 PASSED: All components present and Pod is running."
else
  echo "❌ Q1 FAILED: One or more components are missing or not running."
  exit 1
fi

