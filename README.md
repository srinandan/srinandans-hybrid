# srinandans-hybrid

This **experimental** repo contains Kubernetes manifests for [Apigee hybrid](https://cloud.google.com/apigee/docs/hybrid/v1.6/what-is-hybrid) runtime and explores the use of [Kustomize](https://kustomize.io/) for configuration management.

## Prerequisites

* A supported version of kubernetes cluster
* Apigee control plane entities like Organization, Environment & Environment Group exists
* A Google Service Account is created with appropriate roles/permissions. This
  repo assumes a single GSA for all components (udca, sync etc.)
* If not using workload identity, download the private key.

## Folder Structure

Creating an appropriate folder structure is key to using kustomize. The folder structure below isn't the only approach. Here is a brief explanation of the folders:

* `base`: This folder contains the Kubernetes manifests of ApigeeOrganization, ApigeeEnvironment, ApigeeDatastore and other components of the runtime. Within the folder, there are sub folders per namespace - `apigee`, `apigee-system` and `istio-system`
* `cluster`: This folder contains cluster level resources like `ClusterRoleBinding`, `CustomResourceDefinitions` etc
* `primary`: This folder contains a CA cert file which must only be executed in the primary cluster. If you have more than one region for the Apigee hybrid deployment, select one of the regions  as the primary.
* `overlays/templates`: This folder contains templates that are used to generate Kubernetes manifests
* `overlays/instance1`: Create a folder per Apigee Instance. `instance1` is a placeholder name. An Apigee instance is a Apigee hybrid runtime installed in a region or data center.
* `overlays/instance1/<sub folders>`: Each sub folder inside the `instance1` folder is a feature or property. They're enabled/disabled as necessary in an instance
* `overlays/instance1/environments/<env-name>`: There is a folder for each Apigee environment. Within each folder, there can be further sub-folders to enable/disable features per Apigee Environment.

```sh
.
├── base
│   ├── controller
│   │   ├── APIGEE CONTROLLER MANIFESTS
│   │   └── kustomization.yaml
│   ├── datastore
│   │   ├── DATA STORE MANIFESTS
│   │   └── kustomization.yaml
│   ├── environment
│   │   ├── ENV MANIFESTS
│   │   └── kustomization.yaml
│   ├── envoyfilters
│   │   ├── ISTIO MANIFESTS
│   │   └── kustomization.yaml
│   └── organization
│       ├── ORG MANIFESTS
│       └── kustomization.yaml
├── cluster
│   ├── crds
│   │   └── APIGEE CRDs
│   └── APIGEE CLUSTER RESOURCES
├── overlays
│   ├── controller
│   │   ├── CONTROLLER OVERLAYS
│   │   └── kustomization.tmpl
│   ├── instance1
│   │   ├── kustomization.yaml
│   │   ├── namespace.yaml
│   │   ├── cass-backup
│   │   │   ├── CASSANDRA BACKUP OVERLAYS
│   │   │   └── kustomization.yaml
│   │   ├── cass-replicas
│   │   │   ├── CASSANDRA REPLICA OVERLAYS
│   │   │   └── kustomization.yaml
│   │   ├── enable-host-network
│   │   │   └── kustomization.yaml
│   │   ├── envgroup
│   │   │   ├── INGRESS OVERLAYS
│   │   │   └── kustomization.yaml
│   │   ├── environments
│   │   │   └── <ENV>
│   │   │       ├── client_secret.json
│   │   │       ├── node-selector
│   │   │       │   ├── env-nodeselector.yaml
│   │   │       │   └── kustomization.yaml
│   │   │       ├── runtime-replicas
│   │   │       │   ├── kustomization.yaml
│   │   │       │   └── replicas.yaml
│   │   │       └── secrets
│   │   │           └── kustomization.yaml
│   │   ├── google-service-accounts
│   │   │   ├── client_secret.json
│   │   │   └── kustomization.yaml
│   │   ├── http-proxy
│   │   │   ├── HTTP PROXY OVERLAYS
│   │   │   └── kustomization.yaml
│   │   ├── logger
│   │   │   ├── LOGGER OVERLAYS
│   │   │   └── kustomization.yaml
│   │   ├── metrics
│   │   │   ├── METRICS OVERLAYS
│   │   │   └── kustomization.yaml
│   │   ├── multi-region
│   │   │   └── MULTI_REGION OVERLAYS
│   │   ├── node-selector
│   │   │   └── NODE SELECTOR OVERLAYS
│   │   ├── pullsecret
│   │   │   └── IMAGE PULL SECRET OVERLAYS
│   │   ├── runtime-replicas
│   │   │   ├── RUNTIME REPLICA OVERLAYS
│   │   │   └── kustomization.yaml
│   │   ├── secrets
│   │   │   └── kustomization.yaml
│   │   └── workload-identity
│   │       ├── WORKLOAD IDENTITY OVERLAYS
│   │       └── kustomization.yaml
│   └── templates
│       ├── annotate.tmpl
│       ├── apigee-cassandra-backup-cronjob.tmpl
│       ├── apigeerouteconfig.tmpl
│       ├── certificate.tmpl
│       ├── env-kustomization.tmpl
│       ├── env.tmpl
│       ├── logger.tmpl
│       ├── metrics.tmpl
│       ├── multi-region-kustomization.tmpl
│       ├── org-sa.tmpl
│       ├── org.tmpl
│       └── secrets.tmpl
├── primary
│   └── apigee-ca-certificate.yaml
└── vars.sh
```

## Setup Variables

Open the [vars.sh](./vars.sh) and [env-vars.sh](./env-vars.sh) to ensure the following variables are appropriately set:

* `ORG_NAME`: Apigee Organization name
* `ENV_NAME`: Apigee Environment name (in env-vars.sh)
* `ENV_GROUP`: Apigee Environment Group name
* `CLUSTER_REGION`: GCP Region for the Kubernetes cluster (or closest GCP region if running outside GCP)
* `CLUSTER_NAME`: Kubernetes cluster name
* `PROJECT_ID`: GCP Project Id
* `TAG`: Apigee hybrid version
* `INSTANCE_ID`: Apigee Instance name

## Install Order

Follow the instructions in [install.sh](./install.sh). If not using workload identity, download teh GSA private key. The file must be called `client_secret.json`. Place this file in `./overlay/instance1/environments/${ENV_NAME}`, `./overlay/instance1/google-service-accounts`

## Kustomize

Features and/properties of the installation can be modified by commenting or uncommenting the [kustomization.tmpl](./overlays/instance1/kustomization.tmpl) file. The following are enabled by default

```yaml
components:
# Node selectors are used
- node-selector
# workload identity is enabled
- workload-identity
# Generate default secrets for encryption, cassandra auth etc.
- secrets
# Generate ingress configuration via self-signed certs
- envgroup
# Enable Apigee metrics
- metrics

# Use Google Service accounts instead of workload identity
#- google-service-accounts

# Setup Apigee for multi-cluster deployments
#- multi-region

# Enable hostNetwork for Cassandra multi-region communication
#- enable-host-network

# ChangeCassandra replicas
#- cass-replicas

# Enable Cassandra backup
#- cass-backup
# Enable Apigee logger to send container logs to Cloud logging
#- logger

# Configure Image Pull Secrets for containers
#- pullsecret
```

The org kustomization file is generated via the script `generateOrgKustomize.sh`


The kustomize template for environments can be found
[here](./overlays/templates/env-kustomization.tmpl). The env kustomixation file
is generated via the script `generateEnvKustomize.sh`.


### Default Ingress Configuration

This installation generates a self-signed certificate, signed by the [Apigee
CA](./clusters/foo.yaml). The certificate template is
[here](./overlays/templates/certificate.tmpl)

### Add a new environment

These steps assume the Apigee Organization and other components are already installed.

1. Open the [env-vars.sh](./env-vars.sh) file and add the new environment name. Generate the environment variables.

```sh
source env-vars.sh
```

2. Create a new folder for the environment in the `./overlays/instances1/environments` folder.

```sh
mkdir ./overlays/instances1/environments/${ENV_NAME}
```

3. Copy any components to the new environment folder

```sh
cp -r ./overlays/instances1/environments/<OLD-ENV-NAME> ./overlays/instances1/environments/${ENV_NAME}
```

4. Generate the kustomize manifests for the environment

```sh
./generateEnvKustomize.sh
```

5. Apply the Kubernetes manifests

```sh
kubectl apply -k ./overlay/instance1/environments/${ENV_NAME}
```

### Adding a second region

In most cases, an Apigee Organization is identical across data centers or regions. In Apigee terms, an Apigee runtime deployment of an org is called an Apigee instance. Instances of an Org are typically identical.

1. Make a copy of all the files in the first instance to the new instance.

```sh
mkdir ./overlays/instance2

cp -r ./overlays/instance1/* ./overlays/instance2/
```

2. Modify the kustomization.yaml in new instance. Enable the multi-region feature.

```yaml
components:
- node-selector
- workload-identity
- secrets
- envgroup
- metrics
# Enable the following feature in the second and subsequent regions
- multi-region
# On platforms like GKE on-prem, also enable hostNetwork
- enable-host-network
```

3. Download the tls keys and certs from the first cluster.

```sh
# ensure kubeconfing points to the first cluster
. ./overlay/instance1/multi-region/get-tls-keys.sh
```

This will generate `tls.key` and `tls.cert`. Change the kubeconfig to the new cluster.

4. Follow the instructions in [install.sh](./install)


## Versions

* GKE 1.21.xx
* Anthos Service Mesh 1.12.4
* Apigee hybrid 1.6.3
* cert-manager 1.5.2

## Tools

* kubectl v1.23.0
* Kustomize 4.4.1
* Awk 5.1.0
* OpenSSL 1.1.1l
* bash 5.1.8
* envsubst 0.21

___

## Support

This is not an officially supported Google product
