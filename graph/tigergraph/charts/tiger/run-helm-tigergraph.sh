#!/usr/bin/env bash
helm install tigergraph . \
     --namespace poodle \
     --create-namespace \
     -f values.yaml \
     --set dataVolume.size=89Gi,dataVolume.storageClass=longhorn \
     --set ingestVolume.storageClass=nfs,ingestVolume.size=100Gi \
     --set resources.requests.cpu=2000m,resources.requests.memory=2Gi \
     --set uiService.type=NodePort
