#!/bin/sh

# EXPORT GH PAT BEFORE RUNNING THIS SCRIPT

helm install cilium cilium/cilium --version 1.14.4/
--namespace kube-system /
--set operator.replicas=1 /
--set=ipam.operator.clusterPoolIPv4PodCIDRList="10.24.0.0/16"


flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --owner=tmayweather \
  --repository=home-ops \
  --branch=main \
  --path=./cluster/flux \
  --personal \

# DEPLOY SOPS AGE

flux create source git secrets \
  --url=https://github.com/tmayweather/home-ops.git \
  --branch=main

flux create kustomization secrets \
  --source=secrets \
  --path=./cluster \
  --prune=true \
  --interval=10m \
  --decryption-provider=sops \
  --decryption-secret=sops-age

sops -d cluster/bootstrap/age-key.sops.yaml | kubectl apply -f -
sops -d cluster/bootstrap/github-deploy-key.sops.yaml | kubectl apply -f -

# HAVE FLUX MONITOR CLUSTER APPS

kubectl apply -f cluster/flux/apps.yaml

# DEPLOY CERTS AND 1PASSWORD

kubectl apply -f cluster/apps/kube-system/external-secrets/ks.yaml
sops -d cluster/apps/kube-system/external-secrets/stores/onepassword/secret.sops.yaml | kubectl apply -f -

kubectl apply -f cluster/apps/cert-manager/namespace.yaml
kubectl apply -f cluster/apps/cert-manager/cert-manager/ks.yaml
sops -d cluster/apps/cert-manager/cert-manager/issuers/secret.sops.yaml | kubectl apply -f -

