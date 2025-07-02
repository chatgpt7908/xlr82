#!/bin/bash

echo "🔍 Q5: Validating exported container images of etherpad..."

OVERALL_PASS=true
PROD_DIR=~/DO380/labs/backup-export/production
V2_DIR="$PROD_DIR/v2/etherpad"

# Step 1: Check if logged in as developer
CURRENT_USER=$(oc whoami 2>/dev/null)
if [[ "$CURRENT_USER" != "developer" ]]; then
  echo "❌ Error: Not logged in as developer (current user: $CURRENT_USER)"
  OVERALL_PASS=false
else
  echo "✅ Logged in as developer"
fi

# Step 2: Check if registry login is done (auth.json exists)
if [[ ! -f /run/user/1000/containers/auth.json ]]; then
  echo "❌ Error: Not logged in to internal registry (auth.json missing)"
  OVERALL_PASS=false
else
  echo "✅ Logged in to internal registry"
fi

# Step 3: Check if image mirror output is created correctly
if [[ ! -d "$V2_DIR" ]]; then
  echo "❌ Error: Directory $V2_DIR not found. Image mirror not successful."
  OVERALL_PASS=false
else
  echo "✅ v2/etherpad directory found"
  
  # Check for presence of blob + manifest files inside v2
  BLOBS=$(find "$V2_DIR/blobs/" -type f | wc -l)
  MANIFESTS=$(find "$V2_DIR/manifests/" -type f | wc -l)

  if [[ $BLOBS -lt 1 ]]; then
    echo "❌ Error: No blobs found inside $V2_DIR/blobs"
    OVERALL_PASS=false
  else
    echo "✅ Blob files exist"
  fi

  if [[ $MANIFESTS -lt 1 ]]; then
    echo "❌ Error: No manifests found inside $V2_DIR/manifests"
    OVERALL_PASS=false
  else
    echo "✅ Manifest files exist"
  fi
fi

# Final Result
if [[ "$OVERALL_PASS" == true ]]; then
  echo "🎉 Q5 PASSED: Etherpad images exported and mirrored correctly!"
else
  echo "⚠️ Q5 FAILED: Please fix the above issues."
fi

