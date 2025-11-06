#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

cd ./cloudnative-pg

make build-manager
# This step intentionally fail. It is needed to copy files to correct places
make docker-build || true

docker rmi cloudnative-pg:local || true
docker build --no-cache --tag cloudnative-pg:local .
k3d image import cloudnative-pg:local -c cn-data-plane

kubectl set image --namespace cn-data-plane-system deployment/cn-cloudnative-pg manager=cloudnative-pg:local
kubectl set env --namespace cn-data-plane-system deployment/cn-cloudnative-pg OPERATOR_IMAGE_NAME=cloudnative-pg:local
