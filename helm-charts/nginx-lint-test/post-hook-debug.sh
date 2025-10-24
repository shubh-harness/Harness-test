#!/bin/bash
# Debug Script - Shows what's available in Harness post-hook environment

echo "=================================================="
echo "🐛 HARNESS POST-HOOK DEBUG INFORMATION"
echo "=================================================="
echo ""

echo "📂 CURRENT WORKING DIRECTORY:"
pwd
echo ""

echo "📂 DIRECTORY CONTENTS:"
ls -la
echo ""

echo "📂 PARENT DIRECTORY:"
ls -la ../ 2>/dev/null || echo "Cannot access parent directory"
echo ""

echo "📂 GRANDPARENT DIRECTORY:"
ls -la ../../ 2>/dev/null || echo "Cannot access grandparent directory"
echo ""

echo "🔍 SEARCHING FOR Chart.yaml FILES:"
find . -name "Chart.yaml" -type f 2>/dev/null || echo "No Chart.yaml found"
find ../ -name "Chart.yaml" -type f 2>/dev/null || true
find ../../ -name "Chart.yaml" -type f 2>/dev/null || true
echo ""

echo "🔍 SEARCHING FOR HELM DIRECTORIES:"
find . -maxdepth 5 -type d -name "helm" 2>/dev/null || echo "No helm directories found"
echo ""

echo "📋 ENVIRONMENT VARIABLES (filtered):"
env | grep -i "harness\|helm\|chart\|working" | sort || echo "No relevant env vars"
echo ""

echo "🔧 HELM VERSION:"
helm version --short 2>/dev/null || echo "Helm not found in PATH"
echo ""

echo "📊 HARNESS EXPRESSIONS (if resolved):"
echo "Chart Name: <+pipeline.stages.Helm_lint_sample.spec.manifests.nativehelm.chartName>"
echo "Stage Name: <+stage.name>"
echo "Pipeline Name: <+pipeline.name>"
echo ""

echo "=================================================="
echo "End of debug information"
echo "=================================================="

# Don't fail - just provide info
exit 0

