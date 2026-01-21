# **I/O on Mobile Devices — Schematic Overview**

This lecture addresses limitations of mobile I/O and the corresponding commercial and research‑based solutions.

***

# **1. Touch Input**

## **1.1 Core Problems**

*   No haptic feedback (unlike keyboards). 
*   Occlusion: finger/hand covers content. 
*   Low precision: finger touches multiple pixels. 
*   No hover state (Midas Touch Problem). 
*   Reachability issues in one‑hand use. 

***

## **1.2 Solutions: Haptic Feedback**

### **A. Physical Surface Modulation**

**Tactus “Phorm” overlay**

*   Transparent foil with fluid channels; bubbles raise to simulate keys.
*   Entire layout fixed; works only with single keyboard configuration. 

### **B. Electrovibration (“Tactile Touch Screen”)**

*   Modulates friction between finger and screen using electric charge.
*   Creates illusion of ridges/valleys.
*   Only single‑touch supported. 

***

## **1.3 Solutions: Reducing Occlusion**

### **A. Geometric Hand Model**

*   Predicts occluded zones; UI repositions pop‑ups.
*   Objects below/right of touch more likely to be missed. 

### **B. Back‑of‑Device Input (NanoTouch)**

*   Touch surface on device backside; shows “virtual finger” on screen.
*   Makes very small displays usable. 

***

## **1.4 Solutions: Improving Precision**

### **A. Perceived Input Point Model**

*   Touch perception depends on user and finger angle.
*   High‑resolution sensors can extract fingerprints to infer angle, improving accuracy. 

### **B. Offset Cursor / Handles**

*   Fixed offset between finger and target.
*   Used in Android text selection handles. 

### **C. “Shift” Dynamic Lens**

*   Magnified preview near target; used in iOS text selection. 

### **D. Data‑Driven Precision Maps (“100,000,000 Taps”)**

*   Collected millions of tap events to create per‑device offset maps.
*   Still context dependent. 

### **E. Text Entry**

*   Prediction crucial: traditional QWERTY + word prediction or  
    alternative layouts (Swype/Swiftkey, Minuum). 

***

## **1.5 Solutions: Hover State**

### **A. Lift‑Off Strategy**

*   Action triggered on finger release, not touch down.
*   Gives user time to adjust before committing.
*   Introduced in 1988, now widely used. 

### **B. Pre‑Touch Sensing**

*   Some capacitive screens detect hover, grip, force but usually filtered out.
*   Research demos show rich pre‑touch states. 

***

## **1.6 Solutions: Reachability**

*   One‑handed and reachability modes shrink UI (Android/iOS).
*   Still reduced precision due to thumb angle and limited grip stability. 

***

# **2. Motion I/O**

## **2.1 Motion as Input**

### **A. Device Motion — IMU Sensors**

IMU contains:

*   Accelerometer (3 axes): senses acceleration and gravity; cannot detect rotation around gravity axis. 
*   Magnetometer (3 axes): measures Earth’s field; distorted by metal/power lines. 
*   Gyroscope (3 axes): detects rotation; compensates magnetometer errors. 

Combined (sensor fusion):

*   Gives 3 DOF orientation; with GPS → 6 DOF pose.
*   High power use → accelerometer often low rate only. 

### **B. How MEMS Sensors Work**

*   Based on microscopic springs, weights, actuators on silicon.
*   Accelerometers: force on spring‑mounted mass.
*   Gyroscopes: Coriolis effect on vibrating elements.
*   Magnetometers: Hall effect voltage changes with magnetic field.    

### **C. Calibration**

*   Figure‑eight movement compensates magnetic offsets (“hard/soft iron”). 

### **D. Add‑On Motion Controllers**

*   External devices with IMU + buttons + Bluetooth (e.g., Daydream controller). 

### **E. Muscle‑Based Input (EMG)**

*   Myo armband reads muscle activity, infers gestures.
*   Enables hands‑free interaction. 

### **F. Free‑Air Gestures**

*   SixthSense, Imaginary Interfaces using body‑worn cameras. 

### **G. Deformation Input**

*   PaperPhone: bend gestures using flexible displays. 

### **H. Device Bumping**

*   Physical tapping signals intent to connect/exchange data.    

***

## **2.2 Motion as Output**

### **A. Vibration**

*   Usually binary but can encode direction using multiple vibration motors.
*   Used in shoes, belts, vests (“Shoe Me the Way”). 

### **B. Galvanic Vestibular Stimulation (GVS)**

*   Electrical stimulation of inner ear changes balance perception.
*   Possible navigation method; proposed for VR. 

### **C. Muscle‑Propelled Force Feedback**

*   Electrodes trigger involuntary muscle movement, simulating forces.
*   Issues: attachment, safety. 

### **D. Shape‑Changing (“Breathing Phone”)**

*   Device subtly alters shape/center of gravity to convey ambient info. 

***

# **3. Visual I/O**

## **3.1 Output: Displays**

### **A. LCD**

*   Needs constant backlight; poor sunlight readability.
*   Absorbs light; transflective LCDs exist but are rare/expensive. 

### **B. AMOLED**

*   Each pixel emits light; no backlight.
*   More efficient but limited maximum brightness; lifetime issues. 

### **C. E‑Ink**

*   Bistable: no power needed to maintain image.
*   High contrast, sunlight readable.
*   Too slow for video. 

***

## **3.2 Input: Camera**

### **A. Hardware**

*   CCD (high sensitivity), CMOS/APS (cheaper, rolling shutter).
*   Color via Bayer filter (double green pixels). 

### **B. Barcodes**

*   EAN: linear, \~15 chars.
*   QR: \~3 kB + error correction.
*   Simple vision problem, common in apps. 

### **C. OCR**

*   Complex due to fonts/lighting.
*   Used for indexing documents, translating text in AR. 

### **D. SLAM**

*   Builds 3D map and tracks device location simultaneously.
*   Used for AR, mapping, 3D scanning. 

### **E. Object Detection**

*   CNN-based; training offline, inference on device.
*   Needs optimization for mobile (e.g., TensorFlow Lite). 

### **F. Touch Projector**

*   Projects phone interaction onto large screen; combines display + touch.    

***

# **4. Other I/O Channels**

## **4.1 Biosensing**

*   Fingerprint, heart rate, skin conductivity.
*   Raises privacy concerns. 
*   Heart rate measurable with IR sensor or phone camera. 

## **4.2 Hand/Body Stance**

*   Requires skeleton models; computationally heavy.
*   Needs external sensors (Leap Motion) or CNNs. 

## **4.3 Grasp Detection**

*   On‑device sensors detect hand shape and context. 

## **4.4 Facial Expression Recognition**

*   Hard due to lighting, person variation.
*   Easier: mapping features to avatar (“Animoji”).
*   Usually CNN-based. 

## **4.5 Gaze/Eye Tracking**

*   Measures gaze direction, attention, pupil dilation.
*   Provides pointing device. 

## **4.6 Sound Input (non‑speech)**

*   Whistling, music recognition, etc.
*   Based on FFT audio fingerprinting. 

