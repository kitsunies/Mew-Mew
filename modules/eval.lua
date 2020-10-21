local pp = require("pretty-print")
local prefix = require('/constants/settings').prefix

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

    local arg = msg.cleanContent:match(prefix..'eval%s+(.+)')
  
    if not arg then return end

    if msg.author ~= msg.client.owner then return end
    
    arg = arg:gsub('```lua\n?', ''):gsub('```\n?', '')
    
    local lines = {}
    
    sandbox.msg = msg
    sandbox.client = msg.client
    sandbox.print = function(...) table.insert(lines, printLine(...)) end
    sandbox.p = function(...) table.insert(lines, prettyLine(...)) end
    
    local fn, err = load(arg, msg.client.user.name, 't', sandbox)
    local output, cline = 'error', err
    if fn then 
        local ok, flaw = pcall(fn)
        cline = flaw and flaw:gsub('^.-%s', '') or table.concat(lines, '\n')
        output = ok and 'success'
    end

    return msg:reply{
        embed = {
            title = 'Evaluation',
            description = string.format('Output [%s]\n```lua\n%s```', output, cline),
            color = 0x00007c
        }
    }
end
