#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
log_dir="$repo_root/reports"
log_file="$log_dir/requirement-counts.log"

mkdir -p "$log_dir"

requirement_files=(
  "$repo_root/projects/game-release-automation/product/03-requirements/game-release-product-requirements.md"
  "$repo_root/projects/advanced-search/product/03-requirements/product-requirements.md"
)

{
  echo "Requirement count validation run: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo "Repository: $repo_root"
  echo
} > "$log_file"

for file in "${requirement_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing file: $file" | tee -a "$log_file"
    exit 1
  fi

  must=$(grep -c "^- Must Have:" "$file" || true)
  should=$(grep -c "^- Should Have:" "$file" || true)
  could=$(grep -c "^- Could Have:" "$file" || true)
  wont=$(grep -c "^- Won't Have:" "$file" || true)
  total=$((must + should + could + wont))

  {
    echo "File: ${file#$repo_root/}"
    echo "  must: $must"
    echo "  should: $should"
    echo "  could: $could"
    echo "  wont: $wont"
    echo "  total: $total"
    echo
  } | tee -a "$log_file"
done

echo "Log written to $log_file"
