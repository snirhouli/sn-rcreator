-- Register command
RegisterCommand(Config.Command, function()
    QBCore.Functions.TriggerCallback('qb-robberycreator:server:checkAdmin', function(isAdmin)
        if isAdmin then
            TriggerEvent('qb-robberycreator:client:openMenu')
        else
            TriggerEvent('qb-robberycreator:client:notify', 'You don\'t have permission to use this.', 'error')
        end
    end)
end)

-- Register keybind if configured
if Config.Keybind then
    RegisterKeyMapping(Config.Command, 'Open Robbery Creator', 'keyboard', Config.Keybind)
end