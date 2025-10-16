# HPA AmbiguousSelector Issue Reproduction

This reproduction demonstrates the AmbiguousSelector issue that occurs during canary deployments when multiple HPAs attempt to control the same set of pods.

## Problem Description

During a Kubernetes Canary deployment, Harness creates a canary Deployment and a canary HPA. The cluster already has an HPA from the chart that targets the stable Deployment. 

**Root Cause:**
- Stable Deployment selector: `app=wibed-edocssettings-api` (broad selector, no track qualifier)
- Canary Deployment selector: `app=wibed-edocssettings-api, harness.io/track=canary` (specific selector)
- Both HPAs end up selecting the same canary pods because the stable selector is too broad

**Result:**
Kubernetes raises `AmbiguousSelector` error and fails HPA reconciliation for the canary with warning:
```
Warning ambiguity. pods by selector app=wibed-edocssettings-api,harness.io/track=canary are controlled by multiple HPAs: [wibed-prod/wibed-edocssettings-api-hpa wibed-prod/wibed-edocssettings-api-hpa-canary]
```

## Files Structure

- `stable-deployment.yaml` - Stable deployment with broad selector
- `stable-hpa.yaml` - HPA targeting stable deployment
- `canary-deployment.yaml` - Canary deployment with specific selector  
- `canary-hpa.yaml` - HPA targeting canary deployment
- `service.yaml` - Service for the application

## How to Reproduce

1. Apply the stable resources first:
   ```bash
   kubectl apply -f stable-deployment.yaml
   kubectl apply -f stable-hpa.yaml
   kubectl apply -f service.yaml
   ```

2. Wait for stable deployment to be ready, then apply canary resources:
   ```bash
   kubectl apply -f canary-deployment.yaml
   kubectl apply -f canary-hpa.yaml
   ```

3. Check HPA status to see the AmbiguousSelector error:
   ```bash
   kubectl get hpa
   kubectl describe hpa wibed-edocssettings-api-hpa-canary
   ```

## Expected Behavior

You should see warnings about ambiguous pod selectors and HPA reconciliation failures for the canary HPA.
