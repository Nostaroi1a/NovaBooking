local title		= "NovaBooking"

NovaBookingHistory = {}
novaOptions = {}
local NovaBookingHistoryAvailable = false
local history


local nova = LibStub("AceAddon-3.0"):NewAddon(title, "AceConsole-3.0",  "AceHook-3.0", "AceEvent-3.0", "AceSerializer-3.0", "AceComm-3.0")


local AceGUI = LibStub("AceGUI-3.0")
local ScrollingTable = LibStub("ScrollingTable")
local isMailOpen = false
local MailLastClicked = 0
local historyOpened = false
local boosthistoryST
local f
local tradePlayer
local tradeTargetMoney = 0
local ScreenshotsAndSendButton
local SyncedRowsChanged = 0
local SyncedRowsAdded = 0
local goldCollected = 0
local cutAlliance = 0
local cutHorde = 0
local goldCutAllianceLabel
local goldCutHordeLabel
local goldCutTotalLabel
local goldCollectedLabel
local acDropdownTypeForCollector
local acEditboxTrialAdvertiser
local SYNC_DATA = {}

-----------------------------------------------------------------------------------------------------
---------------------------------------------- OPTIONS ----------------------------------------------
-----------------------------------------------------------------------------------------------------


local myOptionsTable = {
	name = title,
	type = 'group',
	handler = nova,
	args = {
		General = {
			type = 'group',
			name = 'General settings',
			order = 1,
			args = {
				Account = {
					type = 'input',
					name = 'Profile Name',
					desc = 'The profile name will be shown on the history.',
					get = 'GetOption',
					set = 'SetOption',
				},
				OpenHistoryAddClient = {
					type = 'toggle',
					name = '',
					get = 'GetOption',
					set = 'SetOption',
					hidden = true,
				},
				Version = {
					type = 'input',
					name = '',
					get = 'GetOption',
					set = 'SetOption',
					hidden = true,
				},
				AccountID = {
					type = 'input',
					name = '',
					get = 'GetOption',
					set = 'SetOption',
					hidden = true,
				},
				OpenHistoryOnMailbox = {
					type = 'toggle',
					name = '',
					get = 'GetOption',
					set = 'SetOption',
					hidden = true,
				}
			}
		},
		Mailing = {
			type = 'group',
			name = 'Mailing',
			order = 2,
			args = {
				InputAdvertiser = {
					type = 'input',
					name = 'Advertiser Name',
					desc = 'Set your AdvertiserName-Server for mailing',
					order = 1,
					set = 'SetOption',
					get = 'GetOption',
				},
				InputSubjectPrefix = {
					type = 'input',
					name = 'Subject Prefix',
					desc = 'Will be placed in sent mail as first letters in the subject box',
					order = 2,
					set = 'SetOption',
					get = 'GetOption',
				},
				CheckBoxShowScreenshotButton = {
					type = 'toggle',
					name = 'Show "Open History Page" button on mailbox',
					order = 3,
					width = 'full',
					set = 'SetOption',
					get = 'GetOption',
				},
			}
		},
		Boosts = {
			type = 'group',
			name = 'Boosts',
			order = 3,
			args  = {
				InputBoostTyp1 = {
					type = 'input',
					name = 'Boost Type 1',
					order = 1,
					get = 'GetOption',
					set = 'SetOption',
				},
				InputBoostTyp2 = {
					type = 'input',
					name = 'Boost Type 2',
					order = 2,
					get = 'GetOption',
					set = 'SetOption',
				},
				InputBoostTyp3 = {
					type = 'input',
					name = 'Boost Type 3',
					order = 3,
					get = 'GetOption',
					set = 'SetOption',
				},
				InputBoostTyp4 = {
					type = 'input',
					name = 'Boost Type 4',
					order = 4,
					get = 'GetOption',
					set = 'SetOption',
				},
				InputBoostTyp5 = {
					type = 'input',
					name = 'Boost Type 5',
					order = 5,
					get = 'GetOption',
					set = 'SetOption',
				},
				InputBoostTyp6 = {
					type = 'input',
					name = 'Boost Type 6',
					order = 6,
					get = 'GetOption',
					set = 'SetOption',
				},
				InputBoostTyp7 = {
					type = 'input',
					name = 'Boost Type 7',
					order = 7,
					get = 'GetOption',
					set = 'SetOption',
				},
				InputBoostTyp8 = {
					type = 'input',
					name = 'Boost Type 8',
					order = 8,
					get = 'GetOption',
					set = 'SetOption',
				},
				InputBoostTyp9 = {
					type = 'input',
					name = 'Boost Type 9',
					order = 9,
					get = 'GetOption',
					set = 'SetOption',
				},
				InputBoostTyp10 = {
					type = 'input',
					name = 'Boost Type 10',
					order = 10,
					get = 'GetOption',
					set = 'SetOption',
				},
			}
		},
		AdvertiserCuts = {
			type = 'group',
			name = 'Advertiser Cuts',
			order = 4,
			args = {},
		},
		Banking = {
			type = 'group',
			name = 'Banking Characters',
			order = 5,
			args = {
			}
		},
	}
}


local myDefaultOptions = {
	["General"] = {
		["Account"] = "",
		["OpenHistoryAddClient"] = true,
		["OpenHistoryOnMailbox"] = true,
		["Version"] = 1
	},
	["Mailing"] = {
		["InputSubjectPrefix"] = "NBC",
		["CheckBoxShowScreenshotButton"] = true
	},
	["Boosts"] = {
		["InputBoostTyp1"] = "M+",
		["InputBoostTyp2"] = "Raid",
		["InputBoostTyp3"] = "Curve",
		["InputBoostTyp4"] = "Legacy",
		["InputBoostTyp5"] = "PVP",
		["InputBoostTyp6"] = "Mounts",
		["InputBoostTyp7"] = "Torghast",
		["InputBoostTyp8"] = "Collect"
	},
	["AdvertiserCuts"] = {
		["Mounts"] = {
			["Normal"] = {
				["Horde"] = "17",
				["Alliance"] = "20",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Client"] = {
				["Horde"] = "10",
				["Alliance"] = "10",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Inhouse"] = {
				["Horde"] = "7",
				["Alliance"] = "7",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
		},
		["Raid"] = {
			["Normal"] = {
				["Horde"] = "17",
				["Alliance"] = "20",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Client"] = {
				["Horde"] = "10",
				["Alliance"] = "10",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Inhouse"] = {
				["Horde"] = "7",
				["Alliance"] = "7",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
		},
		["Torghast"] = {
			["Normal"] = {
				["Horde"] = "17",
				["Alliance"] = "20",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Client"] = {
				["Horde"] = "10",
				["Alliance"] = "10",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Inhouse"] = {
				["Horde"] = "7",
				["Alliance"] = "7",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
		},
		["Collect"] = {
			["Normal"] = {
				["Horde"] = "5000",
				["Alliance"] = "5000",
				["AllianceType"] = 2,
				["HordeType"] = 2,
			},
			["Client"] = {
				["Horde"] = "5000",
				["Alliance"] = "5000",
				["AllianceType"] = 2,
				["HordeType"] = 2,
			},
			["Inhouse"] = {
				["Horde"] = "5000",
				["Alliance"] = "5000",
				["AllianceType"] = 2,
				["HordeType"] = 2,
			},
		},
		["PVP"] = {
			["Normal"] = {
				["Horde"] = "13",
				["Alliance"] = "20",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Client"] = {
				["Horde"] = "10",
				["Alliance"] = "10",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Inhouse"] = {
				["Horde"] = "3",
				["Alliance"] = "7",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
		},
		["Legacy"] = {
			["Normal"] = {
				["Horde"] = "17",
				["Alliance"] = "20",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Client"] = {
				["Horde"] = "10",
				["Alliance"] = "10",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Inhouse"] = {
				["Horde"] = "7",
				["Alliance"] = "7",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
		},
		["M+"] = {
			["Normal"] = {
				["Horde"] = "17",
				["Alliance"] = "20",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Client"] = {
				["Horde"] = "10",
				["Alliance"] = "10",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Inhouse"] = {
				["Horde"] = "7",
				["Alliance"] = "7",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
		},
		["Curve"] = {
			["Normal"] = {
				["Horde"] = "17",
				["Alliance"] = "20",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Client"] = {
				["Horde"] = "10",
				["Alliance"] = "10",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
			["Inhouse"] = {
				["Horde"] = "7",
				["Alliance"] = "7",
				["AllianceType"] = 1,
				["HordeType"] = 1,
			},
		},
	},
	["Banking"] = {
		["English"] = {
			["Silvermoon"] = {
				["Alliance"] = "Novadepot-Silvermoon",
				["Horde"] = "Hordenova-Silvermoon",
			},
			["Ravencrest"] = {
				["Alliance"] = "Novadepot-Ravencrest",
				["Horde"] = "Hordenova-Ravencrest",
			},
			["Outland"] = {
				["Alliance"] = "Novadepot-Outland",
				["Horde"] = "Hordenova-Outland",
			},
			["Frostmane"] = {
				["Alliance"] = "Novadepot-Frostmane",
				["Horde"] = "Hordenova-Frostmane",
			},
			["Grim Batol"] = {
				["Alliance"] = "Novadepot-Frostmane",
				["Horde"] = "Hordenova-Frostmane",
			},
			["Aggra(português)"] = {
				["Alliance"] = "Novadepot-Frostmane",
				["Horde"] = "Hordenova-Frostmane",
			},
			["Sylvanas"] = {
				["Alliance"] = "Novadepot-Sylvanas",
				["Horde"] = "Hordenova-Sylvanas",
			},
			["Auchindoun"] = {
				["Alliance"] = "Novadepot-Sylvanas",
				["Horde"] = "Hordenova-Sylvanas",
			},
			["Dunemaul"] = {
				["Alliance"] = "Novadepot-Sylvanas",
				["Horde"] = "Hordenova-Sylvanas",
			},
			["Jaedenar"] = {
				["Alliance"] = "Novadepot-Sylvanas",
				["Horde"] = "Hordenova-Sylvanas",
			},
			["ArgentDawn"] = {
				["Alliance"] = "Novadepot-Argentdawn",
				["Horde"] = "Hordenova-Argentdawn",
			},
			["Defias Brotherhood"] = {
				["Alliance"] = "Novadepot-Defiasbrotherhood",
				["Horde"] = "Hordenova-DefiasBrotherhood",
			},
			["The Venture Co"] = {
				["Alliance"] = "Novadepot-Defiasbrotherhood",
				["Horde"] = "Hordenova-DefiasBrotherhood",
			},
			["Scarshield Legion"] = {
				["Alliance"] = "Novadepot-Defiasbrotherhood",
				["Horde"] = "Hordenova-DefiasBrotherhood",
			},
			["Ravenholdt"] = {
				["Alliance"] = "Novadepot-Defiasbrotherhood",
				["Horde"] = "Hordenova-DefiasBrotherhood",
			},
			["Sporeggar"] = {
				["Alliance"] = "Novadepot-Defiasbrotherhood",
				["Horde"] = "Hordenova-DefiasBrotherhood",
			},
			["Darkmoon Faire"] = {
				["Alliance"] = "Novadepot-Defiasbrotherhood",
				["Horde"] = "Hordenova-DefiasBrotherhood",
			},
			["Earthen Ring"] = {
				["Alliance"] = "Novadepot-Defiasbrotherhood",
				["Horde"] = "Hordenova-DefiasBrotherhood",
			},
			["Tarren Mill"] = {
				["Alliance"] = "Novadepot-TarrenMill",
				["Horde"] = "Hordenova-TarrenMill",
			},
			["Dentarg"] = {
				["Alliance"] = "Novadepot-TarrenMill",
				["Horde"] = "Hordenova-TarrenMill",
			},
			["Chamber of Aspects"] = {
				["Alliance"] = "Novadepot-Chamberofaspects",
				["Horde"] = "Hordenova-Chamberofaspects",
			},
			["Stormscale"] = {
				["Alliance"] = "Novadepot-Stormscale",
				["Horde"] = "Hordenova-Stormscale",
			},
			["Magtheridon"] = {
				["Alliance"] = "Novadepot-Magtheridon",
				["Horde"] = "Hordenova-Magtheridon",
			},
			["Ahn'Qiraj"] = {
				["Alliance"] = "Novadepot-Ahn'qiraj",
				["Horde"] = "Hordenova-Ahn'qiraj",
			},
			["Balnazzar"] = {
				["Alliance"] = "Novadepot-Ahn'qiraj",
				["Horde"] = "Hordenova-Ahn'qiraj",
			},
			["Boulderfist"] = {
				["Alliance"] = "Novadepot-Ahn'qiraj",
				["Horde"] = "Hordenova-Ahn'qiraj",
			},
			["Chromaggus"] = {
				["Alliance"] = "Novadepot-Ahn'qiraj",
				["Horde"] = "Hordenova-Ahn'qiraj",
			},
			["Daggerspine"] = {
				["Alliance"] = "Novadepot-Ahn'qiraj",
				["Horde"] = "Hordenova-Ahn'qiraj",
			},
			["Laughing Skull"] = {
				["Alliance"] = "Novadepot-Ahn'qiraj",
				["Horde"] = "Hordenova-Ahn'qiraj",
			},
			["Shattered Halls"] = {
				["Alliance"] = "Novadepot-Ahn'qiraj",
				["Horde"] = "Hordenova-Ahn'qiraj",
			},
			["Sunstrider"] = {
				["Alliance"] = "Novadepot-Ahn'qiraj",
				["Horde"] = "Hordenova-Ahn'qiraj",
			},
			["Talnivarr"] = {
				["Alliance"] = "Novadepot-Ahn'qiraj",
				["Horde"] = "Hordenova-Ahn'qiraj",
			},
			["Trollbane"] = {
				["Alliance"] = "Novadepot-Ahn'qiraj",
				["Horde"] = "Hordenova-Ahn'qiraj",
			},
			["Stormreaver"] = {
				["Alliance"] = "Novadepot-Stormreaver",
				["Horde"] = "Hordenova-Stormreaver",
			},
			["Dragonmaw"] = {
				["Alliance"] = "Novadepot-Stormreaver",
				["Horde"] = "Hordenova-Stormreaver",
			},
			["Haomarush"] = {
				["Alliance"] = "Novadepot-Stormreaver",
				["Horde"] = "Hordenova-Stormreaver",
			},
			["Spinebreaker"] = {
				["Alliance"] = "Novadepot-Stormreaver",
				["Horde"] = "Hordenova-Stormreaver",
			},
			["Vashj"] = {
				["Alliance"] = "Novadepot-Stormreaver",
				["Horde"] = "Hordenova-Stormreaver",
			},
			["Drak'Thul"] = {
				["Alliance"] = "Novadepot-Drak'Thul",
				["Horde"] = "Hordenova-Drak'Thul",
			},
			["Burning Blade"] = {
				["Alliance"] = "Novadepot-Drak'Thul",
				["Horde"] = "Hordenova-Drak'Thul",
			},
			["Draenor"] = {
				["Alliance"] = "Novadepot-Draenor",
				["Horde"] = "Hordenova-Draenor",
			},
			["Arathor"] = {
				["Alliance"] = "Novadepot-Arathor",
				["Horde"] = "Hordenova-Arathor",
			},
			["Hellfire"] = {
				["Alliance"] = "Novadepot-Arathor",
				["Horde"] = "Hordenova-Arathor",
			},
			["Runetotem"] = {
				["Alliance"] = "Novadepot-Arathor",
				["Horde"] = "Hordenova-Arathor",
			},
			["Kilrogg"] = {
				["Alliance"] = "Novadepot-Arathor",
				["Horde"] = "Hordenova-Arathor",
			},
			["Nagrand"] = {
				["Alliance"] = "Novadepot-Arathor",
				["Horde"] = "Hordenova-Arathor",
			},
			["Quel'Thalas"] = {
				["Alliance"] = "Novadepot-Quel'thalas",
				["Horde"] = "Hordenova-Quel'thalas",
			},
			["Azjol-Nerub"] = {
				["Alliance"] = "Novadepot-Quel'thalas",
				["Horde"] = "Hordenova-Quel'thalas",
			},
			["Darkspear"] = {
				["Alliance"] = "Novadepot-Darkspear",
				["Horde"] = "Hordenova-Darkspear",
			},
			["Terokkar"] = {
				["Alliance"] = "Novadepot-Darkspear",
				["Horde"] = "Hordenova-Darkspear",
			},
			["Saurfang"] = {
				["Alliance"] = "Novadepot-Darkspear",
				["Horde"] = "Hordenova-Darkspear",
			},
			["Burning Steppes"] = {
				["Alliance"] = "Novadepot-Darkspear",
				["Horde"] = "Hordenova-Darkspear",
			},
			["Kor'gall"] = {
				["Alliance"] = "Novadepot-Darkspear",
				["Horde"] = "Hordenova-Darkspear",
			},
			["Executus"] = {
				["Alliance"] = "Novadepot-Darkspear",
				["Horde"] = "Hordenova-Darkspear",
			},
			["Bloodfeather"] = {
				["Alliance"] = "Novadepot-Darkspear",
				["Horde"] = "Hordenova-Darkspear",
			},
			["Shattered Hand"] = {
				["Alliance"] = "Novadepot-Darkspear",
				["Horde"] = "Hordenova-Darkspear",
			},
			["Aszune"] = {
				["Alliance"] = "Novadepot-Aszune",
				["Horde"] = "Hordenova-Aszune",
			},
			["Shadowsong"] = {
				["Alliance"] = "Novadepot-Aszune",
				["Horde"] = "Hordenova-Aszune",
			},
			["Khadgar"] = {
				["Alliance"] = "Novadepot-Khadgar",
				["Horde"] = "Hordenova-Khadgar",
			},
			["Bloodhoof"] = {
				["Alliance"] = "Novadepot-Khadgar",
				["Horde"] = "Hordenova-Khadgar",
			},
			["Nordrassil"] = {
				["Alliance"] = "Novadepot-Nordrassil",
				["Horde"] = "Hordenova-Nordrassil",
			},
			["Bronze Dragonflight"] = {
				["Alliance"] = "Novadepot-Nordrassil",
				["Horde"] = "Hordenova-Nordrassil",
			},
			["Lightbringer"] = {
				["Alliance"] = "Novadepot-Lightbringer",
				["Horde"] = "Hordenova-Lightbringer",
			},
			["Mazrigos"] = {
				["Alliance"] = "Novadepot-Lightbringer",
				["Horde"] = "Hordenova-Lightbringer",
			},
			["Stormrage"] = {
				["Alliance"] = "Novadepot-Stormrage",
				["Horde"] = "Hordenova-Stormrage",
			},
			["Azuremyst"] = {
				["Alliance"] = "Novadepot-Stormrage",
				["Horde"] = "Hordenova-Stormrage",
			},
			["The Maelstrom"] = {
				["Alliance"] = "Novadepot-Themaelstrom",
				["Horde"] = "Hordenova-Themaelstrom",
			},
			["Deathwing"] = {
				["Alliance"] = "Novadepot-Themaelstrom",
				["Horde"] = "Hordenova-Themaelstrom",
			},
			["Lightning's Blade"] = {
				["Alliance"] = "Novadepot-Themaelstrom",
				["Horde"] = "Hordenova-Themaelstrom",
			},
			["Karazhan"] = {
				["Alliance"] = "Novadepot-Themaelstrom",
				["Horde"] = "Hordenova-Themaelstrom",
			},
			["Dragonblight"] = {
				["Alliance"] = "Novadepot-Themaelstrom",
				["Horde"] = "Hordenova-Themaelstrom",
			},
			["Ghostlands"] = {
				["Alliance"] = "Novadepot-Themaelstrom",
				["Horde"] = "Hordenova-Themaelstrom",
			},
			["Aerie Peak"] = {
				["Alliance"] = "Novadepot-Aeriepeak",
				["Horde"] = "Hordenova-Aeriepeak",
			},
			["Bronzebeard"] = {
				["Alliance"] = "Novadepot-Aeriepeak",
				["Horde"] = "Hordenova-Aeriepeak",
			},
			["Vek'Nilash"] = {
				["Alliance"] = "Novadepot-Aeriepeak",
				["Horde"] = "Hordenova-Aeriepeak",
			},
			["Eonar"] = {
				["Alliance"] = "Novadepot-Aeriepeak",
				["Horde"] = "Hordenova-Aeriepeak",
			},
			["Blade's Edge"] = {
				["Alliance"] = "Novadepot-Aeriepeak",
				["Horde"] = "Hordenova-Aeriepeak",
			},
			["Alonsus"] = {
				["Alliance"] = "Novadepot-Alonsus",
				["Horde"] = "Hordenova-Alonsus",
			},
			["Kul Tiras"] = {
				["Alliance"] = "Novadepot-Alonsus",
				["Horde"] = "Hordenova-Alonsus",
			},
			["Anachronos"] = {
				["Alliance"] = "Novadepot-Alonsus",
				["Horde"] = "Hordenova-Alonsus",
			},
			["Emerald Dream"] = {
				["Alliance"] = "Novadepot-Emeralddream",
				["Horde"] = "Hordenova-Emeralddream",
			},
			["Terenas"] = {
				["Alliance"] = "Novadepot-Emeralddream",
				["Horde"] = "Hordenova-Emeralddream",
			},
			["Steamwheedle Cartel"] = {
				["Alliance"] = "Novadepot-Steamwheedlecartel",
				["Horde"] = "Hordenova-Steamwheedlecartel",
			},
			["Emeriss"] = {
				["Alliance"] = "Novadepot-Emeriss",
				["Horde"] = "Hordenova-Emeriss",
			},
			["Hakkar"] = {
				["Alliance"] = "Novadepot-Emeriss",
				["Horde"] = "Hordenova-Emeriss",
			},
			["Crushridge"] = {
				["Alliance"] = "Novadepot-Emeriss",
				["Horde"] = "Hordenova-Emeriss",
			},
			["Agamaggan"] = {
				["Alliance"] = "Novadepot-Emeriss",
				["Horde"] = "Hordenova-Emeriss",
			},
			["Bloodscalp"] = {
				["Alliance"] = "Novadepot-Emeriss",
				["Horde"] = "Hordenova-Emeriss",
			},
			["Twilight's Hammer"] = {
				["Alliance"] = "Novadepot-Emeriss",
				["Horde"] = "Hordenova-Emeriss",
			},
			["Thunderhorn"] = {
				["Alliance"] = "Novadepot-Thunderhorn",
				["Horde"] = "Hordenova-Thunderhorn",
			},
			["Wildhammer"] = {
				["Alliance"] = "Novadepot-Thunderhorn",
				["Horde"] = "Hordenova-Thunderhorn",
			},
			["Aggramar"] = {
				["Alliance"] = "Novadepot-Aggramar",
				["Horde"] = "Hordenova-Aggramar",
			},
			["Hellscream"] = {
				["Alliance"] = "Novadepot-Aggramar",
				["Horde"] = "Hordenova-Aggramar",
			},
			["Al'Akir"] = {
				["Alliance"] = "Novadepot-Al'akir",
				["Horde"] = "Hordenova-Al'akir",
			},
			["Skullcrusher"] = {
				["Alliance"] = "Novadepot-Al'akir",
				["Horde"] = "Hordenova-Al'akir",
			},
			["Xavius"] = {
				["Alliance"] = "Novadepot-Al'akir",
				["Horde"] = "Hordenova-Al'akir",
			},
			["Burning Legion"] = {
				["Alliance"] = "Novadepot-Al'akir",
				["Horde"] = "Hordenova-Al'akir",
			},
			["Doomhammer"] = {
				["Alliance"] = "Novadepot-Doomhammer",
				["Horde"] = "Hordenova-Doomhammer",
			},
			["Turalyon"] = {
				["Alliance"] = "Novadepot-Doomhammer",
				["Horde"] = "Hordenova-Doomhammer",
			},
			["Darksorrow"] = {
				["Alliance"] = "Novadepot-Darksorrow",
				["Horde"] = "Hordenova-Darksorrow",
			},
			["Genjuros"] = {
				["Alliance"] = "Novadepot-Darksorrow",
				["Horde"] = "Hordenova-Darksorrow",
			},
			["Neptulon"] = {
				["Alliance"] = "Novadepot-Darksorrow",
				["Horde"] = "Hordenova-Darksorrow",
			},
			["Zenedar"] = {
				["Alliance"] = "Novadepot-Darksorrow",
				["Horde"] = "Hordenova-Darksorrow",
			},
			["Frostwhisper"] = {
				["Alliance"] = "Novadepot-Darksorrow",
				["Horde"] = "Hordenova-Darksorrow",
			},
			["Bladefist"] = {
				["Alliance"] = "Novadepot-Darksorrow",
				["Horde"] = "Hordenova-Darksorrow",
			},
			["Moonglade"] = {
				["Alliance"] = "Novadepot-Steamwheedlecartel",
				["Horde"] = "Hordenova-Steamwheedlecartel",
			},
			["The Sha'Tar"] = {
				["Alliance"] = "Novadepot-Steamwheedlecartel",
				["Horde"] = "Hordenova-Steamwheedlecartel",
			},
			["Kazzak"] = {
				["Alliance"] = "Novadepot-Kazzak",
				["Horde"] = "Hordenova-Kazzak",
			},
			["Ragnaros"] = {
				["Alliance"] = "Novadepot-Ragnaros",
				["Horde"] = "Hordenova-Ragnaros",
			},
			["Twisting Nether"] = {
				["Alliance"] = "Novadepot-Twisting Nether",
				["Horde"] = "Hordenova-TwistingNether",
			},
		},
		["Spanish"] = {
			["Dun Modr"] = {
				["Alliance"] = "Novadepot-Dunmodr",
				["Horde"] = "Hordenova-Dunmodr",
			},
			["Sanguino"] = {
				["Alliance"] = "Novadepot-Sanguino",
				["Horde"] = "Hordenova-Sanguino",
			},
			["Shen'dralar"] = {
				["Alliance"] = "Novadepot-Sanguino",
				["Horde"] = "Hordenova-Sanguino",
			},
			["Uldum"] = {
				["Alliance"] = "Novadepot-Sanguino",
				["Horde"] = "Hordenova-Sanguino",
			},
			["Zul'jin"] = {
				["Alliance"] = "Novadepot-Sanguino",
				["Horde"] = "Hordenova-Sanguino",
			},
			["C'thun"] = {
				["Alliance"] = "Novadepot-C'thun ",
				["Horde"] = "Hordenova-C'thun",
			},
			["Tyrande"] = {
				["Alliance"] = "Novadepot-Tyrande",
				["Horde"] = "Hordenova-Tyrande",
			},
			["Colinas Pardas"] = {
				["Alliance"] = "Novadepot-Tyrande",
				["Horde"] = "Hordenova-Tyrande",
			},
			["Los Errantes"] = {
				["Alliance"] = "Novadepot-Tyrande",
				["Horde"] = "Hordenova-Tyrande",
			},
			["Minahonda"] = {
				["Alliance"] = "Novadepot-Minahonda",
				["Horde"] = "Hordenova-Minahonda",
			},
			["Exodar"] = {
				["Alliance"] = "Novadepot-Minahonda",
				["Horde"] = "Hordenova-Minahonda",
			},
		},
		["Italian"] = {
			["Nemesis"] = {
				["Alliance"] = "Novadepot-Nemesis",
				["Horde"] = "Hordenova-Nemesis",
			},
			["Pozzo dell'Eternità"] = {
				["Alliance"] = "Novadepot-Pozzo dell'Eternità",
				["Horde"] = "Hordenova-Pozzo dell'Eternità",
			},
		},
		["German"] = {
			["Antonidas"] = {
				["Alliance"] = "Novadepot-Antonidas",
				["Horde"] = "Hordenova-Antonidas",
			},
			["Aegwynn"] = {
				["Alliance"] = "Novadepot-Aegwynn",
				["Horde"] = "Hordenova-Aegwynn",
			},
			["Blackmoore"] = {
				["Alliance"] = "Novadepot-Blackmoore",
				["Horde"] = "Hordenova-Blackmoore",
			},
			["Lordaeron"] = {
				["Alliance"] = "Novadepot-Blackmoore",
				["Horde"] = "Hordenova-Blackmoore",
			},
			["Tichondrius"] = {
				["Alliance"] = "Novadepot-Blackmoore",
				["Horde"] = "Hordenova-Blackmoore",
			},
			["Malfurion"] = {
				["Alliance"] = "Novadepot-Malfurion",
				["Horde"] = "Hordenova-Malfurion",
			},
			["Malygos"] = {
				["Alliance"] = "Novadepot-Malfurion",
				["Horde"] = "Hordenova-Malfurion",
			},
			["Blackhand"] = {
				["Alliance"] = "Novadepot-Blackhand",
				["Horde"] = "Hordenova-Blackhand",
			},
			["Mal'Ganis"] = {
				["Alliance"] = "Novadepot-Blackhand",
				["Horde"] = "Hordenova-Blackhand",
			},
			["Taerar"] = {
				["Alliance"] = "Novadepot-Blackhand",
				["Horde"] = "Hordenova-Blackhand",
			},
			["Echsenkessel"] = {
				["Alliance"] = "Novadepot-Blackhand",
				["Horde"] = "Hordenova-Blackhand",
			},
			["Rexxar"] = {
				["Alliance"] = "Novadepot-Rexxar",
				["Horde"] = "Hordenova-Rexxar",
			},
			["Alleria"] = {
				["Alliance"] = "Novadepot-Rexxar",
				["Horde"] = "Hordenova-Rexxar",
			},
			["Die Aldor"] = {
				["Alliance"] = "Novadepot-Diealdor",
				["Horde"] = "Hordenova-Diealdor",
			},
			["Alexstrasza"] = {
				["Alliance"] = "Novadepot-Alexstrasza",
				["Horde"] = "Hordenova-Alexstrasza",
			},
			["Nethersturm"] = {
				["Alliance"] = "Novadepot-Alexstrasza",
				["Horde"] = "Hordenova-Alexstrasza",
			},
			["Madmortem"] = {
				["Alliance"] = "Novadepot-Alexstrasza",
				["Horde"] = "Hordenova-Alexstrasza",
			},
			["Proudmoore"] = {
				["Alliance"] = "Novadepot-Alexstrasza",
				["Horde"] = "Hordenova-Alexstrasza",
			},
			["Area 52"] = {
				["Alliance"] = "Novadepot-Area52",
				["Horde"] = "Hordenova-Area52",
			},
			["Sen'jin"] = {
				["Alliance"] = "Novadepot-Area52",
				["Horde"] = "Hordenova-Area52",
			},
			["Un'Goro"] = {
				["Alliance"] = "Novadepot-Area52",
				["Horde"] = "Hordenova-Area52",
			},
			["Gorgonnash"] = {
				["Alliance"] = "Novadepot-Gorgonnash",
				["Horde"] = "Hordenova-Gorgonnash",
			},
			["Destromath"] = {
				["Alliance"] = "Novadepot-Gorgonnash",
				["Horde"] = "Hordenova-Gorgonnash",
			},
			["Mannoroth"] = {
				["Alliance"] = "Novadepot-Gorgonnash",
				["Horde"] = "Hordenova-Gorgonnash",
			},
			["Nefarian"] = {
				["Alliance"] = "Novadepot-Gorgonnash",
				["Horde"] = "Hordenova-Gorgonnash",
			},
			["Nera'thor"] = {
				["Alliance"] = "Novadepot-Gorgonnash",
				["Horde"] = "Hordenova-Gorgonnash",
			},
			["Gilneas"] = {
				["Alliance"] = "Novadepot-Gorgonnash",
				["Horde"] = "Hordenova-Gorgonnash",
			},
			["Ulduar"] = {
				["Alliance"] = "Novadepot-Gorgonnash",
				["Horde"] = "Hordenova-Gorgonnash",
			},
			["Ambossar"] = {
				["Alliance"] = "Novadepot-Ambossar",
				["Horde"] = "Hordenova-Ambossar",
			},
			["Kargath"] = {
				["Alliance"] = "Novadepot-Ambossar",
				["Horde"] = "Hordenova-Ambossar",
			},
			["Ysera"] = {
				["Alliance"] = "Novadepot-Ysera",
				["Horde"] = "Hordenova-Ysera",
			},
			["Malorne"] = {
				["Alliance"] = "Novadepot-Ysera",
				["Horde"] = "Hordenova-Ysera",
			},
			["Garrosh"] = {
				["Alliance"] = "Novadepot-Garrosh",
				["Horde"] = "Hordenova-Garrosh",
			},
			["Nozdormu"] = {
				["Alliance"] = "Novadepot-Garrosh",
				["Horde"] = "Hordenova-Garrosh",
			},
			["Shattrath"] = {
				["Alliance"] = "Novadepot-Garrosh",
				["Horde"] = "Hordenova-Garrosh",
			},
			["Perenolde"] = {
				["Alliance"] = "Novadepot-Garrosh",
				["Horde"] = "Hordenova-Garrosh",
			},
			["Teldrassil"] = {
				["Alliance"] = "Novadepot-Garrosh",
				["Horde"] = "Hordenova-Garrosh",
			},
			["Aman'Thul"] = {
				["Alliance"] = "Novadepot-Aman'thul ",
				["Horde"] = "Hordenova-Aman'thul",
			},
			["Anub'arak"] = {
				["Alliance"] = "Novadepot-Aman'thul ",
				["Horde"] = "Hordenova-Aman'thul",
			},
			["Dalvengyr"] = {
				["Alliance"] = "Novadepot-Aman'thul ",
				["Horde"] = "Hordenova-Aman'thul",
			},
			["Frostmourne"] = {
				["Alliance"] = "Novadepot-Aman'thul ",
				["Horde"] = "Hordenova-Aman'thul",
			},
			["Nazjatar"] = {
				["Alliance"] = "Novadepot-Aman'thul ",
				["Horde"] = "Hordenova-Aman'thul",
			},
			["Zuluhed"] = {
				["Alliance"] = "Novadepot-Aman'thul ",
				["Horde"] = "Hordenova-Aman'thul",
			},
			["Khaz'goroth"] = {
				["Alliance"] = "Novadepot-Khaz'goroth",
				["Horde"] = "Hordenova-Khaz'goroth",
			},
			["Arygos"] = {
				["Alliance"] = "Novadepot-Khaz'goroth",
				["Horde"] = "Hordenova-Khaz'goroth",
			},
			["Tirion"] = {
				["Alliance"] = "Novadepot-Tirion",
				["Horde"] = "Hordenova-Tirion",
			},
			["Durotan"] = {
				["Alliance"] = "Novadepot-Tirion",
				["Horde"] = "Hordenova-Tirion",
			},
			["Arthas"] = {
				["Alliance"] = "Novadepot-Tirion",
				["Horde"] = "Hordenova-Tirion",
			},
			["Blutkessel"] = {
				["Alliance"] = "Novadepot-Tirion",
				["Horde"] = "Hordenova-Tirion",
			},
			["Kel'Thuzad"] = {
				["Alliance"] = "Novadepot-Tirion",
				["Horde"] = "Hordenova-Tirion",
			},
			["Vek'lor"] = {
				["Alliance"] = "Novadepot-Tirion",
				["Horde"] = "Hordenova-Tirion",
			},
			["Wrathbringer"] = {
				["Alliance"] = "Novadepot-Tirion",
				["Horde"] = "Hordenova-Tirion",
			},
			["Baelgun"] = {
				["Alliance"] = "Novadepot-Lothar",
				["Horde"] = "Hordenova-Lothar",
			},
			["Lothar"] = {
				["Alliance"] = "Novadepot-Lothar",
				["Horde"] = "Hordenova-Lothar",
			},
			["Azshara"] = {
				["Alliance"] = "Novadepot-Lothar",
				["Horde"] = "Hordenova-Lothar",
			},
			["Krag'jin"] = {
				["Alliance"] = "Novadepot-Lothar",
				["Horde"] = "Hordenova-Lothar",
			},
			["Dun Morogh"] = {
				["Alliance"] = "Novadepot-DunMorogh",
				["Horde"] = "Hordenova-DunMorogh",
			},
			["Norgannon"] = {
				["Alliance"] = "Novadepot-DunMorogh",
				["Horde"] = "Hordenova-DunMorogh",
			},
			["Die Silberne Hand"] = {
				["Alliance"] = "Novadepot-Diesilbernehand",
				["Horde"] = "Hordenova-Diesilbernehand",
			},
			["Die ewige Wacht"] = {
				["Alliance"] = "Novadepot-Diesilbernehand",
				["Horde"] = "Hordenova-Diesilbernehand",
			},
			["Kult der Verdammten"] = {
				["Alliance"] = "Novadepot-Diesilbernehand",
				["Horde"] = "Hordenova-Diesilbernehand",
			},
			["Der abyssische Rat"] = {
				["Alliance"] = "Novadepot-Diesilbernehand",
				["Horde"] = "Hordenova-Diesilbernehand",
			},
			["Die Todeskrallen"] = {
				["Alliance"] = "Novadepot-Diesilbernehand",
				["Horde"] = "Hordenova-Diesilbernehand",
			},
			["Das Konsortium"] = {
				["Alliance"] = "Novadepot-Diesilbernehand",
				["Horde"] = "Hordenova-Diesilbernehand",
			},
			["Die Arguswacht"] = {
				["Alliance"] = "Novadepot-Diesilbernehand",
				["Horde"] = "Hordenova-Diesilbernehand",
			},
			["Das Syndikat"] = {
				["Alliance"] = "Novadepot-Diesilbernehand",
				["Horde"] = "Hordenova-Diesilbernehand",
			},
			["Zirkel des Cenarius"] = {
				["Alliance"] = "Novadepot-Zirkeldescenarius",
				["Horde"] = "Hordenova-Zirkeldescenarius",
			},
			["Todeswache"] = {
				["Alliance"] = "Novadepot-Zirkeldescenarius",
				["Horde"] = "Hordenova-Zirkeldescenarius",
			},
			["Der Rat von Dalaran"] = {
				["Alliance"] = "Novadepot-Zirkeldescenarius",
				["Horde"] = "Hordenova-Zirkeldescenarius",
			},
			["Der Mithrilorden"] = {
				["Alliance"] = "Novadepot-Zirkeldescenarius",
				["Horde"] = "Hordenova-Zirkeldescenarius",
			},
			["Forscheliga"] = {
				["Alliance"] = "Novadepot-Zirkeldescenarius",
				["Horde"] = "Hordenova-Zirkeldescenarius",
			},
			["Die Nachtwache"] = {
				["Alliance"] = "Novadepot-Zirkeldescenarius",
				["Horde"] = "Hordenova-Zirkeldescenarius",
			},
			["Onyxia"] = {
				["Alliance"] = "Novadepot-Onyxia",
				["Horde"] = "Hordenova-Onyxia",
			},
			["Dethecus"] = {
				["Alliance"] = "Novadepot-Onyxia",
				["Horde"] = "Hordenova-Onyxia",
			},
			["Mug'thol"] = {
				["Alliance"] = "Novadepot-Onyxia",
				["Horde"] = "Hordenova-Onyxia",
			},
			["Terrordar"] = {
				["Alliance"] = "Novadepot-Onyxia",
				["Horde"] = "Hordenova-Onyxia",
			},
			["Theradras"] = {
				["Alliance"] = "Novadepot-Onyxia",
				["Horde"] = "Hordenova-Onyxia",
			},
			["Anetheron"] = {
				["Alliance"] = "Novadepot-Anetheron",
				["Horde"] = "Hordenova-Anetheron",
			},
			["Festung der Stürme"] = {
				["Alliance"] = "Novadepot-Anetheron",
				["Horde"] = "Hordenova-Anetheron",
			},
			["Gul'dan"] = {
				["Alliance"] = "Novadepot-Anetheron",
				["Horde"] = "Hordenova-Anetheron",
			},
			["Kil'jaeden"] = {
				["Alliance"] = "Novadepot-Anetheron",
				["Horde"] = "Hordenova-Anetheron",
			},
			["Nathrezim"] = {
				["Alliance"] = "Novadepot-Anetheron",
				["Horde"] = "Hordenova-Anetheron",
			},
			["Rajaxx"] = {
				["Alliance"] = "Novadepot-Anetheron",
				["Horde"] = "Hordenova-Anetheron",
			},
			["Thrall"] = {
				["Alliance"] = "Novadepot-Thrall",
				["Horde"] = "Hordenova-Thrall",
			},
			["Blackrock"] = {
				["Alliance"] = "Nbcbackup-Blackrock",
				["Horde"] = "Hordenova-Blackrock",
			},
			["Eredar"] = {
				["Alliance"] = "Novadepot-Eredar",
				["Horde"] = "Hordenova-Eredar",
			},
			["Frostwolf"] = {
				["Alliance"] = "Novadepot-Frostwolf",
				["Horde"] = "Hordenova-Frostwolf",
			},
		},
		["French"] = {
			["Archimonde"] = {
				["Alliance"] = "Novadepot-Archimonde ",
				["Horde"] = "Hordenova-Archimonde",
			},
			["Khaz Modan"] = {
				["Alliance"] = "Novadepot-Khazmodan ",
				["Horde"] = "Hordenova-Khazmodan",
			},
			["Hyjal"] = {
				["Alliance"] = "Novadepot-Hyjal ",
				["Horde"] = "Hordenova-Hyjal",
			},
			["Ysondre"] = {
				["Alliance"] = "Novadepot-Ysondre ",
				["Horde"] = "Hordenova-Ysondre",
			},
			["Elune"] = {
				["Alliance"] = "Novadepot-Elune",
				["Horde"] = "Hordenova-Elune",
			},
			["Varimathras"] = {
				["Alliance"] = "Novadepot-Elune",
				["Horde"] = "Hordenova-Elune",
			},
			["Dalaran"] = {
				["Alliance"] = "Novadepot-Dalaran",
				["Horde"] = "Hordenova-Dalaran",
			},
			["Marécage de Zangar"] = {
				["Alliance"] = "Novadepot-Dalaran",
				["Horde"] = "Hordenova-Dalaran",
			},
			["Cho'gall"] = {
				["Alliance"] = "Novadepot-Dalaran",
				["Horde"] = "Hordenova-Dalaran",
			},
			["Eldre'Thalas"] = {
				["Alliance"] = "Novadepot-Dalaran",
				["Horde"] = "Hordenova-Dalaran",
			},
			["Sinstralis"] = {
				["Alliance"] = "Novadepot-Dalaran",
				["Horde"] = "Hordenova-Dalaran",
			},
			["Medivh , Suramar"] = {
				["Alliance"] = "Novadepot-Medivh",
				["Horde"] = "Hordenova-Medivh",
			},
			["Confrerie du Thorium"] = {
				["Alliance"] = "Novadepot-Kirintor ",
				["Horde"] = "Hordenova-Kirintor",
			},
			["Les Clairvoyants"] = {
				["Alliance"] = "Novadepot-Kirintor ",
				["Horde"] = "Hordenova-Kirintor",
			},
			["Les Sentinelles"] = {
				["Alliance"] = "Novadepot-Kirintor ",
				["Horde"] = "Hordenova-Kirintor",
			},
			["Kirin Tor"] = {
				["Alliance"] = "Novadepot-Kirintor ",
				["Horde"] = "Hordenova-Kirintor",
			},
			["Culte de la Rive noire"] = {
				["Alliance"] = "Novadepot-Kirintor ",
				["Horde"] = "Hordenova-Kirintor",
			},
			["La Croisade écarlate"] = {
				["Alliance"] = "Novadepot-Kirintor ",
				["Horde"] = "Hordenova-Kirintor",
			},
			["Conseil Des Ombres"] = {
				["Alliance"] = "Novadepot-Kirintor ",
				["Horde"] = "Hordenova-Kirintor",
			},
			["Chants éternels"] = {
				["Alliance"] = "Novadepot-Vol'jin",
				["Horde"] = "Hordenova-Chantséternels",
			},
			["Vol'jin"] = {
				["Alliance"] = "Novadepot-Vol'jin",
				["Horde"] = "Hordenova-Chantséternels",
			},
			["Uldaman"] = {
				["Alliance"] = "Novadepot-Uldaman",
				["Horde"] = "Hordenova-Uldaman",
			},
			["Drek'Thar"] = {
				["Alliance"] = "Novadepot-Uldaman",
				["Horde"] = "Hordenova-Uldaman",
			},
			["Krasus"] = {
				["Alliance"] = "Novadepot-Uldaman",
				["Horde"] = "Hordenova-Uldaman",
			},
			["Eitrigg"] = {
				["Alliance"] = "Novadepot-Uldaman",
				["Horde"] = "Hordenova-Uldaman",
			},
			["Illidan"] = {
				["Alliance"] = "Novadepot-Illidan",
				["Horde"] = "Hordenova-Illidan",
			},
			["Arathi"] = {
				["Alliance"] = "Novadepot-Illidan",
				["Horde"] = "Hordenova-Illidan",
			},
			["Naxxramas"] = {
				["Alliance"] = "Novadepot-Illidan",
				["Horde"] = "Hordenova-Illidan",
			},
			["Temple noir"] = {
				["Alliance"] = "Novadepot-Illidan",
				["Horde"] = "Hordenova-Illidan",
			},
			["Kael'Thas"] = {
				["Alliance"] = "Novadepot-Kael'Thas",
				["Horde"] = "Hordenova-Kael'Thas",
			},
			["Arak-arahm"] = {
				["Alliance"] = "Novadepot-Kael'Thas",
				["Horde"] = "Hordenova-Kael'Thas",
			},
			["Rashgarroth"] = {
				["Alliance"] = "Novadepot-Kael'Thas",
				["Horde"] = "Hordenova-Kael'Thas",
			},
			["Throk'Feroth"] = {
				["Alliance"] = "Novadepot-Kael'Thas",
				["Horde"] = "Hordenova-Kael'Thas",
			},
			["Sargeras"] = {
				["Alliance"] = "Novadepot-Sargeras",
				["Horde"] = "Hordenova-Sargeras",
			},
			["Garona"] = {
				["Alliance"] = "Novadepot-Sargeras",
				["Horde"] = "Hordenova-Sargeras",
			},
			["Ner’zhul"] = {
				["Alliance"] = "Novadepot-Sargeras",
				["Horde"] = "Hordenova-Sargeras",
			},
		},
	}
}

local function BuildBankingOptionsArgs(arg_table, options)
	for realmRegion,_ in pairs(options) do
		if realmRegion ~= "" then 
			arg_table[realmRegion] = {
				type = 'group',
				name = realmRegion,
				args = {}
			}
			
			for realmName, k in pairs(options[realmRegion]) do
				arg_table[realmRegion].args[realmName] = {
					type = 'group',
					name = realmName,
					args = {
						Alliance = {
							type = 'input',
							name = 'Alliance',
							order = 1,
							get = 'GetOption',
							set = 'SetOption',
						},
						Horde = {
							type = 'input',
							name = 'Horde',
							order = 2,
							get = 'GetOption',
							set = 'SetOption',
						},
					}
				}
			end
		end
	end
end

local function BuildAdvertiserCutsOptionArgs(arg_table, options)
	--arg_table = {}
	--print(arg_table)
	if options ~= nil then
		for i, k in pairs(options) do
			--print(k)
			if k ~= "" then
				local section = k
				arg_table[section] = {
					type = "group",
					name = "Boost Type: "..section,
					inline = true,
					args = {
						Normal = {
							type = "group",
							name = "Normal",
							order = 1,
							inline = true,
							args = {
								Horde = {
									type = "input",
									name = "Horde",
									order = 1,
									get = 'GetOption',
									set = 'SetOption',
								},
								HordeType = {
									type = "select",
									name = "",
									order = 2,
									values = { [1] = "%", [2] = "g" },
									get = 'GetOption',
									set = 'SetOption',
								},
								Alliance = {
									type = "input",
									name = "Alliance",
									order = 3,
									get = 'GetOption',
									set = 'SetOption',
								},
								AllianceType = {
									type = "select",
									name = "",
									order = 4,
									values = { [1] = "%", [2] = "g" },
									get = 'GetOption',
									set = 'SetOption',
								},
							},
						},
						Client = {
							type = "group",
							name = "Client",
							order = 2,
							inline = true,
							args = {
								Horde = {
									type = "input",
									name = "Horde",
									order = 1,
									get = 'GetOption',
									set = 'SetOption',
								},
								HordeType = {
									type = "select",
									name = "",
									order = 2,
									values = { [1] = "%", [2] = "g" },
									get = 'GetOption',
									set = 'SetOption',
								},
								Alliance = {
									type = "input",
									name = "Alliance",
									order = 3,
									get = 'GetOption',
									set = 'SetOption',
								},
								AllianceType = {
									type = "select",
									name = "",
									order = 4,
									values = { [1] = "%", [2] = "g" },
									get = 'GetOption',
									set = 'SetOption',
								},
							},
						},
						Inhouse = {
							type = "group",
							name = "Inhouse",
							order = 3,
							inline = true,
							args = {
								Horde = {
									type = "input",
									name = "Horde",
									order = 1,
									get = 'GetOption',
									set = 'SetOption',
								},
								HordeType = {
									type = "select",
									name = "",
									order = 2,
									values = { [1] = "%", [2] = "g" },
									get = 'GetOption',
									set = 'SetOption',
								},
								Alliance = {
									type = "input",
									name = "Alliance",
									order = 3,
									get = 'GetOption',
									set = 'SetOption',
								},
								AllianceType = {
									type = "select",
									name = "",
									order = 4,
									values = { [1] = "%", [2] = "g" },
									get = 'GetOption',
									set = 'SetOption',
								},
							},
						},
					},
				}
			end
		end
	end
end

function nova:GetOption(info)
	--print(#info)
	local opt = novaOptions[info[#info]]
	local optname=info[#info]
	if #info == 4 then
		if novaOptions [info[#info-3]] == nil then novaOptions [info[#info-3]] = {}	end
		if novaOptions [info[#info-3]] [info[#info-2]] == nil then novaOptions [info[#info-3]] [info[#info-2]] = {}	end
		if novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] == nil then novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] = {} end
		
		opt = novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] [info[#info]]
		optname=info[#info-3].."."..info[#info-2].."."..info[#info-1].."."..info[#info]
		
	elseif #info == 2 then
		if novaOptions[info[#info-1]] == nil then
			novaOptions[info[#info-1]]={}
		end
		
		opt = novaOptions[info[#info-1]] [info[#info]]
		optname=info[#info-1].."."..info[#info]
		
    end
	--print("The " .. tostring(optname) .. " returned as: " .. tostring(opt) )
	
	return opt
end

function nova:SetOption(info, value)
	--print(#info)
	if #info == 4 then
		if novaOptions [info[#info-3]] == nil then novaOptions [info[#info-3]] = {}	end
		if novaOptions [info[#info-3]] [info[#info-2]] == nil then novaOptions [info[#info-3]] [info[#info-2]] = {}	end
		if novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] == nil then novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] = {} end
		
		novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] [info[#info]] = value
		
	elseif #info == 2 then
		if novaOptions [info[#info-1]] == nil then
			novaOptions [info[#info-1]] = {}
		end
		novaOptions [info[#info-1]] [info[#info]] = value
		--print("The " .. info[#info-1].."."..info[#info] .. " was set to: " .. tostring(value) )
		
	elseif #info == 1 then
		novaOptions [info[#info]] = value
		--print("The " .. info[#info] .. " was set to: " .. tostring(value) )
		
	end
	
	if info[#info-1] == "Boosts" then
		myOptionsTable.args.AdvertiserCuts.args = {}
		BuildAdvertiserCutsOptionArgs(myOptionsTable.args.AdvertiserCuts.args, novaOptions.Boosts)
	end
	
	if info[#info] == "Account" then
		if NovaBookingHistoryAvailable then
			for i,v in pairs(NovaBookingHistory) do
				if v.ID == novaOptions.General.AccountID then
					if value == nil or value == "" then
						v.Accountname = " "
					else
						v.Accountname = value
					end
					v.LastChanged = date("%d.%m.%y %H:%M:%S")
				end
			end
		end
	end
end


-----------------------------------------------------------------------------------------------------
---------------------------------------------- HISTORY ----------------------------------------------
-----------------------------------------------------------------------------------------------------

local function FormatMoneyTostring(amount)
	local outstring=""
	amount = tonumber(amount) or 0
	if (amount >= 0) then
		outstring = GetCoinTextureString(amount + 0.0001)
		local formatted = outstring
		while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
			if (k==0) then
				break
			end
		end
		outstring = formatted
	end
	return outstring
end

local function getAdvertiserCut()
	goldCollected = 0
	cutAlliance = 0
	cutHorde = 0
	
	for i,k in pairs(NovaBookingHistory) do
		goldCollected = goldCollected + k.Gold
		if k.AdvertiserCutGold ~= nil and k.AdvertiserCutGold ~= "" and k.AdvertiserCut ~= nil and k.AdvertiserCut ~= "" and k.AdvertiserCutType ~= nil and k.AdvertiserCutType ~= "" then
			if k.Faction == "Alliance" then cutAlliance = cutAlliance + k.AdvertiserCutGold end
			if k.Faction == "Horde" then cutHorde = cutHorde + k.AdvertiserCutGold end
		end
	end
	
	if goldCutAllianceLabel ~= nil then
		goldCutAllianceLabel:SetText("[A] Cut:    "..FormatMoneyTostring(cutAlliance))
		goldCutHordeLabel:SetText("[H] Cut:    "..FormatMoneyTostring(cutHorde))
		goldCutTotalLabel:SetText("Total Cut: "..FormatMoneyTostring(cutAlliance + cutHorde))
		goldCollectedLabel:SetText("Gold Collected: "..FormatMoneyTostring(goldCollected))
	end
end


local function setHistoryData()
	--print("--setHistoryData")

	if NovaBookingHistoryAvailable then
		--print("NovaBookingHistoryAvailable: true")
		local testdata={}
		--local i = 0
		for i = #NovaBookingHistory, 1, -1 do
			if NovaBookingHistory[i].Valid then
				tinsert(testdata, {cols = {
					{value = NovaBookingHistory[i].Index},
					{value = NovaBookingHistory[i].Timestamp},
					{value = NovaBookingHistory[i].Accountname},
					{value = NovaBookingHistory[i].Client},
					{value = NovaBookingHistory[i].ClientType},
					{value = NovaBookingHistory[i].BoostType},
					{value = NovaBookingHistory[i].Gold},
					{value = NovaBookingHistory[i].IsSent},
					{value = NovaBookingHistory[i].DiscordLink},
					{value = NovaBookingHistory[i].Notes},
				}})
			end
			
		end
		
		if boosthistoryST ~= nil then
			boosthistoryST:SetData(testdata)
		end
		
		getAdvertiserCut()
	end
end


local function getIndex(tab, val)
	--print("--getIndex")
    local index = nil
    for i, v in ipairs (tab) do 
        if (v.Index == val) then
          index = i 
        end
    end
    return index
end


local function DeleteItem(row)
	--print("--DeleteItem "..row)
	local idx = getIndex(NovaBookingHistory, row) -- index = 1 found at idx = 2
	if idx == nil then 
		print("Erorr in the matrix")
	else
		table.remove(NovaBookingHistory, idx) -- remove Table[2] and shift remaining entries

		for i, v in ipairs (NovaBookingHistory) do 
			v.Index = i
		end

		--print("Deleted! "..row)
	end
	sortBookings()
	setHistoryData()
end

local function setMailContent(index, SendMailNameEditBox, SendMailSubjectEditBox, SendMailBodyEditBox, SendMailMoneyGold, depotName)
	local realmName,_ = string.gsub(GetRealmName(), "%s+", "")
	SendMailNameEditBox:SetText(depotName)
	
	depotNameTemp, depotNameRealmTemp = depotName:match("([^\-]+)\-([^\-]+)")
	
	if depotNameRealmTemp:lower() == realmName:lower() then
		advName = depotNameTemp
	else
		advName = depotNameTemp.."-"..depotNameRealmTemp
	end
	local advFriend = C_FriendList.GetFriendInfo(advName)
	if advFriend == nil then
		C_FriendList.AddFriend(advName)
	end
	
	if novaOptions.Mailing.InputSubjectPrefix == nil then
		novaOptions.Mailing.InputSubjectPrefix = ""
	end
	if novaOptions.Mailing.InputSubjectPrefix == "" then
		SendMailSubjectEditBox:SetText(NovaBookingHistory[index].BoostType)
	elseif NovaBookingHistory[index].BoostType == "Collect" and NovaBookingHistory[index].CollectBoostType ~= nil then
		SendMailSubjectEditBox:SetText(novaOptions.Mailing.InputSubjectPrefix.." "..NovaBookingHistory[index].CollectBoostType.." "..NovaBookingHistory[index].BoostType)
	else
		SendMailSubjectEditBox:SetText(novaOptions.Mailing.InputSubjectPrefix.." "..NovaBookingHistory[index].BoostType)
	end
	
	if novaOptions.Mailing.InputAdvertiser == nil then
		print("Go to Interface -> Addons -> NovaBooking -> Mailing -> Set your DiscordName-Server as Advertiser Name")
		novaOptions.Mailing.InputAdvertiser = ""
	else
		local boosterGold = NovaBookingHistory[index].Gold/10000
		
		local mailBodyTextInhouse
		local mailBodyText
		local boosterGoldInhouseFull = floor(boosterGold * 100 / 90, 0)
		if NovaBookingHistory[index].DiscordLink ~= nil and NovaBookingHistory[index].DiscordLink ~= "" and NovaBookingHistory[index].DiscordLink ~= " " then
			local runID = mysplit(NovaBookingHistory[index].DiscordLink,"/")
			mailBodyTextInhouse = novaOptions.Mailing.InputAdvertiser.."\n"..boosterGoldInhouseFull.."\n\nInhouse Pot\n"..boosterGold.."\n\nRun ID\n"..runID[#runID]
			if NovaBookingHistory[index].BoostType == "Collect" then
				mailBodyText = NovaBookingHistory[index].CollectTrialAdvertiser.."\n"..boosterGold.."\n\nCollector\n"..novaOptions.Mailing.InputAdvertiser.."\n\n\nRun ID\n"..runID[#runID]
			else
				mailBodyText = novaOptions.Mailing.InputAdvertiser.."\n"..boosterGold.."\n\n\nRun ID\n"..runID[#runID]
			end
		else
			mailBodyTextInhouse = novaOptions.Mailing.InputAdvertiser.."\n"..boosterGoldInhouseFull.."\n\nInhouse Pot\n"..boosterGold
			if NovaBookingHistory[index].BoostType == "Collect" then
				mailBodyText = NovaBookingHistory[index].CollectTrialAdvertiser.."\n"..boosterGold.."\n\nCollector\n"..novaOptions.Mailing.InputAdvertiser
			else
				mailBodyText = novaOptions.Mailing.InputAdvertiser.."\n"..boosterGold
			end
		end
		if NovaBookingHistory[index].ClientType == "Inhouse" then
			SendMailBodyEditBox:SetText(mailBodyTextInhouse)
		else
			SendMailBodyEditBox:SetText(mailBodyText)
		end
	end
	
	SendMailMoneyGold:SetText(NovaBookingHistory[index].Gold/10000)
	MailLastClicked = index

end

local function getDepotName()

	local currentRealm,_ = string.gsub(GetRealmName(), "%s+", "")

	for serverRegion,_ in pairs(novaOptions.Banking) do
		for serverName,bankingChar in pairs(novaOptions.Banking[serverRegion]) do
			
			local serverName,_ = string.gsub(serverName, "%s+", "")
			
			if serverName:lower() == currentRealm:lower() then
				local currentFaction, _ = UnitFactionGroup("player")
				return bankingChar[currentFaction]
			end
			
		end
	end
	
	return nil
end

function table.shallow_copy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
	return t2
end

local function splitEntry(var, index)
	if tonumber(var) > 1 then
		for i=1,var-1 do
			local tab = table.shallow_copy(NovaBookingHistory[index])
			tab.Index = #NovaBookingHistory+1
			tab.Gold = floor(tab.Gold/tonumber(var)/10000, 0)*10000
			tab.Timestamp = date("%d.%m.%y %H:%M")
			tab.Notes = tab.Notes.." ".. i+1 .."/"..var
			tab.LastChanged = date("%d.%m.%y %H:%M:%S")
			tab.AdvertiserCutGold = floor(tab.AdvertiserCutGold/tonumber(var)/10000, 0)*10000
			tinsert(NovaBookingHistory, tab)
		end
		
		NovaBookingHistory[index].Gold = floor(NovaBookingHistory[index].Gold/tonumber(var)/10000, 0)*10000
		NovaBookingHistory[index].Notes = NovaBookingHistory[index].Notes.." 1/"..var
		NovaBookingHistory[index].LastChanged = date("%d.%m.%y %H:%M:%S")
		NovaBookingHistory[index].AdvertiserCutGold = floor(NovaBookingHistory[index].AdvertiserCutGold/tonumber(var)/10000, 0)*10000
		
		sortBookings()
		setHistoryData()
	end
end


local function ShowHistory()
	local SendDataButton
	
	goldCollected = 0
	cutAlliance = 0
	cutHorde = 0
	
	historyOpened = true
	
	f = AceGUI:Create("Frame")
	
	f.frame:SetFrameStrata("BACKGROUND")
	f.frame:SetPropagateKeyboardInput(true)
	f:SetTitle("NovaBooking History Page")
	f:SetStatusText(novaOptions.General.Account)
	f:SetLayout("Fill")
	
	f:SetCallback("OnClose",function(widget)
		historyOpened = false
		SendDataButton:Hide()
		local f=widget.ScrollTable.frame
		f:Hide()
		widget.ScrollTable:SetData({})
		f:UnregisterAllEvents()
		f:ClearAllPoints()
		widget.ScrollTable = nil
		AceGUI:Release(widget) 
	end)
	
	f.frame:SetScript("OnKeyDown", function(widget, key)
		if key == "ESCAPE" then
			f.frame:SetPropagateKeyboardInput(false)
			f:ClearAllPoints()
			AceGUI:Release(f)
		end
	end)
	

	local boostshistorycols = {
		{ name= "#", width = 25, defaultsort = "dsc", 
			DoCellUpdate = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					local cellData = data[realrow].cols[column]
					cellFrame.text:SetText(cellData.value)
					if NovaBookingHistory[index].IsSent == true then
						cellFrame.text:SetTextColor(0.5,0.5,0.5)
					else
						cellFrame.text:SetTextColor(1,1,1)
					end
				end
			end
		},
		{ name= 'DATETIME', width = 100, defaultsort = "dsc", 
			DoCellUpdate = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					local cellData = data[realrow].cols[column]
					cellFrame.text:SetText(cellData.value)
					if NovaBookingHistory[index].IsSent == true then
						cellFrame.text:SetTextColor(0.5,0.5,0.5)
					else
						cellFrame.text:SetTextColor(1,1,1)
					end
				end
			end
		},
		{ name= 'ACCOUNT', width = 100, defaultsort = "dsc", 
			DoCellUpdate = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					local cellData = data[realrow].cols[column]
					cellFrame.text:SetText(cellData.value)
					if NovaBookingHistory[index].IsSent == true then
						cellFrame.text:SetTextColor(0.5,0.5,0.5)
					else
						cellFrame.text:SetTextColor(1,1,1)
					end
				end
			end
		},
		{ name= 'CLIENT', width = 200, defaultsort = "dsc", 
			DoCellUpdate = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					local cellData = data[realrow].cols[column]
					
					cellFrame.text:SetText(cellData.value)
					
					
						cellFrame:HookScript("OnEnter", function()
							GameTooltip:SetOwner(cellFrame, "ANCHOR_TOP")
							if #NovaBookingHistory >= index then
								if NovaBookingHistory[index].CollectTrialAdvertiser ~= nil and NovaBookingHistory[index].CollectTrialAdvertiser ~= "" then
									GameTooltip:SetText(NovaBookingHistory[index].CollectTrialAdvertiser)
									GameTooltip:Show()
								end
							end
						end)
						cellFrame:HookScript("OnLeave", function()
							GameTooltip:Hide()
						end)
					
					
					if NovaBookingHistory[index].Faction == "Alliance" then
						if NovaBookingHistory[index].IsSent == true then
							cellFrame.text:SetTextColor(0,0.4,0.8)
						else
							cellFrame.text:SetTextColor(0,0.4,1)
						end
					elseif NovaBookingHistory[index].Faction == "Horde" then
						if NovaBookingHistory[index].IsSent == true then
							cellFrame.text:SetTextColor(0.5,0,0)
						else
							cellFrame.text:SetTextColor(1,0,0)
						end
					end
					
					
				end
			end
		},
		{ name= 'CLIENT TYPE', width = 100, defaultsort = "dsc", 
			DoCellUpdate = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					local cellData = data[realrow].cols[column]
					cellFrame.text:SetText(cellData.value)
					if NovaBookingHistory[index].IsSent == true then
						cellFrame.text:SetTextColor(0.5,0.5,0.5)
					else
						cellFrame.text:SetTextColor(1,1,1)
					end
				end
			end
		},
		{ name= 'BOOST', width = 80, defaultsort = "dsc", 
			DoCellUpdate = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					local cellData = data[realrow].cols[column]
					
					cellFrame.text:SetText(cellData.value)
					
					cellFrame:HookScript("OnEnter", function()
						GameTooltip:SetOwner(cellFrame, "ANCHOR_TOP")
						if #NovaBookingHistory >= index then
							if NovaBookingHistory[index].CollectBoostType ~= nil and NovaBookingHistory[index].CollectBoostType ~= "" then
								GameTooltip:SetText(NovaBookingHistory[index].CollectBoostType)
								GameTooltip:Show()
							end
						end
					end)
					cellFrame:HookScript("OnLeave", function()
						GameTooltip:Hide()
					end)
					
					if NovaBookingHistory[index].IsSent == true then
						cellFrame.text:SetTextColor(0.5,0.5,0.5)
					else
						cellFrame.text:SetTextColor(1,1,1)
					end
				end
			end
		},
		{ name= 'GOLD', width = 80, defaultsort = "dsc", align = "RIGHT",
			DoCellUpdate = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then 
					local index = data[realrow].cols[1].value
					local cellData = data[realrow].cols[column]
					
					if NovaBookingHistory[index].AdvertiserCutGold ~= nil and NovaBookingHistory[index].AdvertiserCutGold ~= "" and NovaBookingHistory[index].AdvertiserCut ~= nil and NovaBookingHistory[index].AdvertiserCut ~= "" and NovaBookingHistory[index].AdvertiserCutType ~= nil and NovaBookingHistory[index].AdvertiserCutType ~= "" then
						local advCut 
						if NovaBookingHistory[index].AdvertiserCutType == 1 then
							advCut = NovaBookingHistory[index].AdvertiserCut.."%: "..FormatMoneyTostring(NovaBookingHistory[index].AdvertiserCutGold)
						else
							advCut = NovaBookingHistory[index].AdvertiserCut.."g"
						end
					
						cellFrame:HookScript("OnEnter", function()
							GameTooltip:SetOwner(cellFrame, "ANCHOR_TOP")
							GameTooltip:SetText(advCut)
							GameTooltip:Show()
						end)
						cellFrame:HookScript("OnLeave", function()
							GameTooltip:Hide()
						end)
					end
					
					cellFrame.text:SetText(FormatMoneyTostring(cellData.value))
					
					if NovaBookingHistory[index].IsSent == true then
						cellFrame.text:SetTextColor(0.5,0.5,0.5)
					else
						cellFrame.text:SetTextColor(1,1,1)
					end
				end
			end
		},
		{ name= 'MAIL', width = 100, defaultsort = "dsc", align = "CENTER",
			DoCellUpdate  = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then 
					local index = data[realrow].cols[1].value
					--print(data[realrow].cols[1].value)

					local cellData = data[realrow].cols[column]
					if cellData.value == true then
						cellFrame.text:SetText('DONE')
						cellFrame.text:SetTextColor(0.5,0.5,0.5)
						
					else
						
						--local mailButton = _G["mailButton"..index] or CreateFrame("Button", "mailButton"..index, cellFrame, "UIPanelButtonTemplate")--"UIMenuButtonStretchTemplate") UIPanelButtonTemplate
						--mailButton:SetSize(70, 17)
						--mailButton:Show()
						--test:SetText("OPEN")
						--mailButton:SetPoint("CENTER",-1,0)
						--print("show "..mailButton:GetName())
						--local mailButtonTexture = cellFrame:CreateTexture(nil,"ARTWORK")
						--mailButtonTexture:SetTexture("Interface\\AddOns\\NovaBooking\\Media\\mail")
						--mailButtonTexture:SetPoint("CENTER")
						--mailButtonTexture:SetSize(25,10)
						
						--local mailButton = AceGUI:Create("Button")
						--mailButton:SetPoint("CENTER", cellFrame)
						--mailButton:SetText("OPEN")
						
						--mailButton:SetScript("OnClick", function()
							
						--mailButton:SetCallback("OnClick", function()
						
						cellFrame.text:SetTextColor(1,1,1)
						cellFrame.text:SetText('OPEN')
						
						cellFrame:SetScript("OnClick", function() 
							if isMailOpen == false then
								print("Go to the mailbox dumbass!")
							else
								if GetMoney() < NovaBookingHistory[index].Gold + 30 then
									StaticPopup_Show("NOVABOOKING_WARNING_NOTENOUGHGOLD")
								else
								
									local depotName = getDepotName()
									local realmName,_ = string.gsub(GetRealmName(), "%s+", "")
									local connectedRealms = GetAutoCompleteRealms()
									
									if depotName == nil or depotName == "" then
										StaticPopup_Show("NOVABOOKING_WARNING_NODEPOTFOUND", currentRealm)
									end
									
								
									local _,clientRealm = NovaBookingHistory[index].Client:match("([^\-]+)\-([^\-]+)")
									local boolRealmMail = false
									if clientRealm:lower() == realmName:lower() then
										boolRealmMail = true
									else
										for i=1, #connectedRealms do
											if clientRealm:lower() == connectedRealms[i]:lower() then
												boolRealmMail = true
												break
											end
											i = i + 1
										end
									end
									if boolRealmMail == false then
										local dialogWarning = StaticPopup_Show("NOVABOOKING_WARNING_WRONGSERVER", realmName, clientRealm)
										if (dialogWarning) then
											dialogWarning.data  = realmName
											dialogWarning.data2 = clientRealm
											dialogWarning.data3 = index
											dialogWarning.data4 = SendMailNameEditBox
											dialogWarning.data5 = SendMailSubjectEditBox
											dialogWarning.data6 = SendMailBodyEditBox
											dialogWarning.data7 = SendMailMoneyGold
											dialogWarning.data8 = depotName
										end
									else
										setMailContent(index, SendMailNameEditBox, SendMailSubjectEditBox, SendMailBodyEditBox, SendMailMoneyGold, depotName)
									end
								end
							end
						end)
					end
					
				end
			end
		},
		{ name= 'DISCORD', width = 100, defaultsort = "dsc", 
			DoCellUpdate = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					local cellData = data[realrow].cols[column]
					
					
					cellFrame.text:SetText(cellData.value)
					
					if NovaBookingHistory[index].IsSent == true then
						cellFrame.text:SetTextColor(0.5,0.5,0.5)
					else
						cellFrame.text:SetTextColor(1,1,1)
					end
					
					cellFrame:SetScript("OnClick", function() 
						if cellData.value ~= "" and cellData.value ~= " " and cellData.value ~= nil then
							StaticPopupDialogs["NOVABOOKING_DISCORDLINK"].urltext = cellData.value
							StaticPopup_Show("NOVABOOKING_DISCORDLINK", cellData.value)
						end
					end)
					
					
				end
			end
		},
		{ name= 'NOTES', width = 200, defaultsort = "dsc", 
			DoCellUpdate  = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					local cellData = data[realrow].cols[column]
					cellFrame.text:SetText(cellData.value)
				
					cellFrame:HookScript("OnEnter", function()
						GameTooltip:SetOwner(cellFrame, "ANCHOR_TOP")
						GameTooltip:SetText(cellData.value)
						GameTooltip:Show()
					end)
					cellFrame:HookScript("OnLeave", function()
						GameTooltip:Hide()
					end)
					
					if NovaBookingHistory[index].IsSent == true then
						cellFrame.text:SetTextColor(0.5,0.5,0.5)
					else
						cellFrame.text:SetTextColor(1,1,1)
					end
				end
			end
		},
		{ name= 'SPLIT', width = 34, defaultsort = "dsc", 
			DoCellUpdate  = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					cellFrame:SetNormalTexture('Interface\\AddOns\\NovaBooking\\Media\\duplicate')
					cellFrame:SetScript("OnClick", 
						function() 
							local dialogWarning = StaticPopup_Show("NOVABOOKING_SPLITENTRY", index)
							if (dialogWarning) then
								dialogWarning.data  = index
							end
						end)
				end
			end
		},
		{ name= 'EDIT', width = 30, defaultsort = "dsc", 
			DoCellUpdate  = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					cellFrame:SetNormalTexture('Interface\\AddOns\\NovaBooking\\Media\\Edit_icon')
					cellFrame:SetScript("OnClick", function() addEditClientToHistory(index) end)
					cellFrame:SetWidth(20)
				end
			end
		},
		{ name= 'DELETE', width = 43, defaultsort = "dsc", 
			DoCellUpdate  = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, self, ...)
				if fShow then
					local index = data[realrow].cols[1].value
					cellFrame:SetNormalTexture('Interface\\AddOns\\NovaBooking\\Media\\delete.tga')
					cellFrame:SetScript("OnClick", function() --DeleteItem(index)
						local dialog = StaticPopup_Show("NOVABOOKING_DELETE", index)
						if (dialog) then
							dialog.data  = index
						end
					end)
				end
			end
		},
		
	}
	
	local window  = f.frame
		
	boosthistoryST = ScrollingTable:CreateST(boostshistorycols, 22, 16, nil, window)
	boosthistoryST.frame:SetPoint("BOTTOMLEFT",window, 10,10)
	boosthistoryST.frame:SetPoint("TOP", window, 0, -100)
	boosthistoryST.frame:SetPoint("RIGHT", window, -10,0)	
	f.ScrollTable = boosthistoryST
	boosthistoryST.Fire=function(...)return true;end;
	boosthistoryST.userdata={}
	
	boosthistoryST.QuickFilterRule=""
	
	

	local width = 100
	for i, data in pairs(boostshistorycols) do 
		width = width + data.width
	end
	f:SetWidth(width);
	
	
	SendDataButton = CreateFrame("BUTTON", "syncButton", window, "UIMenuButtonStretchTemplate")
	SendDataButton:SetWidth(150)
	SendDataButton:SetHeight(35)
	SendDataButton:SetPoint("TOPRIGHT", -10, -10)
	SendDataButton:SetText("Share data with raid/party")

	SendDataButton:SetScript("OnClick", function(self)
		StaticPopup_Show("NOVABOOKING_SYNC_SEND")

	end)
	
	
	
	getAdvertiserCut()
	
	local goldGroup = AceGUI:Create("SimpleGroup")
	goldGroup:SetPoint("LEFT", f.frame, "LEFT", 0, 0)
	goldGroup:SetLayout("Flow")
	
	goldCollectedLabel = AceGUI:Create("Label")
	goldCollectedLabel:SetText("Gold Collected: "..FormatMoneyTostring(goldCollected))
	
	goldGroup:AddChild(goldCollectedLabel)
	
	local goldAdvertiserGroup = AceGUI:Create("SimpleGroup")
	
	goldCutAllianceLabel = AceGUI:Create("Label")
	goldCutAllianceLabel:SetText("[A] Cut:    "..FormatMoneyTostring(cutAlliance))
	goldCutAllianceLabel:SetColor(0,0.4,1)
	
	goldCutHordeLabel = AceGUI:Create("Label")
	goldCutHordeLabel:SetText("[H] Cut:    "..FormatMoneyTostring(cutHorde))
	goldCutHordeLabel:SetColor(1,0,0)
	
	goldCutTotalLabel = AceGUI:Create("Label")
	goldCutTotalLabel:SetText("Total Cut: "..FormatMoneyTostring(cutAlliance + cutHorde))
	
	goldAdvertiserGroup:AddChild(goldCutHordeLabel)
	goldAdvertiserGroup:AddChild(goldCutAllianceLabel)
	goldAdvertiserGroup:AddChild(goldCutTotalLabel)
	
	goldGroup:AddChild(goldAdvertiserGroup)
	
	f:AddChild(goldGroup)

	local openHistoryOnMailbox = AceGUI:Create("CheckBox")
	openHistoryOnMailbox:SetType("checkbox")
	openHistoryOnMailbox:SetLabel("Open on Mailbox")
	openHistoryOnMailbox:SetPoint("TOP", f.frame, "TOP", 220, -10)
	
	openHistoryOnMailbox:SetValue(novaOptions.General.OpenHistoryOnMailbox)
	
	openHistoryOnMailbox:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then 
			novaOptions.General.OpenHistoryOnMailbox = true
		else
			novaOptions.General.OpenHistoryOnMailbox = false
		end
	end )
	
	
	f:AddChild(openHistoryOnMailbox)
	
	
	setHistoryData()
end


-----------------------------------------------------------------------------------------------------
---------------------------------------------- ADD CLIENT -------------------------------------------
-----------------------------------------------------------------------------------------------------

local function addEditButton(row,acCheckboxInhouse,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acCheckboxClient,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acCheckboxNormal,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acCheckboxAlliance,acCheckboxHorde,acEditboxGold,acMultiEditboxDiscordLink,acMultiEditboxNotes,acEditboxName,acDropDownTypeValue,acCheckboxOpenHistory, acFrame,acEditboxTrialAdvertiser,acDropdownTypeForCollector)
	local acAdvType
	local acAdvCut
	if acCheckboxInhouse == true then
		acAdvCut = acEditboxAdvertiserCutsInhouse
		acAdvType = acEditboxAdvertiserCutsInhouseDropdown
	elseif acCheckboxClient == true then
		acAdvCut = acEditboxAdvertiserCutsClient
		acAdvType = acEditboxAdvertiserCutsClientDropdown
	elseif acCheckboxNormal == true then
		acAdvCut = acEditboxAdvertiserCutsNormal
		acAdvType = acEditboxAdvertiserCutsNormalDropdown
	end
	
	local acCheckboxTypeValue
	if acCheckboxNormal == true then
		acCheckboxTypeValue = "Normal"
	elseif acCheckboxClient == true then
		acCheckboxTypeValue = "Client"
	elseif acCheckboxInhouse == true then
		acCheckboxTypeValue = "Inhouse"
	end
	
	local acCheckboxFactionValue
	if acCheckboxAlliance == true then
		acCheckboxFactionValue = "Alliance"
	elseif acCheckboxHorde == true then
		acCheckboxFactionValue = "Horde"
	end
	
	--print("PRESSED")
	--print(#NovaBookingHistory+1)
	local acAdvCutGold
	if acAdvType == 1 then
		acAdvCutGold = acEditboxGold*10000 * acAdvCut / 100
	else
		acAdvCutGold = acEditboxGold*10000
	end
	
	local discord = acMultiEditboxDiscordLink
	local notes = acMultiEditboxNotes
	local client = acEditboxName
	--if notes == "" then notes = " " end
	if client == "" then client = " " end
	--if discord == "" then discord = " " end
	
	local collectBoostType = ""
	local collectTrialAdvertiser = ""
	if acDropDownTypeValue == "Collect" then
		collectBoostType = acDropdownTypeForCollector
		collectTrialAdvertiser = acEditboxTrialAdvertiser
	end
	
	
	tab = {
		["Valid"] = true,
		["Index"] = #NovaBookingHistory+1,
		["Gold"] = acEditboxGold*10000,
		["IsSent"] = false,
		["Timestamp"] = date("%d.%m.%y %H:%M"),
		["Client"] = client,
		["BoostType"] = acDropDownTypeValue,
		["ClientType"] = acCheckboxTypeValue,
		["Faction"] = acCheckboxFactionValue,
		["DiscordLink"] = discord,
		["Notes"] = notes,
		["ID"] = novaOptions.General.AccountID,
		["Accountname"] = novaOptions.General.Account,
		["LastChanged"] = date("%d.%m.%y %H:%M:%S"),
		["AdvertiserCut"] = tonumber(acAdvCut),
		["AdvertiserCutGold"] = tonumber(acAdvCutGold),
		["AdvertiserCutType"] = tonumber(acAdvType),
		["CollectBoostType"] = collectBoostType,
		["CollectTrialAdvertiser"] = collectTrialAdvertiser,
	}
	
	
	if row > 0 then
		NovaBookingHistory[row].Gold = acEditboxGold*10000
		NovaBookingHistory[row].Client = client
		NovaBookingHistory[row].BoostType = acDropDownTypeValue
		NovaBookingHistory[row].ClientType = acCheckboxTypeValue
		NovaBookingHistory[row].Faction = acCheckboxFactionValue
		NovaBookingHistory[row].DiscordLink = discord
		NovaBookingHistory[row].Notes = notes
		NovaBookingHistory[row].LastChanged = date("%d.%m.%y %H:%M:%S")
		NovaBookingHistory[row].AdvertiserCut = tonumber(acAdvCut)
		NovaBookingHistory[row].AdvertiserCutGold = tonumber(acAdvCutGold)
		NovaBookingHistory[row].AdvertiserCutType = tonumber(acAdvType)
		NovaBookingHistory[row].CollectBoostType = collectBoostType
		NovaBookingHistory[row].CollectTrialAdvertiser = collectTrialAdvertiser
	else
		tinsert(NovaBookingHistory, tab)
	end
	
	sortBookings()

	if acCheckboxOpenHistory == true and historyOpened == false then
		ShowHistory()
	else
		setHistoryData()
	end
	
	AceGUI:Release(acFrame)
	
	getAdvertiserCut()


end

local function setCuts(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES)
	
	local acCheckboxFactionValue
	if acCheckboxAlliance:GetValue() == true then
		acCheckboxFactionValue = "Alliance"
	elseif acCheckboxHorde:GetValue() == true then
		acCheckboxFactionValue = "Horde"
	end
	
	acEditboxAdvertiserCutsNormal:SetText(novaOptions.AdvertiserCuts[BOOST_TYPES[acDropdownType:GetValue()]]["Normal"][acCheckboxFactionValue])
	acEditboxAdvertiserCutsNormalDropdown:SetValue(novaOptions.AdvertiserCuts[BOOST_TYPES[acDropdownType:GetValue()]]["Normal"][acCheckboxFactionValue.."Type"])
	
	acEditboxAdvertiserCutsClient:SetText(novaOptions.AdvertiserCuts[BOOST_TYPES[acDropdownType:GetValue()]]["Client"][acCheckboxFactionValue])
	acEditboxAdvertiserCutsClientDropdown:SetValue(novaOptions.AdvertiserCuts[BOOST_TYPES[acDropdownType:GetValue()]]["Client"][acCheckboxFactionValue.."Type"])
	
	acEditboxAdvertiserCutsInhouse:SetText(novaOptions.AdvertiserCuts[BOOST_TYPES[acDropdownType:GetValue()]]["Inhouse"][acCheckboxFactionValue])
	acEditboxAdvertiserCutsInhouseDropdown:SetValue(novaOptions.AdvertiserCuts[BOOST_TYPES[acDropdownType:GetValue()]]["Inhouse"][acCheckboxFactionValue.."Type"])

end

local function createWidgetDropdown(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES,acGroupDropdownTypeSG,acGroupDropdownType,acFrame,value,row)
	local acDropdown = AceGUI:Create("Dropdown")
	acDropdown:SetWidth(220)
	acDropdown:SetList(BOOST_TYPES)
	acDropdown:SetLabel("Boost Type*")
	acDropdown:SetText(BOOST_TYPES[1])
	acDropdown:SetValue(1)
	acDropdown:SetCallback("OnValueChanged",function(widget,event,value)
		acDropdownTypeCallback(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES,acGroupDropdownTypeSG,acGroupDropdownType,acFrame,value,row)
	end)
	return acDropdown
end

local function createWidgetDropdown2(BOOST_TYPES)
	local acDropdown = AceGUI:Create("Dropdown")
	acDropdown:SetWidth(220)
	acDropdown:SetList(BOOST_TYPES)
	acDropdown:SetLabel("Boost Type*")
	acDropdown:SetText(BOOST_TYPES[1])
	acDropdown:SetValue(1)
	return acDropdown
end

local function createWidgetEditboxAdvertiserName()
	local acEditboxName = AceGUI:Create("EditBox")
	acEditboxName:SetWidth(220)
	acEditboxName:SetLabel("Trial Advertiser Name*")
	return acEditboxName
end

function acDropdownTypeCallback(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES,acGroupDropdownTypeSG,acGroupDropdownType,acFrame,value,row)

	setCuts(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES)

	if BOOST_TYPES[value] == "Collect" then
		acDropdownTypeForCollector = createWidgetDropdown2(BOOST_TYPES)
		acDropdownTypeForCollector:SetWidth(110)
		acDropdownType:SetWidth(110)
		acEditboxTrialAdvertiser = createWidgetEditboxAdvertiserName()
		acGroupDropdownTypeSG:AddChild(acDropdownTypeForCollector)
		acGroupDropdownType:AddChild(acEditboxTrialAdvertiser)
		acFrame:SetHeight(715)
		if row > 0 then
			for i=1, #BOOST_TYPES do
				if BOOST_TYPES[i] == NovaBookingHistory[row].CollectBoostType then
					acDropdownTypeForCollector:SetValue(i)
					break
				end
			end
			acEditboxTrialAdvertiser:SetText(NovaBookingHistory[row].CollectTrialAdvertiser)
			acDropdownTypeForCollector:SetText(NovaBookingHistory[row].CollectBoostType)
		end
	else
		acGroupDropdownType:ReleaseChildren()
		acGroupDropdownTypeSG = AceGUI:Create("SimpleGroup")
		acGroupDropdownTypeSG:SetLayout("Flow")
		acGroupDropdownType:AddChild(acGroupDropdownTypeSG)
		acDropdownType = createWidgetDropdown(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES,acGroupDropdownTypeSG,acGroupDropdownType,acFrame,value,row)
		acDropdownType:SetValue(value)
		acDropdownType:SetText(BOOST_TYPES[value])
		acGroupDropdownTypeSG:AddChild(acDropdownType)
		acFrame:SetHeight(670)
	end
end

function addEditClientToHistory(row)
	------------------------
	-- Add Client Main Frame
	local acFrame = AceGUI:Create("Frame")
	acFrame:SetWidth(350)
	acFrame:SetHeight(670)
	acFrame:SetTitle("Add Client")
	acFrame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	
	------------------------
	-- Client & Gold
	local acGroupNameGold = AceGUI:Create("InlineGroup")
	
	local acEditboxName = AceGUI:Create("EditBox")
	acEditboxName:SetText(tradePlayer)
	acEditboxName:SetWidth(200)
	acEditboxName:SetLabel("Client*")
	
	local acEditboxGold = AceGUI:Create("EditBox")
	acEditboxGold:SetText(tradeTargetMoney)
	acEditboxGold:SetWidth(200)
	acEditboxGold:SetLabel("Gold*")
	
	acGroupNameGold:AddChild(acEditboxName)
	acGroupNameGold:AddChild(acEditboxGold)
	
	------------------------
	-- Faction
	local alli = false
	local horde = false
	local englishFaction, _ = UnitFactionGroup("player")
	if englishFaction == "Alliance" then
		alli = true 
	elseif englishFaction == "Horde" then
		horde = true
	end
	
	local acGroupFaction = AceGUI:Create("InlineGroup")
	
	local acLabelFaction = AceGUI:Create("Label")
	acLabelFaction:SetText("Faction*")
	acLabelFaction:SetFont("GameFontNormalSmall",100,OUTLINE)
	acLabelFaction:SetColor(1, 0.8, 0)
	acLabelFaction:SetHeight(15)
	
	local acCheckboxAlliance = AceGUI:Create("CheckBox")
	acCheckboxAlliance:SetType("radio")
	acCheckboxAlliance:SetLabel("Alliance")
	acCheckboxAlliance:SetValue(alli)
	acCheckboxAlliance:SetHeight(15)
	acCheckboxAlliance:SetWidth(80)
	
	local acCheckboxHorde = AceGUI:Create("CheckBox")
	acCheckboxHorde:SetType("radio")
	acCheckboxHorde:SetLabel("Horde")
	acCheckboxHorde:SetValue(horde)
	acCheckboxHorde:SetHeight(15)
	acCheckboxHorde:SetWidth(80)
	

	
	------------------------
	-- Client Type (Normal, Client, Inhouse) & AdvertiserCuts
	local advertiserCutTypeValue = {[1] = "%", [2] = "g"}
	
	---Simple Group 0: Titels
	local acLabelGroup = AceGUI:Create("SimpleGroup")
	acLabelGroup:SetWidth(300)
	
	local acLabelCheckbox = AceGUI:Create("Label")
	acLabelCheckbox:SetText("Client Type")
	acLabelCheckbox:SetFont("GameFontNormalSmall",100,OUTLINE)
	acLabelCheckbox:SetColor(1, 0.8, 0)
	acLabelCheckbox:SetWidth(80)
	
	local acLabelAdvertiserCuts = AceGUI:Create("Label")
	acLabelAdvertiserCuts:SetText("Advertiser Cut")
	acLabelAdvertiserCuts:SetFont("GameFontNormalSmall",100,OUTLINE)
	acLabelAdvertiserCuts:SetColor(1, 0.8, 0)
	acLabelAdvertiserCuts:SetWidth(220)
	
	acLabelGroup:SetLayout("Flow")
	acLabelGroup:AddChild(acLabelCheckbox)
	acLabelGroup:AddChild(acLabelAdvertiserCuts)
	
	
	---Simple Group 1: Normal
	local acEditboxAdvertiserCutsNormalSG = AceGUI:Create("SimpleGroup")
	acEditboxAdvertiserCutsNormalSG:SetWidth(300)
	
	local acCheckboxNormal = AceGUI:Create("CheckBox")
	acCheckboxNormal:SetType("radio")
	acCheckboxNormal:SetLabel("Normal")
	acCheckboxNormal:SetValue(true)
	acCheckboxNormal:SetWidth(80)
	
	local acEditboxAdvertiserCutsNormal = AceGUI:Create("EditBox")
	acEditboxAdvertiserCutsNormal:SetWidth(80)
	
	local acEditboxAdvertiserCutsNormalDropdown = AceGUI:Create("Dropdown")
	acEditboxAdvertiserCutsNormalDropdown:SetWidth(50)
	acEditboxAdvertiserCutsNormalDropdown:SetList(advertiserCutTypeValue)
	acEditboxAdvertiserCutsNormalDropdown:SetText(advertiserCutTypeValue[1])
	acEditboxAdvertiserCutsNormalDropdown:SetValue(1)
	
	acEditboxAdvertiserCutsNormalSG:SetLayout("Flow")
	acEditboxAdvertiserCutsNormalSG:AddChild(acCheckboxNormal)
	acEditboxAdvertiserCutsNormalSG:AddChild(acEditboxAdvertiserCutsNormal)
	acEditboxAdvertiserCutsNormalSG:AddChild(acEditboxAdvertiserCutsNormalDropdown)
	
	
	
	---Simple Group 2: Client
	local acEditboxAdvertiserCutsClientSG = AceGUI:Create("SimpleGroup")
	acEditboxAdvertiserCutsClientSG:SetWidth(300)
	
	local acCheckboxClient = AceGUI:Create("CheckBox")
	acCheckboxClient:SetType("radio")
	acCheckboxClient:SetLabel("Client")
	acCheckboxClient:SetWidth(80)
	
	local acEditboxAdvertiserCutsClient = AceGUI:Create("EditBox")
	acEditboxAdvertiserCutsClient:SetWidth(80)
	
	local acEditboxAdvertiserCutsClientDropdown = AceGUI:Create("Dropdown")
	acEditboxAdvertiserCutsClientDropdown:SetWidth(50)
	acEditboxAdvertiserCutsClientDropdown:SetList(advertiserCutTypeValue)
	acEditboxAdvertiserCutsClientDropdown:SetText(advertiserCutTypeValue[1])
	acEditboxAdvertiserCutsClientDropdown:SetValue(1)
	
	acEditboxAdvertiserCutsClientSG:SetLayout("Flow")
	acEditboxAdvertiserCutsClientSG:AddChild(acCheckboxClient)
	acEditboxAdvertiserCutsClientSG:AddChild(acEditboxAdvertiserCutsClient)
	acEditboxAdvertiserCutsClientSG:AddChild(acEditboxAdvertiserCutsClientDropdown)
	
	
	
	---Simple Group 3: Inhouse
	local acEditboxAdvertiserCutsInhouseSG = AceGUI:Create("SimpleGroup")
	acEditboxAdvertiserCutsInhouseSG:SetWidth(300)
	
	local acCheckboxInhouse = AceGUI:Create("CheckBox")
	acCheckboxInhouse:SetType("radio")
	acCheckboxInhouse:SetLabel("Inhouse")
	acCheckboxInhouse:SetWidth(80)
	
	local acEditboxAdvertiserCutsInhouse = AceGUI:Create("EditBox")
	acEditboxAdvertiserCutsInhouse:SetWidth(80)
	
	local acEditboxAdvertiserCutsInhouseDropdown = AceGUI:Create("Dropdown")
	acEditboxAdvertiserCutsInhouseDropdown:SetWidth(50)
	acEditboxAdvertiserCutsInhouseDropdown:SetList(advertiserCutTypeValue)
	acEditboxAdvertiserCutsInhouseDropdown:SetText(advertiserCutTypeValue[1])
	acEditboxAdvertiserCutsInhouseDropdown:SetValue(1)
	
	acEditboxAdvertiserCutsInhouseSG:SetLayout("Flow")
	acEditboxAdvertiserCutsInhouseSG:AddChild(acCheckboxInhouse)
	acEditboxAdvertiserCutsInhouseSG:AddChild(acEditboxAdvertiserCutsInhouse)
	acEditboxAdvertiserCutsInhouseSG:AddChild(acEditboxAdvertiserCutsInhouseDropdown)
	
	
	
	local acGroupCheckbox = AceGUI:Create("InlineGroup")
	acGroupCheckbox:SetWidth(300)
	acGroupCheckbox:AddChild(acLabelGroup)
	acGroupCheckbox:AddChild(acEditboxAdvertiserCutsNormalSG)
	acGroupCheckbox:AddChild(acEditboxAdvertiserCutsClientSG)
	acGroupCheckbox:AddChild(acEditboxAdvertiserCutsInhouseSG)
	
	acCheckboxNormal:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then 
			acCheckboxClient:SetValue(false)
			acCheckboxInhouse:SetValue(false)
		end
		if value == false and acCheckboxInhouse:GetValue() == false and acCheckboxClient:GetValue() == false then
			acCheckboxNormal:SetValue(true)
		end
	end )
	acCheckboxClient:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then 
			acCheckboxNormal:SetValue(false)
			acCheckboxInhouse:SetValue(false)
		end
		if value == false and acCheckboxInhouse:GetValue() == false and acCheckboxNormal:GetValue() == false then
			acCheckboxClient:SetValue(true)
		end
	end )
	acCheckboxInhouse:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then 
			acCheckboxNormal:SetValue(false)
			acCheckboxClient:SetValue(false)
		end
		if value == false and acCheckboxClient:GetValue() == false and acCheckboxNormal:GetValue() == false then
			acCheckboxInhouse:SetValue(true)
		end
	end )

	------------------------
	-- Boost Type Dropdown
	BOOST_TYPES = {}
	for i,v in pairs(novaOptions.Boosts) do
		if v ~= "" then
			BOOST_TYPES[tonumber(i:match("[%d+]"))] = v
		end
	end

	local acGroupDropdownType = AceGUI:Create("InlineGroup")
	local acGroupDropdownTypeSG = AceGUI:Create("SimpleGroup")
	acGroupDropdownTypeSG:SetLayout("Flow")
	acGroupDropdownType:AddChild(acGroupDropdownTypeSG)
	
	
	local acDropdownType = createWidgetDropdown(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES,acGroupDropdownTypeSG,acGroupDropdownType,acFrame,value,row)
	acGroupDropdownTypeSG:AddChild(acDropdownType)
	
	setCuts(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES)
	
	acEditboxTrialAdvertiser = createWidgetEditboxAdvertiserName()
	acDropdownTypeForCollector = createWidgetDropdown2(BOOST_TYPES)
	
	acDropdownType:SetCallback("OnValueChanged",function(widget,event,value)
		acDropdownTypeCallback(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES,acGroupDropdownTypeSG,acGroupDropdownType,acFrame,value,row)
	
		--[[setCuts(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES)

		if BOOST_TYPES[value] == "Collect" then
			acDropdownTypeForCollector = createWidgetDropdown(BOOST_TYPES)
			acDropdownTypeForCollector:SetWidth(110)
			acDropdownType:SetWidth(110)
			acEditboxTrialAdvertiser = createWidgetEditboxAdvertiserName()
			acGroupDropdownTypeSG:AddChild(acDropdownTypeForCollector)
			acGroupDropdownType:AddChild(acEditboxTrialAdvertiser)
			acFrame:SetHeight(710)
		else
			acGroupDropdownType:ReleaseChildren()
			acGroupDropdownTypeSG = AceGUI:Create("SimpleGroup")
			acGroupDropdownType:AddChild(acGroupDropdownTypeSG)
			acDropdownType = createWidgetDropdown(BOOST_TYPES)
			acDropdownType:SetValue(value)
			acDropdownType:SetText(BOOST_TYPES[value])
			acGroupDropdownTypeSG:AddChild(acDropdownType)
			acFrame:SetHeight(670)
		end]]
	end )
	
	
	
	acCheckboxAlliance:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then
			acCheckboxHorde:SetValue(false)
			setCuts(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES)
		end
	end )
	
	acCheckboxHorde:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then
			acCheckboxAlliance:SetValue(false)
			setCuts(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES)
		end
	end )
	
	acGroupFaction:SetLayout("Flow")
	acGroupFaction:AddChild(acLabelFaction)
	acGroupFaction:AddChild(acCheckboxAlliance)
	acGroupFaction:AddChild(acCheckboxHorde)
	
	
	
	------------------------
	-- DiscordLink & Notes
	local acGroupEditboxNotes = AceGUI:Create("InlineGroup")
	
	local acMultiEditboxDiscordLink = AceGUI:Create("EditBox")
	acMultiEditboxDiscordLink:SetLabel("Discord Link")
	
	local acMultiEditboxNotes = AceGUI:Create("EditBox")
	acMultiEditboxNotes:SetLabel("Notes")
	
	acGroupEditboxNotes:AddChild(acMultiEditboxDiscordLink)
	acGroupEditboxNotes:AddChild(acMultiEditboxNotes)
	
	------------------------
	-- Open History Checkbox
	local acCheckboxOpenHistory = AceGUI:Create("CheckBox")
	acCheckboxOpenHistory:SetType("checkbox")
	acCheckboxOpenHistory:SetLabel("Open History")
	acCheckboxOpenHistory:SetValue(novaOptions.General.OpenHistoryAddClient)
	acCheckboxOpenHistory:SetWidth(110)
	
	acCheckboxOpenHistory:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then 
			novaOptions.General.OpenHistoryAddClient = true
		else
			novaOptions.General.OpenHistoryAddClient = false
		end
	end )
	
	------------------------
	-- Add Client Button
	local acButtonAdd = AceGUI:Create("Button")
	acButtonAdd:SetText("Add Client")
	acButtonAdd:SetWidth(180)
	acButtonAdd:SetCallback("OnClick", function()
		addEditButton(row,acCheckboxInhouse:GetValue(),acEditboxAdvertiserCutsInhouse:GetText(),acEditboxAdvertiserCutsInhouseDropdown:GetValue(),acCheckboxClient:GetValue(),acEditboxAdvertiserCutsClient:GetText(),acEditboxAdvertiserCutsClientDropdown:GetValue(),acCheckboxNormal:GetValue(),acEditboxAdvertiserCutsNormal:GetText(),acEditboxAdvertiserCutsNormalDropdown:GetValue(),acCheckboxAlliance:GetValue(),acCheckboxHorde:GetValue(),acEditboxGold:GetText(),acMultiEditboxDiscordLink:GetText(),acMultiEditboxNotes:GetText(),acEditboxName:GetText(),BOOST_TYPES[acDropdownType:GetValue()],acCheckboxOpenHistory:GetValue(),acFrame,acEditboxTrialAdvertiser:GetText(),BOOST_TYPES[acDropdownTypeForCollector:GetValue()])
	end)
	
	local acGroupButtonAdd = AceGUI:Create("SimpleGroup")
	acGroupButtonAdd:AddChild(acButtonAdd)
	acGroupButtonAdd:AddChild(acCheckboxOpenHistory)
	acGroupButtonAdd:SetLayout("Flow")

	
	acFrame:AddChild(acGroupNameGold)
	acFrame:AddChild(acGroupFaction)
	acFrame:AddChild(acGroupDropdownType)
	acFrame:AddChild(acGroupCheckbox)
	acFrame:AddChild(acGroupEditboxNotes)
	acFrame:AddChild(acGroupButtonAdd)
	
	-- EDIT ROW
	if row > 0 then
		acFrame:SetTitle("Edit Client")
		
		acEditboxName:SetText(NovaBookingHistory[row].Client)
		acEditboxGold:SetText(NovaBookingHistory[row].Gold/10000)
		if NovaBookingHistory[row].Faction == "Alliance" then
			acCheckboxAlliance:SetValue(true)
			acCheckboxHorde:SetValue(false)
		elseif NovaBookingHistory[row].Faction == "Horde" then
			acCheckboxAlliance:SetValue(false)
			acCheckboxHorde:SetValue(true)
		end
		acDropdownType:SetText(NovaBookingHistory[row].BoostType)
		for i=1, #BOOST_TYPES do
			if BOOST_TYPES[i] == NovaBookingHistory[row].BoostType then
				acDropdownType:SetValue(i)
				break
			end
		end
		
		if NovaBookingHistory[row].ClientType == "Inhouse" then
			acCheckboxInhouse:SetValue(true)
			acCheckboxNormal:SetValue(false)
			acCheckboxClient:SetValue(false)
			acEditboxAdvertiserCutsInhouse:SetText(NovaBookingHistory[row].AdvertiserCut)
			acEditboxAdvertiserCutsInhouseDropdown:SetValue(NovaBookingHistory[row].AdvertiserCutType)
			acEditboxAdvertiserCutsInhouseDropdown:SetText(advertiserCutTypeValue[NovaBookingHistory[row].AdvertiserCutType])
		elseif NovaBookingHistory[row].ClientType == "Client" then
			acCheckboxInhouse:SetValue(false)
			acCheckboxNormal:SetValue(false)
			acCheckboxClient:SetValue(true)
			acEditboxAdvertiserCutsClient:SetText(NovaBookingHistory[row].AdvertiserCut)
			acEditboxAdvertiserCutsClientDropdown:SetValue(NovaBookingHistory[row].AdvertiserCutType)
			acEditboxAdvertiserCutsClientDropdown:SetText(advertiserCutTypeValue[NovaBookingHistory[row].AdvertiserCutType])
		elseif NovaBookingHistory[row].ClientType == "Normal" then
			acCheckboxInhouse:SetValue(false)
			acCheckboxNormal:SetValue(true)
			acCheckboxClient:SetValue(false)
			acEditboxAdvertiserCutsNormal:SetText(NovaBookingHistory[row].AdvertiserCut)
			acEditboxAdvertiserCutsNormalDropdown:SetValue(NovaBookingHistory[row].AdvertiserCutType)
			acEditboxAdvertiserCutsNormalDropdown:SetText(advertiserCutTypeValue[NovaBookingHistory[row].AdvertiserCutType])
		end
		acMultiEditboxDiscordLink:SetText(NovaBookingHistory[row].DiscordLink)
		acMultiEditboxNotes:SetText(NovaBookingHistory[row].Notes)
		
		-- OPEN/DONE Checkbox
		local acCheckboxOpenDone= AceGUI:Create("CheckBox")
		acCheckboxOpenDone:SetType("checkbox")
		acCheckboxOpenDone:SetLabel("Done")
		acCheckboxOpenDone:SetValue(NovaBookingHistory[row].IsSent)
		acCheckboxOpenDone:SetWidth(110)
		
		acCheckboxOpenDone:SetCallback("OnValueChanged",function(widget,event,value)
			if value == true then 
				NovaBookingHistory[row].IsSent = true
			else
				NovaBookingHistory[row].IsSent = false
			end
		end )
		acFrame:AddChild(acCheckboxOpenDone)
		
		--EDIT Button
		acButtonAdd:SetText("Edit Client")
		
		
		if NovaBookingHistory[row].BoostType == "Collect" then
			acDropdownTypeCallback(acCheckboxAlliance,acCheckboxHorde,acEditboxAdvertiserCutsNormal,acEditboxAdvertiserCutsNormalDropdown,acEditboxAdvertiserCutsClient,acEditboxAdvertiserCutsClientDropdown,acEditboxAdvertiserCutsInhouse,acEditboxAdvertiserCutsInhouseDropdown,acDropdownType,BOOST_TYPES,acGroupDropdownTypeSG,acGroupDropdownType,acFrame,acDropdownType:GetValue(),row)
		end
	end
	
end


-----------------------------------------------------------------------------------------------------
---------------------------------------------- MAILING ----------------------------------------------
-----------------------------------------------------------------------------------------------------

function nova:MAIL_SHOW(event, ...)
	--print("--MAIL_SHOW")
	isMailOpen = true
	if historyOpened == false and novaOptions.General.OpenHistoryOnMailbox == true then
		ShowHistory()
	end
	
	if novaOptions.Mailing.CheckBoxShowScreenshotButton == false then
		ScreenshotsAndSendButton:Hide()
	else
		ScreenshotsAndSendButton:Show()
	end
	
	ScreenshotsAndSendButton:SetSize(130, 40)
	ScreenshotsAndSendButton:SetPoint("BOTTOM", "SendMailFrame", "BOTTOMRIGHT", -95, 45)
	ScreenshotsAndSendButton:SetText("Open History Page")
	--ScreenshotsAndSendButton:RegisterForClicks("AnyUp")

	ScreenshotsAndSendButton:SetScript("OnClick", function(self)
		if historyOpened == false then
			ShowHistory()
		end
	end)
end


function nova:MAIL_CLOSED(event, ...)
	--print("--MAIL_CLOSED")
	isMailOpen = false
	MailLastClicked = 0
end

function nova:MAIL_SEND_SUCCESS(event, ...)
	--print("--MAIL_SEND_SUCCESS")
	if MailLastClicked ~= 0 then
		NovaBookingHistory[MailLastClicked].IsSent = true
		NovaBookingHistory[MailLastClicked].LastChanged = date("%d.%m.%y %H:%M:%S")
		setHistoryData()
	end
end



local waitTable = {};
local waitFrame = nil;

function Nova__wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end


function Nova_takeScreenshot()
	Screenshot()
end

-----------------------------------------------------------------------------------------------------
---------------------------------------------- TRADING ----------------------------------------------
-----------------------------------------------------------------------------------------------------

TBT_CURRENT_TRADE = nil;

local function curr()
	if(not TBT_CURRENT_TRADE) then
		TBT_CURRENT_TRADE = CreateNewTrade();
	end
	return TBT_CURRENT_TRADE;
end

function CreateNewTrade() 
	local trade = {
		targetMoney = 0,
		result = nil
	}
	return trade
end

function NovaBookingTrade_OnLoad(self)
	self:RegisterEvent("TRADE_SHOW")
	self:RegisterEvent("TRADE_MONEY_CHANGED")
	self:RegisterEvent("TRADE_ACCEPT_UPDATE")
	self:RegisterEvent("UI_INFO_MESSAGE")
end

function NovaBookingTrade_OnEvent(self, event, arg1, arg2, ...)
	if (event=="UI_INFO_MESSAGE" and ( arg2==ERR_TRADE_CANCELLED or arg2==ERR_TRADE_COMPLETE) ) then
		curr().result = (arg2==ERR_TRADE_CANCELLED) and "cancelled" or "complete"
		if(curr().result == "complete") then
			--print(curr().targetMoney)
			if curr().targetMoney > 0 then
				tradeTargetMoney = curr().targetMoney/10000
				addEditClientToHistory(0)
			end
		end
		TBT_CURRENT_TRADE = nil;

	elseif (event=="TRADE_MONEY_CHANGED") then
		--print("--TRADE_MONEY_CHANGED")
		UpdateMoney();
	
	elseif (event=="TRADE_ACCEPT_UPDATE") then
		--print("--TRADE_ACCEPT_UPDATE")
		UpdateMoney()
	end

	if (event=="TRADE_SHOW") then
		--print("--TRADE_SHOW")
		tradePlayer = GetUnitName("NPC", true)
		if string.match(tradePlayer, '-') then
			tradePlayer = tradePlayer
		else
			local realmName,_ = string.gsub(GetRealmName(), "%s+", "")
			tradePlayer = tradePlayer.."-"..realmName
		end
	end
end

function UpdateMoney()
	curr().targetMoney = GetTargetTradeMoney()
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", NovaBookingTrade_OnEvent)
NovaBookingTrade_OnLoad(frame)

-----------------------------------------------------------------------------------------------------
---------------------------------------------- SYNCING ----------------------------------------------
-----------------------------------------------------------------------------------------------------

function SyncSendData(i)
	--print("Sending Message "..i)
	
	--Load the libraries
	local libC = LibStub:GetLibrary("LibCompress")
	local libCE = libC:GetAddonEncodeTable()
	
	--Serialize and compress the data
	local data = NovaBookingHistory[i]
	local one = nova:Serialize(data)
	local two = libC:CompressHuffman(one)
	local message = libCE:Encode(two)
	
	--Send it via an addon message
	nova:SendCommMessage("NovaBooking", message, "RAID", "CHANNEL", "BULK")
	--print("Sending Message "..i.." DONE")
end

function SyncStoreData(message)
	--Load the libraries
	local libC = LibStub:GetLibrary("LibCompress")
	local libCE = libC:GetAddonEncodeTable()
	
	-- Decode the compressed data
	local one = libCE:Decode(message)
	
	--Decompress the decoded data
	local two, message = libC:Decompress(one)
	if(not two) then
		print("NovaBooking: error decompressing: " .. message)
		return
	end
	
	-- Deserialize the decompressed data
	local success, receivedMessage = nova:Deserialize(two)
	if (not success) then
		print("NovaBooking: error deserializing " .. receivedMessage)
		return
	end
	
	local foundData = false
	for i,k in pairs(NovaBookingHistory) do
		if k.ID == receivedMessage.ID and k.Timestamp == receivedMessage.Timestamp and k.Client == receivedMessage.Client then
			foundData = true
			
			if getTimestamp(k.LastChanged) < getTimestamp(receivedMessage.LastChanged) then
				k.IsSent = receivedMessage.IsSent
				k.ClientType = receivedMessage.ClientType
				k.BoostType = receivedMessage.BoostType
				k.Gold = receivedMessage.Gold
				k.Notes = receivedMessage.Notes
				k.Accountname = receivedMessage.Accountname
				k.LastChanged = receivedMessage.LastChanged
				k.Faction = receivedMessage.Faction
				k.AdvertiserCut = receivedMessage.AdvertiserCut
				k.AdvertiserCutGold = receivedMessage.AdvertiserCutGold
				k.AdvertiserCutType = receivedMessage.AdvertiserCutType
				k.DiscordLink = receivedMessage.DiscordLink
				k.CollectTrialAdvertiser = receivedMessage.CollectTrialAdvertiser
				k.CollectBoostType = receivedMessage.CollectBoostType
				
				SyncedRowsChanged = SyncedRowsChanged + 1
				
				if boosthistoryST ~= nil then
					setHistoryData()
				end
			end
		end
	end
	
	if not foundData then
		local new = {
			["Valid"] = true,
			["Index"] = #NovaBookingHistory+1,
			["Gold"] = receivedMessage.Gold,
			["IsSent"] = receivedMessage.IsSent,
			["Timestamp"] = receivedMessage.Timestamp,
			["Client"] = receivedMessage.Client,
			["BoostType"] = receivedMessage.BoostType,
			["ClientType"] = receivedMessage.ClientType,
			["Faction"] = receivedMessage.Faction,
			["DiscordLink"] = receivedMessage.DiscordLink,
			["Notes"] = receivedMessage.Notes,
			["ID"] = receivedMessage.ID,
			["Accountname"] = receivedMessage.Accountname,
			["LastChanged"] = receivedMessage.LastChanged,
			["AdvertiserCut"] = receivedMessage.AdvertiserCut,
			["AdvertiserCutGold"] = receivedMessage.AdvertiserCutGold,
			["AdvertiserCutType"] = receivedMessage.AdvertiserCutType,
			["CollectTrialAdvertiser"] = receivedMessage.CollectTrialAdvertiser,
			["CollectBoostType"] = receivedMessage.CollectBoostType,
		}
		
		tinsert(NovaBookingHistory, new)
		
		SyncedRowsAdded = SyncedRowsAdded + 1
		
		sortBookings()

		if boosthistoryST ~= nil then
			setHistoryData()
		end
	end
	
end

function nova:OnCommReceived(prefix, message, distribution, sender)
	if sender ~= GetUnitName("player") and prefix == "NovaBooking" then
		
		if message == "START" then
			SYNC_DATA = {}
		elseif message == "END" then
			local count = 0
			for _ in pairs(SYNC_DATA) do count = count + 1 end
			StaticPopupDialogs["NOVABOOKING_SYNC_RECEIVE"].text = sender.." is sending you "..count.." rows. Do you want to import the data?"
			StaticPopup_Show("NOVABOOKING_SYNC_RECEIVE", sender)
			SyncedRowsChanged = 0
			SyncedRowsAdded = 0
		else
			tinsert(SYNC_DATA, message)
		end
	end
end



function mysplit (inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function getTimestamp(s)
	local p="(%d+).(%d+).(%d+) (%d+):(%d+):(%d+)"
	local days,months,years,hours,mins,secs=s:match(p)
	years = "20"..years
	return time({day=days,month=months,year=years,hour=hours,min=mins,sec=secs})
end

function sortBookings()
	-- Bubble sort 
	local n=#NovaBookingHistory
	local swapped = false
	repeat 
		swapped = false
		for i= 2,n do 
			if getTimestamp(NovaBookingHistory[i-1].Timestamp..":00") > getTimestamp(NovaBookingHistory[i].Timestamp..":00") then 
				NovaBookingHistory[i-1],NovaBookingHistory[i] = NovaBookingHistory[i], NovaBookingHistory[i-1]
				NovaBookingHistory[i-1].Index,NovaBookingHistory[i].Index = i-1, i
				swapped = true
			end 
		end 
	until not swapped
end




-----------------------------------------------------------------------------------------------------
---------------------------------------------- EVENTS ----------------------------------------------
-----------------------------------------------------------------------------------------------------



local regEvents = {
	"ADDON_LOADED",
	"MAIL_SHOW",
	"MAIL_CLOSED",
	"MAIL_SEND_SUCCESS",
}

function nova:OnInitialize()
    --print "---NovaBoosting init"
    self:RegisterChatCommand("NovaBooking", "MySlashProcessorFunc")
	self:RegisterChatCommand("nb", "MySlashProcessorFunc")
	
	for i, event in pairs (regEvents) do
		--print(event)
		self:RegisterEvent(event)
		--print "---NovaBoosting End";
	end
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable(title, myOptionsTable)
  	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(title, title)
	
	LoadAddOn("LibCompress")
	
	nova:RegisterComm("NovaBooking")
end



local addon_initialized=false

function nova:ADDON_LOADED(event, ...)
	--print "--ADDON_LOADED"
    if not addon_initialized then
		addon_initialized = true
		--print "--ADDON_LOADED initialized"

		if NovaBookingHistory == nil then
			NovaBookingHistory = {}
		end
		NovaBookingHistoryAvailable = true
		
		if NovaBookingHistory.Serialized then
			local result
			result,NovaBookingHistory = nova:Deserialize(NovaBookingHistory.Serialized)
		end
		
		------------------
		--- Check Version
		------------------
		--[[if novaOptions.General.Version == 1 then
			for i,v in pairs(NovaBookingHistory) do
				if v.ID == nil then v.ID = novaOptions.General.AccountID end
				if v.Accountname == nil then v.Accountname = novaOptions.General.Account end
				if v.LastChanged == nil then v.LastChanged = date("%d.%m.%y %H:%M:%S") end
				if v.Notes == "" then v.Notes = " " end
				if v.Client == "" then v.Client = " " end
			end
			novaOptions.General.Version = 2
		end
		
		
		
		if novaOptions.General.Version == 2 then
			if novaOptions.General.OpenHistoryOnMailbox == nil then novaOptions.General.OpenHistoryOnMailbox = myDefaultOptions.General.OpenHistoryOnMailbox end
			if novaOptions.AdvertiserCuts == nil then novaOptions.AdvertiserCuts = myDefaultOptions.AdvertiserCuts end
			
			for i,v in pairs(NovaBookingHistory) do
				if v.AdvertiserCut == nil then v.AdvertiserCut = tonumber(novaOptions.AdvertiserCuts[v.BoostType][v.ClientType][v.Faction]) end
				if v.AdvertiserCutGold == nil then v.AdvertiserCutGold = v.Gold * v.AdvertiserCut / 100 end
				if v.AdvertiserCutType == nil then v.AdvertiserCutType = tonumber(novaOptions.AdvertiserCuts[v.BoostType][v.ClientType][v.Faction.."Type"]) end
				v.LastChanged = date("%d.%m.%y %H:%M:%S")
			end
			
			novaOptions.General.Version = 3
		end
		
		if novaOptions.General.Version == 4 then
			for i,v in pairs(NovaBookingHistory) do
				if v.DiscordLink == nil then v.DiscordLink = "" end
			end
		end
		
		novaOptions.General.Version = 5]]
		------------------
		--- Set Options
		------------------
		if novaOptions.General == nil then
			novaOptions.General = myDefaultOptions.General 
		else
			if novaOptions.General.Account == nil then novaOptions.General.Account = myDefaultOptions.General.Account end
			if novaOptions.General.OpenHistoryAddClient == nil then novaOptions.General.OpenHistoryAddClient = myDefaultOptions.General.OpenHistoryAddClient end
			if novaOptions.General.OpenHistoryOnMailbox == nil then novaOptions.General.OpenHistoryOnMailbox = myDefaultOptions.General.OpenHistoryOnMailbox end
			if novaOptions.General.Version == nil then novaOptions.General.Version = myDefaultOptions.General.Version end
		end
		
		if novaOptions.General.AccountID == nil then
			novaOptions.General.AccountID = UnitGUID("player")
		end
		
		if novaOptions.Mailing == nil then
			novaOptions.Mailing = myDefaultOptions.Mailing 
		else
			if novaOptions.Mailing.InputAdvertiser == nil then novaOptions.Mailing.InputAdvertiser = myDefaultOptions.Mailing.InputAdvertiser end
			if novaOptions.Mailing.InputSubjectPrefix == nil then novaOptions.Mailing.InputSubjectPrefix = myDefaultOptions.Mailing.InputSubjectPrefix end
			if novaOptions.Mailing.CheckBoxShowScreenshotButton == nil then novaOptions.Mailing.CheckBoxShowScreenshotButton = myDefaultOptions.Mailing.CheckBoxShowScreenshotButton end
		end
		
		if novaOptions.Boosts == nil then
			novaOptions.Boosts = myDefaultOptions.Boosts 
		else
			if myDefaultOptions.Boosts.InputBoostTyp1 ~= nil then  if novaOptions.Boosts.InputBoostTyp1 == nil then novaOptions.Boosts.InputBoostTyp1 = myDefaultOptions.Boosts.InputBoostTyp1 end end
			if myDefaultOptions.Boosts.InputBoostTyp2 ~= nil then if novaOptions.Boosts.InputBoostTyp2 == nil then novaOptions.Boosts.InputBoostTyp2 = myDefaultOptions.Boosts.InputBoostTyp2 end end
			if myDefaultOptions.Boosts.InputBoostTyp3 ~= nil then if novaOptions.Boosts.InputBoostTyp3 == nil then novaOptions.Boosts.InputBoostTyp3 = myDefaultOptions.Boosts.InputBoostTyp3 end end
			if myDefaultOptions.Boosts.InputBoostTyp4 ~= nil then if novaOptions.Boosts.InputBoostTyp4 == nil then novaOptions.Boosts.InputBoostTyp4 = myDefaultOptions.Boosts.InputBoostTyp4 end end
			if myDefaultOptions.Boosts.InputBoostTyp5 ~= nil then if novaOptions.Boosts.InputBoostTyp5 == nil then novaOptions.Boosts.InputBoostTyp5 = myDefaultOptions.Boosts.InputBoostTyp5 end end
			if myDefaultOptions.Boosts.InputBoostTyp6 ~= nil then if novaOptions.Boosts.InputBoostTyp6 == nil then novaOptions.Boosts.InputBoostTyp6 = myDefaultOptions.Boosts.InputBoostTyp6 end end
			if myDefaultOptions.Boosts.InputBoostTyp7 ~= nil then if novaOptions.Boosts.InputBoostTyp7 == nil then novaOptions.Boosts.InputBoostTyp7 = myDefaultOptions.Boosts.InputBoostTyp7 end end
			if myDefaultOptions.Boosts.InputBoostTyp8 ~= nil then if novaOptions.Boosts.InputBoostTyp8 == nil then novaOptions.Boosts.InputBoostTyp8 = myDefaultOptions.Boosts.InputBoostTyp8 end end
			if myDefaultOptions.Boosts.InputBoostTyp9 ~= nil then if novaOptions.Boosts.InputBoostTyp9 == nil then novaOptions.Boosts.InputBoostTyp9 = myDefaultOptions.Boosts.InputBoostTyp9 end end
			if myDefaultOptions.Boosts.InputBoostTyp10 ~= nil then if novaOptions.Boosts.InputBoostTyp10 == nil then novaOptions.Boosts.InputBoostTyp10 = myDefaultOptions.Boosts.InputBoostTyp10 end end
		end
		
		if novaOptions.Banking == nil then
			novaOptions.Banking = myDefaultOptions.Banking
		end
		
		BuildAdvertiserCutsOptionArgs(myOptionsTable.args.AdvertiserCuts.args, novaOptions.Boosts)
		BuildBankingOptionsArgs(myOptionsTable.args.Banking.args, novaOptions.Banking)
		
		
		if novaOptions.AdvertiserCuts == nil then 
			novaOptions.AdvertiserCuts = myDefaultOptions.AdvertiserCuts 
		end
		
		sortBookings()
		
		ScreenshotsAndSendButton = CreateFrame("Button", "ScreenshotsAndSendButton", SendMailFrame, "UIPanelButtonTemplate")
		
		StaticPopupDialogs["NOVABOOKING_DELETE"] = {
			text = "Are you sure you want to delete entry #%s?",
			button1 = "Yes",
			button2 = "No",
			OnAccept = function(self)
				DeleteItem(self.data)
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopupDialogs["NOVABOOKING_WARNING_WRONGSERVER"] = {
			text = "You try to send gold from the wrong realm! You are on %s and you got gold from client on %s!\nAre you sure you want to send gold from this realm?",
			button1 = "Yes",
			button2 = "No",
			OnAccept = function(self)
				setMailContent(self.data3, self.data4, self.data5, self.data6, self.data7, self.data8)
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopupDialogs["NOVABOOKING_WARNING_NODEPOTFOUND"] = {
			text = "Couldn't find the banking character for the realm %s. Please check Interface -> NovaBooking -> Banking Characters.",
			button1 = ACCEPT,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopupDialogs["NOVABOOKING_WARNING_NOTENOUGHGOLD"] = {
			text = "You do not have enough gold on your character!",
			button1 = ACCEPT,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopupDialogs["NOVABOOKING_SPLITENTRY"] = {
			text = "How often should entry #%s be splited into?",
			button1 = "Split",
			button2 = "Cancel",
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			OnAccept = function(self)
				someVar = self.editBox:GetText()
				splitEntry(someVar, self.data)
			end,
			hasEditBox = 1
		}
		StaticPopupDialogs["NOVABOOKING_DISCORDLINK"] = StaticPopupDialogs["NOVABOOKING_DISCORDLINK"] or {
        text = "URL: %s",
        button2 = ACCEPT,
        hasEditBox = 1,
        hasWideEditBox = 1,
        editBoxWidth = 350,
        preferredIndex = 3,
        OnShow = function(this, ...)
          this:SetWidth(420)

          local editBox = _G[this:GetName() .. "WideEditBox"] or _G[this:GetName() .. "EditBox"]

          editBox:SetText(StaticPopupDialogs["NOVABOOKING_DISCORDLINK"].urltext)
          editBox:SetFocus()
          editBox:HighlightText(false)

          local button = _G[this:GetName() .. "Button2"]
          button:ClearAllPoints()
          button:SetWidth(200)
          button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
        end,
        OnHide = NOP,
        OnAccept = NOP,
        OnCancel = NOP,
        EditBoxOnEscapePressed = function(this, ...) this:GetParent():Hide() end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1
      }
	  StaticPopupDialogs["NOVABOOKING_SYNC_RECEIVE"] = {
		text = "%s is sending you NovaBooking data.",
		button1 = ACCEPT,
		button2 = CANCEL,
		OnAccept = function()
			for _,v in pairs(SYNC_DATA) do
				SyncStoreData(v)
			end
			print("Added "..SyncedRowsAdded.." new row(s)")
			print("Modified "..SyncedRowsChanged.." row(s)")
		end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
		preferredIndex = 3,
      }
	  StaticPopupDialogs["NOVABOOKING_SYNC_SEND"] = {
		text = "Blizzard is only allowing to share ~5 messages. Please fill out the id of the runs you want to share: ",
		button1 = "Send data",
		button2 = CANCEL,
		OnShow = function(this, ...)
          this:SetWidth(420)

          local editBox = _G[this:GetName() .. "EditBox"]

          editBox:SetText("1-10")
          editBox:SetFocus()
          editBox:HighlightText(false)
        end,
		OnAccept = function(this, ...)
			if IsInGroup() or IsInRaid() then
				--print("in a group")

				local editBox = _G[this:GetName() .. "EditBox"]
				if editBox:GetText() ~= nil and editBox:GetText() ~= "" and string.len(editBox:GetText()) >= 3 and string.find(editBox:GetText(), '%-') then
					local textSplit = mysplit(editBox:GetText(), "-")

					if tonumber(textSplit[2]) >= tonumber(textSplit[1]) and textSplit[2] ~= "" and textSplit[2] ~= nil and textSplit[1] ~= "" and textSplit[1] ~= nil and tonumber(textSplit[2]) <= #NovaBookingHistory and tonumber(textSplit[1]) <= #NovaBookingHistory then
						print("Sending Data...")
						nova:SendCommMessage("NovaBooking", "START", "RAID", "CHANNEL")
					
						for i = textSplit[2], textSplit[1], -1 do
							--print("Send data... "..i)
							SyncSendData(i)
						end
						
						nova:SendCommMessage("NovaBooking", "END", "RAID", "CHANNEL")
						print("Sending Data... DONE!")
					else
						print("Error: please give a range of ids from your history e.g. 1-10 or 5-20")
					end
				else
					print("Error: please give a range of ids from your history e.g. 1-10 or 6-20")
				end
			else
				print("You have to be in a raid/party")
			end
		end,
		hasEditBox = 2,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
		preferredIndex = 3,
      }
	end
end



----------------------------------------------
function nova:MySlashProcessorFunc(input)	--
----------------------------------------------
	if historyOpened == false and strlower(input)=="" then
		ShowHistory()
	end
	if strlower(input)=="add" then
		addEditClientToHistory(0)
	end
end


