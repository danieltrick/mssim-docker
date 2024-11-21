#!/bin/sh
set -ex
stdbuf -oL -eL /usr/bin/tpm2-simulator "$@"
