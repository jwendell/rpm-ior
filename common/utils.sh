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

function guess_repo_name() {
  local dir_name

  dir_name="$(basename "$(pwd)")"
  if [[ ${dir_name} == rpm-* ]]; then
    echo "${dir_name#rpm-}"
  fi
}
