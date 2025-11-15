
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
- Radial menu functions used to trigger dispatch request response events.
`ERS Menu`
- `Duty Menu - Toggle police, ambulance, fire amd tow jobs specifically.`
- `Utility Menu - Request callouts, toggle callouts, wraith radar remote, open mdt, speedzone menu.`
- `Cancel Request Menu - Cancel service requests.`
- `ERS Services Menu - Request ambulance, tow, coroner etc.`
- `State Dispatch Menu - Activate specific ps-dispatch events. Traffic stop, 10-99, Code-4, En-route.`

Duty Locations
- Go on/off duty for services at designated points around the map using ox-target or qb-target.
- Add or remove duty locations in the `config.lua`.

Inventory Item Support
- Add usable items to your Qb or Qbox inventory. 
- Currently supports the `Broom`, `MDT`, and `Wraith Radar Remote`.

PS-Dispatch Integration
- Ps-dispatch simulates a dispatcher on service requests and certain events notifying of arrivals and calls giving a bit more immersion for players.
- Integration with ps-dispatch for dispatch notifications and events.
- Persistent and Non-persistent dispatch notifications depending on call and completion state.
- Traffic stops, accepted callouts, callout arrivals and pursuits all trigger an automatic dispatch event with player location and data.

Custom Command Functions
- Supports basic command triggers, allowing server admins to extend functionality or bind actions to custom commands.

Dynamic Event Handling
- Listens for in-game events (pullover events, dispatch responses, on-scene arrivals) and interacts with your ERS systems accordingly.
- Delays are intentional in dispatch events to give some more immersion.

Player Rewards
- Awards players with automatic bank payment bonus on completion of scene cleanup. Giving player incentive to clean-up their scenes.
- Adjust reward amount in `config.lua`.

Traffic Stops
- When used with Wk_wars2k radar the front plate will lock automatically.
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
- Next head into your `client` folder and open `alerts.lua` file. Scroll all the way to the bottom and paste the alerts from `add.alerts.lua` here.
   - ps-dispatch/client/alerts.lua
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
   - ps-dispatch/client/alerts.lua
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

# Known Bugs
- Dispatch will display arrival event when the player requests a service even if the request is denied

# Download - Use this link for the latest release and features
https://github.com/DrSnyder86/ERS-Integration/tree/main


## Dependencies
- Qb-core or Qbox framework
- Emergency Response Simulator    https://store.nights-software.com/category/ersgamemode
- Ps-dispatch                     https://github.com/Project-Sloth/ps-dispatch
- ox_lib                          https://github.com/overextended/ox_lib
- nearest-postal                  https://github.com/DevBlocky/nearest-postal

- qb-radialmenu                   https://github.com/qbcore-framework/qb-radialmenu
or
- qbx-radialmenu                  https://github.com/Qbox-project/qbx_radialmenu

## Optional
- Wk-wars2x Radar                 https://github.com/WolfKnight98/wk_wars2x
- ps-mdt                          https://github.com/Project-Sloth/ps-mdt


## Events
| Event                        | Description                                                      
| ---------------------------- | ---------------------------------------------------------------- 
| `mdt:toggle`                 | Alternative MDT toggle event — triggers the same `/mdt` command.  
| `callout:request`            | Requests a new callout using `/requestcallout`.                  
| `shift:toggle`               | Toggles the player’s duty shift status via `/toggleshift`.       
| `callouts:toggle`            | Enables or disables active callouts via `/togglecallouts`.       
| `escort:toggle`              | Toggles player escort mode with `/escort`.                       
| `call:coroner`               | Requests a coroner unit (`/requestcoroner`).                     
| `call:mechanic`              | Requests a mechanic (`/requestmechanic`).                             
| `call:tow`                   | Requests a tow truck (`/requesttow`).                                 
| `call:taxi`                  | Requests a taxi (`/requesttaxi`).                                     
| `call:police`                | Requests police backup (`/requestpolice`).                            
| `call:animalrescue`          | Requests animal rescue services (`/requestanimalrescue`).             
| `call:ambulance`             | Requests an ambulance (`/requestambulance`).                          
| `call:roadservice`           | Requests road service or roadside assistance (`/requestroadservice`). 
| `custom:requestfire`         | Requests fire department support (`/requestfire`).                    
| `call:cancelambulance`       | Cancels a pending ambulance request.     
| `call:cancelfire`            | Cancels a pending fire unit request.     
| `call:cancelpolice`          | Cancels a pending police request.        
| `call:canceltaxi`            | Cancels a pending taxi request.          
| `call:canceltow`             | Cancels a pending tow request.           
| `call:cancelmechanic`        | Cancels a pending mechanic request.      
| `call:cancelcoroner`         | Cancels a pending coroner request.       
| `call:cancelanimalrescue`    | Cancels a pending animal rescue request. 
| `call:cancelroadservice`     | Cancels a pending road service request.  




