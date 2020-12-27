# controller.yaml

The following configuration was removed from `controller.yaml` since the data was generated using Vault

```yaml
  apigee-ca.yaml: |-
    
    apiVersion: v1
    kind: Secret
    metadata:
      name: apigee-ca
      namespace: cert-manager
    type: kubernetes.io/tls
    data:
      tls.crt: |
        LS0...
      tls.key: |
        LS0...
  apigee-ca-issuer.yaml: |-
    
    apiVersion: cert-manager.io/v1alpha2
    kind: ClusterIssuer
    metadata:
      name: apigee-ca-issuer
    spec:
      ca:
        secretName: apigee-ca
```
