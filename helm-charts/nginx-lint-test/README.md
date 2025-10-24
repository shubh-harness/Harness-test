# Helm Chart Lint Testing with Harness Expressions

This chart demonstrates the challenge of linting Helm charts that contain Harness expressions and provides the recommended solution.

## The Problem

Papa John's wants to lint their Helm charts before deployment, but Harness expressions like `<+artifact.tag>` are not resolved until the Apply stage. Running `helm lint` in the Prepare stage fails because expressions are treated as invalid values.

## Chart Contents

This test chart includes:
- **values.yaml**: Contains Harness expressions (`<+artifact.tag>`, `<+env.name>`, etc.)
- **Templates**: Deployment, Service, and ConfigMap using these values
- **Test Scripts**: Demonstrate the problem and solution

## The Issue: Expression Resolution Timing

### Prepare Stage ❌
- Harness fetches the chart
- Expressions are **NOT** resolved yet
- `helm lint` sees `<+artifact.tag>` as a literal string
- Cannot validate actual deployment viability

### Apply Stage ✅
- Harness resolves all expressions to actual values
- `<+artifact.tag>` becomes `nginx:1.21.6`
- Now we can properly validate the chart

## Testing Approaches

### Test 1: Pre-Deployment Lint (Fails)
```bash
chmod +x test-pre-deployment-lint.sh
./test-pre-deployment-lint.sh
```

**Shows:**
- Helm lint cannot validate Harness expressions
- Expressions appear as strings in the output
- No real validation of deployment readiness

### Test 2: Post-Render Validation (Works)
```bash
chmod +x test-post-render-lint.sh
./test-post-render-lint.sh
```

**Shows:**
- With resolved values, helm lint works correctly
- Can template and validate rendered manifests
- Can use `kubectl --dry-run` for full validation

## Recommended Solution: Post-Hook Script

Use the provided `harness-post-hook-script.sh` as a **Post-Deployment Hook** in Harness:

### Why Post-Hook?
1. ✅ Runs AFTER expression resolution
2. ✅ Runs BEFORE actual deployment (can still fail safely)
3. ✅ Has access to delegate tools (helm, kubectl)
4. ✅ Three-stage validation:
   - Helm lint (chart structure)
   - Helm template (rendering)
   - kubectl dry-run (cluster validation)

### Configuration in Harness

1. **Go to**: Service → Configuration → Hooks
2. **Add Post-Deployment Hook**
3. **Script**: Upload `harness-post-hook-script.sh`
4. **Runs on**: Delegate
5. **Timing**: After rendering, before deployment

### Pipeline Variables Required

For this simplified example, only one pipeline variable is needed:
```yaml
replicas: 3
```

All other values (namespace, image, resources, etc.) are hardcoded in values.yaml for simplicity.

### What Gets Validated

1. **Helm Lint**: Chart structure, template syntax
2. **Helm Template**: Successful rendering with actual values
3. **kubectl --dry-run=server**: 
   - Valid Kubernetes resources
   - API version compatibility
   - Resource quota checks
   - Admission controller validation

## Alternative: Command Flags (Not Recommended)

You cannot use command flags effectively because:
- Command flags run during `helm install/upgrade`
- At that point, it's too late to fail gracefully
- Post-renderer is for modifying manifests, not validation
- Pre-deployment hooks run on cluster, not delegate

## Comparison

| Approach | When | Expressions | Tools Available | Can Fail Safely |
|----------|------|-------------|-----------------|-----------------|
| Service Hook (Pre) | Prepare | ❌ Not resolved | helm, kubectl | ✅ Yes |
| **Post-Hook** | **Apply** | **✅ Resolved** | **helm, kubectl** | **✅ Yes** |
| Command Flags | During Install | ✅ Resolved | helm only | ❌ Messy |
| Post-Renderer | During Install | ✅ Resolved | stdin/stdout | ❌ Not for validation |

## Testing in Harness

1. Create a pipeline with this chart
2. Add the post-hook script
3. Set pipeline variables
4. Deploy to see validation in action
5. Intentionally break something (wrong tag, invalid CPU) to see it fail

## Conclusion

**Use Post-Hook for validation** - it's the only approach that:
- Has resolved expressions
- Can validate properly
- Fails before actual deployment
- Provides comprehensive validation (lint + template + k8s)

