# Check 1 - Certificate Inspection

```bash
openssl s_client -showcerts </dev/null -connect github.com:443 >github.com.pem
openssl x509 -text -noout -in github.com.pem

Subject: CN=github.com
Issuer: C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication CA DV E36
Validity:  Not Before: Sep  1 00:00:00 2026 GMT  Not After : Nov 29 23:59:59 2026 GMT
Serial Number: a5:9e:bd:b5:96:75:1d:b7:f5:c0:95:07:96:13:95:3c
Signature Algorithm: ecdsa-with-SHA256  Public Key Info: id-ecPublicKey, P-256
SAN: DNS:github.com, DNS:www.github.com
```

# Check 2 - Hash Verification

```bash
~ cat hash_tst.txt
MedDefense
~ cat hash_tst.txt  | sha256sum
ced71cb97584630a2726f7949578b9d2669036d73d419285efeab6b2fcd996cf  -
 ~ cat hash_tst.txt
MedDefense2
 ~ cat hash_tst.txt  | sha256sum
4312498a70ee3bbd1c7c453dcccac224957d9c25b9da81503e3f448c797f0869  -
```

It matters if checking the the hash published with the hash of the downloaded file, to assure integrity

# Check 3 - Exploit Research

```bash
➜  ~ searchsploit fortigate
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                                                                                       |  Path
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Fortigate Firewall 2.x - dlg Admin Interface Cross-Site Scripting                                                                                    | hardware/remote/23376.txt
Fortigate Firewall 2.x - listdel Admin Interface Cross-Site Scripting                                                                                | hardware/remote/23378.txt
Fortigate Firewall 2.x - Policy Admin Interface Cross-Site Scripting                                                                                 | hardware/remote/23377.txt
Fortigate Firewall 2.x - selector Admin Interface Cross-Site Scripting                                                                               | hardware/remote/23379.txt
Fortigate Firewalls - 'EGREGIOUSBLUNDER' Remote Code Execution                                                                                       | hardware/webapps/40276.txt
Fortigate Firewalls - Cross-Site Request Forgery                                                                                                     | hardware/webapps/26528.txt
Fortigate UTM WAF Appliance - Multiple Vulnerabilities                                                                                               | hardware/webapps/21395.txt
Fortinet Fortigate - CRLF Characters URL Filtering Bypass                                                                                            | hardware/remote/31026.pl
Fortinet Fortigate 2.x/3.0 - URL Filtering Bypass                                                                                                    | hardware/remote/27203.pl
Fortinet FortiGate 4.x < 5.0.7 - SSH Backdoor Access                                                                                                 | linux/remote/43386.py
Fortinet FortiGate FortiOS < 6.0.3 - LDAP Credential Disclosure                                                                                      | hardware/webapps/46171.py
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
➜  ~ searchsploit fortios
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                                                                                       |  Path
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Fortinet FortiGate FortiOS < 6.0.3 - LDAP Credential Disclosure                                                                                      | hardware/webapps/46171.py
Fortinet FortiOS 5.6.3 - 5.6.7 / FortiOS 6.0.0 - 6.0.4 - Credentials Disclosure                                                                      | hardware/webapps/47288.py
Fortinet FortiOS 5.6.3 - 5.6.7 / FortiOS 6.0.0 - 6.0.4 - Credentials Disclosure (Metasploit)                                                         | hardware/webapps/47287.rb
Fortinet FortiOS 6.0.4 - Unauthenticated SSL VPN User Password Modification                                                                          | hardware/webapps/49074.py
Fortinet FortiOS < 5.6.0 - Cross-Site Scripting                                                                                                      | hardware/webapps/42388.txt
Fortinet FortiOS_ FortiProxy_ and FortiSwitchManager 7.2.0 - Authentication bypass                                                                   | windows/remote/52239.py
FortiOS SSL-VPN 7.4.4 - Insufficient Session Expiration & Cookie Reuse                                                                               | multiple/remote/52336.py
FortiOS_ FortiProxy_ FortiSwitchManager v7.2.1 - Authentication Bypass                                                                               | multiple/webapps/51092.sh
----------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
```

# Check 4 - System Audit

```bash
sudo lynis audit system --quick
```
