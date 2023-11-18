return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local stepped = game:GetService("RunService").RenderStepped
	local lighting = game:GetService("Lighting")
	local player = _p.player
	local camera = game.Workspace.CurrentCamera
	local Spacial = {
		enabled=false,
	}



	return Spacial
end	



-- Decompiled with the Synapse X Luau decompiler.
--[[
return function(_p)
	local Utilities = _p.Utilities 
	local CurrentCamera = game.Workspace.CurrentCamera 
	local Spacial = {
		enabled = false, 
		jewelColors = { Color3.fromRGB(157, 0, 255), Color3.fromRGB(200, 0, 113), Color3.fromRGB(226, 0, 0), Color3.fromRGB(206, 148, 0), Color3.fromRGB(0, 206, 34) }
	} 
	({}).chunk2 = { "chunkGSM", CFrame.new(617.934692, 4.79562378, 3273.05176, 0, -0.906308174, 0.4226183, -1, 0, 0, 0, -0.422618508, -0.906307817), CFrame.new() } 
	function Spacial:doWarp(p2)
		_p.MasterControl.WalkEnabled = false 
		_p.Menu:disable() 
		_p.NPCChat:say("Reality seems to be weakened here.", "You should leave quickly before this reality collapses!") 
	end 
	local Lighting = game:GetService("Lighting") 
	local RunService = game:GetService("RunService") 
	function Spacial:removeSpacial()
		if not self.enabled then
			return 
		end 
		self.enabled = false 
		spawn(function()
			--_p.modelEffects:disableJewel() 
		end) 
		if Lighting:FindFirstChild("Atmosphere") then
			local Atmosphere = Lighting:FindFirstChild("Atmosphere") 
			Utilities.pTween(Atmosphere, "Density", 0, 1.5) 
			Atmosphere:Remove() 
		end 
		RunService:UnbindFromRenderStep("shardEmitter_" .. self.UID) 
		workspace:FindFirstChild("spacialShardEmitter"):Remove() 
		self.UID = "" 
	end 
	local l__Create__3 = Utilities.Create 
	function Spacial:setupSpacial()
		if self.enabled then
			return 
		end 
		self.enabled = true 
		local HumanoidRootPart = _p.Utilities.getHumanoid().Parent.HumanoidRootPart 
		local player = _p.player 
		local Atmos = l__Create__3("Atmosphere")({
			Name = "Distortion", 
			Parent = Lighting, 
			Color = Color3.fromRGB(40, 0, 60), 
			Decay = Color3.fromRGB(0, 0, 0)
		}) 
		spawn(function()
			Utilities.pTween(Atmos, "Density", 0.75, 1.5) 
			Utilities.pTween(Atmos, "Offset", 0.2, 1.5) 
			Utilities.pTween(Atmos, "Glare", 0, 1.5) 
			Utilities.pTween(Atmos, "Haze", 10, 1.5) 
		end) 
		self.UID = Utilities.uid() 
		local Emitter = l__Create__3("Part")({
			Name = "spacialShardEmitter", 
			Parent = workspace, 
			Transparency = 1, 
			CanCollide = false, 
			Anchored = true, 
			Size = Vector3.new(50, 40, 50)
		}) 
		spawn(function()
			_p.modelEffects:animJewel(Emitter, self.jewelColors) 
		end) 
		RunService:BindToRenderStep("shardEmitter_" .. self.UID, Enum.RenderPriority.Camera.Value, function()
			Emitter.Position = HumanoidRootPart.Position 
			task.wait() 
		end) 
	end 
	return Spacial
end 
]]

