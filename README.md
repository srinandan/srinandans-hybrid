# Use Kustomize with Apigee hybrid

This **experimental** repo contains Kubernetes manifests for [Apigee hybrid](https://cloud.google.com/apigee/docs/hybrid/v1.6/what-is-hybrid) runtime and explores the use of [Kustomize](https://kustomize.io/) for configuration management.

## Prerequisites

* A GKE cluster of supported version. See notes below if not using GKE.
* Apigee control plane entities like Organization, Environment & Environment Group have been created

## Folder Structure

Creating an appropriate folder structure is key to using kustomize. The folder structure below isn't the only approach. Here is a brief explanation of the folders:

* `base`: This folder contains the Kubernetes manifests of ApigeeOrganization, ApigeeEnvironment, ApigeeDatastore and other components of the runtime. Within the folder, there are sub folders per component - `controller`, `organization`, `environment` and `datastore`
* `base/ingress`: This folder contains manifests for an Istio based ingress. This method is described [here](https://cloud.google.com/service-mesh/docs/gateways). It is recommended that istio ingresses are are installed **outside** of the `istio-system` namespace
* `base/envoyfilters`: This folder contains Istio EnvoyFilters used by Apigee
* `cluster`: This folder contains cluster level resources like `ClusterRoleBinding`, `CustomResourceDefinitions` etc
* `primary`: This folder contains a CA cert file which must only be executed in the primary cluster. Technically speaking, Apigee hybrid has not concept of primary vs. secondary regions. If you have more than one region for the Apigee hybrid deployment, select the first region  as the primary.
* `overlays/templates`: This folder contains templates that are used to generate Kubernetes manifests
* `overlays/templates/org-components`: Kustomize has a concept of [components](https://kubectl.docs.kubernetes.io/guides/config_management/components/). This folder contains a set of commonly used features or properties that can be enabled at the org level.
* `overlays/templates/env-components`: This folder contains a set of Kustomize components for  commonly used features or properties that can be enabled at the env level
* `overlays/<instance-id>`: Create a folder per Apigee Instance. `instance1` is a placeholder name. An Apigee instance is a Apigee hybrid runtime installed in a region or data center.
* `overlays/<instance-id>/environments/<env-name>`: There is a folder for each Apigee environment. Within each folder, there can be further sub-folders to enable/disable features per Apigee Environment.
* `overlays/<instance-id>/envgroups/<env-group-name>`: There is a folder for each Apigee environment group. ech env group contains a certificate and ApigeeRouteConfig.
* `overlays/envoyfilters`: This folder contains envoyfilters to be applied to each Apigee instance
* `bin`: folder containing bash scripts

```sh
.
├── base
│   ├── controller
│   │   ├── APIGEE CONTROLLER MANIFESTS
│   │   └── kustomization.yaml
│   ├── datastore
│   │   ├── DATA STORE MANIFESTS
│   │   └── kustomization.yaml
│   ├── environment
│   │   ├── ENV MANIFESTS
│   │   └── kustomization.yaml
│   ├── envoyfilters
│   │   ├── ISTIO MANIFESTS
│   │   └── kustomization.yaml
│   ├── ingress
│   │   ├── INGRESS MANIFESTS
│   │   └── kustomization.yaml
│   └── organization
│       ├── ORG MANIFESTS
│       └── kustomization.yaml
├── cluster
│   ├── crds
│   │   └── APIGEE CRDs
│   └── APIGEE CLUSTER RESOURCES
├── overlays
│   ├── controller
│   │   ├── CONTROLLER OVERLAYS
│   │   └── kustomization.tmpl
│   ├── <INSTANCE>
│   │   ├── kustomization.yaml
│   │   ├── namespace.yaml
│   │   ├── <ORG COMPONENTS>
│   │   ├── envgroups
│   │   │   └── <ENV GROUP>
│   │   │       ├── <ENV GROUP MANIFESTS>
│   │   │       └── kustomization.yaml
│   │   ├── environments
│   │   │   └── <ENV>
│   │   │       ├── client_secret.json
│   │   │       ├── kustomization.yaml
│   │   │       └── <ENV COMPONENTS>
│   ├── templates
│   │   └── KUBERNETES MANIFEST TEMPLATES
│   ├── env-components
│   │   └── ENV SCOPED COMPONENTS
│   ├── org-components
│   │   └── ORG SCOPED COMPONENTS
│   ├── envoyfilters
│   │   └── <APIGEE ENVOY FILTERS>
└── primary
    └── apigee-ca-certificate.yaml
```

The folders `./overlays/<INSTANCE>` and `./overlays/<INSTANCE>/environments/<ENV>` are generated based on environment variables. The `generateOrgKustomize.sh` and `generateEnvKustomize.sh` scripts generate Kustomize from templates (in `./overlays/templates`).

## Setup Variables

**NOTE:** The setup scripts require access to tools on specific versions. Please consult [here](#tools) before proceeding.

Open the [vars.sh](./bin/vars.sh) and [env-vars.sh](./bin/env-vars.sh) to ensure the following variables are appropriately set:

* `ORG_NAME`: Apigee Organization name
* `ENV_NAME`: Apigee Environment name (in env-vars.sh)
* `ENV_GROUP`: Apigee Environment Group name
* `CLUSTER_REGION`: GCP Region for the Kubernetes cluster (or closest GCP region if running outside GCP)
* `CLUSTER_NAME`: Kubernetes cluster name
* `PROJECT_ID`: GCP Project Id
* `APIGEE_VERSION`: Apigee hybrid version
* `INSTANCE_ID`: Apigee Instance name
* `ASM_MINOR_VERSION`: Anthos Service Mesh minor Version. For example, if installing ASM 1.12, set this to 12

Other environment variables:
* `GSA`: This is the Google service account name. This var is mandatory if using workload identity
* `SEED_HOST`: This is needed when expanding an org to a second region
* `DATA_CENTER`: This is needed when expanding an org to a second region
* `HUB`: The image repository, defaults to GCR
* `APIGEE_VERSION`: The Apigee hybrid version to install. Defaults to 1.6.3
* `GCS_BUCKET`: If Cassandra backup is enabled, then the GCS bucket name. Non-GCS backup is not available

## Installation

Follow the instructions in [install.sh](./bin/install.sh). This installation assumes GKE. However, all the steps with the exception of ASM are identical when running outside GKE. Please see this [link](https://cloud.google.com/service-mesh/docs/unified-install/install#amazon-eks) for instructions on how to change ASM install for other platforms.

### Managing access to the control plane

This installation supports two models to authenticate and authorize access to the control plane:
* Google Service Accounts
* Workload Identity

#### Workload Identity

This method is only supported on GKE. This is enabled through the `workload-identity` kustomize component. This installation process only supports one Google service account (GSA) to be mapped to the Kubernetes service accounts (KSA). If you want multiple GSAs mapped to KSAs, then it will have to be done manually (i.e., edit the namespace annotation). When using workload identity set the env variable `GSA` to the Google Service Account name.

#### Google Service Accounts

If you are using Google Service Accounts, there are two approaches:

1. Using a single GSA for all components (default method). This is enabled with the `google-service-accounts` kustomize component. To use this method, please the GSA private key (the file must be called `client_secret.json`) in `./overlay/org-components/google-service-accounts/` and `./overlay/env-components/google-service-accounts/`. This must be done before calling `./generateOrgKustomize.sh`

2. Use a different GSA for each type of component. This is enabled with the `multi-google-service-accounts` kustomize component. To use this method, place the GSA private key (the file must be called `client_secret.json`in all cases) for:
  - mart in `./overlay/org-components/multi-google-service-accounts/mart`
  - watcher in `./overlay/org-components/multi-google-service-accounts/watcher`
  - apigee connect in `./overlay/org-components/multi-google-service-accounts/connect`
  - telemetry/metrics in `./overlay/org-components/multi-google-service-accounts/telemetry`
  - runtime in `./overlay/env-components/multi-google-service-accounts/runtime`
  - udca in `./overlay/env-components/multi-google-service-accounts/udca`
  - synchronizer in `./overlay/env-components/multi-google-service-accounts/synchronizer`

This must be done before calling `./generateOrgKustomize.sh` or `./generateEnvKustomize.sh`

### Private/Custom Image repo

There are three helper scripts to download images from GCR (and Quay in the case of cert-manager):
* [apigee-pull-push.sh](./bin/apigee-pull-push.sh): Pull Apigee hybrid images and push to another image repo
* [asm-pull-push.sh](./bin/asm-pull-push.sh): Pull ASM images and push to another image repo
* [cert-mgr-pull-push.sh](./bin/cert-mgr-pull-push.sh): Pull cert-manager images and push to another repo

NOTE: All three scripts must be edited/changed to add target image repo details before use.

## Kustomize

Features and/properties of the installation can be modified by commenting or uncommenting the `kustomization.yaml` file in the instance folder. The following features for an org are enabled by default:

```yaml
components:
# Node selectors are used
- node-selector
# workload identity is enabled
- workload-identity
# Generate default secrets for encryption, cassandra auth etc.
- secrets
# Generate ingress configuration via self-signed certs
- envgroups
# Enable Apigee metrics
- metrics
...
...
```

The org kustomization file is generated via the script `generateOrgKustomize.sh`. The kustomize template for environments can be found [here](./overlays/templates/env-kustomization.tmpl). The env kustomization file is generated via the script `generateEnvKustomize.sh`.

### Ingress Configuration

This installation generates a self-signed certificate, signed by the [Apigee CA](./clusters/apigee-apigee-ca-issuer-clusterissuer.yaml). The certificate template is [here](./overlays/templates/certificate.tmpl).

If you wish to provide your own certificates, there are two ways:

1. Modify the templates
2. Modify the kustomize files

Edit the `./overlays/templates/envgroup-kustomization.tmpl` template file or `./overlays/<instance-id>/envgroups/<env group>/kustomization.yaml`. Make the following edits in the file

```

resources:
# do not include the certificate yaml
# - certificate.yaml
- apigeerouteconfig.yaml

# add a secretGenerator with path to the tls key and crt
```


### Add a new environment

These steps assume the Apigee Organization and other components are already installed.

1. Open the [env-vars.sh](./bin/env-vars.sh) file and add the new environment name. Generate the environment variables.

```sh
source ./bin/env-vars.sh
```

2. Generate the kustomize manifests for the environment

```sh
./bin/generateEnvKustomize.sh
```

Edit the generated/default `kustomization.yaml` file if needed. Optionally, add the new environment in the `./overlays/${INSTANCE_ID}/environments/kustomizations.yaml` file.

3. Apply the Kubernetes manifests

To apply a single environment,

```sh
kubectl apply -k ./overlays/instance1/environments/${ENV_NAME}
```

To apply all environments,

```sh
kubectl apply -k ./overlays/instance1/environments
```

### Adding a second region

In most cases, an Apigee Organization is identical across data centers or regions. In Apigee terms, an Apigee runtime deployment of an org is called an Apigee instance. Instances of an Org are typically identical.

1. Change/set the environment variables `INSTANCE_ID`, `CLUSTER_NAME` and `CLUSTER_REGION`. Add env variables for `SEED_HOST` and `DATA_CENTER`. Make these changes in [vars.sh](./bin/vars.sh)

Make a copy of all the files in the first instance to the new instance.

```sh
mkdir ./overlays/${INSTANCE_ID}

cp -r ./overlays/<OLD-INSTANCE>/* ./overlays/${INSTANCE_ID}/
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
./bin/get-tls-keys.sh
```

This will generate `tls.key` and `tls.crt`. Change the kubeconfig to the new cluster

4. Follow the steps in [expand.sh](./bin/expand.sh).


### Adding a new environment group

These steps assume an ApigeeOrganization and at least one environment group already exists.

1. Set the new environment group variable name `ENV_GROUP` in the `generateEnvGrpKustomize.sh` file.

2. Generate the kustomize manifests for the environment

```sh
./bin/generateEnvGrpKustomize.sh
```

3. Add all the environment group names to the kustomization file

```sh
./overlays/${INSTANCE_ID}/envgroups/kustomization.yaml
```

For example:

```yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component

resources:
- env-group1
- env-group2
...
```

4. Replace/modify the auto-generated certificate. If the key/cert were generated by an external cert management system, use the `secretGenerator` to generate the secret.

```sh
./overlays/${INSTANCE_ID}/envgroups/${ENV_GROUP}/certificate.yaml
```

5. Re-apply the instance manifests

```
kubectl apply -k overlays/${INSTANCE_ID}
```

### Other considerations

* Instead of using the `secretGenerator` secrets could be managed externally. Some of the techniques are explored in the legacy branch in this repo.
* Integrate with ArgoCD, Flux or Anthos Config Management for GitOps.

## Components

The following components are included. Enable/disable these features as necessary in the kustomization.yaml file.

* Instance and Org Components
  - `cass-backup`: Enable Cassandra backup to GCP (GCS)
  - `cass-production`: Set recommended Cassandra resources for production (mem, CPU etc.)
  - `cass-replicas`: Set Cassandra replicas
  - `enable-host-network`: Enable hostNetwork on platforms like GKE on-prem
  - `envgroups`: Include ingress settings for environment groups
  - `google-service-accounts`: Create Kubernetes secrets for  Google Service Accounts. Uses a single GSA for all components
  - `multi-google-service-accounts`: Same as above, but uses one GSA per component
  - `http-proxy`: Use http forward proxy to communicate with the Apigee control plane
  - `logger`: Enable Apigee logger
  - `metrics`: Enable Apigee metrics
  - `multi-region`: Setup Cassandra for multi-region
  - `node-selector`: Use node selectors for org components
  - `pullsecret`: Set a Image Pull Secret
  - `secrets`: Generate Kubernetes secrets for org components
  - `workload-identity`: Enable workload identity for org components (only for GKE)
  - `ingress-annotations`: Add annotations to the istio-ingressgateway service
  - `wildcard-gateway`: Creates a wildcard Gateway (Istio CR) and adds additionalGateways configuration to ApigeeRouteConfig

* Environment Components
  - `google-service-accounts`: Create Kubernetes secrets for  Google Service Accounts. Uses a single GSA for all components
  - `multi-google-service-accounts`: Same as above, but uses one GSA per component
  - `http-proxy`: Use http forward proxy to communicate with the Apigee control plane
  - `node-selector`: Use node selectors for env components
  - `runtime-http-proxy`: Use http forward proxy when API Proxies talk to backend/targets
  - `runtime-replicas`: Set runtime replicas
  - `secrets`: Generate Kubernetes secrets for env components
  - `pullsecret`: Set a Image Pull Secret for Env components
  - `workload-identity`: Enable workload identity for env components (only for GKE)

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
* helm v3.7.2

## History

A previous version of this repo contained integration with Anthos Configuration Management and Vault. The contents are found in the `legacy` branch.
___

## Support

This is not an officially supported Google product
