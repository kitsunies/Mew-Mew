local prefix = loader.constants.settings.prefix 

local cmds = {
    load = function(query)
        return loader.load(query)
    end,
    unload = function(query)
        return loader.unload(query)
    end,
}

local aliases = {
    reload = cmds.load,
    upload = cmds.load,
    offload = cmds.unload,
}

return function(msg)

    if msg.author ~= msg.client.owner then return end

    local cmd, arg = msg.content:match(prefix..'(.-)%s+(.*)')
    if not cmd or not arg then return end

    local fn = cmds[cmd] or aliases[cmd]
    if not fn then return end

    if select(2, pcall(fn, arg)) then
        msg:addReaction ':Success:737622039078240366'
    else
        msg:addReaction ':Error:737622049517994056'
    end

end
