local loader = require('./loader')
local dotenv = loader.load('dotenv').Config()
local client = require('discordia').Client {
	cacheAllMembers = true,
	logFile = '', 
	gatewayFile = ''
}

for k, v in pairs(loader.load 'events') do
	client:on(k, function(...) 
		v(client, ...)
	end)
end

client:run('Bot '..process.env.TOKEN)