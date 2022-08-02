# Slow recover from large backups

Recovery of files beyond 1TiB in a backup will either fail completely or revert to slow restore that scans the entire tar/tape.

Reported [Issue #156](https://github.com/zmanda/amanda/issues/156).

## Impact

  - ❌ [Source 3_5](https://github.com/zmanda/amanda/tree/3_5)
  - ❌ Ubuntu-20.04 amanda v3.5.1
  - ❌ Ubuntu-22.04 amanda v3.5.1

## Test

Use the [intmax](config/intmax/) setup to create a large enough backup to trigger this bug.



### Results

Confirm in the amgtar log that `file1024.1g` starts after 2^31 blocks:

Log file in `amanda/client/intmax/amgtar.*.debug`

```
...
amgtar: recover_dump_state_file: 2143290366 /file1022.1g
amgtar: recover_dump_state_file: 2145387519 /file1023.1g
amgtar: recover_dump_state_file: 2147484672 /file1024.1g
...
```

Attempt to recover `file1023.1g` succeeds and attempt to recover `file1024.1g` fails:

```
...
Restoring files into directory /mnt/tank/amanda
Continue [?/Y/n]? 
./file1023.1g
1048576 kb 
amrecover> add file1024.1g
Added file /file1024.1g
amrecover> extract

Extracting files using tape drive chg-disk:/mnt/tank/amanda/intmax/vtapes on host localhost.
The following tapes are needed: Intmax-01

Extracting files using tape drive chg-disk:/mnt/tank/amanda/intmax/vtapes on host localhost.
Load tape Intmax-01 now
Continue [?/Y/n/s/d]? 
Restoring files into directory /mnt/tank/amanda
Continue [?/Y/n]? 

/usr/local/bin/gtar: This does not look like a tar archive
/usr/local/bin/gtar: ./file1024.1g: Not found in archive
/usr/local/bin/gtar: Exiting with failure status due to previous errors
ERROR /usr/local/bin/gtar exited with status 2: see /tmp/amanda/client/intmax/amgtar.debug
Extractor child exited with status 1
```

[amidxtaped-error.20220716132747.debug](logs/intmax/amidxtaped-error.20220716132747.debug), notable lines pasted below where DAR fails to return an offset:

```
amidxtaped: Amanda::Recovery::Clerk: reading file 1 on 'Intmax-01'
amidxtaped: ctl line: DAR-DONE
amidxtaped: sending XMSG_CRC message 0x804143820
amidxtaped: pull_and_write CRC: 00000000      size 0
```

### Analysis

This issue is in the DAR calculation so only affects dumps using amgtar.

This is triggered by restoring from a DLE larger than `INT_MAX` **blocks**. My testing on an Ubuntu server resulted in `INT_MAX` at 2^31 and block size at 512 bytes, and so this bug was triggered when recovering beyond the 1TiB point in a backup.

## Resolution

Fix was proposed [PR #157](https://github.com/zmanda/amanda/pull/157) but it is not merged.

[amidxtaped-patched.20220716132951.debug](logs/intmax/amidxtaped-patched.20220716132951.debug), notable lines pasted below where DAR returns the expected offset:

```
amidxtaped: Amanda::Recovery::Clerk: reading file 1 on 'Intmax-01'
amidxtaped: ctl line: DAR-DONE
amidxtaped: xfer_queue_message: MSG: <XMsg@0x804191000 type=XMSG_CRC elt=<XferSourceRecovery@0x803dd1000> version=0>
amidxtaped: source_crc: 362489ee:1073742336
amidxtaped: xfer_queue_message: MSG: <XMsg@0x804191070 type=XMSG_SEGMENT_DONE elt=<XferSourceRecovery@0x803dd1000> version=0>
amidxtaped: Amanda::Recovery::Clerk: done reading segment from file
```

