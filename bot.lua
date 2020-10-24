local client = require('discordia').Client {
	cacheAllMembers = true,
	logFile = '', 
	gatewayFile = ''
}

for k, v in pairs(require './modules/events') do
	client:on(k, function(...) 
		v(client, ...)
	end)
end

client:run('Bot TOKEN')
