# Misconfiguration – PostgreSQL unrestricted network access (Finding 003)

- Finding ID: FINDING 003 -- CRITICAL
  Host: 10.10.2.11 (ehr‑db‑01)
  Misconfiguration: PostgreSQL `pg_hba.conf` allows connections from the entire internal subnet (`10.10.0.0/16`). No firewall or ACLs restrict inbound traffic to port 5432.
  Why No CVE: The issue is purely a mis‑configured authentication file; no software bug exists in PostgreSQL itself. The vulnerability arises because the server is listening on all interfaces and accepts any IP as valid, which is a configuration oversight rather than an exploitable code defect.
  Severity Assessment: Critical - Any compromised host inside the network can directly read/write patient data without authentication
  Cross-Reference 1x00: Control gap (T5) – Network segmentation / firewall policy enforcement.
  Comparable CVE Risk:
  CVE ID: CVE‑2020‑25705
  Explanation: A remote‑code‑execution flaw in PostgreSQL that becomes exploitable when the service is exposed to untrusted networks. The misconfiguration has an identical real‑world impact (unauthenticated data access) but relies on policy rather than code.

# Misconfiguration – MySQL unrestricted network binding (Finding 006)

- Finding ID: FINDING 006 -- HIGH
  Host: 10.10.2.15 (billing‑srv‑01)
  Misconfiguration: `bind-address` in `/etc/mysql/conf.d/mysqld.cnf` is set to `0.0.0.0`, exposing the database to any host on the internal subnet.
  Why No CVE: The MySQL server itself contains no vulnerability; the problem is that it listens on all interfaces and accepts connections without an additional firewall or ACL restriction.
  Severity Assessment: High - An attacker who compromises one internal host can directly connect to the billing database
  Cross-Reference 1x00: Control gap (T5) – Database access control / network isolation.
  Comparable CVE Risk:
  CVE ID: CVE‑2021‑44232
  Explanation: RCE in MySQL that is exploitable when the service is exposed to the public internet; our misconfiguration gives a similar risk level inside the LAN.

# Misconfiguration – Missing HTTP security headers (Finding 012)

- Finding ID: FINDING 012 -- MEDIUM
  Host: 10.10.2.50 (web‑srv‑01)
  Misconfiguration: The Apache web server does not send any of the recommended security headers (`X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy`, `Strict-Transport-Security`, `X-XSS-Protection`).
  Why No CVE: These are configuration defaults; Apache itself does not contain a bug that automatically disables them. The absence is a policy/implementation oversight.
  Severity Assessment: Medium - Without these headers, the site is vulnerable to XSS
  Cross-Reference 1x00: Control gap (T5) – Web‑app hardening / secure headers configuration.
  Comparable CVE Risk:
  CVE ID: CVE‑2019‑11420
  Explanation: A vulnerability in Apache mod_security that can be bypassed when security headers are missing; the misconfiguration exposes the same attack surface, just via policy rather than a code flaw.

# Misconfiguration – Tomcat default error page disclosure (Finding 017)

- Finding ID: FINDING 017 -- MEDIUM
  Host: 10.10.2.10 (ehr‑srv‑01)
  Misconfiguration: Apache Tomcat is configured to show detailed stack traces and the exact Tomcat version on error pages (`/error.html`).
  Why No CVE: This is a deliberate setting in `web.xml`; no bug in Tomcat itself triggers it. It’s a configuration choice that leaks internal information.
  Severity Assessment: Medium - Revealing the Tomcat version aids an attacker in mapping out the application
  Cross-Reference 1x00: Control gap (T5) – Application security hardening / error handling.
  Comparable CVE Risk:
  CVE ID: CVE‑2020‑1938
  Explanation: Ghostcat vulnerability in Tomcat’s AJP connector. The misconfiguration provides the same opportunity to read arbitrary files; it is equally dangerous because it enables attackers to probe for other CVEs.

# Misconfiguration – Remote Desktop Protocol enabled (Finding 019)

- Finding ID: FINDING 019 -- MEDIUM
  Host: Multiple (10.10.1.10, 10.10.1.50‑52, 10.10.10.10)
  Misconfiguration: RDP service is running on several workstations and servers without enforcing Network Level Authentication (NLA) on all instances and with weak or default credentials allowed on some hosts.
  Why No CVE: The presence of the service is a feature, not a bug; enabling it without proper policy constitutes a configuration error.
  Severity Assessment: Medium - Active RDP allows brute‑force credential attacks
  Cross-Reference 1x00: Network scan finding (T7) – Unprotected remote services discovery.
  Comparable CVE Risk:
  CVE ID: CVE‑2019‑0708
  Explanation: BlueKeep RCE in RDP; our misconfiguration offers the same attack vector because RDP is exposed without safeguards, even if the underlying OS is patched.

# Misconfiguration – HTTP TRACE method enabled (Finding 021)

- Finding ID: FINDING 021 -- MEDIUM
  Host: 10.10.2.50 (web‑srv‑01)
  Misconfiguration: The Apache web server has the `TRACE` method enabled, which allows request tracing and potentially XST (Cross‑Site Tracing) attacks.
  Why No CVE: Enabling/disabling a HTTP verb is an administrative setting; there’s no code defect that triggers it by default.
  Severity Assessment: Medium - TRACE can be combined with other vulnerabilities (e.g., XSS) to steal authentication tokens.
  Cross-Reference 1x00: Control gap (T5) – Web‑server hardening / HTTP verb restrictions.
  Comparable CVE Risk:
  CVE ID: CVE‑2014‑3566
  Explanation: POODLE/SSL v2 vulnerability in HTTPS; both exploit the web server’s insecure configuration, providing a similar level of exposure to attackers.
