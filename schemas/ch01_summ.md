# 📘 **Big Issues in Mobile Information Systems — Exam Study Overview**

Below is a **structured, exam‑ready schematic** organized into the seven key issue areas. Each section includes:

*   **Core arguments** (what you must remember)
*   **Tradeoffs** (common exam theme!)
*   **Examples** (helps memorization)
*   **Mini diagrams** where appropriate

***

# 1️⃣ **Power**

### ⭐ Core Idea

Mobile devices have **strict energy limits** → power becomes a central design constraint.

### ⚖️ Key Tradeoffs

*   **Capacity ↔ Size/Weight** (bigger battery = heavier device)
*   **Energy consumption ↔ Functionality**
*   **Cloud offloading ↔ Network energy cost**

### 🔌 Biggest Energy Consumers (in order)

1.  **Display (+ backlight)**
2.  **GPS, camera**
3.  **Wireless modules** (4G/LTE > WiFi > Bluetooth)
4.  **Sensors** (IMU, touchscreen)

### 🔧 Energy‑Saving Approaches

*   Disable unused modules
*   Lower sensor polling rate
*   Move heavy computation to cloud

### 🧠 Examples

*   Screen-dimming on auto mode
*   Turning off GPS unless navigation is active
*   Offloading photo classification to cloud servers (but requires energy-expensive data transfer!)

***

# 2️⃣ **Storage**

### ⭐ Core Idea

Smartphones use **flash memory**, which is small, fast, low‑power, but limited.

### ⚖️ Tradeoffs

*   **Performance ↔ Power**
*   **Local storage ↔ Cloud storage**
*   **Capacity ↔ Price**

### 🔍 Flash vs Hard Disk (from slides)

*   Flash: higher density, lower power, lower capacity
*   HDD: cheaper per TB, higher power usage, larger capacity

### ☁️ Cloud Storage Impacts

*   Frees local space
*   Requires network access → **more bandwidth + more power consumption**

### 🧠 Example

*   Google Photos storing pictures in the cloud → saves space, but syncing drains battery.

***

# 3️⃣ **Wireless Communication**

### ⭐ Core Idea

Wireless is **unpredictable**: fluctuating throughput, interference, and variable RTT.

### ⚖️ Tradeoffs

*   **Bandwidth ↔ Energy consumption**
*   **Data rate needs (4K video) ↔ Real‑world network limits**

### 🚫 Physical Effects

*   Reflection
*   Refraction
*   Absorption
*   Diffraction
*   Interference & multipath effects

### 📡 Types of Wireless

*   **WLAN (WiFi)** – medium range, high speed
*   **WPAN (Bluetooth)** – short range, low speed
*   **WWAN (cell networks: 3G, 4G, 5G)** – long range
*   **Mesh networks** – peer-to-peer

### 🧠 Examples

*   Video call lag due to high RTT in poor 4G coverage
*   WiFi signal drops due to thick concrete walls → absorption
*   Bluetooth headphones glitch near microwaves (ISM band interference)

***

# 4️⃣ **I/O Capabilities**

### ⭐ Core Idea

Mobile devices have **limited, unique I/O methods** compared to desktop systems.

***

## **A. Touch Input**

### Issues

*   **No haptic feedback**
*   **Occlusion** (finger covers display)
*   **Precision** (“fat finger problem”)
*   **No hover state** → “Midas Touch Problem”

### 🧠 Example

*   Mis‑tapping small links in a browser → need bigger touch targets (Apple recommends \~44px).

***

## **B. Gestures**

### Issues

*   No standard gesture set
*   Discoverability is low
*   Cultural differences in "natural gestures"

### 🧠 Example

*   Swipe left = delete in some apps, archive in others.

***

## **C. Speech**

*   Mostly used in cars
*   Not widely adopted elsewhere due to social embarrassment or environment noise

### 🧠 Example

*   People rarely interact with Siri in public because of social norms.

***

## **D. Motion Sensors (Accelerometer, IMU)**

*   Detect relative motion, not absolute position
*   Need fusion with GPS or markers
*   Sensitive to magnetic interference

### 🧠 Example

*   Fitness apps using IMU to count steps, but miscounting in buses due to vibrations.

***

## **E. Camera / Vision**

*   Sensitive to lighting
*   Enables QR scanning, AR, SLAM

### 🧠 Example

*   AR apps fail outdoors under strong sunlight.

***

# 5️⃣ **Context Awareness**

### ⭐ Core Idea

Mobile devices operate in **dynamic, unpredictable contexts**, affecting usability.

***

## **A. Environmental Context**

*   Motion (walking vs. car)
*   Sound (library vs. concert)
*   Light (sunlight vs. dark theatre)

### 🧠 Example

*   Bright sunlight → user cannot see screen → need high‑contrast UI.

***

## **B. Geographic & Geometric Context**

*   Geographic (GPS, 3DOF)
*   Device orientation relative to user (6DOF)

### 🧠 Example

*   A map app rotates automatically using compass orientation.

***

## **C. Social Context**

*   What is acceptable where?
*   Privacy (shoulder surfing)

### 🧠 Example

*   Not appropriate to use voice assistant in a quiet church.

***

## **D. Activity Context**

*   User activity affects attention
*   Need seamless switching

### 🧠 Example

*   Walking + texting → lower accuracy → require larger UI buttons.

***

## **E. Context Recognition (Hard!)**

*   False positives/negatives reduce trust

### 🧠 Example

*   Phone misdetects a “meeting” and silently sends calls to voicemail.

***

# 6️⃣ **Security & Privacy**

### ⭐ Core Idea

Mobile devices store **highly sensitive personal data** and are always connected.

### 🚨 Threat Sources

*   Corporations (for ads)
*   Governments (for surveillance)
*   Hackers (for financial theft)

### ⚠️ Two Main Problems

1.  **Lack of universal encryption**
2.  **Heavy use of cloud services → trust in third parties**

### 🧠 Examples

*   WhatsApp encryption controversies (government demand for “key escrow”)
*   Lost phones often breakable via weak lock screens

***

# 7️⃣ **Sustainability**

### ⭐ Core Idea

Smartphones have **short life cycles (\~2 years)**, creating ecological impact.

### 🌍 Environmental Impact

*   \~85 kg CO₂ per phone (iPhone 12 / Pixel 5)
*   Similar to a flight from Berlin → Paris

### 🚫 Why phones are replaced early?

*   Lack of software updates (mainly Android)

### ✔️ Alternatives

*   EU Right‑to‑Repair regulations
*   FairPhone (modular design)
*   LineageOS community ROMs

### 🧠 Examples

*   Replacing a cracked screen on FairPhone is easy; on iPhone requires full teardown.

