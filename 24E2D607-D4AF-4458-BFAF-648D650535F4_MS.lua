return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local Weather = {
		isRaining = false, 
		isWindy = false,
		isHailing = false,
		isSnowing = false,
		isFoggy = false,
		isSunny = false,
		isMeteor = false,
		isAurora = false,
		isBlood = false,
		isStorm = false,
		isSpacial = false,
		isOn = false,
	}
	Weather.possibleThunderColors = {
		{--orange fun
			ColorSequenceKeypoint.new(0, Color3.fromRGB(Utilities.hexToRGB('#fc4a1a'))),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(Utilities.hexToRGB('#f7b733')))
		},
		{--sun on the horrizon
			ColorSequenceKeypoint.new(0, Color3.fromRGB(Utilities.hexToRGB('#fceabb'))),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(Utilities.hexToRGB('#f8b500')))
		},
		{--frost
			ColorSequenceKeypoint.new(0, Color3.fromRGB(Utilities.hexToRGB('#000428'))),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(Utilities.hexToRGB('#004e92')))
		},
	}
	Weather.IconSheet = '7533554693'
	Weather.Icons = {
		rain = {
			name = "Heavy Rainfall", 
			color = Color3.fromRGB(90, 128, 209), 
			iconOffset = Vector2.new(1, 1)
		}, 
		seismic = {
			name = "Seismic Activity", 
			color = Color3.fromRGB(158, 84, 66),
			iconOffset = Vector2.new(101, 1)
		}, 	
		wind = {
			name = "Strong Gusts", 
			color = Color3.fromRGB(156, 156, 156), 
			iconOffset = Vector2.new(203, 1)
		},
		hail = {
			name = "Pelting Hailstorm", 
			color = Color3.fromRGB(185, 236, 255), 
			iconOffset = Vector2.new(304, 1)
		},
		fog = {
			name = "Thick Fog", 
			color = Color3.fromRGB(147, 147, 147), 
			iconOffset = Vector2.new(405, 1)
		},
		snow = {
			name = "Blinding Snowstorm", 
			color = Color3.fromRGB(255, 255, 255), 
			iconOffset = Vector2.new(506, 1)
		},
		sun = {
			name = "Extreme Heat", 
			color = Color3.fromRGB(255, 255, 0), 
			iconOffset = Vector2.new(607, 1)
		},
		meteor = {
			name = "Meteor Shower", 
			color = Color3.fromRGB(255, 204, 102), 
			iconOffset = Vector2.new(809, 1),
			data = {
				name = 'Deoxys',
				icon = 443,
				location = 'Cosmeos Valley'
			}
		},
		aurora = {
			name = "Northern Lights", 
			color = Color3.fromRGB(119, 255, 170), 
			iconOffset = Vector2.new(910, 1),
			data = {
				name = 'Cresselia',
				icon = 564,
				location = '???' --Change
			}
		},
		blood = { --blood
			name = "Blood Moon", 
			color = Color3.fromRGB(255, 0, 70), 
			iconOffset = Vector2.new(101, 101)
		},
		thunder = { 
			name = "Explosive Thunderstorms", 
			color = Color3.fromRGB(255, 141, 0), 
			iconOffset = Vector2.new(202, 101)
		},
		smog = {
			name = "Toxic Smog", 
			color = Color3.fromRGB(100, 81, 123), 
			iconOffset = Vector2.new(303, 101)
		},
		sand = {
			name = "Savage Sandstorms", 
			color = Color3.fromRGB(205, 201, 0), 
			iconOffset = Vector2.new(404, 101)
		},
		fireworks = {
			name = "Seasonal Fireworks", 
			color = Color3.fromRGB(255, 0, 0), 
			iconOffset = Vector2.new(1, 101)
		},
		spacial = {
			name = "Spacial Anomalies", 
			color = Color3.fromRGB(107, 96, 255), 
			iconOffset = Vector2.new(1, 101)
		},
	}
	Weather.Popup = {
		aurora = {
			name = 'Cresselia',
			icon = 564,
			location = '???', --Change
			pp = true,
		},
		meteor = {
			name = 'Deoxys',
			icon = 443,
			location = 'Cosmeos Valley',
			pp = true,
		}
	}
	--Vector2.new(910, 101) Himtopia was bored
	function Weather:Notification(p37)
		local v190 = _p.NotificationManager:ReserveSlot(0.16, 0.16, 14)	
		local v189 = self.Icons[p37.weatherKind]

		local v191 = Create 'Frame' {
			BorderSizePixel = 0, 
			BackgroundColor3 = Color3.new(.1, .1, .1), 
			Size = UDim2.fromScale(1, 1), 
			Position = UDim2.fromScale(1.1, 0), 
			Parent = v190.gui
		}
		Create("UICorner")({
			Parent = v191,
			CornerRadius = UDim.new(0.08, 0)
		})
		Create("TextLabel")({
			Parent = v191,
			BackgroundTransparency = 1, 
			Size = UDim2.fromScale(0.949, 0.212), 
			Position = UDim2.fromScale(0.02, 0.03), 
			ZIndex = 2, 
			Text = p37.regionName, 
			Font = Enum.Font.GothamBold, 
			TextScaled = true, 
			TextColor3 = Color3.fromRGB(255,255,255)
		})
		Create("TextLabel")({
			Parent = v191,
			BackgroundTransparency = 1, 
			Size = UDim2.fromScale(0.9, 0.142), 
			AnchorPoint = Vector2.new(0.5, 0), 
			Position = UDim2.fromScale(0.5, 0.25), 
			ZIndex = 2, 
			Text = "is now experiencing", 
			Font = Enum.Font.GothamBold, 
			TextScaled = true, 
			TextColor3 = Color3.fromRGB(255,255,255)
		})
		Create("ImageLabel")({
			Parent = v191,
			BackgroundTransparency = 1, 
			Image = "rbxassetid://"..self.IconSheet, --7134985927
			ImageRectSize = Vector2.new(100, 100), 
			ImageRectOffset = v189.iconOffset, 
			SizeConstraint = Enum.SizeConstraint.RelativeYY, 
			Size = UDim2.fromScale(0.322, 0.322), 
			Position = UDim2.fromScale(0.035, 0.391), 
			ZIndex = 2
		})
		Create("TextLabel")({
			Parent = v191,
			BackgroundTransparency = 1, 
			Size = UDim2.fromScale(0.528, 0.322), 
			Position = UDim2.fromScale(0.422, 0.391), 
			ZIndex = 2, 
			Text = v189.name, 
			Font = Enum.Font.GothamBlack, 
			TextScaled = true, 
			TextColor3 = v189.color
		})
		if p37.Poke['name'] then
			Create("TextLabel")({
				Parent = v191,
				BackgroundTransparency = 1, 
				Size = UDim2.fromScale(0.636, 0.096), 
				Position = UDim2.fromScale(0.347, 0.747), 
				ZIndex = 2, 
				Text = "Acting Strangely:", 
				Font = Enum.Font.GothamBold, 
				TextScaled = true, 
				TextColor3 = Color3.fromRGB(255, 255, 255)
			})
			Create("TextLabel")({
				Parent = v191,
				BackgroundTransparency = 1, 
				Size = UDim2.fromScale(0.603, 0.128), 
				Position = UDim2.fromScale(0.347, 0.843), 
				ZIndex = 2, 
				Text = p37.Poke['name'], 
				Font = Enum.Font.GothamBlack, 
				TextScaled = true, 
				TextColor3 = Color3.fromRGB(200,200,200), 
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local v192 = _p.Pokemon:getIcon(p37.Poke['icon']-1, false)
			v192.SizeConstraint = Enum.SizeConstraint.RelativeYY
			v192.Size = UDim2.fromScale(0.2986666666666667, 0.224)
			v192.AnchorPoint = Vector2.new(0.125, 0)
			v192.Position = UDim2.fromScale(0.071, 0.747)
			v192.ZIndex = 4
			v192.Parent = v191
		end
		Utilities.spTween(v191, "Position", UDim2.fromScale(-0.1, 0), 0.5, "easeOutCubic")
		wait(6)
		Utilities.spTween(v191, "Position", UDim2.fromScale(1.1, 0), 0.5, "easeOutCubic")
		wait(.6)
		v190:Remove()
	end
	
	function Weather:StartHail(model)
		if self.isHailing then
			return
		end
		self.isHailing = true
		
		_p.Overworld.Weather.Hail:enableHail(model)
	end
	function Weather:EndHail()
		if not self.isHailing then
			return
		end
		self.isHailing = false
		_p.Overworld.Weather.Hail:disableHail()
		
	end
	function Weather:StartAurora()
		if self.isAurora then
			return
		end
		self.isAurora = true
		
		local cf = nil
		if _p.DataManager.currentChunk then
			cf = _p.DataManager.currentChunk.map:GetBoundingBox()
		end
		_p.Overworld.Weather.NorthernLights:enableNorthernLights(cf)
	end
	function Weather:EndAurora()
		if not self.isAurora then
			return
		end
		self.isAurora = false
		_p.Overworld.Weather.NorthernLights:disableNorthernLights()
		
	end
	function Weather:StartFireworks()
		if self.isFireworks then
			return
		end
		self.isFireworks = true
		_p.Overworld.Weather.Fireworks:startFireworks()

	end
	function Weather:EndFireworks()
		if not self.isFireworks then
			return
		end
		self.isFireworks = false
		_p.Overworld.Weather.Fireworks:endFireworks()

	end
	function Weather:StartBloodMoon()
		if self.isBlood then
			return
		end
		self.isBlood = true
		_p.Overworld.Weather.BloodMoon:enableBloodMoon()

	end
	function Weather:EndBloodMoon()
		if not self.isBlood then
			return
		end
		self.isBlood = false
		_p.Overworld.Weather.BloodMoon:disableBloodMoon()
		
	end
	function Weather:StartSnow()
		if self.isSnowing then
			return
		end
		self.isSnowing = true
		
		_p.Overworld.Weather.Snow:enableSnow()

	end
	function Weather:EndSnow()
		if not self.isSnowing then
			return
		end
		self.isSnowing = false
		_p.MusicManager:popMusic('SnowMusic', 1)
		_p.Overworld.Weather.Snow:disableSnow()
		--_p.DataManager:unlockClockTime()
	end
	function Weather:StartShower()
		if self.isMeteor then
			return
		end
		self.isMeteor = true
		
		_p.DataManager:lockClockTime(0)
		_p.Overworld.Weather.Meteor:Enable(math.random(1, 5))--Make color decided on server :)
		spawn(function()
			_p.Overworld.Weather.Meteor:bigCrash('chunk51')
		end)
	end
	function Weather:EndShower()
		if not self.isMeteor then
			return
		end
		self.isMeteor = false
		_p.MusicManager:popMusic('MeteorMusic', 1)
		_p.Overworld.Weather.Meteor:Disable()
		_p.DataManager:unlockClockTime()
		local currentChunk = _p.DataManager.currentChunk
		if currentChunk and not currentChunk.Removeing then
			pcall(function()
				currentChunk.map:FindFirstChild("MeteorSite"):Remove()
			end)
		end
	end
	function Weather:StartFog(variant)
		if self.isFoggy then
			return
		end
		self.isFoggy = true
		_p.Overworld.Weather.Fog:enableFog(2.5, nil, variant)
	end
	function Weather:EndFog()
		if not self.isFoggy then
			return
		end
		self.isFoggy = false
		_p.Overworld.Weather.Fog:disableFog(2.5)
	end
	function Weather:StartRain(plc)
		if self.isRaining then
			return
		end
		self.isRaining = true
		
		_p.Overworld.Weather.Rain:enableNewRain(plc, 1.5)
		game.Workspace.Terrain.WaterWaveSize = 0 -- . 5
		game.Workspace.Terrain.WaterWaveSpeed = 0 --10
		_p.Overworld.Weather.Rain:setupBuildingReverb()
	end
	function Weather:EndRain(p4)
		if not self.isRaining then
			return
		end
		self.isRaining = false
		game.Workspace.Terrain.WaterWaveSize = .5
		game.Workspace.Terrain.WaterWaveSpeed = 10		
		local v7
		if not p4 then
			v7 = 1.5
		end
		_p.Overworld.Weather.Rain:disableNewRain(v7)
		
	end
	
	function Weather:StartWind()
		if Weather.isWindy then
			return
		end
		Weather.isWindy = true
		
		_p.Clouds:setCloudSpeed(3)
		local u1 = nil
		pcall(function()
			u1 = _p.DataManager.currentChunk.map.Clouds.CFrame.RightVector 
		end)
		_p.Overworld.Weather.WindEffect:Enable(u1)
	end
	function Weather:EndWind(p8)
		if not self.isWindy then
			return
		end
		self.isWindy = false		
		_p.Clouds:setCloudSpeed(1)
		_p.Overworld.Weather.WindEffect:Disable(p8)
		
	end
	
	function Weather:StartSandstorm()
		if Weather.isStorm then
			return
		end
		Weather.isStorm = true
		_p.Overworld.Weather.Sandstorm:enableStorm()
	end
	function Weather:EndSandstorm(p8)
		if not self.isStorm then
			return
		end
		self.isStorm = false		
		_p.Overworld.Weather.Sandstorm:disableStorm()

	end
	function Weather:StartSpacial()
		if self.isSpacial then
			return
		end
		self.isSpacial = true
		_p.Overworld.Weather.Spacial:setupSpacial()
	end
	function Weather:EndSpacial()
		if not self.isSpacial then
			return
		end
		self.isSpacial = false;
		_p.Overworld.Weather.Spacial:removeSpacial()
	end;	
	Weather.Rain = require(script.Rain)(_p)
	Weather.WindEffect = require(script.WindEffect)(_p)
	Weather.Fog = require(script.Fog)(_p)
	Weather.Meteor = require(script.Meteor)(_p)
	Weather.Snow = require(script.Snow)(_p)
	Weather.Hail = require(script.Hail)(_p)
	Weather.NorthernLights = require(script.NorthernLights)(_p)
	Weather.BloodMoon = require(script.BloodMoon)(_p)
	Weather.Sandstorm = require(script.Sandstorm)(_p)
	Weather.Fireworks = require(script.Fireworks)(_p)
	Weather.Spacial = require(script.Spacial)(_p)

	return Weather
end