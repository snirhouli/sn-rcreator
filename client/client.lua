local isMenuOpen = false
local currentPosition = nil

-- Open/close menu functions
function OpenRobberyCreator()
    SendNUIMessage({action = 'open'})
    SetNuiFocus(true, true)
    isMenuOpen = true
end

function CloseRobberyCreator()
    SendNUIMessage({action = 'close'})
    SetNuiFocus(false, false)
    isMenuOpen = false
end

-- Grab player position
function GetPlayerPosition()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    currentPosition = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        h = heading
    }
    
    return currentPosition
end

-- NUI Callbacks
RegisterNUICallback('close', function(_, cb)
    CloseRobberyCreator()
    cb({})
end)

RegisterNUICallback('getPlayerPosition', function(_, cb)
    local pos = GetPlayerPosition()
    cb({success = true, position = pos})
end)

RegisterNUICallback('saveRobbery', function(data, cb)
    TriggerServerEvent('qb-robberycreator:server:saveRobbery', data)
    cb({})
end)

RegisterNUICallback('deleteRobbery', function(data, cb)
    TriggerServerEvent('qb-robberycreator:server:deleteRobbery', data.id)
    cb({})
end)

RegisterNUICallback('getSavedRobberies', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-robberycreator:server:getRobberies', function(robberies)
        cb({robberies = robberies})
    end)
end)

-- Events
RegisterNetEvent('qb-robberycreator:client:openMenu', function()
    OpenRobberyCreator()
end)

RegisterNetEvent('qb-robberycreator:client:notify', function(message, type)
    if Config.Notify == 'qb' then
        QBCore.Functions.Notify(message, type)
    else
        -- Add other notification systems here
    end
end)

-- Add this function to client.lua
function TriggerRobberyAlert(robberyData)
    if not Config.Dispatch.useQS then return end
    
    local alertCode = Config.Dispatch.alertCodes[robberyData.type] or Config.Dispatch.defaultAlert
    
    exports['qs-dispatch']:CreateDispatchCall({
        job = 'police',
        coords = GetEntityCoords(PlayerPedId()),
        message = string.format('%s Robbery in Progress', robberyData.name),
        code = alertCode,
        sprite = 487,
        color = 1,
        scale = 1.5,
        length = 3,
        radius = robberyData.radius * 20,
    })
end

-- Modify the robbery start event in your actual robbery script
RegisterNetEvent('qb-robberies:client:startRobbery', function(robberyData)
    -- Your existing robbery logic here
    
    -- Trigger dispatch alert if configured
    if robberyData.alert ~= 'none' and Config.Dispatch.useQS then
        TriggerRobberyAlert(robberyData)
    end
end)