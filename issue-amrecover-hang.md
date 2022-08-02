# amrecover hangs during restore

In a singledrive configuration with a backup that spans tapes, amrecover will hang after asking for the next tape.

Reported as [Issue #181](https://github.com/zmanda/amanda/issues/181).

## Impact

  - ❌ [Source 3_5](https://github.com/zmanda/amanda/tree/3_5)
  - ❌ Ubuntu-20.04 v3.5.1
  - ❌ Ubuntu-22.04 v3.5.1


## Test

Use the [singledrive](config/singledrive/) setup to create a backup that spans two virtual tapes, then attempt to recover the backup.

### Results

Console output:

```
AMRECOVER Version 3.5.1. Contacting server on localhost ...
220 qemu-ubuntu AMANDA index server (3.5.1) ready.
Setting restore date to today (2022-07-15)
200 Working date set to 2022-07-15.
200 Config set to singledrive.
200 Dump host set to localhost.
Use the setdisk command to choose dump disk to recover
amrecover> setdisk tank
200 Disk set to tank.
amrecover> ls
2022-07-15-04-52-08 file.150M
amrecover> add file.150M
Added file /file.150M
amrecover> extract

Extracting files using tape drive chg-single:tape:/dev/st0 on host localhost.
The following tapes are needed: Singledrive-01 Singledrive-02

Extracting files using tape drive chg-single:tape:/dev/st0 on host localhost.
Load tape Singledrive-01 now
Continue [?/Y/n/s/d]? y
Restoring files into directory /root
All existing files in /root can be deleted
Continue [?/Y/n]? y

./file.150M
3968 kb 
Source Volume 'Singledrive-02' not found
Load tape Singledrive-02 now
Continue [?/Y/n/d]? y
```

The console hangs after entering //y// above.

Debug Logs:

  - [amrecover.20220716044941.debug](logs/amrecover-hang/amrecover.20220716044941.debug)
  - [amidxtaped.20220716045144.debug](logs/amrecover-hang/amidxtaped.20220716045144.debug)

### Analysis

The crucial log is the last line of amidxtaped:

```
amidxtaped: ctl line: TP h-igetp:dvs
```
The expected result is

```
amidxtaped: CTL << TAPE chg-single:tape:/dev/st0
```
So it appears there is some problem with the client/server messaging.

## Resolution

I traced the failure to [here](https://github.com/zmanda/amanda/blob/6cec2349bfab67b4c6e5237c9ffdbff81ec2b6c7/server-src/amidxtaped.pl#L91-L92), though I don't understand the underlying cause of why `getline_async` is failing at this point.

As a workaround, replacing `getline_async` with the following will allow recovery:

```perl
my $buf;
$buf = $self->{'clientservice'}->getline($self->{'clientservice'}->{'ctl_stream'});
$steps->{'got_response'}->(undef, $buf);
```


