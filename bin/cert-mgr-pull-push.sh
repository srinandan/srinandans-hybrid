#!/bin/bash
CERT_MANAGER_VER="v1.5.4"
docker pull quay.io/jetstack/cert-manager-controller:${CERT_MANAGER_VER}
docker pull quay.io/jetstack/cert-manager-cainjector:${CERT_MANAGER_VER}
docker pull quay.io/jetstack/cert-manager-webhook:${CERT_MANAGER_VER}

docker tag quay.io/jetstack/cert-manager-controller:${CERT_MANAGER_VER} gcr.io/${PROJECT_ID}/cert-manager-controller:${CERT_MANAGER_VER}
docker tag quay.io/jetstack/cert-manager-cainjector:${CERT_MANAGER_VER} gcr.io/${PROJECT_ID}/cert-manager-cainjector:${CERT_MANAGER_VER}
docker tag quay.io/jetstack/cert-manager-webhook:${CERT_MANAGER_VER} gcr.io/${PROJECT_ID}/cert-manager-webhook:${CERT_MANAGER_VER}

docker push gcr.io/${PROJECT_ID}/cert-manager-controller:${CERT_MANAGER_VER}
docker push gcr.io/${PROJECT_ID}/cert-manager-cainjector:${CERT_MANAGER_VER}
docker push gcr.io/${PROJECT_ID}/cert-manager-webhook:${CERT_MANAGER_VER}
