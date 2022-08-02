# Amanda Bugs

This repository is for keeping track of significant bugs and their patches or workarounds in [Amanda Network Backup](https://github.com/zmanda/amanda/).

I began tracking these issues because for some years the Amanda community version was broadly unmaintained. There had not been any commits to the `3_5` branch since 2019 and distributions are using even older versions. For example Ubuntu [packages](https://packages.ubuntu.com/jammy/amanda-server) are based off [earlier v3.5.1](https://github.com/zmanda/amanda/commits/subtag-community-3.5.1) from 2017 and FreeBSD provides [v3.3.9](https://www.freshports.org/misc/amanda-server) from 2016.

The 'recent' changes in v3.5.x source from 2017-2019 do not appear to be widely tested and in one example have been confirmed to trigger data loss (See in [active tapes overwritten](issue-tapes-overwritten.md))

All issues below here refer to Amanda v3.5.x built [from source](https://github.com/zmanda/amanda/tree/3_5) or distributed as system-specific packages.

## Issues

  - ❌ [amrecover hangs during restore](issue-amrecover-hang.md)
  - ❌ [slow recovery from large backups](issue-int-max.md)
  - ❌ [drive polled every 10 seconds](issue-drive-polling.md)
  - ✔ [active tapes overwritten](issue-tapes-overwritten.md)

## Building from source

Each distribution has their own set of patches and configuration tweaks to build.

### Common patches

#### hexencode-test fails

```bash
% make check

make[5]: Entering directory '/builddir/build/BUILD/amanda-3.5.1/common-src'
PASS: amflock-test
PASS: event-test
PASS: amsemaphore-test
PASS: crc32-test
PASS: quoting-test
PASS: ipc-binary-test
FAIL: hexencode-test
PASS: fileheader-test
PASS: match-test
```

This error appeared after upgrading to FreeBSD-12.3 or Ubuntu-22.04. It has been reported [Issue #167](https://github.com/zmanda/amanda/issues/167) and a fix [PR #176](https://github.com/zmanda/amanda/pull/176) supplied, but not merged. 

