#!/bin/bash
set -e

GCLOUD_VERSION="453.0.0"
GCLOUD_PACKAGE="google-cloud-cli-${GCLOUD_VERSION}-linux-x86_64.tar.gz"
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${GCLOUD_PACKAGE}
tar -xf "${GCLOUD_PACKAGE}"
./google-cloud-sdk/install.sh -q --path-update true --command-completion true 