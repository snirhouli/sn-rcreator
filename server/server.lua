QBCore = exports['qb-core']:GetCoreObject()

-- Admin permissions check
QBCore.Functions.CreateCallback('qb-robberycreator:server:checkAdmin', function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    cb(player.PlayerData.permissions.admin)
end)

-- Save robbery to DB
RegisterNetEvent('qb-robberycreator:server:saveRobbery', function(data)
    local src = source
    if not QBCore.Functions.HasPermission(src, Config.AdminPerms) then return end

    local robberyData = {
        name = data.name,
        type = data.type,
        cooldown = data.cooldown,
        rewards = json.encode(data.rewards),
        required = json.encode(data.required),
        alert = data.alert,
        position = json.encode(data.position),
        radius = data.radius,
        minigame = json.encode(data.minigame)
    }

    -- Save new or update existing
    if data.id then
        exports.oxmysql:update('UPDATE ?? SET ? WHERE id = ?', {Config.Database.tableName, robberyData, data.id}, function()
            TriggerClientEvent('qb-robberycreator:client:notify', src, 'Robbery updated successfully!', 'success')
        end)
    else
        exports.oxmysql:insert('INSERT INTO ?? SET ?', {Config.Database.tableName, robberyData}, function()
            TriggerClientEvent('qb-robberycreator:client:notify', src, 'Robbery created successfully!', 'success')
        end)
    end
end)

-- Delete robbery
RegisterNetEvent('qb-robberycreator:server:deleteRobbery', function(id)
    local src = source
    if not QBCore.Functions.HasPermission(src, Config.AdminPerms) then return end

    if Config.Database.deleteAfterDays then
        exports.oxmysql:update('UPDATE ?? SET deleted = ?, delete_at = DATE_ADD(NOW(), INTERVAL ? DAY) WHERE id = ?', 
            {Config.Database.tableName, 1, Config.Database.deleteAfterDays, id}, function()
                TriggerClientEvent('qb-robberycreator:client:notify', src, 'Robbery marked for deletion!', 'success')
            end)
    else
        exports.oxmysql:update('DELETE FROM ?? WHERE id = ?', {Config.Database.tableName, id}, function()
            TriggerClientEvent('qb-robberycreator:client:notify', src, 'Robbery deleted permanently!', 'success')
        end)
    end
end)

-- Get saved robberies
QBCore.Functions.CreateCallback('qb-robberycreator:server:getRobberies', function(source, cb)
    local src = source
    if not QBCore.Functions.HasPermission(src, Config.AdminPerms) then return cb({}) end

    exports.oxmysql:execute('SELECT * FROM ?? WHERE deleted = 0', {Config.Database.tableName}, function(result)
        local robberies = {}
        for _, v in pairs(result) do
            robberies[#robberies+1] = {
                id = v.id,
                name = v.name,
                type = v.type,
                cooldown = v.cooldown,
                rewards = json.decode(v.rewards),
                required = json.decode(v.required),
                alert = v.alert,
                position = json.decode(v.position),
                radius = v.radius,
                minigame = json.decode(v.minigame)
            }
        end
        cb(robberies)
    end)
end)

-- Add this function to server.lua
function TriggerQSDispatch(source, robberyData)
    if not Config.Dispatch.useQS then return end
    
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    local alertCode = Config.Dispatch.alertCodes[robberyData.type] or Config.Dispatch.defaultAlert
    
    exports['qs-dispatch']:CreateDispatchCall({
        job = 'police',
        coords = coords,
        message = string.format('%s Robbery in Progress', robberyData.name),
        code = alertCode,
        sprite = 487,
        color = 1,
        scale = 1.5,
        length = 3,
        radius = robberyData.radius * 20, -- Convert radius to a reasonable dispatch radius
    })
end

-- Modify the saveRobbery event to include dispatch
RegisterNetEvent('qb-robberycreator:server:saveRobbery', function(data)
    local src = source
    if not QBCore.Functions.HasPermission(src, Config.AdminPerms) then return end

    local robberyData = {
        name = data.name,
        type = data.type,
        cooldown = data.cooldown,
        rewards = json.encode(data.rewards),
        required = json.encode(data.required),
        alert = data.alert,
        position = json.encode(data.position),
        radius = data.radius,
        minigame = json.encode(data.minigame)
    }

    -- Save new or update existing
    if data.id then
        exports.oxmysql:update('UPDATE ?? SET ? WHERE id = ?', {Config.Database.tableName, robberyData, data.id}, function()
            TriggerClientEvent('qb-robberycreator:client:notify', src, 'Robbery updated successfully!', 'success')
        end)
    else
        exports.oxmysql:insert('INSERT INTO ?? SET ?', {Config.Database.tableName, robberyData}, function()
            TriggerClientEvent('qb-robberycreator:client:notify', src, 'Robbery created successfully!', 'success')
        end)
    end

    -- Trigger QS-Dispatch if configured
    if data.alert ~= 'none' and Config.Dispatch.useQS then
        TriggerQSDispatch(src, data)
    end
end)