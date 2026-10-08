
Action 1: "Enable Transparent Data Encryption (TDE) on MedDefense EHR PostgreSQL server"
Priority: Immediate
System Affected: ehr-srv-01
Prerequisites:
  - Full DB snapshot in postgresql_backup/
  - Postgres 13 with pgcrypto installed (`sudo apt install postgresql-contrib`).
  - Sufficient disk space on /var/lib/postgresql/12/main.
Steps:
  - "SSH into ehr‑srv‑01: `ssh user@ehr-srv-01`."
  - "Create a master key table and insert a random 256‑bit key:"
    ```sql
    CREATE TABLE tde_key (id INT PRIMARY KEY, key BYTEA);
    INSERT INTO tde_key VALUES (1, gen_random_bytes(32));
    ```
  - "Enable the pgcrypto extension: `CREATE EXTENSION IF NOT EXISTS pgcrypto;`."
  - "Encrypt sensitive tables via column‑level encryption (example shown)."
  - "Restart PostgreSQL: `sudo systemctl restart postgresql`."
Validation:
  - "Confirm the extension exists: `SELECT * FROM pg_extension WHERE extname='pgcrypto';` returns a row."
  - "Verify encrypted columns are BYTEA: `\d ehr_patients` should show type BYTEA."
  - "Run a test insert/select to ensure data is stored encrypted and application performance is acceptable."
Rollback:
  - "Restore the database from snapshot: `pg_restore -U postgres -d ehr_db /var/lib/backup/ehr_backup.sql`."
  - "If service downtime exceeds 30 min, revert immediately."
Maintenance Window: "Overnight (22:00–02:00) – minimal EHR user activity."
Communication:
  - "Notify Clinical Ops & Billing teams 24 hrs prior."
  - "Send completion update to CEO & COO after successful TDE deployment."

Action 2: "Force AES‑256 Kerberos and encrypt AD DS attributes"
Priority: Immediate
System Affected: "Active Directory Domain Controllers (ad-dc-01, ad-dc-02)"
Prerequisites:
  - Group Policy Management Console available on ad-dc‑01.
  - All DCs are Windows Server 2019 and fully patched.
Steps:
  - "Open GPMC → create new GPO ‘Kerberos AES‑256 only’ linked to the DC OU."
  - "Edit GPO → Computer Config → Policies → Windows Settings → Security Settings → Local Policies → Security Options:"
    - `Domain member: Use default credentials only for delegation` = Enabled
    - `Network security: LAN Manager authentication level` = Send NTLMv2 responses only
  - "Under Computer Configuration → Administrative Templates → System → KDC & Kerberos, set:"
    - `Kerberos Authentication Service Pre‑auth` = Enable
    - `Kerberos Ticket Encryption Types` to include AES‑256 and remove RC4.
  - "Force GPO update: `gpupdate /force` on all DCs."
Validation:
  - "Run `klist -f` on a workstation – should display `aes256-cts-hmac-sha1-96` tickets."
  - "Attempt authentication with an old RC4‑based service account – it must fail."
  - "Verify AD DS attributes remain encrypted and accessible."
Rollback:
  - "Delete or revert the GPO to its previous state via GPMC."
  - "Restore any backed‑up policy files if needed."
Maintenance Window: "Business hours (09:00–11:00) – low impact on authentication services."
Communication:
  - "Inform all department heads of a brief “system maintenance” window."
  - "Post status update in the IT internal wiki after deployment."

Action 3: "Upgrade FortiGate firmware to 7.4.x and enable TLS 1.3 + MFA on SSL‑VPN"
Priority: Immediate
System Affected: FortiGate‑100F (Central)
Prerequisites:
  - Current FortiGate firmware ≥ 7.0.0.
  - Valid license key for firmware 7.4.x.
  - Backup of the current configuration (`execute backup config flash <name>.conf`).
Steps:
  - "Log into the FortiGate CLI: `ssh admin@fortigate`."
  - "Back up the running config to flash: `execute backup config flash <name>.conf`."
  - "Download firmware 7.4.x from Fortinet support portal."
  - "Upload image via GUI or CLI (`config system global` → `set fw-upgrade-mode upgrade`)."
  - "Install update and reboot when prompted."
  - "After reboot, verify version: `get system status`."
  - "Enable TLS 1.3 on SSL‑VPN: "
    ```plaintext
    config vpn ssl settings
        set tls-version 13
        set min-tls-version 13
        set server-cert "FortiGate-SSL"
        set client-authentication-mode mfa
    end
    ```
  - "Configure MFA (e.g., FortiToken or third‑party OTP) and associate it with VPN policies."
Validation:
  - "`show vpn ssl settings` should list TLS 1.3 only."
  - "External test: `openssl s_client -connect fortigate:443 -tls1_3` – handshake succeeds."
  - "Verify a test VPN session using MFA; check event logs for successful authentication."
Rollback:
  - "Restore config backup: `execute restore config flash <name>.conf`."
  - "Re‑install previous firmware if necessary."
Maintenance Window: "Overnight (01:00–03:00) – minimal VPN usage on weekends."
Communication:
  - "Notify IT Ops and Security Ops teams 12 hrs before."
  - "Inform all staff via internal bulletin after upgrade."

Action 4: "Harden patient portal web server TLS to enforce TLS 1.3 + ECDHE_RSA"
Priority: Immediate
System Affected: web-srv-01 (Ubuntu 20.04, Nginx/Apache)
Prerequisites:
  - Valid SSL certificate installed on the domain.
  - Web server supports TLS 1.3 (Nginx ≥ 1.15 or Apache 2.4.38+).
Steps:
  - "SSH into web‑srv‑01: `ssh user@web-srv-01`."
  - "Backup current site config: `cp /etc/nginx/sites-enabled/meddefense.conf /tmp/backup_$(date +%s).conf`."
  - "Edit config to enforce TLS 1.3 only:"
    ```nginx
    ssl_protocols TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_ciphers 'TLS_AES_256_GCM_SHA384';
    ssl_session_timeout 86400;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
    ```
  - "Enable OCSP stapling and HSTS if not already present."
  - "Reload Nginx: `sudo systemctl reload nginx`."
Validation:
  - "`openssl s_client -connect web.somedomain.com:443 -tls1_3` succeeds without TLSv1.2 fallback."
  - "Browser devtools show a secure connection and cipher suite `TLS_AES_256_GCM_SHA384`."
  - "`curl -I https://web.somedomain.com` includes `Strict-Transport-Security` header."
Rollback:
  - "Restore config from backup: `mv /tmp/backup_* /etc/nginx/sites-enabled/meddefense.conf`."
  - "Reload Nginx again."
Maintenance Window: "Business hours (10:00–12:00) – portal is used by clinicians during lunch."
Communication:
  - "Alert the Clinical IT team 3 hrs before."
  - "Post success update in the “Portal” channel of Slack."

Action 5: "Encrypt MySQL billing database tablespaces"
Priority: Phase 1
System Affected: billing-srv-01 (Ubuntu 18.04, MySQL 8.0)
Prerequisites:
  - MySQL 8.0 running and accessible.
  - Physical or logical backup (`mysqldump --single-transaction > billing.sql`).
Steps:
  - "SSH into billing‑srv‑01: `ssh user@billing-srv-01`."
  - "Create encryption key table:"
    ```sql
    CREATE TABLE encrypt_keys (id INT PRIMARY KEY, key BLOB);
    INSERT INTO encrypt_keys VALUES (1, AES_ENCRYPT('mysecretkey', 'random_salt'));
    ```
  - "Enable InnoDB tablespace encryption globally:"
    ```ini
    SET GLOBAL innodb_encrypt_tables=ON;
    SET GLOBAL innodb_encrypt_log=ON;
    ```
  - "Alter existing billing tables to use encrypted tablespaces (example):"
    ```sql
    ALTER TABLE billing_transactions ENGINE=InnoDB, ENCRYPTION='Y';
    ```
Validation:
  - "`SELECT ENCRYPTION FROM information_schema.TABLES WHERE TABLE_NAME='billing_transactions';` returns 'YES'."
  - "Run `SHOW CREATE TABLE billing_transactions;` – confirms `ENCRYPTION='Y'`."
  - "Perform a test insert/select to ensure data is encrypted on disk."
Rollback:
  - "If problems arise, disable encryption: "
    ```sql
    ALTER TABLE billing_transactions ENCRYPTION='N';
    ```
  - "Restore from physical backup if integrity fails."
Maintenance Window: "Overnight (02:00–04:00) – minimal billing activity."
Communication:
  - "Notify Finance & Billing leads 24 hrs prior."
  - "Update status in IT Ops after completion."

