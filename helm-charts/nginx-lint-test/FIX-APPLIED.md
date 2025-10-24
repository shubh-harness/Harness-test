# ✅ Fix Applied for Post-Hook Script

## The Problem

Your post-hook was failing with:
```
Current directory: /Users/shubh/harness/harness-core/repository/helm/source/UUID/.__harness_internal_hooks/post_TemplateManifest
❌ Chart.yaml not found!
```

## Root Cause

Harness runs post-hooks in a **special internal directory**:
```
/path/to/UUID/.__harness_internal_hooks/post_TemplateManifest/
```

The actual chart is **2 levels up** in the UUID directory:
```
/path/to/UUID/
  ├── Chart.yaml          ← The chart is here
  ├── values.yaml
  ├── templates/
  └── .__harness_internal_hooks/
      └── post_TemplateManifest/
          └── your-script.sh    ← Your script runs here
```

## The Fix

Updated both scripts to:
1. **Look up 2-3 directory levels** (using `../..` and `../../..`)
2. **Search from parent directories** instead of current directory
3. **Exclude `__harness_internal` directories** from search results

### post-hook-simple.sh ✅
```bash
# Now checks ../../Chart.yaml (2 levels up)
if [[ -f "../../Chart.yaml" ]]; then
  CHART_DIR="../.."
```

### post-hook-robust.sh ✅
```bash
# Prioritizes relative paths first
POSSIBLE_DIRS=(
  "../.."                    # Most likely location
  "../../.."
  ...
)
```

## How to Test

1. **Upload the updated `post-hook-simple.sh`** to Harness
2. Run your pipeline again
3. You should now see:
   ```
   ✅ Found Chart.yaml at: ../..
   🔍 Running: helm lint ../..
   ```

## Expected Result

Since your chart has a lint issue (missing selector in `broken-deployment.yaml`), you should see:

```
==> Linting ../..
[INFO] Chart.yaml: icon is recommended  
[ERROR] templates/broken-deployment.yaml: Deployment must have selector

Error: 1 chart(s) linted, 1 chart(s) failed

❌ Helm lint FAILED!
```

**This will block the deployment** - exactly what Papa John's needs! ✅

## To Test with a Passing Chart

Comment out the broken deployment:
```bash
mv templates/broken-deployment.yaml templates/broken-deployment.yaml.bak
```

Then helm lint will pass and deployment will proceed.

## Files Ready to Use

- ✅ `post-hook-simple.sh` - **Use this one** (clean and simple)
- ✅ `post-hook-robust.sh` - Backup option with more debugging
- ✅ `post-hook-debug.sh` - For troubleshooting if needed

All scripts now understand Harness's internal directory structure!

