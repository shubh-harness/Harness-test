#!/bin/bash
# Test script 1: Pre-deployment lint (FAILS with expressions)
# This simulates running helm lint BEFORE Harness resolves expressions

set -e

echo "=================================================="
echo "TEST 1: Pre-Deployment Lint (Before Expression Resolution)"
echo "=================================================="
echo ""
echo "This simulates running helm lint during PREPARE stage"
echo "where Harness expressions are NOT yet resolved."
echo ""

CHART_DIR="$(dirname "$0")"

echo "📂 Chart directory: $CHART_DIR"
echo ""

echo "🔍 Running helm lint on chart with unresolved expressions..."
echo ""

# This will likely fail or give warnings about invalid values
if helm lint "$CHART_DIR" 2>&1; then
    echo ""
    echo "✅ Helm lint passed (but expressions are NOT validated!)"
    echo "⚠️  Note: Helm lint cannot validate expression syntax like <+artifact.tag>"
else
    echo ""
    echo "❌ Helm lint failed!"
    echo "This is expected when values contain Harness expressions"
fi

echo ""
echo "=================================================="
echo "🔍 Let's see what helm template produces with raw expressions:"
echo "=================================================="
echo ""

# Try to template - this will show unresolved expressions
helm template test-release "$CHART_DIR" 2>&1 | head -50 || true

echo ""
echo "📌 CONCLUSION:"
echo "   - Helm lint cannot validate Harness expressions"
echo "   - Values like '<+artifact.tag>' are treated as strings"
echo "   - No validation of actual deployment viability"

