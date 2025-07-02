#!/bin/bash

echo "🔍 Q3: Validating exported Kubernetes resource YAMLs..."

PROD_DIR=~/DO380/labs/backup-export/production
FILES=("01-pvc.yml" "02-deployment.yml" "03-service.yml" "04-route.yml")
OVERALL_PASS=true

# Step 1: Check if directory exists
if [[ ! -d "$PROD_DIR" ]]; then
  echo "❌ Error: Directory $PROD_DIR does not exist. Please create it first."
  OVERALL_PASS=false
fi

# Step 2: Check if all required files exist
for file in "${FILES[@]}"; do
  if [[ ! -f "$PROD_DIR/$file" ]]; then
    echo "❌ Error: File $file is missing in $PROD_DIR"
    OVERALL_PASS=false
  else
    echo "✅ Found $file"
  fi
done

# Step 3: Define function to check if unwanted fields are present
check_fields_absent() {
  local file="$1"
  shift
  local fields=("$@")
  local file_passed=true

  for field in "${fields[@]}"; do
    if grep -q "$field" "$PROD_DIR/$file"; then
      echo "❌ $file contains unwanted field: $field"
      file_passed=false
    fi
  done

  if [[ "$file_passed" == true ]]; then
    echo "✅ $file cleaned correctly"
  else
    OVERALL_PASS=false
  fi
}

# Step 4: Check each file for unwanted fields (only if file exists)

[[ -f "$PROD_DIR/01-pvc.yml" ]] && check_fields_absent "01-pvc.yml" \
  "metadata.annotations" "metadata.creationTimestamp" "metadata.namespace" \
  "metadata.finalizers" "metadata.resourceVersion" "metadata.uid" \
  "spec.volumeName" "status"

[[ -f "$PROD_DIR/02-deployment.yml" ]] && check_fields_absent "02-deployment.yml" \
  "metadata.annotations" "metadata.creationTimestamp" "metadata.namespace" \
  "metadata.resourceVersion" "metadata.uid" "metadata.generation" \
  "status"

[[ -f "$PROD_DIR/03-service.yml" ]] && check_fields_absent "03-service.yml" \
  "metadata.annotations" "metadata.creationTimestamp" "metadata.namespace" \
  "metadata.resourceVersion" "metadata.uid" "spec.clusterIP" \
  "spec.clusterIPs" "status"

[[ -f "$PROD_DIR/04-route.yml" ]] && check_fields_absent "04-route.yml" \
  "metadata.annotations" "metadata.creationTimestamp" "metadata.namespace" \
  "metadata.resourceVersion" "metadata.uid" "spec.host" "status"

# Step 5: Final Result
if [[ "$OVERALL_PASS" == true ]]; then
  echo "🎉 Q3 PASSED: All resource YAMLs exported and cleaned properly!"
else
  echo "⚠️ Q3 FAILED: Please fix the issues listed above."
fi

