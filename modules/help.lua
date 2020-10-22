local prefix = require('/constants/settings').prefix

return function (msg)
	msg:reply {
		embed = {
			title = 'Commands',
			fields = {
				{name = 'code', value = '**Usage:** Evaluates Lua code\n**Format** '..prefix..'code [arg]', inline = true},
				{name = 'man', value = '**Usage:** Searches the Lua manual for provided function\n**Format:** '..prefix..'man[5.1-5.4] [function]', inline = true}
			},
			color = 0x00007c
		}
	}
end
