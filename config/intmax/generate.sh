#!/usr/bin/env bash

set -e

BACKUP_ROOT=/mnt/tank/backup/intmax

mkdir -p $BACKUP_ROOT

cd $BACKUP_ROOT

if [ ! -f file0000.1g ]; then
  echo "Generating random 1GB files"
  dd if=/dev/urandom of=file0000.1g bs=1M count=1024
  for i in `seq -f "%04g" 1 1048`; do
    ln file0000.1g file$i.1g
    echo $i
  done
fi

