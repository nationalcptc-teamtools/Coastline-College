- check for anonymous bind
```bash
ldapsearch -H ldap://10.10.10.161 -x -b "DC=HTB,DC=LOCAL"
# anonymous bind get users
ldapsearch -H ldap://172.16.5.5 -x -b "DC=inlanefreight,DC=local" '(objectClass=User)' "sAMAccountName" | grep sAMAccountName
# dive deeper into an OU
ldapsearch -H "ldap://10.10.10.161" -x -b "OU=Service Accounts,DC=htb,DC=local"
./windapsearch.py --dc-ip 172.16.5.5 -u "" -U
```

