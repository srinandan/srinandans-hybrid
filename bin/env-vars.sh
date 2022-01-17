#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#export ENV_NAME=prod1
export UC_ENV_NAME=$(echo "${ENV_NAME}" | awk '{print toupper($0)}')

orglen=${#ORG_NAME}

ORGHASH=$(printf "$ORG_NAME" | openssl dgst -sha256 | awk '{print $2}' | cut -c1-7)

export ORG=$ORGSHORTNAME-$ORGHASH

FULLNAME=$ORG_NAME:$ENV_NAME
envlen=${#ENV_NAME}
ENVHASH=$(printf "$FULLNAME" | openssl dgst -sha256 | awk '{print $2}' | cut -c1-7)

if [[ envlen -gt 15 ]]; then
  ENVSHORTNAME=`echo $ENV_NAME | cut -c1-15`
else
  ENVSHORTNAME=$ENV_NAME
fi

export ENV=$ORGSHORTNAME-$ENVSHORTNAME-$ENVHASH

