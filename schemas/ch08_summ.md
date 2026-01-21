# **ISS Technologies — Schematic Overview**

***

# **1. Output Technologies**

## **1.1 Head-Mounted Displays (HMDs)**

*   Used primarily for **interactive spaces** (3D interaction).
*   Details covered in Lecture 05.    

***

## **1.2 Screens**

Used for **interactive surfaces** (2D interaction).  
Types:

*   **LCD / OLED displays**
*   **Projection screens**    

***

## **1.3 Stereoscopic Screens**

### **Goal:** Deliver separate left-eye/right-eye images.

 

### **A. Autostereoscopic**

*   No glasses required.
*   Typically **single-user** due to narrow viewing zones.    

### **B. Shutter or Polarized Glasses**

*   Shutter: alternating images synced with LCD shutters.
*   Polarized: uses special projector/screen to separate light channels.    

***

## **1.4 Active Tangibles**

Tangible objects can function as **output devices**, using:

*   Sound
*   Light
*   Motion  
    Examples mentioned: Actibles, Tangible Bots.    

***

## **1.5 Sound Zones**

*   Steerable directional sound fields.
*   Raises question: does focused audio create an “interactive space”?    

***

# **2. Input Technologies**

***

# **2.1 Touch Technologies**

### **A. Resistive**

*   Cheap, low-end.
*   Two conductive layers separated by spacers.
*   Works with gloves, pens.
*   No multitouch.    

### **B. Capacitive**

*   Common in POS terminals.
*   Robust, simple.
*   Not glove-compatible unless special variants.    

**Projected capacitive:**

1.  **Mutual capacitance:** rows × columns measured together.
2.  **Self-capacitance:** each crossing measured individually.    

***

### **C. Optical Touch Technologies**

Optical sensing enables large surfaces and tangibles.

#### **1. FTIR (Frustrated Total Internal Reflection)**

*   IR LEDs + acrylic glass + camera/projector.
*   Touch disrupts internal reflection → bright spot captured by camera.    

#### **2. Diffuse Illumination (DI)**

*   IR illumination from behind or front; touches create contrast changes.    

#### **3. IR Grid**

*   IR emitters + sensors on opposing edges detect beam breaks.    

#### **4. Laser Rangefinders**

*   Allows very large touch surfaces.    

#### **5. In‑cell Sensing**

*   Light‑sensitive pixels built inside LCD panel.
*   Example: Samsung SUR40.
*   Can detect hands, fingers, tokens; sensitive to stray light.    

***

# **2.2 Tangible Input Technologies**

### **A. Optical Tangibles**

*   Passive markers: ReacTIVision, ArUco, ByteTag, etc.
*   Requires camera-based detection.    

### **B. Active Tangibles (Inside-Out Tracking)**

*   Tangible contains sensors and recognizes patterned surface below.
*   Does *not* require external camera.    

***

# **2.3 Pen/Stylus Input**

*   Many touch systems treat pens as enhanced fingertips.
*   Advanced pens (Apple Pencil, Wacom): transmit
    *   angle
    *   pressure
    *   rotation
*   Some legacy pens (Anoto, Tiptoi): camera reads microdot patterns on paper.    

***

# **2.4 Depth Cameras (DCs)**

## **2.4.1 What depth cameras measure**

*   Regular cameras: color per pixel.
*   Depth cameras: distance per pixel (often colorized).    

***

## **2.4.2 Geometry-based Depth Cameras**

### **A. Stereo Matching**

*   Two cameras → match corresponding pixels.
*   Compute depth via triangulation.
*   Used in Occipital Structure Sensor, Intel RealSense D4xx.    

### **B. Structured Light — Speckle Pattern**

*   IR projector emits known random dot pattern.
*   Compare observed vs. known pattern.
*   Example: Kinect v1.    

### **C. Structured Light — Stripe (Gray Code) Pattern**

*   Alternating encoded stripes projecting binary IDs onto surfaces.
*   Requires high frame rate or static scene.
*   Example: RealSense SR300 (\~300 FPS).    

***

## **2.4.3 Time-of-Flight (ToF) Depth Cameras**

**Principle:**

*   Emit IR flash → measure return delay.    

**Improvement:**

*   Instead of raw time, measure **phase shift** between emitted and received modulated signal → calculate distance.    

**Example:** Kinect v2.    

***

## **2.4.4 Depth–Color Alignment**

*   Must align depth pixels with RGB pixels.
*   Requires:
    *   **Intrinsic parameters**: FOV, distortion, focal length.
    *   **Extrinsic parameters**: translation + rotation between cameras.    

***

## **2.4.5 Point Clouds**

*   Each depth pixel → (x, y, z).
*   Optional RGB → (x, y, z, r, g, b).    

***

## **2.4.6 Depth Cameras for ISS**

*   Can ignore the surface entirely → detect objects directly in space.
*   No planar surface required.    

***

# **3. 6DoF Tracking Technologies**

## **3.1 Hardware Principles**

*   Uses ≥2 cameras + asymmetric markers.
*   Reflective markers: Vicon, ART.
*   LED beacons: Meta, HTC.
*   In HTC Vive: sensors are on the tracked object; light sources in room.    

***

## **3.2 Pose Calculation**

*   Rays from cameras intersect → determine 3D positions.
*   Distances between markers identify target & orientation.    


