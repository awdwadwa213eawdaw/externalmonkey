local _f = require(script.Parent)
local Utilities = _f.Utilities
local ChatService = game:GetService('Chat')
local searchFns = require(script.searchFns)

local N_WALLPAPERS = 43

local pc = Utilities.class({
	className = 'PCSession',

	public = {
		nameBox            = true,
		setWPaper          = true,

		getSummary         = true,
		nickname           = true,
		getItem            = true,
		takeItem           = true,

		getSearchableLists = true,
		search             = true,
	}
}, function(PlayerData)
	local self = {
		PlayerData = PlayerData,
		id = Utilities.uid(),
		dpc = {},
		updated = {} -- updated indicates that onClose, the corresponding ServerPokemon in dpc needs to be reserialized
	}

	return self
end)

function pc:getStartPacket()
	if self.db or self.closed then return end
	local PlayerData = self.PlayerData

	local db = {}
	local dbReverse = {}
	local count = 0
	local function addPokemon(pokemon, box, pos)
		if dbReverse[pokemon] then return end
		dbReverse[pokemon] = true
		count = count + 1
		db[count] = {pokemon, box, pos}
		return box==0 and -- note that [5] is used by the client to indicate wasOriginallyInParty
			{count, pokemon:getIcon(), pokemon.shiny and true or false, not pokemon.egg and pokemon.hp > 0}--, pokemon.item and true or false}
			or
			{count, pokemon[1], pokemon[2], pokemon[1] < 1450} -- egg threshold
	end
	local party = {}
	for i, p in pairs(PlayerData.party) do
		party[i] = addPokemon(p, 0, i)
	end
	local boxes = {}
	local pcBoxes = PlayerData.pc.boxes
	for b = 1, PlayerData.pc.maxBoxes do
		local pcBox = pcBoxes[b]
		local box = {}
		local add = false
		for p = 1, 30 do
			local pokemon = pcBox[p]
			if pokemon then
				add = true
				box[tostring(p)] = addPokemon(pokemon, b, p)
			end
		end
		if add then
			boxes[tostring(b)] = box
		end
	end

	self.db = db
	self.dbCount = count
	dbReverse = nil
	local boxNames = {}
	for box, name in pairs(PlayerData.pc.boxNames) do
		boxNames[tostring(box)] = name
	end
	local boxWallpapers = {}
	for box, wallpaper in pairs(PlayerData.pc.boxWallpapers) do
		boxWallpapers[tostring(box)] = wallpaper
	end
	return {
		id = self.id,
		party = party,
		boxes = boxes,
		maxBoxes = PlayerData.pc.maxBoxes,
		cBox = PlayerData.pc.currentBox,
		bNames = boxNames,
		bBacks = boxWallpapers
	}
end

function pc:nameBox(box, name)
	if type(box) ~= 'number' or math.floor(box) ~= box or box < 1 or box > 50 or type(name) ~= 'string' then return end
	local defaultName = 'Box '..box
	if not name:lower():match('^box %d+$') then -- bypass filter ONLY for cases that STRICTLY match the format "Box ##"
		local s, r = pcall(function() -- filter
			local player = self.PlayerData.player
			name = ChatService:FilterStringAsync(name, player, player)
			if not name or name == '' or name:match('^[#%s]+$)') then
				name = defaultName
			end
		end)
		if not s then print('censor failed:', r) end
	end
	if name == defaultName then
		self.PlayerData.pc.boxNames[box] = nil
	else
		self.PlayerData.pc.boxNames[box] = name
	end
	return name
end

function pc:setWPaper(box, wNum)
	if type(box) ~= 'number' or math.floor(box) ~= box or box < 1 or box > 50 or type(wNum) ~= 'number' or math.floor(wNum) ~= wNum or wNum < 1 or wNum > N_WALLPAPERS then return end
	if wNum == (box-1)%N_WALLPAPERS+1 then
		self.PlayerData.pc.boxWallpapers[box] = nil
	else
		self.PlayerData.pc.boxWallpapers[box] = wNum
	end
end

function pc:forAllPokes(fn)
	if self.db then
		for i, data in pairs(self.db) do
			local poke = data[1]

			if data[2] ~= 0 then
				poke = _f.ServerPokemon:deserialize(poke[3], self.PlayerData)
			end

			fn(poke, i)
		end
	end
	--local pd = self.PlayerData

	--for b, box in pairs(pd.pc.boxes) do
	--	for i = 1, 30 do
	--		local pcd = box[i]
	--		if pcd then
	--			pcall(function()
	--				local p = _f.ServerPokemon:deserialize(pcd[3], pd)
	--				if p then
	--					fn(p, pcd[1])
	--				end
	--			end)
	--		end
	--	end
	--end

	--for i, v in pairs(pd.party) do
	--	if v then
	--		fn(v, i)
	--	end
	--end
end

function pc:search(queries)

	local results = {}
	local queryTypes = {
		"species", "class",
		"generation", "nickname",
		"helditem", "moves", 
		"ability", "level", 
		"type", "flags", 
		"nature", "egggroup", 
		"gender", "form",	
	}

	self:forAllPokes(function(poke, index)
		local p = poke:getPCSearchData()
		local checks = {}
		local queryN = 0

		if p then
			for i, query in pairs(queryTypes) do
				local list = queries[query.."List"]
				local opt =  queries[query.."Option"]
				if list then
					queryN += 1
					local d = p[query]
					local mCheck -- master check

					if searchFns[query] then
						--print(opt)
						mCheck = searchFns[query](p, list, d, opt)
					else

						--if query == "moves" then
						--	print("Data:")
						--	Utilities.print_r(d)
						--	print("Query:")
						--	Utilities.print_r(list)
						--	print(tostring(mCheck))
						--end	

						mCheck = table.find(list, d) and true or false

						if opt == 2 then
							mCheck = not mCheck
						end
					end

					if mCheck then
						table.insert(checks, true)
					end
				end
			end

			--print(queryN)
			--Utilities.print_r(checks)

			if #checks == queryN and #checks ~= 0 then
				table.insert(results, index)
			end
		end
	end)

	--for i, v in pairs({"List", "Option"}) do
	--	for i, qType in pairs(queryTypes) do
	--		print(qType, ":", queries[qType..v])
	--	end
	--end

	-- "is:", "is not:", "is only:", "is any of:", "is all of:", "is none of:", "is exactly:"

	--Utilities.print_r(results)

	return results
end

function pc:getSearchableLists()
	local data = {{}, {}, {}, {}, {}, {}, {}}
	local pd = self.PlayerData

	-- Species, HeldItems, 
	-- Abilities, Moves,
	-- EggGroups, Forms,
	-- Nicknames

	self:forAllPokes(function(poke)
		local p = poke:getPCSearchData(true)
		if p then
			for num, value in pairs({'species', 'helditem', 'ability', 'moves', "egggroup", "form", "nickname"}) do
				if type(p[value]) == "table" then
					for _, c in pairs(p[value]) do
						if not table.find(data[num], c) then
							table.insert(data[num], c)
						end
					end
				elseif not table.find(data[num], p[value]) then
					table.insert(data[num], p[value])
				end
			end
		end	
	end)

	return table.unpack(data)
end

function pc:getPokemon(pid, updating)
	if self.closed then return end
	pid = tonumber(pid)
	if not pid or not self.db then return end
	local p = self.db[pid]
	if not p then return end
	if updating then
		self.updated[pid] = true
	end
	-- in party
	if p[2] == 0 then
		self.dpc[pid] = p[1]
		return p[1]
	end
	-- in PC
	local pokemon = self.dpc[pid]
	if not pokemon then
		pokemon = _f.ServerPokemon:deserialize(p[1][3], self.PlayerData)
		self.dpc[pid] = pokemon
	end
	return pokemon
end

function pc:getSummary(pid)
	local pokemon = self:getPokemon(pid)
	if not pokemon then return end
	return pokemon:getSummary{}
end

function pc:nickname(pid, name)
	local pokemon = self:getPokemon(pid, true)

	if not pokemon then return end

	if type(name) ~= 'string' or name == "" then 
		name = pokemon.name 
	end

	pokemon:giveNickname(name)
end

function pc:getItem(pid)
	local pokemon = self:getPokemon(pid)
	if not pokemon then return end
	return pokemon:getName(), pokemon:getHeldItem().name
end

function pc:takeItem(pid)
	local pokemon = self:getPokemon(pid, true)
	if not pokemon then return end
	local itemNum = pokemon:getHeldItem().num
	if not itemNum then return end
	pokemon.item = nil
	self.PlayerData:incrementBagItem(itemNum, 1)
end


function pc:close(changes)
	if self.closed then return end
	self.closed = true
	if not changes then return end
	local s, r = pcall(function() -- SHOULD WE LET THIS BREAK INSTEAD? WE DON'T WANT THE ACTIONS TO HALF-COMPLETE
		-- OR we could have it make shallowcopy boxes that replace the boxes at the end
		-- after, such that if an error occurs, no changes are made
		local PlayerData = self.PlayerData
		local party = PlayerData.party
		--		local partyCopy = Utilities.shallowcopy(party)
		local boxes = PlayerData.pc.boxes 
		--		local boxesCopy = {} for i, b in pairs(boxes) do boxesCopy[i] = Utilities.shallowcopy(b) end
		local db = self.db
		local moves = changes.m
		local locationIsMovedTo, movedPokemon, dbDataByPokemon, pidByPokemon = {}, {}, {}, {}

		-- Verification:
		--  Each id corresponds to something in the db
		--  Each location is valid
		--  No two indices are equivalent after converted to number (i.e. '1' and '1.0'); no duplicate indices (dupe attempt)
		--  There are no two pokemon which desire to move to the same location
		--  Any slot to which something is moved, if there was something already there, it has also moved

		-- TODO: check healthiness/eggness of new party
		for i, p in pairs(moves) do
			if #p ~= 2 then return false end
			p = {tonumber(p[1]), tonumber(p[2])}
			if type(p[1]) ~= 'number' or type(p[2]) ~= 'number' then return false end
			i = tonumber(i)
			local pd = db[i]
			local pokemon = pd[1]
			if not pokemon or movedPokemon[pokemon] then return false end
			movedPokemon[pokemon] = p
			dbDataByPokemon[pokemon] = pd
			pidByPokemon[pokemon] = i
			local destination_hash = p[1]..'_'..p[2]
			if locationIsMovedTo[destination_hash] then return false end
			locationIsMovedTo[destination_hash] = true
		end
		local limbo = {} -- the place where the released go
		local function gett(b) return (b==-1 and limbo) or (b==0 and party) or boxes[b] end
		for _, location in pairs(movedPokemon) do
			local otherPokemon = gett(location[1])[location[2] ] -- may be ServerPokemon or array
			if otherPokemon and not movedPokemon[otherPokemon] then return false end -- other would get overwritten
		end

		-- VERIFIED, NOW EXECUTE

		-- perform moves, without clearing where we move from
		for pokemon, destination in pairs(movedPokemon) do
			local pd = dbDataByPokemon[pokemon]
			local fromParty = pd[2] == 0
			local toParty   = destination[1] == 0
			if fromParty ~= toParty then
				local pid = pidByPokemon[pokemon]
				if fromParty then
					-- moving from party to pc
					if self.updated[pid] then
						-- updated and cached, serialize that
						local cPoke = self.dpc[pid]
						if cPoke.name == 'Shaymin' and cPoke.forme == 'sky' then
							cPoke.forme = nil
							cPoke.data = _f.Database.PokemonById.shaymin
						end
						pokemon = {cPoke:getIcon(), cPoke.shiny and true or false, cPoke:serialize(true)}
						self.updated[pid] = nil
					else
						-- convert to pd
						if pokemon.name == 'Shaymin' and pokemon.forme == 'sky' then
							pokemon.forme = nil
							pokemon.data = _f.Database.PokemonById.shaymin
						end
						pokemon = {pokemon:getIcon(), pokemon.shiny and true or false, pokemon:serialize(true)}
						-- destroy ServerPokemon?
					end
				else
					-- moving from pc to party
					if self.updated[pid] then
						-- updated and cached, use that
						pokemon = self.dpc[pid]
						self.updated[pid] = nil
					else
						-- convert from pd to ServerPokemon
						pokemon = _f.ServerPokemon:deserialize(pokemon[3], PlayerData)
					end
				end
			end
			gett(destination[1])[destination[2] ] = pokemon
		end
		-- now clear locations that were moved from, but not moved to
		for _, pd in pairs(dbDataByPokemon) do
			local location_hash = pd[2]..'_'..pd[3]
			if not locationIsMovedTo[location_hash] then
				gett(pd[2])[pd[3] ] = nil
			end
		end
		-- lock in cached pokemon updates that didn't cross the party-pc border
		for pid in pairs(self.updated) do
			local pd = self.db[pid]
			local originalPokemon = pd[1]
			local updatedPokemon = self.dpc[pid]
			local location = movedPokemon[originalPokemon]
			if not location then
				location = {pd[2], pd[3]}
			end
			if location[1] == 0 then
				party[location[2] ] = updatedPokemon
			elseif location[1] > 0 then -- released pokemon are ignored
				boxes[location[1] ][location[2] ] = {originalPokemon[1], originalPokemon[2], updatedPokemon:serialize(true)}
			end
		end
		-- perform heals (occurs when a party pokemon was dragged into PC and back out)
		if changes.h then
			for id in pairs(changes.h) do
				pcall(function()
					local pd = db[tonumber(id)]
					local from = pd[2]
					local destination = movedPokemon[pd[1] ]
					local to = destination[1]
					if from == 0 and to == 0 then
						PlayerData.party[destination[2] ]:heal()
					end
				end)
			end
		end
		PlayerData.pc.currentBox = math.max(1, math.min(PlayerData.pc.maxBoxes, math.floor(tonumber(changes.cb) or PlayerData.pc.currentBox)))
		return true
	end)

	local firstNonEgg = self.PlayerData:getFirstNonEgg()
	_f.Connection:post('PDChanged', self.PlayerData.player, 'firstNonEggLevel', firstNonEgg.level,
		'firstNonEggAbility', firstNonEgg:getAbilityName())

	if not s then
		print('PC CLOSE ERROR:', r)
		spawn(function()
			pcall(function()
				_f.Logger:logError(self.player,{
					ErrType = "PC Close Error",
					Errors = tostring(r)
				})
			end)
		end)
		return false
	end
	self.PlayerData:checkForHatchables(true)
	self:Remove()
	return r
end

function pc:Remove()
	self.PlayerData = nil
	self.db = nil
	self.dpc = nil
end

return pc