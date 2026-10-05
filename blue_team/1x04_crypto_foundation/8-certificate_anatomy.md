# Part 1 - Inspect Three Real Certificates

```bash
openssl s_client -showcerts </dev/null -connect letsencrypt.org:443 >letsencrypt.org.pem
openssl s_client -showcerts </dev/null -connect github.com:443 >github.com.pem
openssl s_client -showcerts </dev/null -connect expired.badssl.com:443 >expired.badssl.com.pem

openssl x509 -text -in letsencrypt.org.pem

openssl x509  -text -noout -in letsencrypt.org.pem
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            0c:d5:d0:af:b0:61:1b:5b:d9:d6:92:53:5c:0c:a7:c4
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, O=DigiCert Inc, CN=DigiCert Global G2 TLS RSA SHA256 2020 CA1
        Validity
            Not Before: Feb 16 00:00:00 2026 GMT
            Not After : Mar 19 23:59:59 2027 GMT
        Subject: C=US, ST=California, L=San Francisco, O=Netlify, Inc, CN=*.netlify.app
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:64:c3:ab:83:a1:9f:9b:f7:ff:e5:00:bf:41:ae:
                    cd:d1:cd:1c:5d:8d:4d:62:fb:0e:e4:90:33:13:2d:
                    b5:45:91:e6:7a:26:a0:5e:01:ae:25:84:fb:d5:88:
                    23:7e:13:7e:a9:d3:a5:de:69:2d:91:69:c3:12:86:
                    5a:94:02:42:28
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Authority Key Identifier:
                keyid:74:85:80:C0:66:C7:DF:37:DE:CF:BD:29:37:AA:03:1D:BE:ED:CD:17

            X509v3 Subject Key Identifier:
                3E:6A:BE:6E:25:AC:12:10:AB:BE:F1:EB:A7:A9:BC:6D:88:7D:54:8F
            X509v3 Subject Alternative Name:
                DNS:*.netlify.app, DNS:netlify.app
            X509v3 Certificate Policies:
                Policy: 2.23.140.1.2.2
                  CPS: http://www.digicert.com/CPS

            X509v3 Key Usage: critical
                Digital Signature, Key Agreement
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://crl3.digicert.com/DigiCertGlobalG2TLSRSASHA2562020CA1-1.crl

                Full Name:
                  URI:http://crl4.digicert.com/DigiCertGlobalG2TLSRSASHA2562020CA1-1.crl

            Authority Information Access:
                OCSP - URI:http://ocsp.digicert.com
                CA Issuers - URI:http://cacerts.digicert.com/DigiCertGlobalG2TLSRSASHA2562020CA1-1.crt

openssl x509 -text -noout -in github.com.pem

Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            a5:9e:bd:b5:96:75:1d:b7:f5:c0:95:07:96:13:95:3c
    Signature Algorithm: ecdsa-with-SHA256
        Issuer: C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication CA DV E36
        Validity
            Not Before: Sep  1 00:00:00 2026 GMT
            Not After : Nov 29 23:59:59 2026 GMT
        Subject: CN=github.com
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:85:36:1b:34:bc:b3:51:f7:20:e9:aa:9a:cb:e8:
                    27:2d:60:d1:31:7b:1d:38:d1:d8:c7:d7:a0:fa:5a:
                    b1:f1:2f:28:e7:99:51:46:61:22:38:b2:3e:b0:2b:
                    75:75:ec:00:e2:69:a6:cf:13:4e:2f:42:4e:fa:76:
                    35:b4:0d:3f:2a
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Authority Key Identifier:
                keyid:17:99:A8:04:C1:6F:E4:2D:70:A8:0A:10:3D:03:D3:E9:1A:B8:26:63

            X509v3 Subject Key Identifier:
                66:98:EC:4C:11:35:F7:4B:50:84:8B:A8:1C:36:65:D0:17:56:D4:E0
            X509v3 Key Usage: critical
                Digital Signature
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Certificate Policies:
                Policy: 1.3.6.1.4.1.6449.1.2.2.7
                  CPS: https://sectigo.com/CPS
                Policy: 2.23.140.1.2.1

            Authority Information Access:
                CA Issuers - URI:http://crt.sectigo.com/SectigoPublicServerAuthenticationCADVE36.crt
                OCSP - URI:http://ocsp.sectigo.com

openssl x509 -text -noout -in expired.badssl.com.pem

Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            cd:bc:5a:4a:ec:97:67:b1
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=California, L=San Francisco, O=BadSSL, CN=BadSSL Intermediate Certificate Authority
        Validity
            Not Before: Aug  8 21:17:05 2016 GMT
            Not After : Aug  8 21:17:05 2018 GMT
        Subject: C=US, ST=California, L=San Francisco, O=BadSSL Fallback. Unknown subdomain or no SNI., CN=badssl-fallback-unknown-subdomain-or-no-sni
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)


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
