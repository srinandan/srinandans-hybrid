#!/usr/bin/env bash

# Exit immediately if sequence of one or more commands returns a non-zero status.
set -e

PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

# shellcheck disable=SC1090
source "${PWD}/common.sh"

TAG=${APIGEE_VERSION}
REPO=$1

APIGEE_COMPONENTS=("apigee-authn-authz" "apigee-mart-server" "apigee-synchronizer" "apigee-runtime" "apigee-hybrid-cassandra-client" "apigee-hybrid-cassandra" "apigee-cassandra-backup-utility" "apigee-udca" "apigee-connect-agent" "apigee-watcher" "apigee-operators" "apigee-installer" "apigee-redis" "apigee-diagnostics-collector" "apigee-diagnostics-runner")
THIRD_PARTY_COMPONENTS=("apigee-stackdriver-logging-agent:1.8.9" "apigee-prom-prometheus:v2.25.0" "apigee-stackdriver-prometheus-sidecar:0.9.0" "apigee-kube-rbac-proxy:v0.8.0" "apigee-envoy:v1.19.1")

#**
# @brief    Displays usage details.
#
usage() {
    log_info "$*\\n usage: $(basename "$0")" \
        "[repo where you want to push the images]\\n" \
        "Note: if the repo is not provided. It will be pushed to us.gcr.io/<PROJECT_ID>.\\n" \
        "      Please make sure you have gcloud installed as it uses for finding out PROJECT_ID\\n\\n" \
        "example: $(basename "$0") [foo.docker.com]"
}

#**
# @brief    Obtains GCP project ID from gcloud configuration and updates global variable PROJECT_ID.
#
get_project(){
    local project_id ret
    local msg="Provide GCP Project ID via command line arguments or update gcloud config: gcloud config set project <project_id>"

    project_id=$(gcloud config list core/project --format='value(core.project)'); ret=$?
    [[ ${ret} -ne 0 || -z "${project_id}" ]] && \
        usage "Failed to get project ID from gcloud config.\\n${msg}"

    log_info "gcloud configured project ID is ${project_id}.\\n" \
        "Press: y to proceed for pushing images in project: ${project_id}\\n" \
        "Press: n to abort."
    read -r prompt
    if [[ "${prompt}" != "y" ]]; then
        usage "Aborting.\\n${msg}"
        exit 0
    fi
    PROJECT_ID="${project_id}"
}

docker_exe() {
  local action=$1
  local repo=$2

  for i in "${APIGEE_COMPONENTS[@]}"
  do
    docker "${action}" "${repo}/$i:${TAG}"
  done

  for i in "${THIRD_PARTY_COMPONENTS[@]}"
  do
    docker "${action}" "${repo}/$i"
  done
}

docker_tag() {
  local source=$1
  local dest=$2

  for i in "${APIGEE_COMPONENTS[@]}"
  do
    docker tag "${source}/$i:${TAG}" "${dest}/$i:${TAG}"
  done

  for i in "${THIRD_PARTY_COMPONENTS[@]}"
  do
    docker tag "${source}/$i" "${dest}/$i"
  done
}

# check whether user had supplied -h or --help . If yes display usage
if [[ ( $* == "--help") ||  $* == "-h" ]]
then
  usage
  exit 0
fi

# Check gcloud config for project ID.
if [[ -z "${REPO}" ]]; then
  # Check gcloud is installed and on the $PATH.
  if ! which gcloud > /dev/null 2>&1; then
      log_error "gcloud is not installed or not on PATH."
  fi
  get_project
  REPO="us.gcr.io/${PROJECT_ID}"
fi

# Check docker is installed and on the $PATH.
if ! which docker > /dev/null 2>&1; then
    log_error "docker is not installed or not on PATH."
fi

# Pull all the images from the Google Docker Hub
docker_exe "pull" "google"
# tag the pulled images
docker_tag "google" "${REPO}"
# Push the images to the user defined repo.
docker_exe "push" "${REPO}"
