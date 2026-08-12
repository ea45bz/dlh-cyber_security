## What is nmap?

**nmap (Network Mapper)** is a free, open‑source utility used primarily for network discovery and security auditing.  
It scans hosts on a computer network to determine:

- Which IP addresses are active
- What ports are open on those hosts
- The services (and versions) running behind each port
- Host operating system and kernel characteristics

nmap works by sending packets (TCP/UDP/SCTP, ICMP, etc.) and interpreting the responses. Its output can be customized with various options and saved in different formats (plain text, XML, JSON). It is widely used by network administrators for inventory and monitoring, as well as by security professionals for vulnerability assessment.

## How to use nmap?

On command line start scans on hosts or subnet in different modes
Run as root (or sudo) for more aggressive scans (-sS, OS detection).
Combine with script engine: nmap --script vuln <host> to run vulnerability scripts.

## What are subnetworks?

A smaller network carved out of a larger one by applying a subnet mask, it’s how we divide a single IP range into multiple, isolated segments.
Usually noted as CIDR Block that combines address + mask

## How to enumerate targets with Nmap?

1. **Discover live hosts** – run a _ping sweep_ (`nmap -sn <network/CIDR>`).
2. **Scan for open ports** – use a full port scan or specify ranges (`nmap -p- <host>`).
3. **Identify services and versions** – add service detection (`nmap -sV <host>`).
4. **Detect operating systems** – enable OS discovery (`nmap -O <host>`) or combine with `-A`.

## What is ARP Scan?

scan uses "-PR" to force Nmap to use ARP ping on local networks.
ARP tables (IP to MAC ) are used in LAN for an efficent communication

## What is ICMP Echo Scan?

It is a ping to targets for standard ICMP echos, option -PE

## What is ICMP Timestamp Scan?

Purpose of these queries is to learn information of current times over ICMP. Replying systems tell that rhey are available. option -PP 

## What is ICMP Address Mask Scan?

 Purpose of these queries is to learn information of address mask over ICMP. Replying systems tell that rhey are available. option -PM

## What is TCP SYN Ping Scan?

TCP TCP SYN Ping Scan is a method used to determine if a host is online by sending TCP SYN packets to specific ports. If the host responds with a SYN-ACK, it tells reponding on this port. option -PS

## What is TCP ACK Ping Scan?

TCP ACK Ping Scan is a method used to determine if a host is online by sending a TCP ACK packet to a specified port. If the host responds with a reset (RST) packet, it's there. option -PA 

## What is UDP Ping Scan?

UDP Ping Scan is a method used to check if a host is active by sending UDP packets to specific ports and listening for responses. If a port is closed, the target host typically responds with an ICMP "Port Unreachable" message, indicating that the host is active but not listening on that port. option -PU

## What can nmap detect?

Nmap can detect host availability, port status, service identification, OS family.

## How to scan an IP address with nmap?

Perform a basic port scan of target IP, with nmap [IP Address], without port scanning use option -sn

## How to check ports with nmap?

With option -p to specify a ports or range, set usually as default 

# Python

## What is the correct way to write a Python script with proper syntax?

- Shebang line for Unix execution
- Module documentation
- Imports at top
- Constants clearly defined
- Functions with docstrings
- Main function for logic
- Main guard pattern

## What are variables, data types, and operators used for in Python?

They are the foundational elements of programming in Python.
Variables are used to store values in memory, data types the kind of data the variable contains, and operators perform actions on the variables or values.

## What conditions would you use to implement if, elif, and else statements?

Welche Bedingungen würden Sie verwenden, um if-, elif- und else-Anweisungen zu implementieren?

if,elif,else Statements  are used to execute a block of code among one or more alternatives

## What is the difference between a for loop and a while loop, and when do you use each?

A for loop is a control flow statement that executes code repeatedly for a  number of iterations. 
A while loop executes a  statement  as long as the  condition is true.

The fundamental difference between a for loop and a while loop is predictability: a for loop is used when the number of iterations is known or definite, whereas a while loop is used when the iterations are unknown or indefinite and depend on a specific condition being met

## What is a function in Python, and how do you define and call it with parameters and return values?

A function is defined using the def keyword, parameters passed in parantheses behind the function names
A function can return **any Python object**: strings, numbers, lists, dictionaries, or even custom objects, default is None

## What is the socket module used for, and how do you import and use it in a script?

Socket module is used for DNS Resolution, Port scanning, opening sockets
module provides IP socket operations,
import socket.
open sockets to host:port , hostname, ip ops

## What are Python's built-in functions like input(), print(), len(), and open() used for?

input() used to take user input, print() is used to display output to the console, open() to files and len() to count object length

## What do string methods such as .strip(), .split(), and .format() allow you to do?

manipulating or extracting   strings and .format() for composing dynamic text

## What operations can you perform on Python lists?

Main operation are iteration, listing, append, insert, sorting, insert, pop, delete

## What command do you use to install Python packages using pip?

python -m pip install

## What steps are needed to import and use external modules such as dnspython, requests, or beautifulsoup4?

package must be installed
with "import <package>" at the top

## What should you look for when reading and understanding Python library documentation?

help(library)

## What is the proper way to use third-party APIs effectively in a Python script?

Rest API's can be used with requests to make HTTP calls

## What methods can you use to read text files using open() and context managers?

The following methods can be used read(), readline(), readlines()

## What are the correct techniques to write data to files in Python?

you typically use the open() function with the desired file name and mode (like 'w' for writing or 'a' for appending). After opening the file, you can use the write() method to add content, and it's important to close the file afterward to ensure data integrity.

## What is the right way to parse file content line by line?

with open(file) as f: ..
it assures the file will be closed

## What are the file modes ('r', 'w', 'a'), and what is each one used for?

r reading (to process file without changing it)
w write ( write file (overwrites))
a append (to append lines to an existing file)

## How do you resolve a domain to an IP address in Python?

socket.gethostbyname(domain)

## What is socket.gethostbyname() used for?

socket.gethostbyname  is uesd to resolve a domain to an IP address

## What library do you use for advanced DNS queries?

dnspython

## How do you make an HTTP GET request in Python?

with requests.get(url)

## What library do you use for HTTP requests in Python?

requests

## How do you access response headers in Python?

in headers of the requests reponse

## How do you check if a port is open in Python?

with socket.connect_ex

## What does socket.connect_ex() return for an open port?

0

## What library is used to parse HTML in Python?

beautifulsoup4

## What is BeautifulSoup used for?

parse HTML

## What does .prettify() do?

Pretty print HTML form beautifulsoup4

## What is web scraping?

data scraping used for extracting data from websites

## What is web crawling?

crawler systematically browses webpages for the purpose of indexing or to gain active reconnaissance

## What is recursion and how is it used in web crawling?

recursion is used to systematically explore a website by starting from a seed URL, visiting it, and then following all the links found on that page, repeating the process for each new link to discover all reachable pages.

# Network Traffic Monitoring & Analysis

## What is packet capture and why is it important?

process to intercept and log data packets, it is important to allows IT teams to analyze network performance, detect security threats, and troubleshoot issues
Security Investigation, Compliance Monitoring

## How does Wireshark display and dissect network packets?

Protocol dissection (breaking down packet structures)
It dissects packets step by step—starting with the Frame dissector for the capture file, then handing the payload to lower-level dissectors (like Ethernet and IP), and continuing through the encapsulated protocols to produce a readable, decoded protocol tree.

## What is the difference between capture filters and display filters?

Capture filters reduces the amount of data captured and is more efficient
Display Filters is more flexible, user-friendly and filter what you see

## How do you follow TCP streams in Wireshark?

with Protocol Filters TCP

## What is tcpdump and when should you use it over Wireshark?

on remote hosts, automated scripts and for quick troubleshooting

## How do you construct effective tcpdump filter expressions?

specify interface and filter on port or network dependig on opportunity

## What are common indicators of network anomalies?

sudden spikes in traffic, unexpected drops in activity, unusual traffic from foreign IP addresses, and devices making connections they typically do not.

## How can you identify unauthorized connections in packet captures?

for example with HTTP Traffic Analysis status 401

## What tools does Wireshark provide for traffic statistics?

Protocol Hierarchy (Identifies which protocols consume most bandwidth)
Conversations (comm pairs, data volume) identify top
I/O Graphs (Visual representation, spikes)

## How do you analyze DNS queries in network traffic?

Filter for DNS traffic (UDP port 53)
Analyze respones

## What are best practices for capturing network traffic?

capture to file, filter the noise

## How does encryption affect traffic analysis?

Encryption creates blind spots for traffic analysis by obscuring the content of network packets, making it difficult for security tools to detect malicious activities.
