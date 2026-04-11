#!/usr/bin/env bash

set -e

BACKUP_ROOT=/mnt/tank/backup/intmax

mkdir -p $BACKUP_ROOT

cd $BACKUP_ROOT

if [ ! -f file0000.1g ]; then
  echo "Generating sparse 1GB files"
  for i in `seq -f "%04g" 1 1048`; do
    dd if=/dev/zero of=file$i.1g bs=1 count=0 seek=1G
    echo $i
  done
fi

