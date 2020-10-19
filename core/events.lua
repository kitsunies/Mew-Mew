local discordia = require('discordia')
local modules = loader.modules
local prefix = loader.constants.settings.prefix

discordia.extensions()
local clock = discordia.Clock()

local events = {}

--|| Ready

function events.ready(client)
    -- print('Ready: ' .. client.user.tag)

    local userPresence = {
        name = #client.guilds .. " guilds | " .. prefix .. "help",
        type = "default",
        status = "online"
    }

    client:setGame(userPresence)

    clock:on('hour', function()
        client:setGame(userPresence)
    end)

    clock:start()

end


--|| Message

function events.messageCreate(client, msg)

    if msg.author.bot then return end
    if msg.author == client.user then return end

    if not msg.guild then
        return client.owner:sendf('%s said: %s', msg.author.mentionString, msg.content)
    end

    if modules.manual then
        modules.manual(msg)
    end

end

return events
