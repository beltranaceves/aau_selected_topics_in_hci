# **Case Studies — Schematic Overview**

The lecture provides applied examples of mobile systems, IoT behavior, privacy/security challenges, and advanced mobile features.  
Each subsection highlights **core ideas**, **technical mechanisms**, and **memorization‑friendly examples**.

***

# **1. Amazon Dash Button**

## **1.1 Concept**

*   Very simple IoT device: single button → orders one product.    

## **1.2 Internal Components**

*   Microcontroller (reprogrammable)
*   PCB antenna
*   WiFi module
*   Button
*   Microphone (purpose unclear)
*   Non‑rechargeable battery    

## **1.3 Key Problem: Initial Configuration**

IoT setup dilemma → device needs WiFi credentials, but has no UI.    

### **Solutions**

1.  **Local hotspot (Android)**
    *   Dash opens temporary WiFi hotspot
    *   Phone configures it
    *   Dash joins target network    

2.  **Side‑channel configuration (iOS)**
    *   App sends WiFi data via **ultrasound**
    *   Dash decodes pattern → joins WiFi    

3.  **Other approaches**
    *   WiFi Layer‑2 misuse (“ProbMe”, mentioned only)    

***

# **2. Tweaks Without Root Access**

## **2.1 Netguard (User-Level Network Filter)**

*   Android blocks low‑level filtering without root.
*   Workaround: **VPN APIs** allow user‑level filtering.
*   Enables ad/tracker blocking.    

## **2.2 PixOff (AMOLED Saver)**

*   Turns off individual pixels → saves energy.
*   Works only on AMOLED (LCD has backlight so pixel off ≠ power off).
*   Provides multiple filter patterns.    

## **2.3 Re‑using Old Devices**

*   **Kiosk mode:** transform device into dedicated appliance (browser, music player).
*   **Surveillance:** use sensors (cam, mic, IMU).
*   Example: **Haven** app.    

## **2.4 Automation Tools**

*   MacroDroid, Automate.
*   Very powerful (nearly development environments).
*   Risk: flawed automation scripts may lock user out.    

***

# **3. COVID‑19 Contact Tracing Systems**

(Several slides are diagrams only; concepts must be inferred.)

## **3.1 Core Idea**

*   Mobile phones track proximity events
*   Without exposing identities    

## **3.2 Basic Principles (visuals from slides)**

*   Random identifiers exchanged via Bluetooth
*   Identifiers change frequently
*   If someone tests positive, identifiers uploaded
*   Other devices check locally for matches    

**Key Themes:** privacy, decentralized storage, matching on‑device, avoiding GPS tracking.

***

# **4. Apple AirTags & “Find My” Network**

## **4.1 Technical Basis**

Uses **Bluetooth Low Energy**, **NFC**, and **UWB** simultaneously.    

### **BLE workflow**

*   AirTag generates a **public–private keypair**.
*   AirTag broadcasts **public key** over BLE.
*   Nearby devices encrypt their location with this public key and upload it.
*   Owner’s phone uses private key to retrieve + decrypt location.    

### **UWB (iPhone 11+)**

*   Precise short‑range direction + distance.    

### **NFC**

*   Used for contact‑based identification, especially on Android.    

## **4.2 Issues**

*   **Privacy:** reasonably strong thanks to public‑key crypto.
*   **Major concern:** stalking & theft
    *   iPhones alert users of unknown AirTags moving with them.
    *   Android requires a dedicated app.    

***

# **5. Mobile Card Emulation**

## **5.1 Two Modes**

### **Host Card Emulation (HCE)**

*   Implemented in software
*   Less secure → malware may intercept communication    

### **Secure Element Mode (SEM)**

*   Uses dedicated hardware chip (often SIM or embedded SE).
*   Much more secure; used by Apple Pay.    

## **5.2 Issues in Ecosystem**

*   Google Pay previously limited by carriers protecting SIM secure element.
*   Coordination across website, issuer, certificate authority, browser, secure element, helper app makes debugging hard.    

## **5.3 Applications**

*   Mobile payments
*   Digital ID cards    

***

# **6. Computational Photography**

Modern smartphone cameras overcome physical sensor limits using software.

## **6.1 Examples**

### **Artificial Bokeh**

*   Simulated background blur even without large optical apertures.    

### **Night Sight (Pixel)**

*   Multiple images combined → long‑exposure‑like low‑light performance without tripod.    

## **6.2 Super‑Resolution / Super‑Zoom**

*   Capture burst (<1 s) of multiple slightly shifted images.
*   Merge to produce 2–3× higher resolution/zoom.
*   Takes advantage of:
    *   natural hand tremor
    *   IMU data
    *   Bayer pattern details    

**Challenges:** moving objects, noise, unpredictable motion.    

## **6.3 Over‑processing (“Hallucinated” Details)**

*   AI sometimes adds details that never existed.
*   Example: Samsung moon photos “too detailed”.    



