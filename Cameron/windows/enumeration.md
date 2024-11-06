# nmap
## SMB
### common smb vulnerabilities
```bash
nmap --script 'smb-vuln-*' 10.10.10.161 -p 445
```
### anonymous share access
```bash
sudo nmap --script 'smb-enum-shares.nse' 10.10.10.161 -p 445
```
### check for signing
```bash
nmap --script 'smb2-security-mode.nse' -p 445 10.10.10.161
```
### run all scripts
```bash
sudo nmap --script 'smb-* and not brute' -p 445 10.10.10.161
```

