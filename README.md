# srinandans-hybrid

This repo contains Kubernetes manifests for [Apigee hybrid](https://cloud.google.com/apigee/docs/hybrid/v1.4/what-is-hybrid) runtime and is connected with [Anthos Config Management](https://cloud.google.com/anthos-config-management/docs) for configuration management.

## Setup

### Apigee Entities

* Organization: `srinandans-hybrid`
* Environments: `prod1` and `prod2`

Apigee hybrid manifests were generated using the script [here](./install/apigee-overrides)

### Vault

Hashicorp Vault was setup using instructions [here](https://github.com/srinandan/apigee-vault/tree/main/install-vault)

### External Secrets

This setup uses [ExternalSecrets](https://github.com/external-secrets/kubernetes-external-secrets), a Kubernetes controller which provisions Kubernetes secrets from external credential management systems like Vault. See [here](./install/external-secrets) for details about the setup.

### cert-manager

cert-manager was installed using the manifests [here](./install/cert-manager)

## Management

### Ingress Certificate Management

There are two ingresses in the setup:

* An externally available (GCP External Load Balancer) hostname. This setup uses [cert-manager](https://cert-manager.io/docs/) and [Let's Encrypt](https://letsencrypt.org/) to automatically obtain and renew certificates for the ASM Ingress

* An internally available (GCP Internal Load Balancer) hostname. This setup uses Vault's Credential Management and External Secrets to provision the key, cert and ca.

### TLS Management/PKI

This setup uses [cert-manager] to to dynamically request and provision certificates. cert-manager is [integrated]((https://cert-manager.io/docs/configuration/vault/)) with Vault. Vault acts as the PKI that signs the certificates requested by cert-manager. Vault's [PKI Engine](https://www.vaultproject.io/docs/secrets/pki) was used to create an self signed Issuer (self signed root) to sign the certificates.

These certificates are used for TLS communication within Apigee hybrid (ex: Runtime to UDCA, Synchronizer to Runtime etc.). Details about the setup can be found [here](./install/vault)

### Credential Management

Apigee hybrid allows customers to setup encryption keys for sensitive data like KVMs, Cache etc. This setup uses Vault's [KV 2 Secret Engine](https://www.vaultproject.io/docs/secrets/kv) to store such credentials. Details about the setup can be found [here](./install/vault)

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