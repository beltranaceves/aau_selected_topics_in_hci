# **Lecture 02 — Networks & Location: Schematic Overview (with examples)**

This summary follows the same structure and style as the previous one, optimized for memorization.

***

# **1. Networks**

## **1.1 Core Concept**

Wireless communication requires that many transmitters share a limited radio spectrum without interfering. This requires *multiple access methods*. 

***

## **1.2 Multiplexing / Multiple Access Methods**

### **A. TDMA — Time Division Multiple Access**

*   Spectrum is shared by dividing time into slots. Only one device transmits in each slot.
*   Requires strict clock synchronization.
*   Dynamic variant: **CSMA/CA** (used in WiFi)
    *   Device listens before sending.
    *   Optional RTS/CTS solves the hidden node problem.
    *   Collision detection is almost impossible in wireless.    

**Example to remember:**  
Classic GSM (2G) uses TDMA: each user gets a time slot. WiFi uses CSMA/CA for dynamic access.

***

### **B. FDMA — Frequency Division Multiple Access**

*   Each transmission gets its own frequency band.
*   Receiver must switch between frequency slots.
*   Complex variant: **OFDMA** (used in LTE, WiFi 6, 5G) uses many small sub‑channels that do not interfere because they are orthogonal.    

**Example:**  
FM radio stations operate in different frequency bands → no interference.

***

### **C. CDMA — Code Division Multiple Access**

*   All devices use the same frequency band but encode signals using unique spreading codes.
*   Uses *spread spectrum*: wide bandwidth, lower risk of interference.
*   Two forms: FHSS (Bluetooth), DSSS (older WiFi).    

**Example:**  
UMTS (3G) uses CDMA to allow multiple users in the same bandwidth.

***

### **Comparison Diagram (conceptual)**

    TDMA: ┌A─┐ ┌B─┐ ┌C─┐ ┌A─┐ ... time
    FDMA: AAAAA  BBBBB  CCCCC ... frequencies
    CDMA: A+B+C mixed in same frequency, separated by codes

***

## **1.3 Wireless Standards (Overview)**

### **A. WPAN — Bluetooth**

*   Covers all OSI layers (very complex).
*   Works in 2.4 GHz ISM band with adaptive frequency hopping (FHSS).
*   Two incompatible variants:
    *   Classic (audio devices)
    *   BLE (sensors, wearables)
*   Many devices since 2011 support both.    

**Example:**  
Wireless keyboards use Classic Bluetooth; fitness trackers use BLE.

***

### **B. WLAN — WiFi (802.11 family)**

*   Also in 2.4 / 5 GHz ISM band → possible interference with Bluetooth.
*   Uses DSSS, OFDM, or OFDMA depending on version; newer ones include MIMO.
*   Typically star topology with Access Points; roaming supported.
*   WiFi Direct exists but is often unstable.    

**Example:**  
Home routers with multiple APs let smartphones roam between floors.

***

### **C. WWAN — Cellular Networks (2G → 5G)**

**2G GSM:** TDMA, \~200 kbit/s  
**3G UMTS:** CDMA, \~20 Mbit/s  
**4G LTE:** OFDMA, IP‑only, \~300 Mbit/s  
**5G:** faster LTE; supports IoT, microcells, campus networks, Car‑to‑Car.    

**Example:**  
5G in factories enables private campus networks replacing industrial WiFi.

***

# **2. Location**

## **2.1 Classes of Location Information**

Three conceptual types:

*   **Geographic** (latitude/longitude)
*   **Topological** (addresses)
*   **Cell‑based** (WLAN MAC/SSID, cellular tower ID)    

### Mapping between classes

*   Geocoding: address → coordinates
*   Reverse geocoding: coordinates → address
*   Cell ID mapping → requires large external database    

**Example:**  
Google Maps converting “Karl‑Haußknecht‑Str. 7” to precise coordinates.

***

## **2.2 Location Determination Methods**

### **A. Satellite-Based (GPS, GLONASS, Galileo, BeiDou)**

**Principle:**

*   Measures time of flight of signals → distance to satellites.
*   Triangulation using at least 4 satellites because receivers lack atomic clocks (TDOA method).    

**Facts:**

*   \~32 GPS satellites at \~20,000 km altitude.
*   Weak signal strength due to distance.
*   Needs line of sight; cold start takes minutes.
*   Galileo is the only civilian-controlled system.    

**Extensions:**

*   aGPS: downloads almanac via mobile network → faster fixes.
*   Differential GPS: uses stationary base stations to improve accuracy.    

**Example:**  
Smartphones fixing GPS faster when mobile data is enabled (assisted GPS).

***

### **B. WLAN-Based Location**

*   Measures visible WiFi access points (MAC + SSID).
*   Uses database lookup for known access point coordinates.
*   Accuracy: \~10 m.
*   Lower power than GPS.    

**Example:**  
Indoor apps deducing building position based on known office routers.

***

### **C. Cell Tower Location**

*   Uses IDs of surrounding cell towers.
*   Accuracy: \~100–1000 m depending on cell size.
*   No extra power consumption because device already monitors towers.    

**Example:**  
Emergency location in rural areas often falls back to cell tower triangulation.

***

### **D. Tradeoff**

Accuracy vs. battery consumption:

*   GPS: high accuracy, high power
*   WLAN: medium accuracy, medium power
*   Cell ID: low accuracy, lowest power    

***

## **2.3 Precision vs Accuracy**

*   Accuracy = closeness to true value (systematic error)
*   Precision = reproducibility (random error)    

**Example:**  
GPS drifting around the same wrong position: high precision, low accuracy.

***

## **2.4 Coordinate Systems**

*   Standard: WGS‑84
*   China uses GCJ‑02 (intentionally distorted) → mismatch between satellite images and map data    

**Example:**  
A location in mainland China appears shifted on map apps unless corrected.

***

## **2.5 Cell-Based Location Issues**

*   Most queries rely on Google’s location database (\~99%).
*   Raises privacy concerns (logging access).
*   Alternative DBs: Mozilla, OpenCellID (lower accuracy).
*   WLAN cells change frequently → DB becomes stale.    

**Example:**  
Moving a home router completely corrupts WiFi-based location accuracy until databases update.


