# ASM Manifests

Anthos Service Mesh manifests were generated using the command

```bash
istioctl manifest generate --set profile=asm-gcp -f asm/istio/istio-operator.yaml >> istio.yaml
```