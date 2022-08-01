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
				Profiles = {
					type = 'group',
					name = 'Active Profile',
					inline = true,
					args = {
						Profile_A = {
							type = 'toggle',
							name = 'Profile A',
							order = 1,
							get = 'GetOption',
							set = 'SetOption',
						},
						Profile_B = {
							type = 'toggle',
							name = 'Profile B',
							order = 2,
							get = 'GetOption',
							set = 'SetOption',
						},
					},
				},
			},
		},
	}
}


local myDefaultOptions = {
	["General"] = {
		["Account"] = "",
		["OpenHistoryAddClient"] = true,
		["OpenHistoryOnMailbox"] = true,
		["Version"] = 6
	},
	["Mailing"] = {
		["InputSubjectPrefix"] = "NBC",
		["CheckBoxShowScreenshotButton"] = false
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
				["Horde"] = "25",
				["Alliance"] = "25",
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
				["Horde"] = "20",
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
				["Horde"] = "30",
				["Alliance"] = "30",
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
				["Horde"] = "25",
				["Alliance"] = "25",
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
		["Legacy"] = {
			["Normal"] = {
				["Horde"] = "20",
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
				["Horde"] = "30",
				["Alliance"] = "30",
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
				["Horde"] = "30",
				["Alliance"] = "30",
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
		["Profiles"] = {
			["Profile_A"] = true,
			["Profile_B"] = false,
		},
		["Profile B"] = {
			["German"] = {
				["Wrathbringer"] = {
					["Horde"] = "Pothorde-Tirion",
					["Alliance"] = "Potalliance-Tirion",
				},
				["Mannoroth"] = {
					["Horde"] = "Pothorde-Gorgonnash",
					["Alliance"] = "Potalliance-Gorgonnash",
				},
				["Tichondrius"] = {
					["Horde"] = "Pothorde-Blackmoore",
					["Alliance"] = "Potalliance-Blackmoore",
				},
				["Theradras"] = {
					["Horde"] = "Pothorde-Onyxia",
					["Alliance"] = "Potalliance-Onyxia",
				},
				["Alexstrasza"] = {
					["Horde"] = "Pothorde-Alexstrasza",
					["Alliance"] = "Potalliance-Alexstrasza",
				},
				["Die ewige Wacht"] = {
					["Horde"] = "Pothorde-Diesilbernehand",
					["Alliance"] = "Potalliance-Diesilbernehand",
				},
				["Lothar"] = {
					["Horde"] = "Pothorde-Lothar",
					["Alliance"] = "Potalliance-Lothar",
				},
				["Mug'thol"] = {
					["Horde"] = "Pothorde-Onyxia",
					["Alliance"] = "Potalliance-Onyxia",
				},
				["Kil'jaeden"] = {
					["Horde"] = "Pothorde-Anetheron",
					["Alliance"] = "Potalliance-Anetheron",
				},
				["Die Nachtwache"] = {
					["Horde"] = "Pothorde-Zirkeldescenarius",
					["Alliance"] = "Potalliance-Zirkeldescenarius",
				},
				["Dalvengyr"] = {
					["Horde"] = "Pothorde-Aman'thul",
					["Alliance"] = "Potalliance-Aman'thul ",
				},
				["Frostwolf"] = {
					["Horde"] = "Pothorde-Frostwolf",
					["Alliance"] = "Potalliance-Frostwolf",
				},
				["Anub'arak"] = {
					["Horde"] = "Pothorde-Aman'thul",
					["Alliance"] = "Potalliance-Aman'thul ",
				},
				["Echsenkessel"] = {
					["Horde"] = "Pothorde-Blackhand",
					["Alliance"] = "Potalliance-Blackhand",
				},
				["Alleria"] = {
					["Horde"] = "Pothorde-Rexxar",
					["Alliance"] = "Potalliance-Rexxar",
				},
				["Taerar"] = {
					["Horde"] = "Pothorde-Blackhand",
					["Alliance"] = "Potalliance-Blackhand",
				},
				["Das Konsortium"] = {
					["Horde"] = "Pothorde-Diesilbernehand",
					["Alliance"] = "Potalliance-Diesilbernehand",
				},
				["Gilneas"] = {
					["Horde"] = "Pothorde-Gorgonnash",
					["Alliance"] = "Potalliance-Gorgonnash",
				},
				["Perenolde"] = {
					["Horde"] = "Pothorde-Garrosh",
					["Alliance"] = "Potalliance-Garrosh",
				},
				["Aegwynn"] = {
					["Horde"] = "Pothorde-Aegwynn",
					["Alliance"] = "Potalliance-Aegwynn",
				},
				["Teldrassil"] = {
					["Horde"] = "Pothorde-Garrosh",
					["Alliance"] = "Potalliance-Garrosh",
				},
				["Tirion"] = {
					["Horde"] = "Pothorde-Tirion",
					["Alliance"] = "Potalliance-Tirion",
				},
				["Durotan"] = {
					["Horde"] = "Pothorde-Tirion",
					["Alliance"] = "Potalliance-Tirion",
				},
				["Blackhand"] = {
					["Horde"] = "Pothorde-Blackhand",
					["Alliance"] = "Potalliance-Blackhand",
				},
				["Gorgonnash"] = {
					["Horde"] = "Pothorde-Gorgonnash",
					["Alliance"] = "Potalliance-Gorgonnash",
				},
				["Destromath"] = {
					["Horde"] = "Pothorde-Gorgonnash",
					["Alliance"] = "Potalliance-Gorgonnash",
				},
				["Ambossar"] = {
					["Horde"] = "Pothorde-Ambossar",
					["Alliance"] = "Potalliance-Ambossar",
				},
				["Shattrath"] = {
					["Horde"] = "Pothorde-Garrosh",
					["Alliance"] = "Potalliance-Garrosh",
				},
				["Der Mithrilorden"] = {
					["Horde"] = "Pothorde-Zirkeldescenarius",
					["Alliance"] = "Potalliance-Zirkeldescenarius",
				},
				["Malorne"] = {
					["Horde"] = "Pothorde-Ysera",
					["Alliance"] = "Potalliance-Ysera",
				},
				["Un'Goro"] = {
					["Horde"] = "Pothorde-Area52",
					["Alliance"] = "Potalliance-Area52",
				},
				["Madmortem"] = {
					["Horde"] = "Pothorde-Alexstrasza",
					["Alliance"] = "Potalliance-Alexstrasza",
				},
				["Nethersturm"] = {
					["Horde"] = "Pothorde-Alexstrasza",
					["Alliance"] = "Potalliance-Alexstrasza",
				},
				["Eredar"] = {
					["Horde"] = "Pothorde-Eredar",
					["Alliance"] = "Potalliance-Eredar",
				},
				["Malfurion"] = {
					["Horde"] = "Pothorde-Malfurion",
					["Alliance"] = "Potalliance-Malfurion",
				},
				["Kargath"] = {
					["Horde"] = "Pothorde-Ambossar",
					["Alliance"] = "Potalliance-Ambossar",
				},
				["Sen'jin"] = {
					["Horde"] = "Pothorde-Area52",
					["Alliance"] = "Potalliance-Area52",
				},
				["Der abyssische Rat"] = {
					["Horde"] = "Pothorde-Diesilbernehand",
					["Alliance"] = "Potalliance-Diesilbernehand",
				},
				["Der Rat von Dalaran"] = {
					["Horde"] = "Pothorde-Zirkeldescenarius",
					["Alliance"] = "Potalliance-Zirkeldescenarius",
				},
				["Krag'jin"] = {
					["Horde"] = "Pothorde-Lothar",
					["Alliance"] = "Potalliance-Lothar",
				},
				["Die Aldor"] = {
					["Horde"] = "Pothorde-Diealdor",
					["Alliance"] = "Potalliance-Diealdor",
				},
				["Lordaeron"] = {
					["Horde"] = "Pothorde-Blackmoore",
					["Alliance"] = "Potalliance-Blackmoore",
				},
				["Vek'lor"] = {
					["Horde"] = "Pothorde-Tirion",
					["Alliance"] = "Potalliance-Tirion",
				},
				["Zuluhed"] = {
					["Horde"] = "Pothorde-Aman'thul",
					["Alliance"] = "Potalliance-Aman'thul ",
				},
				["Onyxia"] = {
					["Horde"] = "Pothorde-Onyxia",
					["Alliance"] = "Potalliance-Onyxia",
				},
				["Frostmourne"] = {
					["Horde"] = "Pothorde-Aman'thul",
					["Alliance"] = "Potalliance-Aman'thul ",
				},
				["Nozdormu"] = {
					["Horde"] = "Pothorde-Garrosh",
					["Alliance"] = "Potalliance-Garrosh",
				},
				["Arthas"] = {
					["Horde"] = "Pothorde-Tirion",
					["Alliance"] = "Potalliance-Tirion",
				},
				["Azshara"] = {
					["Horde"] = "Pothorde-Lothar",
					["Alliance"] = "Potalliance-Lothar",
				},
				["Rexxar"] = {
					["Horde"] = "Pothorde-Rexxar",
					["Alliance"] = "Potalliance-Rexxar",
				},
				["Antonidas"] = {
					["Horde"] = "Pothorde-Antonidas",
					["Alliance"] = "Potalliance-Antonidas",
				},
				["Blackrock"] = {
					["Horde"] = "Pothorde-Blackrock",
					["Alliance"] = "Potalliance-Blackrock",
				},
				["Todeswache"] = {
					["Horde"] = "Pothorde-Zirkeldescenarius",
					["Alliance"] = "Potalliance-Zirkeldescenarius",
				},
				["Norgannon"] = {
					["Horde"] = "Pothorde-DunMorogh",
					["Alliance"] = "Potalliance-DunMorogh",
				},
				["Das Syndikat"] = {
					["Horde"] = "Pothorde-Diesilbernehand",
					["Alliance"] = "Potalliance-Diesilbernehand",
				},
				["Malygos"] = {
					["Horde"] = "Pothorde-Malfurion",
					["Alliance"] = "Potalliance-Malfurion",
				},
				["Festung der Stürme"] = {
					["Horde"] = "Pothorde-Anetheron",
					["Alliance"] = "Potalliance-Anetheron",
				},
				["Anetheron"] = {
					["Horde"] = "Pothorde-Anetheron",
					["Alliance"] = "Potalliance-Anetheron",
				},
				["Garrosh"] = {
					["Horde"] = "Pothorde-Garrosh",
					["Alliance"] = "Potalliance-Garrosh",
				},
				["Terrordar"] = {
					["Horde"] = "Pothorde-Onyxia",
					["Alliance"] = "Potalliance-Onyxia",
				},
				["Area 52"] = {
					["Horde"] = "Pothorde-Area52",
					["Alliance"] = "Potalliance-Area52",
				},
				["Dethecus"] = {
					["Horde"] = "Pothorde-Onyxia",
					["Alliance"] = "Potalliance-Onyxia",
				},
				["Kel'Thuzad"] = {
					["Horde"] = "Pothorde-Tirion",
					["Alliance"] = "Potalliance-Tirion",
				},
				["Thrall"] = {
					["Horde"] = "Pothorde-Thrall",
					["Alliance"] = "Potalliance-Thrall",
				},
				["Nera'thor"] = {
					["Horde"] = "Pothorde-Gorgonnash",
					["Alliance"] = "Potalliance-Gorgonnash",
				},
				["Gul'dan"] = {
					["Horde"] = "Pothorde-Anetheron",
					["Alliance"] = "Potalliance-Anetheron",
				},
				["Rajaxx"] = {
					["Horde"] = "Pothorde-Anetheron",
					["Alliance"] = "Potalliance-Anetheron",
				},
				["Nathrezim"] = {
					["Horde"] = "Pothorde-Anetheron",
					["Alliance"] = "Potalliance-Anetheron",
				},
				["Die Silberne Hand"] = {
					["Horde"] = "Pothorde-Diesilbernehand",
					["Alliance"] = "Potalliance-Diesilbernehand",
				},
				["Zirkel des Cenarius"] = {
					["Horde"] = "Pothorde-Zirkeldescenarius",
					["Alliance"] = "Potalliance-Zirkeldescenarius",
				},
				["Blackmoore"] = {
					["Horde"] = "Pothorde-Blackmoore",
					["Alliance"] = "Potalliance-Blackmoore",
				},
				["Forscheliga"] = {
					["Horde"] = "Pothorde-Zirkeldescenarius",
					["Alliance"] = "Potalliance-Zirkeldescenarius",
				},
				["Mal'Ganis"] = {
					["Horde"] = "Pothorde-Blackhand",
					["Alliance"] = "Potalliance-Blackhand",
				},
				["Die Arguswacht"] = {
					["Horde"] = "Pothorde-Diesilbernehand",
					["Alliance"] = "Potalliance-Diesilbernehand",
				},
				["Arygos"] = {
					["Horde"] = "Pothorde-Khaz'goroth",
					["Alliance"] = "Potalliance-Khaz'goroth",
				},
				["Die Todeskrallen"] = {
					["Horde"] = "Pothorde-Diesilbernehand",
					["Alliance"] = "Potalliance-Diesilbernehand",
				},
				["Kult der Verdammten"] = {
					["Horde"] = "Pothorde-Diesilbernehand",
					["Alliance"] = "Potalliance-Diesilbernehand",
				},
				["Dun Morogh"] = {
					["Horde"] = "Pothorde-DunMorogh",
					["Alliance"] = "Potalliance-DunMorogh",
				},
				["Baelgun"] = {
					["Horde"] = "Pothorde-Lothar",
					["Alliance"] = "Potalliance-Lothar",
				},
				["Nefarian"] = {
					["Horde"] = "Pothorde-Gorgonnash",
					["Alliance"] = "Potalliance-Gorgonnash",
				},
				["Blutkessel"] = {
					["Horde"] = "Pothorde-Tirion",
					["Alliance"] = "Potalliance-Tirion",
				},
				["Khaz'goroth"] = {
					["Horde"] = "Pothorde-Khaz'goroth",
					["Alliance"] = "Potalliance-Khaz'goroth",
				},
				["Nazjatar"] = {
					["Horde"] = "Pothorde-Aman'thul",
					["Alliance"] = "Potalliance-Aman'thul ",
				},
				["Aman'Thul"] = {
					["Horde"] = "Pothorde-Aman'thul",
					["Alliance"] = "Potalliance-Aman'thul ",
				},
				["Proudmoore"] = {
					["Horde"] = "Pothorde-Alexstrasza",
					["Alliance"] = "Potalliance-Alexstrasza",
				},
				["Ysera"] = {
					["Horde"] = "Pothorde-Ysera",
					["Alliance"] = "Potalliance-Ysera",
				},
				["Ulduar"] = {
					["Horde"] = "Pothorde-Gorgonnash",
					["Alliance"] = "Potalliance-Gorgonnash",
				},
			},
			["Spanish"] = {
				["Los Errantes"] = {
					["Horde"] = "Pothorde-Tyrande",
					["Alliance"] = "Potalliance-Tyrande",
				},
				["Exodar"] = {
					["Horde"] = "Pothorde-Minahonda",
					["Alliance"] = "Potalliance-Minahonda",
				},
				["Sanguino"] = {
					["Horde"] = "Pothorde-Sanguino",
					["Alliance"] = "Potalliance-Sanguino",
				},
				["Zul'jin"] = {
					["Horde"] = "Pothorde-Sanguino",
					["Alliance"] = "Potalliance-Sanguino",
				},
				["Minahonda"] = {
					["Horde"] = "Pothorde-Minahonda",
					["Alliance"] = "Potalliance-Minahonda",
				},
				["Uldum"] = {
					["Horde"] = "Pothorde-Sanguino",
					["Alliance"] = "Potalliance-Sanguino",
				},
				["Colinas Pardas"] = {
					["Horde"] = "Pothorde-Tyrande",
					["Alliance"] = "Potalliance-Tyrande",
				},
				["Shen'dralar"] = {
					["Horde"] = "Pothorde-Sanguino",
					["Alliance"] = "Potalliance-Sanguino",
				},
				["Dun Modr"] = {
					["Horde"] = "Pothorde-DunModr",
					["Alliance"] = "Potalliance-DunModr",
				},
				["Tyrande"] = {
					["Horde"] = "Pothorde-Tyrande",
					["Alliance"] = "Potalliance-Tyrande",
				},
				["C'thun"] = {
					["Horde"] = "Pothorde-C'thun",
					["Alliance"] = "Potalliance-C'thun ",
				},
			},
			["Italian"] = {
				["Pozzo dell'Eternità"] = {
					["Horde"] = "Pothorde-Pozzo dell'Eternità",
					["Alliance"] = "Potalliance-Pozzo dell'Eternità",
				},
				["Nemesis"] = {
					["Horde"] = "Pothorde-Nemesis",
					["Alliance"] = "Potalliance-Nemesis",
				},
			},
			["French"] = {
				["Conseil Des Ombres"] = {
					["Horde"] = "Pothorde-Kirintor",
					["Alliance"] = "Potalliance-Kirintor ",
				},
				["Sinstralis"] = {
					["Horde"] = "Pothorde-Dalaran",
					["Alliance"] = "Potalliance-Dalaran",
				},
				["Chants éternels"] = {
					["Horde"] = "Hordenova-Chantséternels",
					["Alliance"] = "Potalliance-Vol'jin",
				},
				["Hyjal"] = {
					["Horde"] = "Pothorde-Hyjal",
					["Alliance"] = "Potalliance-Hyjal ",
				},
				["Naxxramas"] = {
					["Horde"] = "Pothorde-Illidan",
					["Alliance"] = "Potalliance-Illidan",
				},
				["Varimathras"] = {
					["Horde"] = "Pothorde-Elune",
					["Alliance"] = "Potalliance-Elune",
				},
				["Krasus"] = {
					["Horde"] = "Pothorde-Uldaman",
					["Alliance"] = "Potalliance-Uldaman",
				},
				["Arathi"] = {
					["Horde"] = "Pothorde-Illidan",
					["Alliance"] = "Potalliance-Illidan",
				},
				["Eitrigg"] = {
					["Horde"] = "Pothorde-Uldaman",
					["Alliance"] = "Potalliance-Uldaman",
				},
				["Kirin Tor"] = {
					["Horde"] = "Pothorde-Kirintor",
					["Alliance"] = "Potalliance-Kirintor ",
				},
				["Garona"] = {
					["Horde"] = "Pothorde-Sargeras",
					["Alliance"] = "Potalliance-Sargeras",
				},
				["Vol'jin"] = {
					["Horde"] = "Hordenova-Chantséternels",
					["Alliance"] = "Potalliance-Vol'jin",
				},
				["Cho'gall"] = {
					["Horde"] = "Pothorde-Dalaran",
					["Alliance"] = "Potalliance-Dalaran",
				},
				["Ysondre"] = {
					["Horde"] = "Pothorde-Ysondre",
					["Alliance"] = "Potalliance-Ysondre ",
				},
				["Archimonde"] = {
					["Horde"] = "Pothorde-Archimonde",
					["Alliance"] = "Potalliance-Archimonde ",
				},
				["Elune"] = {
					["Horde"] = "Pothorde-Elune",
					["Alliance"] = "Potalliance-Elune",
				},
				["Les Sentinelles"] = {
					["Horde"] = "Pothorde-Kirintor",
					["Alliance"] = "Potalliance-Kirintor ",
				},
				["Les Clairvoyants"] = {
					["Horde"] = "Pothorde-Kirintor",
					["Alliance"] = "Potalliance-Kirintor ",
				},
				["Uldaman"] = {
					["Horde"] = "Pothorde-Uldaman",
					["Alliance"] = "Potalliance-Uldaman",
				},
				["Eldre'Thalas"] = {
					["Horde"] = "Pothorde-Dalaran",
					["Alliance"] = "Potalliance-Dalaran",
				},
				["Dalaran"] = {
					["Horde"] = "Pothorde-Dalaran",
					["Alliance"] = "Potalliance-Dalaran",
				},
				["Sargeras"] = {
					["Horde"] = "Pothorde-Sargeras",
					["Alliance"] = "Potalliance-Sargeras",
				},
				["Kael'Thas"] = {
					["Horde"] = "Pothorde-Kael'Thas",
					["Alliance"] = "Potalliance-Kael'Thas",
				},
				["Khaz Modan"] = {
					["Horde"] = "Pothorde-Khazmodan",
					["Alliance"] = "Potalliance-Khazmodan ",
				},
				["Rashgarroth"] = {
					["Horde"] = "Pothorde-Kael'Thas",
					["Alliance"] = "Potalliance-Kael'Thas",
				},
				["Ner’zhul"] = {
					["Horde"] = "Pothorde-Sargeras",
					["Alliance"] = "Potalliance-Sargeras",
				},
				["Throk'Feroth"] = {
					["Horde"] = "Pothorde-Kael'Thas",
					["Alliance"] = "Potalliance-Kael'Thas",
				},
				["Arak-arahm"] = {
					["Horde"] = "Pothorde-Kael'Thas",
					["Alliance"] = "Potalliance-Kael'Thas",
				},
				["Temple noir"] = {
					["Horde"] = "Pothorde-Illidan",
					["Alliance"] = "Potalliance-Illidan",
				},
				["La Croisade écarlate"] = {
					["Horde"] = "Pothorde-Kirintor",
					["Alliance"] = "Potalliance-Kirintor ",
				},
				["Illidan"] = {
					["Horde"] = "Pothorde-Illidan",
					["Alliance"] = "Potalliance-Illidan",
				},
				["Drek'Thar"] = {
					["Horde"] = "Pothorde-Uldaman",
					["Alliance"] = "Potalliance-Uldaman",
				},
				["Marécage de Zangar"] = {
					["Horde"] = "Pothorde-Dalaran",
					["Alliance"] = "Potalliance-Dalaran",
				},
				["Culte de la Rive noire"] = {
					["Horde"] = "Pothorde-Kirintor",
					["Alliance"] = "Potalliance-Kirintor ",
				},
				["Confrerie du Thorium"] = {
					["Horde"] = "Pothorde-Kirintor",
					["Alliance"] = "Potalliance-Kirintor ",
				},
				["Medivh , Suramar"] = {
					["Horde"] = "Pothorde-Medivh",
					["Alliance"] = "Potalliance-Medivh",
				},
			},
			["English"] = {
				["The Venture Co"] = {
					["Horde"] = "Pothorde-Defiasbrotherhood",
					["Alliance"] = "Potalliance-Defiasbrotherhood",
				},
				["Nordrassil"] = {
					["Horde"] = "Pothorde-Nordrassil",
					["Alliance"] = "Potalliance-Nordrassil",
				},
				["Silvermoon"] = {
					["Horde"] = "Pothorde-Silvermoon",
					["Alliance"] = "Potalliance-Silvermoon",
				},
				["Kilrogg"] = {
					["Horde"] = "Pothorde-Arathor",
					["Alliance"] = "Potalliance-Arathor",
				},
				["Ahn'Qiraj"] = {
					["Horde"] = "Pothorde-Ahn'qiraj",
					["Alliance"] = "Potalliance-Ahn'qiraj",
				},
				["Alonsus"] = {
					["Horde"] = "Pothorde-Alonsus",
					["Alliance"] = "Potalliance-Alonsus",
				},
				["Anachronos"] = {
					["Horde"] = "Pothorde-Alonsus",
					["Alliance"] = "Potalliance-Alonsus",
				},
				["Darkspear"] = {
					["Horde"] = "Pothorde-Darkspear",
					["Alliance"] = "Potalliance-Darkspear",
				},
				["Skullcrusher"] = {
					["Horde"] = "Pothorde-Al'akir",
					["Alliance"] = "Potalliance-Al'akir",
				},
				["Terokkar"] = {
					["Horde"] = "Pothorde-Darkspear",
					["Alliance"] = "Potalliance-Darkspear",
				},
				["Aszune"] = {
					["Horde"] = "Pothorde-Aszune",
					["Alliance"] = "Potalliance-Aszune",
				},
				["Aggra(português)"] = {
					["Horde"] = "Pothorde-Frostmane",
					["Alliance"] = "Potalliance-Frostmane",
				},
				["Darksorrow"] = {
					["Horde"] = "Pothorde-Darksorrow",
					["Alliance"] = "Potalliance-Darksorrow",
				},
				["Jaedenar"] = {
					["Horde"] = "Pothorde-Sylvanas",
					["Alliance"] = "Potalliance-Sylvanas",
				},
				["Runetotem"] = {
					["Horde"] = "Pothorde-Arathor",
					["Alliance"] = "Potalliance-Arathor",
				},
				["Xavius"] = {
					["Horde"] = "Pothorde-Al'akir",
					["Alliance"] = "Potalliance-Al'akir",
				},
				["Ravencrest"] = {
					["Horde"] = "Pothorde-Ravencrest",
					["Alliance"] = "Potalliance-Ravencrest",
				},
				["Draenor"] = {
					["Horde"] = "Pothorde-Draenor",
					["Alliance"] = "Potalliance-Draenor",
				},
				["Vek'Nilash"] = {
					["Horde"] = "Pothorde-Aeriepeak",
					["Alliance"] = "Potalliance-Aeriepeak",
				},
				["Deathwing"] = {
					["Horde"] = "Pothorde-Themaelstrom",
					["Alliance"] = "Potalliance-Themaelstrom",
				},
				["Agamaggan"] = {
					["Horde"] = "Pothorde-Emeriss",
					["Alliance"] = "Potalliance-Emeriss",
				},
				["Twilight's Hammer"] = {
					["Horde"] = "Pothorde-Emeriss",
					["Alliance"] = "Potalliance-Emeriss",
				},
				["Aerie Peak"] = {
					["Horde"] = "Pothorde-Aeriepeak",
					["Alliance"] = "Potalliance-Aeriepeak",
				},
				["Nagrand"] = {
					["Horde"] = "Pothorde-Arathor",
					["Alliance"] = "Potalliance-Arathor",
				},
				["Vashj"] = {
					["Horde"] = "Pothorde-Stormreaver",
					["Alliance"] = "Potalliance-Stormreaver",
				},
				["Ragnaros"] = {
					["Horde"] = "Pothorde-Ragnaros",
					["Alliance"] = "Potalliance-Ragnaros",
				},
				["Boulderfist"] = {
					["Horde"] = "Pothorde-Ahn'qiraj",
					["Alliance"] = "Potalliance-Ahn'qiraj",
				},
				["Al'Akir"] = {
					["Horde"] = "Pothorde-Al'akir",
					["Alliance"] = "Potalliance-Al'akir",
				},
				["Auchindoun"] = {
					["Horde"] = "Pothorde-Sylvanas",
					["Alliance"] = "Potalliance-Sylvanas",
				},
				["Balnazzar"] = {
					["Horde"] = "Pothorde-Ahn'qiraj",
					["Alliance"] = "Potalliance-Ahn'qiraj",
				},
				["Burning Steppes"] = {
					["Horde"] = "Pothorde-Darkspear",
					["Alliance"] = "Potalliance-Darkspear",
				},
				["Stormrage"] = {
					["Horde"] = "Pothorde-Stormrage",
					["Alliance"] = "Potalliance-Stormrage",
				},
				["Quel'Thalas"] = {
					["Horde"] = "Pothorde-Quel'thalas",
					["Alliance"] = "Potalliance-Quel'thalas",
				},
				["Haomarush"] = {
					["Horde"] = "Pothorde-Stormreaver",
					["Alliance"] = "Potalliance-Stormreaver",
				},
				["Terenas"] = {
					["Horde"] = "Pothorde-Emeralddream",
					["Alliance"] = "Potalliance-Emeralddream",
				},
				["Eonar"] = {
					["Horde"] = "Pothorde-Aeriepeak",
					["Alliance"] = "Potalliance-Aeriepeak",
				},
				["Chamber of Aspects"] = {
					["Horde"] = "Pothorde-Chamberofaspects",
					["Alliance"] = "Potalliance-Chamberofaspects",
				},
				["Steamwheedle Cartel"] = {
					["Horde"] = "Pothorde-Steamwheedlecartel",
					["Alliance"] = "Potalliance-Steamwheedlecartel",
				},
				["Neptulon"] = {
					["Horde"] = "Pothorde-Darksorrow",
					["Alliance"] = "Potalliance-Darksorrow",
				},
				["Thunderhorn"] = {
					["Horde"] = "Pothorde-Thunderhorn",
					["Alliance"] = "Potalliance-Thunderhorn",
				},
				["Outland"] = {
					["Horde"] = "Pothorde-Outland",
					["Alliance"] = "Potalliance-Outland",
				},
				["Burning Legion"] = {
					["Horde"] = "Pothorde-Al'akir",
					["Alliance"] = "Potalliance-Al'akir",
				},
				["Turalyon"] = {
					["Horde"] = "Pothorde-Doomhammer",
					["Alliance"] = "Potalliance-Doomhammer",
				},
				["Doomhammer"] = {
					["Horde"] = "Pothorde-Doomhammer",
					["Alliance"] = "Potalliance-Doomhammer",
				},
				["Scarshield Legion"] = {
					["Horde"] = "Pothorde-Defiasbrotherhood",
					["Alliance"] = "Potalliance-Defiasbrotherhood",
				},
				["Magtheridon"] = {
					["Horde"] = "Pothorde-Magtheridon",
					["Alliance"] = "Potalliance-Magtheridon",
				},
				["Daggerspine"] = {
					["Horde"] = "Pothorde-Ahn'qiraj",
					["Alliance"] = "Potalliance-Ahn'qiraj",
				},
				["Azjol-Nerub"] = {
					["Horde"] = "Pothorde-Quel'thalas",
					["Alliance"] = "Potalliance-Quel'thalas",
				},
				["Crushridge"] = {
					["Horde"] = "Pothorde-Emeriss",
					["Alliance"] = "Potalliance-Emeriss",
				},
				["Moonglade"] = {
					["Horde"] = "Pothorde-Steamwheedlecartel",
					["Alliance"] = "Potalliance-Steamwheedlecartel",
				},
				["Spinebreaker"] = {
					["Horde"] = "Pothorde-Stormreaver",
					["Alliance"] = "Potalliance-Stormreaver",
				},
				["Aggramar"] = {
					["Horde"] = "Pothorde-Aggramar",
					["Alliance"] = "Potalliance-Aggramar",
				},
				["Genjuros"] = {
					["Horde"] = "Pothorde-Darksorrow",
					["Alliance"] = "Potalliance-Darksorrow",
				},
				["Saurfang"] = {
					["Horde"] = "Pothorde-Darkspear",
					["Alliance"] = "Potalliance-Darkspear",
				},
				["Frostwhisper"] = {
					["Horde"] = "Pothorde-Darksorrow",
					["Alliance"] = "Potalliance-Darksorrow",
				},
				["Shattered Halls"] = {
					["Horde"] = "Pothorde-Ahn'qiraj",
					["Alliance"] = "Potalliance-Ahn'qiraj",
				},
				["Dentarg"] = {
					["Horde"] = "Pothorde-TarrenMill",
					["Alliance"] = "Potalliance-TarrenMill",
				},
				["Twisting Nether"] = {
					["Horde"] = "Pothorde-TwistingNether",
					["Alliance"] = "Potalliance-Twisting Nether",
				},
				["Shadowsong"] = {
					["Horde"] = "Pothorde-Aszune",
					["Alliance"] = "Potalliance-Aszune",
				},
				["Kazzak"] = {
					["Horde"] = "Pothorde-Kazzak",
					["Alliance"] = "Potalliance-Kazzak",
				},
				["Sporeggar"] = {
					["Horde"] = "Pothorde-Defiasbrotherhood",
					["Alliance"] = "Potalliance-Defiasbrotherhood",
				},
				["Bladefist"] = {
					["Horde"] = "Pothorde-Darksorrow",
					["Alliance"] = "Potalliance-Darksorrow",
				},
				["Bloodhoof"] = {
					["Horde"] = "Pothorde-Khadgar",
					["Alliance"] = "Potalliance-Khadgar",
				},
				["Dragonmaw"] = {
					["Horde"] = "Pothorde-Stormreaver",
					["Alliance"] = "Potalliance-Stormreaver",
				},
				["Drak'Thul"] = {
					["Horde"] = "Pothorde-Drak'Thul",
					["Alliance"] = "Potalliance-Drak'Thul",
				},
				["Dunemaul"] = {
					["Horde"] = "Pothorde-Sylvanas",
					["Alliance"] = "Potalliance-Sylvanas",
				},
				["Defias Brotherhood"] = {
					["Horde"] = "Pothorde-Defiasbrotherhood",
					["Alliance"] = "Potalliance-Defiasbrotherhood",
				},
				["Bloodscalp"] = {
					["Horde"] = "Pothorde-Emeriss",
					["Alliance"] = "Potalliance-Emeriss",
				},
				["Tarren Mill"] = {
					["Horde"] = "Pothorde-TarrenMill",
					["Alliance"] = "Potalliance-TarrenMill",
				},
				["Burning Blade"] = {
					["Horde"] = "Pothorde-Drak'Thul",
					["Alliance"] = "Potalliance-Drak'Thul",
				},
				["Laughing Skull"] = {
					["Horde"] = "Pothorde-Ahn'qiraj",
					["Alliance"] = "Potalliance-Ahn'qiraj",
				},
				["Lightbringer"] = {
					["Horde"] = "Pothorde-Lightbringer",
					["Alliance"] = "Potalliance-Lightbringer",
				},
				["Dragonblight"] = {
					["Horde"] = "Pothorde-Themaelstrom",
					["Alliance"] = "Potalliance-Themaelstrom",
				},
				["Frostmane"] = {
					["Horde"] = "Pothorde-Frostmane",
					["Alliance"] = "Potalliance-Frostmane",
				},
				["Emerald Dream"] = {
					["Horde"] = "Pothorde-Emeralddream",
					["Alliance"] = "Potalliance-Emeralddream",
				},
				["Kor'gall"] = {
					["Horde"] = "Pothorde-Darkspear",
					["Alliance"] = "Potalliance-Darkspear",
				},
				["The Sha'Tar"] = {
					["Horde"] = "Pothorde-Steamwheedlecartel",
					["Alliance"] = "Potalliance-Steamwheedlecartel",
				},
				["Mazrigos"] = {
					["Horde"] = "Pothorde-Lightbringer",
					["Alliance"] = "Potalliance-Lightbringer",
				},
				["Talnivarr"] = {
					["Horde"] = "Pothorde-Ahn'qiraj",
					["Alliance"] = "Potalliance-Ahn'qiraj",
				},
				["Wildhammer"] = {
					["Horde"] = "Pothorde-Thunderhorn",
					["Alliance"] = "Potalliance-Thunderhorn",
				},
				["Sylvanas"] = {
					["Horde"] = "Pothorde-Sylvanas",
					["Alliance"] = "Potalliance-Sylvanas",
				},
				["The Maelstrom"] = {
					["Horde"] = "Pothorde-Themaelstrom",
					["Alliance"] = "Potalliance-Themaelstrom",
				},
				["Hellfire"] = {
					["Horde"] = "Pothorde-Arathor",
					["Alliance"] = "Potalliance-Arathor",
				},
				["Azuremyst"] = {
					["Horde"] = "Pothorde-Stormrage",
					["Alliance"] = "Potalliance-Stormrage",
				},
				["Darkmoon Faire"] = {
					["Horde"] = "Pothorde-Defiasbrotherhood",
					["Alliance"] = "Potalliance-Defiasbrotherhood",
				},
				["Zenedar"] = {
					["Horde"] = "Pothorde-Darksorrow",
					["Alliance"] = "Potalliance-Darksorrow",
				},
				["Ghostlands"] = {
					["Horde"] = "Pothorde-Themaelstrom",
					["Alliance"] = "Potalliance-Themaelstrom",
				},
				["Blade's Edge"] = {
					["Horde"] = "Pothorde-Aeriepeak",
					["Alliance"] = "Potalliance-Aeriepeak",
				},
				["Bronze Dragonflight"] = {
					["Horde"] = "Pothorde-Nordrassil",
					["Alliance"] = "Potalliance-Nordrassil",
				},
				["Hellscream"] = {
					["Horde"] = "Pothorde-Aggramar",
					["Alliance"] = "Potalliance-Aggramar",
				},
				["Stormscale"] = {
					["Horde"] = "Pothorde-Stormscale",
					["Alliance"] = "Potalliance-Stormscale",
				},
				["Khadgar"] = {
					["Horde"] = "Pothorde-Khadgar",
					["Alliance"] = "Potalliance-Khadgar",
				},
				["Bronzebeard"] = {
					["Horde"] = "Pothorde-Aeriepeak",
					["Alliance"] = "Potalliance-Aeriepeak",
				},
				["Arathor"] = {
					["Horde"] = "Pothorde-Arathor",
					["Alliance"] = "Potalliance-Arathor",
				},
				["Bloodfeather"] = {
					["Horde"] = "Pothorde-Darkspear",
					["Alliance"] = "Potalliance-Darkspear",
				},
				["Executus"] = {
					["Horde"] = "Pothorde-Darkspear",
					["Alliance"] = "Potalliance-Darkspear",
				},
				["Hakkar"] = {
					["Horde"] = "Pothorde-Emeriss",
					["Alliance"] = "Potalliance-Emeriss",
				},
				["Kul Tiras"] = {
					["Horde"] = "Pothorde-Alonsus",
					["Alliance"] = "Potalliance-Alonsus",
				},
				["Lightning's Blade"] = {
					["Horde"] = "Pothorde-Themaelstrom",
					["Alliance"] = "Potalliance-Themaelstrom",
				},
				["Sunstrider"] = {
					["Horde"] = "Pothorde-Ahn'qiraj",
					["Alliance"] = "Potalliance-Ahn'qiraj",
				},
				["Earthen Ring"] = {
					["Horde"] = "Pothorde-Defiasbrotherhood",
					["Alliance"] = "Potalliance-Defiasbrotherhood",
				},
				["Emeriss"] = {
					["Horde"] = "Pothorde-Emeriss",
					["Alliance"] = "Potalliance-Emeriss",
				},
				["Trollbane"] = {
					["Horde"] = "Pothorde-Ahn'qiraj",
					["Alliance"] = "Potalliance-Ahn'qiraj",
				},
				["Grim Batol"] = {
					["Horde"] = "Pothorde-Frostmane",
					["Alliance"] = "Potalliance-Frostmane",
				},
				["Stormreaver"] = {
					["Horde"] = "Pothorde-Stormreaver",
					["Alliance"] = "Potalliance-Stormreaver",
				},
				["Karazhan"] = {
					["Horde"] = "Pothorde-Themaelstrom",
					["Alliance"] = "Potalliance-Themaelstrom",
				},
				["Ravenholdt"] = {
					["Horde"] = "Pothorde-Defiasbrotherhood",
					["Alliance"] = "Potalliance-Defiasbrotherhood",
				},
				["Shattered Hand"] = {
					["Horde"] = "Pothorde-Darkspear",
					["Alliance"] = "Potalliance-Darkspear",
				},
				["Chromaggus"] = {
					["Horde"] = "Pothorde-Ahn'qiraj",
					["Alliance"] = "Potalliance-Ahn'qiraj",
				},
				["ArgentDawn"] = {
					["Horde"] = "Pothorde-Argentdawn",
					["Alliance"] = "Potalliance-Argentdawn",
				},
			},
		},
		["Profile A"] = {
			["German"] = {
				["Wrathbringer"] = {
					["Horde"] = "Hordepot-Tirion",
					["Alliance"] = "Alliancepot-Tirion",
				},
				["Mannoroth"] = {
					["Horde"] = "Hordepot-Gorgonnash",
					["Alliance"] = "Alliancepot-Gorgonnash",
				},
				["Tichondrius"] = {
					["Horde"] = "Hordepot-Blackmoore",
					["Alliance"] = "Alliancepot-Blackmoore",
				},
				["Theradras"] = {
					["Horde"] = "Hordepot-Onyxia",
					["Alliance"] = "Alliancepot-Onyxia",
				},
				["Alexstrasza"] = {
					["Horde"] = "Hordepot-Alexstrasza",
					["Alliance"] = "Alliancepot-Alexstrasza",
				},
				["Die ewige Wacht"] = {
					["Horde"] = "Hordepot-Diesilbernehand",
					["Alliance"] = "Alliancepot-Diesilbernehand",
				},
				["Lothar"] = {
					["Horde"] = "Hordepot-Lothar",
					["Alliance"] = "Alliancepot-Lothar",
				},
				["Mug'thol"] = {
					["Horde"] = "Hordepot-Onyxia",
					["Alliance"] = "Alliancepot-Onyxia",
				},
				["Kil'jaeden"] = {
					["Horde"] = "Hordepot-Anetheron",
					["Alliance"] = "Alliancepot-Anetheron",
				},
				["Die Nachtwache"] = {
					["Horde"] = "Hordepot-Zirkeldescenarius",
					["Alliance"] = "Alliancepot-Zirkeldescenarius",
				},
				["Dalvengyr"] = {
					["Horde"] = "Hordepot-Aman'thul",
					["Alliance"] = "Alliancepot-Aman'thul ",
				},
				["Frostwolf"] = {
					["Horde"] = "Hordepot-Frostwolf",
					["Alliance"] = "Alliancepot-Frostwolf",
				},
				["Anub'arak"] = {
					["Horde"] = "Hordepot-Aman'thul",
					["Alliance"] = "Alliancepot-Aman'thul ",
				},
				["Echsenkessel"] = {
					["Horde"] = "Hordepot-Blackhand",
					["Alliance"] = "Alliancepot-Blackhand",
				},
				["Alleria"] = {
					["Horde"] = "Hordepot-Rexxar",
					["Alliance"] = "Alliancepot-Rexxar",
				},
				["Taerar"] = {
					["Horde"] = "Hordepot-Blackhand",
					["Alliance"] = "Alliancepot-Blackhand",
				},
				["Das Konsortium"] = {
					["Horde"] = "Hordepot-Diesilbernehand",
					["Alliance"] = "Alliancepot-Diesilbernehand",
				},
				["Gilneas"] = {
					["Horde"] = "Hordepot-Gorgonnash",
					["Alliance"] = "Alliancepot-Gorgonnash",
				},
				["Perenolde"] = {
					["Horde"] = "Hordepot-Garrosh",
					["Alliance"] = "Alliancepot-Garrosh",
				},
				["Aegwynn"] = {
					["Horde"] = "Hordepot-Aegwynn",
					["Alliance"] = "Alliancepot-Aegwynn",
				},
				["Teldrassil"] = {
					["Horde"] = "Hordepot-Garrosh",
					["Alliance"] = "Alliancepot-Garrosh",
				},
				["Tirion"] = {
					["Horde"] = "Hordepot-Tirion",
					["Alliance"] = "Alliancepot-Tirion",
				},
				["Durotan"] = {
					["Horde"] = "Hordepot-Tirion",
					["Alliance"] = "Alliancepot-Tirion",
				},
				["Blackhand"] = {
					["Horde"] = "Hordepot-Blackhand",
					["Alliance"] = "Alliancepot-Blackhand",
				},
				["Gorgonnash"] = {
					["Horde"] = "Hordepot-Gorgonnash",
					["Alliance"] = "Alliancepot-Gorgonnash",
				},
				["Destromath"] = {
					["Horde"] = "Hordepot-Gorgonnash",
					["Alliance"] = "Alliancepot-Gorgonnash",
				},
				["Ambossar"] = {
					["Horde"] = "Hordepot-Ambossar",
					["Alliance"] = "Alliancepot-Ambossar",
				},
				["Shattrath"] = {
					["Horde"] = "Hordepot-Garrosh",
					["Alliance"] = "Alliancepot-Garrosh",
				},
				["Der Mithrilorden"] = {
					["Horde"] = "Hordepot-Zirkeldescenarius",
					["Alliance"] = "Alliancepot-Zirkeldescenarius",
				},
				["Malorne"] = {
					["Horde"] = "Hordepot-Ysera",
					["Alliance"] = "Alliancepot-Ysera",
				},
				["Un'Goro"] = {
					["Horde"] = "Hordepot-Area52",
					["Alliance"] = "Alliancepot-Area52",
				},
				["Madmortem"] = {
					["Horde"] = "Hordepot-Alexstrasza",
					["Alliance"] = "Alliancepot-Alexstrasza",
				},
				["Nethersturm"] = {
					["Horde"] = "Hordepot-Alexstrasza",
					["Alliance"] = "Alliancepot-Alexstrasza",
				},
				["Eredar"] = {
					["Horde"] = "Hordepot-Eredar",
					["Alliance"] = "Alliancepot-Eredar",
				},
				["Malfurion"] = {
					["Horde"] = "Hordepot-Malfurion",
					["Alliance"] = "Alliancepot-Malfurion",
				},
				["Kargath"] = {
					["Horde"] = "Hordepot-Ambossar",
					["Alliance"] = "Alliancepot-Ambossar",
				},
				["Sen'jin"] = {
					["Horde"] = "Hordepot-Area52",
					["Alliance"] = "Alliancepot-Area52",
				},
				["Der abyssische Rat"] = {
					["Horde"] = "Hordepot-Diesilbernehand",
					["Alliance"] = "Alliancepot-Diesilbernehand",
				},
				["Der Rat von Dalaran"] = {
					["Horde"] = "Hordepot-Zirkeldescenarius",
					["Alliance"] = "Alliancepot-Zirkeldescenarius",
				},
				["Krag'jin"] = {
					["Horde"] = "Hordepot-Lothar",
					["Alliance"] = "Alliancepot-Lothar",
				},
				["Die Aldor"] = {
					["Horde"] = "Hordepot-Diealdor",
					["Alliance"] = "Alliancepot-Diealdor",
				},
				["Lordaeron"] = {
					["Horde"] = "Hordepot-Blackmoore",
					["Alliance"] = "Alliancepot-Blackmoore",
				},
				["Vek'lor"] = {
					["Horde"] = "Hordepot-Tirion",
					["Alliance"] = "Alliancepot-Tirion",
				},
				["Zuluhed"] = {
					["Horde"] = "Hordepot-Aman'thul",
					["Alliance"] = "Alliancepot-Aman'thul ",
				},
				["Onyxia"] = {
					["Horde"] = "Hordepot-Onyxia",
					["Alliance"] = "Alliancepot-Onyxia",
				},
				["Frostmourne"] = {
					["Horde"] = "Hordepot-Aman'thul",
					["Alliance"] = "Alliancepot-Aman'thul ",
				},
				["Nozdormu"] = {
					["Horde"] = "Hordepot-Garrosh",
					["Alliance"] = "Alliancepot-Garrosh",
				},
				["Arthas"] = {
					["Horde"] = "Hordepot-Tirion",
					["Alliance"] = "Alliancepot-Tirion",
				},
				["Azshara"] = {
					["Horde"] = "Hordepot-Lothar",
					["Alliance"] = "Alliancepot-Lothar",
				},
				["Rexxar"] = {
					["Horde"] = "Hordepot-Rexxar",
					["Alliance"] = "Alliancepot-Rexxar",
				},
				["Antonidas"] = {
					["Horde"] = "Hordepot-Antonidas",
					["Alliance"] = "Alliancepot-Antonidas",
				},
				["Blackrock"] = {
					["Horde"] = "Hordepot-Blackrock",
					["Alliance"] = "Alliancepot-Blackrock",
				},
				["Todeswache"] = {
					["Horde"] = "Hordepot-Zirkeldescenarius",
					["Alliance"] = "Alliancepot-Zirkeldescenarius",
				},
				["Norgannon"] = {
					["Horde"] = "Hordepot-DunMorogh",
					["Alliance"] = "Alliancepot-DunMorogh",
				},
				["Das Syndikat"] = {
					["Horde"] = "Hordepot-Diesilbernehand",
					["Alliance"] = "Alliancepot-Diesilbernehand",
				},
				["Malygos"] = {
					["Horde"] = "Hordepot-Malfurion",
					["Alliance"] = "Alliancepot-Malfurion",
				},
				["Festung der Stürme"] = {
					["Horde"] = "Hordepot-Anetheron",
					["Alliance"] = "Alliancepot-Anetheron",
				},
				["Anetheron"] = {
					["Horde"] = "Hordepot-Anetheron",
					["Alliance"] = "Alliancepot-Anetheron",
				},
				["Garrosh"] = {
					["Horde"] = "Hordepot-Garrosh",
					["Alliance"] = "Alliancepot-Garrosh",
				},
				["Terrordar"] = {
					["Horde"] = "Hordepot-Onyxia",
					["Alliance"] = "Alliancepot-Onyxia",
				},
				["Area 52"] = {
					["Horde"] = "Hordepot-Area52",
					["Alliance"] = "Alliancepot-Area52",
				},
				["Dethecus"] = {
					["Horde"] = "Hordepot-Onyxia",
					["Alliance"] = "Alliancepot-Onyxia",
				},
				["Kel'Thuzad"] = {
					["Horde"] = "Hordepot-Tirion",
					["Alliance"] = "Alliancepot-Tirion",
				},
				["Thrall"] = {
					["Horde"] = "Hordepot-Thrall",
					["Alliance"] = "Alliancepot-Thrall",
				},
				["Nera'thor"] = {
					["Horde"] = "Hordepot-Gorgonnash",
					["Alliance"] = "Alliancepot-Gorgonnash",
				},
				["Gul'dan"] = {
					["Horde"] = "Hordepot-Anetheron",
					["Alliance"] = "Alliancepot-Anetheron",
				},
				["Rajaxx"] = {
					["Horde"] = "Hordepot-Anetheron",
					["Alliance"] = "Alliancepot-Anetheron",
				},
				["Nathrezim"] = {
					["Horde"] = "Hordepot-Anetheron",
					["Alliance"] = "Alliancepot-Anetheron",
				},
				["Die Silberne Hand"] = {
					["Horde"] = "Hordepot-Diesilbernehand",
					["Alliance"] = "Alliancepot-Diesilbernehand",
				},
				["Zirkel des Cenarius"] = {
					["Horde"] = "Hordepot-Zirkeldescenarius",
					["Alliance"] = "Alliancepot-Zirkeldescenarius",
				},
				["Blackmoore"] = {
					["Horde"] = "Hordepot-Blackmoore",
					["Alliance"] = "Alliancepot-Blackmoore",
				},
				["Forscheliga"] = {
					["Horde"] = "Hordepot-Zirkeldescenarius",
					["Alliance"] = "Alliancepot-Zirkeldescenarius",
				},
				["Mal'Ganis"] = {
					["Horde"] = "Hordepot-Blackhand",
					["Alliance"] = "Alliancepot-Blackhand",
				},
				["Die Arguswacht"] = {
					["Horde"] = "Hordepot-Diesilbernehand",
					["Alliance"] = "Alliancepot-Diesilbernehand",
				},
				["Arygos"] = {
					["Horde"] = "Hordepot-Khaz'goroth",
					["Alliance"] = "Alliancepot-Khaz'goroth",
				},
				["Die Todeskrallen"] = {
					["Horde"] = "Hordepot-Diesilbernehand",
					["Alliance"] = "Alliancepot-Diesilbernehand",
				},
				["Kult der Verdammten"] = {
					["Horde"] = "Hordepot-Diesilbernehand",
					["Alliance"] = "Alliancepot-Diesilbernehand",
				},
				["Dun Morogh"] = {
					["Horde"] = "Hordepot-DunMorogh",
					["Alliance"] = "Alliancepot-DunMorogh",
				},
				["Baelgun"] = {
					["Horde"] = "Hordepot-Lothar",
					["Alliance"] = "Alliancepot-Lothar",
				},
				["Nefarian"] = {
					["Horde"] = "Hordepot-Gorgonnash",
					["Alliance"] = "Alliancepot-Gorgonnash",
				},
				["Blutkessel"] = {
					["Horde"] = "Hordepot-Tirion",
					["Alliance"] = "Alliancepot-Tirion",
				},
				["Khaz'goroth"] = {
					["Horde"] = "Hordepot-Khaz'goroth",
					["Alliance"] = "Alliancepot-Khaz'goroth",
				},
				["Nazjatar"] = {
					["Horde"] = "Hordepot-Aman'thul",
					["Alliance"] = "Alliancepot-Aman'thul ",
				},
				["Aman'Thul"] = {
					["Horde"] = "Hordepot-Aman'thul",
					["Alliance"] = "Alliancepot-Aman'thul ",
				},
				["Proudmoore"] = {
					["Horde"] = "Hordepot-Alexstrasza",
					["Alliance"] = "Alliancepot-Alexstrasza",
				},
				["Ysera"] = {
					["Horde"] = "Hordepot-Ysera",
					["Alliance"] = "Alliancepot-Ysera",
				},
				["Ulduar"] = {
					["Horde"] = "Hordepot-Gorgonnash",
					["Alliance"] = "Alliancepot-Gorgonnash",
				},
			},
			["Spanish"] = {
				["Los Errantes"] = {
					["Horde"] = "Hordepot-Tyrande",
					["Alliance"] = "Alliancepot-Tyrande",
				},
				["Exodar"] = {
					["Horde"] = "Hordepot-Minahonda",
					["Alliance"] = "Alliancepot-Minahonda",
				},
				["Sanguino"] = {
					["Horde"] = "Hordepot-Sanguino",
					["Alliance"] = "Alliancepot-Sanguino",
				},
				["Zul'jin"] = {
					["Horde"] = "Hordepot-Sanguino",
					["Alliance"] = "Alliancepot-Sanguino",
				},
				["Minahonda"] = {
					["Horde"] = "Hordepot-Minahonda",
					["Alliance"] = "Alliancepot-Minahonda",
				},
				["Uldum"] = {
					["Horde"] = "Hordepot-Sanguino",
					["Alliance"] = "Alliancepot-Sanguino",
				},
				["Colinas Pardas"] = {
					["Horde"] = "Hordepot-Tyrande",
					["Alliance"] = "Alliancepot-Tyrande",
				},
				["Shen'dralar"] = {
					["Horde"] = "Hordepot-Sanguino",
					["Alliance"] = "Alliancepot-Sanguino",
				},
				["Dun Modr"] = {
					["Horde"] = "Hordepot-DunModr",
					["Alliance"] = "Alliancepot-DunModr",
				},
				["Tyrande"] = {
					["Horde"] = "Hordepot-Tyrande",
					["Alliance"] = "Alliancepot-Tyrande",
				},
				["C'thun"] = {
					["Horde"] = "Hordepot-C'thun",
					["Alliance"] = "Alliancepot-C'thun ",
				},
			},
			["Italian"] = {
				["Pozzo dell'Eternità"] = {
					["Horde"] = "Hordepot-Pozzo dell'Eternità",
					["Alliance"] = "Alliancepot-Pozzo dell'Eternità",
				},
				["Nemesis"] = {
					["Horde"] = "Hordepot-Nemesis",
					["Alliance"] = "Alliancepot-Nemesis",
				},
			},
			["French"] = {
				["Conseil Des Ombres"] = {
					["Horde"] = "Hordepot-Kirintor",
					["Alliance"] = "Alliancepot-Kirintor ",
				},
				["Sinstralis"] = {
					["Horde"] = "Hordepot-Dalaran",
					["Alliance"] = "Alliancepot-Dalaran",
				},
				["Chants éternels"] = {
					["Horde"] = "Hordenova-Chantséternels",
					["Alliance"] = "Alliancepot-Vol'jin",
				},
				["Hyjal"] = {
					["Horde"] = "Hordepot-Hyjal",
					["Alliance"] = "Alliancepot-Hyjal ",
				},
				["Naxxramas"] = {
					["Horde"] = "Hordepot-Illidan",
					["Alliance"] = "Alliancepot-Illidan",
				},
				["Varimathras"] = {
					["Horde"] = "Hordepot-Elune",
					["Alliance"] = "Alliancepot-Elune",
				},
				["Krasus"] = {
					["Horde"] = "Hordepot-Uldaman",
					["Alliance"] = "Alliancepot-Uldaman",
				},
				["Arathi"] = {
					["Horde"] = "Hordepot-Illidan",
					["Alliance"] = "Alliancepot-Illidan",
				},
				["Eitrigg"] = {
					["Horde"] = "Hordepot-Uldaman",
					["Alliance"] = "Alliancepot-Uldaman",
				},
				["Kirin Tor"] = {
					["Horde"] = "Hordepot-Kirintor",
					["Alliance"] = "Alliancepot-Kirintor ",
				},
				["Garona"] = {
					["Horde"] = "Hordepot-Sargeras",
					["Alliance"] = "Alliancepot-Sargeras",
				},
				["Vol'jin"] = {
					["Horde"] = "Hordenova-Chantséternels",
					["Alliance"] = "Alliancepot-Vol'jin",
				},
				["Cho'gall"] = {
					["Horde"] = "Hordepot-Dalaran",
					["Alliance"] = "Alliancepot-Dalaran",
				},
				["Ysondre"] = {
					["Horde"] = "Hordepot-Ysondre",
					["Alliance"] = "Alliancepot-Ysondre ",
				},
				["Archimonde"] = {
					["Horde"] = "Hordepot-Archimonde",
					["Alliance"] = "Alliancepot-Archimonde ",
				},
				["Elune"] = {
					["Horde"] = "Hordepot-Elune",
					["Alliance"] = "Alliancepot-Elune",
				},
				["Les Sentinelles"] = {
					["Horde"] = "Hordepot-Kirintor",
					["Alliance"] = "Alliancepot-Kirintor ",
				},
				["Les Clairvoyants"] = {
					["Horde"] = "Hordepot-Kirintor",
					["Alliance"] = "Alliancepot-Kirintor ",
				},
				["Uldaman"] = {
					["Horde"] = "Hordepot-Uldaman",
					["Alliance"] = "Alliancepot-Uldaman",
				},
				["Eldre'Thalas"] = {
					["Horde"] = "Hordepot-Dalaran",
					["Alliance"] = "Alliancepot-Dalaran",
				},
				["Dalaran"] = {
					["Horde"] = "Hordepot-Dalaran",
					["Alliance"] = "Alliancepot-Dalaran",
				},
				["Sargeras"] = {
					["Horde"] = "Hordepot-Sargeras",
					["Alliance"] = "Alliancepot-Sargeras",
				},
				["Kael'Thas"] = {
					["Horde"] = "Hordepot-Kael'Thas",
					["Alliance"] = "Alliancepot-Kael'Thas",
				},
				["Khaz Modan"] = {
					["Horde"] = "Hordepot-Khazmodan",
					["Alliance"] = "Alliancepot-Khazmodan ",
				},
				["Rashgarroth"] = {
					["Horde"] = "Hordepot-Kael'Thas",
					["Alliance"] = "Alliancepot-Kael'Thas",
				},
				["Ner’zhul"] = {
					["Horde"] = "Hordepot-Sargeras",
					["Alliance"] = "Alliancepot-Sargeras",
				},
				["Throk'Feroth"] = {
					["Horde"] = "Hordepot-Kael'Thas",
					["Alliance"] = "Alliancepot-Kael'Thas",
				},
				["Arak-arahm"] = {
					["Horde"] = "Hordepot-Kael'Thas",
					["Alliance"] = "Alliancepot-Kael'Thas",
				},
				["Temple noir"] = {
					["Horde"] = "Hordepot-Illidan",
					["Alliance"] = "Alliancepot-Illidan",
				},
				["La Croisade écarlate"] = {
					["Horde"] = "Hordepot-Kirintor",
					["Alliance"] = "Alliancepot-Kirintor ",
				},
				["Illidan"] = {
					["Horde"] = "Hordepot-Illidan",
					["Alliance"] = "Alliancepot-Illidan",
				},
				["Drek'Thar"] = {
					["Horde"] = "Hordepot-Uldaman",
					["Alliance"] = "Alliancepot-Uldaman",
				},
				["Marécage de Zangar"] = {
					["Horde"] = "Hordepot-Dalaran",
					["Alliance"] = "Alliancepot-Dalaran",
				},
				["Culte de la Rive noire"] = {
					["Horde"] = "Hordepot-Kirintor",
					["Alliance"] = "Alliancepot-Kirintor ",
				},
				["Confrerie du Thorium"] = {
					["Horde"] = "Hordepot-Kirintor",
					["Alliance"] = "Alliancepot-Kirintor ",
				},
				["Medivh , Suramar"] = {
					["Horde"] = "Hordepot-Medivh",
					["Alliance"] = "Alliancepot-Medivh",
				},
			},
			["English"] = {
				["The Venture Co"] = {
					["Horde"] = "Hordepot-Defiasbrotherhood",
					["Alliance"] = "Alliancepot-Defiasbrotherhood",
				},
				["Nordrassil"] = {
					["Horde"] = "Hordepot-Nordrassil",
					["Alliance"] = "Alliancepot-Nordrassil",
				},
				["Silvermoon"] = {
					["Horde"] = "Hordepot-Silvermoon",
					["Alliance"] = "Alliancepot-Silvermoon",
				},
				["Kilrogg"] = {
					["Horde"] = "Hordepot-Arathor",
					["Alliance"] = "Alliancepot-Arathor",
				},
				["Ahn'Qiraj"] = {
					["Horde"] = "Hordepot-Ahn'qiraj",
					["Alliance"] = "Alliancepot-Ahn'qiraj",
				},
				["Alonsus"] = {
					["Horde"] = "Hordepot-Alonsus",
					["Alliance"] = "Alliancepot-Alonsus",
				},
				["Anachronos"] = {
					["Horde"] = "Hordepot-Alonsus",
					["Alliance"] = "Alliancepot-Alonsus",
				},
				["Darkspear"] = {
					["Horde"] = "Hordepot-Darkspear",
					["Alliance"] = "Alliancepot-Darkspear",
				},
				["Skullcrusher"] = {
					["Horde"] = "Hordepot-Al'akir",
					["Alliance"] = "Alliancepot-Al'akir",
				},
				["Terokkar"] = {
					["Horde"] = "Hordepot-Darkspear",
					["Alliance"] = "Alliancepot-Darkspear",
				},
				["Aszune"] = {
					["Horde"] = "Hordepot-Aszune",
					["Alliance"] = "Alliancepot-Aszune",
				},
				["Aggra(português)"] = {
					["Horde"] = "Hordepot-Frostmane",
					["Alliance"] = "Alliancepot-Frostmane",
				},
				["Darksorrow"] = {
					["Horde"] = "Hordepot-Darksorrow",
					["Alliance"] = "Alliancepot-Darksorrow",
				},
				["Jaedenar"] = {
					["Horde"] = "Hordepot-Sylvanas",
					["Alliance"] = "Alliancepot-Sylvanas",
				},
				["Runetotem"] = {
					["Horde"] = "Hordepot-Arathor",
					["Alliance"] = "Alliancepot-Arathor",
				},
				["Xavius"] = {
					["Horde"] = "Hordepot-Al'akir",
					["Alliance"] = "Alliancepot-Al'akir",
				},
				["Ravencrest"] = {
					["Horde"] = "Hordepot-Ravencrest",
					["Alliance"] = "Alliancepot-Ravencrest",
				},
				["Draenor"] = {
					["Horde"] = "Hordepot-Draenor",
					["Alliance"] = "Alliancepot-Draenor",
				},
				["Vek'Nilash"] = {
					["Horde"] = "Hordepot-Aeriepeak",
					["Alliance"] = "Alliancepot-Aeriepeak",
				},
				["Deathwing"] = {
					["Horde"] = "Hordepot-Themaelstrom",
					["Alliance"] = "Alliancepot-Themaelstrom",
				},
				["Agamaggan"] = {
					["Horde"] = "Hordepot-Emeriss",
					["Alliance"] = "Alliancepot-Emeriss",
				},
				["Twilight's Hammer"] = {
					["Horde"] = "Hordepot-Emeriss",
					["Alliance"] = "Alliancepot-Emeriss",
				},
				["Aerie Peak"] = {
					["Horde"] = "Hordepot-Aeriepeak",
					["Alliance"] = "Alliancepot-Aeriepeak",
				},
				["Nagrand"] = {
					["Horde"] = "Hordepot-Arathor",
					["Alliance"] = "Alliancepot-Arathor",
				},
				["Vashj"] = {
					["Horde"] = "Hordepot-Stormreaver",
					["Alliance"] = "Alliancepot-Stormreaver",
				},
				["Ragnaros"] = {
					["Horde"] = "Hordepot-Ragnaros",
					["Alliance"] = "Alliancepot-Ragnaros",
				},
				["Boulderfist"] = {
					["Horde"] = "Hordepot-Ahn'qiraj",
					["Alliance"] = "Alliancepot-Ahn'qiraj",
				},
				["Al'Akir"] = {
					["Horde"] = "Hordepot-Al'akir",
					["Alliance"] = "Alliancepot-Al'akir",
				},
				["Auchindoun"] = {
					["Horde"] = "Hordepot-Sylvanas",
					["Alliance"] = "Alliancepot-Sylvanas",
				},
				["Balnazzar"] = {
					["Horde"] = "Hordepot-Ahn'qiraj",
					["Alliance"] = "Alliancepot-Ahn'qiraj",
				},
				["Burning Steppes"] = {
					["Horde"] = "Hordepot-Darkspear",
					["Alliance"] = "Alliancepot-Darkspear",
				},
				["Stormrage"] = {
					["Horde"] = "Hordepot-Stormrage",
					["Alliance"] = "Alliancepot-Stormrage",
				},
				["Quel'Thalas"] = {
					["Horde"] = "Hordepot-Quel'thalas",
					["Alliance"] = "Alliancepot-Quel'thalas",
				},
				["Haomarush"] = {
					["Horde"] = "Hordepot-Stormreaver",
					["Alliance"] = "Alliancepot-Stormreaver",
				},
				["Terenas"] = {
					["Horde"] = "Hordepot-Emeralddream",
					["Alliance"] = "Alliancepot-Emeralddream",
				},
				["Eonar"] = {
					["Horde"] = "Hordepot-Aeriepeak",
					["Alliance"] = "Alliancepot-Aeriepeak",
				},
				["Chamber of Aspects"] = {
					["Horde"] = "Hordepot-Chamberofaspects",
					["Alliance"] = "Alliancepot-Chamberofaspects",
				},
				["Steamwheedle Cartel"] = {
					["Horde"] = "Hordepot-Steamwheedlecartel",
					["Alliance"] = "Alliancepot-Steamwheedlecartel",
				},
				["Neptulon"] = {
					["Horde"] = "Hordepot-Darksorrow",
					["Alliance"] = "Alliancepot-Darksorrow",
				},
				["Thunderhorn"] = {
					["Horde"] = "Hordepot-Thunderhorn",
					["Alliance"] = "Alliancepot-Thunderhorn",
				},
				["Outland"] = {
					["Horde"] = "Hordepot-Outland",
					["Alliance"] = "Alliancepot-Outland",
				},
				["Burning Legion"] = {
					["Horde"] = "Hordepot-Al'akir",
					["Alliance"] = "Alliancepot-Al'akir",
				},
				["Turalyon"] = {
					["Horde"] = "Hordepot-Doomhammer",
					["Alliance"] = "Alliancepot-Doomhammer",
				},
				["Doomhammer"] = {
					["Horde"] = "Hordepot-Doomhammer",
					["Alliance"] = "Alliancepot-Doomhammer",
				},
				["Scarshield Legion"] = {
					["Horde"] = "Hordepot-Defiasbrotherhood",
					["Alliance"] = "Alliancepot-Defiasbrotherhood",
				},
				["Magtheridon"] = {
					["Horde"] = "Hordepot-Magtheridon",
					["Alliance"] = "Alliancepot-Magtheridon",
				},
				["Daggerspine"] = {
					["Horde"] = "Hordepot-Ahn'qiraj",
					["Alliance"] = "Alliancepot-Ahn'qiraj",
				},
				["Azjol-Nerub"] = {
					["Horde"] = "Hordepot-Quel'thalas",
					["Alliance"] = "Alliancepot-Quel'thalas",
				},
				["Crushridge"] = {
					["Horde"] = "Hordepot-Emeriss",
					["Alliance"] = "Alliancepot-Emeriss",
				},
				["Moonglade"] = {
					["Horde"] = "Hordepot-Steamwheedlecartel",
					["Alliance"] = "Alliancepot-Steamwheedlecartel",
				},
				["Spinebreaker"] = {
					["Horde"] = "Hordepot-Stormreaver",
					["Alliance"] = "Alliancepot-Stormreaver",
				},
				["Aggramar"] = {
					["Horde"] = "Hordepot-Aggramar",
					["Alliance"] = "Alliancepot-Aggramar",
				},
				["Genjuros"] = {
					["Horde"] = "Hordepot-Darksorrow",
					["Alliance"] = "Alliancepot-Darksorrow",
				},
				["Saurfang"] = {
					["Horde"] = "Hordepot-Darkspear",
					["Alliance"] = "Alliancepot-Darkspear",
				},
				["Frostwhisper"] = {
					["Horde"] = "Hordepot-Darksorrow",
					["Alliance"] = "Alliancepot-Darksorrow",
				},
				["Shattered Halls"] = {
					["Horde"] = "Hordepot-Ahn'qiraj",
					["Alliance"] = "Alliancepot-Ahn'qiraj",
				},
				["Dentarg"] = {
					["Horde"] = "Hordepot-TarrenMill",
					["Alliance"] = "Alliancepot-TarrenMill",
				},
				["Twisting Nether"] = {
					["Horde"] = "Hordepot-TwistingNether",
					["Alliance"] = "Alliancepot-Twisting Nether",
				},
				["Shadowsong"] = {
					["Horde"] = "Hordepot-Aszune",
					["Alliance"] = "Alliancepot-Aszune",
				},
				["Kazzak"] = {
					["Horde"] = "Hordepot-Kazzak",
					["Alliance"] = "Alliancepot-Kazzak",
				},
				["Sporeggar"] = {
					["Horde"] = "Hordepot-Defiasbrotherhood",
					["Alliance"] = "Alliancepot-Defiasbrotherhood",
				},
				["Bladefist"] = {
					["Horde"] = "Hordepot-Darksorrow",
					["Alliance"] = "Alliancepot-Darksorrow",
				},
				["Bloodhoof"] = {
					["Horde"] = "Hordepot-Khadgar",
					["Alliance"] = "Alliancepot-Khadgar",
				},
				["Dragonmaw"] = {
					["Horde"] = "Hordepot-Stormreaver",
					["Alliance"] = "Alliancepot-Stormreaver",
				},
				["Drak'Thul"] = {
					["Horde"] = "Hordepot-Drak'Thul",
					["Alliance"] = "Alliancepot-Drak'Thul",
				},
				["Dunemaul"] = {
					["Horde"] = "Hordepot-Sylvanas",
					["Alliance"] = "Alliancepot-Sylvanas",
				},
				["Defias Brotherhood"] = {
					["Horde"] = "Hordepot-Defiasbrotherhood",
					["Alliance"] = "Alliancepot-Defiasbrotherhood",
				},
				["Bloodscalp"] = {
					["Horde"] = "Hordepot-Emeriss",
					["Alliance"] = "Alliancepot-Emeriss",
				},
				["Tarren Mill"] = {
					["Horde"] = "Hordepot-TarrenMill",
					["Alliance"] = "Alliancepot-TarrenMill",
				},
				["Burning Blade"] = {
					["Horde"] = "Hordepot-Drak'Thul",
					["Alliance"] = "Alliancepot-Drak'Thul",
				},
				["Laughing Skull"] = {
					["Horde"] = "Hordepot-Ahn'qiraj",
					["Alliance"] = "Alliancepot-Ahn'qiraj",
				},
				["Lightbringer"] = {
					["Horde"] = "Hordepot-Lightbringer",
					["Alliance"] = "Alliancepot-Lightbringer",
				},
				["Dragonblight"] = {
					["Horde"] = "Hordepot-Themaelstrom",
					["Alliance"] = "Alliancepot-Themaelstrom",
				},
				["Frostmane"] = {
					["Horde"] = "Hordepot-Frostmane",
					["Alliance"] = "Alliancepot-Frostmane",
				},
				["Emerald Dream"] = {
					["Horde"] = "Hordepot-Emeralddream",
					["Alliance"] = "Alliancepot-Emeralddream",
				},
				["Kor'gall"] = {
					["Horde"] = "Hordepot-Darkspear",
					["Alliance"] = "Alliancepot-Darkspear",
				},
				["The Sha'Tar"] = {
					["Horde"] = "Hordepot-Steamwheedlecartel",
					["Alliance"] = "Alliancepot-Steamwheedlecartel",
				},
				["Mazrigos"] = {
					["Horde"] = "Hordepot-Lightbringer",
					["Alliance"] = "Alliancepot-Lightbringer",
				},
				["Talnivarr"] = {
					["Horde"] = "Hordepot-Ahn'qiraj",
					["Alliance"] = "Alliancepot-Ahn'qiraj",
				},
				["Wildhammer"] = {
					["Horde"] = "Hordepot-Thunderhorn",
					["Alliance"] = "Alliancepot-Thunderhorn",
				},
				["Sylvanas"] = {
					["Horde"] = "Hordepot-Sylvanas",
					["Alliance"] = "Alliancepot-Sylvanas",
				},
				["The Maelstrom"] = {
					["Horde"] = "Hordepot-Themaelstrom",
					["Alliance"] = "Alliancepot-Themaelstrom",
				},
				["Hellfire"] = {
					["Horde"] = "Hordepot-Arathor",
					["Alliance"] = "Alliancepot-Arathor",
				},
				["Azuremyst"] = {
					["Horde"] = "Hordepot-Stormrage",
					["Alliance"] = "Alliancepot-Stormrage",
				},
				["Darkmoon Faire"] = {
					["Horde"] = "Hordepot-Defiasbrotherhood",
					["Alliance"] = "Alliancepot-Defiasbrotherhood",
				},
				["Zenedar"] = {
					["Horde"] = "Hordepot-Darksorrow",
					["Alliance"] = "Alliancepot-Darksorrow",
				},
				["Ghostlands"] = {
					["Horde"] = "Hordepot-Themaelstrom",
					["Alliance"] = "Alliancepot-Themaelstrom",
				},
				["Blade's Edge"] = {
					["Horde"] = "Hordepot-Aeriepeak",
					["Alliance"] = "Alliancepot-Aeriepeak",
				},
				["Bronze Dragonflight"] = {
					["Horde"] = "Hordepot-Nordrassil",
					["Alliance"] = "Alliancepot-Nordrassil",
				},
				["Hellscream"] = {
					["Horde"] = "Hordepot-Aggramar",
					["Alliance"] = "Alliancepot-Aggramar",
				},
				["Stormscale"] = {
					["Horde"] = "Hordepot-Stormscale",
					["Alliance"] = "Alliancepot-Stormscale",
				},
				["Khadgar"] = {
					["Horde"] = "Hordepot-Khadgar",
					["Alliance"] = "Alliancepot-Khadgar",
				},
				["Bronzebeard"] = {
					["Horde"] = "Hordepot-Aeriepeak",
					["Alliance"] = "Alliancepot-Aeriepeak",
				},
				["Arathor"] = {
					["Horde"] = "Hordepot-Arathor",
					["Alliance"] = "Alliancepot-Arathor",
				},
				["Bloodfeather"] = {
					["Horde"] = "Hordepot-Darkspear",
					["Alliance"] = "Alliancepot-Darkspear",
				},
				["Executus"] = {
					["Horde"] = "Hordepot-Darkspear",
					["Alliance"] = "Alliancepot-Darkspear",
				},
				["Hakkar"] = {
					["Horde"] = "Hordepot-Emeriss",
					["Alliance"] = "Alliancepot-Emeriss",
				},
				["Kul Tiras"] = {
					["Horde"] = "Hordepot-Alonsus",
					["Alliance"] = "Alliancepot-Alonsus",
				},
				["Lightning's Blade"] = {
					["Horde"] = "Hordepot-Themaelstrom",
					["Alliance"] = "Alliancepot-Themaelstrom",
				},
				["Sunstrider"] = {
					["Horde"] = "Hordepot-Ahn'qiraj",
					["Alliance"] = "Alliancepot-Ahn'qiraj",
				},
				["Earthen Ring"] = {
					["Horde"] = "Hordepot-Defiasbrotherhood",
					["Alliance"] = "Alliancepot-Defiasbrotherhood",
				},
				["Emeriss"] = {
					["Horde"] = "Hordepot-Emeriss",
					["Alliance"] = "Alliancepot-Emeriss",
				},
				["Trollbane"] = {
					["Horde"] = "Hordepot-Ahn'qiraj",
					["Alliance"] = "Alliancepot-Ahn'qiraj",
				},
				["Grim Batol"] = {
					["Horde"] = "Hordepot-Frostmane",
					["Alliance"] = "Alliancepot-Frostmane",
				},
				["Stormreaver"] = {
					["Horde"] = "Hordepot-Stormreaver",
					["Alliance"] = "Alliancepot-Stormreaver",
				},
				["Karazhan"] = {
					["Horde"] = "Hordepot-Themaelstrom",
					["Alliance"] = "Alliancepot-Themaelstrom",
				},
				["Ravenholdt"] = {
					["Horde"] = "Hordepot-Defiasbrotherhood",
					["Alliance"] = "Alliancepot-Defiasbrotherhood",
				},
				["Shattered Hand"] = {
					["Horde"] = "Hordepot-Darkspear",
					["Alliance"] = "Alliancepot-Darkspear",
				},
				["Chromaggus"] = {
					["Horde"] = "Hordepot-Ahn'qiraj",
					["Alliance"] = "Alliancepot-Ahn'qiraj",
				},
				["ArgentDawn"] = {
					["Horde"] = "Hordepot-Argentdawn",
					["Alliance"] = "Alliancepot-Argentdawn",
				},
			},
		},
	}
}

local function BuildBankingOptionsArgs(arg_table, options)
	for profile,_ in pairs(options) do
		--print(profile)
		if profile ~= "" and profile:find("Profile ") ~= nil then
			arg_table[profile] = {
				type = 'group',
				name = profile,
				args = {}
			}
			
			for realmRegion,_ in pairs(options[profile]) do
				--print(realmRegion)
				if realmRegion ~= "" then
					arg_table[profile].args[realmRegion] = {
						type = 'group',
						name = realmRegion,
						args = {}
					}
					
					for realmName,_ in pairs(options[profile][realmRegion]) do
						--print(realmName)
						arg_table[profile].args[realmRegion].args[realmName] = {
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
	if #info == 5 then
		if novaOptions [info[#info-4]] == nil then novaOptions [info[#info-4]] = {}	end
		if novaOptions [info[#info-4]] [info[#info-3]] == nil then novaOptions [info[#info-4]] [info[#info-3]] = {}	end
		if novaOptions [info[#info-4]] [info[#info-3]] [info[#info-2]] == nil then novaOptions [info[#info-4]] [info[#info-3]] [info[#info-2]] = {}	end
		if novaOptions [info[#info-4]] [info[#info-3]] [info[#info-2]] [info[#info-1]] == nil then novaOptions [info[#info-4]] [info[#info-3]] [info[#info-2]] [info[#info-1]] = {} end
		
		opt = novaOptions [info[#info-4]] [info[#info-3]] [info[#info-2]] [info[#info-1]] [info[#info]]
		optname=info[#info-4].."."..info[#info-3].."."..info[#info-2].."."..info[#info-1].."."..info[#info]
		
	elseif #info == 4 then
		if novaOptions [info[#info-3]] == nil then novaOptions [info[#info-3]] = {}	end
		if novaOptions [info[#info-3]] [info[#info-2]] == nil then novaOptions [info[#info-3]] [info[#info-2]] = {}	end
		if novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] == nil then novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] = {} end
		
		opt = novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] [info[#info]]
		optname=info[#info-3].."."..info[#info-2].."."..info[#info-1].."."..info[#info]
	
	elseif #info == 3 then
		if novaOptions [info[#info-2]] == nil then novaOptions [info[#info-2]] = {}	end
		if novaOptions [info[#info-2]] [info[#info-1]] == nil then novaOptions [info[#info-2]] [info[#info-1]] = {} end
		
		opt = novaOptions [info[#info-2]] [info[#info-1]] [info[#info]]
		optname=info[#info-2].."."..info[#info-1].."."..info[#info]
		
		
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
	--print(value)
	if #info == 5 then
		if novaOptions [info[#info-4]] == nil then novaOptions [info[#info-4]] = {}	end
		if novaOptions [info[#info-4]] [info[#info-3]] == nil then novaOptions [info[#info-4]] [info[#info-3]] = {}	end
		if novaOptions [info[#info-4]] [info[#info-3]] [info[#info-2]] == nil then novaOptions [info[#info-4]] [info[#info-3]] [info[#info-2]] = {}	end
		if novaOptions [info[#info-4]] [info[#info-3]] [info[#info-2]] [info[#info-1]] == nil then novaOptions [info[#info-4]] [info[#info-3]] [info[#info-2]] [info[#info-1]] = {} end
		
		novaOptions [info[#info-4]] [info[#info-3]] [info[#info-2]] [info[#info-1]] [info[#info]] = value
		
	elseif #info == 4 then
		if novaOptions [info[#info-3]] == nil then novaOptions [info[#info-3]] = {}	end
		if novaOptions [info[#info-3]] [info[#info-2]] == nil then novaOptions [info[#info-3]] [info[#info-2]] = {}	end
		if novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] == nil then novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] = {} end
		
		novaOptions [info[#info-3]] [info[#info-2]] [info[#info-1]] [info[#info]] = value
		
	elseif #info == 3 then
		if novaOptions [info[#info-2]] == nil then novaOptions [info[#info-2]] = {}	end
		if novaOptions [info[#info-2]] [info[#info-1]] == nil then novaOptions [info[#info-2]] [info[#info-1]] = {} end
		
		novaOptions [info[#info-2]] [info[#info-1]] [info[#info]] = value
		
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
	
	if info[#info-2] == "Banking" then
		--print(info[#info-2])
		--print(info[#info-1])
		--print(info[#info])
		
		if novaOptions [info[#info-2]] [info[#info-1]].Profile_A == true and info[#info] == "Profile_A" then
			--print("here1")
			novaOptions [info[#info-2]] [info[#info-1]].Profile_B = false
		end
		if novaOptions [info[#info-2]] [info[#info-1]].Profile_A == false and info[#info] == "Profile_A" then
			--print("here2")
			novaOptions [info[#info-2]] [info[#info-1]].Profile_B = true
		end
		if novaOptions [info[#info-2]] [info[#info-1]].Profile_B == true and info[#info] == "Profile_B" then
			--print("here3")
			novaOptions [info[#info-2]] [info[#info-1]].Profile_A = false
		end
		if novaOptions [info[#info-2]] [info[#info-1]].Profile_B == false and info[#info] == "Profile_B" then
			--print("here4")
			novaOptions [info[#info-2]] [info[#info-1]].Profile_A = true
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
	
	local bankingProfile = "Profile A"
	
	if novaOptions.Banking.Profiles.Profile_A == true then
		bankingProfile = "Profile A"
	end
	if novaOptions.Banking.Profiles.Profile_B == true then
		bankingProfile = "Profile B"
	end
	
	local currentRealm,_ = string.gsub(GetRealmName(), "%s+", "")

	for serverRegion,_ in pairs(novaOptions.Banking[bankingProfile]) do
		for serverName,bankingChar in pairs(novaOptions.Banking[bankingProfile][serverRegion]) do
			
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
------------------------------------- IMPORT BANKING CHARACTERS -------------------------------------
-----------------------------------------------------------------------------------------------------

function importBankingCharacters(row)
	------------------------
	-- Main Frame
	local ibcFrame = AceGUI:Create("Frame")
	ibcFrame:SetWidth(350)
	ibcFrame:SetHeight(670)
	ibcFrame:SetTitle("Import Banking Characters")
	ibcFrame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	
	------------------------
	-- Profile
	local ibcGroupProfile = AceGUI:Create("InlineGroup")
	
	local ibcLabelProfile = AceGUI:Create("Label")
	ibcLabelProfile:SetText("Banking Profile")
	ibcLabelProfile:SetFont("GameFontNormalSmall",100,OUTLINE)
	ibcLabelProfile:SetColor(1, 0.8, 0)
	ibcLabelProfile:SetHeight(15)
	
	local ibcCheckboxProfileA = AceGUI:Create("CheckBox")
	ibcCheckboxProfileA:SetType("radio")
	ibcCheckboxProfileA:SetLabel("Profile A")
	ibcCheckboxProfileA:SetValue(true)
	ibcCheckboxProfileA:SetHeight(15)
	ibcCheckboxProfileA:SetWidth(80)
	
	local ibcCheckboxProfileB= AceGUI:Create("CheckBox")
	ibcCheckboxProfileB:SetType("radio")
	ibcCheckboxProfileB:SetLabel("Profile B")
	ibcCheckboxProfileB:SetValue(false)
	ibcCheckboxProfileB:SetHeight(15)
	ibcCheckboxProfileB:SetWidth(80)
	
	local profileSelected = "Profile A"
	
	ibcCheckboxProfileA:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then
			ibcCheckboxProfileB:SetValue(false)
			profileSelected = "Profile A"
		end
	end )
	
	ibcCheckboxProfileB:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then
			ibcCheckboxProfileA:SetValue(false)
			profileSelected = "Profile B"
		end
	end )
	
	ibcGroupProfile:SetLayout("Flow")
	ibcGroupProfile:AddChild(ibcLabelProfile)
	ibcGroupProfile:AddChild(ibcCheckboxProfileA)
	ibcGroupProfile:AddChild(ibcCheckboxProfileB)
	
	------------------------
	-- Faction
	local ibcGroupFaction = AceGUI:Create("InlineGroup")
	
	local ibcLabelFaction = AceGUI:Create("Label")
	ibcLabelFaction:SetText("Faction")
	ibcLabelFaction:SetFont("GameFontNormalSmall",100,OUTLINE)
	ibcLabelFaction:SetColor(1, 0.8, 0)
	ibcLabelFaction:SetHeight(15)
	
	local ibcCheckboxAlliance = AceGUI:Create("CheckBox")
	ibcCheckboxAlliance:SetType("radio")
	ibcCheckboxAlliance:SetLabel("Alliance")
	ibcCheckboxAlliance:SetValue(true)
	ibcCheckboxAlliance:SetHeight(15)
	ibcCheckboxAlliance:SetWidth(80)
	
	local ibcCheckboxHorde = AceGUI:Create("CheckBox")
	ibcCheckboxHorde:SetType("radio")
	ibcCheckboxHorde:SetLabel("Horde")
	ibcCheckboxHorde:SetValue(false)
	ibcCheckboxHorde:SetHeight(15)
	ibcCheckboxHorde:SetWidth(80)
	
	local factionSelected = "Alliance"
	
	ibcCheckboxAlliance:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then
			ibcCheckboxHorde:SetValue(false)
			factionSelected = "Alliance"
		end
	end )
	
	ibcCheckboxHorde:SetCallback("OnValueChanged",function(widget,event,value)
		if value == true then
			ibcCheckboxAlliance:SetValue(false)
			factionSelected = "Horde"
		end
	end )
	
	ibcGroupFaction:SetLayout("Flow")
	ibcGroupFaction:AddChild(ibcLabelFaction)
	ibcGroupFaction:AddChild(ibcCheckboxAlliance)
	ibcGroupFaction:AddChild(ibcCheckboxHorde)
	
	------------------------
	-- Textbox
	local ibcGroupInput = AceGUI:Create("InlineGroup")
	
	local ibcLabelInput = AceGUI:Create("Label")
	ibcLabelInput:SetText("Input Banking Charachters")
	ibcLabelInput:SetFont("GameFontNormalSmall",100,OUTLINE)
	ibcLabelInput:SetColor(1, 0.8, 0)
	ibcLabelInput:SetHeight(15)
	
	local ibcMEditboxInput = AceGUI:Create("MultiLineEditBox")
	ibcMEditboxInput:SetMaxLetters(0)
	--ibcMEditboxInput:SetFocus()
	ibcMEditboxInput:SetWidth(280)
	ibcMEditboxInput:SetHeight(350)
	
	ibcGroupInput:AddChild(ibcLabelInput)
	ibcGroupInput:AddChild(ibcMEditboxInput)
	
	------------------------
	-- Import Button
	local ibcButtonImport = AceGUI:Create("Button")
	ibcButtonImport:SetText("Import")
	ibcButtonImport:SetWidth(300)
	ibcButtonImport:SetCallback("OnClick", function()
		
		print("Import started...")
		
		local newBankingChars = mysplit(ibcMEditboxInput:GetText(), "\r\n")
		
		for serverRegion,_ in pairs(novaOptions.Banking[profileSelected]) do
			for serverName,bankingChar in pairs(novaOptions.Banking[profileSelected][serverRegion]) do
				
				for _,newBankingChar in pairs(newBankingChars) do

					local serverNameOldBanking = mysplit(bankingChar[factionSelected], "-")
					local serverNameNewBanking = mysplit(newBankingChar, "-")
					
					if serverNameOldBanking[2]:lower() == serverNameNewBanking[2]:lower() then
						novaOptions.Banking[profileSelected][serverRegion][serverName][factionSelected] = newBankingChar
					end
				
				end
				
			end
		end
		
		print("Import finished...")
		
	end)
	
	ibcFrame:AddChild(ibcGroupProfile)
	ibcFrame:AddChild(ibcGroupFaction)
	ibcFrame:AddChild(ibcGroupInput)
	ibcFrame:AddChild(ibcButtonImport)
	

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
		
		]]
		
		if novaOptions.General.Version == 5 then
			novaOptions.Banking = myDefaultOptions.Banking
		end
		
		novaOptions.General.Version = 6
		
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
	if strlower(input)=="help" then
		print("/nb : Opens the NovaBooking History window")
		print("/nb add : Opens the Add Client window")
		print("/nb banking : Opens the Import Banking Characters window")
	end
	if strlower(input)=="add" then
		addEditClientToHistory(0)
	end
	if strlower(input)=="banking" then
		importBankingCharacters(0)
	end
end


