#!/bin/bash
set -euo pipefail

# Configuration
MERGE_SECRETS=${MERGE_SECRETS:-true}
MERGE_CONFIGMAPS=${MERGE_CONFIGMAPS:-false}
DEBUG=${DEBUG:-false}

MANIFESTS=$(cat)
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "$MANIFESTS" > "$TEMP_DIR/input.yaml"

[[ "$DEBUG" == "true" ]] && echo "Processing manifests for secret merging..." >&2

# Simple pass-through for now - in real scenarios, this would merge secrets
cat "$TEMP_DIR/input.yaml"
