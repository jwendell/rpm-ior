#!/bin/bash

# WARNING: DO NOT EDIT, THIS FILE IS PROBABLY A COPY
#
# The original version of this file is located in the https://github.com/maistra/rpm-common repo.
# If you're looking at this file in a different repo and want to make a change, please go to the
# rpm-common repo, make the change there and check it in. Then come back to this repo and run
# "make update-common".

# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o pipefail
set -e
set -u

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck disable=SC1090
source "${SCRIPTPATH}/utils.sh"

DEFAULT_BRANCH=${DEFAULT_BRANCH:-"maistra-1.1"}

function usage() {
    echo "Update references of upstream to build a new version of RPM"
    echo
    echo "Usage: $0 [commit|tag|branch]"
    echo
    echo
    echo "Without any argument, it grabs the HEAD of the default branch (${DEFAULT_BRANCH})"
    echo "If there is an argument, it will be used to fetch the tarball. It can be a commit, tag or a branch name"
    echo
    echo "The special value 'spec' will use the SHA specified by the variable 'git_commit' in the .spec file"
    echo "This essentially only downloads the source tarball so that a SRPM can be created"
    exit "${1:-1}"
}

function validate_args() {
  if [ $# -gt 1 ]; then
    usage 1
  fi

  local arg="${1:-}"

  if [ "${arg}" == "-h" ] || [ "${arg}" == "--help" ]; then
    usage 0
  fi

  if [[ ${arg} == -* ]]; then
    usage 1
  fi

  REPO=${REPO:-"$(guess_repo_name)"}
  if [ -z "${REPO}" ]; then
    echo "Unknown repository. Please set the REPO variable."
    exit 1
  fi

  if [ "${arg}" == "spec" ]; then
    arg="$(grep '%global git_commit ' "${REPO}.spec" | awk '{print $3}')"
  fi

  COMMIT="${arg:-${DEFAULT_BRANCH}}"

  echo "Updating repo ${REPO} using committish ${COMMIT}"
}

function download_tarball() {
  TMP_DIR=$(mktemp -d)
  pushd "${TMP_DIR}" >/dev/null

  git clone --quiet "https://github.com/maistra/${REPO}.git"
  pushd "${REPO}" >/dev/null
  git checkout --quiet "${COMMIT}"

  SHA=$(git rev-parse HEAD)
  if [ "${SHA}" != "${COMMIT}" ]; then
    echo "Commitish ${COMMIT} resolved to SHA ${SHA}"
  fi

  rm -rf .git
  popd >/dev/null

  REPO_SHA="${REPO}-${SHA}"
  mv "${REPO}" "${REPO_SHA}"
  tar cfz "${REPO_SHA}.tar.gz" "${REPO_SHA}"
  popd >/dev/null

  mv "${TMP_DIR}/${REPO_SHA}.tar.gz" .
}

function update_spec_and_sources() {
  sed -i "s/%global git_commit .*/%global git_commit ${SHA}/" "${REPO}".spec
  md5sum "${REPO_SHA}.tar.gz" > sources
}

function export_globals() {
  export SHA
}

function run_local_update() {
  if [ -x "./update-local.sh" ]; then
    echo "Running update-local.sh"
    export_globals

    ./update-local.sh
  else
    echo "Skipping update-local.sh"
  fi
}

cleanup() {
  rm -rf "${TMP_DIR:-}"
}

main () {
  trap cleanup EXIT

  validate_args "$@"
  download_tarball
  update_spec_and_sources
  run_local_update
}

main "$@"
