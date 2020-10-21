local discordia = require('discordia')
local fs = require('fs')
local prefix = require('/constants/settings').prefix

discordia.extensions()
local clock = discordia.Clock()

local events = {}

function events.ready(client)

    local userPresence = {
        name = #client.guilds..' guilds | '..prefix..'help',
        status = 'online',
        type = 3
    }

    client:setGame(userPresence)

    clock:on('hour', function()
        client:setGame(userPresence)
    end)

    clock:start()

end

local modules = {}

for _, v in pairs(fs.readdirSync('./modules')) do
    local name = v:match('(.*)%.lua$')
    if name then
        modules[name] = require('./'..name)
    end
end

function events.messageCreate(client, msg)

    if msg.author.bot then return end
    if msg.author == client.user then return end

    if not msg.guild then
        client.owner:sendf('%s said: %s', msg.author.mentionString, msg.content)
    end

    for k, v in pairs(modules) do
        if type(v) == 'function' then
            v(msg)
        end
    end

end

return events
