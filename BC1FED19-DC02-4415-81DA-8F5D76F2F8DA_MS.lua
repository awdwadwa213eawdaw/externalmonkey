return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local stepped = game:GetService("RunService").RenderStepped
	local lighting = game:GetService("Lighting")
	local fog = {
		enabled=false,
		testing=true
	}
--[[
  Notes:
		Fix chunk.data.lighting in disableFog()
		Adjust FOV for battles
		Add music
		More Variants: 
			Smog
			Fog
  ]]
	local RunService = game:GetService("RunService")

	function fog:pulsateFog(object, data)
		if not object then object = self.Atmosphere end
		local savedDensity = object.Density

		if self.pulsateEnabled then
			RunService:UnbindFromRenderStep("Pulsate")
		else
			RunService:BindToRenderStep("Pulsate", Enum.RenderPriority.Camera.Value, function()
				Utilities.Tween(data.timing/2, "easeOutCubic", function(a)
					object.Density = object.Density - (object.Density*a)
				end)
				Utilities.Tween(data.timing/2, "easeOutCubic", function(a)
					object.Density = (savedDensity*a)
				end)
			end)
		end
	end
	function fog:enableFog(tweenTime, FOV, variant) --Should I require fog type e.g smog n such? _p.Weather.Fog:enableFog(1.26)
		if self.enabled then
			return 
		end
		self.enabled = true
		if not FOV then --Never give FOV unless via cutscenes
			FOV = 230
		end
		local def = {}
		if variant == 'smog' then
			def = {
				AtmoCD = Color3.fromRGB(63, 48, 65),
				FogColor = Color3.fromRGB(95, 67, 91),
				OutdoorAmbient = Color3.fromRGB(150, 115, 131),
				--Density = .206
			}
			--FOV = 450
		elseif variant == 'bloodmoon' then
			def = {
				AtmoCD = Color3.fromRGB(75, 28, 0),
				FogColor = Color3.fromRGB(95, 39, 0),
				OutdoorAmbient = Color3.fromRGB(150, 51, 0),
				Density = .604
			}
		elseif variant == 'snow' then
			def = {
				AtmoCD = Color3.fromRGB(191, 191, 191),
				FogColor = Color3.fromRGB(102, 102, 102),
				OutdoorAmbient = Color3.fromRGB(153, 153, 153),
			}
		elseif variant == 'sandstorm' then
			def = {
				AtmoCD = Color3.fromRGB(157, 134, 0),
				FogColor = Color3.fromRGB(123, 114, 0),
				OutdoorAmbient = Color3.fromRGB(213, 206, 85),
				Density = .704
			}
		else --Default fog
			def = {
				AtmoCD = Color3.fromRGB(191, 191, 191),
				FogColor = Color3.fromRGB(102, 102, 102),
				OutdoorAmbient = Color3.fromRGB(153, 153, 153),
			}
		end

		local sky = lighting:FindFirstChildOfClass("Sky") --Why do I mention it here?  Because I'm slick and change it depending on area
		if sky then
			sky.CelestialBodiesShown = false
			sky.StarCount = 0
		end   
		self.Atmosphere = create("Atmosphere")({
			Density = 0, 
			Offset = 0, 
			Color = def.AtmoCD, --Color3.fromRGB(125, 125, 125), 
			Decay = def.AtmoCD, --Color3.fromRGB(125, 125, 125), 
			Glare = 0, 
			Haze = 0,
			Parent = lighting
		})
		lighting.FogColor = def.FogColor
		if tweenTime then
			Utilities.spTween(lighting, "Brightness", 0, tweenTime, nil, nil, function()
				--_p.DataManager:lockClockTime(6.2) --Modify?
			end)
			Utilities.spTween(lighting, "ExposureCompensation", 0, tweenTime)
			Utilities.spTween(lighting, "OutdoorAmbient", def.OutdoorAmbient, tweenTime)
			Utilities.spTween(self.Atmosphere, "Density", def.Density or 0.506, tweenTime)
			Utilities.spTween(self.Atmosphere, "Haze", def.Haze or 2.21, tweenTime)
		else
			--_p.DataManager:lockClockTime(6.2)
			lighting.Brightness = 0
			lighting.ExposureCompensation = 0
			lighting.OutdoorAmbient = def.OutdoorAmbient --Color3.fromRGB(70, 70, 70)
			lighting.FogEnd = FOV
		end
	end
	--Add function to tween already existing fog?
	function fog:disableFog(fadeTime)
		if not self.enabled then return end
		self.enabled = false
		local sky = lighting:FindFirstChildOfClass("Sky") --Why do I mention it here?  Because I'm slick and change it depending on area
		if sky then
			sky.CelestialBodiesShown = true
			sky.StarCount = 3000
		end
		if fadeTime then
			Utilities.spTween(lighting, "Brightness", _p.Constants.LIGHTING_BRIGHTNESS, fadeTime)
			Utilities.spTween(lighting, "ExposureCompensation", _p.Constants.LIGHTING_EXPOSURE_COMPENSATION, fadeTime)
			Utilities.spTween(lighting, "OutdoorAmbient", _p.Constants.LIGHTING_OUTDOOR_AMBIENT, fadeTime)
			Utilities.spTween(lighting, "FogEnd", 100000, fadeTime)
			Utilities.spTween(self.Atmosphere, "Density", 0, fadeTime)
			Utilities.spTween(self.Atmosphere, "Haze", 0, fadeTime)
		else
			lighting.Brightness = .3
			lighting.ExposureCompensation = 1
			lighting.FogColor = Color3.fromRGB(96, 146, 163)
			lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
			lighting.FogEnd = 100000
		end
		--_p.DataManager:unlockClockTime()
		local atmo = self.Atmosphere
		atmo:Remove()
		self.Atmosphere = nil
		--end
	end
	return fog
end	