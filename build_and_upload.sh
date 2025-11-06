#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

WRITER_USERNAME='codenow-release-writer'
VERSION='1.27.1-cn.0.1'

if [ -z "${WRITER_PASSWORD:-}" ]; then
  read -p "Enter password for \"${WRITER_USERNAME}\" : " WRITER_PASSWORD
fi

echo "$WRITER_PASSWORD" | docker login --username "$WRITER_USERNAME" --password-stdin 'codenow-codenow-releases.jfrog.io'
echo "$WRITER_PASSWORD" | docker login --username "$WRITER_USERNAME" --password-stdin 'codenow-codenow-data-plane.jfrog.io'

docker buildx rm multiplatform &> /dev/null || true
docker buildx create --name multiplatform --use

cd './cloudnative-pg'

for HOST in 'codenow-codenow-data-plane.jfrog.io' 'codenow-codenow-releases.jfrog.io'; do

    ARCHITECTURES=('amd64' 'arm64')

    for ARCHITECTURE_NAME in "${ARCHITECTURES[@]}"; do

        export ARCH="$ARCHITECTURE_NAME"

        make build-manager
        # This step intentionally fail. It is needed to copy files to correct places
        make docker-build || true

        docker buildx build --platform "linux/${ARCHITECTURE_NAME}" --tag "${HOST}/cloudnative-pg/cloudnative-pg-${ARCHITECTURE_NAME}:${VERSION}" --output type=docker .
    done

    ARGS=()
    for ARCHITECTURE_NAME in "${ARCHITECTURES[@]}"; do
        docker push "${HOST}/cloudnative-pg/cloudnative-pg-${ARCHITECTURE_NAME}:${VERSION}"
        ARGS+=("${HOST}/cloudnative-pg/cloudnative-pg-${ARCHITECTURE_NAME}:${VERSION}")
    done

    docker manifest create "${HOST}/cloudnative-pg/cloudnative-pg:${VERSION}" "${ARGS[@]}"
    docker manifest push "${HOST}/cloudnative-pg/cloudnative-pg:${VERSION}"

done
