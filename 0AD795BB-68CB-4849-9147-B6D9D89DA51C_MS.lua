return function(_p)
	local Create = _p.Utilities.Create;
	local v2 = Instance.new("Attachment")
	local u1 = {}
	local Terrain = workspace.Terrain
	local u3 = Create("Trail")({
		Color = ColorSequence.new(Color3.new(1, 1, 1)), 
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.25, 0.5), NumberSequenceKeypoint.new(0.75, 0.75), NumberSequenceKeypoint.new(1, 1) }), 
		WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 1) }), 
		LightInfluence = 0, 
		LightEmission = 0
	})
	local u4 = false
	local WindEffect = {
		enabled = false,
		windFocus = nil,
		useCameraPosition = false
	}
	local u6 = Vector3.new(0, 1, 0);
	local u7 = Random.new();
	local u8 = Create("ParticleEmitter")({
		Color = ColorSequence.new(Color3.fromRGB(134, 255, 90)), 
		LightEmission = 0, 
		LightInfluence = 0, 
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 0.5), NumberSequenceKeypoint.new(0.7, 0.5), NumberSequenceKeypoint.new(1, 0) }), 
		Texture = "rbxassetid://242830579", 
		Transparency = NumberSequence.new(0, 1), 
		Acceleration = Vector3.new(0, -2, 0), 
		EmissionDirection = Enum.NormalId.Front, 
		Enabled = false, 
		Rotation = NumberRange.new(0, 360), 
		RotSpeed = NumberRange.new(-360, 360), 
		SpreadAngle = Vector2.new(0, 0), 
		Parent = v2
	})
	local function u9(p2, p3)
		local v3 = #u1		
		local v5 
		local v6
		if v3 > 0 then
			local v4 = table.remove(u1, v3)
			v5 = v4[1]
			v6 = v4[2]
			v5.Trail.Lifetime = p3
			v5.Position = p2
			v6.Position = p2
			v5.Parent = Terrain
			v6.Parent = Terrain
		else
			v5 = Instance.new("Attachment", Terrain)
			v6 = Instance.new("Attachment", Terrain)
			v5.WorldPosition = p2
			v6.WorldPosition = p2
			local v7 = u3:Clone()
			v7.Attachment0 = v5
			v7.Attachment1 = v6
			v7.Lifetime = p3
			v7.Parent = v5
		end
		return v5, v6
	end
	local u10 = {}
	local u11 = 0
	local u12 = 0
	local u13 = 0
	local u14 = nil
	local RunService = game:GetService("RunService")
	local function u16(p4, p5)
		local u17 
		if WindEffect.useCameraPosition then WindEffect.windFocus = workspace.CurrentCamera.CFrame.Position end
		pcall(function()
			u17 = WindEffect.windFocus or _p.player.Character.HumanoidRootPart.Position
		end)
		if not u17 then
			return
		end
		local v8 = p4:Cross(u6) * u7:NextNumber(-150, 150)
		local v9 = u17 + Vector3.new(0, u7:NextNumber(5, 60), 0) - p4 * u7:NextNumber(150, 300) + v8
		if u7:NextInteger(1, 100) <= 40 then
			v2.CFrame = CFrame.lookAt(v9, v9 + p4) - v8 * 0.5
			u8.Speed = NumberRange.new(p5 * 0.25, p5 * 0.5)
			u8.Lifetime = NumberRange.new(600 / p5, 1200 / p5)
			u8.Acceleration = Vector3.new(0, u7:NextNumber(-6, 2), 0)
			u8:Emit(1)
		end
		local v10 = u7:NextNumber(0.4, 0.6)
		local v11 = u7:NextNumber(0.1, 0.15)
		local v12 = u7:NextNumber(1, 4)
		local v13 = u7:NextNumber(0, 2 * math.pi)
		local v14 = 300 / p5 * v11 + 0.2
		local v15 = os.clock()
		local v16 = Vector3.new(0, -v10, 0)
		local v17, v18 = u9(v9, v14)
		table.insert(u10, { os.clock(), 1, 600 / p5, v14, v9, p4 * p5, v11, v12 + p5 / 150, v13, v17, v18, v16, 0 })
	end
	local function u18(p6, p7)
		if not u4 then
			p6:Remove()
			p7:Remove()
			return
		end
		p6.Parent = nil
		p7.Parent = nil
		table.insert(u1, { p6, p7 })
	end
	function WindEffect:Enable(p9, p10, p11)
		if self.enabled then
			return
		end
		self.enabled = true
		if p9 then
			u11 = math.atan2(p9.X, p9.Z);
		else
			u11 = 0
		end
		u12 = p10 or 0
		u13 = os.clock() - (p11 or 0)
		u14 = _p.DataManager.currentChunk
		if not u4 then
			u4 = true
			v2.Parent = Terrain
			local u19 = 0
			RunService:BindToRenderStep("loomOverworldWindEffect", Enum.RenderPriority.Last.Value, function(p12)
				local v19 = os.clock();
				if self.enabled and #u10 < 50 and v19 - u19 > 0.03 and ((not u14 or not u14.indoors) and u7:NextInteger(1, 100) <= 17) then
					u19 = v19
					local v20 = u11 + 1.2 * math.noise(u12, (v19 - u13) * 0.02, 0)
					u16(Vector3.new(math.sin(v20), 0, math.cos(v20)), 150 * u7:NextNumber(1, 1.5))
				end
				local v21 = #u10
				if not (v21 > 0) then
					if not self.enabled then
						u4 = false
						RunService:UnbindFromRenderStep("loomOverworldWindEffect")
						v2.Parent = nil
						for v22, v23 in ipairs(u1) do
							v23[1]:Remove()
							v23[2]:Remove()
						end
						table.clear(u1)
					end
					return
				end
				for v24 = v21, 1, -1 do
					local v25 = nil
					local v26 = u10[v24]
					v25 = v19 - v26[1]
					if v26[2] == 1 then
						if v26[3] < v25 then
							v26[2] = 2
							v26[1] = v26[1] + v26[3]
						else
							v26[13] = v26[13] + v26[7] * math.sin(v26[8] * v25 + v26[9])
							local v27 = v26[5] + v26[6] * v25 + Vector3.new(0, v26[13], 0)
							v26[10].Position = v27
							v26[11].Position = v27 + v26[12]
						end
					elseif v26[4] < v25 then
						u10[v24] = u10[v21]
						u10[v21] = nil
						v21 = v21 - 1
						u18(v26[10], v26[11])
					end
				end
			end)
		end
	end
	function WindEffect:Disable(p14)
		if not self.enabled then
			return
		end
		self.enabled = false
		if p14 then
			self:Clear()
			for v28, v29 in ipairs(u10) do
				v29[10]:Remove()
				v29[11]:Remove()
			end
			table.clear(u10)
		end
	end
	return WindEffect
end