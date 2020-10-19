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

    --[[
    if modules.experience then
        modules.experience(msg)
    end
    --]]
    if modules.commands then
        modules.commands.create(msg)
    end

    if modules.manual then
        modules.manual(msg)
    end

end


function events.messageDelete(client, msg)

    if modules.commands then
        modules.commands.delete(msg)
    end

	if modules.undelete then
		modules.undelete(msg)
	end

end

--[[
function events.messageUpdate(...)
    print('messageUpdate: Nothing to connect to!')
end


function events.messageDelete(...)
    print('messageDelete: Nothing to connect to!')
end


function events.messageUpdateUncached(...)
    print('messageUpdateUncached: Nothing to connect to!')
end


function events.messageDeleteUncached(...)
    print('messageDeleteUncached: Nothing to connect to!')
end


--|| Reactions

function events.reactionAdd(...)
    print('reactionAdd: Nothing to connect to!')
end


function events.reactionRemove(...)
    print('reactionRemove: Nothing to connect to!')
end


function events.reactionAddUncached(...)
    print('reactionAddUncached: Nothing to connect to!')
end


function events.reactionRemoveUncached(...)
    print('reactionRemoveUncached: Nothing to connect to!')
end
]]

return events