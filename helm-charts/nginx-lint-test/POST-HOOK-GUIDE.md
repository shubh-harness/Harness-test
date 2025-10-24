# Harness Post-Hook Scripts for Helm Lint

## Problem You're Facing

Your original script failed because the hardcoded path doesn't match your actual Harness environment:

```bash
# Your script used:
BASE_DIR="/opt/harness-delegate/repository/helm/source"

# But Harness is actually using:
/Users/shubh/harness/harness-core/repository/helm/source/...
```

## Solution: Use These Scripts

### 1️⃣ **START HERE: Debug Script** (Recommended First Step)

**File:** `post-hook-debug.sh`

**Use this to understand your Harness environment:**
- Shows current working directory
- Lists available files and directories
- Finds Chart.yaml location
- Shows environment variables
- **Doesn't fail** - just provides information

**Steps:**
1. Upload `post-hook-debug.sh` as your post-hook
2. Run your pipeline
3. Check the execution logs
4. You'll see exactly where Harness puts the chart
5. Then use the appropriate script below

---

### 2️⃣ **Simple Script** (Works in Most Cases)

**File:** `post-hook-simple.sh`

**Features:**
- ✅ Uses relative paths (works regardless of base directory)
- ✅ Checks current directory first
- ✅ Searches up to 3 levels for Chart.yaml
- ✅ Minimal dependencies

**Use when:**
- Your debug script shows Chart.yaml is nearby (within 2-3 directory levels)
- You want a simple, maintainable solution

---

### 3️⃣ **Robust Script** (Handles Complex Environments)

**File:** `post-hook-robust.sh`

**Features:**
- ✅ Tries multiple common base directories
- ✅ Searches by chart name (from Harness expression)
- ✅ Falls back to finding Chart.yaml
- ✅ Detailed logging and debugging output

**Use when:**
- You have multiple delegates with different paths
- Your environment varies (local testing vs cloud delegates)
- You need comprehensive error messages

---

## Quick Start Guide

### Step 1: Debug Your Environment
```bash
# In Harness:
1. Go to your service → Hooks → Add Post-Deployment Hook
2. Upload: post-hook-debug.sh
3. Run your pipeline
4. Check logs to see where Chart.yaml is located
```

### Step 2: Choose Your Script

**If Chart.yaml is in current directory or nearby:**
→ Use `post-hook-simple.sh`

**If Chart.yaml is in a complex path or varies by environment:**
→ Use `post-hook-robust.sh`

### Step 3: Test with Your Chart

```bash
# The chart has intentional lint issues:
# - Missing selector in broken-deployment.yaml

# When post-hook runs, helm lint will FAIL (expected behavior)
# This proves the validation is working!
```

---

## Expected Behavior

### ✅ With Working Chart (all issues commented out):
```
🔍 Running: helm lint .
==> Linting .
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed

✅ Helm lint PASSED!
```

### ❌ With Broken Chart (current state):
```
🔍 Running: helm lint .
==> Linting .
[INFO] Chart.yaml: icon is recommended
[ERROR] templates/: missing required field 'selector'

Error: 1 chart(s) linted, 1 chart(s) failed

❌ Helm lint FAILED!
```

**This will stop the deployment before it fails in the cluster!**

---

## Troubleshooting

### Error: "Chart directory not found"
1. Run `post-hook-debug.sh` first
2. Check logs for actual directory structure
3. Modify `POSSIBLE_DIRS` in `post-hook-robust.sh` if needed

### Error: "helm: command not found"
- Helm is not installed on your delegate
- Install helm on the delegate or use a delegate with helm pre-installed

### Error: "Expression not resolved"
- Make sure the expression syntax matches your pipeline:
  ```
  <+pipeline.stages.YOUR_STAGE_NAME.spec.manifests.nativehelm.chartName>
  ```
- Check stage name is correct

### Hook runs but doesn't fail deployment
- Check your hook is configured as **Post-Deployment Hook**
- Ensure script exits with code 1 on failure: `exit 1`

---

## Files in This Chart

```
nginx-lint-test/
├── Chart.yaml
├── values.yaml (with expression: replicaCount: <+pipeline.variables.replicas>)
├── templates/
│   ├── deployment.yaml (working)
│   ├── service.yaml (working)
│   ├── configmap.yaml (working)
│   └── broken-deployment.yaml (has lint issues)
├── post-hook-debug.sh       ← Start here
├── post-hook-simple.sh       ← Use for simple cases
├── post-hook-robust.sh       ← Use for complex environments
└── POST-HOOK-GUIDE.md        ← This file
```

---

## Next Steps for Papa John's

1. ✅ Test with `post-hook-debug.sh` to understand their environment
2. ✅ Deploy with `post-hook-simple.sh` or `post-hook-robust.sh`
3. ✅ Verify lint failures block deployments
4. ✅ Add to approval workflow:
   - Helm lint validation (post-hook)
   - Manual approval
   - Deployment

This gives them **lint validation + approval** before any deployment!

