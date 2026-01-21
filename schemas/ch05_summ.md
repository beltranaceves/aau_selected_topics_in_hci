# **Mixed Reality — Schematic Overview**

 

***

# **1. Mixed Reality & AR Basics**

## **1.1 Virtuality Continuum**

*   From purely real environments → purely virtual.
*   Augmented Reality (AR) lies within *mixed reality*, where virtual and real elements are combined. 

## **1.2 Definition of AR (Azuma, 1997)**

AR requires:

*   Combination of **real‑world view** + **virtual content**.
*   **Real‑time interactivity**.
*   **Spatial alignment in 3D** (virtual elements precisely located in real space).
*   Requires:
    *   real visual input, virtual output
    *   user input + fast graphics
    *   **6D head tracking** (3D position + 3D orientation).    

***

# **2. AR: History**

*   1901: Concept mentioned in novel *The Master Key*.
*   1968: First HMD, “Sword of Damocles” by Ivan Sutherland.
*   1980: First wearable HMD by Steve Mann.    

***

# **3. AR Hardware**

***

## **3.1 Optical See‑Through HMDs**

**Principle:**  
Beam combiners overlay virtual imagery onto direct real‑world view. 

**Pros**

*   Real world seen directly (no camera feed).
*   Eyes can focus at different distances naturally.

**Cons**

*   Cannot correctly occlude real objects.
*   Alignment issues between virtual & real noticeable.    

**Examples**

*   Microsoft Hololens
*   Magic Leap
*   Google Glass (but not fully AR)    

***

## **3.2 Video See‑Through HMDs**

**Principle:**  
Camera feed replaces direct view, virtual objects added to frames. 

**Pros**

*   Better alignment and tracking.
*   Can hide/substitute real objects.

**Cons**

*   Parallax errors (camera ≠ eye position).
*   Same issues as VR (motion sickness).
*   Only one focus distance.    

**Examples**

*   Meta Quest 3, Lenovo Mirage Solo
*   Smartphone VR goggles with passthrough    

***

## **3.3 General HMD Issues**

*   **Brightness** (outdoor use difficult).
*   **Field of view (FOV)**: human \~180°, many HMDs \~20°.
*   **Weight / comfort**.
*   **Lag** (real vs virtual, head motion vs image).
*   **Safety:** video see‑through failures can be dangerous.    

***

## **3.4 Cardboard‑Type Smartphone Goggles**

Weak for AR because:

*   Single camera → no stereo depth.
*   Usually no positional tracking (only rotation) → motion sickness.
*   Varied device quality.
*   Poor ergonomics.    

***

## **3.5 Heads‑Up Displays (HUDs)**

*   Mainly used in vehicles (speed, navigation).
*   Not spatially aligned to real environment.
*   Uses beam combiners and simple 2D overlays.    

***

# **4. AR Beyond Adding Objects**

## **Augmented *Diminished* Reality**

*   Removes or filters real‑world content.
*   Example: HDR welding goggles that suppress welding arc brightness.    

***

# **5. Mobile Devices as AR Displays**

*   “Window into the virtual world” metaphor.
*   No real 3D display (except smartphone VR hacks).
*   Major challenge: **accurate tracking & localization**.
*   Parallax issues when moving camera.    

***

# **6. AR Tracking & Localization**

Tracking must produce **stable 6D pose**.

***

## **6.1 GPS + IMU Tracking**

*   Combines 3D GPS position + IMU orientation.
*   Low accuracy indoors.
*   Works best at large scale (buildings, outdoor).
*   Used in: Pokémon Go, Layar, Wikitude.    

***

## **6.2 Vision‑Based Tracking**

### **Stereo/Depth Cameras**

*   Stereo: two cameras → triangulate depth.
*   Depth cameras: structured light or ToF sensors.
*   Require special hardware.    

### **Marker‑Based Tracking**

*   Fiducial markers or image targets.
*   Compute pose relative to known patterns.
*   SIFT: scale‑invariant keypoint detection & matching.    

### **SLAM (Simultaneous Localization And Mapping)**

*   Builds 3D map + camera pose, using only a single RGB camera.
*   Now feasible on phones (ARKit, ARCore).
*   Needs camera and IMU calibration, performs plane detection for object anchoring.    

***

# **7. Spatial AR / Projection Mapping**

## **7.1 Projector‑Based AR**

*   Project visuals directly onto physical surfaces.
*   Useful for buildings, industrial objects.
*   Challenges: brightness, power, focus distance.
*   Needs environment map + object tracking.    

## **7.2 Industrial Use (“Werklicht”)**

*   Projects assembly instructions onto workpieces.
*   Requires high brightness + laser projectors.
*   Workpiece geometry must be known.    

***

# **8. Interaction in AR**

*   Touchscreen (e.g., Touch Projector, AI Pin).
*   Tracked tools (controllers, gloves).
*   Optical hand tracking.    

***

# **9. AR Applications**

*   Advertisements (Ikea, fashion try‑ons).
*   Military (cockpits, targeting).
*   Education (e.g., iSkull).
*   Repair & maintenance guidance.
*   Gaming (Ingress, Pokémon Go).
*   Medical visualization (X‑ray overlays).
*   Navigation prototypes.    

***

# **10. Mobile Virtual Reality**

*   Meta Quest 1–3: fully mobile, inside‑out tracking with 4 IR cameras.
*   Enables room‑scale VR but requires large space and pre‑defined safety boundaries.
*   “Redirected walking” as locomotion research area.    
