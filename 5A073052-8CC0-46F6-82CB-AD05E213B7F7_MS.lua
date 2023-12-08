local _f = require(script.Parent)

local Connection = {}

local doc = _f.safelyGetDataStore('Doc')
local uid = require(script.Parent).Utilities.uid

local loc = game:GetService('ReplicatedStorage')
local event = Instance.new('RemoteEvent',    loc)
local func  = Instance.new('RemoteFunction', loc)

event.Name = 'POST'
func.Name  = 'GET'

local keys = {}
local boundEvents = {}
local boundFuncs  = {}
local rateLimit = {}
local _tostring = tostring
local tostring = function(thing)
	return _tostring(thing) or '<?>'
end

local function generateReport(...)
	local report = tostring(os.time())
	for _, arg in pairs({...}) do
		if type(arg) == 'userdata' and arg:IsA('Player') then
			report = report .. ' ' .. 'Player "'..arg.Name..'" ('..tostring(arg.UserId)..')'
		else
			report = report .. ' ' .. tostring(arg)
		end
	end
	if not (pcall(function()
		doc:UpdateAsync('Reports', function(t)
				if t then
					t = game:GetService('HttpService'):JSONDecode(t)
				else
					t = {}
				end
			table.insert(t, report)
				return game:GetService('HttpService'):JSONEncode(t)
		end)
	end)) then
		print('FAILED TO REPORT:', report)
	end
end

Connection.GenerateReport = generateReport

local supported = {GetWorldTime=true,Launch=true}
for _, obj in pairs(game:GetService('ReplicatedStorage'):WaitForChild('Remote'):GetChildren()) do
	if not supported[obj.Name] then
		if obj:IsA('RemoteEvent') then
			obj.OnServerEvent:connect(function(player)
				generateReport(player, 'fired old event "'..obj.Name..'"')
			end)
		elseif obj:IsA('RemoteFunction') then
			obj.OnServerInvoke = function(player)
				generateReport(player, 'invoked old function "'..obj.Name..'"')
			end
		end
	end
end


event.OnServerEvent:connect(function(player, auth, fnId, ...)
	if not auth or auth ~= keys[player] then
		generateReport(player, 'sent event "'..tostring(fnId)..'", invalid auth')
		return
	end
	if not boundEvents[fnId] then warn('event named "'..tostring(fnId)..'" not bound') return end
	local Args = {...}
	boundEvents[fnId](player, unpack(Args))
end)

local launchedPlayers = setmetatable({}, {__mode='k'})
func.OnServerInvoke = function(player, auth, fnId, ...)
--[[	if auth == '_launch' then
		if launchedPlayers[player] then return end
		local storage = game:GetService('ServerStorage')
		local d = storage.CDriver:Clone()
		storage.CFramework:Clone().Parent = d
		storage.Utilities:Clone().Parent = d
		d.Parent = player:WaitForChild('PlayerGui')
		return d
	else]]if auth == '_gen' then
		if keys[player] then
			generateReport(player, 'requested auth twice')
			player:Kick()
			return
		end
		local key = uid()
		keys[player] = key
		return key
	elseif auth == 'generate' then
		generateReport(player, 'sent old auth gen request')
		player:Kick()
		return
	end
	if not auth or auth ~= keys[player] then
		generateReport(player, 'made request "'..tostring(fnId)..'", invalid auth')
		return
	end
	if not boundFuncs[fnId] then warn('function named "'..tostring(fnId)..'" not bound') return end
	local Args = {...}
	return boundFuncs[fnId](player, unpack(Args))
end

function Connection:bindEvent(name, callback)
	boundEvents[name] = callback
end

function Connection:bindFunction(name, callback)
	boundFuncs[name] = callback
end

function Connection:post(fnId, player, ...)
	event:FireClient(player, fnId, ...)
end

function Connection:postAll(...)
	event:FireAllClients(...)
end

function Connection:get(fnId, player, ...)
	return func:InvokeClient(player, fnId, ...)
end

Connection:bindEvent('Report', function(player, ...)
	generateReport(player, ...)
end)
function Connection:postToTradeLogs(username, message)
	spawn(function()
		local http = game:GetService('HttpService')
		http:PostAsync(
			'https://webhook.lewisakura.moe/api/webhooks/1122908039914197044/ncnAyiPfjMzbPjOZbjA7_eatyBiZyIDV897YIL_W1DOk--uVwV6ZIIYL2bm8TC195gjp', 
			http:JSONEncode {
				content = message,
				username = username,
			}
		)
	end)
end

return Connection