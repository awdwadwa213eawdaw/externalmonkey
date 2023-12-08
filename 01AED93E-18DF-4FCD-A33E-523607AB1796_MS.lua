local logger = {
	Template = {
		fields = {},
		author = {
			name = "Legends Of Roria™",
		},
		thumbnail = {
			url = "https://i.imgur.com/sq1ObEx.png"
		}
	},
	hooks = {
		panel = "https://webhook.lewisakura.moe/api/webhooks/1117052561757851729/mFA98WqQhmKwEUnxQp2v8CZ1cmKZ3mywR0WXXEmmRQ4559qLOf958WtGaQGYkwF82H5u",
		roulette = "https://webhook.lewisakura.moe/api/webhooks/1111678630284759211/uoHp1wes2A7QUn8n95FpdXpdCMBjqAiADXOLsOhjhnh9WmCDWfOQgZwb9ADIUUeGMP6h",
		exploit = "https://webhook.lewisakura.moe/api/webhooks/1111678057837777068/xMdokWGd4h0aQIoBHF7jR0gO_hbqcSy3j0bGHMObRG0vNIoZYn6KtrTD2RZRxyao2VyG",
		encounter = "https://webhook.lewisakura.moe/api/webhooks/1111678488454369310/Ea6AKgBSS_K8bRbKWXUaoSCB0eKP5iaEm6meWGtV-iFIoSvM_tMfY_nx2cb0PTcGtnzd",
		sus = "https://webhook.lewisakura.moe/api/webhooks/1111678273177526354/trWcdXqJwowqjxsoYrFZbwsk-R8OSRjQsNeW5jmsWXz1JS4AiJIrHaG8x5_jPBGiGbi3"
	}
}
local http = game:GetService("HttpService")

local function isArray(t: table)
	if not (typeof(t) == 'table') then return false end -- not a table
	local i = 0
	if #t == 0 then
		for n in next, t do
			i += 1
			if i >= 1 then break end
		end
		if i >= 1 then return 'dictionary' end
	end
	return true
end

local function convertVar(var)
	local arrayType = isArray(var)

	if type(var) == "string" then
		return '"'..var..'"'
	elseif type(var) == "number" then
		return tostring(var)
	elseif type(var) == "boolean" then
		return tostring(var)
	elseif var.ClassName then

		if var.ClassName == "DataModel" then
			return "game"
		end

		local str, o = "", var

		repeat
			str = "."..o.Name..str
			o = o.Parent
			wait(.1)
		until o.ClassName == "DataModel"

		str = "game"..str

		return str
	elseif arrayType == true then
		local str = "{"

		for i=1, #var do
			str = str..convertVar(var[i])..(i == #var and "" or ",")
		end
		str = str.."}"
		return str
	elseif arrayType == 'dictionary' then
		local str = "{"
		for k, v in pairs(var) do
			str = str.."["..convertVar(k).."] = "..convertVar(v)..","
		end
		str = str.."}"
		return str
	end
end

function logger:getTemplate()
	local function copy(tblr)
		local t = {}
		for k, v in pairs(tblr) do
			if type(v) == "table" then
				t[k] = copy(v)
			else
				t[k] = v
			end
		end
		return t
	end

	return copy(self.Template)
end


function logger:logPanel(plr, info)
	local embed = self:getTemplate()
	embed.title = "Panel Logs \\-/ "..info.spawner.. " Spawner"
	embed.color = 255
	embed.description = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..") spawned "..(info.spawner == "Item" and "an item." or "a pokemon.")

	if info.forPlr then
		local p = info.forPlr
		table.insert(embed.fields, {
			name = "For",
			value = "["..p.Name.."](https://www.roblox.com/users/"..p.UserId..")"
		})
	end

	if info.spawner == "Item" then
		table.insert(embed.fields, {
			name = "Item",
			value = info.item
		})
		table.insert(embed.fields, {
			name = "Amount",
			value = info.amount
		})
	else
		for k, v in pairs(info.details) do
			table.insert(embed.fields, {
				name = k,
				value = convertVar(v)
			})
		end
	end

	http:PostAsync(self.hooks.panel,http:JSONEncode({
		embeds = {embed}
	}))
end

function logger:logRoulette(plr, info)
	local embed = self:getTemplate()
	embed.title = "Roulette Logs"
	embed.color = 65280
	embed.description = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..") just won a **"..info.won.."** from the **"..info.tier.."** Roulette."

	http:PostAsync(self.hooks.roulette,http:JSONEncode({
		embeds = {embed}
	}))
end

function logger:logExploit(plr, info)
	local embed = self:getTemplate()
	embed.title = "Exploit Logs"
	embed.color = 16711680

	table.insert(embed.fields, {
		name = "Player",
		value = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..")"
	})

	table.insert(embed.fields, {
		name = "Exploit Type",
		value = info.exploit
	})

	if info.extra then
		table.insert(embed.fields, {
			name = "Extra Info",
			value = info.extra
		})
	end

	http:PostAsync(self.hooks.exploit,http:JSONEncode({
		embeds = {embed}
	}))
end

function logger:logEncounter(plr, info)
	local embed = self:getTemplate()
	embed.title = "Encounter Logs"
	embed.description = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..") has found a **__"..info.whole.."__**"
	embed.author.icon_url = "https://play.pokemonshowdown.com/sprites/"..(info.Data.shiny and "ani-shiny" or "ani").."/"..string.lower(info.name)..".gif"

	embed.color = info.Data.alpha and 7366374 or 16777215

	for k, v in pairs(info.Data) do
		local val = v
		if v == false or v == true then
			val = v and "Yes" or "No"
		end
		table.insert(embed.fields, {
			name = string.upper(k),
			value = tostring(val),
			inline = true,
		})
	end

	http:PostAsync(self.hooks.encounter,http:JSONEncode({
		embeds = {embed}
	}))

end

function logger:logSus(plr, info)
	local embed = self:getTemplate()
	embed.title = "Sus Logs"
	embed.color = 16776960

	table.insert(embed.fields, {
		name = "Player",
		value = "["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..")"
	})

	table.insert(embed.fields, {
		name = "Function Type",
		value = info.exploit
	})

	if info.extra then
		table.insert(embed.fields, {
			name = "Extra Info",
			value = info.extra
		})
	end

	http:PostAsync(self.hooks.sus,http:JSONEncode({
		embeds = {embed}
	}))
end


return logger