ZFS
===

[http://constantin.glez.de/blog/2011/02/frequently-asked-questions-about-flash-memory-ssds-and-zfs](SSD and ZFS)
[http://www.richardelling.com/Home/scripts-and-programs-1/zilstat](Zilstat)
[http://forums.freenas.org/threads/slideshow-explaining-vdev-zpool-zil-and-l2arc-for-noobs.7775/](VDev, zpool, ZIL and L2ARC for noobs)

[http://www.solarisinternals.com/wiki/index.php/ZFS_Best_Practices_Guide](ZFS Best Practices Guide)
[http://zfsguru.com/doc/bsd/zfs](ZFS Guru)
[http://www.c0t0d0s0.org/archives/6224-You-dont-need-zfs-resize-...-and-a-workaround-when-you-need-one-;.html](ZFS resizing)
[https://wiki.freebsd.org/ZFS?](FreeBSD wiki on ZFS)
[http://docs.oracle.com/cd/E19253-01/819-5461/index.html](Solaris ZFS Guide)
[http://jeanbruenn.info/2011/01/18/setting-up-zfs-with-3-out-of-4-discs-raidz/](Setting up ZFS with 3 out of 4 discs)
[http://www.freebsddiary.org/zfs-resizing.php](FreeBSD diary on ZFS resizing)

[http://www.datadisk.co.uk/html_docs/sun/sun_zfs_cs.htm](ZFS cheatsheet)


Creating a sparse file: `dd if=/dev/zero bs=1024k count=1 seek=400000 of=/path/to/vdev_file`
