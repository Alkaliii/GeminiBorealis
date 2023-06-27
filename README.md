# GeminiBorealis (WIP)
![image](https://github.com/Alkaliii/GeminiBorealis/assets/53021785/7dfee5bf-2c30-4143-9ec6-79369cdd6166)

(GB) is a [SpaceTraders](spacetraders.io) 3rd party client made in [Godot Engine](godotengine.org). Thanks to its built-in automation and contextual UI, GB is perfect for managing small fleets (<20) or playing around in a single ship.

*I may be overselling it a bit*

## Features
*Base API*
- [ ] View Server Status and Leaderboards 
- [x] Register a New Agent 
- [x] Login with a Preexisting Token
- [ ] Manage your Contracts
   - [x] View Contracts
   - [x] Accept Contracts
   - [ ] Deliver and Fulfil Contracts
   - [ ] Negotiate New Contracts
- [x] View your Fleet
- [ ] Manage Ships within your Fleet
   - [ ] Manage Ship Inventory *(Transfer/Jettison/Extract/Refine)*
   - [x] Manage Ship Status *(Dock/Orbit/Refuel)*
   - [ ] Manage Ship Voyage *(Navigate/Jump/Warp/Flight Mode)*
   - [ ] Manage Ship Hardware *(Install/Remove Mounts)
- [ ] Explore the Universe
   - [ ] Scan, Survey, and/or Chart Locations
   - [x] View Systems and Waypoints
   - [ ] Use Jump Gates
- [ ] Game the Economy
   - [ ] View Markets and Shipyards
   - [x] Purchase and Sell Goods/Cargo
   - [x] Purchase Ships

*Gemini Indulgences*
- [ ] Groups and Group Actions
   - [ ] Nameable Groups
   - [ ] Navigate Group
   - [ ] Jump Group
   - [ ] Dock Group
   - [ ] Orbit Group
   - [ ] Top Up (Refuel) Group
   - [ ] Purge (Sell) Group Cargo
- [ ] Automation
   - [x] Purge Ship Cargo
   - [ ] Strip Waypoint (group)
   - [x] Auto Extract (group)
   - [ ] Auto Explore (group)
- [x] Quickly Login to Previously Used Tokens
- [ ] Nameable Ships

# Quickstart Guide
Enter a pre-existing token or press register in the bottom right to create a new token. Please be aware it will be saved locally to your machine immediately upon login. You can remove tokens from the save file but can't prevent them from being auto-saved on usage. Once on the map screen, you can:

* Move around the map by holding [SHIFT] and pressing one of the arrow keys.
* Press [SHIFT] & [TAB] to return the screen to default.
* You can use [SHIFT] & [=/+] to zoom in and [SHIFT] & [-/_] to zoom out (or [CTRL] & [SHIFT] & [ARROW UP/DOWN]).
* Use [SHIFT] & [A] to select waypoints quickly, and [SHIFT] & [Z] to chart a line between a previously selected location and a hovered one.

## System Screen
![image](https://github.com/Alkaliii/GeminiBorealis/assets/53021785/5138859d-e22b-48a8-a632-3b8fad7bc6c8)

On the System Screen, you can click options at the bottom to focus them. Some provide more options you can click on when a ship is at the location.
The top left provides a focus map button which will remove information from the map and recenter it. It also features a chart button which replicates [SHIFT] & [Z].

### Universe Screen
![image](https://github.com/Alkaliii/GeminiBorealis/assets/53021785/24578880-8b2f-48a1-b1b1-d48421d9d86e)

By opening a JUMP_GATE, you can access the Universe Screen, it will require a bit of loading the first time around but afterwards should be much faster. You can click on the textbox to enter commands such as `@focus ZERO`, `@bookmark IDK`, or `help` to do things. You can also drag the map around by clicking. currently [SHIFT] & [TAB], [SHIFT] & [A], [SHIFT] & [Z] are not available but the rest of the navigation shortcuts are functional. Additionally, you can press [B] to bring up the bookmark menu. Once you're done looking at the stars you can use `@exit` to return to the system screen.

## Ships Screen
![image](https://github.com/Alkaliii/GeminiBorealis/assets/53021785/4f02cf64-59f5-4fb0-b19d-770d33736a58)

On the Ships Screen, you can click the options at the bottom to focus on a ship. The black box beside the checkmark can be clicked to reveal possible actions (not all of them work currently). When a ship is docked you can assign them to a group doing so will reveal the Group Overlay. At the moment it is very buggy and might need to be restarted (set routine to stop, then set routine to start).

### Group Overlay
![image](https://github.com/Alkaliii/GeminiBorealis/assets/53021785/ddab51e2-ade9-4a4d-aff5-fb123bd80b8c)

Press [CTRL] & [G] to open the Group Overlay. Here you can manage groups and assign tasks. It's still pretty buggy.

## Agent Screen
Doesn't do much...
