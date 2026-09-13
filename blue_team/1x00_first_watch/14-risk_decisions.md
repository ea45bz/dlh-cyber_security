**Risk Treatment Decisions (Top 7 gaps)**

```
Gap ID: GAP-001
Gap Title: No corrective restoration test for EHR server
Risk Level: Critical

Treatment Strategy: Mitigate

Justification:
  The EHR server is a core business asset.  A single loss of data or downtime would trigger regulatory fines, patient harm and revenue loss that far exceed any reasonable budget allocation.
  A small‑scale automated restore‑test suite can be built once and run nightly, keeping costs low while providing high assurance.

If Mitigate:
  - Proposed Control(s):
      • Technical – Corrective: Automated full‑restore validation of the EHR database and file system
      • Operational: Scheduled monthly dry‑runs with audit logging
  - Estimated Cost: $10‑50K (shared tooling for server & DB)
  - Implementation Effort: Short‑term < 1 month
  - Expected Risk Reduction:
      • Drastically lowers risk of undetected corruption or data loss (≈ 90 % reduction)
      • Provides compliance evidence for HIPAA and audit purposes

Trade‑offs:
  • Initial development effort may compete with other projects, but once built it requires minimal ongoing maintenance.
  • Testing in a production environment introduces small risk of service interruption; mitigated by scheduling during low‑usage windows.

--------------------------------------------------------------------

Gap ID: GAP-002
Gap Title: No corrective restoration test for EHR database
Risk Level: Critical

Treatment Strategy: Mitigate

Justification:
  Same assets as GAP‑001, but the database layer is even more critical because corruption propagates to all downstream applications.
  Using the same restore‑test framework as GAP‑001 keeps cost and effort consolidated.

If Mitigate:
  - Proposed Control(s):
      • Technical – Corrective: Post‑backup integrity verification of PostgreSQL snapshots
      • Operational: Bi‑weekly recovery drills with rollback scripts
  - Estimated Cost: $10‑50K (shared tooling)
  - Implementation Effort: Short‑term < 1 month
  - Expected Risk Reduction:
      • High‑confidence validation reduces data loss risk by ≈ 90 %

Trade‑offs:
  • Shared tooling limits customization; any future changes to backup format may require re‑development.
  • Recovery drills could temporarily lock the DB, but can be scheduled for maintenance windows.

--------------------------------------------------------------------

Gap ID: GAP-006
Gap Title: No domain‑controller disaster‑recovery plan
Risk Level: Critical

Treatment Strategy: Mitigate

Justification:
  Loss of AD DC would cripple authentication across the entire hospital network.
  A robust failover plan (secondary DC, replication) is mandatory and justified by high risk.

If Mitigate:
  - Proposed Control(s):
      • Technical – Corrective: Secondary domain controller with live replication
      • Administrative – Preventive: Documentation and quarterly drill schedule
  - Estimated Cost: $10‑50K ($25K for additional DC hardware & licensing)
  - Implementation Effort: Long‑term > 1 month (includes design, deployment, testing)
  - Expected Risk Reduction:
      • Prevents single‑point failure; risk of catastrophic downtime drops from 90 % to < 5 %

Trade‑offs:
  • Initial capital outlay and ongoing licensing costs.
  • Requires staff training on failover procedures.

--------------------------------------------------------------------

Gap ID: GAP-007
Gap Title: No firmware hardening / device firewall for ICU monitor
Risk Level: Critical

Treatment Strategy: Mitigate

Justification:
  The ICU monitor is a life‑support device; any compromise can directly harm patients.
  Device hardening and a lightweight firewall are inexpensive but provide essential protection.

If Mitigate:
  - Proposed Control(s):
      • Technical – Preventive: Secure boot, signed firmware updates, host‑based firewall
      • Administrative – Policy: Firmware upgrade schedule & change management
  - Estimated Cost: $1‑10K (≈$8K for vendor licensing and update tooling)
  - Implementation Effort: Short‑term < 1 month
  - Expected Risk Reduction:
      • Blocks unauthorized firmware loading, reducing exploit risk by ~95 %

Trade‑offs:
  • Some device vendors may not support secure boot without hardware upgrades.
  • Frequent firmware updates can temporarily disrupt patient monitoring if not scheduled properly.

--------------------------------------------------------------------

Gap ID: GAP-009
Gap Title: No backup recovery test for backup infrastructure (NAS/Backup‑SRV)
Risk Level: Critical

Treatment Strategy: Mitigate

Justification:
  Failure to recover backups would erase all PHI, imaging and billing data.
  Testing the backup stack itself is a best practice that can be achieved with minimal extra cost by reusing the restore framework from GAP‑001/002.

If Mitigate:
  - Proposed Control(s):
      • Technical – Corrective: Full‑restore tests on NAS and backup servers
      • Operational: Quarterly dry‑run schedule, automated failure alerts
  - Estimated Cost: $5‑20K (shared with server/database restore tools)
  - Implementation Effort: Short‑term < 1 month
  - Expected Risk Reduction:
      • Verifies that backups can be recovered; risk of data loss drops from ~90 % to < 5 %

Trade‑offs:
  • Testing may consume backup bandwidth and storage temporarily.
  • Requires coordination with storage vendors for test environments.

--------------------------------------------------------------------

Gap ID: GAP-003
Gap Title: No asset‑specific firewall/IDS rules for PACS
Risk Level: High

Treatment Strategy: Mitigate

Justification:
  Imaging data is PHI and critical for patient care; lateral compromise of the PACS server could alter images.
  Adding segmentation and IDS/IPS rules is a low‑cost, high‑impact measure.

If Mitigate:
  - Proposed Control(s):
      • Technical – Preventive: Host‑based firewall & IDS/IPS policies specific to PACS
      • Operational: Weekly log review and alerting
  - Estimated Cost: $5‑20K (network device configuration + SIEM rules)
  - Implementation Effort: Short‑term < 1 month
  - Expected Risk Reduction:
      • Reduces lateral movement risk by ~80 %; prevents unauthorized imaging access.

Trade‑offs:
  • Requires network reconfiguration; may need temporary downtime.
  • IDS false positives could increase alert fatigue if not tuned.

--------------------------------------------------------------------

Gap ID: GAP-004
Gap Title: No application‑level logs for PACS server
Risk Level: High

Treatment Strategy: Mitigate

Justification:
  Detecting image tampering or unauthorized changes is essential; application‑level logging is inexpensive and highly effective.

If Mitigate:
  - Proposed Control(s):
      • Technical – Detective: Enable comprehensive audit logs on PACS application + centralized log aggregation
      • Operational: Log rotation, retention policy & quarterly review
  - Estimated Cost: $1‑10K (log agent, SIEM subscription share)
  - Implementation Effort: Quick Win < 1 week
  - Expected Risk Reduction:
      • Provides forensic evidence and early detection; risk of undetected tampering falls from ~60 % to < 10 %

Trade‑offs:
  • Increased storage requirements for logs.
  • Potential performance impact if logging is not optimized.

--------------------------------------------------------------------
```

---

## Budget Summary

| Gap                                | Mitigation Cost |
| ---------------------------------- | --------------- |
| GAP‑001 + GAP‑002 (shared tooling) | $20,000         |
| GAP‑006                            | $25,000         |
| GAP‑007                            | $8,000          |
| GAP‑009 (shared tooling)           | $12,000         |
| GAP‑003                            | $18,000         |
| GAP‑004                            | $10,000         |
| **Total**                          | **$93,000**     |

### Allocation vs. Budget

- **Annual budget:** $120 000
- **Planned spend:** $93 000
- **Remaining runway:** $27 000

The remaining $27 k can be reserved for contingency (e.g., unforeseen hardware upgrades) or for additional control enhancements such as SIEM tuning, staff training, or periodic red‑team exercises.

### What to defer if costs creep

If any control cost estimate rises above the budgeted figure, we would defer the most expensive single‑off component to FY‑next year—typically the **AD DC failover hardware (GAP‑006)**. The justification is that the existing single DC remains functional and that other high‑risk controls are already in place; thus delaying a secondary DC gives us time to secure additional funding without exposing the network to new risks.

---
