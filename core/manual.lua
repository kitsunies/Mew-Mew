local url = 'https://www.lua.org/manual/%s/manual.html'
local pretag = '<hr><h3><a name="'
local prefix = loader.constants.settings.prefix
require('discordia').extensions()

local function sub(sub)
    --> Entity Subs
    sub = sub:gsub('&.-;', {
        --> Names
        ['&nbsp;'] = ' ', ['&lt;'] = '<',
        ['&gt;'] = '>', ['&amp;'] = '&',
        ['&quot;'] = '"', ['&apos;'] = '\'',
        ['&copy;'] = '©', ['&reg;'] = '®',
        --> Numbers
        ['&#160'] = ' ', ['&#60;'] = '<',
        ['&#62;'] = '>', ['&#38;'] = '&',
        ['&#34'] = '"', ['&#39;'] = '\'',
        ['&#169'] = '©', ['&#174;'] = '®',
        --> Single 
        ['&middot;'] = '.'
    })
    --> Ordinary Sub
    sub = sub:gsub('<.->', {
        ['<i>'] = '*', ['</i>'] = '*',
        ['<p>'] = '', ['</p>'] = '',
        ['<b>'] = '**', ['</b>'] = '**',
        ['<em>'] = '*', ['</em>'] = '*',
        ['<br>'] = '\n', ['</a>'] = '',
        ['<code>'] = '`', ['</code>'] = '`',
        ['<strong>'] = '**', ['</strong>'] = '**',
        ['<pre>'] = '```lua', ['</pre>'] = '```\n'
    })
    --> Unique Subs
    sub = sub:gsub('<a href=".-">', '')
    sub = sub:gsub('\n\n+', '=\n\n=')
    sub = sub:gsub('(%S)\n(%S)', '%1 %2')
    return sub
end

return function(msg)

    if msg.content:sub(1, #prefix+3) ~= prefix..'man' then return end
    if msg.author.id == msg.client.user.id then return end
    if not loader.constants.manual['5.4'] then msg:reply('Lua manuals are loading...') return end

    local query = msg.content:split(' ')[2]
    local version

    if msg.content:sub(6, 6) ~= '.' then 
        version = msg.content:sub(5, 5) .. '.' .. msg.content:sub(6, 6)
    else
        version = msg.content:sub(5, 7)
    end

    if not query then return end
    if not version then return end

    local url = url:format(version)
    local data = loader.constants.manual[version]
    local suc, ret = pcall(function()
        return {
            sub(data:match(pretag..'[pdf%-]+'..query..'"><code>(.-)</code></a></h3>.-<hr>')),
            sub(data:match(pretag..'[pdf%-]+'..query..'"><code>.-</code></a></h3>(.-)<hr>'))
        }
    end)

    local keyPairs = { 
        'Library', 
        'C API', 
        'C Aux' 
    }

    local switch = {
        ['pdf-'] = 'Library',
        ['lua_'] = 'C API',
        ['luaL_'] = 'C Aux'
    }

    local title, body
    if suc then
        title, body = unpack(ret)
    else
        local results = {}
        local temps = {
            ['Library'] = {},
            ['C API'] = {},
            ['C Aux'] = {}
        }
        local count = 0
        for str in data:gmatch(pretag..'(%S-'..query..'%S-)">') do
            for match in data:gmatch('<h3><a name="(%S-'..query..'%S-)">') do
                local str = ('[`%s`](%s%s%s)'):format(match:gsub('pdf%-', ''), url, '#', match)
                if match:gsub('pdf%-', '') ~= query then
                    for k in pairs(switch) do
                        if str:find(k) then
                            temps[switch[k]][#temps[switch[k]]+1] = str
                        end    
                    end
                end
            end
        end
        for _, k in ipairs(keyPairs) do
            for _, v in ipairs(temps[k]) do
                local found = false
                for _, r in pairs(results) do
                    if v == r then
                        found = true
                    end
                end
                if v ~= query and count < 10 and not found then 
                    results[#results+1] = v
                    count = count + 1
                end
            end
        end
        
        return msg:reply {
            embed = {
                title = 'Lua '..version..' Manual',
                url = url,
                description = 'No results for: `'..query..'`',
                fields = {
                    {
                        name = 'Did you mean:', 
                        value = table.concat(results, ', '),
                        inline = false
                    }
                },
                color = 0x00007c
            }    
        }
    end
    local description = ('----\n\n[`%s`](%s#pdf-%s)'):format(title, url, query)


    local fields = {}
    for paragraph in body:gmatch('\n=(.-)=\n') do
        fields[#fields+1] = {
            name = '​', -- zero length white space >w<
            value = paragraph,
            inline = false
        }
    end

    local results = {
        ['Library'] = {},
        ['C API'] = {},
        ['C Aux'] = {}
    }

    for lib, post in data:gmatch(pretag..'(%S-)'..query..'(%S-)">') do
        local sub
        for k in pairs(switch) do
            if lib:find(k) then
                sub = k
            end    
        end
        local pre = lib:sub(#sub+1, #lib)
        local fol = switch[sub]
        pre = pre or ''
        post = post or ''
        sub = sub == 'pdf-' and 'pdf%-' or sub
        for match in data:gmatch('"('..sub..pre..query..post..')">') do
            if match:gsub('pdf%-', '') ~= query then
                match = ('[`%s`](%s%s%s)'):format(match:gsub('pdf%-', ''), url, '#', match)
                results[fol][#results[fol]+1] = match ~= query and match
            end
        end
    end

    for _, k in ipairs(keyPairs) do
        local val = results[k]
        if #val > 0 then
            fields[#fields+1] = {
                name = 'Additional '..k..' Results',
                value = table.concat(val, ', '),
                inline = false
            }
        end
    end

    msg:reply {
        embed = {
            title = 'Lua '..version..' Manual',
            url = url,
            description = description,
            fields = fields,
            color = 0x00007c
        }
    }

end
