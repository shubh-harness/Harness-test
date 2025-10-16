#!/bin/bash

# HPA AmbiguousSelector Issue Reproduction Test Script

echo "🔄 Starting HPA AmbiguousSelector reproduction test..."

# Step 1: Create namespace
echo "📁 Creating namespace..."

# Step 2: Apply stable resources first
echo "🚀 Deploying stable resources..."
kubectl apply -f stable-deployment.yaml
kubectl apply -f stable-hpa.yaml
kubectl apply -f service.yaml

echo "⏳ Waiting for stable deployment to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/wibed-edocssettings-api -n hpa

# Step 3: Apply canary resources (this should trigger the AmbiguousSelector issue)
echo "🐥 Deploying canary resources..."
kubectl apply -f canary-deployment.yaml
kubectl apply -f canary-hpa.yaml

echo "⏳ Waiting a moment for HPA reconciliation..."
sleep 10

# Step 4: Check for the AmbiguousSelector issue
echo ""
echo "📊 HPA Status:"
kubectl get hpa -n hpa

echo ""
echo "🔍 Checking for AmbiguousSelector warnings in canary HPA..."
kubectl describe hpa wibed-edocssettings-api-hpa-canary -n hpa | grep -A 5 -B 5 -i "ambiguous\|warning"

echo ""
echo "🔍 Checking events for AmbiguousSelector issues..."
kubectl get events -n hpa --field-selector reason=AmbiguousSelector

echo ""
echo "📋 Pod labels to verify the overlap:"
echo "Stable pods:"
kubectl get pods -n hpa -l app=wibed-edocssettings-api --show-labels | grep -v canary

echo ""
echo "Canary pods:"
kubectl get pods -n hpa -l harness.io/track=canary --show-labels

