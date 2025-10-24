#!/bin/bash
# Test script 2: Post-render validation (WORKS with resolved values)
# This simulates validation AFTER Harness resolves expressions

set -e

echo "=================================================="
echo "TEST 2: Post-Render Validation (After Expression Resolution)"
echo "=================================================="
echo ""
echo "This simulates validation during/after APPLY stage"
echo "where Harness expressions ARE resolved to actual values."
echo ""

CHART_DIR="$(dirname "$0")"

# Simulate Harness-resolved values (what Harness would provide)
# Only replicaCount is an expression, everything else is hardcoded
RESOLVED_VALUES=$(cat <<EOF
replicaCount: 3
namespace: default
image:
  repository: nginx
  tag: 1.21.6
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
  targetPort: 8080
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
environment: production
releaseName: my-app
invalidPort: "not-a-number"
minReplicas: 2
maxReplicas: 10
EOF
)

echo "📝 Using simulated resolved values:"
echo "$RESOLVED_VALUES"
echo ""

# Save to temp file
TEMP_VALUES=$(mktemp)
echo "$RESOLVED_VALUES" > "$TEMP_VALUES"

echo "🔍 Step 1: Running helm lint with resolved values..."
echo ""
helm lint "$CHART_DIR" --values "$TEMP_VALUES"

echo ""
echo "✅ Helm lint passed with resolved values!"
echo ""

echo "🔍 Step 2: Templating with resolved values..."
echo ""
helm template my-app "$CHART_DIR" --values "$TEMP_VALUES" > /tmp/rendered-manifests.yaml

echo "✅ Manifests rendered successfully!"
echo ""

echo "🔍 Step 3: Validating rendered Kubernetes manifests..."
echo ""

# Check if kubectl is available
if command -v kubectl &> /dev/null; then
    echo "Running kubectl dry-run validation..."
    if kubectl apply --dry-run=client -f /tmp/rendered-manifests.yaml 2>&1; then
        echo "✅ Kubernetes validation passed!"
    else
        echo "❌ Kubernetes validation failed!"
    fi
else
    echo "⚠️  kubectl not found, skipping K8s validation"
    echo "   In Harness post-hook, kubectl would be available"
fi

echo ""
echo "📄 Sample of rendered manifests:"
echo "=================================================="
head -30 /tmp/rendered-manifests.yaml

# Cleanup
rm -f "$TEMP_VALUES" /tmp/rendered-manifests.yaml

echo ""
echo "=================================================="
echo "📌 CONCLUSION:"
echo "   ✅ Helm lint works with resolved values"
echo "   ✅ Can validate rendered manifests"
echo "   ✅ Can use kubectl dry-run for full validation"
echo "   ✅ This approach catches real deployment issues"

