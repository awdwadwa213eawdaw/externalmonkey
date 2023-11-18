return function(_p)
	local Utilities = _p.Utilities
	local rc4 = Utilities.rc4
    local _f
	local rateLimit = {}

	local player = _p.player

	local MAX_MONEY = 9999999
	local MAX_BP = 9999
	local MAX_TIX = 9999999

	--local ENABLE_DEBUG_LOCATION = true -- TODO: REMOVE BEFORE PUBLISHING
	--local DEBUG_LOCATION

	local PlayerData = {
		gameBegan = false,
		trainerName = player.Name,
		badges = {},
		money = 0,
		bp = 0,
		completedEvents = {},
		expShareOn = false,
		defeatedTrainers = '',
		firstNonEggLevel = 1, -- remember us!!!
		firstNonEggAbility = '',
		tix = 0,
		isDate = false
	}

	_p.Connection:bindEvent('PDChanged', function(...) -- k1, v1, k2, v2, ... kn, vn
		local k
		for _, v in pairs({...}) do
			if k then
				PlayerData[k] = v
				if k == 'money' then
					_p.Menu.shop:updateMoneyIfActive()
				end
				k = nil
			else
				k = v
			end
		end
	end)

	_p.Connection:bindEvent('eventCompleted', function(name)
		PlayerData.completedEvents[name] = true
	end)

	_p.Connection:bindEvent('badgeObtained', function(i)
		PlayerData.badges[i] = true
	end)

	_p.Connection:bindEvent('bpAwarded', function(amount, newTotal)
		PlayerData.bp = math.min(newTotal)
		_p.Menu.battleShop:updateBP()
		local gui = _p.RoundedFrame:new {
			CornerRadius = Utilities.gui.AbsoluteSize.Y*.025,
			BackgroundColor3 = BrickColor.new('Deep blue').Color,
			Size = UDim2.new(.3, 0, .3, 0),
			Position = UDim2.new(.35, 0, .35, 0),
			Parent = Utilities.frontGui,
		}
		Utilities.Write('+'..amount..' BP') {
			Frame = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.3, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 2, Parent = gui.gui,
			}, Scaled = true,
		}
		Utilities.Write 'Remember to SAVE!' {
			Frame = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.15, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 2, Parent = gui.gui,
			}, Scaled = true,
		}
		local ok; ok = _p.RoundedFrame:new {
			Button = true,
			CornerRadius = Utilities.gui.AbsoluteSize.Y*.025,
			BackgroundColor3 = BrickColor.new('Navy blue').Color,
			Size = UDim2.new(.5, 0, .3, 0),
			Position = UDim2.new(.25, 0, .6, 0),
			Parent = gui.gui,
			MouseButton1Click = function()
				ok:Remove()
				gui:Remove()
			end,
		}
		Utilities.Write 'OK' {
			Frame = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.6, 0),
				Position = UDim2.new(0.5, 0, 0.2, 0),
				ZIndex = 2, Parent = ok.gui,
			}, Scaled = true,
		}
		delay(6, function()
			pcall(function()
				ok:Remove()
				gui:Remove()
			end)
		end)
	end)

	_p.Connection:bindEvent('ItemProductPurchased', function(itemName, itemIcon)
		game:GetService('StarterGui'):SetCore('SendNotification', {
			Title = itemName .. ' Obtained!',
			Text = 'Don\'t forget to SAVE!',
			Icon = 'rbxassetid://'..itemIcon,
			--		Duration = 5; -- Optional, defaults to 5 seconds
			--		Callback = bindableFunction; -- Optional, gets invoked with the text of the button the user pressed
			--		Button1 = "Yes"; -- Optional, makes a button appear with the given text that, when clicked, fires the Callback if it's given
			--		Button2 = "No"; -- Optional, makes another button appear with the given text that, when clicked, fires the Callback if it's given
		})
	end)

	_p.Connection:bindEvent('PondPassPassPurchased', function()
		_p.PlayerData.hasPondPass = true
	end)
	
	function PlayerData:formatMoney(m)
		return Utilities.comma_value(m or self.money)
	end
	function PlayerData:formatTix(t)
		return Utilities.comma_value(t or self.tix)
	end
	function PlayerData:completeEvent(event, ...)
		local r = _p.Connection:get('PDS', 'completeEvent', event, ...)
		if r == false then return false end
		self.completedEvents[event] = true
		return r or true
	end
	
	local function limit(player, calls, interval)
		if not rateLimit[player.UserId] then
			rateLimit[player.UserId] = {0, tick(), false}
		end
		local list = rateLimit[player.UserId]

		if (tick() - list[2]) >= interval then
			list[1] = 0
			list[2] = tick()
			list[3] = false
		else
			list[1] = list[1] + 1
		end

		if list[1] >= calls then
			if not list[3] then
				list[3] = true
				pcall(function()
					_f.Logger:logSus(player, {
						exploit = tostring(script.Name).." Exploit",
						extra = "The player has been detected spamming functions faster than the rate limit allows."
					})
				end)
				player:Kick("We have detected an instance of exploiting. If this isn't the case, please rejoin to continue playing the game.")
			end
			return true
		end
	end


	function PlayerData:getEtc()
		if not limit(player, 60, 60) then
			if not self.gameBegan then error('attempt to save before game began') end

			local etc = {
				expShareOn = self.expShareOn,
				--		tName = self.trainerName
			}

			-- repel
			if _p.Repel.steps > 0 then
				etc.repel = {}
				etc.repel.kind = _p.Repel.kind
				etc.repel.steps = math.ceil(_p.Repel.steps/2)
			end

			-- options
			etc.options = {}
			etc.options.autosaveEnabled = _p.Autosave.enabled and true or false
			etc.options.reduceGraphics = _p.Menu.options.reduceGraphics and true or false
			etc.options.lastUnstuckTick = _p.Menu.options.lastUnstuckTick
			etc.options.tSpeed = _p.NPCChat.speed ~= 35 and true or false

			-- location
--[[
	if ENABLE_DEBUG_LOCATION then
		etc.location = DEBUG_LOCATION
	else]]if _p.context == 'adventure' then
				local buffer = _p.BitBuffer.Create()
				local chunk = _p.DataManager.currentChunk
				-- position
				local cframe = _p.player.Character.HumanoidRootPart.CFrame
				if chunk.id == 'gym5' and cframe.p.Y < 80 then
					cframe = CFrame.new(-130, 83, 350, -1, 0, 0, 0, 1, 0, 0, 0, -1) -- instead of loading under the dirt
				end
				if #chunk.roomStack > 0 then
					local room = chunk.roomStack[#chunk.roomStack]
					cframe = cframe - room.model.Base.Position
				end
				buffer:WriteCFrame(cframe)
				-- chunk / buildings
				buffer:WriteString(chunk.id)
				for i, room in pairs(chunk.roomStack) do
					buffer:WriteBool(true)
					buffer:WriteString(room.id)
					if i > 1 then
						buffer:WriteCFrame(room.exitCFrame-chunk.roomStack[i-1].model.Base.Position)
					end
				end
				buffer:WriteBool(false)
				etc.location = buffer:ToBase64()
			end

			return etc
		end
	end

	function PlayerData:loadEtc(etc)
		if not limit(player, 60, 60) then
			self.isDate = etc.SpecialDate
			self.trainerName = etc.tName
			self.defeatedTrainers = etc.dTrainers or ''
			self.completedEvents = etc.completedEvents --for event in pairs(self.completedEvents) do print(event) end
			_p.Events.init() -- to grab the new completedEvents table
			self.expShareOn = etc.expShareOn

			local b = {}
			for k, v in pairs(etc.badges) do
				b[tonumber(k)] = v
			end
			self.badges = b
			if self.completedEvents.ReceivedRTD then
				_p.Menu.rtd:enable()
			end
			if self.completedEvents.RunningShoesGiven then
				_p.RunningShoes:enable()
			end
			--if self.completedEvents.GivenZPouch then
			--	_p.Menu.bag:enablezmovepouch()
			--end
			if etc.repel then
				_p.Repel.kind = etc.repel.kind
				_p.Repel.steps = etc.repel.steps
				_p.Repel.more = etc.repel.more
			end

			if etc.dcEgg then
				self.daycareManHasEgg = true
			end

			if etc.options then
				if etc.options.autosaveEnabled then
					_p.Autosave:enable()
				end
				if etc.options.reduceGraphics then
					_p.Menu.options.reduceGraphics = true
					_p.Menu.options:setLightingForReducedGraphics(true)
				end
				_p.Menu.options.lastUnstuckTick = etc.options.lastUnstuckTick or 0
				if etc.options.tSpeed then
					_p.NPCChat.speed = 35*3
				end
			end

			if etc.newGameFlag then
				_p.Menu.newGameFlag = true
			end

			self.rotomEventLevel = etc.rotom

			if self.completedEvents.GivenZPouch then
				_p.Menu.bag:enablezmovepouch()
			end
			if etc.repel then
				_p.Repel.kind = etc.repel.kind
				_p.Repel.steps = etc.repel.steps
				_p.Repel.more = etc.repel.more
			end
			-- location
--[[
	if ENABLE_DEBUG_LOCATION then
		_p.DataManager:loadChunk('gym6')
		Utilities.Teleport(CFrame.new(216, 50, 883))
		DEBUG_LOCATION = etc.location
	else]]if etc.location then
				local buffer = _p.BitBuffer.Create()
				buffer:FromBase64(etc.location)
				-- position
				local cframe = buffer:ReadCFrame()
				-- chunk / buildings
				local chunkId = buffer:ReadString()
				local indoors = buffer:ReadBool()
				local chunk    
				local s,r = pcall(function()
					if not indoors then
						chunk = _p.DataManager:loadChunk(chunkId, {continueCFrame = cframe})
						if etc.Surfin == true then
							print('Attempted to forceSurf at cframe')
							_p.Surf:forceSurf(cframe)
						end
					else
						chunk = _p.DataManager:loadChunk(chunkId)
						chunk.indoors = true
						_p.MasterControl:SetIndoors(true)
						local roomId = buffer:ReadString()
						local door = chunk:getDoor(roomId)
						local room = chunk:getRoom(roomId, door, 1)
						chunk.roomStack = {room}

						chunk:checkRegion(door.Position)
						game:GetService('RunService').RenderStepped:wait()
						local roomMusicId, roomMusicVolume
						if roomId == 'PokeCenter' then
							roomMusicId = 9987312401
						elseif roomId:sub(1, 4) == 'Gate' and tonumber(roomId:sub(5)) then
							roomMusicId = 9987455431--288893317
							roomMusicVolume = .45
							_p.DataManager.ignoreRegionChangeFlag = nil
						end
						pcall(function()
							if not chunk.roomData[roomId].Music then return end
							roomMusicId = chunk.roomData[roomId].Music
							roomMusicVolume = chunk.roomData[roomId].MusicVolume
						end)
						local function fixMusic()
							_p.MusicManager:fadeToVolume('RegionMusic', roomMusicId and 0 or 0.3, 0)
							if roomMusicId then
								_p.MusicManager:stackMusic(roomMusicId, 'RoomMusic', roomMusicVolume)
							end
						end
						local oneRegion = false
						for _ in pairs(chunk.data.regions) do
							if oneRegion then
								oneRegion = false
								break
							else
								oneRegion = true
							end
						end
						if oneRegion then
							spawn(function()
								local stack = _p.MusicManager:getMusicStack()
								while true do
									local l = stack[#stack]
									if l and l.Name == 'RegionMusic' then break end -- hax
									wait(.1)
								end
								fixMusic()
							end)
						else
							fixMusic()
						end

						local event = _p.Events['onBeforeEnter_'..roomId]
						if event then event(room, cframe) end

						while buffer:ReadBool() do
							chunk.indoors = true
							local subRoomId = buffer:ReadString()
							local subRoomButton
							for _, p in pairs(chunk:topRoom().model:GetChildren()) do
								if ((p.Name == 'SubRoom' and p:IsA('BasePart'))
									or (p.Name == 'InsideDoor' and p:IsA('Model')))
									and p:FindFirstChild('id') and p.id.Value == subRoomId then
									subRoomButton = p:IsA('Model') and p.Main or p
									break
								end
							end
							chunk:stackSubRoom(subRoomId, subRoomButton, true) -- support for multi-sub-roomed buildings ?
							chunk:topRoom().exitCFrame = buffer:ReadCFrame() + chunk.roomStack[#chunk.roomStack-1].model.Base.Position
						end
						workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
						chunk:bindIndoorCam()
						cframe = cframe + chunk:topRoom().model.Base.Position
					end
				end)
				if not s then -- Chunk Loading Failsafe
					_f = game:GetService("ServerScriptService"):WaitForChild("SFramework")
					wait(.5)
					_f.Logger:logExploit(self.PlayerData.player,{
						exploit = "Chunk Failsafe Initiated",
						extra = r
					})
					Utilities.TeleportToSpawnBox()
					chunk = _p.DataManager:loadChunk('chunk1')
					spawn(function()
						wait(2)
						_p.Menu.options:getUnstuck(true)			
					end)
				end
				local function indoorsFix()
					local room = chunk:topRoom()
					local entrance = room.Entrance
					if entrance then
						cframe = entrance.CFrame * CFrame.new(0, 3, 3.5) * CFrame.Angles(0, math.pi, 0)
					else
						entrance = room.model:FindFirstChild('ToChunk:'..chunk.id)
						if entrance then
							cframe = entrance.CFrame * CFrame.new(0, 3, -3.5)
						end
					end
					wait(1)
				end
				pcall(function() -- for those who save in spawn box and were *not* indoors OR were indoors and got the same LocalIndoorsOrigin
					if chunkId == 'mining' or _p.Region.FromPart(_p.storage.Models.SpawnRegion):CastPoint(cframe.p) then
						if indoors then
							indoorsFix()
						else
							--					local place = 'PokeCenter'
							--					if chunk.id == 'chunk1' then
							--						place = 'yourhomef1'
							--					end
							--					local door = chunk:getDoor(place) or chunk.doors[1]
							--					cframe = door.CFrame * CFrame.new(0, 0, door.Size.Z + 3)
							_p.Menu.options:getUnstuck(true)
							cframe = nil
							wait(1)
						end
					end
				end)
				pcall(function() -- for those who save in spawn box and were indoors, but got a different LocalIndoorsOrigin
					if not chunk.indoors then return end
					local hit = (workspace:FindPartOnRay(Ray.new(cframe.p, Vector3.new(0, -100, 0))))
					if hit then return end
					indoorsFix()
				end)
				pcall(function()
					if chunkId == 'gym7' then
						local door = chunk:getDoor('C_chunk46')
						if door then
							cframe = door.CFrame * CFrame.new(0, 0, -5)
						end
					end
				end)
				if cframe then Utilities.Teleport(cframe) end
			end

			self.gameBegan = true
			
		end
	end

	function PlayerData:save()
		if not limit(player, 60, 60) then
			return _p.Connection:get('PDS', 'saveGame', self:getEtc())
		end
	end


	return PlayerData end