[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)


# ERS integration script for QB-core created to be used with 'Emergency Response Simulator' by [nightssoftware](https://store.nights-software.com/)



# Features

QBCore & QBox Integration
-Fully compatible with QBCore and QBox frameworks.

Radial Menu Support
-Includes radial menu functions for quick access to commands and actions. Players can easily trigger key functions without memorizing chat commands.
Players can request or cancel services while inside of a vehicle.

PS-Dispatch Integration
-Seamless integration with ps-dispatch for real-time notifications and dispatch events, allowing multiple players to attach to calls with ps-dispatch.
Persistent and Non-persistent dispatch notifications depending on call and completion state.

Custom Command Functions
-Supports basic command triggers, allowing server admins to extend functionality or bind actions to custom commands.

Dynamic Event Handling
-Listens for in-game events (pullover events, dispatch responses, on-scene arrivals) and interacts with your ERS systems accordingly.

Player Rewards
-Awards players with automatic bank payment bonus on completion of scene cleanup. Giving player incentive to clean-up their scenes.

## Installation
- Make a backup of your current resourses for security.
- Open the INSTALL ME Folder. Inside are your new ps-dispatch alerts and radial menu items. `Script will not work without these`.
- `These are not drag & drop. You must add them manually!`
- Go into your ps-dispatch resourse. Open the `config` file in the `shared` folder.
- Add the new `Alert blips` from `add.config.lua` under the `Config.Blips` section.
- Next head into your `client` folder and open `alerts` file. Scroll all the way to the bottom and paste the alerts from `add.alerts.lua` here.
- Open your qbx-radialmenu resourse. Go into the `config` folder and open the `client.lua`. Copy the items from `config.client` and paste them under `menu items` or `job items`.
- Drag and drop the ers_integration script in your resourse folder. Be sure it is started after ERS and Ps-dispatch.

## Known Bugs
- ps-dispatch blip error
- dispatch does not display callout info

## Dependencies
Qb-core or Qbox framework
Emergency Response Simulator    https://store.nights-software.com/category/ersgamemode
Ps-dispatch                     https://github.com/Project-Sloth/ps-dispatch
ox_lib                          https://github.com/overextended/ox_lib

## Optional
Wk-wars2x Radar                 https://github.com/WolfKnight98/wk_wars2x
ps-mdt                          https://github.com/Project-Sloth/ps-mdt


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





## 🧾 License

This project, **ERS Integration**, is licensed under the **MIT License**.  
Copyright © 2025 **DrSnyder**

You are free to use, modify, and distribute this software for personal or commercial use,  
as long as proper credit is given by keeping the license notice.
