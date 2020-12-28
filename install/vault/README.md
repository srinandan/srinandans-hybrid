# vault

## Install

* See [here]((https://github.com/srinandan/apigee-vault)) for instructions to install

## Credential Setup

The following hierarchy was used to create credentials for Apigee hybrid. The root element is `secret/srinandans-hybrid`

```

├── config
├── datastore
│   ├── [ default.password  ] 
│   ├── [ admin.password    ] 
│   ├── [ admin.user        ] 
│   ├── [ ddl.user          ] 
│   ├── [ ddl.password      ] 
│   ├── [ dml.user          ] 
│   ├── [ dml.password      ] 
│   ├── [ jmx.user          ] 
│   ├── [ jmx.password      ] 
│   ├── [ jolokia.user      ] 
│   ├── [ jolokia.password  ] 
├── ingress
│   ├── [ key.json ] = [ The GSA with access to Cloud DNS ]
├── internal-ingress
│   ├── [ tls.key ] = [ tls private key ]
│   ├── [ tls.crt ] = [ tls cert        ]
│   ├── [ ca.crt  ] = [ ca crt file     ]
├── org
│   ├── [ salt             ] 
│   ├── [ plainTextDEK     ] 
│   ├── [ kmsEncryptionKey ] 
├── prod1
│   ├── [ cacheEncryptionKey  ] 
│   ├── [ envKvmEncryptionKey ] 
│   ├── [ kmsEncryptionKey    ] 
│   ├── [ kvmEncryptionKey    ] 
│   ├── config
│   ├── runtime-config
│   ├── sync-config
├── prod2
│   ├── [ cacheEncryptionKey  ] 
│   ├── [ envKvmEncryptionKey ] 
│   ├── [ kmsEncryptionKey    ] 
│   ├── [ kvmEncryptionKey    ]
│   ├── config
│   ├── runtime-config
│   ├── sync-config
```

## PKI Setup

Enable the PKI Engine

```bash
vault secrets enable pki
```

Tune the default parameters

```bash
vault secrets tune -max-lease-ttl=8760h pki
```

Generate a self signed Root CA

```bash
vault write pki/root/generate/internal common_name=apigeehybrid ttl=8760h
```

Allow cert-manager to request certificates

```bash
vault write auth/kubernetes/role/vault-issuer \
    bound_service_account_names=cert-manager \
    bound_service_account_namespaces=cert-manager \
    policies=pki \
    ttl=20m
```

Create a default policy for `apigeehybrid`

```bash
vault policy write pki - <<EOF
path "pki*"                      { capabilities = ["read", "list"] }
path "pki/roles/apigeehybrid"   { capabilities = ["create", "update"] }
path "pki/sign/apigeehybrid"    { capabilities = ["create", "update"] }
path "pki/issue/apigeehybrid"   { capabilities = ["create"] }
EOF
```

Provide a overly generous role (since this is for demo/experimental purposes)

```bash
vault write pki/roles/apigeehybrid allowed_domains=apigee.svc.cluster.local allow_subdomains=true max_ttl=72h enforce_hostnames=false allow_any_name=true allow_bare_domains=true allow_glob_domains=true
```

Create a Apigee Cluster Issuer (CA)

```bash
ISSUER_SECRET_REF=$(kubectl get serviceaccount cert-manager -n cert-manager -o json | jq -r ".secrets[].name")

cat <<EOF | kubectl apply -f - 
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: apigee-vault-issuer
spec:
  vault:
    server: $VAULT_ADDR
    path: pki/sign/apigeehybrid
    auth:
      kubernetes:
        mountPath: /v1/auth/kubernetes
        role: vault-issuer
        secretRef:
          name: $ISSUER_SECRET_REF
          key: token
EOF
```