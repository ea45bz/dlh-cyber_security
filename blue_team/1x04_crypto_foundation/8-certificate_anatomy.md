# Part 1 - Inspect Three Real Certificates

```bash
openssl s_client -showcerts </dev/null -connect letsencrypt.org:443 >letsencrypt.org.pem
openssl s_client -showcerts </dev/null -connect github.com:443 >github.com.pem
openssl s_client -showcerts </dev/null -connect expired.badssl.com:443 >expired.badssl.com.pem


openssl x509  -text -noout -in letsencrypt.org.pem

Subject: C=US, ST=California, L=San Francisco, O=Netlify, Inc, CN=*.netlify.app
Issuer: C=US, O=DigiCert Inc, CN=DigiCert Global G2 TLS RSA SHA256 2020 CA1
Validity:
  Not Before: Feb 16 00:00:00 2026 GMT
  Not After : Mar 19 23:59:59 2027 GMT
Serial Number: 0c:d5:d0:af:b0:61:1b:5b:d9:d6:92:53:5c:0c:a7:c4
Signature Algorithm: sha256WithRSAEncryption
Public Key Info: id-ecPublicKey, P-256
SAN: DNS:*.netlify.app, DNS:netlify.app
X509v3 Key Usage: critical
X509v3 Extended Key Usage: TLS Web Server Authentication
Authority Information Access:
  OCSP - URI:http://ocsp.digicert.com
  CA Issuers - URI:http://cacerts.digicert.com/DigiCertGlobalG2TLSRSASHA2562020CA1-1.crt

openssl x509 -text -noout -in github.com.pem

Subject: CN=github.com
Issuer: C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication CA DV E36
Validity:
    Not Before: Sep  1 00:00:00 2026 GMT
    Not After : Nov 29 23:59:59 2026 GMT
Serial Number: a5:9e:bd:b5:96:75:1d:b7:f5:c0:95:07:96:13:95:3c
Signature Algorithm: ecdsa-with-SHA256
Public Key Info: id-ecPublicKey, P-256
SAN: DNS:github.com, DNS:www.github.com
X509v3 Key Usage: critical
X509v3 Extended Key Usage: TLS Web Server Authentication
Authority Information Access:
    CA Issuers - URI:http://crt.sectigo.com/SectigoPublicServerAuthenticationCADVE36.crt
    OCSP - URI:http://ocsp.sectigo.com

openssl x509 -text -noout -in expired.badssl.com.pem


Subject: C=US, ST=California, L=San Francisco, O=BadSSL Fallback. Unknown subdomain or no SNI., CN=badssl-fallback-unknown-subdomain-or-no-sni
Issuer: C=US, ST=California, L=San Francisco, O=BadSSL, CN=BadSSL Intermediate Certificate Authority
Validity:
    Not Before: Aug  8 21:17:05 2016 GMT
    Not After : Aug  8 21:17:05 2018 GMT
Serial Number: cd:bc:5a:4a:ec:97:67:b1
Signature Algorithm: sha256WithRSAEncryption
Public Key Info: rsaEncryption RSA Public-Key: (2048 bit)
SAN: DNS:badssl-fallback-unknown-subdomain-or-no-sni
Key Usage / EKU: present in raw output

# Part 2 - The Broken Certificate

For the expired.badssl.com.pem certificate the validity is expired, as the value for the key "Not After" is  "Aug  8 21:17:05 2018 GMT".
A browser would respond with an unsecure message, that the certificate is expired.
I would not advise a patient to proceed to portal with a certificate error.

# Part 3 - MedDefense Certificate Profile

## What type (DV, OV, EV) and why


Organizational Validation (OV)

The portal is public‑facing and handles PHI, so users need confidence that the site truly belongs to MedDefense. An OV cert proves that a legitimate, verified entity owns the domain, which is enough for HIPAA compliance and most browsers without the extra cost of EV.

## What CA should issue it and why

Certificate Authority (CA)

GlobalSign, DigiCert, or Sectigo – any CA that offers HIPAA‑compliant OV certificates with strong audit trails.

## What SAN entries should it include

https://portal.meddefense.com,
https://www.portal.meddefense.com

Explicit SANs give browsers a clear indication that every URL in the list is covered and prevent accidental exposure via an unintended sub‑domain.

## What key algorithm and size

RSA 2048 bits or ECC P‑256

They provide ~128‑bit security; both are supported by all clients. ECC is slightly more efficient for mobile users, but if the hospital’s load balancer only accepts RSA you can use that instead.
What validity period

##  Whether a wildcard or single-domain certificate is more appropriate

Avoid a wildcard (*.meddefense.com) unless you know that all sub‑domains are secured with identical TLS configurations; otherwise, list each host.
```
