local sandbox = require('/util/sandbox')
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

local env = {}

return function(msg)

    local arg = msg.cleanContent:match(prefix..'code%s+(.+)')
  
    if not arg then return end
    
    arg = arg:gsub('```lua\n?', ''):gsub('```\n?', '')
    
    local lines = {}

    env.print = function(...) table.insert(lines, printLine(...)) end
    env.p = function(...) table.insert(lines, prettyLine(...)) end
    env.coroutine = nil
    
    local success, error = pcall(sandbox.run, arg, {env = env, quota = 1e4})
    local cline = error and error:gsub('^.-%s', '') or #lines > 1 and table.concat(lines, '\n') or ' '
    local output = success and 'success' or 'error'

    return msg:reply{
        embed = {
            title = 'Evaluation',
            description = string.format('Output [%s]\n```lua\n%s```', output, cline),
            color = 0x00007c
        }
    }
end
