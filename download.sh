#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

rm -rf './workspace'
git clone --branch 'custom/main' --single-branch --depth 1 git@github.com:codenow-com/cloudnative-pg
