#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

rm -rf './cloudnative-pg'
git clone --branch disableASC --single-branch --depth 1 git@github.com:codenow-com/cloudnative-pg
