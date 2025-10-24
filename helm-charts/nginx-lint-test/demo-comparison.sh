#!/bin/bash
# Demonstration: Pre-deployment vs Post-hook validation

set -e
CHART_DIR="/Users/shubh/harness-repo/Harness-test/helm-charts/nginx-lint-test"

echo "================================================================================"
echo "🎯 HELM LINT VALIDATION DEMO: Papa John's Use Case"
echo "================================================================================"
echo ""

echo "📋 SCENARIO: Chart has Harness expression in values.yaml"
echo "   replicaCount: <+pipeline.variables.replicas>"
echo ""

# =============================================================================
# PART 1: Pre-Deployment (PREPARE Stage) - Expression NOT resolved
# =============================================================================
echo "================================================================================"
echo "❌ APPROACH 1: Running helm lint BEFORE expression resolution (PREPARE stage)"
echo "================================================================================"
echo ""

echo "🔍 Running: helm lint $CHART_DIR"
helm lint "$CHART_DIR"
echo ""
echo "✅ Result: helm lint PASSED"
echo "⚠️  BUT... this doesn't validate the actual deployment!"
echo ""

echo "🔍 Let's see what the rendered manifest looks like:"
echo ""
echo "   replicas field in Deployment:"
helm template test-release "$CHART_DIR" | grep -A 2 "replicas:"
echo ""
echo "❌ PROBLEM: 'replicas: <+pipeline.variables.replicas>' is a STRING, not INTEGER"
echo "   - Helm lint cannot catch this"
echo "   - This would cause issues in actual deployment"
echo "   - Papa John's cannot reliably validate their charts this way"
echo ""

# =============================================================================
# PART 2: Post-Hook (APPLY Stage) - Expression IS resolved
# =============================================================================
echo "================================================================================"
echo "✅ APPROACH 2: Running helm lint AFTER expression resolution (POST-HOOK)"
echo "================================================================================"
echo ""

# Create a temporary values file with resolved expression
RESOLVED_VALUES=$(mktemp)
cat > "$RESOLVED_VALUES" <<EOF
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

echo "📝 Simulating Harness-resolved values:"
echo "   replicaCount: <+pipeline.variables.replicas> → 3"
echo ""

echo "🔍 Running: helm lint with resolved values"
helm lint "$CHART_DIR" --values "$RESOLVED_VALUES"
echo ""

echo "🔍 Rendering with resolved values:"
echo ""
echo "   replicas field in Deployment:"
helm template test-release "$CHART_DIR" --values "$RESOLVED_VALUES" | grep -A 2 "replicas:"
echo ""
echo "✅ SUCCESS: 'replicas: 3' is now a valid INTEGER"
echo ""

echo "🔍 Validating rendered manifests with kubectl:"
if helm template test-release "$CHART_DIR" --values "$RESOLVED_VALUES" | kubectl apply --dry-run=client -f - > /dev/null 2>&1; then
    echo "✅ Kubernetes validation PASSED"
else
    echo "❌ Kubernetes validation FAILED"
fi

# Cleanup
rm -f "$RESOLVED_VALUES"

echo ""
echo "================================================================================"
echo "📊 SUMMARY: Why Post-Hook is the Right Approach for Papa John's"
echo "================================================================================"
echo ""
echo "❌ PREPARE Stage (Service Hook):"
echo "   - Expressions NOT resolved"
echo "   - helm lint passes but doesn't validate actual values"
echo "   - Cannot catch deployment issues"
echo ""
echo "✅ APPLY Stage (Post-Hook):"
echo "   - Expressions ARE resolved by Harness"
echo "   - helm lint validates actual values"
echo "   - Can validate rendered manifests with kubectl"
echo "   - Catches real deployment issues BEFORE applying"
echo ""
echo "🎯 RECOMMENDATION: Use Post-Deployment Hook with:"
echo "   1. helm lint (structure validation)"
echo "   2. helm template (rendering validation)"
echo "   3. kubectl --dry-run (cluster validation)"
echo "================================================================================"

