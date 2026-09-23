```yaml
cve_segment_analysis:
  - CVE: "CVE‑2021‑44790"
    Host: "10.10.2.15 (billing-srv-01 – Apache HTTP Server mod_lua Buffer Overflow)"
    CVSS Base Score: 9.8
    Scenario A:
      Current flat network:
        Who can reach this vulnerability: >
          Every host in the 10.10.0.0/16 subnet can send a crafted HTTP request to
          billing‑srv‑01 (port 80). No ACLs, no VLAN isolation.
        What the attacker can reach AFTER exploitation: >
          After gaining code execution on billing‑srv‑01 an attacker can:
          * pivot via SSH or local privileges to the internal PostgreSQL instance
            (ehr‑db‑01) – stealing PHI & financial data;
          * compromise any workstation in the same subnet;  
          * use the compromised host as a launchpad for lateral movement into
            the domain controller, EHR server, and even medical devices.
        Effective Risk:
          "Extremely high – immediate access to all internal assets,
          including patient‑record databases and critical infrastructure."
    Scenario B:
      Hypothetical segmented network:
        Who can reach this vulnerability: >
          Only hosts in billing‑srv‑01’s VLAN (e.g., other billing or accounting
          servers). Typical segmentation might include 5–7 hosts.
        What the attacker can reach AFTER exploitation: >
          The attacker can move to:
          * other billing or finance servers within the same VLAN;  
          * the local database if it resides in that VLAN;  
          * any host reachable via a firewall rule (unlikely without additional
            misconfiguration).
        Effective Risk:
          "High – limited to the billing subnet, no direct reach to
          EHR, DC, or medical devices."
    risk_amplification_factor:
      9x
      # Approx. (# of potential victims in flat network / # in segmented VLAN)

  - CVE: "CVE‑2020‑1938"
    Host: "10.10.2.10 (ehr-srv-01 – Apache Tomcat AJP Ghostcat)"
    CVSS Base Score: 9.8
    Scenario A:
      Current flat network:
        Who can reach this vulnerability: >
          Any internal host can connect to port 8009 (AJP) on ehr‑srv‑01.
        What the attacker can reach AFTER exploitation: >
          * Read any file on the Tomcat server – database credentials,
            config files, PHI backups.  
          * From the same compromised workstation reach the PostgreSQL
            instance (ehr‑db‑01), domain controller, billing system,
            and any medical device that communicates over the flat LAN.
        Effective Risk: "Critical – full read of patient records and the
          ability to pivot into all other internal assets."
    Scenario B:
      Hypothetical segmented network:
        Who can reach this vulnerability: >
          Only hosts in ehr‑srv‑01’s VLAN (perhaps 3–4 hosts).
        What the attacker can reach AFTER exploitation: >
          * Access local files and the PostgreSQL instance if it is in the same
            subnet;  
          * No direct reach to DC, billing or medical devices unless a firewall
            misconfiguration allows lateral traffic.
        Effective Risk: "High – confined to the EHR VLAN with no out‑of‑VLAN
          movement."
    Risk Amplification Factor:18x

  - CVE: "CVE‑2019‑0708"
    Host: "10.10.1.70 (WS‑RAD‑01 – Windows XP RDP)"
    CVSS Base Score: 9.8
    Scenario A:
      Current flat network:
        Who can reach this vulnerability: >
          Every internal host can open an RDP session to port 3389 on the MRI workstation.
        What the attacker can reach AFTER exploitation: >
          * Execute arbitrary code as SYSTEM;  
          * From this compromised machine, move to any other host in the
            10.10.0.0/16 subnet – including EHR server, DC,
            billing‑srv‑01, and all medical devices.
        Effective Risk: "Very high – critical imaging equipment is
          exposed, with immediate lateral reach into all
          sensitive systems."
    Scenario B:
      Hypothetical segmented network:
        Who can reach this vulnerability: >
          Only hosts in the MRI workstation’s VLAN (likely 5–6 hosts).
        What the attacker can reach AFTER exploitation: >
          * Local access to imaging files and configuration;  
          * If RDP is allowed only within the VLAN, no reach to EHR or DC.
        Effective Risk: "High – limited to imaging subnet, but still critical
          due to patient data on that workstation."
    Risk Amplification Factor:12x
```
