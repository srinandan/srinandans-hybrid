# Apigee CRD Fixes

When running `nomos vet`, this error was observed

```bash
KNV1045: Configs with "status" specified are not allowed. To fix, either remove the config or remove the "status" field in the config:

source: /Users/srinandans/local_workspace/srinandans-hybrid/cluster/crds.yaml
metadata.name: cassandradatareplications.apigee.cloud.google.com
group: apiextensions.k8s.io
version:
kind: CustomResourceDefinition

For more information, see https://g.co/cloud/acm-errors#knv1045
```

This is likely due to non-pointer struct field generating an empty `status` object. To fix this error, I commented the following lines:

```yaml
#status:
#  acceptedNames:
#    kind: ""
#    plural: ""
#  conditions: []
#  storedVersions: []
```

There are 8 such occurrences.

In the apigee-clusterroles manifest file, remove the following lines

```yaml
# This is the role that will be associated to the above service account.
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: apigee-init
rules:
  - apiGroups: ["*"]
    resources: ["secrets"]
    verbs: ["get", "create", "watch"]
---
# Binding the role to the service account.
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: apigee-init
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: apigee-init
subjects:
  - kind: ServiceAccount
    name: apigee-init
    namespace: apigee
```

Refer [here](../namespace/apigee-system) for details