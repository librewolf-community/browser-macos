# LibreWolf macOS

## Building

### Instructions

1.  Place a Firefox `.dmg` in `~/Downloads` — `~/Downloads/ff.dmg`
2.  `git clone --recursive https://gitlab.com/librewolf-community/browser/macos.git`
3.  `cd macos`
4.  `./package.sh ~/Downloads/ff.dmg`

    ```
    "disk3" ejected.
    Preparing imaging engine…
    Reading Driver Descriptor Map (DDM : 0)…
    (CRC32 $BAB1946F: Driver Descriptor Map (DDM : 0))
    Reading Apple (Apple_partition_map : 1)…
    (CRC32 $C133292C: Apple (Apple_partition_map : 1))
    Reading Macintosh (Apple_Driver_ATAPI : 2)…
    (CRC32 $C71C0011: Macintosh (Apple_Driver_ATAPI : 2))
    Reading Mac_OS_X (Apple_HFSX : 3)…
    .........................................................................
    (CRC32 $C07F196B: Mac_OS_X (Apple_HFSX : 3))
    Reading  (Apple_Free : 4)…
    ..........................................................................
    (CRC32 $00000000:  (Apple_Free : 4))
    Adding resources…
    ..........................................................................
    Elapsed Time: 10.034s
    File size: 84362685 bytes, Checksum: CRC32 $55286B19
    Sectors processed: 411730, 407569 compressed
    Speed: 19.8Mbytes/sec
    Savings: 60.0%
    created: /Users/(redacted)/Downloads/LibreWolf.dmg
    ```

A LW `dmg` named `LibreWolf.dmg` will be created in `~/Downloads`.

### Troubleshooting

#### `Firefox 1.app: No such file or directory`

```
$ ./package.sh ~/Downloads/ff.dmg
Firefox 1.app: No such file or directory
./package.sh: line 14: cd: Firefox 1.app/Contents: No such file or directory
```

You probably have a disk image mounted under the name `Firefox`. Eject that, use a fresh copy of the FF `dmg`, and try again.

#### `Firefox.app: No such file or directory`

```
$ ./package.sh ~/Downloads/ff.dmg
Firefox.app: No such file or directory
./package.sh: line 14: cd: Firefox.app/Contents: No such file or directory
```

This is probably a result of using the same FF `dmg` for more than one build. Use fresh FF `dmg`s for each build.

## License

Mozilla Public License Version 2.0. See `LICENSE.txt` for details.
