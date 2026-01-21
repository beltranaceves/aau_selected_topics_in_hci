# **1. Power in Mobile Systems**



*   Mobile devices face strict power limits due to size/weight constraints.
*   Most energy is consumed by: display/backlight, GPS, camera, wireless modules, and sensors.
*   Strategies: disable unused components, reduce polling frequency, offload heavy computation to cloud (with caution, since network transfer itself consumes power).
*   Primary tradeoff: battery capacity vs. portability.

***

# **2. Storage in Mobile Systems**



*   Smartphones rely on flash memory: high density, low power, limited capacity.
*   Outsourcing to cloud services compensates for limited local storage, but increases network dependency and power usage.
*   Flash vs HDD: Flash is far smaller and lower-power but has lower overall capacity and higher cost per TB.

***

# **3. Wireless Communication**



*   Wireless links are unpredictable: variable bandwidth, noise, interference, high RTT.
*   Physical effects: reflection, refraction, absorption, diffraction, multipath scattering.
*   Multiple access methods:
    *   TDMA (time slots), FDMA (frequency slots), CDMA (spread spectrum).
*   Wireless families:
    *   WLAN (WiFi, 802.11), WPAN (Bluetooth), WWAN (2G–5G).
*   ISM bands lead to interference across device classes.

***

# **4. Mobile I/O Constraints**

(Surfaces/touch, gestures, speech, motion, vision, biosensing)   

*   Touch limitations: no haptics, occlusion, low precision, no hover state, reachability issues.
*   Gestures: discoverability problems, cultural variation, no universal standards.
*   Speech input/output: limited adoption in everyday settings.
*   Motion input: accelerometer, gyroscope, magnetometer used for relative pose; requires sensor fusion.
*   Vision: lighting variability, heavy computation; supports QR scanning, OCR, SLAM, AR.
*   Other channels: biometrics, back‑of‑device input, location sensors.

***

# **5. Context Awareness**



*   Mobile context varies across environment (lighting, sound, motion), geometric (GPS, device orientation), social (privacy expectations), and activity context.
*   Context recognition is error‑prone: false positives/negatives harm user trust.
*   Context influences allowable interactions (e.g., silent mode in meetings).

***

# **6. Security & Privacy in Mobile Systems**



*   Devices store sensitive private data (contacts, messages, photos, codes).
*   Threat actors include corporations, governments, and hackers.
*   Issues:
    *   Lack of universal, pervasive encryption.
    *   Heavy reliance on cloud services.
    *   Lost phones may be trivial to access without strong device protection.

***

# **7. Sustainability**



*   Short device lifecycles (\~2 years) cause environmental burden (\~85 kg CO₂ per phone).
*   Reasons for short lifespan: lack of long-term software updates (especially on Android).
*   Solutions: modular phones (Fairphone), EU right-to-repair laws, community ROMs (LineageOS).

***

# **8. Networks & Location (Lecture 02)**



## **8.1 Multiplexing & Network Standards**

*   TDMA, FDMA/OFDMA, CDMA enable shared channel usage.
*   Bluetooth: complex stack, classic vs BLE (2.4 GHz, AFH).
*   WiFi: 802.11x family; high data rates, star topology.
*   Cellular: GSM (2G/TDMA), UMTS (3G/CDMA), LTE (4G/OFDMA), 5G expansions.

## **8.2 Location Classes**

*   Geographic (lat/long), topological (address), cell-based (SSID, cell tower ID).
*   Geocoding and reverse‑geocoding require large databases.

## **8.3 Location Methods**

*   GPS: accurate (\~1 m), slow, high‑power, requires line‑of‑sight.
*   WLAN-based: medium accuracy (\~10 m).
*   Cell-tower based: low accuracy (\~100–1000 m).
*   Tradeoff: accuracy vs power usage.
*   GPS enhancements: assisted GPS, differential GPS.

***

# **9. Mobile I/O Technologies in Depth (Lecture 03)**



*   Touch improvements: haptic overlays (Tactus), electrovibration, occlusion‑aware UIs, back‑of‑device input (NanoTouch), dynamic lens “Shift”, offset cursors, large datasets to calibrate tap offsets.
*   Motion sensing: IMUs (accelerometer, gyro, magnetometer), MEMS details, calibration techniques (figure‑eight magnetometer calibration), motion-based input (EMG bands, free-air gestures, bend gestures, bump interactions).
*   Motion output: vibration systems, wearable haptics (GVS, muscle‑propelled feedback), shape‑changing devices.
*   Vision: QR codes, OCR, SLAM, object detection via CNNs.
*   Other channels: gaze tracking, biosensors, sound FFT‑based recognition.

***

# **10. UbiComp & IoT (Lecture 04)**



*   Mark Weiser’s vision: technology integrated seamlessly into daily life.

*   IoT: connectivity added everywhere; often marketed excessively.

*   Goals: automation, efficiency, logistics optimization; hidden goal: more data collection.

*   Big issues:
    *   Power (scaling battery maintenance across thousands of sensors).
    *   Interaction complexity (managing massive device ecosystems).
    *   Privacy (BLE broadcasts reveal identity/location; tracking risks).
    *   Security (many IoT devices unpatched → botnets).
    *   Standards fragmentation (Matter emerging; Physical Web attempts).

*   Technologies: wearables, sensor networks, WPAN (BTLE), LPWAN (LoRaWAN).

*   NFC: tags powered inductively; used for access control, payments, data sharing; risks include malicious tag rewriting.

***

# **11. Mixed Reality (Lecture 05)**



*   Mixed reality spans the continuum from real → virtual.
*   AR definition: combines real and virtual; real‑time; spatially aligned; requires tracking + graphics.
*   Optical see‑through HMDs: direct view, natural focus, but poor occlusion and alignment issues.
*   Video see‑through HMDs: better alignment, but parallax and latency issues.
*   Mobile AR issues: 2D screen metaphor, lack of depth, parallax, tracking obstacles.
*   Tracking approaches:
    *   GPS + IMU
    *   Vision-based (markers, SIFT, SLAM)
    *   Depth/stereo cameras
*   Spatial AR: projection mapping on real surfaces; industrial use for assembly guidance.
*   Interaction: touchscreens, tracked tools, hand tracking.
*   Applications: advertising, military, education, maintenance, gaming, medicine.

***

# **12. ISS: Introduction (Lecture 07)**



*   ISS = Interactive Surfaces & Spaces
*   Surfaces: 2D + rotation; pen/stylus, tokens, blobs, multitouch.
*   Spaces: 6D pose tracking; tracked objects, controllers, hands, full-body.
*   Big Issues: infrastructure, fatigue, reachability.
*   Research domains: ACM ISS, TEI, VRST, IEEE VR.
*   Example systems: Reactable, SandScape, interactive ads, Virtual Valcamonica, SPLOM Wall, MR anatomy education.

***

# **13. ISS: Technologies (Lecture 08)**



## **13.1 Output**

*   Screens (LCD/OLED, projection), stereoscopic displays (autostereo, shutter, polarized).
*   HMDs for spatial interaction.
*   Active tangibles using light/sound/motion.
*   Directional sound zones.

## **13.2 Input**

*   Touch technologies: resistive, capacitive, projected capacitive, FTIR, DI, IR grids, laser rangefinders, in‑cell sensing.
*   Tangibles: passive optical markers, active inside‑out tracked tangibles.
*   Stylus input: pressure/angle/rotation; camera‑based pens.
*   Depth cameras:
    *   Stereo
    *   Structured light (speckle, stripe/Gray code)
    *   Time‑of‑Flight (phase measurement)
    *   Depth‑color alignment → point clouds.

## **13.3 6DoF Tracking**

*   Multi-camera systems with reflective markers or LEDs (Vicon, ART, HTC Lighthouse).
*   Pose estimated through ray intersection and marker geometry.

***

# **MASTER SUMMARY — Ultra-Condensed (One Page)**

    POWER: limited energy, displays and radios dominate usage; save by disabling modules and reducing polling.

    STORAGE: flash memory constrained; cloud adds dependency and power cost.

    WIRELESS: unpredictable, interference-prone; use TDMA/FDMA/CDMA; WLAN/WPAN/WWAN families.

    I/O: touch lacks precision/haptics; gestures undiscoverable; sensors for motion and vision; multimodal inputs.

    CONTEXT: environment, location, social, activity; automatic detection unreliable.

    SECURITY/PRIVACY: massive sensitive data; weak encryption ubiquity; cloud trust issues.

    SUSTAINABILITY: high CO2 footprint; short lifespans; repairability and modular designs needed.

    NETWORKS/LOCATION: multiplexing; standards (BT/WiFi/Cellular); GPS/WLAN/Cell-ID methods with accuracy vs power.

    MOBILE I/O: touch R&D (haptics, occlusion fixes); extensive sensor fusion; AR via SLAM and depth cameras.

    UBICOMP/IoT: pervasive devices; challenges in power, interaction, privacy, standards; BLE, LPWAN, NFC.

    MIXED REALITY: AR requires real-time alignment; HMDs optical vs video see-through; tracking via vision/GPS/IMU.

    ISS INTRO: surfaces (2D) vs spaces (6D); touch, tangibles, tracking; challenges: fatigue, reach.

    ISS TECH: HMDs, stereoscopic screens, optical touch, capacitive/resistive, depth cameras, 6DoF tracking.


