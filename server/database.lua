QBCore = exports['qb-core']:GetCoreObject()

-- Initialize database table
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `]] .. Config.Database.tableName .. [[` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(50) NOT NULL,
            `type` varchar(20) NOT NULL,
            `cooldown` int(11) NOT NULL DEFAULT 30,
            `rewards` text NOT NULL,
            `required` text NOT NULL,
            `alert` varchar(20) NOT NULL DEFAULT 'none',
            `position` text NOT NULL,
            `radius` float NOT NULL DEFAULT 2.0,
            `minigame` text NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            `deleted` tinyint(1) NOT NULL DEFAULT 0,
            `delete_at` datetime DEFAULT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], function() end)
end)