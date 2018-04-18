#!/bin/bash -il


set -e

# Activate the default conda's base environment
. /opt/conda/etc/profile.d/conda.sh
conda activate base

# Run whatever the user wants to
exec "$@"
