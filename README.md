
# ERS integration script for QB-core created to be used with 'Emergency Response Simulator' by [nightssoftware](https://store.nights-software.com/)

Screenshots

https://r2.fivemanage.com/image/sLLMLJ8vLExb.png

https://r2.fivemanage.com/image/WhHjS5PSgHZm.png

https://r2.fivemanage.com/image/fdjumATvxYAN.png

https://r2.fivemanage.com/image/DVjxnTVIs5Rj.png

https://r2.fivemanage.com/image/75ioDK1cpXfI.png

https://r2.fivemanage.com/image/y5GNyAqhZFf6.png

https://r2.fivemanage.com/image/cRwF9KgJa2I7.png

https://r2.fivemanage.com/image/oNWm1TPnA70M.png

https://r2.fivemanage.com/image/286JJBy3VzJl.png

https://r2.fivemanage.com/image/Q3PMDltU27xy.jpg

https://r2.fivemanage.com/image/5UDpOC218Tez.png

https://r2.fivemanage.com/image/fSVssFYcHyxu.png

https://r2.fivemanage.com/image/9ZXHwtObGTsl.png

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

ERS Submenu (radialmenu)
- Duty Menu - Toggle police, ambulance, fire amd tow jobs specifically.
- Utility Menu - Request callouts, toggle callouts, wraith radar remote, open mdt, speedzone menu.
- Cancel Request Menu - Cancel service requests.
- ERS Services Menu - Request ambulance, tow, coroner etc.

PS-Dispatch Integration
- Ps-dispatch simulates a dispatcher on service requests and certain events notifying of arrivals and calls giving a bit more immersion for players.
- Persistent dispatch notifications for all players.
- Traffic stops, accepted callouts, callout arrivals and pursuits all trigger dispatch events with player location and data.
- Callouts appear in dispatch as 911 Calls with caller and call details
- Uses `Character Name`, `Callsign` and `Job` in dispatch
- Added `Tow` and `Fire` jobs to receive dispatch events (callouts and request events)

Duty Locations
- Go on/off duty for services at designated points using ox-target or qb-target.
- Add or remove duty locations in the `config.lua`.

Dispatch Chat Display (only happens on first interaction - enable/disable in config)
- Automatic notifications in chat for peds and ped vehicles
- Display vehicle plate info when you interact
- Display ped ID info when you interact
- Callout offers displayed as Incoming 911 calls

Inventory Item Support (qb_inventory and ox_inventory items)
- Use your ERS tools as items. 
- Currently supports the `Stretcher`, `Fire Hose`, `Broom`, `MDT`, and `Wraith Radar Remote`.
   - Stretcher    - uses same as /stretcher command
   - Fire Hose    - uses same as /hose command
   - Broom        - uses same as /broom command
   - MDT          - opens any MDT that uses /mdt
   - Wraith Radar - use your radar remote as item

Player Rewards
- Awards players with automatic bank payment bonus on completion of scene cleanup. Giving player incentive to clean-up their scenes.
- Adjust reward amount in `config.lua`.

Traffic Stops
- When used with Wk_wars2k radar the front plate will lock automatically. (enable/disable in config)
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
OR
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

# Update
- Included a drag and drop version for the ps-dispatch and radial menu configs so you dont have to copy and paste. Latest versions of both.
- Dispatch will display Last name and Callsign.
- Front plate will auto lock on a pullover.
- Added ability to open Speedzone menu in radial menu.
- Optimized script and fixed all errors
- Dispatch events with postals and information for service requests
- New config file for configurable duty points around the map using qb or ox target.
- Ability to change Dispatch event delays and callout complete bonus in config file.
- Use your ERS broom as a item
- Use your Radar remote as item
- Simplified and condensed the radial menu items for easier implementation

# Known Bugs
- Dispatch will display arrival event when the player requests a service even if the request is denied

# Download - Use this link for the latest release and features
https://github.com/DrSnyder86/ERS-Integration/tree/main


## Dependencies
- Qb-core or Qbox framework
- Emergency Response Simulator    https://store.nights-software.com/category/ersgamemode
- Ps-dispatch                     https://github.com/Project-Sloth/ps-dispatch
- ox_lib                          https://github.com/overextended/ox_lib
- qb-radialmenu                   https://github.com/qbcore-framework/qb-radialmenu
or
- qbx-radialmenu                  https://github.com/Qbox-project/qbx_radialmenu

## Recommended
- nearest-postal                  https://github.com/DevBlocky/nearest-postal
- Wk-wars2x Radar                 https://github.com/WolfKnight98/wk_wars2x
- ps-mdt                          https://github.com/Project-Sloth/ps-mdt






