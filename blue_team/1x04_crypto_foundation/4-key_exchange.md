# Part 1 - The DH Simulation

```bash
openssl dhparam -out dhparams.pem 2048

Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
...................................................................+..............................................+.................................

openssl genpkey -paramfile dhparams.pem -out alice_priv.pem

openssl pkey -in alice_priv.pem -pubout  -out alice_pub.pem

openssl genpkey -paramfile dhparams.pem -out bob_priv.pem

openssl pkey -in bob_priv.pem -pubout  -out bob_pub.pem

openssl pkeyutl -derive  -inkey alice_priv.pem  -peerkey bob_pub.pem  -out alice_secret.bin

openssl pkeyutl -derive  -inkey bob_priv.pem  -peerkey alice_pub.pem  -out bob_secret.bin

diff alice_secret.bin bob_secret.bin
```

# Part 2 - The Explanation

Alice and Bob first agreed on the DH parameters that everyone can see.  
Each of them then secretly chose a hidden number – Alice’s, Bob’s.  
Using the shared dh params, they turned their hidden numbers into two public shadows what are sent over the network.

When Alice saw Bob’s shadow she raised it to her own hidden number. Bob did the exact same thing with Alice’s shadow.  
Because of the math property, both end up with exactly the same secret without ever having sent that secret itself.

Eve, who can only see the two shadows, would need to solve a hard problem called the “discrete logarithm”.
With current computing power and the 2048‑bit prime used, that is practically impossible, so Eve cannot recover the shared secret even though she captured all traffic.

# Part 3 - The MITM Attack

A plain Diffie‑Hellman exchange trusts only that the numbers you receive are the other party’s values.  
An man in the middle attacker (Eve) can intercept Alice’s public key, generate her own DH pair, and forward her public value to Bob while keeping the original for Alice.  
Alice and Eve now share a secret ; Bob and Eve share a different secret.  
Because Eve knows both secrets, she can decrypt, read or modify every packet that passes between Alice and Bob.

In MedDefense’s VPN link from Central to Westside, the FortiGate uses an IPsec tunnel that performs DH key exchange but lacks certificate‑based authentication.  
An attacker on the path could simply replace the DH parameters with her own, establishing two parallel tunnels: one to Central and one to Westside.  
With both shared secrets in hand, she can read, alter, or drop traffic without anyone noticing.

Certificates solve this by binding the DH key exchange to a trusted identity (the VPN gateway’s public key).  
The client verifies the server’s certificate against a trusted CA; if Eve tries to inject her own parameters, the certificate chain fails and the connection is rejected, preventing the MITM attack.
