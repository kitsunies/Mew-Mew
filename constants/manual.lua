local manual = 'https://www.lua.org/manual/%s/manual.html'
local http = require 'coro-http'

local manuals = {state = false}

coroutine.wrap(function()
    for i = 5.1, 5.4, 0.1 do
        i = tostring(i)
        local res, data = http.request('GET', manual:format(i))
        manuals[i] = data and tostring(data)
    end
    manuals.state = true
end)()

return manuals
