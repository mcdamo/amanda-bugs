#!/usr/bin/env bash

set -e

BACKUP_ROOT=/mnt/tank/backup/singledrive

mkdir -p $BACKUP_ROOT

cd $BACKUP_ROOT

if [ ! -f file.150M ]; then
  echo "Generating random 150MB file"
  dd if=/dev/urandom of=file.150M bs=1M count=150
fi
