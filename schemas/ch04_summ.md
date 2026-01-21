# **UbiComp & IoT — Schematic Overview (with memory‑friendly examples)**

***

# **1. Ubiquitous Computing (UbiComp)**

## **1.1 Definition & Vision**

*   Coined by Mark Weiser (1991): technologies become invisible, integrated into everyday life.  
    Examples: tabs (cm‑sized), pads (handheld), boards (large).  
    Vision is largely realized today. 

## **1.2 What’s Still Missing?**

*   Not only about having devices everywhere, but also *calm/ambient/pervasive* interaction.  
    Should require **no manual setup**, but current reality:  
    Even using two Bluetooth speakers simultaneously is hard → not yet Weiser’s vision. 

***

# **2. Internet of Things (IoT)**

## **2.1 Core Idea**

*   Overused marketing term; essentially means adding connectivity everywhere.  
    Similar to UbiComp but more focus on smart objects and sensor networks.  
    Examples: connected trash cans, fridges, lightbulbs, water meters; Industry 4.0. 

## **2.2 Goals & Motivations**

*   Official: automate tasks, improve efficiency, enable smarter logistics.
*   Unofficial: sell more wireless modules, collect consumer data.  
    Example: detailed power‑meter readings can reveal which movie a person is watching (usage pattern matching). 

***

# **3. Big Issues for UbiComp/IoT**

## **3.1 Power & Energy Supply**

*   Thousands of sensors cannot rely on replaceable batteries.
*   Energy harvesting is considered: sunlight, vibration, temperature differences, EM radiation.
*   Limitation: very low efficiency (tens of mW) and storage issues (nighttime). 

## **3.2 Interaction Complexity**

*   Users already struggle with synchronizing 2 devices; IoT setups involve 100+.
*   Need new paradigms for configuration & coordination. 

## **3.3 Privacy**

*   Bluetooth LE beacons broadcast publicly → tracking possible.
*   Often leak private data such as heart rate; MAC randomization inconsistently used.
*   Danger of stalking via devices like AirTags / FindMy tags. 

## **3.4 Security**

*   Phones get poor update support; IoT devices are worse.
*   Many devices remain unpatched, enabling botnets (DDoS attacks).  
    Example: Persirai IoT botnet. 

## **3.5 Standards**

*   Fragmentation: many vendor‑specific protocols (MQTT, ZigBee, HTTP…).
*   Partial harmonization attempts: IP as common layer; new “Matter” protocol.
*   Physical Web/URIBeacon: devices broadcast URLs → accessed via browser.  
    Problem: mapping each URL to the right function. 

***

# **4. UbiComp/IoT Technologies**

***

# **4.1 Wearables & Interaction**

## **Definition**

*   Body‑worn, hands‑free devices: smartwatches, fitness trackers, glasses, headphones.  
    Require new interaction methods (gestures, voice, no screen). 

## **Smartwatches**

*   Not new; revived due to smartphone‑companion role.
*   Hardware capabilities: up to 1 GHz quad‑core, 4 GB ROM, BTLE, sometimes WiFi.
*   Software: Android Wear, iOS ecosystem, Tizen etc.
*   Issues: battery life & size constraints.
*   Typical interactions: rough swipes, motion gestures, in‑air gestures.
*   Common scenarios: notifications, quick replies, tracking body state. 

***

# **4.2 Sensor & Mesh Networks**

## **4.2.1 Problems with Traditional Networks**

*   Star / tree topologies insufficient for low‑power, short‑range IoT sensors → too many hubs needed. 

## **4.2.2 Mesh Networks**

*   Devices act as both sensors and relays.
*   Multi‑hop forwarding; dynamic topology.
*   Methods:
    *   Flooding (simple, heavy traffic)
    *   On‑demand routing (AODV)
    *   Proactive routing (OLSR, B.A.T.M.A.N., used in Freifunk)
*   Used in ZigBee, BTLE 5.1, WiFi‑based community networks. 

## **4.2.3 LPWAN**

*   Long range (1–10 km), extremely low bandwidth (<50 kbit/s), ISM band.
*   Standards: LoRaWAN, Weightless, WiFi HaLow.
*   Use cases: smart meters, street lamps, slow‑changing sensors. 

***

# **4.3 Personal Area Networks (WPAN)**

## **4.3.1 Classic Bluetooth**

*   Originally for personal peripherals; complex setup, high power consumption. 

## **4.3.2 Bluetooth Low Energy (BLE)**

### Key Properties

*   Shares 2.4 GHz band and modulation with classic BT but has a much simpler stack.
*   Designed for sensors with months/years of battery life.
*   Max data rate: \~1 Mbit/s.
*   Roles:
    *   Central (connects, requests data)
    *   Peripheral (broadcasts/unicasts)
*   OS support: Android (central since 4.3, peripheral since 5.0), iOS since v5/6 depending on role. 

### Types of Devices

*   Beacons: broadcast UUID (iBeacon), possibly extra data.
*   Sensors: profiles for temperature, heart rate etc.
*   Bidirectional devices: mainly for configuration, not synchronous streams. 

### Power Considerations

*   Depends heavily on advertising interval.  
    Example: nRF51822 + CR2032 cell, 1‑second interval = \~1 year lifetime.
*   Modern SoCs allow aggressive per‑module power shutdown. 

### BLE Protocol Structure

*   GAP (advertising, discovery, connection).
*   GATT (services, characteristics, 16‑bit UUIDs; publish‑subscribe).
*   Advertisements: 31‑byte payload + optional 31‑byte request‑based extension. 

***

# **4.4 Near‑Field Communication (NFC)**

## **Basics**

*   Very low‑cost tags (\~0.10 €), many form factors (cards, stickers, implants).
*   Subclass of RFID; powered inductively by the reader.
*   Frequency: 13.56 MHz; speed \~400 kbit/s; typical range \~2 cm.
*   Storage: 137 bytes – 80 kB depending on tag type. 

## **Variants**

*   Simple storage (NDEF).
*   Crypto smart cards (Mifare).
*   Java cards.
*   Card emulation (phone acts as NFC card). 

## **Use Cases**

*   Contact sharing (posters, business cards).
*   Access control (university cards).
*   Payments (Apple Pay, contactless credit cards).
*   ePassports.
*   Device‑to‑device transfers (Android Beam).
*   Range extension possible with directional antenna → risk of unauthorized reading. 

## **Security**

*   Public tags should be write‑protected; otherwise can be overwritten with malicious URLs.
*   Security levels:
    *   Low‑level block keys (often brute‑forceable).
    *   High‑level crypto apps (SIM‑card‑like security). 

***

# **5. One‑Page Summary for Exams**

    UBICOMP
      - Weiser’s vision: tabs, pads, boards, invisible computing
      - Reality: devices exist, but interactions still not seamless

    IOT
      - Everywhere connectivity; smart objects & sensor networks
      - Goals: automation, efficiency, data collection
      - Risks: surveillance, unintended inference (e.g., power meter pattern analysis)

    BIG ISSUES
      - Power: energy harvesting limited, storage challenges
      - Interaction: configuring large device ecosystems is complex
      - Privacy: BLE broadcasts trackable, MAC often not randomized
      - Security: unpatched devices → botnets
      - Standards: fragmentation, Matter emerges, Physical Web tries URL-based access

    TECHNOLOGIES
      - Wearables: new interactions (gestures, voice)
      - Mesh networks: AODV, OLSR, ZigBee, BTLE 5.1
      - LPWAN: LoRaWAN, ultra-low bandwidth, long range
      - WPAN: BLE—low power, GAP/GATT, beacons, sensors
      - NFC: RFID-based, short range, many security pitfalls

***

If you want, I can now also prepare:

*   a printable cheat sheet,
*   a diagram/mind‑map of the UbiComp/IoT ecosystem, or
*   exam‑style practice questions.

