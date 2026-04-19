-- ███████╗██████╗ ███████╗        ██╗███╗   ██╗████████╗███████╗ ██████╗ ██████╗  █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
-- ██╔════╝██╔══██╗██╔════╝        ██║████╗  ██║╚══██╔══╝██╔════╝██╔════╝ ██╔══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
-- █████╗  ██████╔╝███████╗        ██║██╔██╗ ██║   ██║   █████╗  ██║  ███╗██████╔╝███████║   ██║   ██║██║   ██║██╔██╗ ██║
-- ██╔══╝  ██╔══██╗╚════██║        ██║██║╚██╗██║   ██║   ██╔══╝  ██║   ██║██╔══██╗██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
-- ███████╗██║  ██║███████║███████╗██║██║ ╚████║   ██║   ███████╗╚██████╔╝██║  ██║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
-- ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
--        _   ____  
-- __   _/ | | ___| 
-- \ \ / / | |___ \ 
--  \ V /| |_ ___) |
--   \_/ |_(_)____/ 
-- ===============================================================================================================
-- CONFIGURATION FILE FOR ERS_INTEGRATION v1.5-- GAMEPLAY ENHANCEMENTS FOR "EMERGENCY RESPONSE SIMULATOR"

Config = Config or {}

-- Enable/Disable Features      = true/false

-- Ps-dispatch Alert Notifications -- (Server - Everybody can see)
-- Ps-dispatch Callout Notifications
Config.EnableCalloutOffer    = false  -- Callout offer
Config.EnableCalloutAccept   = true  -- Callout accept
Config.EnableCalloutArrive   = true  -- Callout arrival
Config.EnableCalloutComplete = true  -- Callout complete 

-- Ps-dispatch Traffic Notifications
Config.EnablePulloverNotify = true  -- Dispatch Pullover event
Config.EnablePulloverCode4  = true  -- Pullover Code-4
Config.EnablePursuitNotify  = true  -- Pursuit started

-- Enable/Diasble all Service Request and Service Arrival events regardless of the settings below.
-- Enables/Diasbles all options in "Ps-dispatch Service Arrival Notifications", and "Service Request Notifications".
Config.EnableServiceRequestandArrive = true

-- Ps-dispatch Service Arrival Notifications 
Config.EnableCoronerArrive      = true  -- Coroner request arrival
Config.EnableMechanicArrive     = true  -- Mechanic request arrival
Config.EnableTowArrive          = true  -- Tow request arrival
Config.EnableTaxiArrive         = true  -- Taxi request arrival
Config.EnableTransportArrive    = true  -- PD Transport request arrival
Config.EnableAnimalRescueArrive = true  -- Animal Rescue request arrival
Config.EnableAmbulanceArrive    = true  -- Ambulance request arrival
Config.EnableFireArrive         = true  -- Fire request arrival
Config.EnableRoadServiceArrive  = true  -- Road Service request arrival

-- Service Request Notifications -- (Client - Only you can see)
-- Display a notification to dispatch requesting services (Displays character name, callsign, service requested and location with postal. Uses qbcore.notify)
Config.EnableCoronerRequest      = true
Config.EnableMechanicRequest     = true
Config.EnableTowRequest          = true
Config.EnableTaxiRequest         = true
Config.EnableTransportRequest    = true
Config.EnableAnimalRescueRequest = true
Config.EnableAmbulanceRequest    = true
Config.EnableFireRequest         = true
Config.EnableRoadServiceRequest  = true

-- Location update notification to dispatch (qbcore.notify)
Config.EnableTrafficUpdate       = true -- Update to dispatch when initiating a traffic stop
Config.EnablePursuitUpdate       = true -- Update to dispatch when a pursuit is started
Config.EnableCallCompleteUpdate  = true -- Update to dispatch when call is complete
Config.EnableCallArriveUpdate    = true -- Update to dispatch when you arrive near call


-- Display Callout, Ped & Vehicle info in chat. 
-- This happens in callout events and and when you interact with peds or vehicles through ERS.
Config.ShowCallInChat    = true  -- Show 911 call (ERS calls display as incoming 911 calls)
Config.ShowCalloutInChat = true  -- Show callout info (Callout accept displayed as 911 call)
Config.ShowLicenseInChat = true  -- Show license check (when you interact with a ped)
Config.ShowPlateInChat   = true  -- Show plate check (when a vehicle is pulled over)

-- This determines which jobs ('QB' jobs not 'ERS') will receive dispatch notifications.
-- Ps-dispatch uses job types for certain jobs. `LEO` for police, bcso and sasp. `EMS` for ambulance.
-- If you are not receiving notifications, check your qb-core shared jobs file. If there is no `type` defined, add your job name here.
Config.Dispatch = {
    CallOffer       = { 'fire', 'tow', 'leo', 'ems', 'police', 'ambulance' }, -- Callout Offer
    CallAccept      = { 'fire', 'tow', 'leo', 'ems', 'police', 'ambulance' }, -- Callout Accepted
    CallArrive      = { 'fire', 'tow', 'leo', 'ems', 'police', 'ambulance' }, -- Callout Arrive
    CallComplete    = { 'fire', 'tow', 'leo', 'ems', 'police', 'ambulance' }, -- Callout Completed
    TrafficStop     = { 'leo', 'police' },                                    -- Traffic Stop
    ServiceRequest  = { 'fire', 'tow', 'leo', 'ems', 'police', 'ambulance' }, -- Service Request
    
}

-- Player Rewards ( CAUTION : MAY BE EXPLOITED )
Config.EnableBonusPayCallArrive   = true -- Bonus pay on arriving at a callout (may be exploited)
Config.EnableBonusPayCallComplete = true -- Bonus pay for completing a callout (this is triggered when all tasks in a callout are completed)
Config.EnableBonusPayTrafficStop  = true -- Bonus pay for initiating a traffic stop (may be exploited)
Config.BonusPayAmountCallArrive   = 2500 -- Callout Arrival bonus amount
Config.BonusPayAmountCallComplete = 5000 -- Callout Complete bonus amount
Config.BonusPayAmountTrafficStop  = 1000 -- Traffic stop bonus amount
Config.BonusPayDepositType        = bank  -- Deposit type (`bank`, `cash`)

-- Ps-dispatch Wait Times (in milliseconds - 10000 = 10 Seconds)(Time in between ERS dispatch events and ps-dispatch events)(Simulates reaction and response times)
-- This is the amount of time it takes for ps-dispatch to respond to the event.
-- Set to 0 (ZERO) for no delay
Config.WaitTimes = {
    CalloutOffer     = 1000, -- How long after ERS dispatch notify does Ps-dispatch notify
    CalloutAccepted  = 5000, -- How long after callout accept does dispatch notify
    CalloutArrived   = 10000, -- How long after you arrived at the callout should you notify dispatch
    CalloutCompleted = 6000,  -- How long after the callout is completed should you notify dispatch
    PulloverNotify   = 10000, -- How long after you initiate a traffic stop should you notify dispatch
    PulloverEnd      = 8000,  -- How long after you completed a traffic stop should you notify dispatch
    PursuitStart     = 5000,  -- How long after you initiate a pursuit should you notify dispatch
    RequestEvents    = 10000, -- How long after you request a service should dispatch notify you of their arrival
    Updates          = 1000, -- This is how long after the event that you notify dispatch
}

-- EXTRA FEATURES --

-- Play radio and phone animations for 'Ps-dispatch Alert Notifications' and 'QBCore:Notify' options.
-- Requires 'ox_lib'. Only way I could get it to work atm.
Config.EnableRadioAnim = true

-- Wraith radar auto plate lock (whether or not front plate reader auto locks on pullovers)
Config.EnableRadarLock = true 

-- Minimap fixed radar zoom. Removes vanilla GTA multi zoom minimap and remains in a higher FOV on foot and in vehicle.
Config.EnableRadarZoom = true

-- Disables and replaces default crosshair with a smaller more aethetically pleasing version.
-- Command /togglecrosshair - Enable/disable crosshair in game.
Config.EnableCrosshair = true

-- Enable persistent flashlight and weapon light when not in ADS. Light stays on until turned off.
Config.EnableFlashlightWhileMoving = true


