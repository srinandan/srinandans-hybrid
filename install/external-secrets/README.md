# external-secrets

This repo uses [External Secrets](https://github.com/external-secrets/kubernetes-external-secrets) and [Vault](http://projectvault.io/) as a backend to automatically provision secrets.

## Installation

The following command was used to install External Secrets:

```bash
helm template external-secrets external-secrets/kubernetes-external-secrets --set env.VAULT_ADDR=http://vault.srinandans.internal:8200 --set serviceAccount.name=external-secrets --namespace external-secrets --create-namespace >> external-secrets.yaml
```

```bash
kubectl apply -f external-secrets.sh
```

## Vault Setup

External Secrets requires a [role](https://www.vaultproject.io/docs/auth/kubernetes) in vault to read KV vales, secrets, PKI etc. THe following role was created to give External Secrets

```bash
vault write auth/kubernetes/role/external-secrets bound_service_account_names="external-secrets" bound_service_account_namespaces="*" policies=apigee-policy ttl=30m
```

## References

It is not ideal that External Secrets has access to all namespace. There are a couple of features that are WIP that will improve the role access. See [this](https://github.com/external-secrets/kubernetes-external-secrets/pull/549) and [this](https://github.com/external-secrets/kubernetes-external-secrets/pull/548) for more details