# Command Reference: Linux, AIX, Windows

This file contains commands for **Linux, AIX, and Windows**, organized by skill levels: **Basic, Intermediate, Advanced, Expert, Should Know**.  
Each OS section and skill level is **collapsible** for GitHub-friendly viewing.

---


Linux 🐧
<details> <summary>⚡ Basic Commands (20)</summary>

  - `pwd` : **Print working directory**

> /home/username


ls : List directory contents

bash
Desktop Documents Downloads Music Pictures Videos
cd : Change directory

bash
cd Documents
[Changes to Documents directory]
mkdir : Make new directory

bash
mkdir new_folder
rmdir : Remove empty directory

bash
rmdir old_folder
touch : Create empty file or update timestamp

bash
touch file.txt
cp : Copy files or directories

bash
cp file.txt backup.txt
mv : Move or rename files/directories

bash
mv oldname.txt newname.txt
rm : Remove files

bash
rm file.txt
cat : Display file contents

bash
cat file.txt
Hello World
echo : Print text to terminal

bash
echo "Hello World"
Hello World
clear : Clear terminal screen

bash
[screen cleared]
date : Show current date and time

bash
Mon Oct  6 00:00:00 IST 2025
whoami : Show current user

bash
username
uname : Show system information

bash
Linux
df : Show disk space usage

bash
Filesystem     1K-blocks  Used Available Use% Mounted on
/dev/sda1      20511356 823456  18679900  5% /
free : Display memory usage

bash
              total        used        free      shared  buff/cache   available
Mem:           7982        2048        3290         250        2644        5230
ps : List running processes

bash
  PID TTY          TIME CMD
 1234 pts/0    00:00:01 bash
kill : Terminate process by PID

bash
kill 1234
man : Show manual pages

bash
[Displays manual for the command]
💡 Tips:

Use ls -la to list all files including hidden with permissions.

Use tab key for autocompletion.

cd .. moves up one directory.

Commands are case-sensitive.

Use man <command> to learn about options.

</details>
<details> <summary>🔧 Intermediate Commands (20)</summary>
grep : Search text in files

bash
grep 'pattern' file.txt
pattern found in line
find : Find files and directories

bash
find . -name "*.txt"
./docs/file.txt
chmod : Change file permissions

bash
chmod 755 script.sh
chown : Change file owner

bash
chown user file.txt
tar : Archive files

bash
tar -cvf archive.tar folder/
Archive created
gzip : Compress files

bash
gzip file.txt
top : Monitor system processes

bash
[interactive process list display]
ssh : Remote login to another machine

bash
ssh user@host
wget : Download files from web

bash
wget http://example.com/file
curl : Transfer data from or to server

bash
curl http://example.com
history : Show command history

bash
1 ls
2 cd
alias : Create command shortcuts

bash
alias ll='ls -l'
diff : Compare two files

bash
diff file1.txt file2.txt
uname -a : Show detailed system info

bash
Linux hostname 5.4.0-42-generic x86_64 GNU/Linux
df -h : Show disk space in human readable

bash
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       20G  7.5G   12G  38% /
du -sh : Show folder size

bash
du -sh /home/user
2.5G    /home/user
ps aux : List all running processes

bash
root     1  0.0  0.1  22504  1148 ?        Ss   Oct05   0:06 /sbin/init
netstat : Display network connections

bash
Active Internet connections
sudo : Run command as superuser

bash
sudo apt update
service : Manage system services

bash
service nginx start
💡 Tips:

Use sudo !! to rerun last command as root.

grep -i for case-insensitive searches.

Use curl -O to save file with original name.

Use tar -xvf to extract archives.

Monitor system with htop if installed.

</details>
<details> <summary>🚀 Advanced Commands (20)</summary>
iptables : Configure firewall rules

bash
iptables -L
strace : Trace system calls

bash
strace ls
lsof : List open files

bash
lsof -i :80
tcpdump : Capture network packets

bash
tcpdump -i eth0
rsync : Remote file sync

bash
rsync -av src/ dest/
dd : Copy and convert files

bash
dd if=/dev/sda of=/dev/sdb bs=4M
nc : Netcat - for network debugging

bash
nc -l 1234
cron : Schedule jobs

bash
crontab -e
useradd : Add new user

bash
useradd john
passwd : Change user password

bash
passwd john
journalctl : Read systemd logs

bash
journalctl -u nginx
systemctl : Manage systemd services

bash
systemctl restart nginx
mount : Mount filesystems

bash
mount /dev/sdb1 /mnt
umount : Unmount filesystems

bash
umount /mnt
awk : Pattern scanning and processing

bash
awk '{print $1}' file
sed : Stream editor

bash
sed 's/old/new/g' file
cut : Extract fields from lines

bash
cut -d',' -f1 file.csv
basename : Show filename from path

bash
basename /path/to/file.txt
file.txt
dirname : Show directory part of path

bash
dirname /path/to/file.txt
/path/to
openssl : Cryptographic toolkit

bash
openssl version
💡 Tips:

Use iptables-save to back up firewall rules.

strace -p <pid> to attach to running process.

Use rsync -z to compress data during transfer.

Use awk to perform complex data extractions.

Use systemctl status to check service health.

</details>
<details> <summary>🏆 Expert Commands (20)</summary>
tcpflow : Capture and reconstruct TCP flows

bash
tcpflow -i eth0
perf : Performance analysis tool

bash
perf stat ls
ip : Advanced network management

bash
ip addr
ss : Display socket statistics

bash
ss -tuln
cgroups : Control groups management

bash
cgcreate -g cpu:/test
bpftrace : Dynamic tracing with BPF

bash
bpftrace -e 'tracepoint:syscalls:sys_enter_execve { printf("%s\n", comm); }'
ethtool : Network interface settings

bash
ethtool eth0
tc : Traffic control for networking

bash
tc qdisc show dev eth0
strace -f : Trace child processes

bash
strace -f bash
lldpad : LLDP protocol daemon

bash
systemctl start lldpad
tcpkill : Kill specified TCP connections

bash
tcpkill -i eth0 host 192.168.1.100
ipset : Manage IP sets for firewall

bash
ipset create blacklist hash:ip
nslookup : DNS queries

bash
nslookup google.com
dig : More powerful DNS querying

bash
dig google.com
vmstat : System performance statistics

bash
vmstat 1 5
iostat : CPU and I/O statistics

bash
iostat -xz 1 3
strace -e trace=file : Trace filesystem calls

bash
strace -e trace=file ls
ip rule : Configure routing policy rules

bash
ip rule add from 192.168.1.10 table 100
tcpdump -w : Write packets to file

bash
tcpdump -w capture.pcap
sar : Collect and report system activity

bash
sar -u 1 3
💡 Tips:

Use perf record and perf report for profiling.

Combine ss with filters for deep socket inspection.

Use bpftrace scripts for custom kernel probes.

tcpdump requires root privileges.

ip is preferred over deprecated ifconfig.

</details>
<details> <summary>📘 Should Know Commands (20)</summary>
systemctl list-units : List active systemd units

bash
systemctl list-units
journalctl -f : Follow system logs in realtime

bash
journalctl -f
nmcli : NetworkManager CLI tool

bash
nmcli device status
tcping : Ping over TCP

bash
tcping google.com 80
watch : Run command periodically

bash
watch -n 2 df -h
getent : Get entries from databases

bash
getent passwd
swapoff : Disable swap space

bash
swapoff -a
swapon : Enable swap space

bash
swapon -a
hostnamectl : Get or set hostname

bash
hostnamectl
tcpflow : Capture TCP flows

bash
tcpflow -i eth0
bg : Send job to background

bash
bg
fg : Bring job to foreground

bash
fg
jobs : List current jobs

bash
jobs
set : Set shell options and variables

bash
set -o
ulimit : Control user resource limits

bash
ulimit -a
chmod +x : Make script executable

bash
chmod +x script.sh
pkill : Kill process by name

bash
pkill firefox
tcpdump -i lo : Capture loopback traffic

bash
tcpdump -i lo
uptime : Show system uptime

bash
 12:00:00 up 5 days,  3:45,  1 user,  load average: 0.00, 0.02, 0.05
last : Show login history

bash
last
💡 Tips:

Use watch to monitor changes live.

Combine getent with grep to filter database entries.

pkill for terminating multiple related processes.

Use jobs, fg, bg to manage shell jobs.

Regularly check logs with journalctl.

</details>
AIX 💻
<details> <summary>⚡ Basic Commands (20)</summary>
pwd : Print current directory

bash
/home/aix_user
ls : List directory contents

bash
bin  etc  home  usr  tmp
cd : Change directory

bash
cd /usr
cp : Copy files or directories

bash
cp file.txt backup.txt
mv : Move or rename files

bash
mv oldname newname
rm : Remove files

bash
rm file.txt
mkdir : Create directory

bash
mkdir newdir
rmdir : Remove empty directory

bash
rmdir olddir
cat : Display file contents

bash
cat file.txt
more : Paginate output

bash
more file.txt
echo : Display text/string

bash
echo "Hello AIX"
date : Show date/time

bash
Mon Oct 6 00:00:00 EDT 2025
whoami : Current username

bash
aix_user
uname : System info

bash
AIX
df : Disk space usage

bash
Filesystem    512-blocks      Used Available Capacity Mounted on
/dev/hd4       5242880   2000000  3242880    38%    /
ps : List processes

bash
  PID TTY      TIME CMD
 1234 pts/0  00:00:01 ksh
kill : Kill process by PID

bash
kill 1234
smit : System Management Interface Tool GUI

bash
[Graphical interface appears]
file : Determine file type

bash
file /bin/ls
/bin/ls: ELF 32-bit LSB executable
man : Manual pages

bash
[shows manual page]
💡 Tips:

Use ls -l for detailed list with permissions.

smit is useful for admin tasks via GUI.

Use file to quickly know file type.

Use more to scroll through large files.

man pages contain detailed command info.

</details>
<details> <summary>🔧 Intermediate Commands (20)</summary>
lslpp -L : List installed software packages

bash
lslpp -L
Fileset                 Level  State
bos.rte                 7.1.0  COMMITTED
instfix -ik IX99999 : Check if a fix is installed

bash
instfix -ik IX99999
Fix installed
oslevel : Show OS level

bash
7.2.0.0
chuser : Change user attributes

bash
chuser shell=/usr/bin/ksh user1
lsattr : List device attributes

bash
lsattr -El hdisk0
name           value  description
chggrp : Change group ownership

bash
chggrp staff file.txt
chgrp : Change file group

bash
chgrp staff file.txt
exportfs : Export NFS directories

bash
exportfs
mount : Mount file system

bash
mount /dev/hd1 /mnt
umount : Unmount file system

bash
umount /mnt
netstat : Show network status

bash
Active Internet connections
ping : Network connectivity test

bash
ping google.com
errpt : Show error report

bash
USER         T S PID   MESSAGE
root         P  1234  Disk error detected
chkpwd : Change password interactively

bash
chkpwd
lsvg : List volume groups

bash
lsvg
rootvg
lslv : List logical volumes

bash
lslv rootvg
lsdev : List devices

bash
lsdev
hdisk0
lspv : List physical volumes

bash
lspv
hdisk0
sync : Flush filesystem buffers

bash
sync
who : Show logged in users

bash
user1 pts/0
💡 Tips:

Use lslpp -L | grep <package> to find specific software.

errpt -a gives detailed error info.

Combine lsvg and lslv to understand storage.

ping -c 4 for limited ping count.

Use netstat -rn for route table.

</details>
<details> <summary>🚀 Advanced Commands (20)</summary>
aixpert : Security configuration assistant

bash
aixpert
alt_disk_copy : Copy running system to alternate disk

bash
alt_disk_copy
adb : Advanced debugger

bash
adb -k
ac : Print connect-time records

bash
ac

acctcms : Summarize command usage

bash
acctcms
account : Turn on accounting

bash
account on
acctcom : Show process accounting summaries

bash
acctcom
alog : Maintain fixed-size logs

bash
alog -o -t boot
autoconf6 : Configure IPv6 interfaces at boot

bash
autoconf6
banner : Print ASCII banners

bash
banner Hello
bindprocessor : Bind process threads to CPUs

bash
bindprocessor -p 1234 0
bootparamd : Boot parameter server

bash
bootparamd
bootpd : Boot protocol daemon

bash
bootpd
bugfiler : Collect bug reports

bash
bugfiler
cb : Format C programs

bash
cb program.c
cfgenv : Configure environment variables

bash
cfgenv
cfgif : Configure TCP/IP interfaces

bash
cfgif
chauthent : Change authentication settings

bash
chauthent
chmod : Change file permissions

bash
chmod 755 file
chlang : Set system language

bash
chlang En_US
💡 Tips:

aixpert helps harden security.

Use alt_disk_copy for backup.

adb can debug core dumps.

acctcms helps analyze command usage.

bindprocessor optimizes CPU usage.

</details>
<details> <summary>🏆 Expert Commands (20)</summary>
cache_mgt : Manage SSD cache infrastructure

bash
cache_mgt status
certcreate : Create new certificates

bash
certcreate
certget : Retrieve certificate from LDAP

bash
certget
cfgenv : Configure environment variables

bash
cfgenv
chgnetaddr : Change network addresses

bash
chgnetaddr en0
chnamsv : Modify TCP/IP name service config

bash
chnamsv
conserver : Console server management

bash
conserver
ctstat : Cluster status

bash
ctstat
defvsd : Define virtual shared disks

bash
defvsd
devinstall : Install device software

bash
devinstall
dispgid : Display group IDs

bash
dispgid
emstat : Emulation exception stats

bash
emstat
errlg : Error log manager

bash
errlg -n
fastboot : Fast reboot

bash
fastboot
filemon : File system monitoring

bash
filemon
fwtmp : Manipulate accounting records

bash
fwtmp
getconf : Show system limits and configs

bash
getconf ARG_MAX
gencore : Generate core dump

bash
gencore 1234
glbd : Global location broker management

bash
glbd
hpmstat : Hardware performance monitoring

bash
hpmstat
💡 Tips:

Use certcreate and certget for certificate management.

errlg -n to view recent errors.

Use filemon to track file/system I/O.

fastboot requires no other users logged in.

Use getconf before scripts for environment info.

</details>
<details> <summary>📘 Should Know Commands (20)</summary>
aclconvert : Convert file ACL types

bash
aclconvert
aclget : Display ACL info

bash
aclget /path/to/file
addbib : Manage bibliographic databases

bash
addbib
addrpnode : Add nodes to peer domain

bash
addrpnode
admin : Source Code Control System admin

bash
admin
alog : Advanced logging utility

bash
alog
Authexec : Run RBAC privileged commands

bash
Authexec
autoconf6 : Configure IPv6 interfaces

bash
autoconf6
banner : Print text banners

bash
banner "Welcome"
Basename : Strip directory path from filename

bash
basename /etc/passwd
passwd
batch : Run commands at low load

bash
batch
bc : Arbitrary precision calculator

bash
bc
bellmail : Send messages to users

bash
bellmail user1
bindintcpu : Bind interrupt to CPU

bash
bindintcpu
bindprocessor : Bind threads to processors

bash
bindprocessor
bootauth : Check user at boot

bash
bootauth
calender : Display calendar events

bash
calender
cat : Concatenate and display files

bash
cat file.txt
certget : Get certificate

bash
certget
cfgenv : Configure environment variables

bash
cfgenv
💡 Tips:

Use banner to create large ASCII headings.

batch schedules commands when load is low.

bc is useful for calculations in shell.

Use Basename to parse filenames.

ACL tools help manage file permissions finely.

</details>
Windows 🪟
<details> <summary>⚡ Basic Commands (20)</summary>
dir : List directory contents

powershell
 Volume in drive C is Windows
 Volume Serial Number is XXXX-XXXX

 Directory of C:\Users\User

10/06/2025  12:00 AM    <DIR>          Documents
10/06/2025  12:00 AM    <DIR>          Downloads
               0 File(s)              0 bytes
cd : Change directory

powershell
C:\Users\User> cd Documents
C:\Users\User\Documents>
cls : Clear screen

powershell
[screen cleared]
copy : Copy files

powershell
copy file.txt backup.txt
1 file(s) copied.
del : Delete files

powershell
del file.txt
mkdir : Make directory

powershell
mkdir newfolder
rmdir : Remove directory

powershell
rmdir oldfolder
type : Display file content

powershell
type file.txt
Hello World
echo : Print text

powershell
echo Hello World
Hello World
date : Display or set date

powershell
Current date: 10/06/2025
time : Display or set time

powershell
Current time: 12:00 AM
ipconfig : Show network config

powershell
Windows IP Configuration

Ethernet adapter Local Area Connection:
   IPv4 Address. . . . . . . . . . . : 192.168.1.100
tasklist : Show running processes

powershell
Image Name                     PID Session Name        Session#    Mem Usage
========================= ======== ================ =========== ==========
notepad.exe                  1234 Console                    1      10,000 K
taskkill : Kill process

powershell
taskkill /PID 1234 /F
SUCCESS: The process with PID 1234 has been terminated.
help : Get help info

powershell
[Displays help topics]
shutdown : Shutdown or restart machine

powershell
shutdown /s
systeminfo : Show system info

powershell
Host Name:                 USER-PC
OS Name:                   Microsoft Windows 10 Pro
OS Version:                10.0.19042 Build 19042
whoami : Current user name

powershell
user
hostname : Show computer name

powershell
USER-PC
💡 Tips:

Use dir /a to list hidden files.

Use tasklist and taskkill to manage processes.

Use ipconfig /all for detailed network info.

Use help to learn about commands.

cls clears the console screen.

</details>
<details> <summary>🔧 Intermediate Commands (20)</summary>
ping : Test network connectivity

powershell
ping google.com
Pinging google.com [172.217.11.14] with 32 bytes of data:
Reply from 172.217.11.14: bytes=32 time=14ms TTL=54
tracert : Trace route packets

powershell
tracert google.com
netstat : Show network connections

powershell
Active Connections
  Proto  Local Address          Foreign Address        State
  TCP    192.168.1.100:139     192.168.1.101:52688   ESTABLISHED
ipconfig /release : Release DHCP IP

powershell
Windows IP Configuration

 DHCP release failed.
ipconfig /renew : Renew DHCP IP

powershell
Windows IP Configuration

IPv4 Address. . . . . . . . . . . : 192.168.1.100
net user : Manage users

powershell
net user
net localgroup : List local groups

powershell
net localgroup
sc : Service control

powershell
sc query
schtasks : Schedule tasks

powershell
schtasks /query
powershell : Start PowerShell shell

powershell
PS C:\>
assoc : Show file associations

powershell
.txt=txtfile
fc : File compare

powershell
fc file1.txt file2.txt
tasklist /svc : List services for processes

powershell
tasklist /svc
diskpart : Disk partitioning tool

powershell
DISKPART>
cipher : Encrypt/decrypt files

powershell
cipher /e file.txt
driverquery : List installed drivers

powershell
driverquery
gpupdate : Update Group Policy

powershell
gpupdate
hostname : Show system hostname

powershell
USER-PC
shutdown /r : Restart system

powershell
shutdown /r
sfc /scannow : System file checker

powershell
Beginning system scan...
💡 Tips:

Use tracert to diagnose routing problems.

Use netstat -an for all connections.

schtasks to automate jobs.

sfc /scannow repairs system files.

sc to view and manage services.

</details>
<details> <summary>🚀 Advanced Commands (20)</summary>
PowerShell ISE : Graphical PowerShell editor

powershell
Start powershell_ise
Get-Process : List running processes

powershell
Get-Process
Get-Service : List Windows services

powershell
Get-Service
Set-ExecutionPolicy : Change script execution policy

powershell
Set-ExecutionPolicy RemoteSigned
Get-EventLog : Read event logs

powershell
Get-EventLog -LogName System
New-Item : Create files or folders

powershell
New-Item -Path "C:\test.txt" -ItemType File
Remove-Item : Delete files or folders

powershell
Remove-Item "C:\test.txt"
Get-Content : Read file contents

powershell
Get-Content "C:\test.txt"
Set-Content : Write to a file

powershell
"Hello" | Set-Content "C:\test.txt"
Invoke-WebRequest : Download web content

powershell
Invoke-WebRequest http://example.com
Test-Connection : Ping test equivalent

powershell
Test-Connection google.com
Get-NetIPAddress : Show IP address info

powershell
Get-NetIPAddress
Restart-Service : Restart a service

powershell
Restart-Service wuauserv
Get-Command : List all commands

powershell
Get-Command
Export-Csv : Export data to CSV

powershell
Get-Process | Export-Csv processes.csv
Import-Csv : Import CSV data

powershell
Import-Csv processes.csv
Get-Help : Show help on commands

powershell
Get-Help Get-Process
Measure-Object : Calculate properties of objects

powershell
Get-Content file.txt | Measure-Object -Line
Format-Table : Format output as a table

powershell
Get-Process | Format-Table -AutoSize
Select-Object : Select specific object properties

powershell
Get-Process | Select-Object Name,Id
💡 Tips:

Use PowerShell for automation.

Get-Help is the best friend.

Use Format-Table to beautify output.

Invoke-WebRequest for REST calls.

Always check script execution policies.

</details>
<details> <summary>🏆 Expert Commands (20)</summary>
Get-WmiObject : Access WMI information

powershell
Get-WmiObject Win32_OperatingSystem
New-PSSession : Create remote PowerShell session

powershell
New-PSSession -ComputerName SERVER01
Invoke-Command : Run commands on remote session

powershell
Invoke-Command -Session $s -ScriptBlock { Get-Process }
Register-ScheduledJob : Register background jobs

powershell
Register-ScheduledJob -Name "Job1" -ScriptBlock { Get-Process }
Get-ADUser : Get Active Directory user info (requires AD module)

powershell
Get-ADUser -Identity "jdoe"
Set-ADUser : Modify AD user properties

powershell
Set-ADUser -Identity "jdoe" -Title "Manager"
New-ADUser : Create new AD user

powershell
New-ADUser -Name "John Doe"
Remove-ADUser : Delete AD user

powershell
Remove-ADUser -Identity "jdoe"
Get-EventLog -FilterHashtable : Filter event logs

powershell
Get-EventLog -LogName System -EntryType Error
Install-WindowsFeature : Add Windows features

powershell
Install-WindowsFeature -Name Web-Server
Uninstall-WindowsFeature : Remove Windows features

powershell
Uninstall-WindowsFeature -Name Web-Server
Backup-Job : Create backups (custom scripts)

powershell
# Custom backup script
Start-Transcript : Record PowerShell session

powershell
Start-Transcript -Path transcript.txt
Stop-Transcript : Stop recording session

powershell
Stop-Transcript
Measure-Command : Measure execution time

powershell
Measure-Command { Get-Process }
Get-ChildItem : List files and directories

powershell
Get-ChildItem -Recurse
New-ItemProperty : Create registry entries

powershell
New-ItemProperty -Path "HKLM:\Software" -Name "Test" -Value 1
Remove-ItemProperty : Delete registry entries

powershell
Remove-ItemProperty -Path "HKLM:\Software" -Name "Test"
CheckPoint : Create system restore point (via GUI or system tools)

Invoke-Sqlcmd : Run SQL commands (with SQL module)

powershell
Invoke-Sqlcmd -Query "SELECT TOP 10 * FROM dbo.Table"
💡 Tips:

Remote management via PowerShell is powerful.

Regularly back up PowerShell transcript.

Active Directory module is a must for admins.

Use Measure-Command to benchmark.

Registry manipulation requires caution.

</details>
<details> <summary>📘 Should Know Commands (20)</summary>
wmic : WMI command-line

powershell
wmic cpu get name
schtasks /create : Schedule tasks

powershell
schtasks /create /tn "Backup" /tr "backup.bat" /sc daily
fsutil : File system utility

powershell
fsutil dirty query C:
powercfg : Power settings management

powershell
powercfg /energy
reg : Registry command line

powershell
reg query HKLM\Software
netsh : Network shell utility

powershell
netsh wlan show profiles
whoami /groups : Show user groups

powershell
whoami /groups
openfiles : List open files on network

powershell
openfiles /query
fsutil : Manage sparse files

powershell
fsutil sparse queryflag C:\file.txt
defrag : Disk defragmenter

powershell
defrag C:
systeminfo : Detailed system info

powershell
systeminfo
netstat -ano : Show connections with PID

powershell
netstat -ano
chkdsk : Check disk for errors

powershell
chkdsk C:
robocopy : Robust copy command

powershell
robocopy C:\Source C:\Dest /E
powershell -ExecutionPolicy : Run scripts with policy

powershell
powershell -ExecutionPolicy Bypass -File script.ps1
Get-Volume : Disk volume info

powershell
Get-Volume
Get-Process -Id : Process info by PID

powershell
Get-Process -Id 1234
Get-Module : Show loaded modules

powershell
Get-Module
Repair-WindowsImage : Fix Windows images

powershell
Repair-WindowsImage -Online -RestoreHealth
Enable-PSRemoting : Enable remote PowerShell

powershell
Enable-PSRemoting
💡 Tips:

Use wmic for deep Windows queries.

robocopy is superior for batch file copies.

Enable-PSRemoting is critical for remote admin.

Regularly chkdsk for disk health.

netsh provides granular network controls.

</details>
