--SynapseX Decompiler

return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local stepped = game:GetService("RunService").RenderStepped
	local rain = {
		reverbOn = false,
		IndoorReverb = create("SoundGroup")({
			Archivable = false,
			Volume = 1,
			Parent = game:GetService("SoundService"),
			create("EqualizerSoundEffect")({
				HighGain = -10,
				MidGain = -5,
				LowGain = 1,
				Priority = 2,
				Enabled = false
			}),
			create("ReverbSoundEffect")({
				DecayTime = 1.5,
				Density = 1,
				Diffusion = 1,
				DryLevel = -6,
				WetLevel = 0.4,
				Priority = 1,
				Enabled = false
			})
		})
	}
	function rain:start(frame, imageId, ar, velocity)
		ar = ar or 1.3254786450662739
		if not velocity then
			local angle = math.rad(105)
			velocity = Vector2.new(math.cos(angle), math.sin(angle)) * 2
		end
		local img = create("ImageLabel")({
			BackgroundTransparency = 1,
			ImageTransparency = 0.1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(ar, 0, 1, 0)
		})
		if imageId then
			if type(imageId) == "number" then
				imageId = "rbxassetid://" .. imageId
			end
			img.Image = imageId
		else
			img.Image = "rbxassetid://337973384"
			img.ImageColor3 = Color3.new(0.6, 0.7, 1)
		end
		local imgs = {
			img:Clone(),
			img:Clone(),
			img:Clone(),
			img:Clone()
		}
		local pos = Vector2.new(0.5, 0.5)
		local lastTick = tick()
		imgs[1].Parent = frame
		imgs[2].Parent = frame
		local raining = true
		Utilities.fastSpawn(function()
			while raining do
				local now = tick()
				local dt = now - lastTick
				lastTick = now
				local posX = pos.X + dt * frame.AbsoluteSize.Y * velocity.X / frame.AbsoluteSize.X
				local sx = frame.AbsoluteSize.Y * ar / frame.AbsoluteSize.X
				while posX < 0 do
					posX = posX + sx
				end
				pos = Vector2.new(posX, (pos.Y + velocity.Y * dt) % 1)
				imgs[1].Position = UDim2.new(posX, 0, pos.Y - 1, 0)
				imgs[2].Position = UDim2.new(posX, 0, pos.Y, 0)
				local i = 3
				local x = posX
				while x > 0 do
					x = x - sx
					if not imgs[i] then
						imgs[i] = img:Clone()
						imgs[i + 1] = img:Clone()
					end
					imgs[i].Position = UDim2.new(x, 0, pos.Y - 1, 0)
					imgs[i].Parent = frame
					imgs[i + 1].Position = UDim2.new(x, 0, pos.Y, 0)
					imgs[i + 1].Parent = frame
					i = i + 2
				end
				x = pos.X + sx
				while x < 1 do
					if not imgs[i] then
						imgs[i] = img:Clone()
						imgs[i + 1] = img:Clone()
					end
					imgs[i].Position = UDim2.new(x, 0, pos.Y - 1, 0)
					imgs[i].Parent = frame
					imgs[i + 1].Position = UDim2.new(x, 0, pos.Y, 0)
					imgs[i + 1].Parent = frame
					i = i + 2
					x = x + sx
				end
				for j = i, #imgs do
					imgs[j].Parent = nil
				end
				stepped:wait()
			end
		end)
		local obj = {}
		function obj:setTransparency(t)
			img.ImageTransparency = t
			for _, img in pairs(imgs) do
				img.ImageTransparency = t
			end
		end
		function obj:setColor(c)
			img.ImageColor3 = c
			for _, img in pairs(imgs) do
				img.ImageColor3 = c
			end
		end
		function obj:Remove()
			raining = false
			for _, i in pairs(imgs) do
				i:Remove()
			end
		end
		return obj
	end
	function rain:enableNewRain()
		if self.newRainEnabled then
			return
		end
		self.newRainEnabled = true
		local thisThread = {}
		self.rainThread = thisThread
		local lighting = game:GetService("Lighting")
		local sky = lighting:FindFirstChildOfClass("Sky")
		if sky then
			sky.CelestialBodiesShown = false
			sky.StarCount = 0
		end
		lighting.Brightness = 0
		lighting.ExposureCompensation = 0
		lighting.FogColor = Color3.fromRGB(25, 23, 62)
		lighting.OutdoorAmbient = Color3.fromRGB(106, 99, 169)
		lighting.FogEnd = 250
		_p.DataManager:lockClockTime(6.2)
		self.blueFrame = create("Frame")({
			BorderSizePixel = 0,
			BackgroundTransparency = 0.8,
			BackgroundColor3 = Color3.fromRGB(14, 15, 32),
			Size = UDim2.new(1, 0, 1, 36),
			Position = UDim2.new(0, 0, 0, -36),
			Parent = Utilities.backGui
		})
		spawn(function()
			local player = _p.player
			local rainParts = {}
			local nRainParts = 0
			local random = math.random
			local twoPi = math.pi * 2
			local sin, cos = math.sin, math.cos
			local cf = CFrame.new
			local v3 = Vector3.new
			local down = Vector3.new(0, -150, 0)
			local splashOffset = Vector3.new(0, 0.6, 0)
			local xzPlane = Vector3.new(1, 0, 1)
			local DataManager = _p.DataManager
			local baseDrop = create("Part")({
				Anchored = true,
				CanCollide = false,
				Material = Enum.Material.SmoothPlastic,
				Color = Color3.fromRGB(175, 221, 255),
				Transparency = 1,
				Size = Vector3.new(0.15, 2, 0.15),
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				create("Decal")({
					Texture = "rbxassetid://2878049753",
					Face = Enum.NormalId.Back
				})
			})
			local splashLocation = create("Attachment")({
				Parent = workspace.Terrain
			})
			local splashEmitter = create("ParticleEmitter")({
				Color = ColorSequence.new(Color3.fromRGB(205, 232, 255), Color3.fromRGB(124, 139, 157)),
				LightEmission = 0,
				LightInfluence = 0,
				Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0, 0),
					NumberSequenceKeypoint.new(0.56, 2.2, 0.6),
					NumberSequenceKeypoint.new(1, 0, 0)
				}),
				Texture = "rbxassetid://1890069725",
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0, 0),
					NumberSequenceKeypoint.new(0.06, 0.44, 0.09),
					NumberSequenceKeypoint.new(0.1, 0.33, 0.19),
					NumberSequenceKeypoint.new(0.15, 0.36, 0.17),
					NumberSequenceKeypoint.new(0.2, 0.34, 0.15),
					NumberSequenceKeypoint.new(0.33, 0.41, 0.13),
					NumberSequenceKeypoint.new(0.5, 0.44, 0.09),
					NumberSequenceKeypoint.new(0.68, 0.87, 0.04),
					NumberSequenceKeypoint.new(0.9, 0.75, 0),
					NumberSequenceKeypoint.new(1, 1, 0)
				}),
				Acceleration = Vector3.new(0, 0, 0),
				LockedToPart = false,
				Lifetime = NumberRange.new(0.2),
				Rate = 0,
				Enabled = false,
				EmissionDirection = Enum.NormalId.Top,
				Speed = NumberRange.new(1),
				RotSpeed = NumberRange.new(-170),
				Parent = splashLocation
			})
			local camera = workspace.CurrentCamera
			while self.rainThread == thisThread do
				local now = tick()
				local camPos = camera.CFrame.Position
				for i = nRainParts, 1, -1 do
					local rain = rainParts[i]
					local l = (now - rain[3]) * 100
					if l >= rain[4] then
						rainParts[i] = rainParts[nRainParts]
						nRainParts = nRainParts - 1
						rain[1]:Remove()
						if (camPos - rain[5]).Magnitude < 40 then
							splashLocation.Position = rain[5]
							splashEmitter:Emit(1)
						end
					else
						local pos = rain[2] + v3(0, -0.7 - l, 0)
						rain[1].CFrame = cf(pos, pos + (pos - camPos) * xzPlane)
					end
				end
				if nRainParts < 200 then
					local chunkModel = DataManager.currentChunk and DataManager.currentChunk.map 
					if chunkModel then
						do
							local rainFocus = self.rainFocus
							if not self.rainFocus then
								if self.useCameraPosition then
									rainFocus = camPos
								else
									pcall(function()
										local head = player.Character.Head
										rainFocus = head.Position + 1.5 * head.Velocity
									end)
								end
							end
							if rainFocus then
								for i = 1, 4 do
									local r = random() ^ 1.2 * 120 + 4
									local t = random() * twoPi
									local p = rainFocus + v3(r * sin(t), 100, r * cos(t))
									local ray = Ray.new(p, down)
									local hit, pos = workspace:FindPartOnRayWithWhitelist(ray, {chunkModel, game.Workspace.Terrain}, true)
									if hit then
										local drop = baseDrop:Clone()
										drop.Parent = camera
										drop.CFrame = cf(p)
										nRainParts = nRainParts + 1
										rainParts[nRainParts] = {
											drop,
											p,
											now,
											p.Y - pos.Y,
											pos + splashOffset
										}
									end
								end
							end
						end
					end
				end
				stepped:Wait()
			end
			for i = 1, nRainParts do
				rainParts[i][1]:Remove()
			end
			rainParts = nil
		end)
	end
	do
		local indoorReverb = rain.IndoorReverb
		local eq = indoorReverb.EqualizerSoundEffect
		local rv = indoorReverb.ReverbSoundEffect
		local log10 = math.log10
		local function interpolateDecibel(from, to)
			local fromPower = 10 ^ (from / 10)
			local toPower = 10 ^ (to / 10)
			local difPower = toPower - fromPower
			return function(alpha)
				return 10 * log10(fromPower + difPower * alpha)
			end
		end
		local fadeThread
		function rain:fadeIndoorReverbOn(duration)
			if self.reverbOn then
				return
			end
			self.reverbOn = true
			if duration == 0 then
				fadeThread = nil
				eq.HighGain = -10
				eq.MidGain = -5
				eq.LowGain = 1
				eq.Enabled = true
				rv.DryLevel = -6
				rv.WetLevel = 0.4
				rv.Enabled = true
				return
			end
			local thisThread = {}
			fadeThread = thisThread
			if not eq.Enabled then
				eq.HighGain = 0
				eq.MidGain = 0
				eq.LowGain = 0
				eq.Enabled = true
			end
			if not rv.Enabled then
				rv.DryLevel = 0
				rv.WetLevel = -30
				rv.Enabled = true
			end
			local eqHighLerp = interpolateDecibel(eq.HighGain, -10)
			local eqMidLerp = interpolateDecibel(eq.MidGain, -5)
			local eqLowLerp = interpolateDecibel(eq.LowGain, 1)
			local reverbDryLerp = interpolateDecibel(rv.DryLevel, -6)
			local reverbWetLerp = interpolateDecibel(rv.WetLevel, 0.4)
			Utilities.Tween(duration, nil, function(a)
				if fadeThread ~= thisThread then
					return false
				end
				eq.HighGain = eqHighLerp(a)
				eq.MidGain = eqMidLerp(a)
				eq.LowGain = eqLowLerp(a)
				rv.DryLevel = reverbDryLerp(a)
				rv.WetLevel = reverbWetLerp(a)
			end)
		end
		function rain:fadeIndoorReverbOff(duration)
			if not self.reverbOn then
				return
			end
			self.reverbOn = false
			if duration == 0 then
				fadeThread = nil
				eq.Enabled = false
				rv.Enabled = false
				return
			end
			local thisThread = {}
			fadeThread = thisThread
			local eqHighLerp = interpolateDecibel(eq.HighGain, 0)
			local eqMidLerp = interpolateDecibel(eq.MidGain, 0)
			local eqLowLerp = interpolateDecibel(eq.LowGain, 0)
			local reverbDryLerp = interpolateDecibel(rv.DryLevel, 0)
			local reverbWetLerp = interpolateDecibel(rv.WetLevel, -30)
			Utilities.Tween(duration, nil, function(a)
				if fadeThread ~= thisThread then
					return false
				end
				eq.HighGain = eqHighLerp(a)
				eq.MidGain = eqMidLerp(a)
				eq.LowGain = eqLowLerp(a)
				rv.DryLevel = reverbDryLerp(a)
				rv.WetLevel = reverbWetLerp(a)
			end)
			if fadeThread == thisThread then
				eq.Enabled = false
				rv.Enabled = false
			end
		end
	end
	function rain:setupBuildingReverb()
		local chunk = _p.DataManager.currentChunk
		chunk:registerEnterDoorEvent("rainReverbEnable", function(doorId, state)
			spawn(function()
				while state[1] < 4 do
					if state[1] == -1 then
						return
					end
					wait()
				end
				self:fadeIndoorReverbOn(1.5)
				while state[1] < 6 do
					if state[1] == -1 then
						return
					end
					wait()
				end
				game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(148, 148, 148)
				if self.blueFrame then
					self.blueFrame.Visible = false
				end
			end)
		end)
		chunk:registerExitDoorEvent("rainReverbDisable", function(doorId, state)
			game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(106, 99, 169)
			if self.blueFrame then
				self.blueFrame.Visible = true
			end
			spawn(function()
				while state[1] < 1 do
					if state[1] == -1 then
						return
					end
					wait()
				end
				self:fadeIndoorReverbOff(1.5)
			end)
		end)
		if chunk.map:FindFirstChild("TriggerReverbOn") then
			local touchConns = {}
			local function tryTriggerOn(p)
				if not p or p.Parent ~= _p.player.Character then
					return
				end
				rain:fadeIndoorReverbOn(1)
			end
			local function tryTriggerOff(p)
				if not p or p.Parent ~= _p.player.Character then
					return
				end
				rain.rainFocus = nil
				rain:fadeIndoorReverbOff(1)
			end
			for _, ch in ipairs(chunk.map:GetChildren()) do
				if ch.Name == "TriggerReverbOn" then
					local attachment = ch:FindFirstChild("RainPos")
					if attachment then
						do
							local pos = attachment.WorldPosition
							touchConns[#touchConns + 1] = ch.Touched:Connect(function(p)
								if not p or p.Parent ~= _p.player.Character then
									return
								end
								rain.rainFocus = pos
								rain:fadeIndoorReverbOn(1)
							end)
						end
					else
						touchConns[#touchConns + 1] = ch.Touched:Connect(tryTriggerOn)
					end
				elseif ch.Name == "TriggerReverbOff" then
					touchConns[#touchConns + 1] = ch.Touched:Connect(tryTriggerOff)
				end
			end
			if #touchConns > 0 then
				self.reverbTriggerTouchConns = touchConns
			end
		end
		if chunk.indoors then
			self:fadeIndoorReverbOn(0)
			game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(148, 148, 148)
			if self.blueFrame then
				self.blueFrame.Visible = false
			end
		end
	end
	function rain:disableNewRain(fadeTime, leaveClockLocked)
		if not self.newRainEnabled then
			return
		end
		self.newRainEnabled = false
		self.rainThread = nil
		local lighting = game:GetService("Lighting")
		local sky = lighting:FindFirstChildOfClass("Sky")
		if sky then
			sky.CelestialBodiesShown = true
			sky.StarCount = 3000
		end
		local chunk = _p.DataManager.currentChunk
		if chunk then
			chunk:registerEnterDoorEvent("rainReverbEnable", nil)
			chunk:registerExitDoorEvent("rainReverbDisable", nil)
		end
		if self.reverbTriggerTouchConns then
			for _, cn in ipairs(self.reverbTriggerTouchConns) do
				pcall(function()
					cn:Disconnect()
				end)
			end
			self.reverbTriggerTouchConns = nil
		end
		if not leaveClockLocked then
			_p.DataManager:unlockClockTime()
		end
		if fadeTime then
			Utilities.spTween(lighting, "Brightness", 1, fadeTime)
			Utilities.spTween(lighting, "ExposureCompensation", 0.3, fadeTime)
			Utilities.spTween(lighting, "OutdoorAmbient", Color3.fromRGB(148, 148, 148), fadeTime)
			Utilities.spTween(lighting, "FogEnd", 100000, fadeTime)
			do
				local blueFrame = self.blueFrame
				Utilities.spTween(blueFrame, "BackgroundTransparency", 1, fadeTime, nil, nil, function()
					blueFrame:Remove()
				end)
			end
		else
			lighting.Brightness = 1
			lighting.ExposureCompensation = 0.3
			lighting.OutdoorAmbient = Color3.fromRGB(148, 148, 148)
			lighting.FogEnd = 100000
			self.blueFrame:Remove()
		end
		self.blueFrame = nil
	end
	return rain
end
