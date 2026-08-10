### 1️⃣ What is **MAC** in Linux?

- **MAC = Mandatory Access Control**  
  A security model where the operating system enforces a fixed set of rules that _cannot_ be overridden by regular users. It’s “mandatory” because every access decision is dictated by the policy, not by discretionary owner permissions.

In Linux, MAC is typically implemented via security modules such as **SELinux**, **AppArmor**
---

### 2️⃣ How does **SELinux** enforce MAC?

In Linux, **SELinux** implements MAC by assigning security contexts (labels) to every object and using Type Enforcement rules to decide permissions.

### What are the differences between SELinux and AppArmor?

AppArmor works by granting access first, then applying restrictions. SELinux, however, restricts access to all applications by default and grants access only to users that present the proper certifications.

_SELinux_ offers a **label‑based**, highly granular, and more complex policy model, while _AppArmor_ uses **path‑based profiles** that are easier to author but less fine‑grained.
**Default install & target** | RHEL/CentOS/Fedora default; _targeted_ (protects only selected daemons) or _strict_ (everything). | Ubuntu/Debian default; each app has its own profile by name. |

### What is the purpose of policy in MAC systems?

the _policy_ is the contract between the system and its users: it defines “what’s allowed” so that the kernel can enforce it consistently, leaving no room for discretionary overrides.

### How do labels work in SELinux?

What are Type Enforcement, Role-Based Access Control, and Multi-Level Security in SELinux?
How can you check the status of SELinux on a system?
What are common SELinux management commands?
How do you set file contexts in SELinux?
What is an AppArmor profile?
How do you reload AppArmor profiles?
What is the concept of least privilege in MAC?
How do you troubleshoot SELinux issues?
What is the significance of audit logs in MAC systems?

In MAC, audit logs are _the primary observable_ of what the policy is actually doing—without them you cannot tell whether the system is enforcing or if something has slipped through.

### Can you explain the concept of capabilities in Linux security?

Capabilities are Linux’s answer to “split root into smaller, auditable pieces” – they allow daemons to perform privileged tasks without inheriting all of root’s powers.

### How to use semanage

semanage enforcing
