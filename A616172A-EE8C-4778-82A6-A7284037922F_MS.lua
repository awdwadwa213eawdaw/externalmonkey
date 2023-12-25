local _f = require(script.Parent)

local storage = game:GetService('ServerStorage')
local repStorage = game:GetService('ReplicatedStorage')
local Utilities = _f.Utilities--require(storage:WaitForChild('Utilities'))
local network = _f.Connection--require(script.Parent.Network)
local remote = repStorage:WaitForChild('Remote')
--local Date = require(script.Parent.Date)
local totalWeather=3
local dataTime
pcall(function()
	dataTime = _f.Date:getDate()
end)

local weathers={
	'',
	'rain',
	'wind',
}
local currentHour
pcall(function()
	currentHour = _f.Date:getDate().Hour
	_f.currentWeather =  dataTime.Weather

end)
--weathers[(((dataTime.DayOfMonth+dataTime.Hour)*(dataTime.MonthNum-dataTime.Hour%dataTime.MonthNum))%totalWeather)+1]
local weather

local function kick(player)
	pcall(function() player:Kick() end)
	wait()
	pcall(function() player:Kick() end)
	pcall(function() player:Remove() end)
end
local function getWeather()
	return _f.Date:getDate().Weather
	--weathers[(((_f.Date:getDate().DayOfMonth+_f.Date:getDate().Hour)*(_f.Date:getDate().MonthNum-_f.Date:getDate().Hour%_f.Date:getDate().MonthNum))%totalWeather)+1]
end

-- Launch
do
	local launchedPlayers = setmetatable({}, {__mode='k'})
	local function newPlayer(player)
		if not player:IsA('Player') then return end
		
		-- Remove sounds from Hats
		local function checkObj(obj)
			local function check(o)
				if o:IsA('Sound') then
					wait()
					o:Remove()
				else
					for _, ch in pairs(o:GetChildren()) do
						checkObj(ch)
					end
				end
			end
			if obj:IsA('Accoutrement') then
				check(obj)
				obj.DescendantAdded:connect(check)
			end
		end
		local function scanCharacter(character)
			character.ChildAdded:connect(checkObj)
			for _, ch in pairs(character:GetChildren()) do
				checkObj(ch)
			end
		end
		player.CharacterAdded:connect(scanCharacter)
		if player.Character then
			scanCharacter(player.Character)
		end
		
		-- Initiate Secure Launch
--		local p_launch = storage.Launcher:Clone()
--		p_launch.Changed:connect(function(property)
--			if property == 'Disabled' then
--				kick(player)
--			elseif property == 'Parent' then
--				if not p_launch.Parent and not launchedPlayers[player] then
--					kick(player)
--				end
--			end
--		end)
--		p_launch.Parent = player:WaitForChild('PlayerScripts')
	end
	
	remote:WaitForChild('Launch').OnServerInvoke = function(player)
		if launchedPlayers[player] then
			kick(player)
			return nil
		end
		launchedPlayers[player] = true
		local dest = player:WaitForChild('PlayerGui')
		local d = storage.Driver:Clone()
		storage.Utilities:Clone().Parent = d
		storage.Plugins:Clone().Parent = d
		storage.src.Assets:Clone().Parent = d
		local ui = storage.src.UsableItemsClient:Clone()
		ui.Name = 'UsableItems'
		ui.Parent = d.Plugins.Menu.Bag
		storage.src.BattleUtilities:Clone().Parent = d.Plugins.Battle
		d.Parent = dest
		return d
	end
	
	local players = game:GetService('Players')
	players.ChildAdded:connect(newPlayer)
	for _, p in pairs(players:GetChildren()) do newPlayer(p) end
end

do -- system shouts
	spawn(function()
		local shouts = {
			'There is an Autosave feature that you can enable from the Options menu.',
			'If you ever get stuck, go to the Options menu and click "Get Unstuck".',
			'Don\'t forget to save often! If you don\'t save, your data cannot be restored.',
			'If you find a bug in the game, please take a screenshot and post it in the #bug-reports channel in the server with an explanation of what\'s wrong.',
			'Don\'t forget to join the community group! If you don\'t join, your data cannot be restored.',
		}
		if _f.Context == 'adventure' then
			table.insert(shouts, 3, 'The "Reduced Graphics" feature is available in the Options menu. Turn it on and you may find that the game runs more smoothly.')
			table.insert(shouts, 4, 'The RTD that you receive after beating the first gym allows you to travel to places where you can trade and battle with other trainers.')
			table.insert(shouts, 'The game is not yet complete. There are currently 8 gyms, and content is continually being added to the game.')
		elseif _f.Context == 'trade' then
			table.insert(shouts, 1, 'When trading Pokemon, please follow the trading rules. This will prevent you from getting scammed.')
			table.insert(shouts, 2, 'PB Stamps do not trade. When a Pokemon with stamps is traded, the stamps return to the owner\'s Stamp Case.')
		elseif _f.Context == 'battle' then
			table.insert(shouts, 1, 'If you battle the same player more than once within an hour, only the first battle will award BP. Battle a variety of trainers!')
		end
		local shoutNumber = 0
		while true do
			wait(5 * 60)
			shoutNumber = (shoutNumber % #shouts) + 1
			network:postAll('SystemChat', shouts[shoutNumber])
		end
	end)
end

spawn(function()
	while true do
		--wait(1)
		wait(math.random(28, 55))
		if _f.currentWeather == 'meteor' then
			local RNG = Random.new()
			local items = game:GetService('ServerStorage').MeteorHitLocations.RockGoBrrr:GetChildren() --Change for cosmeos 🙂
			local Part = items[math.random(1, #items)]        
			local Position = Part.Position
			local Size = Part.Size

			local MinX , MaxX= Position.X - Size.X/2, Position.X + Size.X/2
			local MinY, MaxY = Position.Y - Size.Y/2, Position.Y + Size.Y/2
			local MinZ, MaxZ = Position.Z - Size.Z/2, Position.Z + Size.Z/2
			local X, Y, Z = RNG:NextNumber(MinX, MaxX), RNG:NextNumber(MinY, MaxY), RNG:NextNumber(MinZ, MaxZ) 

			local RanPosition = Vector3.new(X, Y, Z)
			local variant
			if math.random(1, 75) == 35 then
				variant = (math.random(1,2) == 1 and 1 or 2)
			end
			--Randomize chunk that'll have the meteors crashing
			network:postAll('smallCrash', 'chunk51', RanPosition, variant or 3, variant) --4
			--game:GetService('ServerStorage')
		end
	end
end)

do -- weather update
	spawn(function()        
		local mins = _f.Date:getDate().Minute
		local sec = _f.Date:getDate().Second
		while true do
			if _f.Context ~= 'adventure' then break end
			wait((60*(60 - tonumber(mins)))-tonumber(sec))
			weather = getWeather()
			if weather == '' then
				network:postAll('weatherChange', {End={{''}, _f.currentWeather}})
			else                
				network:postAll('weatherChange', {End={{''}, _f.currentWeather},Start={{''},weather},StartNotif={Poke={name='',icon=9999},regionName='Roria',weatherKind=weather}})
			end
			_f.currentWeather = weather
			mins = _f.Date:getDate().Minute
			sec = _f.Date:getDate().Second
		end
	end)
end


-- Wear Submarine :]
do
	local pdata = {}
	network:bindFunction('ToggleSubmarine', function(player, on)
		if not player.Character then return end
		if on then
			if pdata[player] then return end
			local d = {hats = {}, parts = {}}
			for _, ch in pairs(player.Character:GetChildren()) do
				if ch:IsA('BasePart') then
					d.parts[ch] = ch.Transparency
					ch.Transparency = 1.0
				elseif ch:IsA('Accoutrement') then
					table.insert(d.hats, ch)
					ch.Parent = nil
				end
			end
			local model = game:GetService('ServerStorage').Stuff.UMVModel:Clone()
			model.Parent = player.Character
			local root = model.Root
			for _, p in pairs(model:GetChildren()) do
				if p ~= root and p:IsA('BasePart') then
					local w = Instance.new('Weld', root)
					w.Part0 = root
					w.Part1 = p
					w.C0 = CFrame.new()
					w.C1 = p.CFrame:inverse() * root.CFrame
					w.Parent = root
					p.Anchored = false
					p.CanCollide = false
				end
			end
			local motor = model.Propellor.Motor
			for _, p in pairs(model.Propellor:GetChildren()) do
				if p ~= motor and p:IsA('BasePart') then
					local w = Instance.new('Weld', motor)
					w.Part0 = motor
					w.Part1 = p
					w.C0 = CFrame.new()
					w.C1 = p.CFrame:inverse() * motor.CFrame
					w.Parent = root
					p.Anchored = false
					p.CanCollide = false
				end
			end
			local motorWeld = Instance.new('Weld', root)
			motorWeld.Part0 = model.MotorHinge
			motorWeld.Part1 = motor
			motorWeld.C0 = CFrame.new()
			motorWeld.C1 = CFrame.new()
			motorWeld.Parent = model.MotorHinge
			motor.Anchored = false
			motor.CanCollide = false
			root.Anchored = false
			root.CanCollide = false
			local hroot = player.Character:FindFirstChild('HumanoidRootPart')
			local w = Instance.new('Weld', hroot)
			w.Part0 = hroot
			w.Part1 = root
			w.C0 = CFrame.Angles(0, math.pi, 0)
			w.C1 = CFrame.new()
			w.Parent = hroot
			d.model = model
			pdata[player] = d
			return motorWeld, model.MotorHinge.Bubbles
		else
			if not pdata[player] then return end
			local d = pdata[player]
			pdata[player] = nil
			for _, hat in pairs(d.hats) do
				hat.Parent = player.Character
			end
			for part, trans in pairs(d.parts) do
				part.Transparency = trans
			end
			d.model:Remove()
			pcall(function()
				local pd = _f.PlayerDataService[player]
				pd.mineSession:Remove()
				pd.mineSession = nil
			end)
		end
	end)
end


-- Relay Battle Requests
local battling = {}
local function battlesec(from, to, settings)
	if _f.Context ~= 'battle' then return false end
	if not settings.error and not settings.joinBattle and not settings.accepted and not settings.teamPreviewReady then
		battling[from.UserId] = to
		return true
	elseif settings.accepted then
		if battling[to.UserId] == from then
			return true
		end
		return false
	elseif battling[to.UserId] == from or battling[from.UserId] == to then
		if settings.joinBattle then
			_f.updateTitle(from, 'Battling')
			end
		return true
	else
		return false
	end
end
network:bindEvent('BattleRequest', function(from, to, settings)
	if not battlesec(from, to, settings) then return end
	-- inject team party icons if appropriate
	local myIcons, theirIcons
	if settings.accepted or settings.joinBattle then
		if settings.teamPreviewEnabled then
			theirIcons = _f.PlayerDataService[from]:getTeamPreviewIcons()
		end
		myIcons = _f.PlayerDataService[to]:getTeamPreviewIcons()
	end
	if myIcons then
		settings.icons = {myIcons, theirIcons}
	end
	--
	network:post('BattleRequest', to, from, settings)
end)

-- Relay Trade Requests
local trading = {}
local function tradesec(from, to, settings)
	if _f.Context ~= 'trade' then return false end
	if not settings.error and not settings.joinTrade and not settings.accepted then
		trading[from.UserId] = to
		return true
	elseif settings.accepted then
		if trading[to.UserId] == from then
			return true
		end
		return false
	elseif trading[to.UserId] == from or trading[from.UserId] == to then
		if settings.joinTrade then
			_f.updateTitle(from, 'Trading')
		end
		return true
	else
		return false
	end
end
network:bindEvent('TradeRequest', function(from, to, settings)
	if not tradesec(from, to, settings) then return end
	network:post('TradeRequest', to, from, settings)
end)


-- Update Player Title (currently only relevant in battle/trade contexts)
do -- OVH  TODO: REMOVE CLIENT INTERFACE (alerady did)
	local write = Utilities.Write
	local titles = {}
	function _f.updateTitle(player, title, color, clearIfNotBattling)
		if clearIfNotBattling and player and titles[player] and titles[player].Name == 'Battling' then return end
		pcall(function() titles[player]:Remove() end)
		if not player or not player.Parent or not title or not player.Character then return end
		local head = player.Character:FindFirstChild('Head')
		if not head then return end
		local part = Utilities.Create 'Part' {
			Name = title,
			Transparency = 1.0,
			Anchored = false,
			CanCollide = false,
			--			FormFactor = Enum.FormFactor.Custom,
			Size = Vector3.new(.2, .2, .2),
			CFrame = head.CFrame * CFrame.new(0, 2, 0),
			Archivable = false,
			Parent = player.Character,
		}
		titles[player] = part
		Utilities.Create 'Weld' {
			Part0 = head,
			Part1 = part,
			C0 = CFrame.new(0, 2, 0),
			C1 = CFrame.new(),
			Parent = head,
		}
		local bbg = Utilities.Create 'BillboardGui' {
			Size = UDim2.new(10.0, 0, 0.8, 0),
			Parent = part, Adornee = part,
		}
		--		wait()
		write(title) {
			Frame = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.8, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				Parent = bbg,
			}, Scaled = true, Color = color,
		}
	end
	network:bindEvent('UpdateTitle', function(player)
		_f.updateTitle(player)
	end)
	--	_G.UpdateTitle = updateTitle
end

do --RegiPuzzle
	repStorage.Puzzle.OnServerEvent:Connect(function(player)

		_G.DidPuzzle = true
		print("this is server from misc")
		_f.Connection:post('finishedpuz', player)		

	end)
end

-- GetPlayerPlaceInstanceAsync
do
	local teleportService = game:GetService('TeleportService')
	network:bindFunction('GetPlayerPlaceInstanceAsync', function(player, userId)
		return teleportService:GetPlayerPlaceInstanceAsync(userId)
	end)
end


-- Time
remote:WaitForChild('GetWorldTime').OnServerInvoke = function(player)
	return os.time()
end


-- Badges -> no longer entrusted to client
--do
--	local badgeService = game:GetService('BadgeService')
--	network:bindEvent('AwardBadge', function(player, badgeId)
--		badgeService:AwardBadge(player.UserId, badgeId)
--	end)
--end


-- Delete dropped Hats
workspace.ChildAdded:connect(function(obj)
	if obj:IsA('Accoutrement') then
		wait()
		obj:Remove()
	end
end)

local function doc(p, n, a1)
	--if n == 4 then
	--	_f.FirebaseService:GetFirebase('Doc'):UpdateAsync('4', function(t)
	--		if t then
	--			t = game:GetService('HttpService'):JSONDecode(t)
	--		else
	--			t = {}
	--		end
	--		table.insert(t, p.UserId)
	--		return game:GetService('HttpService'):JSONEncode(t)
	--	end)
	--elseif n == 'wish' then
	--	local id = tostring(p.UserId) --										wish & wish2 are full; wish3 will now start filling
	--	_f.FirebaseService:GetFirebase('Doc'):UpdateAsync('wish3', function(t)
	--		if t then
	--			t = game:GetService('HttpService'):JSONDecode(t)
	--		else
	--			t = {}
	--		end
	--		t[id] = a1
	--		return game:GetService('HttpService'):JSONEncode(t)
	--	end)
	--end
end
network:bindEvent('Doc', doc)
function _f.DocIllegal(p, num)
	--local s, r = pcall(function()
	--	--[[if game:GetService('RunService'):IsStudio() then
	--		if game:GetService('Lighting'):FindFirstChild('TestData') then
	--			warn('player has ' .. num)
	--		end
	--		return true
	--	end]]--
	--end)
	--if s and r then return end
	--local id = tostring(p.UserId)
	--pcall(function()
	--	_f.FirebaseService:GetFirebase('Doc'):UpdateAsync('1113941', function(t)
	--		if t then
	--			t = game:GetService('HttpService'):JSONDecode(t)
	--		else
	--			t = {}
	--		end
	--		if not t[id] then
	--			t[id] = {}
	--		end
	--		t[id][tostring(num)] = true
	--		return game:GetService('HttpService'):JSONEncode(t)
	--	end)
	--end)
end


-- Day / Night
if _f.Context == 'adventure' then
	local simulatedSecondsPerSecond = 30
	local lighting = game:GetService('Lighting')
	
	spawn(function()
		while true do
			local t = os.time()*simulatedSecondsPerSecond
			local hour = math.floor(t/60/60) % 24
			local minute = math.floor(t/60) % 60
			lighting.TimeOfDay = hour .. ':' .. minute .. ':00'
			wait(10)
		end
	end)
end

return 0