# Healthcare Mobile App

## 1. Which asset is most critical in this system?

Viewing patential medical records is the most critical asset in the system.

 **Confidentiality:** 
   A healthcare app must ensure that patient medical records are only viewable by authorized medical staff, not other patients or unauthorized third parties. 
 **Integrity:** 
   Even a single altered entry can lead to misdiagnosis.  
 **Availability:** 
   If records are inaccessible (e.g., outage or DoS), care delivery stalls, potentially harming patients.

---

## 2. Apply STRIDE to the "message healthcare providers" feature

| Category | Threat Description |
|----------|--------------------|
| **Tampering (T)** | Malicious alteration of message contents in transit or at rest, e.g., changing medication instructions before reaching the provider. |
| **Spoofing (S)** | Attacker masquerades as a patient or provider to send false messages, potentially manipulating appointments or orders. |
| **Repudiation (R)** | Sender denies ever sending a message; without verifiable audit trail, accountability is lost, hindering dispute resolution. |
| **Information Disclosure (I)** | Unencrypted or improperly authorized messages are intercepted or accessed by third parties (e.g., eavesdropping on the network). |



## 3. What security controls would you prioritize to protect patient data? 

1. **Use encryption (TLS/SSL)**  
   Protects confidentiality and integrity while data moves between mobile client, API, a

2. **Authentication & Access Control**  
   Guarantees only legitimate patients/providers can access records or send messages; minimizes spoofing risk and enforces least‑privilege access.

3. **Database Encryption**  
   Safeguards data even if the database server is compromised

4. **Implement audit logging**  
   Enables detection, investigation, and non‑repudiation of all access or message events—essential for compliance 

5. **Input validation and sanitization**  
   Prevents injection attacks, protects against DoS, and reduces chances of tampering by ensuring only well‑formed data reaches the system.
