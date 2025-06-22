-- Target integration for QB-Target
if Config.UseQBTarget then
    CreateThread(function()
        exports['qb-target']:AddGlobalObject({
            options = {
                {
                    type = "client",
                    event = Config.Command,
                    icon = "fas fa-user-secret",
                    label = "Robbery Creator",
                    canInteract = function(entity)
                        return IsPlayerAdmin() -- Or implement your own admin check
                    end
                }
            },
            distance = 2.0
        })
    end)
end

-- OR for OX Target
if Config.UseOXTarget then
    exports.ox_target:addGlobalObject({
        {
            name = 'qbRobberyCreator',
            event = Config.Command,
            icon = 'fa-solid fa-user-secret',
            label = 'Robbery Creator',
            distance = 2.0,
            canInteract = function(entity, distance, coords, name, bone)
                return IsPlayerAdmin() -- Or implement your own admin check
            end
        }
    })
end