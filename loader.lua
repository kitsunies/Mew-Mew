local fs = require('fs')
local json = require('json')
local pathjoin = require('pathjoin')

local decode = json.decode
local pathJoin = pathjoin.pathJoin
local readFileSync = fs.readFileSync
local scandirSync = fs.scandirSync

local core = './modules'
local consts = './constants'

local loader = {modules = {}, constants = {}}

local env = setmetatable({
	require = require, 
	loader = loader,
}, {__index = _G})

function loader.unload(name)
	if loader.modules[name] then
		loader.modules[name] = nil
		print('Module unloaded: ' .. name)
		return true
	else
		print('Unknown module: ' .. name)
		return false
	end
end

function loader.load(name)

	local success, err = pcall(function()
		local path = pathJoin(core, name) .. '.lua'
		local code = assert(readFileSync(path))
		local fn = assert(loadstring(code, '@' .. name, 't', env))
		loader.modules[name] = fn() or {}
	end)

	if success then
		print('Module loaded: ' .. name)
		return loader.modules[name]
	else
		print('Module not loaded: ' .. name)
		print(err)
		return nil
	end

end

_G.process.stdin:on('data', function(data)
	local cmd, name = data:match('(%S+)%s+(%S+)')
	if not cmd then return end
	if cmd == 'reload' then
		return loader.load(name)
	elseif cmd == 'unload' then
		return loader.unload(name)
	end
end)

for k, v in scandirSync(consts) do
	if v == 'file' then
		local name = k:match('(.*)%.lua')
		if name then
			loader.constants[name] = require(consts..'/'..k)
			print('Constant loaded: ' .. name)
		end
	end
end

for k, v in scandirSync(core) do
	if v == 'file' then
		local name = k:match('(.*)%.lua')
		if name and name:find('_') ~= 1 then
			loader.load(name)
		end
	end
end

return loader
