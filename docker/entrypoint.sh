#!/bin/bash -il


set -e

# Activate the default conda's base environment
set -a
. /opt/conda/etc/profile.d/conda.sh
conda activate base
set +a

# Run whatever the user wants to
exec "$@"
