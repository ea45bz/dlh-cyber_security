# IoT Smart Thermostat

## 1. Identify IoT-specific threats that don't typically apply to web applications


 1. **Physical tampering / side‑channel attacks** 
 A thief can open the device, hook into debug ports, or probe RAM to recover keys. Web servers are usually off‑site and not physically reachable. 
 
 2. **Weak/overlooked default credentials** 
 Many IoT devices ship with hard‑coded “admin/admin” accounts; attackers simply try them. Web apps typically enforce password policies during deployment. 
 
 3. **Unencrypted or weak local wireless links** 
 Home Wi‑Fi can be compromised (e.g., using WPA2‑PSK). In web hosting, traffic is usually tunneled over TLS; the device may still use raw UDP/TCP for telemetry. 

 4. **Firmware/bootloader vulnerabilities** 
 Compromising the firmware can give persistent root access or bypass security checks—something rarely exploitable in a stateless web service. 

 5. **Low‑power constraints leading to insufficient security** 
 Limited CPU/memory may preclude modern cryptographic libraries, making lightweight but weaker crypto schemes common – something rarely seen in full‑featured web stacks. 

---

## 2. What happens if an attacker gains physical access to the device? 

1. **Device opening / cable removal**  
   Goal: expose internal components (e.g., SPI flash, UART debug port).  

2. **Hardware manipulation**  
   - Replace micro‑controller with a custom board to inject malicious code or bypass authentication.  
   - Add a relay/logic analyzer to observe bus traffic and extract secrets in real time.

3. **Firmware extraction & reverse‑engineering**  
   - Recover original firmware image, find hard‑coded credentials, analyze vulnerabilities.

4. **Re‑flashing or tampering**  
   - Flash modified firmware that logs sensor data, disables security checks, or opens backdoors to the HVAC system.

5. **Debug interface exploitation**  
   - Use JTAG/SWD to read/write memory.  
   - Dump encrypted firmware, keys, or configuration files.


**Potential Impacts**

| Impact | Example |
|--------|---------|
| **Unauthorized control of heating/cooling** | Attacker can turn HVAC on/off, causing comfort loss or damage (freeze/overheat). |
| **Data theft / privacy breach** | Temperature logs may reveal occupancy patterns; credentials for home network exposed. |
| **Device compromise → network lateral movement** | The thermostat could become a pivot point to other IoT devices or the router. |
| **Denial of Service** | Disable OTA, block legitimate updates, force device into an insecure state. |

---

## 3. Design security controls for the OTA (Over-The-Air) update process. What are the essential security requirements?

| Requirement | What it is / How it’s implemented |
|-------------|-----------------------------------|
| **Secure Boot / Trusted Boot** | Device boots only signed firmware; public key embedded in ROM verifies signature before execution. Prevents booting tampered code. |
| **Code Signing & Integrity Verification** | OTA package must be signed with the vendor’s private key; the device validates using a cached public key. Detects tampering and ensures authenticity. |
| **Encrypted Transport (TLS 1.2/1.3)** | All update traffic is protected end‑to‑end; protects against MITM or packet sniffing on the local network. |
| **Rollback / Version Control** | Device refuses older firmware versions; keeps a whitelist of acceptable hashes and optionally an immutable audit log. Prevents downgrade attacks that reintroduce known vulnerabilities. |
