#!/usr/bin/env bash

set -e

AMANDA_USER=amanda
AMANDA_ROOT=/amanda/intmax
VTAPE_ROOT=/mnt/tank/amanda/intmax/vtapes

mkdir -p $AMANDA_ROOT/state/log
chown -R $AMANDA_USER:$AMANDA_USER $AMANDA_ROOT

mkdir -p $VTAPE_ROOT

cd $VTAPE_ROOT
for slot in `seq 1 10`; do mkdir slot$slot; done

chown -R $AMANDA_USER:$AMANDA_USER $VTAPE_ROOT
