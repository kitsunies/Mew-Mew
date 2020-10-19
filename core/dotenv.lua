local dotenv = {}

dotenv.Split = function(str, sep)
    if sep == nil then
      sep = '%s'
    end
    local t = { }
    for part in string.gmatch(str, "([^" .. tostring(sep) .. "]+)") do
        table.insert(t, part)
    end
    return t
end

dotenv.Trim = function(str)
  return string.match(str, '^%s*(.-)%s*$')
end

dotenv.Transform = function(str, quoted)
    local _exp_0 = str
    if 'false' == _exp_0 then
        return (quoted and 'false') or false
    elseif 'true' == _exp_0 then
        return (quoted and 'true') or true
    else
        return (quoted and str) or (tonumber(str) and tonumber(str)) or str
    end
end

dotenv.Parse = function(src, options)
    if options == nil then
        options = { }
    end
    local debug = options.debug
    local obj = { }
    for idx, line in pairs(dotenv.Split(src, '\n')) do
        local key, val = line:match("%s*([^.%-]+)%s*=%s*(.*)%s*")
        if not (key or val) then
            if debug then
                print("Failed to parse line " .. tostring(idx) .. " > " .. tostring(line))
            end
        else
            local isQuoted = val:sub(0, 1) == '"' or val:sub(0, 1) == "'" and val:sub(#val, #val) == '"' or val:sub(#val, #val) == "'"
            val = (isQuoted and val:sub(2, #val - 1)) or val
            if not (isQuoted) then
                val = dotenv.Trim(val)
            end
            obj[key] = dotenv.Transform(val, isQuoted)
        end
    end
    return obj
end

dotenv.Config = function(options)
    if options == nil then
        options = {}
    end
    local dotenvPath = options.path or require('path').resolve(process.cwd(), '.env')
    local debug = options.debug or false
    return pcall(function()
        local parsed = dotenv.Parse(require('fs').readFileSync(dotenvPath), options)
        for i, _ in pairs(parsed) do
            if process.env[i] then
                if debug then
                    print(tostring(i) .. " is already defined in process.env and will not be overwritten")
                end
            else
                process.env[i] = parsed[i]
            end
        end
        return parsed
    end)
end

return dotenv