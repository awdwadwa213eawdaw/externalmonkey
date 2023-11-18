return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local ContextActionService = game:GetService("ContextActionService")
	local RunService = game:GetService("RunService")
	local Debris = game:GetService("Debris")

	local noY = Vector3.new(1, 0, 1)
	local randomNew = Random.new()

	local Fireworks = {
		isEnabled = false,
	}
	local fireworkData = {
		colors = {
			Color3.fromRGB(255, 0, 0),
			Color3.fromRGB(0, 255, 0),
			Color3.fromRGB(0, 0, 255),
			Color3.fromRGB(255, 255, 0),
			Color3.fromRGB(0, 255, 255),
			Color3.fromRGB(255, 0, 255),
		},
		chunkRad = {

		},
		types = {
			'classic',
			'fan',
			'display'
		}
	}
	local function getRNGVector()
		local currentChunk = _p.DataManager.currentChunk
		local chunkID = 'chunk1'
		if currentChunk then
			chunkID = currentChunk.id
		end

		local random = math.rad(math.random(1,360))
		local randomCF = fireworkData.chunkRad[chunkID] or random 
		return Vector3.new(-math.sin(randomCF), 0, -math.cos(randomCF))
	end
	local function flare(pos, vel, floaty, timer)
		local point = Create('Part')({
			Name = 'FireworkBS',
			formFactor = "Custom",
			CFrame = CFrame.new(pos) * CFrame.Angles(math.pi, 0, 0),
			Size = Vector3.new(.4, .4, .4),
			Transparency = 1,
			CanCollide = false,
			Velocity = vel
		})
		local color = fireworkData.colors[math.random(1, #fireworkData.colors)]
		local particles = {}
		local sparkColors = {
			Color3.fromRGB(255, 255, 0),
			Color3.fromRGB(0, 0, 0),
			Color3.fromRGB(255, 255, 0),
			Color3.fromRGB(0, 0, 0),
		}
		for i=1, 4 do
			particles[#particles+1] = Create('Sparkles')({
				Name = 'Sparkle',
				SparkleColor = sparkColors[i],
				Parent = point
			})
		end
		particles[#particles+1] = Create("Fire") ({
			Color = Color3.new(1 ,1, .5),
			SecondaryColor=Color3.new(1, 1, 1),
			Heat =  25,
			Parent = point
		})
		particles[1].SparkleColor = color
		particles[3].SparkleColor = color
		particles[5].Color = color

		if floaty > 0 then
			Create('BodyForce')({
				force = Vector3.new(0, point:GetMass()*196.2*floaty,0),
				Parent = point
			})
		end
		point.Parent = workspace.Particles
		Debris:AddItem(point, timer+3)

		delay(timer, function()
			for _, v in pairs(particles) do
				if v and v.Parent and v.Enabled then
					v.Enabled=false
				end
			end
		end)
		return point
	end

	local bangsounds={160248459, 160248479, 160248493}
	local function makerandombang()
		local sound = Create('Sound')({
			Volume=1,
			Pitch=.8+math.random()*.4,
			SoundId="http://www.roblox.com/asset/?id="..bangsounds[math.random(1,3)],
		})
		Debris:AddItem(sound,10)
		return sound
	end

	function Fireworks:makeFireworkEffect(cf, specific)
		if not specific then
			specific = fireworkData.types[math.random(1, #fireworkData.types)]
		end
		local point = Create('Part')({
			Name = 'Firework_'..specific,
			Position = cf,
			Size = Vector3.new(.4, .4, .4),
			Transparency = 1,
			CanCollide = false,
			Anchored = true,
		})
		local bang
		local flareObj
		if specific == 'classic' then
			flareObj = flare(point.Position,(CFrame.Angles(math.pi/2, 0, 0) * CFrame.Angles((math.random()-.5)*.5, (math.random()-.5)*.5, 0)).lookVector*100,.8,2)
			flareObj.RotVelocity=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*100
			bang = makerandombang()
			bang.Parent=flareObj
			task.wait()
			Debris:AddItem(Create("Sound")({
				SoundId = 'rbxassetid://160248505', 
				RollOffMode = Enum.RollOffMode.LinearSquare, 
				RollOffMinDistance = 40, 
				RollOffMaxDistance = 500, 
				Volume = 2, 
				Parent = point
			}):Play(), 7)
			if flareObj and bang then
				bang:Play()
				for i=1, 7 do
					local f=flare(flareObj.Position,(point.CFrame*CFrame.Angles((i/7)*math.pi*2,0,0)).lookVector*20,.95,3,clr)
					if i==7 then
						local sound = Create("Sound")({
							SoundId = 'rbxassetid://160247625', 
							Pitch = .5, 
							Volume = 1, 
							Parent = f
						})
						task.wait()
						if sound then
							sound:Play()
						end
					end
				end

			end
		elseif specific == 'fan' then
			for i=1,7 do
				flareObj = flare(point.Position,(point.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles((((i-1)/6)-.5)*1.5,0,0)).lookVector*30,.95,2.)
				Create("Sound") ({
					Pitch = .5+(math.random()*.1),
					SoundId = "http://www.roblox.com/asset/?id=160248604",
					Parent = flareObj,
				}):Play()
				task.wait(.3)
			end
			task.wait(.3)
			for i=1,7 do
				flareObj = flare(point.Position,(point.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(((1-((i-1)/6))-.5)*1.5,0,0)).lookVector*30,.95,2)
				Create("Sound") ({
					Pitch = .5+(math.random()*.1),
					SoundId = "http://www.roblox.com/asset/?id=160248604",
					Parent = flareObj,
				}):Play()
				task.wait(.3)
			end
		elseif specific == 'display' then
			flare(point.Position,(point.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(.8,0,0)).lookVector*20,.95,2)
			flare(point.Position,(point.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(-.8,0,0)).lookVector*20,.95,2)
			wait(.5)
			flare(point.Position,(point.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(.5,0,0)).lookVector*25,.95,2)
			flare(point.Position,(point.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(-.5,0,0)).lookVector*25,.95,2)
			wait(.5)
			flare(point.Position,(point.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(.25,0,0)).lookVector*32,.95,2)
			flare(point.Position,(point.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(-.25,0,0)).lookVector*32,.95,2)
			wait(1)
			local flare1=flare(point.Position,Vector3.new(0,100,0),.8,1)
			local b = Create("Sound")({
				Volume=1,
				SoundId="http://www.roblox.com/asset/?id=160248522",
				Parent=flare1
			})
			Debris:AddItem(b, 10)
			wait(1)
			if flare1 and b then
				b:Play()
				for i=1, 5 do
					flare(flare1.Position,(point.CFrame*CFrame.Angles((i/5)*math.pi*2,0,0)).lookVector*20,.95,2)
				end
			end
		end
		point:Remove()
	end

	function Fireworks:findSpawnPoint()
		local cf
		local CurrentCamera = workspace.CurrentCamera
		pcall(function()
			if not _p.Battle.currentBattle then
				cf = _p.player.Character.HumanoidRootPart.Position
				return
			end
			cf = _p.Battle.currentBattle.CoordinateFrame1.Position + (CurrentCamera.CFrame.LookVector * noY).Unit * 100 + Vector3.new(0, -50, 0)
		end)
		if not cf then return end
		local Unit = (getRNGVector() + Vector3.new(0, randomNew:NextNumber(-0.2, -0.4), 0)).Unit
		local rngPos = cf + Vector3.new(randomNew:NextNumber(-200, 200), 35, randomNew:NextNumber(-200, 200)) - Unit * 250
		local CFrameOnMatrix = CFrame.fromMatrix(rngPos + Unit, -Unit, ((rngPos + Unit) - CurrentCamera.CFrame.Position).Unit:Cross(-Unit).Unit)

		return CFrameOnMatrix
	end

	local runningFireworks = false
	function Fireworks:startFireworks()
		if self.isEnabled then
			return
		end
		_p.DataManager:lockClockTime(0)
		self.isEnabled = true
		if not runningFireworks then
			runningFireworks = true
			local osClock = os.clock()
			RunService:BindToRenderStep("SeasonalEvent", Enum.RenderPriority.Last.Value, function()
				if osClock+(1) < os.clock() then
					osClock = os.clock()
					local cf = self:findSpawnPoint()
					if not cf then warn('No CFRAME') return end
					self:makeFireworkEffect(cf.Position)
				end
			end)
		end
	end
	function Fireworks:endFireworks()
		if not self.isEnabled then
			return
		end
		self.isEnabled = false
		runningFireworks = false
		RunService:UnbindFromRenderStep("SeasonalEvent");
	end
	return Fireworks
end