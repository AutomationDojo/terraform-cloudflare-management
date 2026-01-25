#!/bin/bash
# Script to encrypt tunnel credentials using SOPS
# Usage: encrypt-sops.sh <output_file> [sops_config_file]
# Reads JSON content from stdin

set -e

# Check if sops is installed
if ! command -v sops &> /dev/null; then
  echo "Error: sops command not found" >&2
  exit 1
fi

# Validate arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <output_file> [sops_config_file]" >&2
  echo "JSON content should be provided via stdin" >&2
  exit 1
fi

OUTPUT_FILE="$1"
SOPS_CONFIG="${2:-}"

# Function to resolve path (handles both absolute and relative)
resolve_path() {
  local path="$1"
  case "$path" in
    /*) echo "$path" ;;  # Already absolute
    *) 
      # Relative path - resolve from current directory
      if command -v realpath &> /dev/null; then
        realpath -m "$path" 2>/dev/null || {
          local dir=$(cd "$(dirname "$path")" && pwd)
          echo "$dir/$(basename "$path")"
        }
      else
        # Fallback: use cd/pwd
        local dir=$(cd "$(dirname "$path")" && pwd)
        echo "$dir/$(basename "$path")"
      fi
      ;;
  esac
}

# Resolve absolute paths
abs_outfile=$(resolve_path "$OUTPUT_FILE")

# Resolve SOPS config file if provided
if [ -n "$SOPS_CONFIG" ]; then
  abs_config=$(resolve_path "$SOPS_CONFIG")
  # Verify config file exists
  if [ ! -f "$abs_config" ]; then
    echo "Error: SOPS config file not found: $abs_config" >&2
    echo "Tried to resolve from: $SOPS_CONFIG" >&2
    exit 1
  fi
fi

# Create temporary file
tmpfile=$(mktemp)
trap "rm -f $tmpfile" EXIT

# Read JSON content from stdin and write to temporary file
cat > "$tmpfile"

# Build SOPS command
sops_cmd="sops --encrypt --input-type json --output-type json --filename-override \"$abs_outfile\""
if [ -n "$SOPS_CONFIG" ]; then
  sops_cmd="$sops_cmd --config \"$abs_config\""
fi

# Encrypt the file
eval "$sops_cmd" "$tmpfile" > "$abs_outfile" || {
  echo "Error: SOPS encryption failed" >&2
  exit 1
}

# Set proper permissions
chmod 600 "$abs_outfile"

echo "Successfully encrypted tunnel credentials to: $abs_outfile"
