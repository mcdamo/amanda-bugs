#!/bin/bash

set -e

AMANDA_USER=amanda
AMANDA_ROOT=/amanda/singledrive

mkdir -p $AMANDA_ROOT/state/log
mkdir -p $AMANDA_ROOT/holding
chown -R $AMANDA_USER:$AMANDA_USER $AMANDA_ROOT

