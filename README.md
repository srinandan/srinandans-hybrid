# srinandans-hybrid

This repo contains Kubernetes manifests for [Apigee hybrid](https://cloud.google.com/apigee/docs/hybrid/v1.4/what-is-hybrid) runtime and is connected with [Anthos Config Management](https://cloud.google.com/anthos-config-management/docs) for configuration management.

## Setup

### Apigee Entities

* Organization: `srinandans-hybrid`
* Environments: `prod1` and `prod2`

### Ingress Certificate Management

This setup uses [cert-manager](https://cert-manager.io/docs/) and [Let's Encrypt](https://letsencrypt.org/) to automatically obtain and renew certificates for the Ingress

### Credential Management

This setup uses Hashicorp [Vault](http://projectvault.io/) to manage credentials to Apigee hybrid (ex: Encryption Keys, Passwords etc.). The secret hierarchy used is:

* `secrets/srinandans-hybrid/datastore`: For cassandra secrets
* `secrets/srinandans-hybrid/org`: For org level secrets
* `secrets/srinandans-hybrid/ENV`: For environment level secrets

### Secret Management

This setup uses [ExternalSecrets](https://github.com/external-secrets/kubernetes-external-secrets), a Kubernetes controller which provisions Kubernetes secrets from external credential management systems like Vault

## Generating Manifests

### ASM Manifests

Anthos Service Mesh manifests were generated using the command

```bash
istioctl manifest generate --set profile=asm-gcp -f asm/istio/istio-operator.yaml >> istio.yaml
```

### Apigee Manifests

Apigee hybrid manifests were generated using the script [here](./install/apigee-overrides/generate-manifests.sh)

## Versions

* GKE 1.17
* Anthos Service Mesh 1.7.3
* Anthos Configuration Management
* Apigee hybrid 1.4
* cert-manager 1.0.4
* Vault 1.6.1
* External Secret 6.0.0

## References

* [https://github.com/srinandan/apigee-vault](https://github.com/srinandan/apigee-vault)

___

## Support

This is not an officially supported Google product