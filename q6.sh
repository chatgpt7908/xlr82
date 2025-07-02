#!/bin/bash

echo "🔍 Q6: Validating VolumeSnapshot for etherpad PVC..."

SNAP_NAME="etherpad"
SNAP_NS="production"  # Assuming developer ne production namespace use kiya
EXPECTED_CLASS="ocs-external-storagecluster-rbdplugin-snapclass"
OVERALL_PASS=true

# Step 1: Check if snapshot exists
if ! oc get volumesnapshot "$SNAP_NAME" -n "$SNAP_NS" &>/dev/null; then
  echo "❌ Error: VolumeSnapshot '$SNAP_NAME' not found in namespace '$SNAP_NS'"
  OVERALL_PASS=false
else
  echo "✅ VolumeSnapshot '$SNAP_NAME' found"

  # Step 2: Validate fields
  READY=$(oc get volumesnapshot "$SNAP_NAME" -n "$SNAP_NS" -o jsonpath='{.status.readyToUse}')
  CLASS=$(oc get volumesnapshot "$SNAP_NAME" -n "$SNAP_NS" -o jsonpath='{.spec.volumeSnapshotClassName}')
  PVC=$(oc get volumesnapshot "$SNAP_NAME" -n "$SNAP_NS" -o jsonpath='{.spec.source.persistentVolumeClaimName}')

  # Check readyToUse
  if [[ "$READY" != "true" ]]; then
    echo "❌ Error: VolumeSnapshot is not readyToUse"
    OVERALL_PASS=false
  else
    echo "✅ VolumeSnapshot is readyToUse"
  fi

  # Check volumeSnapshotClassName
  if [[ "$CLASS" != "$EXPECTED_CLASS" ]]; then
    echo "❌ Error: volumeSnapshotClassName is '$CLASS', expected '$EXPECTED_CLASS'"
    OVERALL_PASS=false
  else
    echo "✅ volumeSnapshotClassName is correct"
  fi

  # Check PVC name
  if [[ "$PVC" != "etherpad" ]]; then
    echo "❌ Error: PersistentVolumeClaim name is '$PVC', expected 'etherpad'"
    OVERALL_PASS=false
  else
    echo "✅ PVC name is correct"
  fi
fi

# Final result
if [[ "$OVERALL_PASS" == true ]]; then
  echo "🎉 Q6 PASSED: VolumeSnapshot created and validated successfully!"
else
  echo "⚠️ Q6 FAILED: Please review the errors above."
fi

