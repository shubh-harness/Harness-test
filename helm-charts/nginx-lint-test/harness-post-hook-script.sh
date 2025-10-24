#!/bin/bash
# Harness Post-Hook Script for Helm Chart Validation
# This runs AFTER Harness resolves expressions but BEFORE deployment

set -e

echo "=================================================="
echo "🎯 Harness Post-Hook: Helm Chart Validation"
echo "=================================================="

# Configuration
BASE_DIR="/opt/harness-delegate/repository/helm/source"
CHART_NAME="<+pipeline.stages.deploy_stage.spec.manifests.nativehelm.chartName>"

# Find the chart directory (Harness has already fetched it)
CHART_DIR=$(find "$BASE_DIR" -maxdepth 2 -type d -name "$CHART_NAME" 2>/dev/null | head -n 1)

if [[ -z "$CHART_DIR" ]]; then
  echo "❌ Chart directory not found: $CHART_NAME"
  echo "   Searched in: $BASE_DIR"
  exit 1
fi

echo "✅ Found chart: $CHART_DIR"
echo ""

# Create a temporary values file with Harness-resolved values
# At this point, Harness has already resolved all expressions
# In this example, only replicaCount is an expression
TEMP_VALUES=$(mktemp)

cat > "$TEMP_VALUES" <<EOF
replicaCount: <+pipeline.variables.replicas>
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
minReplicas: 2
maxReplicas: 10
EOF

echo "📝 Resolved values file created"
echo ""

# Step 1: Lint the chart with resolved values
echo "🔍 Step 1/3: Running helm lint..."
if helm lint "$CHART_DIR" --values "$TEMP_VALUES"; then
    echo "✅ Helm lint passed"
else
    echo "❌ Helm lint failed!"
    rm -f "$TEMP_VALUES"
    exit 1
fi
echo ""

# Step 2: Template the chart to validate rendering
echo "🔍 Step 2/3: Validating template rendering..."
RENDERED_MANIFESTS=$(mktemp)
if helm template <+release.name> "$CHART_DIR" \
    --values "$TEMP_VALUES" \
    --namespace <+env.name> > "$RENDERED_MANIFESTS"; then
    echo "✅ Template rendering successful"
else
    echo "❌ Template rendering failed!"
    rm -f "$TEMP_VALUES" "$RENDERED_MANIFESTS"
    exit 1
fi
echo ""

# Step 3: Validate manifests against Kubernetes API
echo "🔍 Step 3/3: Validating against Kubernetes cluster..."
if kubectl apply --dry-run=server --validate=true -f "$RENDERED_MANIFESTS"; then
    echo "✅ Kubernetes validation passed"
else
    echo "❌ Kubernetes validation failed!"
    rm -f "$TEMP_VALUES" "$RENDERED_MANIFESTS"
    exit 1
fi
echo ""

# Cleanup
rm -f "$TEMP_VALUES" "$RENDERED_MANIFESTS"

echo "=================================================="
echo "✅ All validations passed!"
echo "   - Helm lint: ✅"
echo "   - Template rendering: ✅"
echo "   - Kubernetes validation: ✅"
echo "=================================================="
echo ""
echo "Proceeding with deployment..."

