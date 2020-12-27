# apigee-overrides

Apigee hybrid manifests were generated using the script

```bash
./generate-manifests.sh
```

The generated files were modified to:

* Remove cluster configuration like `ClusterRole`, `ClusterRoleBinding` etc. to the `/clusters` folder. This is to comply with Anthos Configuration Management

* Annotate Kubernetes Service Accounts (KSA). This example is designed to work with Workload Identity (which is not available on all platforms)