# Drive polled every 10 seconds

In a singledrive configuration the tape drive is polled every 10 seconds while waiting for a requested tape. If a tape is in the drive this will repeatedly load/unload the tape, unnecessarily wearing out the physical mechanism.

Reported in [Issue #179](https://github.com/zmanda/amanda/issues/179).

## Impact

  - ❌ [Source 3_5](https://github.com/zmanda/amanda/tree/3_5)
  - ❌ Ubuntu-20.04 amanda v3.5.1
  - ❌ Ubuntu-22.04 amanda v3.5.1

## Test

Use the [singledrive](config/singledrive/) setup. The polling happens during dump/flush to tape as well as recover from tape.

## Resolution

Fix proposed in [PR #180](https://github.com/zmanda/amanda/pull/180).

