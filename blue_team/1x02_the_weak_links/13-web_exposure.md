```yaml
web_hosts:
  - host: "10.10.2.50 (web‑srv‑01 – Patient Portal)"
    exposure: "Internet‑facing"
    findings:
      - id: "FINDING 005"
        name: "SSL/TLS Weak Protocol Version Detection"
        details: |
          TLS 1.0 and 1.1 enabled; vulnerable to BEAST, POODLE,
          Lucky Thirteen, and downgrade attacks.
      - id: "FINDING 012"
        name: "HTTP Security Headers Missing"
        details: |
          No X‑Content‑Type‑Options, X‑Frame‑Options, CSP, HSTS, or
          X‑XSS‑Protection headers – opens the portal to clickjacking,
          MIME sniffing and reflected XSS.
      - id: "FINDING 013"
        name: "SSL Certificate Expiration Warning"
        details: |
          Let’s Encrypt cert expires in 23 days; users will see
          browser warnings which can be leveraged for phishing.
      - id: "FINDING 021"
        name: "HTTP TRACE Method Enabled"
        details: |
          Allows XST attacks to read HTTP headers, potentially leaking
          session cookies or authentication tokens.
    combined_risk: >
      **High** – External exposure, multiple active web‑app
      vulnerabilities that can be chained for credential theft,
      data exfiltration and phishing. The portal contains PHI,
      making compromise a direct threat to privacy and compliance.
    attack_scenario:
      - step: "Reconnaissance"
        action: |
          Discover public URL (e.g., https://portal.meddefense.com) via
          DNS lookup or search engine enumeration.
      - step: "Weaponization & Delivery"
        action: |
          Craft a phishing email with a link that forces an HTTPS downgrade
          to TLS 1.0/1.1, or use a legitimate client that still accepts it.
      - step: "Exploitation"
        action: |
          * Exploit TLS downgrade → MITM on traffic.  
          * Use missing security headers + TRACE to read session cookies via XST.  
          * Inject malicious script (XSS) into patient portal pages; steal
            authentication tokens or perform CSRF against internal services.
      - step: "Installation / Persistence"
        action: |
          Persist via stolen credentials, add a reverse shell inside the web
          application (e.g., using uploaded file upload vulnerability,
          if present).
      - step: "Command & Control"
        action: |
          Communicate through encrypted channels to external C&C host.
      - step: "Actions on Objectives"
        action: |
          Steal PHI, create backdoors into internal network, or spread
          ransomware via web session hijacking.
    priority: "Highest – must be remediated immediately (patch TLS stack,
      enable HSTS, implement security headers, replace expiring
      cert)."

  - host: "10.10.2.10 (ehr‑srv‑01 – EHR Application Server)"
    exposure: "Internal – flat network accessible"
    findings:
      - id: "FINDING 017"
        name: "Apache Tomcat Default Error Page Disclosure"
        details: |
          Error pages reveal Tomcat version 9.0.31 and internal stack traces.
          Information useful for targeting known CVEs (e.g., Ghostcat).
      - id: "FINDING 031"
        name: "AJP Connector – Ghostcat Vulnerability (CVE‑2020-1938)"
        details: |
          Active AJP listener on port 8009. Public PoC allows reading any file
          on the server, including database credentials.
    combined_risk: >
      **Critical** – While internal-only, the flat network makes every host a
      potential pivot point. The vulnerability exposes patient data and DB
      credentials; an attacker who has compromised any workstation can use it to
      read PHI or move laterally into the production database.
    attack_scenario:
      - step: "Reconnaissance"
        action: |
          Enumerate internal hosts; identify Tomcat service via port scan (8009).
      - step: "Weaponization & Delivery"
        action: |
          Use a known Ghostcat exploit or manually craft an AJP request
          to read /etc/passwd, web.xml, or database config files.
      - step: "Exploitation"
        action: |
          Extract MySQL credentials from application.properties; use them to
          connect directly to the PostgreSQL instance (Findings 003) and
          dump PHI tables.
      - step: "Installation / Persistence"
        action: |
          Create a new admin user in EHR database; install web shell or
          reverse proxy backdoor on the Tomcat host.
      - step: "Command & Control"
        action: |
          Communicate via encrypted tunnel to exfiltrate data or control
          compromised workstation.
      - step: "Actions on Objectives"
        action: |
          Steal full PHI, modify medical records, deploy ransomware onto
          EHR system, or pivot into other internal services.
    priority: "Second – high‑impact internal vulnerability; remediate
      by disabling the AJP connector or hardening Tomcat (update,
      restrict to loopback)."

  - host: "10.10.2.41 (NAS‑01 – Backup Storage)"
    exposure: "Internal‑only"
    findings:
      - id: "FINDING 015"
        name: "Synology DSM Web Interface Accessible from Entire Internal Network"
        details: |
          DSM management console is reachable on ports 5000/5001 with
          default credentials still active. Backup data stored unencrypted.
    combined_risk: >
      **High** – An attacker who has moved laterally inside the network can
      gain full administrative control over all backup data, potentially
      deleting or tampering with backups and compromising disaster recovery.
    attack_scenario:
      - step: "Reconnaissance"
        action: |
          Scan internal subnets for open 5000/5001 ports; identify NAS.
      - step: "Weaponization & Delivery"
        action: |
          Brute‑force default admin/user credentials or use known
          credential leaks (admin/admin) to log in.
      - step: "Exploitation"
        action: |
          Gain root privileges on DSM; download, alter, or delete backup
          archives. Optionally install a backdoor or ransomware payload.
      - step: "Installation / Persistence"
        action: |
          Create a hidden admin user or enable SSH with key-based access for
          persistent control over the NAS.
      - step: "Command & Control"
        action: |
          Use DSM’s web interface to initiate data exfiltration to an
          external server, or establish outbound connections from the
          internal network.
      - step: "Actions on Objectives"
        action: |
          Destroy recovery capabilities, plant ransomware or spy on backup
          traffic. Secondary objective: compromise any medical device that
          uses the NAS for configuration backups.
    priority: "Third – important but lower than internet‑facing portal and EHR;
      remediate by disabling DSM web access from non‑trusted hosts,
      enforce strict ACLs, change default credentials, and encrypt backups."
```
