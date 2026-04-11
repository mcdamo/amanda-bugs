# Failed recovery from DLE greater than 1TiB

Recovery of files beyond 1TiB in a DLE will fail completely or under certain circumstances will revert to slow restore that scans the entire tar/tape.

Reported [Issue #156](https://github.com/zmanda/amanda/issues/156).

## Impact

  - ❌ [Source 3_5](https://github.com/zmanda/amanda/tree/3_5)
  - ❌ Ubuntu-20.04 amanda v3.5.1
  - ❌ Ubuntu-22.04 [v3.5.1-8ubuntu1](https://packages.ubuntu.com/jammy/amanda-server)
  - ❌ Ubuntu-24.04 [v3.5.1-11.1build6](https://packages.ubuntu.com/noble/amanda-server)

## Test

Use the [intmax](config/intmax/) setup to create a large enough backup to trigger this bug.



### Results

Confirm in the amgtar log that `file1026.1g` starts after 2^31 blocks:

State file in `/amanda/intmax/state/index/localhost/tank/*.stage.gz`

```
...
2143290366 /file1023.1g
2145387519 /file1024.1g
2147484672 /file1025.1g
2149581825 /file1026.1g
...
```

Recover `file1023.1g` succeeds:

```
amrecover> add file1023.1g
Added file /file1023.1g
amrecover> extract

Restoring files into directory /mnt/tank/amanda
Continue [?/Y/n]? 
./file1023.1g
1048576 kb
```

Attempt to recover `file1026.1g` fails:

```
amrecover> add file1026.1g
Added file /file1026.1g
amrecover> extract

Extracting files using tape drive chg-disk:/mnt/tank/amanda/intmax/vtapes on host localhost.
The following tapes are needed: Intmax-01

Extracting files using tape drive chg-disk:/mnt/tank/amanda/intmax/vtapes on host localhost.
Load tape Intmax-01 now
Continue [?/Y/n/s/d]? 
Restoring files into directory /mnt/tank/amanda
Continue [?/Y/n]? 

/usr/local/bin/gtar: This does not look like a tar archive
/usr/local/bin/gtar: ./file1026.1g: Not found in archive
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

