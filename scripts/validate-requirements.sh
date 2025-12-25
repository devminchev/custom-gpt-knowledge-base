#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
log_dir="$repo_root/reports"
log_file="$log_dir/requirement-counts.log"
index_file="$repo_root/index/verified-product-requirement-counts.yaml"

mkdir -p "$log_dir"

requirement_files=(
  "$repo_root/projects/game-release-automation/product/03-requirements/game-release-product-requirements.md"
  "$repo_root/projects/advanced-search/product/03-requirements/product-requirements.md"
)

declare -A requirement_projects=(
  ["$repo_root/projects/game-release-automation/product/03-requirements/game-release-product-requirements.md"]="game_release_automation"
  ["$repo_root/projects/advanced-search/product/03-requirements/product-requirements.md"]="advanced_search"
)

read_expected_counts() {
  local project="$1"

  awk -v project="$project" '
    function indent_len(line) {
      match(line, /^[[:space:]]*/)
      return RLENGTH
    }
    $1 == "projects:" { in_projects=1; projects_indent=indent_len($0); next }
    in_projects && $1 == project ":" {
      in_project=1
      project_indent=indent_len($0)
      next
    }
    in_project {
      current_indent=indent_len($0)
      if (current_indent <= project_indent && $1 ~ /^[a-z_]+:$/) {
        in_project=0
        in_counts=0
      }
    }
    in_project && $1 == "moscow_counts:" {
      in_counts=1
      counts_indent=indent_len($0)
      next
    }
    in_counts {
      current_indent=indent_len($0)
      if (current_indent <= counts_indent && $1 !~ /^(must|should|could|wont|total):/) {
        in_counts=0
      }
    }
    in_project && in_counts && $1 ~ /^(must|should|could|wont|total):/ {
      key=$1; gsub(":", "", key); counts[key]=$2
    }
    END {
      if (length(counts) == 0) exit 1
      printf "%s %s %s %s %s\n", counts["must"], counts["should"], counts["could"], counts["wont"], counts["total"]
    }
  ' "$index_file"
}

read_footer_counts() {
  local file="$1"

  awk '
    $1 == "verified:" { in_verified=1; next }
    in_verified && $1 == "verified_moscow_counts:" { in_counts=1; next }
    in_counts && $1 ~ /^(must|should|could|wont|total):/ {
      key=$1; gsub(":", "", key); counts[key]=$2
    }
    END {
      if (length(counts) == 0) exit 2
      printf "%s %s %s %s %s\n", counts["must"], counts["should"], counts["could"], counts["wont"], counts["total"]
    }
  ' "$file"
}

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
  project="${requirement_projects[$file]:-}"

  {
    echo "File: ${file#$repo_root/}"
    echo "  must: $must"
    echo "  should: $should"
    echo "  could: $could"
    echo "  wont: $wont"
    echo "  total: $total"
    echo
  } | tee -a "$log_file"

  if [[ -n "$project" ]]; then
    if ! expected=$(read_expected_counts "$project"); then
      echo "Missing expected counts for project: $project" | tee -a "$log_file"
      exit 1
    fi

    read -r exp_must exp_should exp_could exp_wont exp_total <<< "$expected"
    if [[ "$must" -ne "$exp_must" || "$should" -ne "$exp_should" || "$could" -ne "$exp_could" || "$wont" -ne "$exp_wont" || "$total" -ne "$exp_total" ]]; then
      {
        echo "Count mismatch for ${file#$repo_root/} (index/verified-product-requirement-counts.yaml)"
        echo "  expected: must=$exp_must should=$exp_should could=$exp_could wont=$exp_wont total=$exp_total"
        echo "  actual:   must=$must should=$should could=$could wont=$wont total=$total"
      } | tee -a "$log_file"
      exit 1
    fi

    if footer=$(read_footer_counts "$file" 2>/dev/null); then
      read -r foot_must foot_should foot_could foot_wont foot_total <<< "$footer"
      if [[ "$must" -ne "$foot_must" || "$should" -ne "$foot_should" || "$could" -ne "$foot_could" || "$wont" -ne "$foot_wont" || "$total" -ne "$foot_total" ]]; then
        {
          echo "Count mismatch for ${file#$repo_root/} (verified_moscow_counts footer)"
          echo "  footer: must=$foot_must should=$foot_should could=$foot_could wont=$foot_wont total=$foot_total"
          echo "  actual: must=$must should=$should could=$could wont=$wont total=$total"
        } | tee -a "$log_file"
        exit 1
      fi
    else
      echo "Missing verified_moscow_counts footer for ${file#$repo_root/}" | tee -a "$log_file"
      exit 1
    fi
  fi
done

echo "Log written to $log_file"
