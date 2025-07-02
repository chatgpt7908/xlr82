#!/bin/bash

echo "🔍 Q4: Validating internal registry exposure by admin..."

OVERALL_PASS=true

# Step 1: Check if logged in as admin
CURRENT_USER=$(oc whoami 2>/dev/null)
if [[ "$CURRENT_USER" != "admin" ]]; then
  echo "❌ Error: Not logged in as admin (current user: $CURRENT_USER)"
  OVERALL_PASS=false
else
  echo "✅ Logged in as admin"
fi

# Step 2: Check if defaultRoute is enabled in imageregistry config
REGISTRY_ROUTE=$(oc get configs.imageregistry.operator.openshift.io/cluster -o jsonpath='{.spec.defaultRoute}' 2>/dev/null)

if [[ "$REGISTRY_ROUTE" != "true" ]]; then
  echo "❌ Error: Internal registry defaultRoute is NOT enabled"
  OVERALL_PASS=false
else
  echo "✅ Internal registry defaultRoute is enabled"
fi

# Final Result
if [[ "$OVERALL_PASS" == true ]]; then
  echo "🎉 Q4 PASSED: Internal registry exposed correctly by admin!"
else
  echo "⚠️ Q4 FAILED: Please resolve the issues listed above."
fi

