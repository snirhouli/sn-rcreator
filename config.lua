Config = {}

Config.AdminPerms = 'admin' -- QB-Core permission required to use the creator
Config.Command = 'robberycreator' -- Command to open the menu
Config.Keybind = 'F7' -- Keybind to open the menu (false to disable keybind)

-- Target integration (choose one)
Config.UseQBTarget = true
Config.UseOXTarget = false

-- Default minigame settings
Config.Minigames = {
    lockpick = {
        difficulty = {easy = {time = 30, gridsize = 5}, medium = {time = 25, gridsize = 6}, hard = {time = 20, gridsize = 7}}
    },
    hacking = {
        difficulty = {easy = {time = 30}, medium = {time = 25}, hard = {time = 20}}
    }
}

-- Notification system (qb-core or okokNotify)
Config.Notify = 'qb'

-- Database settings
Config.Database = {
    tableName = 'qb_robberycreator',
    deleteAfterDays = false -- false or number of days to keep deleted robberies in DB
}

Config.Dispatch = {
    useQS = true, -- Set to false if you don't want to use QS-Dispatch
    defaultAlert = '10-90', -- Default alert code for robberies
    alertCodes = {
        store = '10-90', -- Convenience Store Robbery
        bank = '10-90B', -- Bank Robbery
        jewelry = '10-90J', -- Jewelry Store Robbery
        house = '10-90H', -- House Robbery
        custom = '10-90' -- Custom Robbery
    }
}