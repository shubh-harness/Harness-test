#!/bin/bash
# Simple Post-Hook Script - Finds chart from Harness hooks directory
set -e

echo "🔍 Helm Lint Post-Hook"
echo "Current directory: $(pwd)"
echo ""

# Post-hooks run in .__harness_internal_hooks/post_TemplateManifest
# Chart is in the parent of parent directory
# Example: /path/to/UUID/.__harness_internal_hooks/post_TemplateManifest
# Chart is at: /path/to/UUID/

CHART_DIR=""

# Go up two levels (out of .__harness_internal_hooks directory)
if [[ -f "../../Chart.yaml" ]]; then
  CHART_DIR="../.."
  echo "✅ Found Chart.yaml at: $CHART_DIR"
elif [[ -f "../../../Chart.yaml" ]]; then
  CHART_DIR="../../.."
  echo "✅ Found Chart.yaml at: $CHART_DIR"
else
  # Search for Chart.yaml starting from parent directories
  echo "🔍 Searching for Chart.yaml..."
  FOUND=$(find ../.. -maxdepth 3 -name "Chart.yaml" -type f 2>/dev/null | grep -v "__harness_internal" | head -n 1)
  if [[ -n "$FOUND" ]]; then
    CHART_DIR=$(dirname "$FOUND")
    echo "✅ Found chart at: $CHART_DIR"
  else
    echo "❌ Chart.yaml not found!"
    echo "📋 Current directory: $(pwd)"
    echo "📋 Parent directory contents:"
    ls -la ../.. 2>/dev/null || true
    exit 1
  fi
fi

echo ""
echo "🔍 Running: helm lint $CHART_DIR"
echo ""

helm lint "$CHART_DIR"

