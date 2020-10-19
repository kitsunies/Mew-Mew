local pp = require("pretty-print")
local prefix = loader.constants.settings.prefix 

local function printLine(...)
    local ret = {}
    for i = 1, select('#', ...) do
        local arg = tostring(select(i, ...))
        table.insert(ret, arg)
    end
    return table.concat(ret, '\t')
end

local function prettyLine(...)
    local ret = {}
    for i = 1, select('#', ...) do
        local arg = pp.strip(pp.dump(select(i, ...)))
        table.insert(ret, arg)
    end
    return table.concat(ret, '\t')
end

local sandbox = setmetatable({
	require = require,
	discordia = discordia
}, {__index = _G})

return function(msg)

    local arg = msg.content:match(prefix..'code%s+(.+)')
  
    if not arg then return end

    if msg.author ~= msg.client.owner then return end
    
    arg = arg:gsub('```lua\n?', ''):gsub('```\n?', '')
    
    local lines = {}
    
    sandbox.msg = msg
    sandbox.client = msg.client
    sandbox.print = function(...) table.insert(lines, printLine(...)) end
    sandbox.p = function(...) table.insert(lines, prettyLine(...)) end
    
    local fn, err = load(arg, msg.client.user.name, 't', sandbox)
    if not fn then return msg:reply{content = err, code = 'lua'} end
    
    local success, runtimeError = pcall(fn)
    if not success then return msg:reply{content = runtimeError, code = 'lua'} end
    
    msg:addReaction("✅")
    
    if #lines > 0 then
        return msg:reply{content = table.concat(lines, '\n'), code = 'lua'}
    end
end
