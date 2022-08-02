# Amanda singledrive test config

## Setup

```
sudo apt-get install mhvtl amanda-server amanda-client
```

Quick setup

```
./setup.sh
```

Generate backup data

```
./generate.sh
```

### Virtual tape drive

```bash
% lsscsi -g
[0:0:0:0]    cd/dvd  QEMU     QEMU DVD-ROM     2.5+  /dev/sr0   /dev/sg0 
[6:0:0:0]    mediumx STK      L700             0107  /dev/sch0  /dev/sg1 
[6:0:1:0]    tape    IBM      ULT3580-TD8      0107  /dev/st0   /dev/sg3 
[6:0:2:0]    tape    IBM      ULT3580-TD8      0107  /dev/st1   /dev/sg4 
[6:0:3:0]    tape    IBM      ULT3580-TD6      0107  /dev/st2   /dev/sg5 
[6:0:4:0]    tape    IBM      ULT3580-TD6      0107  /dev/st3   /dev/sg6 
[6:0:8:0]    mediumx STK      L80              0107  /dev/sch1  /dev/sg2 
[6:0:9:0]    tape    STK      T10000B          0107  /dev/st5   /dev/sg8 
[6:0:10:0]   tape    STK      T10000B          0107  /dev/st4   /dev/sg7 
[6:0:11:0]   tape    STK      T10000B          0107  /dev/st6   /dev/sg9 
[6:0:12:0]   tape    STK      T10000B          0107  /dev/st7   /dev/sg10
```

vtlcmd device number is in `/etc/mhvtl/devices.conf`

make two tapes of any type compatible with the first tape drive, size 100MB

```bash
% mktape -l 10 -m D01000L8 -s 100 -t data -d LTO8
% mktape -l 10 -m D01001L8 -s 100 -t data -d LTO8
```

pick first LTO drive ID #11

```bash
% vtlcmd 11 load D01000L8
```

from lsscsi this drive is mounted at /dev/st0

```bash
% mt -f /dev/st0 status
```

## Amanda
```bash
% amcheck singledrive
```

```bash
% amdump singledrive --no-taper
```

check holding

```bash
% amadmin singledrive holding list -l
```

```bash
% amflush -f singledrive
```

to retest, clear the tape

```bash
% amrmtape --cleanup --keep-label singledrive Singledrive-01
```

