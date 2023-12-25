local _f = require(game:GetService('ServerScriptService'):WaitForChild('SFramework'))

local kmanVolume = 1
local routeMusicVolume = kmanVolume

local uid = require(game:GetService('ServerStorage').Utilities).uid

local encounterLists = {}
local function EncounterList(list)
	local isMetadata = false
	-- check a random key, if it is not a number then this is metadata
	for i in pairs(list) do if type(i) ~= 'number' then isMetadata = true end break end
	if isMetadata then
		return function(actualList)
			local eld = EncounterList(actualList)
			local t = encounterLists[eld.id]
			for k, v in pairs(list) do
				t[k] = v
			end
			return eld
		end
	end
	-- modify lists here (e.g. for a new version of October2k16's Haunter event)
	--[[local function modList(list)
		local totalWeightD = 0
		local totalWeightN = 0
		local minLevel = 100
		local maxLevel = 1
		for _, encounter in pairs(list) do
			local w = encounter[4] * 20
			encounter[4] = w
			if encounter[5] ~= 'night' then totalWeightD = totalWeightD + w end
			if encounter[5] ~= 'day'   then totalWeightN = totalWeightN + w end
			minLevel = math.min(minLevel, encounter[2])
			maxLevel = math.max(maxLevel, encounter[3])
		end
		local totalWeight = (totalWeightD+totalWeightN)/2
		if totalWeight == 0 then return end
		list[#list+1] = {'Haunter', minLevel, maxLevel, totalWeight/500, nil, true, 'hallow'}
	end
	modList(list) Halloween 2021]]--

	local id = uid()--#encounterLists + 1 -- prefer uid, because it prevents guessing and makes every server unique
	while encounterLists[id] do id = uid() end
	encounterLists[id] = {id = id, list = list}
	local levelDistributionDay   = {}
	local levelDistributionNight = {}
	for _, entry in pairs(list) do
		-- day
		if entry[5] ~= 'night' then
			local chancePerLevel = entry[4] / (entry[3] - entry[2] + 1)
			for level = entry[2], entry[3] do
				levelDistributionDay  [level] = (levelDistributionDay  [level] or 0) + chancePerLevel
			end
		end
		-- night
		if entry[5] ~= 'day' then
			local chancePerLevel = entry[4] / (entry[3] - entry[2] + 1)
			for level = entry[2], entry[3] do
				levelDistributionNight[level] = (levelDistributionNight[level] or 0) + chancePerLevel
			end
		end
	end
	local function convert(t)
		local new = {}
		for level, chance in pairs(t) do
			new[#new+1] = {level, chance}
		end
		return new
	end
	return {
		id = id,
		ld = {convert(levelDistributionDay),
			convert(levelDistributionNight)}
	}
end

local function ConstantLevelList(list, level)
	for _, entry in pairs(list) do
		entry[5] = entry[3] -- [5] day / night
		entry[4] = entry[2] -- [4] chance
		entry[2] = level    -- [2] min level
		entry[3] = level    -- [3] max level
	end
	return EncounterList(list)
end

local function OldRodList(list)
	local ed = ConstantLevelList(list, 10)
	encounterLists[ed.id].rod = 'old'
	return ed
end

local function GoodRodList(list)
	local ed = ConstantLevelList(list, 20)
	encounterLists[ed.id].rod = 'good'
	return ed
end

local ruinsEncounter = EncounterList {
	{'Baltoy',   29, 32, 25, nil, nil, nil, 'lightclay', 20},
	{'Natu',     29, 32, 20},
	{'Elgyem',   29, 32, 20},
	{'Sigilyph', 29, 32, 10},
	{'Ekans',    29, 32,  8},
	{'Darumaka', 29, 32,  4},
	{'Zorua',    29, 32,  2},
}

local chunks = {
	['chunk1'] = {
		buildings = {
			'Gate1',
		},
		regions = {
			['Mitis Town'] = {
				SignColor = BrickColor.new('Bronze').Color,
				Music = {15063967503, 15063971133},--288894671,
				MusicVolume = kmanVolume,
				OldRod = OldRodList {
					{'Magikarp', 100},
				},
				GoodRod = GoodRodList {
					{'Magikarp', 80},
					{'Gyarados', 5},
				}
			},
			['Route 1'] = {
				Music = 15063974896,--301381728,
				MusicVolume = kmanVolume,
				Grass = EncounterList {
					{'Pidgey',     2, 4, 25},
					{'Skwovet',    2, 4, 25},
					{'Zigzagoon',  2, 4, 20, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Bunnelby',   2, 4, 24},
					{'Rookidee',    2, 4, 13},
					{'Wurmple',    2, 4, 11, nil, nil, nil, 'brightpowder', 20, 'pechaberry', 2},
					{'Fletchling', 2, 4, 11},
					{'Sentret',    2, 4,  5, 'day'},
				},
			},
		},
	},
	['chunk2'] = {
		buildings = {
			['PokeCenter'] = {
				NPCs = {
					{
						appearance = 'Camper',
						cframe = CFrame.new(10, 0, 0),
						interact = { 'See that girl over there behind the counter?', 'She heals your pokemon.' }
					},
				},
			},
			'Gate1',
			'Gate2',
			['SawsbuckCoffee'] = {
				DoorViewAngle = 15,
			},
		},
		regions = {
			['Cheshma Town'] = {
				SignColor = BrickColor.new('Deep blue').Color,
				Music = 15063982127,
				MusicVolume = kmanVolume,
			},
			['Gale Forest'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = {15063986301, 15063990142},--288893686,
				BattleScene = 'Forest1',
				IsDark = true,
				Grass = EncounterList {
					{'Weedle',     3, 5, 20},
					{'Caterpie',   3, 5, 20},
					{'Metapod',    5, 6, 10},
					{'Kakuna',     5, 6, 10},
					{'Nidoran[F]', 3, 5, 10},
					{'Nidoran[M]', 3, 5, 10},
					{'Blipbug',    5, 6, 10},
					{'Ledyba',     3, 5, 15, 'day'},
					{'Spinarak',   3, 5, 15, 'night'},
					{'Hoothoot',   4, 6, 10, 'night'},
					{'Nickit',     4, 6,  5},
					{'Pikachu',    4, 6,  3, nil, nil, nil, 'lightball', 20},
				  --{'Mimikyu',    4, 6,  3}, -- Halloween 2021
				},
			},
			['Route 2'] = {
				RTDDisabled = true,
				Music = 15063994431,--301381862,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Pidgey',     23, 25, 10},
					{'Fletchling', 23, 25, 10},
					{'Greedent', 23, 25, 10},
					{'Dubwool', 23, 25, 10},
					{'Zigzagoon',   23, 25,  8, nil, nil, nil, 'revive', 20, 'potion', 2},
					{'Plusle',     23, 25,  2, nil, nil, nil, 'cellbattery', 20},
					{'Minun',      23, 25,  2, nil, nil, nil, 'cellbattery', 20},
				},
				OldRod = OldRodList {
					{'Magikarp', 50},
					{'Barboach', 15},
				},
				GoodRod = GoodRodList {
					{'Barboach',20},
					{'Magikarp',15},
					{'Gyarados',10},
					{'Whiscash',5},
				},
				Surf = EncounterList {
					{'Goldeen', 13,18,10, nil, nil, nil, 'mysticwater', 20},
					{'Magikarp',13,18,7},
					{'Barboach',13,18,7},
					{'Lotad',13,18,3, nil, nil, nil, 'mentalherb', 20},
				}
			},
		},
	},
	['chunk3'] = {
		buildings = {
			['Gym1'] = {
				Music = 11909965989,
				BattleSceneType = 'Gym1',
			},
			['PokeCenter'] = {
				NPCs = {
					{
						appearance = 'Rich Boy',
						cframe = CFrame.new(-23, 0, 8) * CFrame.Angles(0, -math.pi/3, 0),
						interact = { 'This PC has been acting awfully strange lately.', 'I think it needs an upgrade...' }
					},
				},
			},
			'Gate2',
			'Gate3',
		},
		regions = {
			['Route 3'] = {
				BlackOutTo = 'chunk2',
				Music = 15063994431,--301381862,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Poochyena', 5, 7, 20},
					{'Shinx',     5, 7, 20},
					{'Electrike', 5, 7, 20},
					{'Mareep',    5, 7, 20},
					{'Nincada',   5, 7, 10, nil, nil, nil, 'softsand', 20},
					{'Abra',      5, 7, 10, nil, nil, nil, 'twistedspoon', 20},
					{'Yamper', 5, 7,  5},
					{'Pachirisu', 6, 8,  4},
				}
			},
			['Silvent City'] = {
				Music = {15064040142, 15064044047},--296993609,
				SignColor = BrickColor.new('Bright yellow').Color,
				PCEncounter = EncounterList {PDEvent = 'PCPorygonEncountered'} {{'Porygon', 5, 5, 1}}
			},
			['Route 4'] = {
				RTDDisabled = true,
				Music = 15063994431,--301381862,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Pidgey', 7,  9, 25},
					{'Shinx',  7,  9, 20},
					{'Mareep', 7,  9, 20},
					{'Stunky', 7,  9, 15},
					{'Yamper', 7, 9,  10},
					{'Skiddo', 7, 10, 10},
					{'Marill', 7, 10, 10},
				}
			},
		},
	},
	['chunk4'] = {
		blackOutTo = 'chunk3',
		buildings = {
			'Gate3',
			'Gate4',
		},
		regions = {
			['Route 5'] = {
				RTDDisabled = true,
				Music = 15064053742,--301381959,
				MusicVolume = .8,
				BattleScene = 'Safari',
				Grass = EncounterList {
					{'Rellor',     8, 10, 25},
					{'Patrat',     8, 10, 25},
					{'Phanpy',     8, 10, 20},
					{'Blitzle',    8, 10, 20},
					{'Litleo',     8, 10, 20},
					{'Lechonk',    8, 10, 20},
					{'Rolycoly',   8, 10, 20},
					{'Hippopotas', 8, 10, 15},
					{'Girafarig',  9, 11,  5},
				}
			},
			['Old Graveyard'] = {
				Music = 15064057193,
				RTDDisabled = true,
				SignColor = Color3.new(.5, .5, .5),
				BattleScene = 'Graveyard',
				GrassEncounterChance = 9,
				Grass = EncounterList {
					{'Cubone',  8, 10, 40, nil, nil, nil, 'thickclub', 20},
					{'Gothita', 8, 10, 15},
					{'Impidimp', 8, 10, 15},
					{'Gastly',  8, 10, 30, 'night'},
					{'Murkrow', 8, 10, 20, 'night'},
					{'Yamask',  8, 10,  5, 'night', nil, nil, 'spelltag', 20},
				}
			},
		},
	},
	['chunk5'] = {
		buildings = {
			'Gate4', 'Gate5', 'Gate6',
			'PokeCenter',
			['Gym2'] = {
				Music = 15064063289,
				BattleSceneType = 'Gym2',
			},
		},
		regions = {
			['Brimber City'] = {
				Music = 15064066006,--316929443,
				SignColor = BrickColor.new('Crimson').Color,
				BattleScene = 'Safari', -- for Santa, if nothing else
			}
		},
	},
	['chunk6'] = {
		blackOutTo = 'chunk5',
		buildings = {
			'Gate5',
		},
		regions = {
			['Route 6'] = {
				Music = 15064053742,--301381959,
				MusicVolume = .8,
				BattleScene = 'Safari',
				Grass = EncounterList {
					{'Litleo',     11, 13, 20},
					{'Blitzle',    11, 13, 20},
					{'Sizzlipede', 11, 13, 20, 'day'},
					{'Ponyta',     11, 13, 15},
					{'Rolycoly',   11, 13, 15},
					{'Rhyhorn',    11, 13, 10},
					{'Zubat',      11, 13, 30, 'night'},
				},
				Anthill = EncounterList {Locked = true} {{'Durant', 5, 8, 1}}
			}
		}
	},
	['chunk7'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Mt. Igneus'] = {
				Music = 15064072586,
				MusicVolume = .8,
				SignColor = BrickColor.new('Cocoa').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Numel',   12, 15, 20},
					{'Sizzlipede', 12, 15, 20},
					{'Slugma',  12, 15, 20},
					{'Torkoal', 12, 15, 17, nil, false, nil, 'charcoal', 20},
					{'Magby',   12, 15,  8, nil, false, nil, 'magmarizer', 20},
					{'Heatmor', 12, 15,  5},
					{'Zubat',   12, 15, 30, 'day'},
				},
				LavaBeast = EncounterList
				{PDEvent = 'Groudon'}
				{{'Groudon', 40, 40, 1}}
			}
		}
	},
	['chunk8'] = {
		blackOutTo = 'chunk5',
		buildings = {
			'Gate6',
			'Gate7',
			['SawMill'] = {
				BattleSceneType = 'SawMill',
			},
		},
		regions = {
			['Route 7'] = {
				Music = 15064078439,
				MusicVolume = .575,
				RTDDisabled = true,
				Grass = EncounterList {
					{'Bidoof',  15, 17, 20},
					{'Poliwag', 15, 17, 15},
					{'Marill',  15, 17, 15},
					{'Wooper',  15, 17, 15},
					{'Sunkern', 15, 17, 12},
					{'Gossifleur', 15, 17, 10},
					{'Surskit', 15, 17, 10, nil, false, nil, 'honey', 2},
					{'Skitty',  15, 17, 8},
					{'Yanma',   15, 17, 8, nil, false, nil, 'widelens', 20},
					{'Hatenna', 16, 18, 7},
					{'Ralts',   16, 18, 5},
				},
				OldRod = OldRodList {
					{'Magikarp', 40},
					{'Tympole',  20},
					{'Corphish', 5},
				},
				GoodRod = GoodRodList {
					{'Tympole',20},
					{'Corphish', 14},
					{'Magikarp',6},
					{'Wishiwashi',2},
				},
				Surf = EncounterList {
					{'Bidoof',26,29,10},
					{'Tympole',26,29,7},
					{'Corphish',26,29,5},
					{'Mareanie',28,31,1}
				}
			}
		}
	},
	['chunk9'] = {
		buildings = {
			'Gate7',
			'Gate8',
			'PokeCenter',
		},
		regions = {
			['Lagoona Lake'] = {
				SignColor = BrickColor.new('Deep blue').Color,
				Music = {15064078439, 15064085212},--323074713,
				OldRod = OldRodList {
					{'Magikarp', 50},
					{'Goldeen',  10, nil,nil,nil, nil, nil, 'mysticwater', 20},
				},
				GoodRod = GoodRodList {
					{'Goldeen',20, nil,nil,nil, nil, nil, 'mysticwater', 20},
				},
				Surf = EncounterList 
				{Weather = 'primordialsea'}
				{
					{'Finizen', 26,30,3, 'night'},
					{'Goldeen', 26,30,10, nil, false, nil, 'mysticwater', 20},
					{'Gyarados', 26,30,3},
					{'Veluza', 26,30,3},
					{'Ducklett', 26,30,1},
					{'Lumineon', 28,32,5, 'night'}
				}
			},
		},
	},
	['chunk10'] = {
		blackOutTo = 'chunk9',
		buildings = {
			'Gate8',
			'Gate9',
		},
		regions = {
			['Route 8'] = {
				RTDDisabled = true,
				Music = 15064095084,
				Grass = EncounterList {
					{'Oddish',     13, 16, 40, nil, false, nil, 'absorbbulb', 20},
					{'Bellsprout', 13, 16, 40},
					{'Falinks',    13, 16, 35},
					{'Starly',     13, 16, 35},
					{'Lillipup',   13, 16, 35},
					{'Espurr',     13, 16, 25},
					{'Swablu',     13, 16, 20},
					{'Staravia',   14, 16, 15},
					{'Herdier',    14, 16, 15},
					{'Clobbopus',  14, 16, 12},
					{'Riolu',      15, 18,  4},
				},
				Well = EncounterList
				{Verify = function(PlayerData) return PlayerData:incrementBagItem('oddkeystone', -1) end}
				{{'Spiritomb', 15, 15, 1}}
			},
		},
	},
	['chunk11'] = {
		buildings = {
			'Gate9',
			'Gate10',
			'PokeCenter',
			['Gym3'] = {
				Music = 15064099613,
				BattleSceneType = 'Gym3',
			},
		},
		regions = {
			['Rosecove City'] = {
				SignColor = BrickColor.new('Storm blue').Color,
				Music = 15064105939,
				BattleScene = 'Beach', -- for Santa, if nothing else
			},
			['Rosecove Beach'] = {
				SignColor = BrickColor.new('Brick yellow').Color,
				Music = 15064114110,
				MusicVolume = 0.4,
				BattleScene = 'Beach',
				RodScene = 'Beach',
				RTDDisabled = true,
				Grass = EncounterList {
					{'Shellos',  15, 17, 20},
					{'Slowpoke', 15, 17, 15, nil, false, nil, 'laggingtail', 20},
					{'Wingull',  15, 17, 10, nil, false, nil, 'prettywing', 2},
					{'Psyduck',  15, 17, 10},
					{'Abra',     15, 17,  2, 'night', false, nil, 'psychicgem', 1},
				},
				OldRod = OldRodList {
					{'Tentacool', 4, nil, nil, nil, false, nil, 'poisonbarb', 20},
					{'Finneon',   1},
				},
				GoodRod = GoodRodList {
					{'Tentacool', 5, nil, nil, nil, false, nil, 'poisonbarb', 20},
					{'Finneon',   4},
					{'Tentacruel',1, nil, nil, nil, false, nil, 'poisonbarb', 20},
				},
				PalmTree = EncounterList {Locked = true} {
					{'Exeggcute', 15, 17, 4, nil, false, nil, 'psychicseed', 2},
					{'Aipom',     15, 17, 1},
				},
				MiscEncounter = EncounterList {Locked = true} {
					{'Krabby', 15, 17, 3},
					{'Staryu', 15, 17, 2, nil, false, nil, 'starpiece', 20, 'stardust', 2},
					{'Crabrawler', 15, 17, 1, 'day', false, nil, 'luckypunch'},
				},
				Surf = EncounterList { 
					{'Tentacool', 27, 32, 5, nil, false, nil, 'poisonbarb', 20},
					{'Finneon', 27, 32, 4},
					{'Lumineon', 27, 32, 2},
					{'Alomomola', 27, 32, 1}
				}
			}
		}
	},
	['chunk12'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'Gate10',
			['Gate11'] = {
				Music = 15064141887,
			},
			'Gate12',
			'Gate13',
		},
		regions = {
			['Route 9'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = 15064145227,
				MusicVolume = 0.7,
				BattleScene = 'Forest1',
				IsDark = true,
				Grass = EncounterList {
					{'Sewaddle',  22, 25, 30, nil, false, nil, 'mentalherb', 20},
					{'Venipede',  22, 25, 25, nil, false, nil, 'poisonbarb', 20},
					{'Shroomish', 22, 25,  2, nil, false, nil, 'bigmushroom', 20, 'tinymushroom', 2},
					{'Paras',     22, 25, 35, 'day', false, nil, 'bigmushroom', 20, 'tinymushroom', 2},
					{'Roselia',   22, 25,  5, 'day'},
					{'Flapple',   21, 24,  1, 'day'},
					{'Kricketot', 22, 25, 35, 'night'},
					{'Venonat',   22, 25,  5, 'night'},
				},
				PineTree = EncounterList {Locked = true} {
					{'Pineco',    22, 25, 30},
					{'Spewpa',    22, 25, 20},
					{'Kakuna',    22, 25, 10},
					{'Metapod',   22, 25, 10},
					{'Heracross', 23, 26,  2, 'night'},
					{'Pinsir',    23, 26,  2, 'day'},
				}
			}
		}
	},
	['chunk13'] = {
		blackOutTo = 'chunk11',
		lighting = {
			FogColor = Color3.fromHSV(5/6, .2, .5),
			FogStart = 45,
			FogEnd = 200,
		},
		buildings = {
			['Gate11'] = {
				Music = 15064141887,
			},
			['HMFoyer'] = {
				BattleSceneType = 'HauntedMansion',
				Music = 15064165730,
			},
			['HMStub1'] = { DoorViewAngle = 10 },
			['HMStub2'] = { DoorViewAngle = 10 },
			['HMAttic'] = {
				BattleSceneType = 'HauntedMansion',
				Music = 15064165730,
			},
			['HMBabyRoom'] = {BattleSceneType = 'HauntedMansion'},
			['HMBadBedroom'] = {BattleSceneType = 'HauntedMansion'},
			['HMBathroom'] = {BattleSceneType = 'HauntedMansion'},
			['HMBedroom'] = {BattleSceneType = 'HauntedMansion'},
			['HMDiningRoom'] = {BattleSceneType = 'HauntedMansion'},
			['HMLibrary'] = {BattleSceneType = 'HauntedMansion'},
			['HMMotherLounge'] = {BattleSceneType = 'HauntedMansion'},
			['HMMusicRoom'] = {BattleSceneType = 'HauntedMansion'},
			['HMUpperHall'] = {BattleSceneType = 'HauntedMansion'},
		},
		regions = {
			['Fortulose Manor'] = { -- Well-Mannered Manure Manor
				SignColor = BrickColor.new('Mulberry').Color,
				Music = {15064170429, 15064173569},
				--				IsDark = true,
				Grass = EncounterList {
					{'Phantump',  20, 22, 30},
					{'Pumpkaboo', 20, 22, 30, nil, nil, nil, 'miracleseed', 1},
					{'Golett',    21, 23,  4, nil, nil, nil, 'lightclay', 20},
					{'Sableye',   24, 27,  1},
					{'Dreepy',    21, 22,  1},
				},
				OldRod = OldRodList {
					{'Magikarp', 18},
					{'Feebas',    1},
				},
				GoodRod = GoodRodList {
					{'Magikarp',35},
					{'Feebas',15},
					{'Corsola',3, nil, nil, 'Galar'},
				},
				InsideEnc = EncounterList {
					{'Rattata',    20, 22, 30, nil, nil, nil, 'chilanberry', 20},
					{'Shuppet',    20, 22, 20, nil, nil, nil, 'spelltag', 20},
					{'Duskull',    20, 22, 20, nil, nil, nil, 'spelltag', 20},
					{'Misdreavus', 20, 22,  8},
					{'Sinistea',    21, 22, 3, nil, false, nil, 'spelltag', 20},
					{'Honedge',    20, 22,  2},
					{'Dreepy',   23, 27,  1},
					{'Greavard', 20, 22,  8},

				},
				Candle = EncounterList {Locked = true} {{'Litwick', 20, 20, 1}},
				Gameboy = EncounterList {PDEvent = 'Rotom7'} {{'Rotom', 25, 25, 1}}
			}
		}
	},
	['chunk14'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'Gate12',
		},
		regions = {
			['Grove of Dreams'] = {
				Music = 15064178514,
				Grass = EncounterList {
					{'Venipede',  20, 22, 25, nil, false, nil, 'poisonbarb', 20},
					{'Mankey',    20, 22, 15},
					{'Snubbull',  20, 22, 10},
					{'Meowth',    20, 22,  9, nil, nil, 'Galar'},
					{'Chatot',    20, 22,  5, nil, false, nil, 'metronome', 20},
					{'Pancham',   21, 23,  2, nil, false, nil, 'mentalherb', 20},
					{'Minccino',  20, 22, 10, 'day'},
					{'Kricketot', 20, 22, 35, 'night', false, nil, 'metronome', 20},
				},
				OldRod = OldRodList {
					{'Magikarp', 49},
				},
				GoodRod = GoodRodList {
					{'Magikarp',98},
					{'Dratini',2, nil, nil, nil, nil, nil, 'dragonscale', 20},
				},
				Wish = EncounterList {PDEvent = 'Jirachi'} {{'Jirachi', 25, 25, 1, nil, nil, nil, 'starpiece', 1}},
				Sage = EncounterList {Locked = true} {{'Pansage', 25, 25, 1}},
				Sear = EncounterList {Locked = true} {{'Pansear', 25, 25, 1}},
				Pour = EncounterList {Locked = true} {{'Panpour', 25, 25, 1}}
			}
		}
	},
	['chunk15'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'Gate13',
			['CableCars'] = {
				DoorViewAngle = 15,
			},
		},
		regions = {
			['Route 10'] = {
				SignColor = BrickColor.new('Linen').Color,
				Music = 15063994431,
				MusicVolume = routeMusicVolume,
				BattleScene = 'Flowers',
				Grass = EncounterList {
					{'Hoppip',     20, 22, 30},
					{'Spoink',     20, 22, 25},
					{'Growlithe',  20, 22, 15},
					{'Chimecho',   20, 22, 10, nil, false, nil, 'cleansetag', 20},
					{'Pawniard',   20, 22,  8},
					{'Grubbin',    20, 22,  6},
					{'Helioptile', 20, 22,  4},
					{'Scyther',    21, 23,  2},
				},
				MiscEncounter = EncounterList {
					{'Floette',    20, 23, 30},
					{'Hoppip',     20, 23, 30},
					{'Spoink',     20, 23, 25},
					{'Petilil',    20, 23, 15, nil, nil, nil, 'absorbbulb', 20},
					{'Comfey',     20, 23, 10, nil, nil, nil, 'mistyseed', 20},
				},
				HoneyTree = EncounterList
				{GetPokemon = function(PlayerData)
					local foe = PlayerData.honey.foe
					PlayerData.honey = nil -- ok to completely remove?
					return foe
				end}
				{{'Teddiursa', 19, 23, 10}, {'Combee', 19, 23, 90, nil, nil, nil, 'honey', 20}},
				Windmill = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.flags.DinWM then return false end
					PlayerData.flags.DinWM = nil
					PlayerData.lastDrifloonEncounterWeek = _f.Date:getWeekId()
					return true
				end}
				{{'Drifloon', 22, 25, 1}}
			}
		}
	},
	['chunk16'] = {
		blackOutTo = 'chunk11',
		canFly = false,
		regions = {
			['Cragonos Mines'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 15064191272,
				BattleScene = 'CragonosMines',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Nymble',     21, 24, 35, 'day'},
					{'Woobat',     21, 24, 35, 'day'},
					{'Geodude',    21, 24, 30, nil, false, nil, 'everstone', 20},
					{'Roggenrola', 21, 24, 30, nil, false, nil, 'hardstone', 20, 'everstone', 2},
					{'Meditite',   21, 24, 15},
					{'Diglett',    21, 24, 10, nil, false, nil, 'softsand', 20},
					{'Onix',       21, 24,  7},
					{'Drilbur',    22, 25,  3},
					{'Cufant',     22, 25,  3},
					{'Larvitar',   22, 25,  2},
				},
				RodScene = 'CragonosMines',
				OldRod = OldRodList {
					{'Magikarp', 20},
					{'Goldeen',  10,nil,nil, nil, false, nil, 'mysticwater', 20},
					{'Chinchou',  2,nil,nil, nil, false, nil, 'deepseascale', 20},
				},
				GoodRod = GoodRodList {
					{'Magikarp',20},
					{'Goldeen', 10,nil,nil, nil, false, nil, 'mysticwater', 20},
					{'Chinchou', 6,nil,nil, nil, false, nil, 'deepseascale', 20},
				},
				Surf = EncounterList {
					{'Goldeen',   22, 24,  5, nil, false, nil, 'mysticwater', 20},
					{'Magikarp',   22, 24,  3},
					{'Tentacool',   22, 24,  2, nil, false, nil, 'poisonbarb', 20},
					{'Clauncher',   22, 24,  1},
				}
			}
		}
	},
	['chunk17'] = {
		buildings = {
			'PokeCenter',
		},
		regions = {
			['Cragonos Cliffs'] = {
				SignColor = BrickColor.new('Sand green').Color,
				Music = 15064292484,
				MusicVolume = routeMusicVolume,
				BattleScene = 'Cliffs',
				Grass = EncounterList {
					{'Woobat',    21, 24, 30, 'night'},
					{'Spearow',   21, 24, 30, nil, nil, nil, 'sharpbeak', 20},
					{'Pidgeotto', 21, 24, 20},
					{'Skiddo',    21, 24, 20},
					{'Vullaby',   21, 24, 10},
					{'Oricorio',   21, 24,  8},
					{'Gligar',    21, 24,  5},
					{'Bagon',     21, 24,  1, nil, false, nil, 'dragonfang', 20},
				},
				Grace = EncounterList
				{Verify = function(PlayerData)
					return PlayerData:getBagDataById('gracidea', 5) and true or false
				end, PDEvent = 'Shaymin'}
				{{'Shaymin', 30, 30, 1, 'lumberry', 1}}
			}
		}
	},
	['chunk18'] = {
		blackOutTo = 'chunk17',
		regions = {
			['Cragonos Peak'] = {
				SignColor = Color3.new(1, 1, 1),
				Music = 15064292484,
				BattleScene = 'Cliffs',
				Grass = EncounterList {
					{'Skiddo',   22, 25, 30},
					{'Dubwool',  22, 25, 30, 'day'},
					{'Doduo',    22, 25, 30, nil, false, nil, 'sharpbeak', 20},
					{'Spearow',  22, 25, 30, nil, false, nil, 'sharpbeak', 20},
					{'Inkay',    22, 25, 10},
					{'Stantler', 23, 26,  6},
					{'Rufflet',  22, 26,  2},
				}
			}
		}
	},
	['chunk19'] = {
		blackOutTo = 'chunk21',
		regions = {
			['Anthian City - Housing District'] = {
				SignColor = BrickColor.new('Steel blue').Color,
				Music = 15064298828,
				--				MusicVolume = 1, -- ?
				Dumpster = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.flags.TinD then return false end
					PlayerData.flags.TinD = nil
					PlayerData.lastTrubbishEncounterWeek = _f.Date:getWeekId()
					return true
				end}
				{{'Trubbish', 22, 25, 1, nil, nil, nil, 'silkscarf', 20}}
			}
		}
	},
	['Arcade'] = {
		canFly = false,
		blackOutTo = 'chunk17',
		lighting = {
			Ambient = Color3.fromRGB(255, 12, 190),
			OutdoorAmbient = Color3.fromRGB(255, 12, 190),
			--			TimeOfDay = '06:00:00',
		},
		regions = {
			['Golden Pokeball - Arcade'] = {
				NoSign = true,
				Music = 15064312937,
			}
		}
	},
	['chunk20'] = {
		blackOutTo = 'chunk21',
		buildings = {
			['PokeBallShop'] = {
				DoorViewAngle = 25
			},
			['LudiLoco'] = {
				Music = 13598077228,
				DoorViewAngle = 20
			},
			['LottoShop'] = {
				DoorViewAngle = 25
			},
			['C_chunk23'] = {
				DoorViewAngle = 60,
				DoorViewZoom = 15
			}
		},
		regions = {
			['Anthian City - Shopping District'] = {
				SignColor = BrickColor.new('Fossil').Color,
				Music = {15064321947, 15064325772},
				MusicVolume = .7,

			}
		}
	},
	['chunk21'] = {
		buildings = {
			['Gym4'] = {
				Music = 15064329774,
				BattleSceneType = 'Gym4',
				DoorViewZoom = 35,
			},
			'PokeCenter'
		},
		regions = {
			['Anthian City - Battle District'] = {
				SignColor = BrickColor.new('Crimson').Color,
				Music = 15064334193,

			}
		}
	},
	['chunk22'] = {
		blackOutTo = 'chunk21',
		buildings = {
			['PowerPlant'] = {DoorViewAngle = 20}
		},
		regions = {
			['Anthian City - Park District'] = {
				SignColor = BrickColor.new('Bright green').Color,
				Music = 15064339113,

			}
		}
	},
	['chunk23'] = {
		blackOutTo = 'chunk21',
		canFly = false,
		buildings = {
			['C_chunk20'] = {
				DoorViewZoom = 14,
			},
			['C_chunk22'] = {
				DoorViewAngle = 30,
				DoorViewZoom = 14,
			},
			['EnergyCore'] = {
				DoorViewAngle = 20,
				DoorViewZoom = 12,
				BattleSceneType = 'CoreRoom',
			}
		},
		lighting = {
			Ambient = Color3.fromRGB(145, 145, 145),
			OutdoorAmbient = Color3.fromRGB(108, 108, 108),
			--			TimeOfDay = '06:00:00',
		},
		regions = {
			['Anthian Sewer'] = {
				SignColor = BrickColor.new('Slime green').Color,
				Music = 15064343455,
				BattleScene = 'Sewer',
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Voltorb',      27, 30, 25},
					{'Magnemite',    27, 30, 25},
					{'Klink',        27, 30, 20},
					{'Farfetch\'d',  27, 30, 20, nil, nil},
					{'Koffing',      27, 30, 10, nil, false, nil, 'smokeball', 20},
					{'Grimer',       27, 30, 10, nil, false, nil, 'blacksludge', 20},
					{'Elekid',       28, 29,  2, nil, false, nil, 'electirizer', 20},
				}
			}
		}
	},
	['chunk24'] = {
		blackOutTo = 'chunk21',
		buildings = {
			['CableCars'] = {DoorViewAngle = 15},
			'Gate14',
		},
		lighting = {
			FogColor = Color3.fromRGB(216, 194, 114),
			FogEnd = 200,
			FogStart = 40,
		},
		regions = {
			['Route 11'] = {
				SignColor = BrickColor.new('Brick yellow').Color,
				Music = 15064348123,
				BattleScene = 'Desert',
				Grass = EncounterList
				{Weather = 'sandstorm'}
				{
					{'Cacnea',    28, 31, 20, nil, false, nil, 'stickybarb', 20},
					{'Stonjourner', 28, 31, 20, 'night'},
					{'Trapinch',  28, 31, 20, nil, false, nil, 'softsand', 20},
					{'Hippowdon', 28, 31, 15},
					{'Silicobra', 28, 31, 12},
					{'Sandslash', 28, 31, 10, nil, false, nil, 'gripclaw', 20},
					{'Krokorok',  28, 31,  8, nil, false, nil, 'blackglasses', 20},
					{'Maractus',  28, 31,  3, nil, false, nil, 'miracleseed', 20},
				}
			}
		}
	},
	['chunk25'] = {
		buildings = {
			'Gate14',
			'Gate15',
			'Gate16',
			['PokeCenter'] = {DoorViewAngle = 25},
			['House4'] = {DoorViewAngle = 25},
			['Palace'] = {Music = {15064356247, 15064359882}}
		},
		regions = {
			['Aredia City'] = {
				SignColor = BrickColor.new('Flint').Color,
				Music = {15064363934, 15064367851},
				BattleScene = 'Aredia',
				Snore = EncounterList
				{Verify = function(PlayerData)
					return PlayerData:hasFlute()
				end, PDEvent = 'Snorlax'}
				{{'Snorlax', 30, 30, 1, nil, nil, nil, 'leftovers', 1}}
			}
		}
	},
	['chunk26'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Glistening Grotto'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 15064371637,
				MusicVolume = .45,
				BattleScene = 'CrystalCave',
				RodScene = 'CrystalCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Zubat',   25, 30, 25, 'day'},
					{'Bronzor', 25, 30, 25},
					{'Boldore', 25, 30, 20, nil, nil, nil, 'hardstone', 20, 'everstone', 2},
					{'Carbink', 25, 30, 15},
					{'Elgyem',  25, 30, 10},
					{'Toxel',  25, 30,   6, nil, nil, nil, 'blacksludge', 50},
					{'Mawile',  25, 30,  5, nil, nil, nil, 'ironball', 20},
					{'Sableye', 25, 30,  5, nil, nil, nil, 'widelens', 20},
					{'Aron',    25, 30,  3, nil, nil, nil, 'hardstone', 20},
				},
				OldRod = OldRodList {
					{'Goldeen',  30,nil,nil, nil, nil, nil, 'mysticwater', 20},
					{'Shellder', 15,nil,nil, nil, nil, nil, 'bigpearl', 20, 'pearl', 2},
				},
				GoodRod = GoodRodList {
					{'Goldeen',20, nil, nil, nil, nil, nil, 'mysticwater', 20},
					{'Shellder',13, nil, nil, nil, nil, nil, 'bigpearl', 20, 'pearl', 2},
					{'Relicanth', 1, nil, nil, nil, nil, nil, 'deepseascale', 20},
				}
			}
		}
	},
	['chunk27'] = {
		blackOutTo = 'chunk25',
		buildings = {
			'Gate15'
		},
		regions = {
			['Old Aredia'] = {
				SignColor = BrickColor.new('Cashmere').Color,
				Music = 15064383757,
				BattleScene = 'Desert',
				Grass = EncounterList {
					{'Hippowdon', 29, 32, 25},
					{'Cacnea',    29, 32, 20, nil, false, nil, 'stickybarb', 20},
					{'Trapinch',  29, 32, 20, nil, false, nil, 'softsand', 20},
					{'Sandslash', 29, 32, 15, nil, false, nil, 'gripclaw', 20},
					{'Dunsparce', 29, 32, 10},
					{'Centiskorch', 29, 32, 5},
					{'Gible',     29, 32,  1},
				}
			}
		}
	},
	['chunk28'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 10062486312, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk29'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 10062486312, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk30'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 10062486312, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk31'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 10062486312, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk32'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 10062486312, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk33'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 10062486312, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	['chunk34'] = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 10062486312, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter,
		Victory = EncounterList
		{Verify = function(PlayerData)
			if not PlayerData.badges[5] then return false end
			return PlayerData.completedEvents.BJP and true or false
		end, PDEvent = 'Victini'}
		{{'Victini', 35, 35, 1}}}}},
	['gym5'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk25',
		-- lighting ?
		regions = {
			['Aredia City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = {15064356247, 15064359882},
				BattleScene = 'Gym5'
			}
		}
	},
	['chunk35'] = {
		blackOutTo = 'chunk25',
		regions = {
			['Desert Catacombs'] = {
				SignColor = BrickColor.new('Black').Color,
				Music = 15064396807,
				MusicVolume = .8,
				BattleScene = 'UnownRuins',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Unown', 25, 30, 1}
				}
			}
		}
	},
	['chunk36'] = {
		buildings = {
			'Gate16'
		},
		blackOutTo = 'chunk25',
		regions = {
			['Route 12'] = {
				SignColor = BrickColor.new('Mint').Color,
				Music = 15063994431,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Tranquill',  31, 34, 20},
					{'Houndour',   31, 34, 20},
					{'Vulpix',     31, 34, 15, nil, false, nil, 'charcoal', 20},
					{'Sawk',       31, 35, 15, nil, false, nil, 'blackbelt', 20},
					{'Throh',      31, 35, 15, nil, false, nil, 'blackbelt', 20},
					{'Scraggy',    31, 34, 10, nil, false, nil, 'shedshell', 20},
					{'Miltank',    31, 34,  5, nil, false, nil, 'moomoomilk', 1},
					{'Tauros',     31, 34,  5},
					{'Bouffalant', 31, 34,  3},
				},
				OldRod = OldRodList {
					{'Magikarp', 10},
					{'Goldeen',   5, nil,nil,nil, false, nil, 'mysticwater', 20},
					{'Qwilfish',  1, nil,nil,nil, false, nil, 'poisonbarb', 20},
				},
				GoodRod = GoodRodList {
					{'Goldeen',20, nil,nil,nil, false, nil, 'mysticwater', 20},
					{'Magikarp',13},
					{'Qwilfish',5, nil,nil,nil, false, nil, 'poisonbarb', 20},
				},
			}
		}
	},
	['chunk37'] = {
		blackOutTo = 'chunk25',
		canFly = false,
		regions = {
			['Nature\'s Den'] = {
				SignColor = BrickColor.new('Moss').Color,
				Music = 15064419227,
				BattleScene = 'NatureDen',
				Landforce = EncounterList
				{Verify = function(PlayerData)
					if not PlayerData.completedEvents.RNatureForces then return false end
					return PlayerData.flags.landorusEnabled and true or false -- flagged by DataService
				end, PDEvent = 'Landorus'}
				{{'Landorus', 40, 40, 1}}
			}
		}
	},
	['chunk38'] = {
		buildings = {'Gate17'},
		canFly = false,
		blackOutTo = 'chunk25',
		regions = {
			['Route 13'] = {
				SignColor = BrickColor.new('Moss').Color,
				Music = 15064424331,
				BattleScene = 'BioCave',
				IsDark = true,
				NoGrassIndoors = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Foongus',  32, 36, 20,nil, false, nil, 'bigmushroom', 20, 'tinymushroom', 2},
					{'Duosion',  32, 36, 20},
					{'Tangela',  32, 36, 15},
					{'Dottler',  32, 36, 12, nil, false, nil, 'leftovers', 80},
					{'Volbeat',  32, 36, 10,nil, false, nil, 'brightpowder', 20},
					{'Illumise', 32, 36, 10,nil, false, nil, 'brightpowder', 20},
					{'Joltik',   32, 36, 10},
					{'Eldegoss',  32, 36,  5},
					{'Tynamo',   32, 36,  3}
				}
			}
		}
	},
	['chunk39'] = {
		buildings = {'Gate17', 'Gate18', 'PokeCenter'},
		regions = {
			['Fluoruma City'] = {
				SignColor = BrickColor.new('Mint').Color,
				Music = 15064428753
			}
		}
	},
	['gym6'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Fluoruma City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 15064329774,
				BattleScene = 'Gym6'
			}
		}
	},
	['chunk40'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Igneus Depths'] = {
				Music = 15064438725,--317351319,
				MusicVolume = .8,
				SignColor = BrickColor.new('Burgundy').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Numel',   25, 27, 20},
					{'Slugma',  25, 27, 20},
					{'Centiskorch',  25, 27, 20},
					{'Torkoal', 25, 27, 17,nil, false, nil, 'charcoal', 20},
					{'Magmar',  25, 27,  8,nil, false, nil, 'magmarizer', 20},
					{'Heatmor', 25, 27,  5},
				},
				Heat = EncounterList
				{PDEvent = 'Heatran'}
				{{'Heatran', 40, 40, 1}}
			}
		}
	},
	['chunk41'] = {
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Chamber of the Jewel'] = {
				SignColor = BrickColor.new('Pink').Color,
				BattleScene = 'BioCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Foongus',  32, 36, 20,nil, false, nil, 'bigmushroom', 20, 'tinymushroom', 2},
					{'Duosion',  32, 36, 20},
					{'Tangela',  32, 36, 15},
					{'Dottler',  32, 36, 12, nil, false, nil, 'leftovers', 80},
					{'Volbeat',  32, 36, 10,nil, false, nil, 'brightpowder', 20},
					{'Illumise', 32, 36, 10,nil, false, nil, 'brightpowder', 20},
					{'Joltik',   32, 36, 10},
					{'Eldegoss',  32, 36,  5},
					{'Tynamo',   32, 36,  3}
				},
				Jewel = EncounterList
				{Verify = function(PlayerData) return PlayerData.completedEvents.OpenJDoor and true or false end,
				PDEvent = 'Diancie'}
				{{'Diancie', 40, 40, 1}}
			}
		}
	},
	['chunk42'] = {
		buildings = {'Gate18'},
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Route 14'] = {
				SignColor = BrickColor.new('Flint').Color,
				BattleScene = 'Rt14Ruins',
				Music = 15064453981,
				IsDark = true,
				NoGrassIndoors = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Loudred',  32, 36, 300},
					{'Makuhita', 32, 36, 300,nil, false, nil, 'blackbelt', 20},
					{'Nosepass', 32, 36, 250,nil, false, nil, 'magnet', 20},
					{'Mr. Mime', 32, 36, 150},
					{'Mr. Rime', 32, 36, 130},
					{'Clefairy', 32, 36, 125,nil, false, nil, 'moonstone', 20},
					{'Noibat',   32, 36,  75},
					{'Morpeko',  32, 36,  50},
					{'Beldum',   32, 36,  40},
					{'Onix',     32, 36,   1, nil, false, 'crystal'},
				}
			}
		}
	},
	chunk99 = {
		canFly = false,
		blackOutTo = 'chunk3',
		isDark = true,
		lighting = {
			FogColor = Color3.fromRGB(21, 174, 191),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Crystal Cavern'] = {
				SignColor = Color3.fromRGB(175, 255, 195),
				BattleScene = 'KokoCave',
				Koko = EncounterList {PDEvent = 'TapuKokoBattle'} {{'Tapu Koko',     40, 40,  5}},
			}
		}
	},
	['chunk43'] = {
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Route 14'] = {
				SignColor = BrickColor.new('Teal').Color,
				BattleScene = 'Rt14Ice',
				Music = 15064453981,
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Loudred',  32, 36, 300},
					{'Makuhita', 32, 36, 300,nil, false, nil, 'blackbelt', 20},
					{'Nosepass', 32, 36, 250,nil, false, nil, 'magnet', 20},
					{'Mr. Mime', 32, 36, 150},
					{'Mr. Rime', 32, 36, 130},
					{'Clefairy', 32, 36, 125,nil, false, nil, 'moonstone', 20},
					{'Noibat',   32, 36,  75},
					{'Morpeko',  32, 36,  50},
					{'Beldum',   32, 36,  40},
					{'Onix',     32, 36,   1, nil, false, 'crystal'},
				}
			}
		}
	},
	['chunk44'] = {
		canFly = false,
		blackOutTo = 'chunk17',
		regions = {
			['Cragonos Sanctuary'] = {
				SignColor = BrickColor.new('Hurricane grey').Color,
				Music = 15064463484,
			}
		}
	},
	['chunk45'] = {
		blackOutTo = 'chunk39',
		buildings = {
			'Gate19',
			'house1',
			'house2'
		},
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 200,
			FogEnd = 1000,
		},
		regions = {
			['Route 15'] = {
				RTDDisabled = true,
				BattleScene = 'Snow',
				RodScene = 'Snow',
				SignColor = BrickColor.new('Medium blue').Color,
				Music = 15064467590,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Snover',  34, 38, 400, nil, false, nil, 'nevermeltice', 20},
					{'Swinub', 34, 38, 400},
					{'Vanillite', 34, 38, 350, nil, false, nil, 'nevermeltice', 20},
					{'Snorunt', 34, 38, 200, nil, false, nil, 'snowball', 20},
					{'Snom', 34, 38, 200, nil, false, nil, 'snowball', 20},
					{'Darumaka', 34, 38, 200, nil, nil, 'Galar'},
					{'Sneasel', 34, 38, 100, 'night', false, nil, 'quickclaw', 20},
					--{'Sceptile', 34, 38, 5, nil, nil, 'christmas'}, -- 2021 X-Mass Event
					--{'Sceptile', 34, 38, 1.7, nil, nil, 'whitechristmas'}, -- 2021 X-Mass Event
				},
				OldRod = OldRodList {
					{'Magikarp', 600},
					{'Spheal', 500},
					{'Seel',   400},
					{'Bergmite',  70}
				},
				GoodRod = GoodRodList {
					{'Spheal',   5},
					{'Seel',     3},
					{'Bergmite', 1},
				},
			}
		}
	},
	['chunk46'] = {
		buildings = {
			'Gate19',
			'PokeCenter',
			'house1',
			'house2',
			'house3',
			'house4',
			'house5',
			'house6',
			'house7',
			'Gate20',
		},
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 200,
			FogEnd = 1000,
		},
		regions = {
			['Frostveil City'] = {
				SignColor = BrickColor.new('Storm blue').Color,
				Music = 15064471464,
				MusicVolume = .7,
			}
		}
	},
	['gym7'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk46',
		lighting = {
			FogColor = Color3.fromRGB(0, 0, 0),
			FogStart = 0,
			FogEnd = 0,
		},
		regions = {
			['Frostveil City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 15064491669,
				MusicVolume = 0.81,
				BattleScene = 'Gym7'
			}
		}
	},
	['mining'] = {
		noHover = true,
		canFly = false,
		regions = {
			['Lagoona Trenches'] = {
				RTDDisabled = true,
				SignColor = Color3.new(78/400, 133/400, 191/400),
				Music = 15064495322,
			},
		},
	},
	['chunk47'] = {
		blackOutTo = 'chunk46',
		buildings = {
			'Gate20',
			'Gate24',
			'SkittyLodge'
		},
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 200,
			FogEnd = 1000,
		},
		regions = {
			['Route 16'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 15064499215, 
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Jigglypuff',  35, 39, 400,nil, nil, nil, 'moonstone', 20},
					{'Swellow', 35, 39, 400},
					{'Furfrou', 35, 39, 350},
					{'Nuzleaf', 35, 39, 200,nil, nil, nil, 'powerherb', 20},
					{'Dedenne', 35, 39, 150},
					{'Emolga', 35, 39, 150},
				}
			}
		}
	},
	['chunk51'] = {
		blackOutTo = 'chunk46',
		buildings = {
			['MagikPond'] = {
				BattleSceneType = 'MagikPond',
			},
			'Gate24',
			'Gate21',
			'Gate25',
		},
		regions = {
			['Cosmeos Valley'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = 15064503432, 
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Tarountula',  36, 40, 400},
					{'Munna',  36, 40, 400},
					{'Cottonee', 36, 40, 400,nil, nil, nil, 'absorbbulb', 20},
					{'Vigoroth', 36, 40, 350},
					{'Minior', 36, 40, 200,nil, nil, nil, 'starpiece', 20},
					{'Skarmory', 36, 40, 100},
					{'Hawlucha', 36, 40, 25,nil, nil, nil, 'kingsrock', 20},
					{'Shelmet', 36, 40, 10},
					{'Karrablast', 36, 40, 10},
				},
				OldRod = OldRodList {
					{'Magikarp', 100},
					{'Goldeen', 50,nil,nil,nil, nil, nil, 'mysticwater', 20},
					{'Basculin', 30,nil,nil,nil, nil, nil, 'deepseatooth', 20},
				},
				GoodRod = GoodRodList {
					{'Goldeen',   10,nil,nil,nil, nil, nil, 'mysticwater', 20},
					{'Magikarp', 5},
					{'Basculin',  3,nil,nil,nil, nil, nil, 'deepseatooth', 20},
					{'Luvdisc',  1,nil,nil,nil, nil, nil, 'heartscale', 2},
				},
				Deoxys = EncounterList {{'Deoxys', 100, 100, 1, nil, false, nil, "lifeorb"}},
				Deoxys2 = EncounterList {PDEvent = 'DeoxysBattle'} {{'Deoxys', 65, 65, 1}}
			}
		}
	},
	['chunk52'] = {
		buildings = {
			'Gate21',
			'Gate22',
			'HeroBoardsDecca',
			'PokeCenter',
			'PBStampShop',
			'DTA',
			'AifesShelter',
			'MewHouse',
			'VolGirlHouse'
		},
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 100000,
		},
		regions = {
			['Port Decca'] = {
				SignColor = BrickColor.new('Teal').Color,
				Music = 15064507203,
				MusicVolume = .7,
			}
		}
	},
	['chunk70'] = {
		blackOutTo = 'chunk52',
		buildings = {

		},
		regions = {
			['Lost Islands'] = {
				SignColor = BrickColor.new('Gold').Color,
				Music = 15064510630, 
				RTDDisabled = true,
				BattleScene = 'Islands',
				Grass = EncounterList {
					{'Yungoos', 20, 30, 500,nil, nil, nil, 'pechaberry', 20},
					{'Pikipek', 20, 30, 350,nil, nil, nil, 'oranberry', 20},
					{'Rattata', 20, 30, 350, nil, nil, 'Alola', 'chilanberry', 20, 'pechaberry', 2},
					{'Grubbin', 20, 30, 150},
					{'Rockruff', 20, 30, 10},
				},
				OldRod = OldRodList {
					{'Tentacool', 100,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Finneon', 50},
				},
				GoodRod = GoodRodList {
					{'Tentacruel', 100,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Lumineon', 50},
					{'Tentacool', 25,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Mareanie', 2,nil,nil,nil, nil, nil, 'poisonbarb', 20},
				},
				Surf = EncounterList {
					{'Tentacruel', 20, 30, 5,nil, nil, nil, 'poisonbarb', 20},
					{'Tentacool', 20, 30, 2,nil, nil, nil, 'poisonbarb', 20},
					{'Lumineon', 20, 30, 2},
					{'Corsola', 20, 30, 1,nil, nil, nil, 'luminousmoss', 20},
				}
			},
		}
	},
	['chunk81'] = {
		blackOutTo = 'chunk52',
		buildings = {

		},
		regions = {
			['Obsidia Island'] = {
				SignColor = BrickColor.new('Bright red').Color,
				Music = 15064510630,
				RTDDisabled = true,
			},
		}
	},
	['chunk82'] = {
		blackOutTo = 'chunk52',
		canFly = false,
		buildings = {

		},
		regions = {
			['Obsidia Cavern'] = {
				SignColor = BrickColor.new('Bright red').Color,
				Music = 15064529903,
				GrassNotRequired = true,
				RTDDisabled = true,
				BattleScene = 'firebird',
				IsDark = true,
				Grass = EncounterList {
					{'Slugma',   29, 37, 20},
					{'Numel', 29, 37, 17},
					{'Camerupt',  29, 37, 17},
					{'Turtonator',  29, 37, 10, nil, nil, nil, 'charcoal', 20},
				},
				Mol = EncounterList 
				{Verify = function(PlayerData)
					local item = PlayerData:birdsitem()
					if not item.ot then return false end
					return true
				end}
				{{'Moltres', 50, 50, 1}}
			},
		}
	},
	['chunk83'] = {
		blackOutTo = 'chunk52',
		buildings = {

		},
		regions = {
			['Voltridia Island'] = {
				SignColor = BrickColor.new('Bright yellow').Color,
				Music = 15064510630,
				RTDDisabled = true,
			},
		}
	},
	['chunk84'] = {
		blackOutTo = 'chunk52',
		canFly = false,
		buildings = {

		},
		regions = {
			['Voltridia Cavern'] = {
				SignColor = BrickColor.new('Bright yellow').Color,
				Music = 15064529903,
				GrassNotRequired = true,
				RTDDisabled = true,
				BattleScene = 'zpbird',
				IsDark = true,
				Grass = EncounterList {
					{'Joltik',   29, 37, 20},
					{'Nosepass', 29, 37, 17, nil, nil, nil, 'magnet', 20},
					{'Graveler',  29, 37, 17, nil, nil, 'Alola', 'cellbattery', 20},
					{'Stunfisk',  29, 37, 10, nil, nil, nil, 'softsand', 20},
				},
				Zap = EncounterList 
				{Verify = function(PlayerData)
					local item = PlayerData:birdsitem()
					if not item.vt then return false end
					return true
				end}
				{{'Zapdos', 50, 50, 1}}
			},
		}
	},
	['chunk85'] = {
		blackOutTo = 'chunk52',
		buildings = {

		},
		regions = {
			['Frigidia Island'] = {
				SignColor = BrickColor.new('Bright blue').Color,
				Music = 15064510630,
				RTDDisabled = true,
			},
		}
	},
	['chunk86'] = {
		blackOutTo = 'chunk52',
		canFly = false,
		buildings = {

		},
		regions = {
			['Frigidia Cavern'] = {
				SignColor = BrickColor.new('Bright blue').Color,
				Music = 15064529903,
				GrassNotRequired = true,
				RTDDisabled = true,
				BattleScene = 'artback',
				IsDark = true,
				Grass = EncounterList {
					{'Swinub',   29, 37, 20},
					{'Snorunt', 29, 37, 17, nil, nil, nil, 'snowball', 20},
					{'Piloswine',  29, 37, 17},
					{'Sandshrew',  29, 37, 10, nil, nil, 'Alola', 'gripclaw', 20},
					{'Vulpix',  29, 37, 10, nil, nil, 'Alola', 'snowball', 20},
				},
				Art = EncounterList 
				{Verify = function(PlayerData)
					local item = PlayerData:birdsitem()
					if not item.ft then return false end
					return true
				end}
				{{'Articuno', 50, 50, 1}}
			},
		}
	},
	['chunk67'] = {
		blackOutTo = 'chunk52',
		regions = {
			['Lost Islands - Deep Jungle'] = {
				BattleScene = 'Islands',
				SignColor = BrickColor.new('Dark green').Color,
				Music = 15064510630, 
				RTDDisabled = true,
				Grass = EncounterList {
					{'Cutiefly',  22, 35, 20, nil, nil, nil, 'honey', 20},
					{'Bounsweet',  22, 35, 15, nil, nil, nil, 'grassyseed', 20},
					{'Dewpider',  22, 35, 10, nil, nil, nil, 'mysticwater', 20},
					{'Fomantis',  22, 35, 6.3, nil, nil, nil, 'miracleseed', 20},
					{'Meowth', 22, 35, 5, nil, nil, 'Alola', 'quickclaw', 20},
					{'Crabrawler', 22, 35, 1.3, nil, nil, nil, 'aspearberry', 20},
				},
				OldRod = OldRodList {
					{'Tentacool', 4, nil, nil, nil, nil, nil, 'poisonbarb', 20},
					{'Finneon',   1},
				},
				GoodRod = GoodRodList {
					{'Tentacool', 20, nil, nil, nil, nil, nil, 'poisonbarb', 20},
					{'Tentacruel',15, nil, nil, nil, nil, nil, 'poisonbarb', 20},
					{'Lumineon',  15},
					{'Gyarados', 10},
					{'Wishiwashi', 1.8, nil, nil, 'School'}, --fix ability
				},
				Surf = EncounterList { 
					{'Tentacruel', 20, 30, 20, nil, nil, nil, 'poisonbarb', 20},
					{'Lumineon', 20, 30, 20},
					{'Tentacool', 20, 30, 15, nil, nil, nil, 'poisonbarb', 20},
					{'Corsola', 20, 30, 10, nil, nil, nil, 'luminousmoss', 20},
				}
			}
		}
	},
	['chunk74'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Steam Chamber'] = {
				Music = 15064545624,--317351319,
				MusicVolume = .8,
				SignColor = BrickColor.new('Cocoa').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Camerupt',   36, 40, 20},
					{'Torkoal', 36, 40, 17, nil, nil, nil, 'charcoal', 20},
					{'Heatmor',  36, 40, 17},
					{'Magcargo',  36, 40, 10},
					{'Magmar',   36, 40,  10, nil, nil, nil, 'magmarizer', 20},
					{'Larvesta', 36, 40,  5},
				},
				Volcanion = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.completedEvents.volrock then return false end
					return true
				end}
				{{'Volcanion', 60, 60, 1}}
			}
		}
	},
	chunk68 = {
		noHover = true,
		blackOutTo = 'chunk52',
		regions = {
			['Secret Lab'] = {
				SignColor = BrickColor.new('Pink').Color,
				RTDDisabled = true,
				CanFly = false,
				Music = 15064343455,
				BattleScene = 'SecretLab',
			}
		}
	},
	['chunk53'] = {
		blackOutTo = 'chunk52',
		buildings = {
			'Gate22'
		},
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Decca Beach'] = {
				SignColor = BrickColor.new('Cashmere').Color,
				Music = 15064557519,
				BattleScene = 'DeccaBeach',
				OldRod = OldRodList {
					{'Tentacool', 100,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Finneon', 50},
				},
				GoodRod = GoodRodList {
					{'Tentacool',20,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Finneon',14},
					{'Gyarados',8},
					{'Remoraid',1},
				},
				Surf = EncounterList { 
					{'Tentacruel', 30, 40, 5,nil, nil, nil, 'poisonbarb', 20},
					{'Carvanha', 30, 40, 5,nil, nil, nil, 'deepseatooth', 20},
					{'Lumineon', 30, 40, 3},
					{'Mantine', 30, 40, 1}
				}
			}
		}
	},
	['chunk77'] = {
		blackOutTo = 'chunk11',
		canFly = false,
		regions = {
			['Silver Cove'] = {
				Music = 15064561901,
				BattleScene = 'llback',
				RTDDisabled = true,
				IsDark = true,
				--MusicVolume = 2, -- why
				Lugia = EncounterList 
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.getLugia then return false end
					if not PlayerData.completedEvents.getsilverwing then return false end
					return true
				end}
				{{'Lugia', 50, 50, 1}}
			},
		}
	},
	['chunk48'] = {
		canFly = false,
		regions = {
			['Frostveil Catacombs'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 15064561901,
				IsDark = true,
			}
		}
	},
	['chunk58'] = {
		canFly = false,
		blackOutTo = 'chunk45',
		regions = {
			['Dendrite Chamber'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Medium blue').Color,
				Music = 11890750098,
				BattleScene = 'RegiceCave',
				IsDark = true,
				Regice = EncounterList
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.getRegIce then return false end
					if not PlayerData.completedEvents.DidRegiPuzzles then return false end
					return true
				end}
				{{'Regice', 40, 40, 1}}
			},
		},
	},
	['chunk49'] = {
		canFly = false,
		blackOutTo = 'chunk11',
		regions = {
			['Martensite Chamber'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Grey').Color,
				Music = 13598415504,
				IsDark = true,
				BattleScene = 'RegisteelCave',
				Registeel = EncounterList
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.getRegSteel then return false end
					if not PlayerData.completedEvents.DidRegiPuzzles then return false end
					return true
				end}
				{{'Registeel', 40, 40, 1}}
			},
		},
	},
	['chunk50'] = {
		canFly = false,
		blackOutTo = 'chunk5',
		regions = {
			['Calcite Chamber'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Yellow flip/flop').Color,
				Music = 13598415504,
				IsDark = true,
				BattleScene = 'RegirockCave',
				Regirock = EncounterList
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.getRegRock then return false end
					if not PlayerData.completedEvents.DidRegiPuzzles then return false end
					return true
				end}
				{{'Regirock', 40, 40, 1}}
			},
		},
	},
	['chunk59'] = {
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Titans Throng'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Gold').Color,
				IsDark = true,
				Music = 15064606089,
			},
		},
	},
	['chunk66'] = {
		blackOutTo = 'chunk9',
		regions = {
			['Secret Grove'] = {
				Music = 15064339113,
				RTDDisabled = true,
				BattleScene = 'keldeobb',
				Keldeo = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.flags.hasSOJ then return false end
					return true
				end}
				{{'Keldeo', 40, 40, 1}}
			}
		}
	},
	chunk69 = {
		blackOutTo = 'chunk52',
		lighting = {
			FogColor = Color3.fromRGB(0, 110, 255), -- transition implemented in Events
			FogEnd = 7000,
			FogStart = 0,
		},
		regions = {
			['Route 17'] = {
				SignColor = BrickColor.new('Navy blue').Color,
				Music = 15064616748,
				MusicVolume = routeMusicVolume,
				RTDDisabled = true,
				BattleScene = 'Surf',
				RodScene = 'Surf',
				OldRod = OldRodList {
					{'Tentacool', 50,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Goldeen',  10,nil,nil,nil, nil, nil, 'mysticwater', 20},
					{'Finneon',   5},
					{'Buizel',   1},
				},
				GoodRod = GoodRodList {
					{'Palafin', 31, 39, 5},
					{'Wailmer', 50},
					{'Tentacool',  45,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Goldeen',   40,nil,nil,nil, nil, nil, 'mysticwater', 20},
					{'Skrelp',   35},
					{'Finneon', 30},
					{'Horsea',  25,nil,nil,nil, nil, nil, 'dragonscale', 20},
					{'Pyukumuku',   10},
					{'Buizel',   5},
					{'Bruxish',   2,nil,nil,nil, nil, nil, 'razorfang', 20},
				},
				Surf = EncounterList { 
					{'Wailmer', 31, 39, 5},
					{'Tentacruel', 31, 39, 5,nil, nil, nil, 'poisonbarb', 20},
					{'Lumineon', 31, 39, 3},
					{'Seaking', 31, 39, 3,nil, nil, nil, 'mysticwater', 20},
					{'Skrelp', 31, 39, 3},
					{'Horsea', 31, 39, 3,nil, nil, nil, 'dragonscale', 20},
					{'Pyukumuku', 31, 39, 1},
					{'Floatzel', 31, 39, 1},
				},
				Sand = EncounterList {
					{'Sandygast', 31, 39, 5,nil, nil, nil, 'spelltag', 20},
				}
			}
		}
	},
	['chunk54'] = {
		buildings = {
			'PokeCenter',
			'Tavern',
			'Gate23',
			'House1',
			'House2',
			'House3',
			'House4'
		},
		regions = {
			['Crescent Town'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Pastel green').Color,
				Music = 15064622726,
				RodScene = 'ci',
				SurfScene = 'ci',
				lighting = {
					FogColor = Color3.fromRGB(184, 212, 227),
					FogStart = 0,
					FogEnd = 10000000,
				},
				MusicVolume = .7,
				OldRod = OldRodList {
					{'Finneon', 100},
					{'Goldeen', 50,nil,nil,nil, nil, nil, 'mysticwater', 20},
					{'Tentacool', 45,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Clamperl', 10,nil,nil,nil, nil, nil, 'bigpearl', 20, 'pearl', 2},
				},
				GoodRod = GoodRodList {
					{'Binacle',10},
					{'Tentacool',10,nil,nil,nil, nil, nil, 'poisonbarb', 20},
					{'Frillish',10},
					{'Goldeen',6,nil,nil,nil, nil, nil, 'mysticwater', 20},
					{'Finneon',6},
					{'Clamperl',2,nil,nil,nil, nil, nil, 'bigpearl', 20, 'pearl', 2},
					{'Dhelmise',2,nil,nil,nil, nil, nil, 'persimberry', 20},
				},
				Surf = EncounterList { 
					{'Frillish', 31, 39, 5},
					{'Tentacruel', 31, 39, 5,nil, nil, nil, 'poisonbarb', 20},
					{'Binacle', 31, 39, 5},
					{'Seaking', 31, 39, 2,nil, nil, nil, 'mysticwater', 20},
					{'Lumineon', 31, 39, 2},
					{'Clamperl', 31, 39, 1,nil, nil, nil, 'bigpearl', 20, 'pearl', 2},
				}
			}
		}
	},
	['chunk57'] = { -- Main Hall
		buildings = {
			['C_chunk577'] = {
				DoorViewAngle = 20
			},
			['C_chunk575'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base'] = {
				NoSign = true,
				RTDDisabled = true,
				Music = 15064630385,
				BattleScene = 'hallwaybb'
			}
		}
	},
	['chunk571'] = { -- Lunch Room
		buildings = {
			['C_chunk57|b'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base'] = {
				NoSign = true,
				RTDDisabled = true,
				Music = 15064630385,
				BattleScene = 'lunchbb'
			}
		}
	},
	['chunk572'] = { -- Lava Room
		buildings = {
			['C_chunk57|a'] = {
				DoorViewAngle = 20
			},
			['C_chunk57|b'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base'] = {
				NoSign = true,
				RTDDisabled = true,
				Music = 15064630385,
				BattleScene = 'lavabb'
			}
		}
	},
	['chunk573'] = { -- Bedroom
		buildings = {
			['C_chunk57'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base'] = {
				NoSign = true,
				RTDDisabled = true,
				Music = 15064630385,
				BattleScene = 'bedroombb'
			}
		}
	},
	['chunk574'] = { -- Security Room
		buildings = {
			['C_chunk57'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base'] = {
				NoSign = true,
				RTDDisabled = true,
				Music = 15064630385,
			}
		}
	},
	['chunk575'] = { -- Office
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base'] = {
				NoSign = true,
				RTDDisabled = true,
				Music = 15064630385,
				BattleScene = 'Base'
			}
		}
	},
	['chunk576'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Gene Lab'] = {
				SignColor = BrickColor.new('Bright violet').Color,
				RTDDisabled = true,
				Music = 15064630385,
				BattleScene = 'genbb',
				Gen = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.completedEvents.doebasegendoor then return false end
					return true
				end}
				{{'Genesect', 50, 50, 1}}
			}
		}
	},
	['chunk577'] = { -- Hallway
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base'] = {
				NoSign = true,
				RTDDisabled = true,
				Music = 15064630385,
			}
		}
	},
	['chunk60'] = { -- Battle Place
		buildings = {
			['C_chunk577'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base'] = {
				NoSign = true,
				RTDDisabled = true,
				Music = 15064630385,
			}
		}
	},
	['chunk55'] = {
		blackOutTo = 'chunk54',
		buildings = {
			'Gate23'
		},
		lighting = {
			FogColor = Color3.fromRGB(104, 131, 107),
			FogStart = 0,
			FogEnd = 200,
		},
		regions = {
			['Route 18'] = {
				RTDDisabled = true,
				BattleScene = 'Swamp',
				SignColor = BrickColor.new('Grime').Color,
				Music = 15064640178,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Swalot',  34, 42, 400,nil, nil, nil, 'sitrusberry', 20, 'oranberry', 2},
					{'Croagunk', 34, 42, 400,nil, nil, nil, 'blacksludge', 20},
					{'Toxicroak', 34, 42, 350,nil, nil, nil, 'blacksludge', 20},
					{'Ribombee', 36, 40, 200,nil, nil, nil, 'honey', 20},
					{'Skorupi', 34, 42, 100,nil, nil, nil, 'poisonbarb', 20},
					{'Drapion', 34, 42, 25,nil, nil, nil, 'poisonbarb', 20},
					{'Carnivine', 34, 42, 25},
					{'Grimer', 34, 42, 10, nil, nil, 'Alola', 'blacksludge', 20},
					{'Goomy', 34, 42, 10,nil, nil, nil, 'shedshell', 20},
					{'Dudunsparce', 42, 49, 1},

				},
			}
		}
	},
	chunk56 = {
		blackOutTo = 'chunk54',
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 100000,
		},
		canFly = false,
		regions = {
			["Demon's Tomb"] = {
				RTDDisabled = true,
				isDark = true,
				SignColor = BrickColor.new('Reddish lilac').Color,
				Music = 15064645874,--301381728,
				BattleScene = 'Tomb',
				MusicVolume = 0.81,
				Hoops = EncounterList 
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.DefeatHoopa then return false end
					if not PlayerData.completedEvents.EBDefeat then return false end
					return true
				end}
				{{'Hoopa', 65, 65, 1, nil, nil, 'unbound'}}
			},
			['Aborille Outpost'] = {
				RTDDisabled = true,
				isDark = true,
				SignColor = BrickColor.new('Dirt brown').Color,
				Music = 15064645874,--301381728,
				BattleScene = 'Aborille',
				MusicVolume = 0.81,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Mienfoo',   36, 40,  7},
					{'Wobbuffet', 36, 40,  6},
					{'Solrock',   36, 40,  4,nil, nil, nil, 'sunstone', 20, 'stardust', 2},
					{'Lunatone',  36, 40,  2,nil, nil, nil, 'moonstone', 20, 'stardust', 2},
					{'Drampa',    36, 40,  1,nil, nil, nil, 'persimberry', 20},
				}
			},
		},
	},
	['chunk73'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Path of Truth'] = {
				isDark = true,
				BattleScene = 'potback',
				SignColor = BrickColor.new('Earth blue').Color,
				Music = 15064650538,
				RTDDisabled = true,
				MusicVolume = routeMusicVolume,
				GrassNotRequired = true,
				Grass = EncounterList {
					{'Axew',     36, 41, 35},
					{'Noibat',    36, 41, 30},
					{'Deino',    36, 41,  3},
					{'Druddigon',   36, 41,  2, nil, nil, nil, 'dragonfang', 20},
				},
			},
		}
	},
	gym8 = {
		RTDDisabled = false,
		CanFly = true,
		blackOutTo = 'chunk54',
		regions = {
			['Cresent Island Gym'] = {
				RTDDisabled = false,
				CanFly = true,
				NoSign = true,
				Music = 15064329774,
				MusicVolume = 0.81,
				BattleScene = 'Docks'
			}
		}
	},
	--[[chunkcress = {
		blackOutTo = 'chunk2',
		--noSaving = true,
		noWeather = true,
		forcedWeather = 'aurora',
		RTDDisabled = false,
		CanFly = false,
		regions = {
			['Between Dreams'] = {
				SignColor = BrickColor.new('Gold').Color,
				BattleScene = 'Cresselia',
				blackOutTo = 'chunk2',
				Music = 13598094173,
				RTDDisabled = false,
				CanFly = true,
				NoSign = true,
				newSign = true,
				IsDark = true,
				MusicVolume = 1.2,
				Cresselia = EncounterList {PDEvent = 'CresseliaBattle'} {{'Cresselia', 45, 45, 1}}

			}
		}
	},]]--
	['chunk76'] = {
		blackOutTo = 'chunk46',
		buildings = {
			'Gate25'
		},
		regions = {
			['Tinbell Construction Site'] = {
				SignColor = BrickColor.new('Light orange brown').Color,
				Music = 15064675078,
				MusicVolume = 2, -- why
			},
		}
	},
	['chunk76a'] = {
		blackOutTo = 'chunk46',
		buildings = {

		},
		regions = {
			['Tinbell Tower'] = {
				SignColor = BrickColor.new('Flame yellowish orange').Color,
				GrassNotRequired = true,
				Music = 15064675078,
				MusicVolume = 2, -- why
				BattleScene = 'ttback',
				Grass = EncounterList {
					{'Machop',   30, 40, 20, nil, nil, nil, 'focusband', 20},
					{'Timburr', 30, 40, 17},
					{'Machoke',  30, 40, 10, nil, nil, nil, 'focusband', 20},
					{'Gurdurr',  30, 40, 10}
				},
			},
		}
	},
	['chunk71'] = {
		blackOutTo = 'chunk11',
		canFly = true,
		lighting = {
			FogColor = Color3.fromRGB(0, 170, 255),
			FogStart = 200,
			FogEnd = 1200,
		},
		regions = {
			['Cragonos Spring'] = {
				isDark = true,
				BattleScene = 'CragonosMines',
				SignColor = BrickColor.new('Storm blue').Color,
				Music = 15064191272,
				GrassNotRequired = true,
				RTDDisabled = true,
				Grass = EncounterList {
					{'Woobat',     21, 24, 35, 'day'},
					{'Geodude',    21, 24, 30, nil, nil, nil, 'everstone', 20},
					{'Roggenrola', 21, 24, 30, nil, nil, nil, 'hardstone', 20, 'everstone', 2},
					{'Meditite',   21, 24, 15},
					{'Diglett',    21, 24, 10, nil, nil, nil, 'softsand', 20},
					{'Onix',       21, 24,  7},
					{'Drilbur',    22, 25,  3},
					{'Larvitar',   22, 24,  2},
				},
				RodScene = 'lapback',
				SurfScene = 'lapback',
				OldRod = OldRodList {
					{'Magikarp', 20},
					{'Goldeen',  10,nil,nil, nil, nil, nil, 'mysticwater', 20},
					{'Chinchou',  2,nil,nil, nil, nil, nil, 'deepseascale', 20},
				},
				GoodRod = GoodRodList {
					{'Magikarp',20},
					{'Goldeen', 10,nil,nil, nil, nil, nil, 'mysticwater', 20},
					{'Chinchou', 6,nil,nil, nil, nil, nil, 'deepseascale', 20},
				},
				Surf = EncounterList {
					{'Goldeen',   22, 24,  5, nil, nil, nil, 'mysticwater', 20},
					{'Magikarp',   22, 24,  3},
					{'Tentacool',   22, 24,  2, nil, nil, nil, 'poisonbarb', 20},
					{'Clauncher',   22, 24,  1},
				},
				Lapras = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.badges[7] then return false end
					if not PlayerData.flags.LapD then return false end
					PlayerData.flags.Lapras = nil
					PlayerData.lastLaprasEncounterWeek = _f.Date:getWeekId()
					return true
				end}
				{{'Lapras', 40, 40, 1, nil, nil, nil, 'mysticwater', 1}}
			},
		}
	},
	['chunk75'] = {
		blackOutTo = 'chunk46',
		canFly = false,
		lighting = {
			FogColor = Color3.fromRGB(94, 94, 94),
			FogStart = 1,
			FogEnd = 800,
		},
		buildings = {

		},
		regions = {
			['Freezing Fissure'] = {
				SignColor = BrickColor.new('Bright blue').Color,
				Music = 15064695798,
				GrassNotRequired = true,
				RTDDisabled = true,
				BattleScene = 'ffback',
				MusicVolume = 2, -- why
				IsDark = true,
				Grass = EncounterList {
					{'Cubchoo',   36, 40, 40},
					{'Snorunt', 36, 40, 29, nil, nil, nil, 'snowball', 20},
					{'Cryogonal',  36, 40, 25, nil, nil, nil, 'nevermeltice', 20},
					{'Jynx',  36, 40, 5},
					{'Delibird',  36, 40, 1},
				},
			},
		}
	},
	['chunk72'] = {
		blackOutTo = 'chunk52',
		canFly = false,
		lighting = {
			FogColor = Color3.fromRGB(0, 127, 186),
			FogEnd = 700,
			FogStart = 200,
		},
		regions = {
			['Ocean\'s Origin'] = {
				SignColor = BrickColor.new('Navy blue').Color,
				Music = 15064708236,
				isDark = true,
				MusicVolume = 2, -- why
				RTDDisabled = true,
			},
		}
	},
	['chunk91'] = {
		canFly = false,
		noHover = true,
		regions = {
			['Cosmeos Observatory'] = {
				Music = 15064703770,
				MusicVolume = routeMusicVolume,
			},
		},
	},
	['chunk78'] = {
		blackOutTo = 'chunk46',
		regions = {
			['Magik Pond'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RodScene = 'MagikCave',
				Music = 9987710053,
				OldRod = OldRodList {
					{'Magikarp', 100, nil, nil, nil, false, 'OrangeDapples'},
					{'Magikarp', 100, nil, nil, nil, false, 'PinkDapples'},
					{'Magikarp', 100, nil, nil, nil, false, 'CalicoOrangeWhite'},
					{'Magikarp', 100, nil, nil, nil, false, 'Monochrome'},
					{'Magikarp', 100, nil, nil, nil, false, 'Wasp'},
					{'Magikarp', 100, nil, nil, nil, false, 'YinYang'},
					{'Magikarp', 100, nil, nil, nil, false, 'Seaking'},
					{'Magikarp', 100, nil, nil, nil, false, 'Gyarados'},
					{'Magikarp', 100, nil, nil, nil, false, 'Relicanth'},
					{'Magikarp', 1.5, nil, nil, nil, nil, 'Rayquaza'},
				},
				GoodRod = GoodRodList {
					{'Magikarp', 100, nil, nil, nil, false, 'OrangeDapples'},
					{'Magikarp', 100, nil, nil, nil, false, 'PinkDapples'},
					{'Magikarp', 100, nil, nil, nil, false, 'CalicoOrangeWhite'},
					{'Magikarp', 100, nil, nil, nil, false, 'Monochrome'},
					{'Magikarp', 100, nil, nil, nil, false, 'Wasp'},
					{'Magikarp', 100, nil, nil, nil, false, 'YinYang'},
					{'Magikarp', 100, nil, nil, nil, false, 'Seaking'},
					{'Magikarp', 100, nil, nil, nil, false, 'Gyarados'},
					{'Magikarp', 100, nil, nil, nil, false, 'Relicanth'},
					{'Magikarp', 1.5, nil, nil, nil, nil, 'Rayquaza'},
				}
			}
		}
	},
	--// Sub-Contexts
	['colosseum'] = {
		canFly = false,
		regions = {
			['Battle Colosseum'] = {
				SignColor = BrickColor.new('Light orange').Color,
				Music = 15064715701,
			}
		}
	},
	['resort'] = {
		canFly = false,
		regions = {
			['Trade Resort'] = {
				SignColor = BrickColor.new('Pastel blue-green').Color,
				Music = {15064719591, 15064722705}, --9987707023, -- 2021 X-Mass Event
				--MusicVolume = 5, -- 2021 X-Mass Event
			}
		}
	},
	rockSmashEncounter = EncounterList {Locked = true} {
		{'Dwebble', 15, 20, 7,nil, nil, nil, 'hardstone', 20},
		{'Shuckle', 15, 20, 1,nil, nil, nil, 'berryjuice', 1},
	},
	nonMaxEnconter = EncounterList {Locked = false} {
		{'Magikarp', 1, 1, 1},
	},
	roamingEncounter = { -- all @ lv 40
		Jirachi = {{'Jirachi', 4}},
		Shaymin = {{'Shaymin', 4}},
		Victini = {{'Victini', 4}},
		RNatureForces = {{'Thundurus', 3},
		{'Tornadus',  3}},
		Landorus = {{'Landorus', 2}},
		Heatran = {{'Heatran', 4}},
		Diancie = {{'Diancie', 4}},
		RBeastTrio = {{'Raikou',  3},
		{'Entei',   3},
		{'Suicune', 3}},
		EonDuo = {{'Latios',  3}, {'Latias ', 3}},
		DefeatHoopa = {{'Hoopa',  4}},
		SOJ = {{'Cobalion', 3},
		{'Terrakion', 3},
		{'Virizion', 3}},
		GetMew = {{'Mew',  4}},
		GetVolcanion = {{'Volcanion', 4}},
		SOJ2 = {{'Keldeo', 4}},
		getzap = {{'Zapdos', 4}},
		getmol = {{'Moltres', 4}},
		getart = {{'Articuno', 4}},
		getLugia = {{'Lugia', 4}},
		getgen = {{'Genesect', 4}},
		getRegIce = {{'Regice', 4}},
		getRegRock = {{'Regirock', 4}},
		getRegSteel = {{'Registeel', 4}},
		findRegigigas = {{'Regigigas', 4}},
		Groudon = {{'Groudon', 2}},
		DeoxysBattle = {{"Deoxys",4}},
	}
}

chunks.encounterLists = encounterLists
return chunks