# Exercise 06 - COVID-19 Contact Tracing Case Study
The main limitation of a system like this is that it requires excelent precision, accuracy and context identification. Crowded areas might still have people be isolated in rooms, vehicles, etc. Even if switching to a location system, Cell-based detection might detect a lot of people at the same place when in reality they are scattered on a kilometer wide radius.

## False Positives

- Through-Wall Detection
Two office workers work in adjacent rooms separated by a single wall. While they never directly interact, their phones continuously exchange Bluetooth messages through the wall. If one of them tests positive and uploads their contact messages, the other's phone will detect these messages and flag them as exposed despite never being in physical proximity or sharing the same air.

-False Positive from Crowded Traffic
People driving their cars through really congested roads might spend enough time stopped or
circulating at low enough speeds to sync with other vehicles for long enough to send Bluetooth
messages and trigger false contacts, since they never left their cars.


## False Negative Scenarios

- Out of Bluetooth Range
Two people sit at opposite ends of a café, about 15 meters apart. They're in the same room breathing the same air, but they're beyond the typical Bluetooth range (5-10 meters depending on phone power settings). Their phones never exchange messages. Later, when one of them tests positive, the other gets no warning, even though they were exposed to each other's air for an hour.

- Phone Turned Off During Exposure
Two people are taking the bus during rush hour after work. They're in close proximity for 15 minutes. However, the phone battery of one of them died an hour before (or battery saver mode kicked in and disabled BLE), so they've been riding without the contact tracing app running. When both of them need to check for contacts afterwards, the encounter has not been registered.

## Mitigation Strategy: 

### Context-Aware Encounter Rules via BLE Broadcasts

Owners and managers of physical spaces can deploy BLE beacon devices that broadcast a preset defining what constitutes a valid "encounter" in that location. When users enter a space, their phones receive the beacon broadcast and adjust their contact tracing rules accordingly.

For example:
- High ventilation, outdoor setting (outdoor markets) → Requires long period of strong RSSI signal to register an encounter
- Enclosed space, shared air (offices) → Requires a medium period of any signal to register.
- Maximum sensitivity (hospitals)→ Requires a very short period of any signal strength, since even brief exposure in a medical setting is significant.
- Isolated environment, no shared air (cars, your house, private offices) → Disables all Bluetooth-based encounter detection since users are in separate air spaces.

I did try to ask multiple LLMs this question, but most answers were completely unusable.