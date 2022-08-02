# Amanda intmax test config

## Setup

Requires patch [PR #183](https://github.com/zmanda/amanda/pull/183)

Quick setup

```
./setup.sh
```

Generate backup data

```
./generate.sh

For convenience this backup uses hardlinks to generate 1048GiB backup data while only using 1GiB of disk space.

Amanda needs to be patched with [PR #183](https://github.com/zmanda/amanda/pull/183) to allow tar to dereference hardlinks.

The resulting dump will take the full 1048GiB of disk space.

