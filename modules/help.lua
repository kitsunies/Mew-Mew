local prefix = require('/constants/settings').prefix

return function(msg)

	if not msg.cleanContent:match(prefix..'help') then return end

	msg:reply {
		embed = {
			title = 'Commands',
			fields = {
				{ name = prefix..'code [arg]', value = '**Usage:** Evaluates Lua code'},
				{ name = prefix..'man[5.1-5.4] [function]', value = '**Usage:** Searches the Lua manual for provided function'}
			},
			color = 0x00007c
		}
	}
	
end
