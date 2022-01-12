#!/bin/bash

ASM_VERSION=1.12.0-asm.4

docker pull gcr.io/gke-release/asm/pilot:${ASM_VERSION}
docker pull gcr.io/gke-release/asm/proxyv2:${ASM_VERSION}

docker tag gcr.io/gke-release/asm/pilot:${ASM_VERSION} gcr.io/${PROJECT_ID}/asm/pilot:${ASM_VERSION}
docker tag gcr.io/gke-release/asm/proxyv2:${ASM_VERSION} gcr.io/${PROJECT_ID}/asm/proxyv2:${ASM_VERSION}

docker push gcr.io/${PROJECT_ID}/asm/pilot:${ASM_VERSION}
docker push gcr.io/${PROJECT_ID}/asm/proxyv2:${ASM_VERSION}

_CI_ASM_IMAGE_LOCATION=gcr.io/${PROJECT_ID}/asm