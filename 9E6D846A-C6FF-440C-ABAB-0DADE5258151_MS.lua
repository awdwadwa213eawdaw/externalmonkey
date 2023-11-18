return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local legendarymusic = 10723844284
	
	return {
		hackableShrubbery = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.DataManager:preload(316598829)
			local trunk = model.CutKit.Main
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(trunk.Position) end)
			local cutter, done
			Utilities.fastSpawn(function()
				cutter = _p.Connection:get('PDS', 'getCutter')
				done = true
			end)
			chat:say('This tree looks like it can be cut down.')
			while not done do wait() end
			if not cutter or not chat:say('[y/n]Would you like ' .. cutter .. ' to use Cut?') then
				_p.MasterControl.WalkEnabled = true
				return
			end
			chat:say(cutter .. ' used Cut!')
			pcall(function() model['#InanimateInteract']:Remove() end)
			local slashEffect = model.CutKit.SlashEffect
			local size = slashEffect.Size
			slashEffect.Parent = model
			local playerPos = _p.player.Character.HumanoidRootPart.CFrame
			local cf = CFrame.new(trunk.Position, Vector3.new(playerPos.X, trunk.CFrame.Y, playerPos.Z))
			Utilities.sound(316598829, nil, nil, 5)
			Utilities.Tween(.35, nil, function(a)
				slashEffect.Size = size*(0.2+1.2*math.sin(a*math.pi))
				slashEffect.CFrame = cf * CFrame.new(-3+6*a, 3-6*a, -2.5) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.pi/4, 0, 0)
			end)
			slashEffect:Remove()
			model.Main:Remove()
			Utilities.MoveModel(trunk, cf)
			create 'Weld' {
				Part0 = model.CutKit.Top,
				Part1 = model.TreePart,
				C0 = CFrame.new(),
				C1 = model.TreePart.CFrame:inverse() * model.CutKit.Top.CFrame,
				Parent = model.CutKit.Top,
			}
			model.TreePart.Anchored = false
			model.CutKit.Top.Anchored = false
			local force = create 'BodyForce' {
				Force = -cf.lookVector * 5000,
				Parent = model.CutKit.Top,
			}
			local force2 = create 'BodyForce' {
				Force = -cf.lookVector * 9000,
				Parent = model.TreePart,
			}
			wait(.5)
			--		pcall(function()
			--			if model.Parent.Name == 'ChristmasTrees' then
			--				local cutall = true
			--				for _, tree in pairs(model.Parent:GetChildren()) do
			--					if tree:FindFirstChild('#InanimateInteract') then
			--						cutall = false
			--						break
			--					end
			--				end
			--				if cutall then
			--					_p.Events.onCutAllChristmasTrees()
			--				end
			--			end
			--		end)
			_p.MasterControl.WalkEnabled = true
			force:Remove()
			force2:Remove()
			wait(1)
			Utilities.Tween(1, nil, function(a)
				model.CutKit.Top.Transparency = a
				model.CutKit.Base.Transparency = a
				model.TreePart.Transparency = a
			end)
			model.CutKit:Remove()
			model.TreePart:Remove()
		end,
		
		MarshadowShadow = function(model)
			if _p.PlayerData.completedEvents.MarshBattle then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chunk = _p.DataManager.currentChunk
			if chunk and chunk.map:FindFirstChild('MarshadowDecal') then
				spawn(function() _p.MasterControl:LookAt(model.Body.Position) end)
				Utilities.exclaim(_p.player.Character.Head)
				local decals = model.Body.Srf
				--
				local marshModel = chunk.map.Marshadow
				local pos = marshModel.Root.Position
				Utilities.MoveModel(marshModel.Root, (marshModel.Root.CFrame-Vector3.new(pos.X,0,pos.Z))+Vector3.new(model.Main.Position.X,0,model.Main.Position.Z))
				--spawn(function()
				local ogframe = marshModel.Root.CFrame
				Utilities.Tween(3, nil, function(a)
					decals.Body.ImageTransparency = 0+a
					decals.Eyes.ImageTransparency = 0+a
					decals.Eyes.Size = UDim2.new(.3, 0, .3-(.3*a), 0)
					delay(.2, function() Utilities.MoveModel(marshModel.Root, ogframe + Vector3.new(0,0+(3.1*a),0)) end)
				end)
				task.wait(1)
				--end)
				--
				delay(3, function() 
					model:remove()
					_p.cameraEffect:shadowVoid(false)
					_p.Overworld.MarshVoid.enabled = false 
					marshModel:remove()
				end)
				_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Marshadow, {cantRun = true, musicId = legendarymusic})--jb
				_p.MasterControl.WalkEnabled = false
				

				_p.NPCChat.bottom = false
				_p.MasterControl.WalkEnabled = true	
			end
		end,
		
		BoulderSmash = function(model)

			if not _p.MasterControl.WalkEnabled then return end
			--        _p.DataManager:preload(TODO)
			local chat = _p.NPCChat
			spawn(function()
				_p.Menu:disable()
			end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local main = model.Main
			spawn(function() _p.MasterControl:LookAt(main.Position) end)
			local smasher, rm, enc, done
			Utilities.fastSpawn(function()
				smasher, rm, enc = _p.Connection:get('PDS', 'getSmasher')
				done = true
			end)
			chat:say('It\'s a huge pile of rocks.', 'A pokemon may be able to break it.')
			while not done do wait() end
			if not smasher or not rm or not chat:say('[y/n]Would you like ' .. smasher .. ' to use Rock Smash?') then
				_p.MasterControl.WalkEnabled = true
				return
			end
			_p.PlayerData:completeEvent('CatacSmash')
			chat:say(smasher .. ' used Rock Smash!')
			local Smashings = model.Flung:GetChildren()




			for i, child in ipairs(Smashings) do
				child.Anchored = false
			end


			wait(1)
			model:Remove()

			spawn(function()
				_p.Menu:enable()
			end)
			_p.MasterControl.WalkEnabled = true
		end,
		durantHill = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			local digger, done
			Utilities.fastSpawn(function()
				digger = _p.Connection:get('PDS', 'getDigger')
				done = true
			end)
			chat:say('This pile of dirt seems to have been made by a pokemon.')
			if not digger or not chat:say('[y/n]Would you like ' .. digger .. ' to use Dig?') then
				_p.MasterControl.WalkEnabled = true
				return
			end
			chat:say(digger .. ' used Dig!')
			pcall(function() model['#InanimateInteract']:Remove() end)
			model.Part:Remove()
			model.Main.Transparency = 1.0
			model.Main.CanCollide = false
			local smoke = create 'Smoke' {
				Color = BrickColor.new('Brown').Color,
				Parent = model.Main,
			}
			delay(10, function()
				smoke:Remove()
			end)
			wait(.5)
			smoke.Enabled = false
			wait(1.5)
			if math.random(10) <= 3 then
				_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Anthill, {battleSceneType = 'Safari'})
			end
			_p.MasterControl.WalkEnabled = true
		end,

		spiritombWell = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)

			if _p.PlayerData.hasOddKeystone then
				if chat:say('Whispers can be heard coming from deep within the well.',
					'The Odd Keystone in your Bag is rumbling...',
					'[y/n]Toss the Odd Keystone into the well?')
				then
					chat:say('You tossed the Odd Keystone into the well.')
					model.SmokePart.Smoke.Enabled = true
					local cf = CFrame.new(model.Main.Position + Vector3.new(0, -model.Main.Size.X/2+.1, 0))
					for i = 1, 3 do
						local pulse = create 'Part' {
							Transparency = 1,
							Anchored = true,
							CanCollide = false,
							Parent = model,
						}
						local sg = create 'SurfaceGui' {
							CanvasSize = Vector2.new(600, 600),
							Face = Enum.NormalId.Top,
							Adornee = pulse,
							Parent = pulse,
						}
						local image = create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://6604524713',
							ImageColor3 = Color3.new(.5, 0, 1),
							Size = UDim2.new(1.0, 0, 1.0, 0),
							Parent = sg,
						}
						spawn(function()
							Utilities.Tween(1.5, nil, function(a)
								pulse.Size = Vector3.new(5+a*10, 0.2, 5+a*10)
								pulse.CFrame = cf
								if a > .75 then
									image.ImageTransparency = (a-.75)*4
								end
							end)
							pulse:Remove()
						end)
						wait(1)
					end
					delay(5, function()
						model.SmokePart.Smoke.Enabled = false
					end)
					_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Well, {battleSceneType = 'SpiritombWell'})
					_p.PlayerData.hasOddKeystone = _p.Connection:get('PDS', 'hasOKS')
				end
			else
				chat:say('This well looks really old...')
			end
			_p.MasterControl.WalkEnabled = true
		end,

		headbuttablePalmTree = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.DataManager:preload(330262909)-- preload sound
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			local headbutter, done
			Utilities.fastSpawn(function()
				headbutter = _p.Connection:get('PDS', 'getHeadbutter')
				done = true
			end)
			chat:say('It\'s a large palm tree that could possibly be the home to small pokemon.')
			while not done do wait() end
			if headbutter and chat:say('[y/n]Would you like ' .. headbutter .. ' to use Headbutt?') then
				chat:say(headbutter .. ' used Headbutt!')
				local p = model.Main.Position + Vector3.new(0, -model.Main.Size.Y/2+0.8, 0)
				local cf = CFrame.new(p, p + (p-_p.player.Character.HumanoidRootPart.Position)*Vector3.new(1, 0, 1))
				local cfs = {}
				for _, ch in pairs(model:GetChildren()) do
					if ch:IsA('BasePart') then
						cfs[ch] = cf:toObjectSpace(ch.CFrame)
					end
				end
				local pow = _p.storage.Models.Misc.Pow:Clone()
				pow.Parent = workspace
				local ps = pow.Size*.7
				pow.CFrame = cf * CFrame.new(0, model.Main.Size.Y/2, model.Main.Size.Z/2+.4) * CFrame.Angles(0, math.pi/2, 0)
				local particlePart = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(10, 1, 10),
					CFrame = model.Main.CFrame * CFrame.new(0, 25, 0),
					Parent = workspace,
				}
				local emitter = create 'ParticleEmitter' {
					EmissionDirection = Enum.NormalId.Bottom,
					Color = ColorSequence.new(BrickColor.new('Bright green').Color),
					Lifetime = NumberRange.new(26),
					Rate = 12,
					Speed = NumberRange.new(5),
					RotSpeed = NumberRange.new(-50, 50),
					Texture = 'rbxassetid://6607853828',--330258890
					Parent = particlePart,
				}
				game:GetService('Debris'):AddItem(particlePart, 11)
				Utilities.sound(330262909, nil, nil, 5)
				Utilities.Tween(1.25, nil, function(a)
					if pow then
						if a > .4 then
							pow:Remove()
							pow = nil
							emitter.Enabled = false
						else
							if a > .2 then
								pow.Transparency = (a-.2)*5
							end
							pow.Size = ps * (1+a)
							--						pow.CFrame = pcf * CFrame.Angles(a*2, 0, 0)
						end
					end
					local ncf = cf*CFrame.Angles(-math.sin(a*math.pi*2)*.4*(1-a), 0, 0)
					for part, rcf in pairs(cfs) do
						part.CFrame = ncf:toWorldSpace(rcf)
					end
				end)
				wait(1)
				local enc
				pcall(function() enc = _p.DataManager.currentChunk.regionData.PalmTree end)
				if enc and math.random(10) <= 5 then
					_p.Battle:doWildBattle(enc)
				end
			end
			_p.MasterControl.WalkEnabled = true
		end,

		headbuttablePineTree = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.DataManager:preload(330262909)
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			local headbutter, done
			Utilities.fastSpawn(function()
				headbutter = _p.Connection:get('PDS', 'getHeadbutter')
				done = true
			end)
			chat:say('It\'s a tall tree that could possibly be the home to small pokemon.')
			while not done do wait() end
			if headbutter and chat:say('[y/n]Would you like ' .. headbutter .. ' to use Headbutt?') then
				chat:say(headbutter .. ' used Headbutt!')
				local p = model.Main.Position + Vector3.new(0, -model.Main.Size.Y/2+2, 0)
				local cf = CFrame.new(p, p + (p-_p.player.Character.HumanoidRootPart.Position)*Vector3.new(1, 0, 1))
				local cfs = {}
				for _, ch in pairs(model:GetChildren()) do
					if ch:IsA('BasePart') then
						cfs[ch] = cf:toObjectSpace(ch.CFrame)
					end
				end
				local pow = _p.storage.Models.Misc.Pow:Clone()
				pow.Parent = workspace
				local ps = pow.Size*.7
				pow.CFrame = cf * CFrame.new(0, 3.5, model.Main.Size.Z/2+1) * CFrame.Angles(0, math.pi/2, 0)
				local particlePart = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(10, 1, 10),
					CFrame = model.Main.CFrame * CFrame.new(0, 25, 0),
					Parent = workspace,
				}
				local emitter = create 'ParticleEmitter' {
					EmissionDirection = Enum.NormalId.Bottom,
					--				Color = ColorSequence.new(BrickColor.new('Bright green').Color),
					Size = NumberSequence.new(.3),
					Lifetime = NumberRange.new(26),
					Rate = 12,
					Speed = NumberRange.new(5),
					RotSpeed = NumberRange.new(-50, 50),
					Texture = 'rbxassetid://6607855467',
					Parent = particlePart,
				}
				game:GetService('Debris'):AddItem(particlePart, 11)
				Utilities.sound(330262909, nil, nil, 5)
				Utilities.Tween(1.25, nil, function(a)
					if pow then
						if a > .4 then
							pow:Remove()
							pow = nil
							emitter.Enabled = false
						else
							if a > .2 then
								pow.Transparency = (a-.2)*5
							end
							pow.Size = ps * (1+a)
							--						pow.CFrame = pcf * CFrame.Angles(a*2, 0, 0)
						end
					end
					local ncf = cf*CFrame.Angles(-math.sin(a*math.pi*2)*.4*(1-a), 0, 0)
					for part, rcf in pairs(cfs) do
						part.CFrame = ncf:toWorldSpace(rcf)
					end
				end)
				wait(1)
				local enc
				pcall(function() enc = _p.DataManager.currentChunk.regionData.PineTree end)
				if enc and math.random(10) <= 5 then
					_p.Battle:doWildBattle(enc)
				end
			end
			_p.MasterControl.WalkEnabled = true
		end,

		Water = function(_, pos)
			_p.Fishing:OnWaterClicked(pos)
		end,

		SpookyBook = function(model)
			pcall(function() model['#InanimateInteract']:Remove() end)
			local m = Instance.new('Model', model)
			local mm = Utilities.MoveModel
			for _, ch in pairs(model:GetChildren()) do
				if ch.Name == 'Top' then
					ch.Parent = m
				end
			end
			local hinge = model.Hinge
			hinge.Parent = m
			local hcf = hinge.CFrame
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				mm(hinge, hcf * CFrame.Angles(0, -math.pi*0.5*a, 0))
			end)
			local button = model.Button
			local bm = Instance.new('Model', model)
			button.Parent = bm
			button.Name = 'Main'
			create 'StringValue' {
				Name = '#InanimateInteract',
				Value = 'SpookyBookButton',
				Parent = bm,
			}
		end,

		SpookyBookButton = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			local chunk = _p.DataManager.currentChunk
			local room = chunk:topRoom()

			local wardrobe = room.model.Wardrobe
			spawn(function() _p.MasterControl:LookAt(wardrobe.Main.Position) end)

			local cam = workspace.CurrentCamera
			chunk:unbindIndoorCam()
			do
				local startCF = cam.CoordinateFrame
				local p = Vector3.new(wardrobe.Main.Position.X + 10, room.model.Base.Position.Y + room.model.Base.Size.Y/2 + 4.5, wardrobe.Main.Position.Z)
				local angle = math.rad(40)
				local from = p + Vector3.new(0, math.sin(angle), -math.cos(angle))*18
				local endCF = CFrame.new(from, p)
				local lerp = select(2, Utilities.lerpCFrame(startCF, endCF))
				Utilities.Tween(.75, 'easeOutCubic', function(a)
					cam.CoordinateFrame = startCF + (from - startCF.p) * a
				end)
			end

			local main = wardrobe.Main
			local wcf = main.CFrame
			local lhp, rhp, lh, rh = wardrobe.LDoor.Hinge, wardrobe.RDoor.Hinge, wardrobe.LHinge, wardrobe.RHinge
			local mm = Utilities.MoveModel
			Utilities.sound(360064127, .8, nil, 5)
			Utilities.Tween(.75, 'easeOutCubic', function(a)
				mm(main, wcf * CFrame.Angles(math.sin(a*math.pi*2)*-0.1, 0, math.sin(a*math.pi)*0.2))
				mm(lhp, lh.CFrame * CFrame.Angles(0, 3*a, 0))
				mm(rhp, rh.CFrame * CFrame.Angles(0, -3*a, 0))
			end)

			do
				local startCF = cam.CoordinateFrame
				local p = room.model.Base.Position + Vector3.new(0, room.model.Base.Size.Y/2 + 4.5, 0)
				local angle = math.rad(30)
				local from = p + Vector3.new(0, math.sin(angle), -math.cos(angle))*25
				local endCF = CFrame.new(from, p)
				local lerp = select(2, Utilities.lerpCFrame(startCF, endCF))
				Utilities.Tween(.75, 'easeOutCubic', function(a)
					cam.CoordinateFrame = lerp(a)
				end)
			end

			local st = tick()
			local sucking = true
			local endPoint = wardrobe.Main.Position + Vector3.new(0, 2.5, 0)
			local function particle()
				local size = .4 + math.random()*.6
				local part = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					--				FormFactor = Enum.FormFactor.Custom,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,
				}
				local frame = create 'Frame' {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(.7, .7, .7),
					Size = UDim2.new(1.0, 0, 1.0, 0),
					Parent = create 'BillboardGui' {
						Size = UDim2.new(size, 0, size, 0),
						Adornee = part, Parent = part,
					}
				}
				local startRotation = math.random(360)
				local deltaRotation = math.random(-360, 360) * 3
				local startPoint = endPoint + Vector3.new(20 + math.random(10), math.random(-5, 5), math.random(-10, 10))
				local moveVector = endPoint - startPoint
				local duration = 1.5 - math.min(1, (tick() - st)/2)
				Utilities.Tween(duration, 'easeInCubic', function(a)
					if not sucking then return false end
					frame.BackgroundTransparency = 1-a
					frame.Rotation = startRotation + deltaRotation * a
					part.CFrame = CFrame.new(startPoint + moveVector * a)
				end)
				part:Remove()
			end
			local whoosh = Utilities.sound(9056932358)
			spawn(function()
				while sucking do
					spawn(particle)
					wait(.1)
				end
			end)
			wait(2)
			for _, wedge in pairs(room.model.Funnel:GetChildren()) do
				wedge.CanCollide = true
			end
			local hGoal = endPoint + Vector3.new(2, 0, 0)
			local humanoid = Utilities.getHumanoid()
			local psc = humanoid.Changed:connect(function()
				humanoid.PlatformStand = true
			end)
			humanoid.PlatformStand = true
			local hroot = _p.player.Character.HumanoidRootPart
			local force = create 'BodyForce' {
				Parent = hroot,
			}
			local mf = 3000
			Utilities.Tween(.5, 'easeInCubic', function(a)
				force.Force = (hGoal - hroot.Position).unit * mf * a
			end)
			local antigravs = {}
			local function antigrav(obj)
				if obj:IsA('BasePart') then
					table.insert(antigravs, create 'BodyForce' {
						Force = Vector3.new(0, 196.2 * obj:GetMass(), 0),
						Parent = obj,
					})
				end
				for _, ch in pairs(obj:GetChildren()) do
					antigrav(ch)
				end
			end
			antigrav(_p.player.Character)
			local stepped = game:GetService('RunService').RenderStepped
			while hroot.Position.X > hGoal.X do
				stepped:wait()
				force.Force = (hGoal - hroot.Position).unit * mf
				if force.Force.X > 0 then
					force.Force = force.Force * Vector3.new(0, 1, 1)
				end
			end
			force:Remove()
			local bp = create 'BodyPosition' {
				Position = endPoint,
				Parent = hroot,
			}
			spawn(function()
				local v = whoosh.Volume
				Utilities.Tween(1, nil, function(a)
					whoosh.Volume = v * (1-a)
				end)
				whoosh:Remove()
			end)
			Utilities.FadeOut(1, Color3.new(0, 0, 0))
			sucking = false
			Utilities.TeleportToSpawnBox()
			chunk:popSubRoom(true)
			room = chunk:stackSubRoom('HMUpperHall', chunk:topRoom().model.SubRoom, true)
			room = chunk:stackSubRoom('HMBadBedroom', room:getDoor('HMBadBedroom'), true)
			bp:Remove()
			for _, ag in pairs(antigravs) do ag:Remove() end
			local tp = room.model.WardrobeBase.Position + Vector3.new(0, 2.5, 0)
			do
				local p = room.model.Base.Position + Vector3.new(0, room.model.Base.Size.Y/2 + 4.5, 0)
				local angle = math.rad(30)
				local from = p + Vector3.new(0, math.sin(angle), -math.cos(angle))*25
				cam.CoordinateFrame = CFrame.new(from, p)
			end
			wait(1)
			Utilities.FadeIn(1)
			Utilities.Teleport(CFrame.new(tp.x, tp.y, tp.z, 0, 1, 0, 0, 0, 1, 1, 0, 0))
			hroot.RotVelocity = Vector3.new()
			hroot.Velocity = Vector3.new(50, 0, 0)
			do
				local startCF = cam.CoordinateFrame
				local angle = math.rad(40)
				local offset = Vector3.new(0, math.sin(angle), -math.cos(angle))*18
				local lcf = Utilities.lerpCFrame
				Utilities.Tween(.75, 'easeOutCubic', function(a)
					local p = hroot.CFrame * Vector3.new(0, 1.5, 0)
					p = Vector3.new(math.max(room.indoorCamMinX, math.min(room.indoorCamMaxX, p.x)), p.y, p.z)
					local from = p + offset
					cam.CoordinateFrame = select(2, lcf(startCF, CFrame.new(from, p)))(a)
				end)
			end
			chunk:bindIndoorCam()
			_p.MasterControl.WalkEnabled = true
			psc:disconnect()
			humanoid.PlatformStand = false
		end,

		-- Rotom Event Click-Helpers
		HauntedJukebox = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:Remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedJukeboxClicked(model)
			_p.MasterControl.WalkEnabled = true
		end,
		HauntedComputer = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:Remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedComputerClicked(model)
			_p.MasterControl.WalkEnabled = true
		end,
		HauntedToaster = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:Remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedToasterClicked(model)
			_p.MasterControl.WalkEnabled = true
		end,
		HauntedTelevision = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:Remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedTelevisionClicked(model)
			_p.MasterControl.WalkEnabled = true
		end,
		HauntedHairDryer = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:Remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedHairDryerClicked(model)
			_p.MasterControl.WalkEnabled = true
		end,
		HauntedBabyMonitor = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:Remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedBabyMonitorClicked(model)
			_p.MasterControl.WalkEnabled = true
		end,
		HauntedGameBoy = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:Remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedGameBoyClicked(model)
			_p.MasterControl.WalkEnabled = true
		end,

		JirachiMonument = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			chat:say('"Under sky alight with stars shall the wish made upon the pedestal of dreams come true."')
			_p.MasterControl.WalkEnabled = true
		end,

		Pansage = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk14' then return end
			local enc
			pcall(function() enc = chunk.regionData.Sage end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.NPCChat:say(model.Main, 'Sa sa sage!')
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc)
			_p.MasterControl.WalkEnabled = true
		end,

		Pansear = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk14' then return end
			local enc
			pcall(function() enc = chunk.regionData.Sear end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.NPCChat:say(model.Main, 'Sear sear!')
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc)
			_p.MasterControl.WalkEnabled = true
		end,

		Panpour = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk14' then return end
			local enc
			pcall(function() enc = chunk.regionData.Pour end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.NPCChat:say(model.Main, 'Po pour!')
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc)
			_p.MasterControl.WalkEnabled = true
		end,

		--[[ManaphyEgg = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk11' then return end

			--        pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			if _p.Connection:get('GrabManaphyEgg') then
				Utilities.sound(304774035, nil, nil, 8)
				_p.NPCChat:say(_p.PlayerData.trainerName .. ' found an Egg!',
					_p.PlayerData.trainerName .. ' put the Egg in the party.')
			else
				_p.NPCChat:say('It\'s a mysterious pokemon Egg.',
					'There\'s no room in your party for it.')
			end
			_p.MasterControl.WalkEnabled = true
		end,]]--

		Drifloon = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk15' then return end
			local enc
			pcall(function() enc = chunk.regionData.Windmill end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.NPCChat:say(model.Main, 'Floooooon!')
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {battleSceneType = 'DrifWindmill'})
			_p.MasterControl.WalkEnabled = true
		end,

		HoneyTree = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk15' then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			local chat = _p.NPCChat
			local honeyData = _p.PlayerData.honey
			if honeyData then
				if honeyData.status > 1 then
					delay(3, function()
						honeyData.status = 0
						model.SlatheredHoney.Transparency = 1.0
						pcall(function() model.HoneyTeddiursa:Remove() end)
					end)
					_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.HoneyTree)
				elseif honeyData.status == 1 then
					chat:say('There is honey slathered on this tree.')
				else
					chat:say('This tree looks like a good place to slather honey to attract wild pokemon.')
					if honeyData.has then
						if chat:say('[y/n]Would you like to slather some honey?') then
							honeyData.status = 1
							_p.Connection:post('PDS', 'slatherHoney')
							chat:say('You slathered honey on the tree.')
							pcall(function() model.SlatheredHoney.Transparency = .2 end)
						end
					end
				end
			end
			_p.MasterControl.WalkEnabled = true
		end,

		gym4tool = function(model)
			local chat = _p.NPCChat
			if model.Name == 'MeasuringTape' then
				chat:say('It\'s a measuring tape.')
				model:Remove()
				chat:say('This might come in handy.')
				_p.PlayerData:completeEvent('G4FoundTape')
			elseif model.Name == 'Wrench' then
				chat:say('It\'s a wrench with worm gear adjustment.')
				model:Remove()
				chat:say('This might come in handy.')
				_p.PlayerData:completeEvent('G4FoundWrench')
			elseif model.Name == 'Hammer' then
				chat:say('It\'s an ordinary hammer.')
				model:Remove()
				chat:say('This might come in handy.')
				_p.PlayerData:completeEvent('G4FoundHammer')
			end
		end,

		EmptyDumpster = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			chat:say('It\'s a stinky dumpster.')
			_p.MasterControl.WalkEnabled = true
		end,

		FullDumpster = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			pcall(function() model['#InanimateInteract'].Value = 'EmptyDumpster' end)
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 10721129823, startTime = 57.68, duration = 1.24}) end)
			wait(.8)
			spawn(function()
				local lid = model.Lid
				local parts = {}
				local main = lid.Hinge
				local mcf = main.CFrame
				local function index(obj)
					for _, ch in pairs(obj:GetChildren()) do
						if ch:IsA('BasePart') and ch ~= main then
							parts[ch] = mcf:toObjectSpace(ch.CFrame)
						end
					end
				end
				index(lid)
				Utilities.Tween(.7, 'easeOutCubic', function(a)
					local cf = mcf * CFrame.Angles(0, 0, -math.pi*3/2*a)
					for p, rcf in pairs(parts) do
						p.CFrame = cf:toWorldSpace(rcf)
					end
					main.CFrame = cf
				end)
				delay(3, function()
					for p, rcf in pairs(parts) do
						p.CFrame = mcf:toWorldSpace(rcf)
					end
					main.CFrame = mcf
				end)
			end)
			wait(.7)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Dumpster, {battleSceneType = 'Trash'})
			_p.MasterControl.WalkEnabled = true
		end,

--[[	SantaClaus = function(model) -- to make it easy to unify the 3 santas in different chunks
		local santa = _p.DataManager.currentChunk.npcs.Santa
		if not santa or not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		
		local chunkId = model.Parent.Name
		_p.DataManager:preload(576438342, 576461904)
		
		spawn(function() santa:LookAt(_p.player.Character.Head.Position) end)
		spawn(function() _p.MasterControl:LookAt(model.Head.Position) end)
		
		if not _p.PlayerData.completedEvents.BeatSanta then
			if chunkId == 'chunk5' then _p.NPCChat.bottom = true end
			santa:Say('Ho ho ho, look who it is, little '.._p.PlayerData.trainerName..'.',
				'You\'ve been very good this year.', 'Oh what\'s that?',
				'You\'re not here to settle your own account?',
				'You wanna know about the lawyer from Anthian City, eh?',
				'He\'s been very naughty lately.',
				'I went to court a few years ago for a reindeer speeding violation and it was his fault I lost and I had to pay the ticket.',
				'I haven\'t forgiven him since.',
				'I\'ll make a deal with you though, for working so hard to find me.',
				'If you beat me in a battle, I will put him back on the nice list.',
				'I can\'t resist a good battle.')
			_p.NPCChat.bottom = nil
			local win = _p.Battle:doTrainerBattle {
				musicId = 576461904,
				PreventMoveAfter = true,
				vs = {name = 'Santa', id = 576438342, hue = 0, sat = .5, val = .7},
				trainerModel = model,
				num = 120
			}
			
			if win then
				if chunkId == 'chunk5' then _p.NPCChat.bottom = true end
				santa:Say('Well, I made a deal and I\'m a man of my word.',
					'You let that lawyer know that he\'ll be put back on the nice list this year.',
					'You can also let him know that he\'s terrible at his job and charges way too much money.',
					'Anyways, I better be off for now.', 'I\'m very busy this time of year.',
					'Maybe I\'ll see you again next year.')
				_p.NPCChat.bottom = nil
				Utilities.FadeOut(.5)
				santa:Remove()
				wait(.5)
				Utilities.FadeIn(.5)
			end
		end
		-- these all 3 need to be enabled, I think, because we use tag "PreventMoveAfter"
		_p.NPCChat:enable()
		_p.MasterControl.WalkEnabled = true
		spawn(function() _p.Menu:enable() end)
	end,]]

		ShayminEncounter = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk17' then return end
			local enc
			pcall(function() enc = chunk.regionData.Grace end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 10721125929, startTime = 25.60, duration = 1.82}) end)
			_p.NPCChat:say(model.Main, 'Shayyyyy!')
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {musicId = legendarymusic})
			_p.NPCChat:say('Shaymin can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
		end,
		
		mashableMineral = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			--		_p.DataManager:preload(TODO)
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local main = model.Main
			spawn(function() _p.MasterControl:LookAt(main.Position) end)
			local smasher, rm, enc, done
			Utilities.fastSpawn(function()
				smasher, rm, enc = _p.Connection:get('PDS', 'getSmasher')
				done = true
			end)
			chat:say('It\'s a cracked boulder.', 'A pokemon may be able to break it.')
			while not done do wait() end
			if not smasher or not rm or not chat:say('[y/n]Would you like ' .. smasher .. ' to use Rock Smash?') then
				_p.MasterControl.WalkEnabled = true
				return
			end
			local isKey = model.Name == 'KeyRockSmash'
			chat:say(smasher .. ' used Rock Smash!')
			--		pcall(function() model['#InanimateInteract']:Remove() end)

			local cf = main.CFrame
			local scale = main.Size.Magnitude / 14.847123146057
			--		Utilities.sound(TODO, nil, nil, 5)
			Utilities.ScaleModel(rm.Main, scale)
			Utilities.MoveModel(rm.Main, cf)
			rm.Main:Remove()--rm.Main.Transparency = 1; rm.Main.Size = Vector3.new(1,1,1); rm.Main.CanCollide = true--
			model:Remove()
			rm.Parent = workspace
			for _, p in pairs(rm:GetChildren()) do
				if p:IsA('BasePart') then
					p.Anchored = false
					local dir = (p.Position-cf.p+Vector3.new(0,1,0)).unit
					p.Velocity = dir * 20
					local force = create 'BodyForce' {
						Force = dir * 50 * p:GetMass(),
						Parent = p
					}
					delay(.25, function() force:Remove() end)
				end
			end
			wait(1)
			Utilities.Tween(.5, nil, function(a)
				for _, p in pairs(rm:GetChildren()) do
					if p:IsA('BasePart') then
						p.Transparency = a
					end
				end
			end)
			rm:Remove()
			if enc and not isKey then
				_p.Battle:doWildBattle(enc)
			else
				_p.MasterControl.WalkEnabled = true
			end
		end,

		jewelStand = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			local events = _p.PlayerData.completedEvents
			if not events.RJO then
				chat:say('It\'s a column with strange indentations.', 'It is unclear what purpose it serves.')
			else
				if events.RJO and not events.RJP then
					spawn(function() _p.PlayerData:completeEvent('RJP') end)
					chat:say('You placed the King\'s Red Jewel in the slot on the column.')
					model.RedJewel.Transparency = 0
					-- TODO: rumble sound/camera?
					chat:say('A rumble can be heard from deep within the ruins.')
				elseif events.GJO and not events.GJP then
					spawn(function() _p.PlayerData:completeEvent('GJP') end)
					chat:say('You placed the King\'s Green Jewel in the slot on the column.')
					model.GreenJewel.Transparency = 0
					-- TODO: rumble sound/camera?
					chat:say('A rumble can be heard from deep within the ruins.')
				elseif events.PJO and not events.PJP then
					spawn(function() _p.PlayerData:completeEvent('PJP') end)
					chat:say('You placed the King\'s Purple Jewel in the slot on the column.')
					model.PurpleJewel.Transparency = 0
					-- TODO: rumble sound/camera?
					chat:say('A rumble can be heard from deep within the ruins.')
				elseif events.BJO and not events.BJP then
					spawn(function() _p.PlayerData:completeEvent('BJP') end)
					chat:say('You placed the King\'s Blue Jewel in the slot on the column.')
					model.BlueJewel.Transparency = 0
					-- TODO: rumble sound/camera?
					chat:say('A rumble can be heard from somewhere else in the ruins.')
				end
			end
			_p.MasterControl.WalkEnabled = true
		end,

		restartPuzzleJ = function()
			-- implemented in PuzzleJ module
		end,

		ancientSarcophagus = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			pcall(function() model['#InanimateInteract']:Remove() end)
			--		spawn(function() _p.PlayerData:completeEvent('BJO') end)
			local main = model.Main
			local lidcf = model.LidEndLocation.CFrame
			model.LidEndLocation:Remove()
			local mcf = main.CFrame
			Utilities.Teleport(CFrame.new(mcf * Vector3.new(3.5, 1, 0), mcf.p))
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = CFrame.new(mcf * Vector3.new(4, 10, 6), mcf.p)
			Utilities.Tween(2, nil, function(a)
				Utilities.MoveModel(main, mcf * CFrame.new(-1.8*a, 0, 0))
			end)
			local lerp = select(2, Utilities.lerpCFrame(main.CFrame, lidcf))
			Utilities.Tween(.4, 'easeInCubic', function(a)
				Utilities.MoveModel(main, lerp(a))
			end)
			wait(1)
			_p.NPCChat:say(_p.PlayerData.trainerName .. ' found one of the King\'s Jewels!',
				'It glimmers a soothing blue color.')
			local chunk = _p.DataManager.currentChunk
			local map = chunk.map
			map.BlueJewel:Remove()
			wait(.5)
			Utilities.lookBackAtMe()

			local players = game:GetService('Players')
			local cn; cn = map.MummyBattleTrigger.Touched:connect(function(p)
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
				cn:disconnect()
				_p.Events.onActivateMummy(map.Mummy)
			end)

			_p.MasterControl.WalkEnabled = true
		end,

		vicSeal = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			local main = model.Main
			local mcf = main.CFrame
			pcall(function() model['#InanimateInteract']:Remove() end)
			Utilities.Teleport(mcf * CFrame.new(0, 2.5, 8))
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = CFrame.new(mcf.p + Vector3.new(9, 7, -7), mcf.p + Vector3.new(0, 4, 0))

			_p.MusicManager:stackMusic(legendarymusic, 'BattleMusic', .4)

			wait(.5)
			local decal = model.Inscription.Decal
			Utilities.Tween(1, 'easeInCubic', function(a)
				decal.Transparency = a
			end)
			wait(.5)

			local vic = _p.DataManager.currentChunk.map.Victini
			vic.Eyes.Glow1.Transparency = 1
			vic.Eyes.Glow2.Transparency = 1
			_p.DataManager:loadModule('AnchoredRig')
			local vcf = vic.Main.CFrame
			local rig = _p.DataManager:loadModule('AnchoredRig'):new(vic)
			rig:connect(vic, vic.Eyes)
			rig:connect(vic, vic.Mouth)
			rig:connect(vic, vic.RightArm)
			rig:connect(vic, vic.LeftArm)

			rig:reset()
			rig:pose('Victini', vcf)
			rig:pose('Victini', vcf + Vector3.new(0, 7, 0), 3.5, 'easeOutCubic')

			--		wait(.5)
			local orb = create 'Part' {
				Anchored = true,
				CanCollide = false,
				Shape = Enum.PartType.Ball,
				BrickColor = BrickColor.new('Neon orange'),
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Parent = workspace
			}
			local ocf = vcf + Vector3.new(0, 7, 0)
			Utilities.Tween(.25, nil, function(a)
				orb.Size = Vector3.new(6, 6, 6)*a
				orb.CFrame = ocf
			end)
			vic.Eyes.Main.BrickColor = BrickColor.new('Deep blue')
			vic.Eyes.LBlue.BrickColor = BrickColor.new('Pastel Blue')
			vic.Eyes.LBlue.Material = Enum.Material.Ice
			vic.Eyes.Glow1.Transparency = .75
			vic.Eyes.Glow2.Transparency = .75
			vic.Mouth.Closed1:Remove()
			vic.Mouth.Closed2:Remove()
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 10721125929, startTime = 31.13, duration = .81}) end)
			Utilities.Tween(.25, nil, function(a)
				orb.Size = Vector3.new(6, 6, 6)*(1+a)
				orb.CFrame = ocf
				orb.Transparency = a
			end)
			orb:Remove()

			rig:poses(
				{'Victini', vcf + Vector3.new(0, 5.5, 0), 2, 'easeOutCubic'},
				{'LeftArm',  CFrame.Angles(0, 0, -.8),  2, 'easeOutCubic'},
				{'RightArm', CFrame.Angles(0, 0,  .8),  2, 'easeOutCubic'})
			wait(.5)
			delay(3, function()
				vic:Remove()
				decal.Transparency = 0
			end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Victory, {battleSceneType = 'VicBattle', musicId = 'none'})
			_p.NPCChat:say('Victini can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
		end,

		Snorlax = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			local has, done
			Utilities.fastSpawn(function()
				has = _p.Connection:get('PDS', 'hasFlute')
				done = true
			end)
			chat:say('It\'s an enormous, sleeping pokemon.')
			while not done do wait() end
			if has then _p.DataManager:preload(9987557463) end
			if has and chat:say('[y/n]Would you like to use the Pok[e\'] Flute?') then
				Utilities.sound(9987557463, nil, nil, 10)
				delay(6, function() chat:manualAdvance() end)
				delay(2, function() model.Mouth.PE.Enabled = false end)
				chat:say('[ma]'.._p.PlayerData.trainerName .. ' played the Pok[e\'] Flute.')
				wait(.5)
				spawn(function() _p.Battle._SpriteClass:playCry(.5, {id = 10721039674, startTime = 43.94, duration = .42}) end)
				wait(1)
				delay(3, function() model:Remove() end)
				_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Snore)
			end
			_p.MasterControl.WalkEnabled = true
		end,

		Landorus = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			spawn(function() chat:say(model.Mouth, '[ma]Grrrraaghrraaah!') end)
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 10721136512, startTime = 104.50, duration = 1.68}) end)
			wait(1.7)
			chat:manualAdvance()
			wait(.5)
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Landforce, {musicId = legendarymusic})
			_p.NPCChat:say('Landorus can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
		end,

		sign = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			chat:say(unpack(Utilities.jsonDecode(model.SignText.Value)))
			_p.MasterControl.WalkEnabled = true
		end,

		motorized = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat

			local forme = model.Name
			local appliance = ({
				fan = 'Electric Fan',
				frost = 'Refrigerator',
				heat = 'Microwave Oven',
				mow = 'Lawn Mower',
				wash = 'Washing Machine'
			})[forme]
			chat:say('It\'s '..Utilities.aOrAn(appliance)..'.')
			local nRotom = _p.PlayerData.nRotom
			if nRotom and nRotom > 0 then
				chat:say('Oh? Rotom would like to investigate the circuits of the '..appliance..'.')
				if chat:say('[y/n]Is that OK?') then
					local slot
					if nRotom > 1 then
						chat:say('Which Rotom will you allow to investigate the circuits of the '..appliance..'?')
						slot = _p.BattleGui:choosePokemon('Choose')
						if not slot then
							_p.MasterControl.WalkEnabled = true
							return
						end
					end
					local r = _p.Connection:get('PDS', 'motorize', forme, slot)
					if r then
						chat:say(r.n..' entered the motor.')
						if r.r then
							chat:say(r.n..' reverted to its original state.')
						end
						if r.f then
							chat:say(r.n..' forgot '..r.f..'...')
						end
						if r.l then
							chat:say(r.n..' learned '..r.l..'!')
						elseif r.t then
							_p.Pokemon:processMovesAndEvolution({
								pokeName = r.n,
								moves = r.t,
								known = r.k
							}, false)
						end
					end
				end
			end

			_p.MasterControl.WalkEnabled = true
		end,

		rockClimb = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			--		_p.DataManager:preload(316598829)
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local main = model.Main
			local normals = {
				[Enum.NormalId.Right ] = Vector3.new( 1, 0, 0),
				[Enum.NormalId.Left  ] = Vector3.new(-1, 0, 0),
				[Enum.NormalId.Top   ] = Vector3.new(0,  1, 0),
				[Enum.NormalId.Bottom] = Vector3.new(0, -1, 0),
				[Enum.NormalId.Back  ] = Vector3.new(0, 0,  1),
				[Enum.NormalId.Front ] = Vector3.new(0, 0, -1),
			}
			local function getDirection(part, surfaceType)
				for id, vec in pairs(normals) do
					if part[id.Name..'Surface'] == surfaceType then
						return vec--(part.CFrame*vec)-part.Position
					end
				end
			end
			local out = getDirection(main, Enum.SurfaceType.Weld)
			spawn(function() _p.MasterControl:LookAt(main.CFrame*(out*((main.Size*out).magnitude/2))) end)
			local climber, done
			Utilities.fastSpawn(function()
				climber = _p.Connection:get('PDS', 'getClimber')
				done = true
			end)
			chat:say('These rocks look like they can be scaled by a Pokemon.')
			while not done do wait() end
			if not climber or not chat:say('[y/n]Would you like ' .. climber .. ' to use Rock Climb?') then
				_p.MasterControl.WalkEnabled = true
				return
			end
			chat:say(climber .. ' used Rock Climb!')
			local up = getDirection(main, Enum.SurfaceType.Studs)
			local yDist = (main.Size*up).magnitude
			--		print(yDist)
			local top = main.CFrame*(up*(yDist/2))
			local hDist = 3+(main.Size*out).magnitude/2
			local bottom = main.CFrame*(out*hDist-up*(yDist/2))
			out = (main.CFrame*out)-main.CFrame.p -- convert `out` to world space
			local hipHeight = 3
			local root = _p.player.Character.HumanoidRootPart
			pcall(function()
				local human = Utilities.getHumanoid()
				if human.RigType == Enum.HumanoidRigType.R15 then
					hipHeight = root.Size.Y/2 + human.HipHeight
				end
			end)
			local smokePart = create 'Part' {
				Anchored = true,
				CanCollide = false,
				Transparency = 1.0,
				Size = Vector3.new(.2, .2, .2)
			}
			local smoke = create 'Smoke' {
				Color = Color3.fromRGB(83, 67, 56),
				Opacity = .5,
				RiseVelocity = 0,
				Size = .6,
				Parent = smokePart
			}
			local smokeTransform = CFrame.new(0, 2-hipHeight, 0)
			local climbspeed = 22
			local extraheight = 2
			if top.Y > root.Position.Y then
				-- up
				local pos = bottom + Vector3.new(0, hipHeight, 0)
				local endcf = CFrame.new(pos, pos - out)
				local lerper = select(2, Utilities.lerpCFrame(root.CFrame, endcf))
				smokePart.Parent = workspace
				Utilities.Tween(yDist/climbspeed, nil, function(a)
					root.CFrame = lerper(a) + Vector3.new(0, yDist*a, 0)
					smokePart.CFrame = root.CFrame * smokeTransform
				end, 150)
				smoke.Enabled = false
				Utilities.Tween(math.pi/climbspeed*extraheight, nil, function(a)
					root.CFrame = endcf + Vector3.new(0, yDist+extraheight*math.sin(math.pi*a), 0) - out*hDist*a
				end, 150)
			else
				-- down
				local pos = top + Vector3.new(0, hipHeight, 0)
				local endcf = CFrame.new(pos, pos + out)
				local lerper = select(2, Utilities.lerpCFrame(root.CFrame, endcf))
				Utilities.Tween(math.pi/climbspeed*extraheight, nil, function(a)
					root.CFrame = lerper(a) + Vector3.new(0, extraheight*math.sin(math.pi*a), 0) + out*hDist*a
				end, 150)
				smokePart.Parent = workspace
				Utilities.Tween(yDist/climbspeed, nil, function(a)
					root.CFrame = endcf + out*hDist + Vector3.new(0, -yDist*a, 0)
					smokePart.CFrame = root.CFrame * smokeTransform
				end, 150)
				smoke.Enabled = false
			end
			delay(10, function() smokePart:Remove() end)
			_p.MasterControl.WalkEnabled = true
		end,

		heatran = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local roar = model.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.heatranRoar })
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Jaw.Position) end)
			spawn(function() chat:say(model.Jaw, '[ma]Grrawraayuuuh!') end)
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 10721125929, startTime = 7.41, duration = 1.72}) end)
			roar:Play()
			wait(1.7)
			chat:manualAdvance()
			wait(.5)
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Heat, {musicId = legendarymusic})
			_p.NPCChat:say('Heatran can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
		end,

		jDoor = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			chat:say('There are some strange markings written in the wall.')
			if _p.PlayerData.hasjkey then
				spawn(function() _p.PlayerData:completeEvent('OpenJDoor') end)
				local main = model.Main
				local mcf = main.CFrame
				Utilities.Tween(2, nil, function(a)
					Utilities.MoveModel(main, mcf + Vector3.new(0, 16*a, 0))
				end)
				model:Remove()
				pcall(function()
					local chunk = _p.DataManager.currentChunk
					local door = chunk.map.CD41
					door.Name = 'CaveDoor:chunk41'
					chunk:hookupCaveDoor(door)
				end)
			end
			_p.MasterControl.WalkEnabled = true
		end,

		diancie = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 10721144999, startTime = 27.79, duration = 1.93}) end)
			wait(1.8)
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Jewel, {musicId = legendarymusic})
			_p.NPCChat:say('Diancie can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
		end,

		rDoor = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.NPCChat:say('The Three Protectors shall awaken the Titan.')
			if _p.Connection:get('PDS', 'has3regis') then
				local CamCFrame = workspace.CurrentCamera.CFrame
				spawn(function()
					(function(p84)
						Utilities.Tween(3.5, nil, function(p86)
							workspace.CurrentCamera.CFrame = CamCFrame * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - p86) * p84), 0)
						end)
					end)(0.07)
				end)
				wait()
				pcall(function() _p.PlayerData:completeEvent('OpenRDoor') end)
				pcall(function() model['#InanimateInteract']:Remove() end)
				local DoorMain = model.Main
				local DoorCFrame = DoorMain.CFrame
				Utilities.Tween(3.5, "easeInSine", function(p87)
					Utilities.MoveModel(DoorMain, DoorCFrame + Vector3.new(0, 10 * p87, 0))
				end);
				(function(p84)
					Utilities.Tween(1, nil, function(p86)
						workspace.CurrentCamera.CFrame = CamCFrame * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - p86) * p84), 0)
					end)
				end)(0.1)
			end
			_p.MasterControl.WalkEnabled = true
		end,
		ZPedestal = function(model)
			local ztype = model.Name
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			if not _p.PlayerData.completedEvents.GivenZPouch then
				_p.NPCChat:say('It seems to be an odd crystal...',
					'You have no where to store it.'
				)
				_p.MasterControl.WalkEnabled = true
				_p.MasterControl:Stop()
				return
			end
			if _p.NPCChat:say('[y/n]Take the Z-Crystal from the pedestal?') then
				_p.NPCChat.bottom = true
				local textype = ''
				if ztype == 'FindZGrass' then
					textype = 'Grassium Z'
				elseif ztype == 'FindZFire' then
					textype = 'Firium Z'
				elseif ztype == 'FindZWater' then
					textype = 'Waterium Z'
				elseif ztype == 'FindZBug' then
					textype = 'Buginium Z'
				elseif ztype == 'FindZDragon' then
					textype = 'Dragonium Z'
				elseif ztype == 'FindZIce' then
					textype = 'Icium Z'
				end
				pcall(function() model['#InanimateInteract']:Remove() end)
				pcall(function() model['Main']:Remove() end)
				_p.NPCChat:say('Obtained a '..textype..'!', _p.PlayerData.trainerName..' put the '..textype..' in the bag.')
				_p.NPCChat.bottom = nil
				pcall(function() _p.PlayerData:completeEvent(ztype) end)
			end
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,
		VolcanionEncounter = function(model)
			if _p.PlayerData.completedEvents.GetVolcanion then return end
			if not _p.PlayerData.completedEvents.volrock then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk74' then return end
			local enc
			pcall(function() enc = chunk.regionData.Volcanion end)
			if not enc then return end

			pcall(function() _p.PlayerData:completeEvent('GetVolcanion') end)
			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9987825458, startTime = 32.99, duration = 1.66})
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 10337697962})
			_p.NPCChat:say('Volcanion can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,
		

		zapenc = function(model)
			local hadbirditems = _p.Connection:get('PDS', 'birdsitem')
			if _p.PlayerData.completedEvents.getzap then return end
			if not hadbirditems.vt then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk84' then return end
			local enc
			pcall(function() enc = chunk.regionData.Zap end)
			if not enc then return end

			pcall(function() _p.PlayerData:completeEvent('getzap') end)
			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9987794224, startTime = 47.74, duration = 0.91})
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 10337697962})
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,
		molenc = function(model)
			local hadbirditems = _p.Connection:get('PDS', 'birdsitem')
			if _p.PlayerData.completedEvents.getmol then return end
			if not hadbirditems.ot then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk82' then return end
			local enc
			pcall(function() enc = chunk.regionData.Mol end)
			if not enc then return end

			pcall(function() _p.PlayerData:completeEvent('getmol') end)
			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9987794224, startTime = 49.64, duration = 1.37})
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 10337697962})
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,
		artenc = function(model)
			local hadbirditems = _p.Connection:get('PDS', 'birdsitem')
			if _p.PlayerData.completedEvents.getart then return end
			if not hadbirditems.ft then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk86' then return end
			local enc
			pcall(function() enc = chunk.regionData.Art end)
			if not enc then return end

			pcall(function() _p.PlayerData:completeEvent('getart') end)
			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9987794224, startTime = 45.37, duration = 1.37})
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 10337697962})
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,
		MewMachine = function(p198)
			_p.MasterControl:Stop();
			_p.MasterControl.WalkEnabled = false;
			local l__NPCChat__287 = _p.NPCChat;
			if not l__NPCChat__287:say("This computer is running a machine that is trapping Mew.", "[y/n]Shut down the computer?") then
				_p.MasterControl.WalkEnabled = true;
				return;
			end;
			l__NPCChat__287:say("...", "Shutdown sequence activated.");
			p198.Main.Color = Color3.fromRGB(76, 78, 79);
			p198["#InanimateInteract"]:Remove();
			spawn(function()
				_p.Menu:disable();
			end);
			local l__MewChamber__288 = _p.DataManager.currentChunk.map.MewChamber;
			local l__Tube__289 = l__MewChamber__288.Tube;
			local l__CFrame__290 = l__Tube__289.CFrame;
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable;
			Utilities.lookAt((CFrame.new(12481.0635, 80.3596649, 650.964417, 0.936088681, 0.0287937634, -0.350583851, 3.7252903E-09, 0.996644318, 0.0818552896, 0.351764292, -0.0766238123, 0.932947338)));
			local l__TubeInner__137 = l__MewChamber__288.TubeInner;
			Utilities.Tween(0.5, "easeOutCubic", function(p199)
				l__TubeInner__137.Transparency = 0.5 + 0.5 * p199;
			end);
			wait(0.8);
			local l__CFrame__138 = l__Tube__289.CFrame;
			Utilities.Tween(0.8, "easeOutCubic", function(p200)
				l__Tube__289.CFrame = l__CFrame__138 * CFrame.new(10 * p200, 0, 0);
			end);
			wait(1);
			local l__Mew__139 = l__MewChamber__288.Mew;
			spawn(function()
				for v291, v292 in pairs(l__Mew__139:GetChildren()) do
					if v292:IsA("UnionOperation") then
						spawn(function()
							Utilities.Tween(0.5, nil, function(p201)
								v292.Transparency = 0 + 1 * p201;
							end);
						end);
					end;
				end;
			end);
			for v293, v294 in pairs(l__Mew__139:GetChildren()) do
				if v294:IsA("BasePart") then
					spawn(function()
						Utilities.Tween(0.5, nil, function(p202)
							v294.Transparency = 0 + 1 * p202;
						end);
					end);
				end;
			end;
			wait(3);
			l__NPCChat__287:say("Mew used Teleport!", "Mew can now be found roaming in the wild.");
			spawn(function()
				_p.PlayerData:completeEvent("GetMew");
			end);
			Utilities.lookBackAtMe();
			_p.MasterControl.WalkEnabled = true;
			_p.Menu:enable();
		end,

		HeadbuttBarrel = function(p188)
			local l__NPCChat__270 = _p.NPCChat;
			_p.MasterControl:Stop();
			_p.MasterControl.WalkEnabled = false;
			spawn(function()
				_p.MasterControl:LookAt(p188.Main.Position);
			end);
			local u129 = nil;
			local u130 = nil;
			Utilities.fastSpawn(function()
				u129 = _p.Connection:get("PDS", "getHeadbutter");
				u130 = true;
			end);
			l__NPCChat__270:say("These barrels are precariously placed");
			while not u130 do
				wait();		
			end;
			if u129 and l__NPCChat__270:say("[y/n]Would you like " .. u129 .. " to use Headbutt?") then
				local l__currentChunk__271 = _p.DataManager.currentChunk;
				local v272 = l__currentChunk__271:topRoom();
				p188["#InanimateInteract"]:Remove();
				local l__model__273 = v272.model;
				local l__Guy__131 = v272.npcs.Guy;
				spawn(function()
					l__Guy__131:LookAt(l__Guy__131.model.HumanoidRootPart.Position + Vector3.new(0, 0, -5));
				end);
				l__NPCChat__270:say(u129 .. " used Headbutt!");
				spawn(function()
					_p.Menu:disable();
				end);
				Utilities.sound(330262909, nil, nil, 5);
				local l__PushBarrels__274 = l__model__273.PushBarrels;
				l__model__273.InvisWall.CanCollide = false;
				l__PushBarrels__274.Main.CanCollide = false;
				l__PushBarrels__274.Barrel1.Main.Anchored = false;
				l__PushBarrels__274.Barrel2.Main.Anchored = false;
				l__PushBarrels__274.Barrel3.Main.Anchored = false;
				l__PushBarrels__274.Barrel1.Main.AssemblyLinearVelocity = Vector3.new(0, 0, 30);
				l__PushBarrels__274.Barrel2.Main.AssemblyLinearVelocity = Vector3.new(0, 0, 30);
				l__PushBarrels__274.Barrel3.Main.AssemblyLinearVelocity = Vector3.new(0, 0, 30);
				delay(0.5, function()
					for v275, v276 in pairs(l__model__273:GetChildren()) do
						if v276:IsA("BasePart") and v276.Name == "OilSpill" then
							v276.Transparency = 0;
						end;
					end;
				end);
				wait(2);
				l__currentChunk__271:unbindIndoorCam();
				local l__CurrentCamera__277 = workspace.CurrentCamera;
				l__CurrentCamera__277.CameraType = Enum.CameraType.Scriptable;
				Utilities.lookAt(l__Guy__131.model.HumanoidRootPart.CFrame * CFrame.new(0, 13, -15) * CFrame.Angles(math.rad(40), math.rad(180), 0));
				Utilities.exclaim(l__Guy__131.model.Head);
				l__Guy__131:Say("What have you done?!");
				spawn(function()
					l__Guy__131:WalkTo(l__model__273.GuyWalkTo.CFrame);
					l__Guy__131:LookAt(l__model__273.Boat.LookAt.CFrame);
					l__Guy__131.model.Interact.Parent = nil;
					l__NPCChat__270.interactableNPCs[l__Guy__131.model] = function()
						l__Guy__131:Say("Look at what you've done!", "How am I supposed to clean this?");
						l__Guy__131:LookAt(l__model__273.Boat.LookAt.CFrame);
					end;
				end);
				local l__CFrame__132 = l__CurrentCamera__277.CFrame;
				local l__CFrame__133 = l__CurrentCamera__277.CFrame;
				Utilities.Tween(0.8, "easeInOutCubic", function(p189)
					l__CurrentCamera__277.CFrame = l__CFrame__132:Lerp(l__CFrame__133, p189);
				end);
				spawn(function()
					_p.PlayerData:completeEvent("DoMewDoor");
				end);
				l__currentChunk__271:bindIndoorCam();
				l__model__273.NoPass.CanCollide = false;
				l__model__273.InvisWall.CanCollide = true;
				l__PushBarrels__274.Main.CanCollide = true;
				spawn(function()
					_p.Menu:enable();
				end);
				_p.MasterControl.WalkEnabled = true;
			end;
			_p.MasterControl.WalkEnabled = true;
		end;
		CraneButton = function(p190)
			_p.MasterControl:Stop();
			local l__currentChunk__278 = _p.DataManager.currentChunk;
			_p.MasterControl.WalkEnabled = false;
			if not _p.NPCChat:say("[y/n]A secret switch! Press it?") then
				_p.MasterControl.WalkEnabled = true;
				return;
			end;
			p190["#InanimateInteract"]:Remove();
			l__currentChunk__278:unbindIndoorCam();
			spawn(function()
				_p.Menu:disable();
			end);
			local l__CurrentCamera__279 = workspace.CurrentCamera;
			l__CurrentCamera__279.CameraType = Enum.CameraType.Scriptable;
			local l__model__280 = l__currentChunk__278:topRoom().model;
			local l__Hook__281 = l__model__280.Hook;
			l__CurrentCamera__279.FieldOfView = 60;
			l__CurrentCamera__279.CFrame = l__Hook__281.Main.CFrame * CFrame.new(35, -8, 35);
			local l__RunService__282 = game:GetService("RunService");
			local l__Main__283 = l__model__280.Truck.Main;
			local l__CurrentCamera__284 = workspace.CurrentCamera;
			l__CurrentCamera__284.CameraType = Enum.CameraType.Scriptable;
			l__RunService__282:BindToRenderStep("camThing", Enum.RenderPriority.Camera.Value + 20, function()
				l__CurrentCamera__284.CFrame = CFrame.new(l__CurrentCamera__284.CFrame.p, l__Hook__281.Main.Position);
			end);
			local l__Main__285 = l__Hook__281.Main;
			local l__Main__286 = l__model__280.Crane.Main;
			Utilities.MoveModel(l__Main__286, l__Main__286.CFrame);
			Utilities.MoveModel(l__Main__285, l__Main__285.CFrame);
			Utilities.MoveModel(l__Main__283, l__Main__283.CFrame);
			local u134 = l__Main__285.CFrame;
			local u135 = l__Main__283.CFrame;
			spawn(function()
				Utilities.Tween(4, nil, function(p191)
					Utilities.MoveModel(l__Main__285, u134 * CFrame.new(0, 0, 27 * p191));
				end);
				u134 = l__Main__285.CFrame;
				Utilities.Tween(2, nil, function(p192)
					Utilities.MoveModel(l__Main__285, u134 * CFrame.new(0, -10.5 * p192, 13.5 * p192));
				end);
				u134 = l__Main__285.CFrame;
				Utilities.Tween(2, nil, function(p193)
					Utilities.MoveModel(l__Main__285, u134 * CFrame.new(0, 0, 13.5 * p193));
				end);
				u134 = l__Main__285.CFrame;
				spawn(function()
					Utilities.Tween(1, nil, function(p194)
						Utilities.MoveModel(l__Main__283, u135 * CFrame.new(0, 2.625 * p194, 0) * CFrame.Angles(0, 0, math.rad(20 * p194)));
					end);
					u135 = l__Main__283.CFrame;
					Utilities.Tween(3, nil, function(p195)
						Utilities.MoveModel(l__Main__283, u135 * CFrame.new(2.625 * p195, 7.875 * p195, 0));
					end);
				end);
				Utilities.Tween(4, nil, function(p196)
					Utilities.MoveModel(l__Main__285, u134 * CFrame.new(0, 10.5 * p196, 0));
				end);
			end);
			local l__CFrame__136 = l__Main__286.CFrame;
			Utilities.Tween(8, nil, function(p197)
				Utilities.MoveModel(l__Main__286, l__CFrame__136 * CFrame.new(-54 * p197, 0, 0));
			end);
			wait(7);
			l__RunService__282:UnbindFromRenderStep("camThing");
			l__CurrentCamera__284.FieldOfView = 70;
			l__currentChunk__278:bindIndoorCam();
			spawn(function()
				_p.PlayerData:completeEvent("OpenMewLab");
			end);
			spawn(function()
				_p.Menu:enable();
			end);
			_p.MasterControl.WalkEnabled = true;
		end;
		GirafarigDunsparceDoor = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local canOpen, done
			Utilities.fastSpawn(function()
				canOpen = _p.Connection:get('PDS', 'OpenGirafarigDunsparceDoor')
				done = true
			end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.NPCChat:say('There are strange markings on this wall.',
				'What could they mean?'
			)
			while not done do wait() end
			if canOpen then
				local DoorMain = model.Main;
				local DoorCFrame = DoorMain.CFrame;
				pcall(function() model['#InanimateInteract']:Remove() end)
				Utilities.Tween(3, "easeInSine", function(p87)
					Utilities.MoveModel(DoorMain, DoorCFrame + Vector3.new(0, 10 * p87, 0));
				end);
				pcall(function() _p.PlayerData:completeEvent('OpenGirafarigDunsparceDoor') end)
				_p.NPCChat:say('The strange wall opened, revealing another chamber.')
			end
			_p.MasterControl.WalkEnabled = true
		end,
		wallbreak = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local main = model.Main
			spawn(function() _p.MasterControl:LookAt(main.Position) end)
			local smasher, done
			Utilities.fastSpawn(function()
				smasher = _p.Connection:get('PDS', 'getSmasher')
				done = true
			end)
			chat:say('It\'s a cracked wall.', 'A pokemon may be able to break it.')
			while not done do wait() end
			if not smasher or not chat:say('[y/n]Would you like ' .. smasher .. ' to use Rock Smash?') then
				_p.MasterControl.WalkEnabled = true
				return
			end
			chat:say(smasher .. ' used Rock Smash!')
			pcall(function() model['#InanimateInteract']:Remove() end)
			main:Remove()
			local cf = main.CFrame
			for _, p in pairs(model:GetChildren()) do
				if p:IsA('BasePart') then
					p.Anchored = false
					local dir = (p.Position-cf.p+Vector3.new(10,7,10)).unit
					p.Velocity = dir * 20
					local force = create 'BodyForce' {
						Force = dir * 50 * p:GetMass(),
						Parent = p
					}
					delay(.25, function() force:Remove() end)
				end
			end
			wait(1)
			Utilities.Tween(.5, nil, function(a)
				for _, p in pairs(model:GetChildren()) do
					if p:IsA('BasePart') then
						p.Transparency = a
					end
				end
			end)
			model:Remove()
			pcall(function() _p.PlayerData:completeEvent('DoWallSmashDoor') end)
			_p.MasterControl.WalkEnabled = true
		end,
		Registeel = function(model)
			if not _p.PlayerData.completedEvents.DidRegiPuzzles then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk49' then return end
			local enc
			pcall(function() enc = chunk.regionData.Registeel end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9987805402, startTime = 8.14, duration = 1.22})
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 10337697962})
			pcall(function() _p.PlayerData:completeEvent('getRegSteel') end)
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
			_p.NPCChat:say('Registeel can now be found roaming in the wild.')
		end,
		Regirock = function(model)
			if not _p.PlayerData.completedEvents.DidRegiPuzzles then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk50' then return end
			local enc
			pcall(function() enc = chunk.regionData.Regirock end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9987805402, startTime = 2.93, duration = 1.66})
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 10337697962})
			pcall(function() _p.PlayerData:completeEvent('getRegRock') end)
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
			_p.NPCChat:say('Regirock can now be found roaming in the wild.')
		end,
		Regice = function(model)
			if not _p.PlayerData.completedEvents.DidRegiPuzzles then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk58' then return end
			local enc
			pcall(function() enc = chunk.regionData.Regice end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9987805402, startTime = 5.59, duration = 1.55})
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 10337697962})
			pcall(function() _p.PlayerData:completeEvent('getRegIce') end)
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
			_p.NPCChat:say('Regice can now be found roaming in the wild.')
		end,
		KeldeoEncounter = function(model)
			if _p.PlayerData.completedEvents.SOJ2 then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk66' then return end
			local enc
			pcall(function() enc = chunk.regionData.Keldeo end)
			if not enc then return end

			pcall(function() _p.PlayerData:completeEvent('SOJ2') end)
			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9987819956, startTime = 109.55, duration = 1.07})
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 10337697962})
			_p.MasterControl.WalkEnabled = true
		end,
		teamegendoor = function(model)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.NPCChat:say('This door is locked.')
			if _p.PlayerData.completedEvents.doebasecard then
				_p.NPCChat:say('You swiped your Card Key.')
				model.Light.BrickColor = BrickColor.new('Lime green')
				model.Light.PointLight.Color = Color3.fromRGB(0, 255, 0)
				_p.NPCChat:say('The door unlocked.')
				pcall(function() model['#InanimateInteract']:Remove() end)
				pcall(function() _p.PlayerData:completeEvent('doebasegendoor') end)
				local door = _p.DataManager.currentChunk:getDoor('C_chunk576')
				door.disabled = false
			end
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,
		PinkKeg = function(p80)
			local l__NPCChat__161 = _p.NPCChat;
			spawn(function()
				_p.Menu:disable();
				_p.MasterControl:Stop();
				_p.MasterControl.WalkEnabled = false;
			end);
			if l__NPCChat__161:say("It's a juice keg.", "[y/n]Would you like to pull the lever?") then
				wait(1);
				l__NPCChat__161:say("It's strawberry watermelon!", "[small]Mmmmmmmmmmmm...");
				spawn(function()
					_p.Menu:enable();
					_p.MasterControl.WalkEnabled = true;
				end);
				return;
			end;
			_p.Menu:enable();
			_p.MasterControl.WalkEnabled = true;
		end;
		PurpleKeg = function(p80)
			local l__NPCChat__162 = _p.NPCChat;
			spawn(function()
				_p.Menu:disable();
				_p.MasterControl:Stop();
				_p.MasterControl.WalkEnabled = false;
			end);
			if l__NPCChat__162:say("It's a juice keg.", "[y/n]Would you like to pull the lever?") then
				wait(1);
				l__NPCChat__162:say("It's grape!", "[small]Mmmmmmmmmmmm...");
				spawn(function()
					_p.Menu:enable();
					_p.MasterControl.WalkEnabled = true;
				end);
				return;
			end;
			_p.Menu:enable();
			_p.MasterControl.WalkEnabled = true;
		end;
		OrangeKeg = function(p80)
			local l__NPCChat__163 = _p.NPCChat;
			spawn(function()
				_p.Menu:disable();
				_p.MasterControl:Stop();
				_p.MasterControl.WalkEnabled = false;
			end);
			if l__NPCChat__163:say("It's a juice keg.", "[y/n]Would you like to pull the lever?") then
				wait(1);
				l__NPCChat__163:say("It's orange!", "[small]Mmmmmmmmmmmm...");
				spawn(function()
					_p.Menu:enable();
					_p.MasterControl.WalkEnabled = true;
				end);
				return;
			end;
			_p.Menu:enable();
			_p.MasterControl.WalkEnabled = true;
		end;
		RedKeg = function(p83)
			if false then
				return;
			end;
			spawn(function()
				_p.Menu:disable();
				_p.MasterControl:Stop();
				_p.MasterControl.WalkEnabled = false;
			end);
			if not _p.NPCChat:say("It's a juice keg.", "[y/n]Would you like to pull the lever?") then
				_p.Menu:enable();
				_p.MasterControl.WalkEnabled = true;
				return;
			end;
			spawn(function()
				_p.Menu:disable();
				_p.MasterControl.WalkEnabled = false;
			end);
			local l__ElevatorMain__164 = p83.ElevatorMain;
			local l__CFrame__80 = workspace.CurrentCamera.CFrame;
			(function(p84)
				Utilities.Tween(1.2, nil, function(p86)
					workspace.CurrentCamera.CFrame = l__CFrame__80 * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - p86) * p84), 0);
				end);
			end)(0.07);
			wait(1);
			local l__CFrame__81 = l__ElevatorMain__164.CFrame;
			Utilities.Tween(2, "easeInSine", function(p87)
				Utilities.MoveModel(l__ElevatorMain__164, l__CFrame__81 + Vector3.new(0, 7.5 * p87, 0));
			end);
			spawn(function()
				local l__CFrame__82 = workspace.CurrentCamera.CFrame;
				(function(p88)
					Utilities.Tween(1.2, nil, function(p90)
						workspace.CurrentCamera.CFrame = l__CFrame__82 * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - p90) * p88), 0);
					end);
				end)(0.07);
			end);
			_p.Menu:enable();
			_p.MasterControl.WalkEnabled = true;
		end;
		teamebutton = function(model)
			local l__CurrentCamera__216 = workspace.CurrentCamera;
			local l__map__217 = _p.DataManager.currentChunk.map;
			local l__CFrame__92 = l__CurrentCamera__216.CFrame;
			spawn(function()
				pcall(function() model['#InanimateInteract']:Remove() end)
				_p.MasterControl.WalkEnabled = false;
				_p.Menu:disable();
			end);
			model.Main.Color = Color3.fromRGB(255, 0, 0);
			(function(p107)
				Utilities.Tween(1.2, nil, function(p109)
					local v218 = (1 - p109) * p107;
					local v219 = math.random() * math.pi * 2;
					l__CurrentCamera__216.CFrame = l__CFrame__92 * CFrame.new(math.cos(v219) * v218, 0, math.sin(v219) * v218);
				end);
			end)(0.1);
			wait(0.7);
			Utilities.FadeOut(1);
			l__CurrentCamera__216.CameraType = Enum.CameraType.Scriptable;
			l__CurrentCamera__216.FieldOfView = 60;
			local v220 = CFrame.new(-91.7385941, 330.102966, -1376.26001, -0.999999285, 4.34831145E-06, -0.0012283239, -0, 0.999993742, 0.00354001415, 0.0012283317, 0.00354001159, -0.999992967);
			local v221 = CFrame.new(-91.2999802, 328.840088, -1019.50378, -0.999999285, 4.34831145E-06, -0.0012283239, -0, 0.999993742, 0.00354001415, 0.0012283317, 0.00354001159, -0.999992967);
			local v222 = CFrame.new(-137.010788, 347.528259, -973.685242, -0.00883319881, -0.0998192951, 0.994966388, -5.82076679E-11, 0.99500531, 0.0998231769, -0.999961078, 0.000881757936, -0.00878907833);
			local v223 = CFrame.new(-49.142952, 335.980804, -968.162354, 0.220119029, 0.246904269, -0.943708658, -0, 0.967437029, 0.253112346, 0.975473046, -0.0557148457, 0.212951273);
			wait(3);
			spawn(function()
				Utilities.FadeIn(1);
			end);
			local l__CFrame__93 = l__map__217.Door2.Left.Main.CFrame;
			delay(0, function()
				Utilities.Tween(3, "easeOutSine", function(p110)
					Utilities.MoveModel(l__map__217.Door2.Left.Main, l__CFrame__93 + Vector3.new(-10 * p110, 0, 0));
				end);
			end);
			local l__CFrame__94 = l__map__217.Door2.Right.Main.CFrame;
			delay(0, function()
				Utilities.Tween(3, "easeOutSine", function(p111)
					Utilities.MoveModel(l__map__217.Door2.Right.Main, l__CFrame__94 + Vector3.new(10 * p111, 0, 0));
				end);
			end);
			local l__CFrame__95 = l__map__217.Door3.Left.Main.CFrame;
			delay(4, function()
				Utilities.Tween(3, "easeOutCubic", function(p112)
					Utilities.MoveModel(l__map__217.Door3.Left.Main, l__CFrame__95 + Vector3.new(-10 * p112, 0, 0));
				end);
			end);
			local l__CFrame__96 = l__map__217.Door3.Right.Main.CFrame;
			delay(4, function()
				Utilities.Tween(3, "easeOutCubic", function(p113)
					Utilities.MoveModel(l__map__217.Door3.Right.Main, l__CFrame__96 + Vector3.new(10 * p113, 0, 0));
				end);
			end);
			local l__CFrame__97 = l__map__217.Door4.Left.Main.CFrame;
			delay(11, function()
				Utilities.Tween(3.5, "easeOutCubic", function(p114)
					Utilities.MoveModel(l__map__217.Door4.Left.Main, l__CFrame__97 + Vector3.new(0, 0, 7 * p114));
				end);
			end);
			local l__CFrame__98 = l__map__217.Door4.Right.Main.CFrame;
			delay(11, function()
				Utilities.Tween(3.5, "easeOutCubic", function(p115)
					Utilities.MoveModel(l__map__217.Door4.Right.Main, l__CFrame__98 + Vector3.new(0, 0, -7 * p115));
				end);
			end);
			local l__CFrame__99 = l__map__217.Door5.Left.Main.CFrame;
			delay(13, function()
				Utilities.Tween(5, "easeOutCubic", function(p116)
					Utilities.MoveModel(l__map__217.Door5.Left.Main, l__CFrame__99 + Vector3.new(0, 0, -7 * p116));
				end);
			end);
			local l__CFrame__100 = l__map__217.Door5.Right.Main.CFrame;
			delay(13, function()
				Utilities.Tween(5, "easeOutCubic", function(p117)
					Utilities.MoveModel(l__map__217.Door5.Right.Main, l__CFrame__100 + Vector3.new(0, 0, 7 * p117));
				end);
			end);
			Utilities.Tween(10, nil, function(p118)
				l__CurrentCamera__216.CFrame = v220:Lerp(v221, p118);
			end);
			Utilities.Tween(2, nil, function(p119)
				l__CurrentCamera__216.CFrame = v221:Lerp(v222, p119);
			end);
			Utilities.Tween(3, "easeInOutCubic", function(p120)
				l__CurrentCamera__216.CFrame = v222:Lerp(v223, p120);
			end);
			wait(0.5);
			Utilities.FadeOut(1);
			l__CurrentCamera__216.CameraType = Enum.CameraType.Custom;
			_p.Menu:enable();
			_p.MasterControl.WalkEnabled = true;
			l__CurrentCamera__216.FieldOfView = 70;
			Utilities.FadeIn(1);
			spawn(function()
				_p.PlayerData:completeEvent("doebasedoor2");
			end);
		end,
		teamecard = function(model)
			if _p.PlayerData.completedEvents.doebasecard then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			Utilities.sound(288899943, nil, nil, 10)
			pcall(function() _p.PlayerData:completeEvent('doebasecard') end)
			_p.NPCChat:say(_p.PlayerData.trainerName..' found a Card Key!')
			pcall(function() model:Remove() end)
			_p.NPCChat:say(_p.PlayerData.trainerName..' put the Card Key in the Bag.')
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,
		
		getdrive = function(model)
			local dtype = model.Name
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			Utilities.sound(288899943, nil, nil, 10)
			local textype = ''
			if dtype == 'burndrive' then
				textype = 'Burn Drive'
			elseif dtype == 'dousedrive' then
				textype = 'Douse Drive'
			elseif dtype == 'chilldrive' then
				textype = 'Chill Drive'
			elseif dtype == 'shockdrive' then
				textype = 'Shock Drive'
			end
			_p.NPCChat:say(_p.PlayerData.trainerName..' found a '..textype..'!')
			pcall(function() model:Remove() end)
			_p.NPCChat:say(_p.PlayerData.trainerName..' put the '..textype..' in the Bag.')
			pcall(function() _p.PlayerData:completeEvent(dtype) end)
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,
		getgen = function(model)
			if _p.PlayerData.completedEvents.getgen then return end
			if not _p.PlayerData.completedEvents.doebasegendoor then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk576' then return end
			local enc
			pcall(function() enc = chunk.regionData.Gen end)
			if not enc then return end

			pcall(function() _p.PlayerData:completeEvent('getgen') end)
			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9987819956, startTime = 113.91, duration = 1.16})
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 10337697962})
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
			_p.NPCChat:say('Genesect can now be found roaming in the wild.')
		end,

		CelebiWell = function(model)
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk12' then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.NPCChat:say('It\'s an odd-looking shrine.')
			if _p.PlayerData.completedEvents.Celebi then
				_p.MasterControl.WalkEnabled = true
				_p.MasterControl:Stop()
				return
			end
			if _p.PlayerData.completedEvents.getGSBall then
				pcall(function() model['#InanimateInteract']:Remove() end)
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				workspace.CurrentCamera.CFrame = CFrame.new(-544.811035, 65.8487015, -517.851318, 0.866025388, -0.129409418, 0.482962936, 0, 0.965925872, 0.258818835, -0.5, -0.224143684, 0.836516321)
				local Celebi = _p.DataManager:request({'Model', 'Celebi'})
				Celebi.Parent = chunk.map
				spawn(function() _p.Menu:disable() end)
				_p.NPCChat:say('The GS Ball is glowing in your Bag...', 'But nothing happened...')
				_p.MasterControl:LookAt(Vector3.new(-550.3, 61.907, -514.717))
				workspace.CurrentCamera.CFrame = CFrame.new(-541.779968, 65.3487015, -519.601318, -0.5, 1.34110451e-07, 0.866025388, 2.08616257e-07, 0.999999881, -1.13133307e-08, -0.866025388, 1.93715096e-07, -0.50000006)
				_p.NPCChat:say('Celebi can now be found roaming in the wild.')
				Celebi:Remove()
				pcall(function() _p.PlayerData:completeEvent('Celebi') end)
				spawn(function() _p.Menu:enable() end)
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,
		KPedestal = function(model)
			local map = _p.DataManager.currentChunk.map
			local kyogre = map:FindFirstChild("Kyogre")

			local cam = workspace.CurrentCamera
			spawn(function()
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				_p.Menu:disable()
			end)
			local Tween = _p.Utilities.Tween
			local stepped = game:GetService('RunService').RenderStepped

			_p.NPCChat:say('This is the pedistal that was used by Team Eclipse.')
			wait()
			if not _p.PlayerData.completedEvents.hasBlueOrb then 
				spawn(function() _p.Menu:enable() end)
				_p.MasterControl.WalkEnabled = true
				return 
			end

			local choice = _p.NPCChat:say('[y/n]Place the Blue Orb?')
			if choice then
				spawn(function()
					_p.NPCChat:say('[ma]You placed the Blue Orb on the pedistal...')
				end)	
				
				map.BlueOrb.Transparency = 0
				_p.MasterControl:Stop()
				_p.RunningShoes:disable()
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:WalkTo(Vector3.new(149.47, 72.24, 581.164))
				_p.MasterControl:LookAt(map.BlueOrb.Position)
								
				--// Animation Swim
				local SwimAnimation = Instance.new("Animation")
				SwimAnimation.AnimationId = 'rbxassetid://'.._p.animationId.KyogreSwim
				local SwimAnimationController = Instance.new("AnimationController")
				SwimAnimationController.Parent = kyogre
				local SwimAnimator = Instance.new("Animator")
				SwimAnimator.Parent = SwimAnimationController

				--// Play Swim
				local KyogreSwim = SwimAnimator:LoadAnimation(SwimAnimation)
				KyogreSwim.Looped = false

				KyogreSwim:Play()
				KyogreSwim.Stopped:Wait()
				KyogreSwim:Stop()
				SwimAnimator.WeightCurrentPlayingAnimation = 1


			else
				-- Code
			end
			
		end,
		Meteor = function(targ, pos)
			_p.Overworld.Weather.Meteor:OnInteractWithMeteor(targ)
		end,
	
		IceDoor = function(model)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local froster, done
			Utilities.fastSpawn(function()
				froster = _p.Connection:get('PDS', 'getFroster')
				done = true
			end)
			_p.NPCChat:say('There are some strange markings written in the wall.')
			while not done do wait() end
			if not froster or not _p.NPCChat:say('[y/n]Would you like ' .. froster .. ' to use Frost Breath?') then
				_p.MasterControl.WalkEnabled = true
				return
			end
			pcall(function() model['#InanimateInteract']:Remove() end)
			pcall(function() model['Main']:Remove() end)
			_p.NPCChat:say(froster .. ' used Frost Breath!')
			pcall(function() _p.PlayerData:completeEvent('BreakIceDoor') end)
			local breakParts = model.Break

			model.Sign:Remove()
			for i,v in pairs(breakParts:GetChildren()) do
				v.Color = Color3.fromRGB(9, 165, 160)
			end
			wait(1.5)
			for i,v in pairs(breakParts:GetChildren()) do
				v.Anchored = false
				v.Velocity = Vector3.new(math.random(5,20), 0, math.random(5,20))
				local force = create 'BodyForce' {
					Force = Vector3.new(math.random(5,20), 0, math.random(5,20)) * v:GetMass(),
					Parent = v
				}
				delay(.25, function() force:Remove() end)
			end
			wait(.5)
			_p.NPCChat:say('A critical hit!')
			breakParts:Remove()
			_p.MasterControl.WalkEnabled = true
		end,
		GPedistal = function(model)
			if _p.PlayerData.completedEvents.Groudon  then
				_p.NPCChat:say('This Event is already completed.')
				return
			end
			local map = _p.DataManager.currentChunk.map
			_p.MasterControl.WalkEnabled = false
			spawn(function() _p.Menu:disable() end)
			local Tween = _p.Utilities.Tween
			local stepped = game:GetService('RunService').RenderStepped

			_p.NPCChat:say('This is the pedistal that was used by Team Eclipse.')

			if not _p.PlayerData.completedEvents.SebastianRebattle then 
				spawn(function() _p.Menu:enable() end)
				_p.MasterControl.WalkEnabled = true
				return 
			end

			local choice = _p.NPCChat:say('[y/n]Place the Red Orb?')
			if choice then
				_p.DataManager:preloadModule('AnchoredRig')
				map.RedOrb.Transparency = 0
				local cam = workspace.CurrentCamera
				local rMusic = _p.MusicManager:getMusicNamed('RegionMusic')
				cam.CameraType = Enum.CameraType.Scriptable
				spawn(function()
					_p.NPCChat:say('[ma]You placed the Red Orb on the pedistal...')
				end)	

				Utilities.sound(317440901, .6, nil, 18)
				local sceneMusic = Utilities.sound(317447005, .3)
				rMusic.Volume = 0
				delay(99, function()
					if not sceneMusic then return end
					sceneMusic = Utilities.loopSound(317447026, .3)
				end)

				local camCFrame1 = CFrame.new(-809.025024, 83.6930923, -824.031494, -0.857597828, -0.196856126, 0.475156426, -0, 0.923852146, 0.382749647, -0.51432085, 0.328245252, -0.792293608)
				local camCFrame2 = CFrame.new(-839.190063, 75.9603577, -802.962585, -0.954399168, 0.0467679016, 0.294847548, -0, 0.987652898, -0.156658739, -0.298533618, -0.149514973, -0.942614973)

				local lerp = select(2, Utilities.lerpCFrame(cam.CoordinateFrame, camCFrame1))
				Tween(1.5, 'easeOutQuad', function(a)
					local cf = lerp(a)
					cam.CoordinateFrame = CFrame.new(cf.p, cf.p+cf.lookVector)
				end)


				local lerp = select(2, Utilities.lerpCFrame(camCFrame1, camCFrame2))
				local groudon = map.Groudon
				local rig = _p.DataManager:loadModule('AnchoredRig'):new(groudon) --_p.DataManager:loadModule('AnchoredRig'):new(groudon)
				rig:connect(groudon, groudon.Body)
				rig:connect(groudon.Body, groudon.Head)
				rig:connect(groudon.Head, groudon.Jaw)
				rig:connect(groudon.Body, groudon.RArm)
				rig:connect(groudon.Body, groudon.LArm)
				rig:connect(groudon.Body, groudon.RLeg)
				rig:connect(groudon.Body, groudon.LLeg)

				local blurPart = create 'Part' {
					Material = Enum.Material.Neon,
					Transparency = 1.0,
					BrickColor = BrickColor.new('Crimson'),
					--					FormFactor = Enum.FormFactor.Custom,
					Size = Vector3.new(20, 20, .2),
					Anchored = true,
					CanCollide = false,
					Parent = workspace,
				}
				local function blur()
					blurPart.CFrame = cam.CoordinateFrame * CFrame.new(0, 0, -1)
				end


				rig:reset()
				local cf = cam.CoordinateFrame
				local st = tick()
				local duration = 8
				while true do
					stepped:wait()
					local et = tick()-st
					if et > duration then break end
					local o = (et%.25)*2
					if o >= .325 then
						o = .5-(o-.325)*4
					elseif o >= .25 then
						o = (o-.25)*4
					elseif o >= .125 then
						o = -.5+(o-.125)*4
					else
						o = o*-4
					end
					local m = 0
					if et < duration-.5 then
						m = math.min(1, math.sin(et/(duration-.5)*math.pi))
					end
					local cf = lerp(et/duration)
					cam.CoordinateFrame = CFrame.new(cf.p, cf.p+cf.lookVector) * CFrame.new(o*m*5, 0, 0)--cf * CFrame.new(o*m*5, 0, 10-10*et/duration)
					blurPart.Transparency = 1-et/duration*.25
					blur()
				end
				cam.CoordinateFrame = camCFrame2
				blur()
				_p.NPCChat:manualAdvance()
				wait(1)

				-- setup initial rig poses
				rig:pose('Groudon', CFrame.new(-826, 42, -747) * CFrame.Angles(0, 1, 0) * CFrame.Angles(-0.6, 0, 0))

				-- animate coming out of lava
				delay(.25, function()
					Tween(.5, nil, function(a)
						local o = 1-a
						local t = math.random()*math.pi*2
						cam.CoordinateFrame = camCFrame2 * CFrame.new(math.cos(t)*o*2.5, math.sin(t)*o*2.5, 0)
						blur()
					end)
				end)
				local cry

				delay(.5, function()
					cry = _p.DataManager:getSprite('_FRONT', 'Groudon').cry
					_p.Battle._SpriteClass:playCry(.5, cry, .5)
					_p.Particles:new {
						N = 20,
						Position = Vector3.new(-836, 62, -757),
						Velocity = Vector3.new(0, 40, 0),
						VelocityVariation = 60,
						Acceleration = Vector3.new(0, -18, 0),
						Size = 2,
						Image = 68068592,
						Color = BrickColor.new('Crimson').Color,
						Lifetime = 8,
					}
				end)
				rig:poses(
					{'Kyogre', CFrame.new(-836, 62, -757) * CFrame.Angles(0, 0.7, 0) * CFrame.Angles(0.5, 0, 0), 2, 'easeOutQuad'},
					{'RArm', CFrame.Angles(0, 0, -1) * CFrame.Angles(0, -0.5, 0), 2},
					{'RightArm', CFrame.Angles(0, 0, 1) * CFrame.Angles(0, 0.5, 0), 2},
					{'LowerJaw', CFrame.Angles(0.8, 0, 0), 3, 'easeOutCubic'})
				--_p.NPCChat:manualAdvance()
				wait(.3)

				rig:poses({'Groudon', CFrame.new(-846, 72, -767) * CFrame.Angles(0, 0.4, 0), 2, 'easeInOutQuad'},
				{'RArm', CFrame.new(), 1.75, 'easeInOutQuad'},
				{'LArm', CFrame.new(), 1.75, 'easeInOutQuad'},
				{'Jaw', CFrame.Angles(0.3, 0, 0), 1.5})
				rig:poses({'Groudon', CFrame.new(-846, 71.3, -767) * CFrame.Angles(0, 0.4, 0), 1},
				{'RLeg', CFrame.new(0, 0.7, 0), 1},
				{'LLeg', CFrame.new(0, 0.7, 0), 1},
				{'Jaw', CFrame.Angles(0.2, 0, 0), 1})

				wait(.2)
				print(tostring(_p.DataManager.currentChunk.regionData.LavaBeast))
				local v = sceneMusic.Volume
				sceneMusic.Volume = 0
				spawn(function()
					_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.LavaBeast, {musicId = 10840573719})
					_p.NPCChat:say('Groudon can now be found roaming in the wild.')
					local function DoChoice(...)
						local q = {...}
						for i=1, #q do
							if i == #q then
								map.RedOrb.Transparency = 1
								_p.NPCChat:say(q[i])
								return true	
							else
								local c = _p.NPCChat:say('[y/n]'..q[i])
								if c then
									_p.NPCChat:say('You picked up the Red Orb.')
									map.RedOrb.Transparency = 1
									return true	
								end
							end
						end
						return false
					end
					sceneMusic.Volume = v
					local music = sceneMusic
					local volume = music.Volume
					sceneMusic = nil
					Tween(1, nil, function(a)
						music.Volume = volume*(1-a)
						rMusic.Volume = volume*(1+a)
					end)
					music:Remove()

					DoChoice('Pick up the Red Orb?', 'C\'mon, I know you want to.', 'PICK UP THE ORB!!!', 'The Red Orb slipped and fell in to your bag...')
					spawn(function() _p.Menu:enable() end)
					_p.MasterControl.WalkEnabled = true
				end)	

				spawn(function()	
					wait(1.5)
					blurPart:Remove()
					groudon:Remove()
				end)	
			else
				_p.NPCChat:say('Maybe next time..')
				spawn(function() _p.Menu:enable() end)
				_p.MasterControl.WalkEnabled = true
			end
		end,
		LaprasEncounter = function(model)
			if not _p.PlayerData.badges[7] then return false end
			local is = _p.Connection:get('PDS', 'isLapD')
			if not is then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk71' then return end
			local enc
			pcall(function() enc = chunk.regionData.Lapras end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:Remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9987794224, startTime = 19.91, duration = 0.90})
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(enc)
			_p.MasterControl.WalkEnabled = true
		end,
	} end