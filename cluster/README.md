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