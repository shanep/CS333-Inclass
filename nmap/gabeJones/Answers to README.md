# In-Class Exercise: Network Scanning with Nmap

## Overview

This is a multi-day exercise where you will learn to use **Nmap** (Network Mapper), one of the most widely used network scanning tools in cybersecurity. You will scan a lab network to discover hosts, identify open ports, detect services, and understand what information an attacker (or a defender) can learn about a network.

> [!TIP]
> We will be updating this document in class as we go through the exercises. Make sure to check back here for the latest instructions and details on each step.

> [!WARNING]
> Only scan networks you have explicit permission to scan. In this exercise, you will only scan the lab network provided by your instructor. Scanning networks without authorization is illegal and unethical.

---

## What You Need

- A computer connected to the lab network
- Terminal access
- Nmap installed (check by typing `nmap --version` in your terminal)
- A notebook or text file to record your findings
- The lab network range provided in class

### What is an IP Address Range?

Throughout this exercise, you will see network ranges written like `10.0.0.0/24`. Here is what that means:

- `10.0.0.0` is the starting network address
- `/24` means the first 24 bits of the address are the "network part," leaving the last 8 bits for hosts
- In plain terms: `/24` covers all addresses from `10.0.0.1` through `10.0.0.254` (254 possible hosts)

## Host Discovery

**Goal:** Find out which devices are alive (connected and responding) on the lab network.

### What is Host Discovery?

Before you can scan a computer for open ports or services, you first need to know it exists. Host discovery is the process of finding which IP addresses on a network have a live device behind them. Think of it like knocking on every door in an apartment building to see who is home.

### Step 1: Ping Sweep

Use the [pingsweep.sh](../pingsweep/) script that we created in the previous exercise to perform a ping sweep and collect all the necessary information for nmap.

### Step 2: Try a List Scan (No Actual Scanning)

Nmap can show you what it *would* scan without actually sending any packets. This is useful for double-checking your target range.

```bash
nmap -sL 10.0.0.0/24
```
**What this does:**
- `-sL` — "list scan" that only lists the targets, it does not send anything to the network
- Notice it also tries to look up hostnames using reverse DNS

### Step 3: Basic Ping Scan Nmap Command

Use Nmap's ping scan to send a small message to each address and listen for a reply. It is the simplest way to discover hosts. Compare the results to your ping sweep script and see if you find the same hosts.

Run this command (replace `10.0.0.0/24` with your lab's network range):

```bash
nmap -sn 10.0.0.0/24
```

**What each part means:**
- `nmap` — the program you are running
- `-sn` — this flag tells Nmap to do a "ping scan" only (do NOT scan for open ports, just check if hosts are alive)
- `10.0.0.0/24` — the range of IP addresses to scan

**What to look for in the output:**

You will see output that looks something like this:
```
Nmap scan report for 10.0.0.1
Host is up (0.0023s latency).
Nmap scan report for 10.0.0.5
Host is up (0.0041s latency).
Nmap scan report for 10.0.0.12
Host is up (0.0018s latency).
...
Nmap done: 256 IP addresses (8 hosts up) scanned in 2.34 seconds
```

Each "Host is up" line is a device that responded. The number in parentheses (like `0.0023s latency`) is how long it took to respond, measured in seconds.

**Record your findings:**
1. How many total addresses were scanned?
256 addresses scanned
2. How many hosts are up?
94 hosts up
3. List every IP address that responded.
Starting Nmap 7.92 ( https://nmap.org ) at 2026-02-18 11:08 MST
Nmap scan report for onyxnode93.boisestate.edu (10.29.3.29)
Host is up (0.0014s latency).
Nmap scan report for tsw-ccp221.boisestate.edu (10.29.3.30)
Host is up (0.00056s latency).
Nmap scan report for cscluster07.boisestate.edu (10.29.3.32)
Host is up (0.0014s latency).
Nmap scan report for onyxnode110.boisestate.edu (10.29.3.35)
Host is up (0.0013s latency).
Nmap scan report for onyxnode62.boisestate.edu (10.29.3.39)
Host is up (0.0019s latency).
Nmap scan report for onyxnode39.boisestate.edu (10.29.3.40)
Host is up (0.0019s latency).
Nmap scan report for angstrom.boisestate.edu (10.29.3.41)
Host is up (0.00073s latency).
Nmap scan report for cscluster02.boisestate.edu (10.29.3.42)
Host is up (0.0018s latency).
Nmap scan report for eng402722.boisestate.edu (10.29.3.44)
Host is up (0.0018s latency).
Nmap scan report for dmps-ccp243.boisestate.edu (10.29.3.47)
Host is up (0.092s latency).
Nmap scan report for osamanatouf.boisestate.edu (10.29.3.48)
Host is up (0.00052s latency).
Nmap scan report for cscluster00.boisestate.edu (10.29.3.50)
Host is up (0.00047s latency).
Nmap scan report for mosel.boisestate.edu (10.29.3.51)
Host is up (0.00045s latency).
Nmap scan report for onyxnode109.boisestate.edu (10.29.3.52)
Host is up (0.0016s latency).
Nmap scan report for 10.29.3.53
Host is up (0.00061s latency).
Nmap scan report for itadmins-mbp-2.boisestate.edu (10.29.3.54)
Host is up (0.0016s latency).
Nmap scan report for tsw-ccp243.boisestate.edu (10.29.3.55)
Host is up (0.0015s latency).
Nmap scan report for onyxnode23.boisestate.edu (10.29.3.56)
Host is up (0.0015s latency).
Nmap scan report for toucan.boisestate.edu (10.29.3.57)
Host is up (0.00033s latency).
Nmap scan report for onyxnode24.boisestate.edu (10.29.3.59)
Host is up (0.0015s latency).
Nmap scan report for eng401524.boisestate.edu (10.29.3.60)
Host is up (0.0014s latency).
Nmap scan report for onyxnode114.boisestate.edu (10.29.3.62)
Host is up (0.0014s latency).
Nmap scan report for onyxnode116.boisestate.edu (10.29.3.66)
Host is up (0.0013s latency).
Nmap scan report for csstorage3.boisestate.edu (10.29.3.69)
Host is up (0.0012s latency).
Nmap scan report for onyxnode70.boisestate.edu (10.29.3.71)
Host is up (0.00050s latency).
Nmap scan report for onyxnode14.boisestate.edu (10.29.3.73)
Host is up (0.00097s latency).
Nmap scan report for onyxnode30.boisestate.edu (10.29.3.74)
Host is up (0.00095s latency).
Nmap scan report for tscw-ccp240.boisestate.edu (10.29.3.75)
Host is up (0.0010s latency).
Nmap scan report for theia.boisestate.edu (10.29.3.77)
Host is up (0.00089s latency).
Nmap scan report for onyxnode86.boisestate.edu (10.29.3.79)
Host is up (0.00085s latency).
Nmap scan report for onyxnode25.boisestate.edu (10.29.3.83)
Host is up (0.00076s latency).
Nmap scan report for onyxnode32.boisestate.edu (10.29.3.84)
Host is up (0.00069s latency).
Nmap scan report for onyxnode33.boisestate.edu (10.29.3.85)
Host is up (0.00067s latency).
Nmap scan report for eng402588.boisestate.edu (10.29.3.87)
Host is up (0.00062s latency).
Nmap scan report for onyxnode57.boisestate.edu (10.29.3.89)
Host is up (0.00059s latency).
Nmap scan report for onyxnode98.boisestate.edu (10.29.3.90)
Host is up (0.00056s latency).
Nmap scan report for onyxnode78.boisestate.edu (10.29.3.91)
Host is up (0.00054s latency).
Nmap scan report for brightsign-d1e916000437.boisestate.edu (10.29.3.92)
Host is up (0.00052s latency).
Nmap scan report for eng402838.boisestate.edu (10.29.3.93)
Host is up (0.00070s latency).
Nmap scan report for onyxnode72.boisestate.edu (10.29.3.94)
Host is up (0.00049s latency).
Nmap scan report for onyxnode21.boisestate.edu (10.29.3.95)
Host is up (0.00046s latency).
Nmap scan report for onyxnode46.boisestate.edu (10.29.3.96)
Host is up (0.00044s latency).
Nmap scan report for onyxnode96.boisestate.edu (10.29.3.98)
Host is up (0.00060s latency).
Nmap scan report for onyxnode84.boisestate.edu (10.29.3.99)
Host is up (0.00058s latency).
Nmap scan report for onyxnode71.boisestate.edu (10.29.3.100)
Host is up (0.00055s latency).
Nmap scan report for onyxnode91.boisestate.edu (10.29.3.101)
Host is up (0.00053s latency).
Nmap scan report for eng402607.boisestate.edu (10.29.3.103)
Host is up (0.00049s latency).
Nmap scan report for onyxnode74.boisestate.edu (10.29.3.104)
Host is up (0.00053s latency).
Nmap scan report for eng403019.boisestate.edu (10.29.3.105)
Host is up (0.0014s latency).
Nmap scan report for onyxnode06.boisestate.edu (10.29.3.107)
Host is up (0.00040s latency).
Nmap scan report for eng402924.boisestate.edu (10.29.3.108)
Host is up (0.0013s latency).
Nmap scan report for onyxnode77.boisestate.edu (10.29.3.109)
Host is up (0.0013s latency).
Nmap scan report for eng402001.boisestate.edu (10.29.3.110)
Host is up (0.00034s latency).
Nmap scan report for eng401727.boisestate.edu (10.29.3.111)
Host is up (0.0012s latency).
Nmap scan report for eng402594.boisestate.edu (10.29.3.112)
Host is up (0.0017s latency).
Nmap scan report for onyxnode08.boisestate.edu (10.29.3.113)
Host is up (0.0012s latency).
Nmap scan report for dlaserver.boisestate.edu (10.29.3.115)
Host is up (0.00023s latency).
Nmap scan report for eng401993.boisestate.edu (10.29.3.116)
Host is up (0.0013s latency).
Nmap scan report for onyxnode20.boisestate.edu (10.29.3.117)
Host is up (0.00077s latency).
Nmap scan report for dm-rmc-ccp240.boisestate.edu (10.29.3.119)
Host is up (0.00073s latency).
Nmap scan report for onyxnode58.boisestate.edu (10.29.3.120)
Host is up (0.0012s latency).
Nmap scan report for tsw-ccp368.boisestate.edu (10.29.3.121)
Host is up (0.0012s latency).
Nmap scan report for onyxnode75.boisestate.edu (10.29.3.122)
Host is up (0.00068s latency).
Nmap scan report for onyxnode52.boisestate.edu (10.29.3.123)
Host is up (0.00067s latency).
Nmap scan report for onyxnode19.boisestate.edu (10.29.3.126)
Host is up (0.00062s latency).
Nmap scan report for onyxnode50.boisestate.edu (10.29.3.127)
Host is up (0.0011s latency).
Nmap scan report for onyxnode34.boisestate.edu (10.29.3.129)
Host is up (0.00057s latency).
Nmap scan report for cscluster04.boisestate.edu (10.29.3.130)
Host is up (0.00055s latency).
Nmap scan report for onyxnode45.boisestate.edu (10.29.3.131)
Host is up (0.0011s latency).
Nmap scan report for onyxnode18.boisestate.edu (10.29.3.132)
Host is up (0.0010s latency).
Nmap scan report for onyxnode15.boisestate.edu (10.29.3.133)
Host is up (0.00051s latency).
Nmap scan report for cscluster05.boisestate.edu (10.29.3.135)
Host is up (0.00048s latency).
Nmap scan report for eng402014.boisestate.edu (10.29.3.137)
Host is up (0.00044s latency).
Nmap scan report for cscluster06.boisestate.edu (10.29.3.138)
Host is up (0.00043s latency).
Nmap scan report for onyxnode107.boisestate.edu (10.29.3.140)
Host is up (0.00092s latency).
Nmap scan report for cscluster08.boisestate.edu (10.29.3.141)
Host is up (0.00038s latency).
Nmap scan report for onyxnode37.boisestate.edu (10.29.3.143)
Host is up (0.00087s latency).
Nmap scan report for onyxnode90.boisestate.edu (10.29.3.144)
Host is up (0.00085s latency).
Nmap scan report for onyxnode38.boisestate.edu (10.29.3.145)
Host is up (0.00084s latency).
Nmap scan report for onyxnode88.boisestate.edu (10.29.3.146)
Host is up (0.00082s latency).
Nmap scan report for csclustertest.boisestate.edu (10.29.3.147)
Host is up (0.00080s latency).
Nmap scan report for zahura-lab.boisestate.edu (10.29.3.149)
Host is up (0.00025s latency).
Nmap scan report for dmps-ccp368.boisestate.edu (10.29.3.150)
Host is up (0.0011s latency).
Nmap scan report for dm-rmc-ccp352.boisestate.edu (10.29.3.151)
Host is up (0.00074s latency).
Nmap scan report for onyxnode65.boisestate.edu (10.29.3.152)
Host is up (0.00071s latency).
Nmap scan report for onyxnode79.boisestate.edu (10.29.3.153)
Host is up (0.00069s latency).
Nmap scan report for onyxnode56.boisestate.edu (10.29.3.154)
Host is up (0.00068s latency).
Nmap scan report for onyxnode12.boisestate.edu (10.29.3.155)
Host is up (0.00066s latency).
Nmap scan report for onyxnode80.boisestate.edu (10.29.3.156)
Host is up (0.00064s latency).
Nmap scan report for onyxnode73.boisestate.edu (10.29.3.157)
Host is up (0.00063s latency).
Nmap scan report for onyxnode108.boisestate.edu (10.29.3.158)
Host is up (0.00061s latency).
Nmap scan report for onyxnode10.boisestate.edu (10.29.3.159)
Host is up (0.00059s latency).
Nmap scan report for dmps-ccp242.boisestate.edu (10.29.3.160)
Host is up (0.0011s latency).
Nmap scan report for dmps-ccp221.boisestate.edu (10.29.3.161)
Host is up (0.0012s latency).
Nmap done: 256 IP addresses (94 hosts up) scanned in 5.90 seconds

4. Which IP address is yours?
10.29.3.83/23

### Step 4: Save Your Results to a File

It is useful to save scan results so you can look at them later. Nmap can write output to a file for you.

Run the same scan, but save the results:

```bash
nmap -sn 10.0.0.0/24 -oN 1-ping-scan.txt
```

**What the new part means:**
- `-oN 1-ping-scan.txt` — save the output in "normal" format to a file called `1-ping-scan.txt`

After it finishes, you can view the saved file:

```bash
cat 1-ping-scan.txt
```

### Step 5: Understanding ARP vs ICMP

When you scan a network you are directly connected to (a "local" network), Nmap uses **ARP** (Address Resolution Protocol) instead of regular ping. ARP is more reliable because:

- ARP works at a lower level than ping
- Firewalls cannot easily block ARP on a local network
- ARP gets a response even from devices that block ping

You do not need to do anything different. Nmap automatically picks the best method. But it is important to understand that "ping scan" does not always mean ICMP ping.


## Port Scanning and Service Detection

**Goal:** Discover what services are running on the live hosts you found.

### What are Ports?

Every networked computer has **65,535 ports** available. Think of ports like apartment numbers in a building — the IP address is the building's street address, and the port number tells you which apartment (service) to talk to.

Common port numbers and what they usually mean:

| Port | Service | What it Does                              |
| ---- | ------- | ----------------------------------------- |
| 22   | SSH     | Secure remote login (command line access) |
| 80   | HTTP    | Web server (unencrypted)                  |
| 443  | HTTPS   | Web server (encrypted)                    |
| 21   | FTP     | File transfer                             |
| 25   | SMTP    | Sending email                             |
| 53   | DNS     | Translating domain names to IP addresses  |
| 3306 | MySQL   | Database server                           |
| 3389 | RDP     | Windows remote desktop                    |

### Step 1: Scan a Single Host for Open Ports

Pick one of the live hosts you found on (NOT your own computer). Replace `10.0.0.5` below with the IP you choose.

```bash
nmap 10.0.0.5
```

When you run `nmap` with just an IP address and no flags, it performs a **default scan** that:
- Checks the **1,000 most common ports**
- Uses a **TCP SYN scan** (sends a connection request to each port and checks if it gets a reply)

**What to look for in the output:**

```
PORT     STATE  SERVICE
22/tcp   open   ssh
80/tcp   open   http
443/tcp  open   https
3306/tcp closed mysql
```

Each line tells you:
- **PORT** — the port number and protocol (tcp means it uses TCP)
- **STATE** — whether the port is `open` (accepting connections), `closed` (reachable but nothing is listening), or `filtered` (a firewall is blocking Nmap from telling)
- **SERVICE** — what service Nmap thinks is running, based on the port number

**Record your findings:**
1. Which host did you scan?
10.29.3.160
2. How many open ports did it have?
6!
3. What services appear to be running?
ssh,http,https,some adobe flash player port 843??, iiimsf, and maybe a printer service

Starting Nmap 7.92 ( https://nmap.org ) at 2026-02-18 11:14 MST
Nmap scan report for dmps-ccp242.boisestate.edu (10.29.3.160)
Host is up (0.0015s latency).
Not shown: 993 closed tcp ports (conn-refused)
PORT      STATE    SERVICE
22/tcp    open     ssh
80/tcp    open     http
443/tcp   open     https
843/tcp   open     unknown
50002/tcp open     iiimsf
50003/tcp open     unknown
50006/tcp filtered unknown

Nmap done: 1 IP address (1 host up) scanned in 2.61 seconds

### Step 2: Service Version Detection

Knowing that port 80 is open tells you a web server is probably running, but what *kind* of web server? Apache? Nginx? What version? This matters because specific versions may have known vulnerabilities.

Run a version detection scan on one of your targets:

```bash
nmap -sV 10.0.0.5
```

**What the new part means:**
- `-sV` — probe open ports to determine the service name and version number

**What to look for in the output:**

```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.6
80/tcp open  http    Apache httpd 2.4.52
```

Now you can see not just "ssh" but the exact software and version: `OpenSSH 8.9p1`.

### Step 3: Scan Specific Ports

Sometimes you only care about certain ports. You can tell Nmap to scan specific ones:

**Scan a single port:**
```bash
nmap -p 22 10.0.0.5
```

**Scan a range of ports:**
```bash
nmap -p 1-100 10.0.0.5
```

**Scan a list of specific ports:**
```bash
nmap -p 22,80,443,3306 10.0.0.5
```

**Scan ALL 65,535 ports (this takes a while):**
```bash
nmap -p- 10.0.0.5
```

**What the flag means:**
- `-p` — specifies which ports to scan
- `-p-` — shorthand for `-p 1-65535` (every possible port)

### Step 5: Understanding Port States

You may see three different port states. Here is what each one means:

| State      | Meaning                                                                                   |
| ---------- | ----------------------------------------------------------------------------------------- |
| `open`     | A service is actively listening and accepting connections on this port                    |
| `closed`   | The port is reachable (no firewall blocking it) but nothing is listening                  |
| `filtered` | Nmap cannot tell if the port is open or closed because a firewall is dropping the packets |

### Step 6: Combine Version Detection with Full Results

Run a thorough scan on one host and save the output:

```bash
nmap -sV -p 1-1024 10.0.0.5 -oN 2-service-scan.txt
```

This scans ports 1 through 1024 (all "well-known" ports) with version detection and saves the results.

---

## The Nmap Scripting Engine (NSE)

Nmap includes hundreds of built-in scripts that can check for specific vulnerabilities, gather extra information, and even attempt basic brute-force tests. These scripts are organized into categories.

**Common script categories:**

| Category    | What it Does                                   |
| ----------- | ---------------------------------------------- |
| `default`   | Safe, general-purpose information gathering    |
| `discovery` | Extra host and service discovery techniques    |
| `vuln`      | Checks for known security vulnerabilities      |
| `safe`      | Scripts that are non-intrusive and safe to run |
| `auth`      | Checks for authentication weaknesses           |

### Step 1: Run Default Scripts

The default scripts gather useful extra information without being aggressive:

```bash
nmap -sC 10.0.0.5
```

**What the new part means:**
- `-sC` — run the "default" category of Nmap scripts against open ports

You will see extra information appear under each port. For example, an SSH port might show:

```
22/tcp open  ssh
| ssh-hostkey:
|   3072 aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99 (RSA)
|   256  aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99 (ECDSA)
```

This shows you the SSH host keys, which uniquely identify that server.

A web server port might show:

```
80/tcp open  http
| http-title: Welcome to Our Lab Server
|_http-server-header: Apache/2.4.52 (Ubuntu)
```

This tells you the web page title and the server header.

### Step 2: Combine Everything into One Scan

You can combine multiple scan types into one command. This is the most common "thorough scan" that security professionals use:

```bash
sudo nmap -sV -sC -O 10.0.0.5 -oN 3-full-scan.txt
```

This single command does:
- `-sV` — detect service versions
- `-sC` — run default scripts
- `-O` — detect the operating system
- `-oN` — save results to a file

### Step 3: Check for Vulnerabilities

> **Important:** Only run vulnerability scans on lab machines you have permission to test.

Nmap can check for known security vulnerabilities:

```bash
nmap --script vuln 10.0.0.5
```

**What this does:**
- `--script vuln` — runs all scripts in the "vuln" category

This may take several minutes. When it finishes, look for output that says things like:

```
| vulners:
|   cve-2021-XXXXX  7.5  https://vulners.com/cve/CVE-2021-XXXXX
```

Each **CVE** (Common Vulnerabilities and Exposures) is a publicly known security flaw. The number (like 7.5) is the severity score from 0 to 10, where 10 is the most critical.

Starting Nmap 7.92 ( https://nmap.org ) at 2026-02-18 11:29 MST
Pre-scan script results:
| broadcast-avahi-dos:
|   Discovered hosts:
|     224.0.0.251
|   After NULL UDP avahi packet DoS (CVE-2011-1002).
|_  Hosts are all up (not vulnerable).
Nmap scan report for dmps-ccp242.boisestate.edu (10.29.3.160)
Host is up (0.0034s latency).
Not shown: 993 closed tcp ports (conn-refused)
PORT      STATE    SERVICE
22/tcp    open     ssh
80/tcp    open     http
|_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
|_http-vuln-cve2013-7091: ERROR: Script execution failed (use -d to debug)
|_http-passwd: ERROR: Script execution failed (use -d to debug)
|_http-dombased-xss: Couldn't find any DOM based XSS.
|_http-csrf: Couldn't find any CSRF vulnerabilities.
| http-slowloris-check:
|   VULNERABLE:
|   Slowloris DOS attack
|     State: LIKELY VULNERABLE
|     IDs:  CVE:CVE-2007-6750
|       Slowloris tries to keep many connections to the target web server open and hold
|       them open as long as possible.  It accomplishes this by opening connections to
|       the target web server and sending a partial request. By doing so, it starves
|       the http server's resources causing Denial Of Service.
|
|     Disclosure date: 2009-09-17
|     References:
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2007-6750
|_      http://ha.ckers.org/slowloris/
443/tcp   open     https
|_http-dombased-xss: Couldn't find any DOM based XSS.
|_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
|_ssl-ccs-injection: No reply from server (TIMEOUT)
|_http-aspnet-debug: ERROR: Script execution failed (use -d to debug)
| http-slowloris-check:
|   VULNERABLE:
|   Slowloris DOS attack
|     State: LIKELY VULNERABLE
|     IDs:  CVE:CVE-2007-6750
|       Slowloris tries to keep many connections to the target web server open and hold
|       them open as long as possible.  It accomplishes this by opening connections to
|       the target web server and sending a partial request. By doing so, it starves
|       the http server's resources causing Denial Of Service.
|
|     Disclosure date: 2009-09-17
|     References:
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2007-6750
|_      http://ha.ckers.org/slowloris/
|_http-csrf: Couldn't find any CSRF vulnerabilities.
843/tcp   open     unknown
50002/tcp open     iiimsf
50003/tcp open     unknown
50006/tcp filtered unknown

Nmap done: 1 IP address (1 host up) scanned in 73.41 seconds


### Step 4: Scan a Specific Service with a Specific Script

You can also run individual scripts. For example, to check what HTTP methods a web server allows:

```bash
nmap --script http-methods -p 80 10.0.0.5
```

Or to grab the banner (greeting message) from any service:

```bash
nmap --script banner -p 22 10.0.0.5
```

To see all available scripts on your system:

```bash
ls /usr/share/nmap/scripts/ | head -20
```

(This shows the first 20 scripts. There are hundreds.)


---

## Nmap Quick Reference

| Command                         | What it Does                         |
| ------------------------------- | ------------------------------------ |
| `nmap -sn <range>`              | Ping scan (host discovery only)      |
| `nmap <target>`                 | Default port scan (top 1,000 ports)  |
| `nmap -p <ports> <target>`      | Scan specific ports                  |
| `nmap -p- <target>`             | Scan all 65,535 ports                |
| `nmap -sV <target>`             | Detect service versions              |
| `nmap -sC <target>`             | Run default scripts                  |
| `nmap -O <target>`              | Detect operating system (needs sudo) |
| `nmap --script <name> <target>` | Run a specific script or category    |
| `nmap -oN <file> <target>`      | Save output to a text file           |
| `nmap -sV -sC -O <target>`      | Combined thorough scan (needs sudo)  |

## Common Troubleshooting

**"Permission denied" or "requires root"**
Some scan types (like OS detection with `-O`) need administrator access. Add `sudo` before the command.

**Scan is taking a very long time**
Scanning all 65,535 ports or running scripts on many hosts is slow. Start with smaller scans (fewer ports, one host at a time) and expand from there.

**"Host seems down" but you know it is on**
Some hosts block ping. Try adding `-Pn` to skip host discovery and scan the ports directly:
```bash
nmap -Pn 10.0.0.5
```

**No results showing up**
Make sure you are on the correct network and using the right IP range. Double-check with your instructor.
