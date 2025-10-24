#!/bin/bash
# Robust Post-Hook Script for Helm Lint
# Works with any Harness environment (delegate, local, embedded)

set -e

echo "=================================================="
echo "🔍 Harness Post-Hook: Helm Chart Lint Validation"
echo "=================================================="

# Debug: Show current directory and environment
echo "📂 Current working directory: $(pwd)"
echo "📂 Script directory: $(dirname "$0")"
echo ""

# Get the chart name from Harness expression
CHART_NAME="<+pipeline.stages.Helm_lint_sample.spec.manifests.nativehelm.chartName>"
echo "📋 Looking for chart: $CHART_NAME"
echo ""

# Post-hooks run in .__harness_internal_hooks/post_TemplateManifest
# Chart is typically 2 levels up from here
# Try multiple possible locations relative to current directory
POSSIBLE_DIRS=(
  "../.."                                    # Most likely: 2 levels up
  "../../.."                                 # 3 levels up
  "$(dirname "$(dirname "$(pwd)")")"         # Explicit: parent of parent
  "/opt/harness-delegate/repository/helm/source"
  "/Users/shubh/harness/harness-core/repository/helm/source"
)

CHART_DIR=""
for BASE_DIR in "${POSSIBLE_DIRS[@]}"; do
  if [[ -d "$BASE_DIR" ]]; then
    echo "🔍 Searching in: $BASE_DIR"
    FOUND=$(find "$BASE_DIR" -maxdepth 3 -type d -name "$CHART_NAME" 2>/dev/null | grep -v "__harness_internal" | head -n 1)
    if [[ -n "$FOUND" ]]; then
      CHART_DIR="$FOUND"
      echo "✅ Found chart at: $CHART_DIR"
      break
    fi
  fi
done

# If still not found, try to find by Chart.yaml
if [[ -z "$CHART_DIR" ]]; then
  echo "⚠️  Chart not found by name, trying to find Chart.yaml..."
  for BASE_DIR in "${POSSIBLE_DIRS[@]}"; do
    if [[ -d "$BASE_DIR" ]]; then
      FOUND=$(find "$BASE_DIR" -maxdepth 3 -name "Chart.yaml" -type f 2>/dev/null | grep -v "__harness_internal" | head -n 1)
      if [[ -n "$FOUND" ]]; then
        CHART_DIR=$(dirname "$FOUND")
        echo "✅ Found chart at: $CHART_DIR"
        break
      fi
    fi
  done
fi

# Final check
if [[ -z "$CHART_DIR" ]]; then
  echo ""
  echo "❌ ERROR: Chart directory not found!"
  echo "   Chart name: $CHART_NAME"
  echo "   Searched in:"
  for dir in "${POSSIBLE_DIRS[@]}"; do
    echo "   - $dir"
  done
  echo ""
  echo "📋 Debug: Listing available directories..."
  ls -la "$(pwd)" 2>/dev/null || true
  exit 1
fi

echo ""
echo "=================================================="
echo "🔍 Running helm lint on: $CHART_DIR"
echo "=================================================="
echo ""

# Run helm lint
if helm lint "$CHART_DIR"; then
  echo ""
  echo "✅ Helm lint PASSED!"
  echo "=================================================="
  exit 0
else
  echo ""
  echo "❌ Helm lint FAILED!"
  echo "=================================================="
  exit 1
fi

