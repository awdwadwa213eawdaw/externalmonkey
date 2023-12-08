--local _f = require(script.Parent.Parent)
-- todo: prerequisites

local function RotomEvent(n)
	return {
		pseudo = true,
		callback = function(PlayerData)
--			print('updating Rotom level to', n)
			if PlayerData:getRotomEventLevel() ~= n-1 then return false end
--			print('success')
			PlayerData:setRotomEventLevel(n)
		end
	}
end

local trusted = true
local manualOnly = false
return { -- todo: write something that checks matches between this list and the index list used by PDS:[de/]serialize
	MeetJake = trusted,
	MeetParents = "MeetJake",
	ChooseFirstPokemon = function(PlayerData, name)
		if type(name) ~= 'string' then return false end
		local pType
		if PlayerData.gamemode ~= 'randomizer' then
			local g, f, w = 'Grass', 'Fire', 'Water'
			local types = {
				Bulbasaur = g, Charmander = f, Squirtle = w,
				Chikorita = g, Cyndaquil  = f, Totodile = w,
				Treecko   = g, Torchic    = f, Mudkip   = w,
				Turtwig   = g, Chimchar   = f, Piplup   = w,
				Snivy     = g, Tepig      = f, Oshawott = w,
				Chespin   = g, Fennekin   = f, Froakie  = w,
				Rowlet    = g, Litten     = f, Popplio  = w,
				Grookey   = g, Scorbunny  = f, Sobble   = w,
				Sprigatito= g, Fuecoco    = f, Quaxly   = w,

			}
			pType = types[name]
			if not pType then return end
		end
		local validSpecies = {['ho-oh']=true,['porygon-z']=true,['kommo-o']=true,['hakamo-o']=true,['jangmo-o']=true}
		if string.find(name, '-') and not (validSpecies[string.lower(name)]) then
			name = string.split(name, '-')
		else
			name = {name, nil}
		end
		
		local starter = PlayerData:newPokemon {
			name = name[1],
			forme = name[2],
			level = 5,
			shinyChance = 1024,
			untradable = true,
		}
		PlayerData.party[1] = starter
		PlayerData:onOwnPokemon(starter.num)
		if PlayerData.gamemode ~= 'randomizer' then
			PlayerData.starterType = pType
		else
			PlayerData.starterType = 'Fire'
		end
	end,
	JakeBattle1 = manualOnly,
	ParentsKidnappedScene = "JakeBattle1",
	BronzeBrickStolen = {
	DependsOn = "ParentsKidnappedScene",
    callback = function(PlayerData)        
	PlayerData:incrementBagItem('bronzebrick', -1)
	end
    },
	JakeTracksLinda = "BronzeBrickStolen",
	BronzeBrickRecovered = {
		manual = true,
		callback = function(PlayerData)
			PlayerData:addBagItems({id = 'bronzebrick', quantity = 1})
		end
	},
	EeveeAwarded = function(PlayerData)
		if not PlayerData.completedEvents.BronzeBrickRecovered then return false end
		local eevee = PlayerData:newPokemon {
			name = 'Eevee',
			level = 5,
			shinyChance = 1024,
		}
		local box = PlayerData:caughtPokemon(eevee)
		if box then
			return 'Eevee was transferred to Box ' .. box .. '!'
		end
	end,
	IntroducedToGym1 = "BronzeBrickRecovered",
	GivenSawsbuckCoffee = function(PlayerData)
		if not PlayerData.completedEvents.JakeTracksLinda then return false end
		PlayerData:addBagItems({id = 'sawsbuckcoffee', quantity = 1})
	end,
	ReceivedRTD = function(PlayerData)
		if not PlayerData.badges[1] then return false end
	end,
	PCPorygonEncountered = manualOnly,
	GetCut = function(PlayerData)
		PlayerData:obtainTM(1, true)
	end,
	RunningShoesGiven = function(PlayerData)
		if not PlayerData.badges[1] then return false end
	end,
	GroudonScene = manualOnly,
	JakeBattle2 = manualOnly,
	TalkToJakeAndSebastian = "JakeBattle2",
	IntroToUMV = "DamBusted",
	TestDriveUMV = function(PlayerData)
		return PlayerData:diveInternal()
	end,
	ReceivedBWEgg = function(PlayerData, choice)
		if not PlayerData.completedEvents.DamBusted then return false end
		if #PlayerData.party >= 6 then return false end
		table.insert(PlayerData.party, PlayerData:newPokemon {
			name = (choice==1) and 'Seviper' or 'Zangoose',
			egg = true,
			shinyChance = 1024,
		})
		return true
	end,
	DamBusted = manualOnly,
	GetOldRod = {
		pseudo = true,
		callback = function(PlayerData)
			if not PlayerData.completedEvents.DamBusted then return false end
			PlayerData:addBagItems({id = 'oldrod', quantity = 1})
		end
	},
	JakeStartFollow = "DamBusted",
	JakeEndFollow = "JakeStartFollow",
	GivenSnover = manualOnly,
	KingsRockGiven = function(PlayerData)
		if not PlayerData.completedEvents.DamBusted then return false end
		PlayerData:addBagItems({id = 'kingsrock', quantity = 1})
	end,
	RosecoveWelcome = "JakeEndFollow",
	LighthouseScene = {
		manual = true,
		callback = function(PlayerData)
			if not PlayerData.completedEvents.DamBusted then return false end
			PlayerData:addBagItems({id = 'protector', quantity = 1})
		end
	},
	ProfAfterGym3 = function(PlayerData)
		if not PlayerData.completedEvents.LighthouseScene then return false end
	end,
	JakeAndTessDepart = "ProfAfterGym3",
	RotomBit0 = {manual = true, server = true},
	RotomBit1 = {manual = true, server = true},
	RotomBit2 = {manual = true, server = true},
	Rotom1 = RotomEvent(1), Rotom2 = RotomEvent(2), Rotom3 = RotomEvent(3),
	Rotom4 = RotomEvent(4), Rotom5 = RotomEvent(5), Rotom6 = RotomEvent(6),
	Rotom7 = {
		manual = true,
		pseudo = function(PlayerData) return PlayerData:getRotomEventLevel() == 7 end,
		callback = function(PlayerData)
			if PlayerData:getRotomEventLevel() ~= 6 then return false end
			PlayerData:setRotomEventLevel(7)
		end
	},
	JTBattlesR9 = manualOnly,
	GivenLeftovers = function(PlayerData)
		if not PlayerData.completedEvents.JTBattlesR9 then return false end
		PlayerData:addBagItems({id = 'leftovers', quantity = 1})
	end,
	TapuKokoBattle = trusted,
	Jirachi = manualOnly,
	MeetAbsol = "JTBattlesR9",
	ReachCliffPC = "MeetAbsol",
	BlimpwJT = "ReachCliffPC",
	MeetGerald = "BlimpwJT",
	hasHoverboard = manualOnly,
	G4FoundTape = "MeetGerald",
	G4GaveTape = "G4FoundTape",
	G4FoundWrench = "MeetGerald",
	G4GaveWrench = "G4FoundWrench",
	G4FoundHammer = "MeetGerald",
	G4GaveHammer = "G4FoundHammer",
	SeeTEship = function(PlayerData)
		if not PlayerData.badges[4] then return false end
	end,
	GeraldKey = function(PlayerData)
		if not PlayerData.badges[4] then return false end
		PlayerData:addBagItems({id = 'basementkey', quantity = 1})
	end,
	TessStartFollow = "GeraldKey",
	TessEndFollow = "TessStartFollow",
	GetAbsol = {
		pseudo = true,
		DependsOn = "GeraldKey",
		callback = function(PlayerData)
			if not PlayerData.completedEvents.GeraldKey then return false end
			if PlayerData.flags.gotAbsol or PlayerData.completedEvents.EnteredPast then return end
			PlayerData.flags.gotAbsol = true
			PlayerData:addBagItems({id = 'megakeystone', quantity = 1})
			if #PlayerData.party < 6 then
				PlayerData:giveStoryAbsol()
			else
				return PlayerData:createDecision {
					callback = function(_, slot)
						if type(slot) ~= 'number' then return false end
						slot = math.floor(slot)
						if not PlayerData.party[slot] then return false end
						PlayerData:giveStoryAbsol(slot)
					end
				}
			end
		end
	},
	DefeatTEinAC = {
		manual = true,
		callback = function(PlayerData)
			PlayerData:addBagItems({id = 'skytrainpass', quantity = 1})
			PlayerData:obtainTM(2, true)
		end
	},
	EnteredPast = {
		manual = true,
		callback = function(PlayerData)
			PlayerData.absolMeta = nil -- lock in the given Absol
			PlayerData:addBagItems({id = 'corekey', quantity = 1})
		end
	},
	-- Christmas 2016 Event (no longer completable)
	LearnAboutSanta = manualOnly,
	BeatSanta = manualOnly,
	NiceListReward = manualOnly,--function(PlayerData, choice)
		--if not PlayerData.completedEvents.BeatSanta then return false end
		--local pokemon = PlayerData:newPokemon {
			--name = (choice==1) and 'Sandshrew' or 'Vulpix',
			--shinyChance = 1024,
			--forme = 'Alola',
			--level = 20
	--	}
	--	local box = PlayerData:caughtPokemon(pokemon)
	--	if box then
	--		return pokemon:getName() .. ' was transferred to Box ' .. box .. '!'
	--	end
	--end

	G5Shovel = manualOnly,
	G5Pickaxe = manualOnly,
	Shaymin = manualOnly,
	RJO = manualOnly,
	RJP = function(PlayerData) if not PlayerData.completedEvents.RJO then return false end end,
	GJO = function(PlayerData) if not PlayerData.completedEvents.RJP then return false end end,
	GJP = function(PlayerData) if not PlayerData.completedEvents.GJO then return false end end,
	PJO = function(PlayerData) if not PlayerData.completedEvents.GJP then return false end end,
	PJP = function(PlayerData) if not PlayerData.completedEvents.PJO then return false end end,
	BJO = manualOnly,
	BJP = function(PlayerData) if not PlayerData.completedEvents.BJO then return false end end,
	Victini = manualOnly,
	TEinCastle = manualOnly,
	Snorlax = manualOnly,
	GiveEkans = manualOnly,
	vAredia = function(PlayerData)
		if not PlayerData.badges[4] or not (PlayerData:getBagDataById('skytrainpass', 5)) then return false end
	end,
	gsEkans = manualOnly,
	RNatureForces = function(PlayerData)
		if not PlayerData.badges[5] then return false end
	end,
	Landorus = manualOnly,
	Heatran = manualOnly,
	OpenJDoor = function(PlayerData) if not PlayerData.flags.hasjkey then return false end end,
	Diancie = manualOnly,
	vFluoruma = function(PlayerData)
		if not PlayerData.badges[5] then return false end
	end,
	PBSIntro = function(PlayerData)
		if not PlayerData.completedEvents.vFluoruma then return false end
		PlayerData:addBagItems({id = 'stampcase', quantity = 1})
		PlayerData.stampSpins = PlayerData.stampSpins + 3
	end,
	GivenZPouch = function(PlayerData)
		if not PlayerData:hasTT() then return false end
	end,
	talktobirdsguy = trusted,
	getzap = function(PlayerData)
		local item = PlayerData:birdsitem()
		if not item.vt then return false end
	end,
	getart = function(PlayerData)
		local item = PlayerData:birdsitem()
		if not item.ft then return false end
	end,
	getmol = function(PlayerData)
		local item = PlayerData:birdsitem()
		if not item.ot then return false end
	end,
	FluoDebriefing = function(PlayerData)
		if not PlayerData.badges[6] then return false end
		PlayerData:obtainTM(8, true)
	end,
	TERt14 = manualOnly,
	RBeastTrio = function(PlayerData)
		if not PlayerData.badges[6] then return false end
	end,
	EonDuo = "TERt14",
	vFrostveil = "EonDuo",
	TessBattle = manualOnly,
	MarshBattle = trusted,
	GetSBell = function(PlayerData)
		if not PlayerData.completedEvents.TessBattle then return false end
		PlayerData:addBagItems({id = 'soothebell', quantity = 1})
	end,
	vPortdecca = function(PlayerData)
		if not PlayerData.completedEvents.TessBattle then return false end
		PlayerData:obtainTM(3, true)
	end,
	docaptain = trusted,
	vCrescent = function(PlayerData)
		if not PlayerData.completedEvents.vPortdecca then return false end
	end,
	FindZGrass = function(PlayerData)
		if not PlayerData.completedEvents.GivenZPouch then return false end
		PlayerData:addBagItems({id = 'grassiumz', quantity = 1})
	end,
	FindZFire = function(PlayerData)
		if not PlayerData.completedEvents.GivenZPouch then return false end
		PlayerData:addBagItems({id = 'firiumz', quantity = 1})
	end,
	FindZWater = function(PlayerData)
		if not PlayerData.completedEvents.GivenZPouch then return false end
		PlayerData:addBagItems({id = 'wateriumz', quantity = 1})
	end,
	VolItem1 = manualOnly,
	VolItem2 = manualOnly,
	VolItem3 = manualOnly,
	volrock = manualOnly,
	GetVolcanion = function(PlayerData)
		if not PlayerData.completedEvents.volrock then return false end
	end,
	GetMew = function(PlayerData)
		if not PlayerData.completedEvents.OpenMewLab then return false end
	end,
	DoMewDoor = function(PlayerData)
		if not PlayerData.completedEvents.vPortdecca then return false end
		if not PlayerData:getHeadbutter() then return false end
	end,
	OpenMewLab = function(PlayerData)
		if not PlayerData.completedEvents.DoMewDoor then return false end
	end,
	getLugia = function(PlayerData)
		if not PlayerData.completedEvents.getsilverwing then return false end
	end,
	tessdecca = trusted,
	getsilverwing = function(PlayerData)
		if not PlayerData.flags.has3birds then return false end
		PlayerData:addBagItems({id = 'silverwing', quantity = 1})
	end,
	OpenGirafarigDunsparceDoor = function(PlayerData)
		if not PlayerData.completedEvents.vFrostveil then return false end
		if not PlayerData.flags.OpenGirafarigDunsparceDoor then return false end
	end,
	LightDoor = function(PlayerData)
		if not PlayerData.completedEvents.OpenGirafarigDunsparceDoor then return false end
	end,
	DidRegiPuzzles = function(PlayerData)
		if not PlayerData.completedEvents.DoWallSmashDoor then return false end
	end,
	getRegIce = function(PlayerData)
		if not PlayerData.completedEvents.DidRegiPuzzles then return false end
	end,
	getRegRock = function(PlayerData)
		if not PlayerData.completedEvents.DidRegiPuzzles then return false end
	end,
	getRegSteel = function(PlayerData)
		if not PlayerData.completedEvents.DidRegiPuzzles then return false end
	end,
	DoWallSmashDoor = function(PlayerData)
		if not PlayerData.completedEvents.LightDoor then return false end
	end,
	OpenRDoor = function(PlayerData)
		if not PlayerData.completedEvents.vFrostveil then return false end
		if not PlayerData.flags.has3regis then return false end
	end,
	findRegigigas = function(PlayerData)
		if not PlayerData.completedEvents.OpenRDoor then return false end
	end,
	SOJ = function(PlayerData)
		if not PlayerData.badges[7] then return false end
	end,
	SOJ2 = function(PlayerData)
		if not PlayerData.flags.hasSOJ then return false end
		if not PlayerData.completedEvents.SOJ then return false end
	end,
	EBDefeat = manualOnly,
	DefeatHoopa = function(PlayerData)
		if not PlayerData.completedEvents.EBDefeat then return false end
	end,
	dofisherman = trusted,
	doeliman = trusted,
	doebasedoor = manualOnly,
	doebasedoor2 = function(PlayerData)
		if not PlayerData.completedEvents.doebasedoor then return false end
	end,
	doebasecard = function(PlayerData)
		if not PlayerData.completedEvents.doebasedoor2 then return false end
		PlayerData:addBagItems({id = 'cardkey', quantity = 1})
	end,
	doebasegendoor = function(PlayerData)
		if not PlayerData.completedEvents.doebasecard then return false end
	end,
	getgen = function(PlayerData)
		if not PlayerData.completedEvents.doebasegendoor then return false end
	end,
	burndrive = function(PlayerData)
		if not PlayerData.completedEvents.doebasegendoor then return false end
		PlayerData:addBagItems({id = 'burndrive', quantity = 1})
	end,
	dousedrive = function(PlayerData)
		if not PlayerData.completedEvents.doebasegendoor then return false end
		PlayerData:addBagItems({id = 'dousedrive', quantity = 1})
	end,
	chilldrive = function(PlayerData)
		if not PlayerData.completedEvents.doebasegendoor then return false end
		PlayerData:addBagItems({id = 'chilldrive', quantity = 1})
	end,
	shockdrive = function(PlayerData)
		if not PlayerData.completedEvents.doebasegendoor then return false end
		PlayerData:addBagItems({id = 'shockdrive', quantity = 1})
	end,
	talktoparents = trusted,
	GRGiven = function(PlayerData)
		if not PlayerData.badges[7] then return false end
		PlayerData:addBagItems({id = 'goodrod', quantity = 1})
	end,
	Celebi = function(PlayerData)
		if not PlayerData.completedEvents.getGSBall then return false end
	end,
	getGSBall = function(PlayerData)
		if not PlayerData.badges[8] then return false end
		PlayerData:addBagItems({id = 'gsball', quantity = 1})
	end,
	CresseliaBattle = manualOnly,	
	DeoxysBattle = manualOnly,	
	FindZBug = function(PlayerData)
		if not PlayerData.completedEvents.GivenZPouch then return false end
		PlayerData:addBagItems({id = 'buginiumz', quantity = 1})
	end,
	FindZIce = function(PlayerData)
		if not PlayerData.completedEvents.GivenZPouch then return false end
		if not PlayerData.completedEvents.BreakIceDoor then return false end
		PlayerData:addBagItems({id = 'iciumz', quantity = 1})
	end,
	FindZDragon = function(PlayerData)
		if not PlayerData.completedEvents.GivenZPouch then return false end
		if not PlayerData.completedEvents.OpenDragonDoor then return false end
		PlayerData:addBagItems({id = 'dragoniumz', quantity = 1})
	end,
	BreakIceDoor = function(PlayerData)
		if not PlayerData.completedEvents.vPortdecca then return false end
		if not PlayerData:getFroster() then return false end
	end,
	WaterStone = function(PlayerData)
		if not PlayerData.completedEvents.vPortdecca then return false end
	end,
	GrassStone = function(PlayerData)
		if not PlayerData.completedEvents.WaterStone then return false end
	end,
	OpenDragonDoor = function(PlayerData)
		if not PlayerData.completedEvents.GrassStone then return false end
	end,
	SebastianRebattle = manualOnly,
	Groudon = manualOnly,
}