# Install Order

The manifests were executed in the following order:

* install
  * cert-manager
  * external-secrets
* cluster
  * ASM
    * istio-crds
    * istio-clusterroles
    * istio-webhook
  * Apigee hybrid
    * apigee-crds
    * apigee-storage
    * apigee-clusterroles
    * apigee-clusterissuer
    * apigee-webhook
* namespaces
  * istio-system
    * namespace
    * istio
    * envoyfilter
    * ingress-certs
    * internal-ingress-secrets
    * ingress-dns-secret
  * apigee-system
    * namespace
    * apigee-gcr-secret [optional, only required if using a private repo]
    * apigee-controller
  * apigee
    * The following is executed once per namespace
      * namespace
      * apigee-peer-auth
    * The following is executed for Cassandra
      * apigee-datastore-certs
      * apigee-datastore-secrets
      * apigee-datastore
    * apigee-telemetry
    * The following are `org` level manifests
      * apigee-srinandans-hybrid-certs
      * apigee-srinandans-hybrid-secrets
      * apigee-srinandans-hybrid
      * The following is executed for the `prod1` environment
        * apigee-srinandans-hybrid-prod1-certs
        * apigee-srinandans-hybrid-prod1-secrets
        * apigee-srinandans-hybrid-prod1
      * The following is executed for the `prod2` environment
        * apigee-srinandans-hybrid-prod2-certs
        * apigee-srinandans-hybrid-prod2-secrets
        * apigee-srinandans-hybrid-prod2
        * apigee-virtualhosts
