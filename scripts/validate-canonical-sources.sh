#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
log_dir="$repo_root/reports"
log_file="$log_dir/canonical-sources.log"

mkdir -p "$log_dir"

canonical_sources_file="$repo_root/index/canonical-sources.yaml"
knowledge_index_file="$repo_root/index/knowledge-index.yaml"

if [[ ! -f "$canonical_sources_file" ]]; then
  echo "Missing canonical sources index: $canonical_sources_file" | tee "$log_file"
  exit 1
fi

if [[ ! -f "$knowledge_index_file" ]]; then
  echo "Missing knowledge index: $knowledge_index_file" | tee -a "$log_file"
  exit 1
fi

if ! git rev-parse --verify origin/main >/dev/null 2>&1; then
  echo "Missing origin/main reference; ensure fetch-depth is sufficient." | tee -a "$log_file"
  exit 1
fi

extract_paths() {
  local file="$1"

  awk '
    function indent_len(line) {
      match(line, /^[[:space:]]*/)
      return RLENGTH
    }
    /^[[:space:]]*priority_order:/ {
      in_priority=1
      priority_indent=indent_len($0)
      next
    }
    {
      current_indent=indent_len($0)
      if (in_priority && current_indent <= priority_indent && $0 !~ /^[[:space:]]*-[[:space:]]+/) {
        in_priority=0
      }
    }
    match($0, /^[[:space:]]*-[[:space:]]+[^#]+$/) {
      if (in_priority) next
      val=$0
      sub(/^[[:space:]]*-[[:space:]]+/, "", val)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
      print val
    }
    match($0, /:[[:space:]]+[^#]+$/) {
      split($0, parts, ":")
      val=parts[2]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
      if (val ~ /\//) print val
    }
  ' "$file" | sed 's/^"//; s/"$//' | sort -u
}

{
  echo "Canonical sources validation run: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo "Repository: $repo_root"
  echo
} > "$log_file"

paths=()
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  paths+=("$path")
done < <(cat <(extract_paths "$canonical_sources_file") <(extract_paths "$knowledge_index_file") | sort -u)

if [[ "${#paths[@]}" -eq 0 ]]; then
  echo "No canonical paths found to validate." | tee -a "$log_file"
  exit 1
fi

for path in "${paths[@]}"; do
  if [[ "$path" =~ ^https?:// ]]; then
    continue
  fi

  full_path="$repo_root/$path"
  path_no_slash="${path%/}"
  if [[ "$path" == */ ]]; then
    if [[ ! -d "$full_path" ]]; then
      echo "Missing directory: $path" | tee -a "$log_file"
      exit 1
    fi
    if [[ -z "$(git ls-tree -d --name-only origin/main "$path_no_slash")" ]]; then
      echo "Missing directory in origin/main: $path" | tee -a "$log_file"
      exit 1
    fi
  else
    if [[ ! -f "$full_path" ]]; then
      echo "Missing file: $path" | tee -a "$log_file"
      exit 1
    fi
    if ! git show "origin/main:$path" >/dev/null 2>&1; then
      echo "Missing file in origin/main: $path" | tee -a "$log_file"
      exit 1
    fi
  fi
done

echo "Canonical sources validated: ${#paths[@]} paths" | tee -a "$log_file"
echo "Log written to $log_file"
