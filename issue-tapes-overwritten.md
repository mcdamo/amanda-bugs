# Active tapes overwritten

**This has been resolved in 3_5 branch**

Active tapes are overwritten when using lexical or oldest taperscan. This will cause a backup to immediately overwrite a tape.

Reported in [Issue #160](https://github.com/zmanda/amanda/issues/160).

## Impact

  - ❌ [Source 3_5](https://github.com/zmanda/amanda/tree/3_5)
  - ✔ Ubuntu-20.04 v3.5.1
  - ✔ Ubuntu-22.04 v3.5.1

## Resolution

The original [commit](https://github.com/zmanda/amanda/pull/136) that caused this error was merged on 11 Dec 2019 but it appears it is not included in packages provided by Ubuntu/FreeBSD/etc so was only a problem when building from source.

Fixed in [PR #174](https://github.com/zmanda/amanda/pull/174).

