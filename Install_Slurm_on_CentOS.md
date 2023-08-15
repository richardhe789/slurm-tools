# Install Slurm on CentOS

## CentOS repo
http://mirror.centos.org/centos/7/os/x86_64/Packages/

## install mariadb
```
# yum install mariadb-server.x86_64
```

## install gcc
```
# yum install gcc.x86_64
```

## install munge 
```
# yum install openssl.x86_64
# yum install openssl-devel.x86_64 openssl-libs.x86_64
# yum install zlib
# yum install bzip2.x86_64
# wget https://github.com/dun/munge/releases/download/munge-0.5.13/munge-0.5.13.tar.xz
#  tar xJf munge-0.5.13.tar.xz
# cd munge-0.5.13
# ./configure
# make
# make check
# make install

# ls /usr/local/include
munge.h
# ls /usr/local/lib
libmunge.a  libmunge.la  libmunge.so  libmunge.so.2  libmunge.so.2.0.0  pkgconfig  systemd  tmpfiles.d

# ls /usr/local/bin
munge  remunge  unmunge
```

## Install Python
```
# yum install python3.x86_64
```

## Install Slurm
```
# wget https://download.schedmd.com/slurm/slurm-21.08.8.tar.bz2

# tar -xvf slurm-21.08.8.tar
# cd  slurm-21.08.8
# ./configure
# make
# make install
# ls /usr/local/lib
libmunge.a   libmunge.so    libmunge.so.2.0.0  libslurm.la  libslurm.so.37      pkgconfig  systemd
libmunge.la  libmunge.so.2  libslurm.a         libslurm.so  libslurm.so.37.0.0  slurm      tmpfiles.d

# ls /usr/local/bin
munge    sacct     salloc   sbatch  scancel   scrontab  sinfo  squeue   srun    sstat     unmunge
remunge  sacctmgr  sattach  sbcast  scontrol  sdiag     sprio  sreport  sshare  strigger

# ls /usr/local/include/slurm/
pmi.h  slurmdb.h  slurm_errno.h  slurm.h  slurm_version.h  smd_ns.h  spank.h

# ls /usr/local/sbin
munged  slurmctld  slurmd  slurmdbd  slurmstepd

# /usr/local/sbin/slurmd -C
NodeName=nonet CPUs=1 Boards=1 SocketsPerBoard=1 CoresPerSocket=1 ThreadsPerCore=1 RealMemory=1839
UpTime=0-02:05:41

This is the full version of the Slurm configuration tool. This version has all the configuration options to create a Slurm configuration file.
groupadd slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm  -g slurm  -s /bin/bash slurm

groupadd munge
$ useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -g munge  -s /sbin/nologin munge

# tail -2 /etc/passwd
slurm:x:1000:1000:SLURM workload manager:/var/lib/slurm:/bin/bash
munge:x:1001:1001:MUNGE Uid 'N' Gid Emporium:/var/lib/munge:/sbin/nologin
```

Read 
/usr/local/share/doc/slurm-21.08.8/html/configurator.html .

There is a simplified version of the Slurm configuration tool available 
/usr/local/share/doc/slurm-21.08.8/html/configurator.easy.html

## Slurm databaase
```
# systemctl start mariadb

[root@ html]# mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!
#  mysql -u root -p  3990
MariaDB [(none)]> grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by 'some_pass' with grant option;
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> create database slurm_acct_db;
Query OK, 1 row affected (0.00 sec)

# vi /usr/local/etc/slurmdbd.conf
  AuthType=auth/munge
  DbdAddr=127.0.0.1
  DbdHost=nonet
  SlurmUser=slurm
  DebugLevel=4
  LogFile=/var/log/slurm/slurmdbd.log
  PidFile=/var/run/slurmdbd.pid
  StorageType=accounting_storage/mysql
  StorageHost=nonet
  StoragePass=some_pass
  StorageUser=slurm
  StorageLoc=slurm_acct_db

[root@nonet html]# vi /usr/local/etc/slurmdbd.conf
[root@nonet html]# /usr/local/sbin/slurmdbd
slurmdbd: fatal: slurmdbd.conf file /usr/local/etc/slurmdbd.conf should be 600 is 644 accessible for group or others
[root@nonet html]# chmod 600 /usr/local/etc/slurmdbd.conf

[root@nonet html]# /usr/local/sbin/slurmdbd -vvv
slurmdbd: fatal: slurmdbd.conf not owned by SlurmUser root!=slurm
[root@nonet html]# ll /usr/local/etc/slurmdbd.conf
-rw-------. 1 root root 289 Jul 20 12:33 /usr/local/etc/slurmdbd.conf
[
[root@nonet html]# ll /usr/local/etc/slurmdbd.conf
-rw-------. 1 root root 289 Jul 20 12:33 /usr/local/etc/slurmdbd.conf
[root@nonet html]# chown slurm:slurm /usr/local/etc/slurmdbd.conf
[root@nonet html]# ll /usr/local/etc/slurmdbd.conf
-rw-------. 1 slurm slurm 289 Jul 20 12:33 /usr/local/etc/slurmdbd.conf
[
[root@nonet html]# /usr/local/sbin/slurmdbd -vvv
(null): _log_init: Unable to open logfile `/var/log/slurm/slurmdbd.log': No such file or directory
[root@nonet html]# ll /var/log/slurm/
ls: cannot access /var/log/slurm/: No such file or directory
[root@nonet html]# mkdir /var/log/slurm/
[root@nonet html]# chown slurm:slurm /var/log/slurm/

[root@nonet html]# /usr/local/sbin/slurmdbd -vvv
```

## Add munge libary
```
# ldd /usr/local/lib/slurm/auth_munge.so
        linux-vdso.so.1 =>  (0x00007ffe905fd000)
        libmunge.so.2 => not found
        libm.so.6 => /lib64/libm.so.6 (0x00007f500431f000)
        libresolv.so.2 => /lib64/libresolv.so.2 (0x00007f5004105000)
        libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f5003ee9000)
        libc.so.6 => /lib64/libc.so.6 (0x00007f5003b1a000)
        /lib64/ld-linux-x86-64.so.2 (0x00005570853cd000)
[root@nonet html]# find /usr/local -name "libmunge.so.2"
/usr/local/lib/libmunge.so.2

[root@nonet html]# ll  /etc/ld.so.conf.d/
total 8
-r--r--r--. 1 root root 63 Aug 22  2017 kernel-3.10.0-693.el7.x86_64.conf
-rw-r--r--. 1 root root 17 Oct  1  2020 mariadb-x86_64.conf
[root@nonet html]# vi /etc/ld.so.conf.d/slurm-munge.conf
[root@nonet html]# ll  /etc/ld.so.conf.d/
total 12
-r--r--r--. 1 root root 63 Aug 22  2017 kernel-3.10.0-693.el7.x86_64.conf
-rw-r--r--. 1 root root 17 Oct  1  2020 mariadb-x86_64.conf
-rw-r--r--. 1 root root 15 Jul 20 12:40 slurm-munge.conf
[root@nonet html]# cat /etc/ld.so.conf.d/slurm-munge.conf
/usr/local/lib

root@nonet log]# ls /usr/local/etc/munge/
[root@nonet log]#
# chown munge:munge "/usr/local/var/log/munge"
echo "helloeveryone." > /usr/local/etc/munge/munge.key
chown munge:munge /usr/local/etc/munge/munge.key
# chown  munge:munge /usr/local/etc/munge
#  chown munge:munge "/usr/local/var/run/munge/"
chmod 400 /usr/local/etc/munge/munge.key
#  munge -n
MUNGE:AwQFAADkEi4s6c0pDaiII+RL4e0obLbWY2CdK4qsh4DSUkXdz7ymWs9WgI85tUsp2XrQ4vvYPMz+3eDynvUOmmToYkzPJqBiZWvl8xKRPMnSSuJygfi69kMFaOvy+pfNYQrmoHc=:

# munge -n | unmunge
STATUS:           Success (0)
ENCODE_HOST:      localhost (127.0.0.1)
ENCODE_TIME:      2023-07-20 16:54:33 -0500 (1674251673)
DECODE_TIME:      2023-07-20 16:54:33 -0500 (1674251673)
TTL:              300
CIPHER:           aes128 (4)
MAC:              sha256 (5)
ZIP:              none (0)
UID:              root (0)
GID:              root (0)
LENGTH:           0

sudo -u munge /usr/local/sbin/munged

# munge -n -t 10 | ssh nonet unmunge
root@nonet's password:
STATUS:           Success (0)
ENCODE_HOST:      localhost (127.0.0.1)
ENCODE_TIME:      2023-07-20 16:55:44 -0500 (1674251744)
DECODE_TIME:      2023-07-20 16:55:48 -0500 (1674251748)
TTL:              10
CIPHER:           aes128 (4)
MAC:              sha256 (5)
ZIP:              none (0)
UID:              root (0)
GID:              root (0)
LENGTH:           0
```

## File permissions
```
[root@nonet local]# mkdir /var/spool/slurmctld
[root@nonet local]# ll /var/spool/slurmctld
total 0
[root@nonet local]# chown slurm:slurm /var/spool/slurmctld
# /usr/local/bin/sinfo -V
slurm 21.08.8
# /usr/local/bin/scontrol show node nonet
NodeName=nonet Arch=x86_64 CoresPerSocket=1
   CPUAlloc=0 CPUTot=1 CPULoad=0.01
   AvailableFeatures=(null)
   ActiveFeatures=(null)
   Gres=(null)
   NodeAddr=nonet NodeHostName=nonet Version=21.08.8
   OS=Linux 3.10.0-693.el7.x86_64 #1 SMP Tue Aug 22 21:09:27 UTC 2017
   RealMemory=1 AllocMem=0 FreeMem=89 Sockets=1 Boards=1
   State=IDLE ThreadsPerCore=1 TmpDisk=0 Weight=1 Owner=N/A MCS_label=N/A
   Partitions=newpart
   BootTime=2023-07-20T09:58:57 SlurmdStartTime=2023-07-20T13:14:44
   LastBusyTime=2023-07-20T13:14:45
   CfgTRES=cpu=1,mem=1M,billing=1
   AllocTRES=
   CapWatts=n/a
   CurrentWatts=0 AveWatts=0
   ExtSensorsJoules=n/s ExtSensorsWatts=0 ExtSensorsTemp=n/s
```
refer
https://southgreenplatform.github.io/trainings/hpc/slurminstallation/

https://slurm.schedmd.com/quickstart_admin.html
