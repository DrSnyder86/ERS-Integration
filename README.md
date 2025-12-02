
# ERS integration script for QB-core created to be used with 'Emergency Response Simulator' by [nightssoftware](https://store.nights-software.com/)

Screenshots

<div class="slideshow-container">
https://r2.fivemanage.com/image/wDPMJQBfuG5D.png
   
https://r2.fivemanage.com/image/ZwJqks3kjwuq.png

https://r2.fivemanage.com/image/z752VMUMlrtR.png

https://r2.fivemanage.com/image/QMMW4wpxlADj.png

https://r2.fivemanage.com/image/aAbsN9yUfpy4.png

https://r2.fivemanage.com/image/RV1KmWlwlwFH.png

https://r2.fivemanage.com/image/P5BWm1F9g9xP.png

https://r2.fivemanage.com/image/7MPsQ37En2oE.png

https://r2.fivemanage.com/image/LBqHlcZ3Tkyv.png

https://r2.fivemanage.com/image/W4mzQipRcAS5.png

https://r2.fivemanage.com/image/1qierHolZa8R.png

https://r2.fivemanage.com/image/WrJ0Nzh0mL4W.png
</div>

Demo

https://www.youtube.com/watch?v=hOujbqjlBBQ

# Features

QBCore & QBox Integration
- Fully compatible with QBCore and QBox frameworks.

Qbx-radialmenu and Qb-radialmenu Support
- Includes radial menu functions for quick access to commands and actions. 
- Players can easily trigger key functions without memorizing chat commands.
- Players can request or cancel services while inside of a vehicle. 
- Radial menu functions used to trigger dispatch response events.

ERS Submenu (qb/qbx-radialmenu)
- Duty Menu - Toggle police, ambulance, fire amd tow jobs specifically.
- Utility Menu - Request callouts, toggle callouts, wraith radar remote, open mdt, speedzone menu.
- Cancel Request Menu - Cancel service requests.
- ERS Services Menu - Request ambulance, tow, coroner etc.
- Pursuit Backup Menu - Request pursuit backup

PS-Dispatch Integration
- Ps-dispatch simulates a dispatcher on service requests and certain events notifying of arrivals and calls giving a bit more immersion for players.
- Persistent dispatch notifications for all players.
- Traffic stops, accepted callouts, callout arrivals and pursuits all trigger dispatch events with player location and data.
- Callouts appear in dispatch as 911 Calls with caller and call details
- Uses Player details `Character Name`, `Callsign` and `Job` in dispatch events
- Added `Tow` and `Fire` jobs to receive dispatch events (callouts and request events)

QB-target/Ox-target Support
- Go on/off duty for services at configurable points using ox-target or qb-target.
- Request `Tow` or `Mechanic` when targeting a vehicle while on duty.
- Request `Ambulance` and `Coroner` when targeting a downed ped while on duty.
- Add or remove duty locations in the `config.lua`.

Dispatch Chat Display (only happens on first interaction - enable/disable in config)
- Automatic notifications in chat for peds and ped vehicles
- Display vehicle plate info when you interact
- Display ped ID info when you interact
- Callout offers displayed as Incoming 911 calls

Inventory Item Support (qb_inventory and ox_inventory items)
- Use your ERS tools as items. 
- Currently supports the `Stretcher`, `Fire Hose`, `Broom`, `MDT`, and `Wraith Radar Remote`.
   - Stretcher    - uses same as `stretcher` command
   - Fire Hose    - uses same as `hose` command
   - Broom        - uses same as `broom` command
   - MDT          - opens any MDT that uses `mdt` command
   - Wraith Radar - use your radar remote as item

Player Rewards
- Awards players with automatic bank payment bonus on completion of scene cleanup. Giving player incentive to clean-up their scenes.
- Adjust reward amount in `config.lua`.

Traffic Stops
- When used with `Wk_wars2x` radar the front plate will lock automatically. (enable/disable in config)
- Sends dispatch alert when a stop is initiated.

Postal
- Nearest postal is now displayed in dispatch request and arrival events.

# Installation
## MANUAL-INSTALL
- Make a backup of your current resourses for security.
- Open the `INSTALL ME` Folder. Inside are your new ps-dispatch alerts and radial menu items. `Script will not work without these`.
- `These are not drag & drop. You must add them manually!`
### Ps-dispatch
- Go into your ps-dispatch resourse. Open the `config.lua` file in the `shared` folder.
   - ps-dispatch/shared/config.lua
- Add the new `Alert blips` from `add.config.lua` under the `Config.Blips` section.
### Radialmenu
- Open your qbx-radialmenu resourse. Go into the `config` folder and open the `client.lua`. Copy the items from `config.client` and paste them under `menuitems` or `jobitems`.
   - qbx-radialmenu/config/client.lua
OR
- Open your qb-radialmenu resourse. Open the `config.lua`. Copy the items from `config.client` and paste them under `Config.MenuItems` or `Config.JobInteractions`.
   - qb-radialmenu/config.lua

- Drag and drop the `ers_integration` script in your resourse folder.

## REPLACE-INSTALL
- Make a backup as usual
### Ps-dispatch
- Replace the following in `ps-dispatch` with the files provoded in the  `REPLACE-INSTALL` Folder.
   - ps-dispatch/shared/config.lua

### Radialmenu

- Next replace the following in `qbx-radialmenu`.
   - qbx-radialmenu/config/client.lua
- OR
- Replace in `qb-radialmenu`.
   - qb-radialmenu/config.lua

- Drag and drop the `ers_integration` script in your resourse folder.

# Configuration `config.lua`
- Change and add target duty locations for jobs in config file
- Dispatch response and delay times (ps-dispatch events)
- Bonus bank money reward amount
- Enable/Disable specific dispatch notification options

## Inventory Items (optional)
- Item tables and images located in `INSTALL ME/Optional Items/items.lua`.
- Supports `qb` and `ox` inventories.

## UPDATE
- Removed ox_lib as dependency
# Known Bugs
- Dispatch will display arrival event when the player requests a service even if the request is denied

# Download - Use this link for the latest release and features
https://github.com/DrSnyder86/ERS-Integration/tree/main


## Dependencies
- Qb-core or Qbox framework
- Emergency Response Simulator    https://store.nights-software.com/category/ersgamemode
- Ps-dispatch                     https://github.com/Project-Sloth/ps-dispatch
- qb-radialmenu                   https://github.com/qbcore-framework/qb-radialmenu
- OR
- qbx-radialmenu                  https://github.com/Qbox-project/qbx_radialmenu

## Recommended
- nearest-postal                  https://github.com/DevBlocky/nearest-postal
- Wk-wars2x Radar                 https://github.com/WolfKnight98/wk_wars2x
- ps-mdt                          https://github.com/Project-Sloth/ps-mdt

### License
For an updated license, check the ``License`` file. That file will always overrule anything mentioned in the ``readme.md``

ers_integration - DrSnyder

Copyright © 2025 DrSnyder. All rights reserved.

You can use and edit this code to your liking as long as you don't ever claim it to be your own code and always provide proper credit. You're not allowed to sell ers_integration or any code you take from it. If you want to release your own version of qb_ers_integration, you have to link the original GitHub repo, or release it via a Forked repo.

         ██████╗ ██████╗ ███████╗███╗   ██╗██╗   ██╗██████╗ ███████╗██████╗ 
         ██╔══██╗██╔══██╗██╔════╝████╗  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗
         ██║  ██║██████╔╝███████╗██╔██╗ ██║ ╚████╔╝ ██║  ██║█████╗  ██████╔╝
         ██║  ██║██╔══██╗╚════██║██║╚██╗██║  ╚██╔╝  ██║  ██║██╔══╝  ██╔══██╗
         ██████╔╝██║  ██║███████║██║ ╚████║   ██║   ██████╔╝███████╗██║  ██║
         ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝





