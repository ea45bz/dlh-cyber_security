 
Risk: "Ransomware encrypts the EHR system"
Source:
  gap_id: GAP‑001
  vulnerability_finding: CVE‑2023‑27997 (FortiOS SSL‑VPN RCE)
  threat_actor: Crimson Tide
Asset:
  name: ehr‑srv‑01
  av:
    replacement_and_recovery: 15000000
    revenue_loss_per_day: 1000000
    estimated_downtime_days: 7
    regulatory_penalties: 2000000
    reputation_impact: 5000000
    total: 25000000   # sum of all above
Exposure Factor (EF):
  percentage: 80.0
  reasoning: |
    The CVE is actively exploited against hospitals with the same firmware,
    and the flat internal network gives attackers full lateral movement.
sle: 20000000          # AV * EF
aro:
  frequency_per_year: 0.5
  reasoning: |
    CISA reports one compromise in a comparable hospital within three days.
    Given our similar footprint, we expect roughly half an incident per year.
ale_before: 10000000   # SLE * ARO
Proposed Control: "Transparent Data Encryption (TDE) for the EHR database"
Control Annual Cost: 12000
  new_exposure_factor_percentage: 10.0
Estimated ALE After Control: 2500000   # AV * 0.1 * 0.5
Net Benefit: 7488000   # ALE_before - ALE_after - cost
 
Risk: "Unencrypted VPN grants remote attackers a foothold"
source:
  gap_id: GAP‑006
  vulnerability_finding: CVE‑2023‑27997 (FortiOS SSL‑VPN RCE)
  threat_actor: Crimson Tide
asset:
  name: web‑srv‑01   # patient portal
  av:
    replacement_and_recovery: 4000000
    revenue_loss_per_day: 200000
    estimated_downtime_days: 2
    regulatory_penalties: 500000
    reputation_impact: 1000000
    total: 5900000
Exposure Factor (EF):
  percentage: 70.0
  reasoning: |
    The VPN is the only external entry point; exploitation would provide
    direct administrative access to all servers.
sle: 4130000          # AV * EF
aro:
  frequency_per_year: 1.0
  reasoning: |
    Attack attempts are frequent, but a successful exploit occurs about once per year in comparable hospitals.
ale_before: 4130000   # SLE * ARO
Proposed Control: "Upgrade FortiGate to v7.4.x and enable MFA on SSL‑VPN"
Control Annual Cost: 6000
  new_exposure_factor_percentage: 20.0
Estimated ALE After Control: 1180000   # AV * 0.2 * 1.0
Net Benefit: 2944000
 
Risk: "Backup data destruction on the on‑prem NAS"
source:
  gap_id: GAP‑009
  vulnerability_finding: Unencrypted, on‑prem backup storage
  threat_actor: Crimson Tide
asset:
  name: nas-01   # backup server
  av:
    replacement_and_recovery: 4000000
    revenue_loss_per_day: 0
    estimated_downtime_days: 0
    regulatory_penalties: 1000000
    reputation_impact: 2000000
    total: 7000000
Exposure Factor (EF):
  percentage: 60.0
  reasoning: |
    Attackers routinely delete or corrupt unencrypted backups in the same sector.
sle: 4200000          # AV * EF
aro:
  frequency_per_year: 0.2
  reasoning: |
    Successful backup destruction events are rare (~1 every 5 years) in similar hospitals.
ale_before: 840000   # SLE * ARO
Proposed Control: "Encrypt the NAS volumes and enable off‑site replication"
Control Annual Cost: 15000
  new_exposure_factor_percentage: 10.0
Estimated ALE After Control: 70000    # AV * 0.1 * 0.2
Net Benefit: 755000
 
Risk: "Credential theft via weak Kerberos (RC4) and AD authentication"
source:
  gap_id: GAP‑003
  vulnerability_finding: RC4 enabled in AD Kerberos tickets
  threat_actor: Internal / Opportunistic attacker
asset:
  name: ad-dc-01   # Active Directory domain controller
  av:
    replacement_and_recovery: 3000000
    revenue_loss_per_day: 500000
    estimated_downtime_days: 3
    regulatory_penalties: 1000000
    reputation_impact: 1000000
    total: 6500000
Exposure Factor (EF):
  percentage: 50.0
  reasoning: |
    RC4 allows offline cracking of service tickets; many users share passwords.
sle: 3250000          # AV * EF
aro:
  frequency_per_year: 0.75
  reasoning: |
    Internal credential compromise incidents occur roughly quarterly in our environment.
ale_before: 2437500   # SLE * ARO
Proposed Control: "Enforce AES‑256 Kerberos tickets and encrypt AD attributes"
Control Annual Cost: 4000
  new_exposure_factor_percentage: 5.0
Estimated ALE After Control: 325000     # AV * 0.05 * 0.75
Net Benefit: 2111000
 
Risk: "Phishing / social engineering leads to credential compromise"
source:
  gap_id: GAP‑012
  vulnerability_finding: Inadequate security awareness training
  threat_actor: External phishers targeting clinicians
asset:
  name: billing-srv-01   # critical application server
  av:
    replacement_and_recovery: 3000000
    revenue_loss_per_day: 1000000
    estimated_downtime_days: 2
    regulatory_penalties: 800000
    reputation_impact: 1000000
    total: 7800000
Exposure Factor (EF):
  percentage: 40.0
  reasoning: |
    Phishing is common; with weak training the likelihood of a successful credential compromise is moderate.
sle: 3120000          # AV * EF
aro:
  frequency_per_year: 2.0
  reasoning: |
    Based on industry data, hospitals experience about two successful phishing incidents per year that lead to credential theft.
ale_before: 6240000   # SLE * ARO
Proposed Control: "Revamp security awareness program (role‑specific training + phishing simulation)"
Control Annual Cost: 8000
  new_aro_per_year: 0.5
Estimated ALE After Control: 1560000   # SLE * new AROR = 3120000*0.5
Net Benefit: 4672000

Risk Prioritization by ALE:
- name: "Phishing / social engineering leads to credential compromise"
  ale_before: 6240000
- name: "Ransomware encrypts the EHR system"
  ale_before: 10000000
- name: "Unencrypted VPN grants remote attackers a foothold"
    ale_before: 4130000
- name: "Credential theft via weak Kerberos (RC4) and AD authentication"
  ale_before: 2437500
- name: "Backup data destruction on the on‑prem NAS"
  ale_before: 840000

