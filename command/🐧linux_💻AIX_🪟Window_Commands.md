# Command Reference: Linux, AIX, Windows

This file contains commands for **Linux, AIX, and Windows**, organized by skill levels: **Basic, Intermediate, Advanced, Expert, Should Know**.  
Each OS section and skill level is **collapsible** for GitHub-friendly viewing.

---


Linux 🐧
<details> <summary>⚡ Basic Commands (20)</summary>


1. `ls` : List directory contents  
2. `pwd` : Print working directory  
3. `cd <dir>` : Change directory  
4. `cp <src> <dest>` : Copy files/directories  
5. `mv <src> <dest>` : Move/rename files  
6. `rm <file>` : Remove files  
7. `mkdir <dir>` : Create a directory  
8. `rmdir <dir>` : Remove empty directory  
9. `cat <file>` : Display file contents  
10. `echo <text>` : Print text  
11. `touch <file>` : Create empty file  
12. `whoami` : Show current user  
13. `date` : Show system date/time  
14. `uptime` : Show system uptime  
15. `df -h` : Disk usage in human-readable format  
16. `du -sh <dir>` : Show directory size  
17. `free -h` : Show memory usage  
18. `uname -a` : Display system info  
19. `hostname` : Show system hostname  
20. `man <command>` : Show manual page  

## 💡 Tips:
- Use ls -la to list all files including hidden with permissions.
- Use tab key for autocompletion.
- cd .. moves up one directory.
- Commands are case-sensitive.
- Use man <command> to learn about options.

</details>
<details> <summary>🔧 Intermediate Commands (20)</summary>

1. `grep <pattern> <file>` : Search for text in files  
2. `awk '{print $1}' <file>` : Text processing  
3. `sed 's/old/new/g' <file>` : Stream editor replacement  
4. `cut -d':' -f1 <file>` : Extract columns  
5. `sort <file>` : Sort file content  
6. `uniq <file>` : Remove duplicates  
7. `diff <file1> <file2>` : Compare files  
8. `wc -l <file>` : Count lines  
9. `head -n 10 <file>` : Show first 10 lines  
10. `tail -f <file>` : Monitor file in real-time  
11. `crontab -l` : List cron jobs  
12. `crontab -e` : Edit cron jobs  
13. `rsync -av <src> <dest>` : Sync files/directories  
14. `ping <host>` : Check connectivity  
15. `netstat -tuln` : Show active network connections  
16. `lsof -i :<port>` : Open files by port  
17. `df -Th` : Disk usage with filesystem type  
18. `systemctl status <service>` : Check service status  
19. `git status` : Check git repository status  
20. `docker ps` : List running containers  

💡 Tips:

Use sudo !! to rerun last command as root.
grep -i for case-insensitive searches.
Use curl -O to save file with original name.
Use tar -xvf to extract archives.
Monitor system with htop if installed.

</details>
<details> <summary>🚀 Advanced Commands (20)</summary>
  
1. `tcpdump -i <interface>` : Capture network traffic  
2. `traceroute <host>` : Trace route to host  
3. `nmap <host>` : Network scanning  
4. `iptables -L` : List firewall rules  
5. `chmod -R 755 <dir>` : Recursive permissions  
6. `chown -R user:group <dir>` : Recursive ownership  
7. `mount -t <fs> <device> <mountpoint>` : Mount filesystem  
8. `umount <mountpoint>` : Unmount filesystem  
9. `ssh-keygen` : Generate SSH keys  
10. `ssh-copy-id user@host` : Copy SSH key to host  
11. `scp -r <dir> user@host:<dest>` : Copy recursively  
12. `sftp user@host` : Secure file transfer  
13. `systemctl enable <service>` : Enable service  
14. `systemctl disable <service>` : Disable service  
15. `strace <command>` : Trace system calls  
16. `ltrace <command>` : Trace library calls  
17. `vmstat` : Monitor virtual memory  
18. `iostat` : Disk I/O statistics  
19. `sar -u 1 3` : CPU usage stats  
20. `docker exec -it <container> /bin/bash` : Access container  

💡 Tips:

Use iptables-save to back up firewall rules.

strace -p <pid> to attach to running process.

Use rsync -z to compress data during transfer.

Use awk to perform complex data extractions.

Use systemctl status to check service health.

</details>
<details> <summary>🏆 Expert Commands (20)</summary>

1. `perf top` : Performance profiling  
2. `perf record` : Record performance data  
3. `tcpdump -nn -vvv` : Detailed packet capture  
4. `auditctl -l` : List audit rules  
5. `ausearch -m avc` : Search audit logs  
6. `iptables-save` : Save firewall rules  
7. `rsync --delete -avz <src> <dest>` : Advanced sync  
8. `systemctl mask <service>` : Mask service  
9. `systemctl unmask <service>` : Unmask service  
10. `docker network inspect <network>` : Inspect Docker network  
11. `docker volume ls` : List Docker volumes  
12. `docker-compose up -d` : Start containers in background  
13. `journalctl -u <service>` : Logs for a service  
14. `nmcli dev status` : Network manager status  
15. `ethtool <interface>` : Network interface info  
16. `strace -p <pid>` : Trace live process  
17. `tcpdump -i any port 80` : Monitor HTTP traffic  
18. `watch -n 5 <command>` : Run command every 5 seconds  
19. `nc -l -p <port>` : Listen on port  
20. `curl -O <url>` : Download file  

💡 Tips:

Use perf record and perf report for profiling.

Combine ss with filters for deep socket inspection.

Use bpftrace scripts for custom kernel probes.

tcpdump requires root privileges.

ip is preferred over deprecated ifconfig.

</details>
<details> <summary>📘 Should Know Commands (20)</summary>
  
1. `alias ll='ls -la'` : Create alias  
2. `unalias ll` : Remove alias  
3. `export VAR=value` : Set environment variable  
4. `env` : List environment variables  
5. `source <file>` : Run script in current shell  
6. `basename <path>` : Get filename  
7. `dirname <path>` : Get directory path  
8. `readlink -f <file>` : Get absolute path  
9. `uptime` : Show system uptime  
10. `hostnamectl` : Host information  
11. `df -i` : Check inode usage  
12. `lsblk` : List block devices  
13. `blkid` : Show UUID of devices  
14. `mount | column -t` : Pretty mount info  
15. `du -ah <dir>` : Disk usage  
16. `free -m` : Memory usage in MB  
17. `journalctl --since today` : Today's logs  
18. `systemctl list-units --type=service` : List services  
19. `crontab -l -u <user>` : List user's cron jobs  
20. `history | grep <command>` : Search command history  

💡 Tips:

Use watch to monitor changes live.

Combine getent with grep to filter database entries.

pkill for terminating multiple related processes.

Use jobs, fg, bg to manage shell jobs.

Regularly check logs with journalctl.

</details>

---

AIX 💻
<details> <summary>⚡ Basic Commands (20)</summary>


1. `ls` : List directory contents  
2. `pwd` : Print working directory  
3. `cd <dir>` : Change directory  
4. `cp <src> <dest>` : Copy files  
5. `mv <src> <dest>` : Move/rename files  
6. `rm <file>` : Remove file  
7. `mkdir <dir>` : Create directory  
8. `rmdir <dir>` : Remove empty directory  
9. `cat <file>` : View file  
10. `more <file>` : View file page by page  
11. `head -n 10 <file>` : First 10 lines  
12. `tail -n 10 <file>` : Last 10 lines  
13. `touch <file>` : Create empty file  
14. `whoami` : Show user  
15. `date` : Show date/time  
16. `uname -a` : System info  
17. `oslevel -s` : Show AIX OS version  
18. `errpt` : Display system errors  
19. `uptime` : Show uptime  
20. `lsattr -El <device>` : Show device attributes  

💡 Tips:

Use ls -l for detailed list with permissions.

smit is useful for admin tasks via GUI.

Use file to quickly know file type.

Use more to scroll through large files.

man pages contain detailed command info.

</details>
<details> <summary>🔧 Intermediate Commands (20)</summary>

1. `lssrc -a` : Show subsystem status  
2. `startsrc -s <subsystem>` : Start subsystem  
3. `stopsrc -s <subsystem>` : Stop subsystem  
4. `lsdev -Cc disk` : List disks  
5. `cfgmgr` : Configure new devices  
6. `mount` : Show mounted filesystems  
7. `df -g` : Disk usage  
8. `du -sk <dir>` : Directory size in KB  
9. `lsps -a` : Show paging spaces  
10. `migratepv` : Move data between PVs  
11. `errpt -a` : Detailed error report  
12. `cron` : Schedule jobs  
13. `crontab -l` : List cron jobs  
14. `lsitab` : Show inittab entries  
15. `topas` : Real-time performance monitor  
16. `vmstat 1 5` : Memory and CPU stats  
17. `netstat -rn` : Routing table  
18. `ping <host>` : Test network  
19. `traceroute <host>` : Trace route  
20. `smit` : AIX management interface  

💡 Tips:

Use lslpp -L | grep <package> to find specific software.

errpt -a gives detailed error info.

Combine lsvg and lslv to understand storage.

ping -c 4 for limited ping count.

Use netstat -rn for route table.

</details>
<details> <summary>🚀 Advanced Commands (20)</summary>
1. `mksysb` : Create system backup  
2. `alt_disk_install` : Alternate disk installation  
3. `bosboot` : Rebuild boot image  
4. `chdev -l <device>` : Change device attributes  
5. `lsvg` : List volume groups  
6. `lsvg -p <vg>` : Show PVs in VG  
7. `lsvg -l <vg>` : Show LV in VG  
8. `migratevg` : Move PVs in VG  
9. `lspv` : Show physical volumes  
10. `extendvg` : Add PV to VG  
11. `reducevg` : Remove PV from VG  
12. `cfgmgr -v` : Reconfigure devices  
13. `errpt -c` : Count errors  
14. `snap -p` : Snapshot for diagnostics  
15. `chgip` : Change IP address  
16. `ifconfig -a` : Network interface info  
17. `chss` : Change subsystem attributes  
18. `lsuser <user>` : Show user info  
19. `passwd <user>` : Change user password  
20. `exportvg` : Export volume group  

💡 Tips:

aixpert helps harden security.

Use alt_disk_copy for backup.

adb can debug core dumps.

acctcms helps analyze command usage.

bindprocessor optimizes CPU usage.

</details>
<details> <summary>🏆 Expert Commands (20)</summary>

1. `alt_disk_install` : Install OS on alternate disk  
2. `bosboot -ad /dev/hd5` : Rebuild boot image  
3. `mksysb -i /dev/rmt0` : Create bootable backup  
4. `lsattr -El <device> -a attribute` : Check attributes  
5. `chdev -l <device> -a attribute=value` : Modify device  
6. `mkvg -y <vgname> <hdisk>` : Create volume group  
7. `mklv` : Create logical volume  
8. `mirrorvg` : Mirror VG for redundancy  
9. `syncvg` : Sync mirrored VG  
10. `reducevg` : Reduce VG size  
11. `bootlist -m normal -o <device>` : Set boot device  
12. `errpt -a -s <date>` : Error report for specific date  
13. `lsvg -o` : Active volume groups  
14. `lscfg -vp` : Detailed device config  
15. `dump -0u -f /dev/rmt0 /dev/<lv>` : Backup LV  
16. `restore -ivf /dev/rmt0` : Restore LV  
17. `tracepath <host>` : Trace route  
18. `sar -u 1 10` : CPU stats  
19. `lsof -i` : Open files  
20. `netstat -an | grep <port>` : Network connections  

💡 Tips:

Use certcreate and certget for certificate management.

errlg -n to view recent errors.

Use filemon to track file/system I/O.

fastboot requires no other users logged in.

Use getconf before scripts for environment info.

</details>
<details> <summary>📘 Should Know Commands (20)</summary>

1. `ls -ltr` : List files by time  
2. `df -k` : Disk usage in KB  
3. `du -h` : Directory usage human-readable  
4. `cat /etc/passwd` : View users  
5. `cat /etc/group` : View groups  
6. `finger <user>` : User info  
7. `who` : Logged-in users  
8. `w` : Show login sessions  
9. `uptime` : System uptime  
10. `hostname` : Hostname  
11. `ifconfig` : Network interfaces  
12. `netstat -i` : Interface statistics  
13. `traceroute` : Trace path to host  
14. `ping` : Network test  
15. `scp` : Secure copy  
16. `sftp` : Secure file transfer  
17. `chmod` : Change permissions  
18. `chown` : Change ownership  
19. `alias` : Set command alias  
20. `history` : Command history  

</details>

💡 Tips:

Use banner to create large ASCII headings.

batch schedules commands when load is low.

bc is useful for calculations in shell.

Use Basename to parse filenames.

ACL tools help manage file permissions finely.

</details>

----
Windows 🪟
<details> <summary>⚡ Basic Commands (20)</summary>

1. `dir` : List directory contents  
2. `cd <dir>` : Change directory  
3. `copy <src> <dest>` : Copy files  
4. `move <src> <dest>` : Move files  
5. `del <file>` : Delete files  
6. `mkdir <dir>` : Create directory  
7. `rmdir <dir>` : Remove directory  
8. `type <file>` : Display file contents  
9. `echo <text>` : Print text  
10. `cls` : Clear screen  
11. `whoami` : Show current user  
12. `date` : Show date  
13. `time` : Show time  
14. `tasklist` : List processes  
15. `taskkill /PID <pid>` : Kill process  
16. `ipconfig` : Network configuration  
17. `ping <host>` : Test connectivity  
18. `systeminfo` : System information  
19. `net user` : List users  
20. `ver` : Windows version  

💡 Tips:

Use dir /a to list hidden files.

Use tasklist and taskkill to manage processes.

Use ipconfig /all for detailed network info.

Use help to learn about commands.

cls clears the console screen.

</details>
<details> <summary>🔧 Intermediate Commands (20)</summary>

1. `chkdsk` : Check disk  
2. `sfc /scannow` : System file check  
3. `diskpart` : Disk partitioning  
4. `netstat -an` : Network stats  
5. `tasklist /svc` : Processes with services  
6. `wmic cpu get name` : CPU info  
7. `wmic memorychip get capacity` : Memory info  
8. `powershell` : Launch PowerShell  
9. `Get-Process` : List processes (PowerShell)  
10. `Get-Service` : List services (PowerShell)  
11. `Stop-Service <name>` : Stop service  
12. `Start-Service <name>` : Start service  
13. `Set-ExecutionPolicy RemoteSigned` : PowerShell policy  
14. `Get-EventLog -LogName System` : Event logs  
15. `gpupdate /force` : Refresh group policy  
16. `net localgroup` : List local groups  
17. `net share` : List shared resources  
18. `shutdown /s /t 0` : Shutdown immediately  
19. `shutdown /r /t 0` : Restart immediately  
20. `whoami /groups` : Show group membership  

💡 Tips:

Use tracert to diagnose routing problems.

Use netstat -an for all connections.

schtasks to automate jobs.

sfc /scannow repairs system files.

sc to view and manage services.

</details>
<details> <summary>🚀 Advanced Commands (20)</summary>

1. `Get-WmiObject Win32_OperatingSystem` : OS info (PowerShell)  
2. `Get-WmiObject Win32_ComputerSystem` : System info  
3. `Get-Process | Sort-Object CPU -Descending` : Top CPU processes  
4. `Get-Process | Sort-Object WS -Descending` : Top memory processes  
5. `Get-Service | Where-Object {$_.Status -eq "Running"}` : Running services  
6. `Get-EventLog -LogName Application -Newest 50` : Recent events  
7. `robocopy <src> <dest>` : Advanced file copy  
8. `diskpart list disk` : List disks  
9. `diskpart select disk <n>` : Select disk  
10. `diskpart clean` : Clean disk  
11. `Get-ADUser <name>` : AD user info  
12. `Get-ADGroup <name>` : AD group info  
13. `Get-ADComputer <name>` : AD computer info  
14. `netstat -ano` : Network with PID  
15. `taskkill /F /PID <pid>` : Force kill process  
16. `powershell -Command "Restart-Service <name>"` : Restart service  
17. `schtasks /query` : List scheduled tasks  
18. `schtasks /run /TN <taskname>` : Run scheduled task  
19. `Get-ChildItem -Recurse` : Recursive file listing  
20. `icacls <file>` : Show file permissions  

💡 Tips:

Use PowerShell for automation.

Get-Help is the best friend.

Use Format-Table to beautify output.

Invoke-WebRequest for REST calls.

Always check script execution policies.

</details>
<details> <summary>🏆 Expert Commands (20)</summary>

1. `Get-Process | Where-Object {$_.CPU -gt 100}` : High CPU processes  
2. `Get-WmiObject Win32_Service | Where-Object {$_.StartMode -eq "Auto"}` : Auto services  
3. `Get-EventLog -LogName Security -Newest 100` : Security logs  
4. `Get-ADReplicationFailure` : AD replication issues  
5. `repadmin /showrepl` : AD replication status  
6. `Get-ADDomainController -Filter *` : List DCs  
7. `Get-ADForest` : AD forest info  
8. `netsh interface ip show config` : Network config  
9. `netsh advfirewall show allprofiles` : Firewall status  
10. `Get-HotFix` : Installed updates  
11. `Enable-PSRemoting -Force` : PowerShell remoting  
12. `Invoke-Command -ComputerName <host> -ScriptBlock { <cmd> }` : Remote execution  
13. `New-PSSession -ComputerName <host>` : Create remote session  
14. `Enter-PSSession <session>` : Enter remote session  
15. `Exit-PSSession` : Exit remote session  
16. `Get-Process | Export-Csv processes.csv` : Export processes  
17. `Get-Service | Export-Csv services.csv` : Export services  
18. `Get-EventLog -LogName System | Export-Csv systemlogs.csv` : Export logs  
19. `Set-ExecutionPolicy Bypass -Scope Process` : Temporary bypass policy  
20. `Start-Process powershell -Verb RunAs` : Run PowerShell as admin  

💡 Tips:

Remote management via PowerShell is powerful.

Regularly back up PowerShell transcript.

Active Directory module is a must for admins.

Use Measure-Command to benchmark.

Registry manipulation requires caution.

</details>
<details> <summary>📘 Should Know Commands (20)</summary>

1. `cls` : Clear console  
2. `echo %USERNAME%` : Current user  
3. `echo %COMPUTERNAME%` : Computer name  
4. `systeminfo | findstr /B /C:"OS Name" /C:"OS Version"` : OS info  
5. `whoami /priv` : Privileges  
6. `whoami /groups` : Groups  
7. `netstat -r` : Routing table  
8. `ping <host> -n 4` : Ping with 4 attempts  
9. `tracert <host>` : Trace route  
10. `ipconfig /all` : Detailed network info  
11. `getmac` : MAC addresses  
12. `nslookup <host>` : DNS lookup  
13. `arp -a` : ARP table  
14. `tasklist /m` : Modules loaded by tasks  
15. `shutdown /i` : GUI shutdown  
16. `gpresult /R` : Group policy result  
17. `driverquery` : List drivers  
18. `systeminfo` : System info  
19. `fsutil fsinfo drives` : List drives  
20. `chkdsk /f` : Fix disk errors  

💡 Tips:

Use wmic for deep Windows queries.

robocopy is superior for batch file copies.

Enable-PSRemoting is critical for remote admin.

Regularly chkdsk for disk health.

netsh provides granular network controls.

</details>

