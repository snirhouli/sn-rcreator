fx_version 'cerulean'
game 'gta5'

author 'snir houli'
description 'QB-Core Robbery Creator - Create and manage robberies in-game'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/client.lua',
    'client/commands.lua',
    'client/target.lua'
}

server_scripts {
    'server/server.lua',
    'server/database.lua'
}

ui_page 'client/html/index.html'

files {
    'client/html/index.html',
    'client/html/style.css',
    'client/html/script.js'
}

dependency 'qb-core'
dependency 'qb-target'  -- or 'ox_target' for OX Target version
dependency 'qs-dispatch'