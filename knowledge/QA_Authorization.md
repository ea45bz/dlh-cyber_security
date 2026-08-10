## General Concepts

### What is the purpose of authentication in computer security

Authentication is the process of proving that an entity (user, device, or service) is who it claims to be.

### What is the purpose of authorization in access control systems

Authorization is what turns a verified identity into an active participant within the system while ensuring they only use the resources and capabilities that align with security policies.

### What are the fundamental differences between authentication and authorization

**Authentication asks “Who are you?”**, while **Authorization asks “What are you allowed to do?”** The two steps together enforce the principle of least privilege—only verified identities get access, and only the permissions they truly need.

### What is the correct sequence of authentication and authorization in security systems

**Authenticate → Establish identity → Authorize each requested action.**

## Authentication

### What are the three main authentication factors

**The three core authentication factors**

| #   | Category                                   | Description                                  | Common examples                                                         |
| --- | ------------------------------------------ | -------------------------------------------- | ----------------------------------------------------------------------- |
| 1   | **Knowledge factor** (something you know)  | A secret only the user should possess.       | Password, PIN, pass‑phrase, security‑question answer                    |
| 2   | **Possession factor** (something you have) | An object that the user physically controls. | Smart card, hardware token (YubiKey), OTP app on a phone, key‑card      |
| 3   | **Inherence factor** (something you are)   | A biometric trait unique to the user.        | Fingerprint scan, facial recognition, iris/retina scan, voice biometric |

### How does the authentication process work

** - User presents credentials**
** – Credential validation**
** – Account status checks**
**6 – Session/token creation**
**7 – Client stores token/session**

### What are the main authentication protocols

| Protocol                          | When you see it                                 |
| --------------------------------- | ----------------------------------------------- |
| **HTTP Basic / Digest**           | Legacy APIs, simple dev environments            |
| **Form‑based login (POST)**       | Web apps with username/password                 |
| **OAuth 2.0 / OpenID Connect**    | Third‑party logins, single sign‑on              |
| **SAML 2.0**                      | Enterprise SSO across domains                   |
| **Kerberos**                      | Windows domain authentication                   |
| **Certificate‑based auth (mTLS)** | API gateways, microservice secure communication |
| Radius , LDAP,                    |

---

### What is the difference between single-factor and multi-factor authentication

- 1 factor – usually a _knowledge_ credential (password, PIN).
- 2 or more factors – combination of <br>• Knowledge (something you know)<br>• Possession (something you have)<br>• Inherence (something you are)

### What HTTP status code indicates authentication failure

**401 Unauthorized**
**403 Forbidden**

## Authorization

### What are the main authorization models

DAC **Discretionary Access Control **
MAC **Mandatory Access Control**
RBAC**Role‑Based Access Control**
ABAC **Attribute‑Based Access Control **

### How does Role-Based Access Control (RBAC) work

**User → Role**: `assign(U, R)`
**Role → Permission**: `grant(R, P)`

### How does Attribute-Based Access Control (ABAC) differ from RBAC

More granular control = better alignment with need-to-know requirements.
User attributes: Department, clearance level, employment type
Resource attributes: Data classification (public, confidential, secret), ownership
Environmental attributes: Time of day, location, device security status

### What are the components of authorization

Principle of Least Privilege (PoLP)
Resource
Action / Operation

### What HTTP status code indicates authorization failure

**401 Unauthorized** – credentials missing or invalid (authentication problem).

- **403 Forbidden** – the user is authenticated but does not have permission to perform the requested action.
-

## Security Best Practices

### What are the advantages of implementing both authentication and authorization

Implementing **both authentication** (verifying who you are) and **authorization** (deciding what you can do) gives a layered, principle‑of‑least‑privilege security posture that protects against a wide range of attacks.

### What are the security risks of skipping authentication or authorization

Without authentication you expose the entire system to anyone on the network (or over the Internet).
Without authorization you give every authenticated user the same “key to everything,” turning an initially safe login into a catastrophic breach if anyone ever misuses it.

### How do authentication and authorization work together to protect systems

**Authenticate (prove identity)**
**Attach identity to every request**
**Authorize (evaluate permissions)**
**Enforce the decision**

Each principal’s actions are strictly limited by policies, ensuring least‑privilege.

### What is the difference between a username/password and biometric authentication

**Passwords** are cheap and widely supported but rely on secrecy; **biometrics** offer a stronger proof of identity because they’re tied to physical traits, yet they require dedicated hardware and careful privacy handling.
