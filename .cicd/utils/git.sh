#! /usr/bin/env bash

function __git_is_repo() {
  git -C "${1}" rev-parse 2>/dev/null
}

function git_master_or_main() {
  if ! __git_is_repo "${PWD}"; then
    printf "%s\n" "${PWD} is not a git repository."
    return 1
  fi

  INITIAL_COMMIT="$(git rev-list --abbrev-commit HEAD | tail -n 1)"

  git show-ref --verify --quiet refs/heads/master
  MASTER_EXISTS="${?}"

  git show-ref --verify --quiet refs/heads/main
  MAIN_EXISTS="${?}"

  if [[ -z ${MASTER_EXISTS} && -z ${MAIN_EXISTS} ]]; then
    MASTER_LENGTH="$(git rev-list --count "${INITIAL_COMMIT}..master")"
    MAIN_LENGTH="$(git rev-list --count "${INITIAL_COMMIT}..main")"

    if [[ ${MASTER_LENGTH} -gt ${MAIN_LENGTH} ]]; then
      MAIN_BRANCH="main"
    else
      MAIN_BRANCH="master"
    fi
  elif [[ ${MAIN_EXISTS} ]]; then
    MAIN_BRANCH="main"
  elif [[ ${MASTER_EXISTS} ]]; then
    MAIN_BRANCH="master"
  else
    printf "%s\n" "This repository does not have a 'master' or 'main' branch!"
    exit 1
  fi

  printf "%s" "${MAIN_BRANCH}"
}
