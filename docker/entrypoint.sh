#!/bin/bash -il


set -e

# Activate the default conda's base environment
conda activate base

# Run whatever the user wants to
exec "$@"
