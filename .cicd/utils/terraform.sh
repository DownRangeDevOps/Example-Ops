#! /usr/bin/env bash

function get_changed_modules() {
  THIS_SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")"
  GIT_TOPLEVEL="$(git rev-parse --show-toplevel 2>/dev/null)"

  if [[ -z ${THIS_SCRIPT_PATH} ]]; then
    THIS_SCRIPT_PATH="${PWD}"
  fi

  # shellcheck disable=SC1091
  source "${THIS_SCRIPT_PATH}/git.sh" # load git helpers

  parse_git_for_changed_path ".*/terraform/modules/.*\.tf$"
  parse_git_for_changed_path ".*/terraform/environments/.*\.tf$"
}

function parse_git_for_changed_path() {
  git -C "${GIT_TOPLEVEL}" diff --diff-filter ACMRT --name-only "$(git_master_or_main)" |
    grep -E --color=never "${1}" |
    xargs -n 1 dirname 2>/dev/null |
    sort -u |
    sed -E "s,(.*),${GIT_TOPLEVEL}/\1,"
}

function main() {
  if declare -f "$1" >/dev/null; then
    "$@"
  else
    echo "'$1' is not a known function name" >&2
    exit 1
  fi
}

main "$1"
