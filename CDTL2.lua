--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
	
	Update notes:
		- Almost complete re-write, see changelog in game for details
]]--

CDTL2 = LibStub("AceAddon-3.0"):NewAddon("CDTL2", "AceConsole-3.0", "AceEvent-3.0")
CDTL2.Masque = LibStub("Masque", true)
CDTL2.LSM = LibStub("LibSharedMedia-3.0")
CDTL2.GUI = LibStub("AceGUI-3.0")

local _, _, _, tocversion = GetBuildInfo()
CDTL2.tocversion = tocversion

-- Cached local reference for secret value checking (performance optimization)
-- Avoids global lookup + method dispatch on every call in hot loops
local _issecretvalue = issecretvalue
local function isSecret(value)
	return _issecretvalue ~= nil and _issecretvalue(value)
end


CDTL2.version = "3.0"
CDTL2.noticeVersion = "3.0"
CDTL2.cdUID = 999
CDTL2.discordlink = "https://discord.gg/4s6xUSq3qQ"
CDTL2.lanes = {}
CDTL2.barFrames = {}
CDTL2.readyFrames = {}
CDTL2.holders = {}
CDTL2.offensives = {}
CDTL2.player = {}
CDTL2.cooldowns = {}
CDTL2.spellbook = {}
CDTL2.testing = false
CDTL2.tracking = {
	mhSwingTime = -1,
	ohSwingTime = -1,
	rSwingTime = -1,
}
CDTL2.spellData = {}
CDTL2.icdData = {}
CDTL2.colors = {
	bg = {},
	db = { r = 0.1, g = 0.1, b = 0.1, a = 0.85 },
}
CDTL2.custom = {}
CDTL2.detected = {}
CDTL2.combat = false
CDTL2.enabled = false
local private = {}

local defaults = {
    profile = {
		global = {
			firstRun = true,
			previousVersion = 0,

			unlockFrames = true,
			debugMode = false,

			customDetection = false,
			customDetectAll = false,

			autohide = false,
			enableTooltip = false,
			zoom = 1,
			
			detectSharedCD = false,
			hideIgnored = true,
			
			notUsableTint = false,
			notUsableDesaturate = false,
			notUsableColor = { r = 0.75, g = 0.1, b = 0.1, a = 1 },
			
			enabledAlways = true,
			enabledGroup = false,
			enabledInstance = false,

			dynamicSpellDetection = false,
			
			exportMode = "SETTINGS",
			importMode = "SETTINGS",

			testingLoop = false,
			testingNumber = 10,
			testingType = "spells",
			testingMinTime = 10,
			testingMaxTime = 180,

			classColors = {
				DEATHKNIGHT = 	{ r = 0.77, g = 0.12, b = 0.23, a = 1 }, 	-- Red
				DEMONHUNTER = 	{ r = 0.64, g = 0.19, b = 0.79, a = 1 }, 	-- Dark Magenta
				DRUID = 		{ r = 1, g = 0.49, b = 0.04, a = 1 }, 		-- Orange
				EVOKER = 		{ r = 0.2, g = 0.58, b = 0.5, a = 1 }, 		-- Dark Emerald
				HUNTER = 		{ r = 0.67, g = 0.83, b = 0.45, a = 1 }, 	-- Pistachio
				MAGE = 			{ r = 0.25, g = 0.78, b = 0.92, a = 1 }, 	-- Light Blue
				MONK = 			{ r = 0, g = 1, b = 0.6, a = 1 }, 			-- Spring Green
				PALADIN = 		{ r = 0.96, g = 0.55, b = 0.73, a = 1 }, 	-- Pink
				PRIEST = 		{ r = 1, g = 1, b = 1, a = 1 }, 			-- White
				ROGUE = 		{ r = 1, g = 0.96, b = 0.41, a = 1 }, 		-- Yellow
				SHAMAN = 		{ r = 0, g = 0.44, b = 0.87, a = 1 }, 		-- Blue
				WARLOCK = 		{ r = 0.53, g = 0.53, b = 0.93, a = 1 }, 	-- Purple
				WARRIOR = 		{ r = 0.78, g = 0.61, b = 0.43, a = 1 }, 	-- Tan
			},
			
			schoolColors = {
				Physical = { r = 1, g = 1, b = 0, a = 1 },
				Holy = { r = 1, g = 0.90196, b = 0.5, a = 1 },
				Fire = { r = 1, g = 0.5, b = 0, a = 1 },
				Nature = { r = 0.30196, g = 1, b = 0.30196, a = 1 },
				Frost = { r = 0.5, g = 1, b = 1, a = 1 },
				Shadow = { r = 0.5, g = 0.5, b = 1, a = 1 },
				Arcane = { r = 1, g = 0.5, b = 1, a = 1 },
				Other = { r = 0.8, g = 0.8, b = 0.8, a = 1 },
			},
			
			spells = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 3600,
				defaultLane = 1,
				defaultReady = 1,
				defaultBar = 1,
			},
			
			items = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 3600,
				defaultLane = 1,
				defaultReady = 1,
				defaultBar = 1,
				useItemIcon = true,
			},
			
			buffs = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 120,
				defaultLane = 2,
				defaultReady = 2,
				defaultBar = 2,
				onlyPlayer = true,
			},
			
			debuffs = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 300,
				defaultLane = 3,
				defaultReady = 3,
				defaultBar = 3,
				onlyPlayer = true,
			},
			
			offensives = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 600,
				defaultLane = 0,
				defaultReady = 0,
				defaultBar = 0,
			},
			
			petspells = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 3600,
				defaultLane = 1,
				defaultReady = 1,
				defaultBar = 1,
			},

			runes = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 3600,
				defaultLane = 1,
				defaultReady = 1,
				defaultBar = 1,
			},
			customs = {
				enabled = true,
				showByDefault = true,
				ignoreThreshold = 3600,
				defaultLane = 1,
				defaultReady = 1,
				defaultBar = 1,
			},
		},
	
		lanes = {
			global = {
				fgTexture = "CDTL2 Smooth",
				fgTextureColor = { r = 0.77647, g = 0.11765, b = 0.28235, a = 1 },
				fgClassColor = true,
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				bgClassColor = false,
			},
			lane1 = {
				enabled = true,
				name = "Lane 1",
				reversed = false,
				vertical = false,
				
				posX = 0,
				posY = -250,
				width = 400,
				height = 44,
				relativeTo = "CENTER",
				alpha = 1,
				
				iconOffset = 0,
				
				tracking = {
					primaryTracking = "NONE",
					secondaryTracking = "GCD",
					
					overrideAutohide = false,
					
					primaryReversed = false,
					secondaryReversed = false,
					
					stTexture = "CDTL2 Smooth",
					stTextureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					stWidth = 5,
					stHeight = 44,
				},
				
				stacking = {
					enabled = false,
					raiseOnMouseOver = false,
					style = "GROUPED",
					grow = "UP",
					height = 80,
				},
				
				fgTexture = "CDTL2 Smooth",
				fgTextureColor = { r = 0.77647, g = 0.11765, b = 0.28235, a = 1 },
				fgClassColor = true,
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				bgClassColor = false,
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 40,
					hlStyle = "NONE",
					timeFormat = "H:MM:SS.MS",
					
					alpha = 1,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 1 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 1 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 11,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "TOPLEFT",
						offX = 2,
						offY = -7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 16,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "",
						font = "Fira Sans Condensed",
						size = 11,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOM",
						offX = 2,
						offY = 5,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				
				mode = {
					type = "LINEAR",
					linear = {
						max = 120,
						hideTimeSurplus = true,
					},
					linearAbs = {
						max = 120,
						hideTimeSurplus = true,
						timeFormat = "XhYmZs",
					},
					split = {
						max = 120,
						hideTimeSurplus = true,
						count = 2,
						s1v = 10,
						s1p = 0.33,
						s2v = 33,
						s2p = 0.66,
						s3v = 66,
						s3p = 0.75,
					},
					splitAbs = {
						max = 120,
						hideTimeSurplus = true,
						timeFormat = "XhYmZs",
						count = 3,
						s1v = 10,
						s1p = 0.25,
						s2v = 30,
						s2p = 0.5,
						s3v = 60,
						s3p = 0.75,
					},
				},
				
				modeText = {
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						text = "T1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						pos = 0,
						offX = 5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						text = "T2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.25,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						text = "T3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.5,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = true,
						used = true,
						text = "T4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.75,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = true,
						used = true,
						text = "T5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "LEFT",
						pos = 1,
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				customText = {				
					text1 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
			lane2 = {
				enabled = true,
				name = "Lane 2",
				reversed = false,
				vertical = false,
				
				posX = 0,
				posY = -200,
				width = 400,
				height = 5,
				relativeTo = "CENTER",
				alpha = 1,
				
				iconOffset = 0,
				
				tracking = {
					primaryTracking = "NONE",
					secondaryTracking = "NONE",
					
					overrideAutohide = false,
					
					primaryReversed = false,
					secondaryReversed = false,
					
					stTexture = "CDTL2 Smooth",
					stTextureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					stHeight = 30,
					stWidth = 5,
				},
				
				stacking = {
					enabled = false,
					raiseOnMouseOver = false,
					style = "GROUPED",
					grow = "UP",
					height = 80,
				},
				
				fgTexture = "CDTL2 Smooth",
				fgTextureColor = { r = 0.52941, g = 0.77647, b = 0.24314, a = 1 },
				fgClassColor = true,
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				bgClassColor = false,
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 30,
					hlStyle = "NONE",
					timeFormat = "H:MM:SS.MS",
					
					alpha = 1,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 1 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 0.25 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "TOPLEFT",
						offX = 0,
						offY = -5,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 13,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "BOTTOMRIGHT",
						offX = 0,
						offY = 5,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				
				mode = {
					type = "LINEAR",
					linear = {
						max = 120,
						hideTimeSurplus = true,
					},
					linearAbs = {
						max = 120,
						hideTimeSurplus = true,
					},
					split = {
						max = 120,
						hideTimeSurplus = true,
						count = 3,
						s1v = 10,
						s1p = 0.25,
						s2v = 25,
						s2p = 0.5,
						s3v = 50,
						s3p = 0.75,
					},
					splitAbs = {
						count = 3,
						s1v = 10,
						s1p = 0.25,
						s2v = 30,
						s2p = 0.5,
						s3v = 60,
						s3p = 0.75,
						max = 120,
						hideTimeSurplus = true,
					},
				},
				
				modeText = {
					text1 = {
						enabled = false,
						used = true,
						text = "T1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						pos = 0,
						offX = 5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = false,
						used = true,
						text = "T2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.25,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						text = "T3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.5,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = false,
						used = true,
						text = "T4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.75,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = false,
						used = true,
						text = "T5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "LEFT",
						pos = 1,
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				customText = {				
					text1 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
			lane3 = {
				enabled = true,
				name = "Lane 3",
				reversed = false,
				vertical = false,
				
				posX = 0,
				posY = -160,
				width = 400,
				height = 5,
				relativeTo = "CENTER",
				alpha = 1,
				
				iconOffset = 0,
				
				tracking = {
					primaryTracking = "NONE",
					secondaryTracking = "NONE",
					
					overrideAutohide = false,
					
					primaryReversed = false,
					secondaryReversed = false,
					
					stTexture = "CDTL2 Smooth",
					stTextureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					stHeight = 20,
					stWidth = 5,
				},
				
				stacking = {
					enabled = false,
					raiseOnMouseOver = false,
					style = "GROUPED",
					grow = "UP",
					height = 80,
				},
				
				fgTexture = "CDTL2 Smooth",
				fgTextureColor = { r = 0.15294, g = 0.63922, b = 0.77647, a = 1 },
				fgClassColor = true,
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				bgClassColor = false,
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 30,
					hlStyle = "NONE",
					timeFormat = "H:MM:SS.MS",
					
					alpha = 1,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 1 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 0.25 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "TOPLEFT",
						offX = 0,
						offY = -3,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 13,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMRIGHT",
						offX = -10,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				
				mode = {
					type = "LINEAR",
					linear = {
						max = 120,
						hideTimeSurplus = true,						
					},
					linearAbs = {
						max = 120,
						hideTimeSurplus = true,
					},
					split = {
						max = 120,
						hideTimeSurplus = true,
						count = 3,
						s1v = 5,
						s1p = 0.25,
						s2v = 25,
						s2p = 0.5,
						s3v = 50,
						s3p = 0.75,
					},
					splitAbs = {
						count = 3,
						s1v = 10,
						s1p = 0.25,
						s2v = 30,
						s2p = 0.5,
						s3v = 60,
						s3p = 0.75,
						max = 120,
						hideTimeSurplus = true,
					},
				},
				
				modeText = {
					text1 = {
						enabled = false,
						used = true,
						text = "T1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						pos = 0,
						offX = 5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = false,
						used = true,
						text = "T2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.25,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						text = "T3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.5,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = false,
						used = true,
						text = "T4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						pos = 0.75,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = false,
						used = true,
						text = "T5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "LEFT",
						pos = 1,
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
				customText = {				
					text1 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 1",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 2",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "TOPRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 3",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text4 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 4",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMLEFT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
					text5 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "Custom Text 5",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOMRIGHT",
						pos = 0,
						offX = 0,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 1 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
		},
		
		barFrames = {
			frame1 = {
				enabled = true,
				name = "Bar Frame 1",
				grow = "UP",
				horizontal = false,
				sorting = "DESCENDING",
				padding = 0,
				
				posX = -300,
				posY = 0,
				width = 180,
				height = 25,
				relativeTo = "CENTER",
				alpha = 1,
				
				transition = {
					hideTransitioned = true,
					
					showTI = true,
					style = "LINE",
					
					texture = "CDTL2 Smooth",
					textureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					width = 5,
				},
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				bar = {
					iconEnabled = true,
					iconPosition = "LEFT",
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
				
					fgTexture = "CDTL2 Smooth",
					fgTextureColor = { r = 0.77647, g = 0.11765, b = 0.28235, a = 1 },	
					fgClassColor = false,
					fgSchoolColor = false,
					bgTexture = "CDTL2 Smooth",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					bgClassColor = false,
					bgSchoolColor = false,
					
					border = {
						style = "None",
						color = { r = 1, g = 1, b = 1, a = 0.25 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						offX = 14,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 0,
						shadY = 0,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						offX = 30,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "RIGHT",
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				}
			},
			frame2 = {
				enabled = true,
				name = "Bar Frame 2",
				grow = "UP",
				horizontal = false,
				padding = 0,
				
				posX = 300,
				posY = 0,
				width = 180,
				height = 25,
				relativeTo = "CENTER",
				alpha = 1,
				
				transition = {
					hideTransitioned = true,
					
					showTI = true,
					style = "LINE",
					
					texture = "CDTL2 Smooth",
					textureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					width = 5,
				},
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				bar = {
					iconEnabled = true,
					iconPosition = "LEFT",
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
				
					fgTexture = "CDTL2 Smooth",
					fgTextureColor = { r = 0.52941, g = 0.77647, b = 0.24314, a = 1 },	
					fgClassColor = false,
					fgSchoolColor = false,
					bgTexture = "CDTL2 Smooth",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					bgClassColor = false,
					bgSchoolColor = false,
					
					border = {
						style = "None",
						color = { r = 1, g = 1, b = 1, a = 0.25 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						offX = 14,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 0,
						shadY = 0,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						offX = 30,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "RIGHT",
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				}
			},
			frame3 = {
				enabled = true,
				name = "Bar Frame 3",
				grow = "UP",
				horizontal = false,
				padding = 0,
				
				posX = 0,
				posY = 175,
				width = 180,
				height = 25,
				relativeTo = "CENTER",
				alpha = 1,
				
				transition = {
					hideTransitioned = true,
					
					showTI = true,
					style = "LINE",
					
					texture = "CDTL2 Smooth",
					textureColor = { r = 1, g = 1, b = 1, a = 0.5 },
					
					width = 5,
				},
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				bar = {
					iconEnabled = true,
					iconPosition = "LEFT",
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
				
					fgTexture = "CDTL2 Smooth",
					fgTextureColor = { r = 0.15294, g = 0.63922, b = 0.77647, a = 1 },
					fgClassColor = false,
					fgSchoolColor = false,
					bgTexture = "CDTL2 Smooth",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					bgClassColor = false,
					bgSchoolColor = false,
					
					border = {
						style = "None",
						color = { r = 1, g = 1, b = 1, a = 0.25 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = true,
						ttags = false,
						text = "[cd.stacks]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "LEFT",
						offX = 14,
						offY = 0,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 0,
						shadY = 0,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "LEFT",
						anchor = "LEFT",
						offX = 30,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = true,
						text = "[cd.time]",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "RIGHT",
						anchor = "RIGHT",
						offX = -5,
						offY = 0,
						outline = "NONE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				}
			},
		},
		
		ready = {
			ready1 = {
				enabled = true,
				name = "Ready 1",
				grow = "DOWN",
				padding = 0,
				
				nTime = 5,
				nSound = "CDTL2 Click",
				hTime = 10,
				hSound = "None",
				pTime = 10,
			
				posX = -300,
				posY = -75,
				relativeTo = "CENTER",
				alpha = 1,
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 50,
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 0.25 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 0.25 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name.s]",
						font = "Fira Sans Condensed",
						size = 18,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "READY",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = -7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.type]",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOM",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
			ready2 = {
				enabled = true,
				name = "Ready 2",
				grow = "DOWN",
				padding = 0,
				
				nTime = 5,
				nSound = "CDTL2 Tinks",
				hTime = 10,
				hSound = "None",
				pTime = 10,
			
				posX = 300,
				posY = -75,
				relativeTo = "CENTER",
				alpha = 1,
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 50,
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 1 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 0.25 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name.s]",
						font = "Fira Sans Condensed",
						size = 18,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "READY",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = -7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.type]",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOM",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
			ready3 = {
				enabled = true,
				name = "Ready 3",
				grow = "CENTER_H",
				padding = 0,
				
				nTime = 5,
				nSound = "CDTL2 Tinks",
				hTime = 10,
				hSound = "None",
				pTime = 10,
			
				posX = 0,
				posY = 100,
				relativeTo = "CENTER",
				alpha = 1,
				
				bgTexture = "CDTL2 Smooth",
				bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
				
				border = {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				},
				
				icons = {
					size = 50,
					
					alpha = 1,
					
					xPadding = 0,
					yPadding = 0,
					
					bgTexture = "CDTL2 Icon Shadow",
					bgTextureColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.5 },
					
					border = {
						style = "None",
						color = { r = 0, g = 0, b = 0, a = 1 },
						size = 5,
						padding = 5,
						inset = 0,
					},
					
					highlight = {
						style = "BORDER",
						
						border = {
							style = "None",
							color = { r = 1, g = 1, b = 1, a = 0.25 },
							size = 5,
							padding = 5,
							inset = 0,
							flash = false,
						},
					},
					
					text1 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.name.s]",
						font = "Fira Sans Condensed",
						size = 18,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text2 = {
						enabled = true,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "READY",
						font = "Fira Sans Condensed",
						size = 12,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "CENTER",
						offX = 0,
						offY = -7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
					text3 = {
						enabled = false,
						used = true,
						edit = false,
						dtags = false,
						ttags = false,
						text = "[cd.type]",
						font = "Fira Sans Condensed",
						size = 10,
						color = { r = 1, g = 1, b = 1, a = 1 },
						align = "CENTER",
						anchor = "BOTTOM",
						offX = 0,
						offY = 7,
						outline = "OUTLINE",
						shadColor = { r = 0, g = 0, b = 0, a = 0.5 },
						shadX = 1.5,
						shadY = -1,
					},
				},
			},
		},
		
		holders = {
			iconPadding = 12,
			iconSize = 48,
			barPadding = 6,
			barWidth = 150,
			barHeight = 22,
			fontSize = 10,
		},
		
		tables = {
			spells = {},
			petspells = {},
			items = {},
			buffs = {},
			debuffs = {},
			offensives = {},
			runes = {},
			customs = {},
			detected = {},
		},
	}
}

function CDTL2:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("CDTL2DB", defaults, true)
	self.registry = LibStub("AceConfigRegistry-3.0")
	self.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	CDTL2.filterList = {}
	CDTL2.currentFilterHidden = {
		default = false,
		spells = true,
		items = true,
		buffs = true,
		debuffs = true,
		offensives = true,
		petspells = true,
		runes = true,
		customs = true,
		detected = true,
	}
	CDTL2.currentFilter = {}
	
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	
	--LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2", CDTL2:GetMainOptions(), { "cdtl2", "cooldowntimeline2"})
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2", CDTL2:GetMainOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Lanes", CDTL2:GetLaneOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Ready", CDTL2:GetReadyOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2BarFrames", CDTL2:GetBarFrameOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Filters", CDTL2:GetFilterOptions())
	LibStub("AceConfig-3.0"):RegisterOptionsTable("CDTL2Profiles", self.profile)
	
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2", "CDTL2")
	self.optionsFrame.oLanes = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2Lanes", "Lanes", "CDTL2")
	self.optionsFrame.oReady = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2Ready", "Ready", "CDTL2")
	self.optionsFrame.oBarFrames = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2BarFrames", "Bars", "CDTL2")
	self.optionsFrame.oFilter = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2Filters", "Filters", "CDTL2")
	self.optionsFrame.profile = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CDTL2Profiles", "Profiles", "CDTL2")
	
	self:RegisterChatCommand("cdtl2", "ChatCommand")
    self:RegisterChatCommand("cooldowntimeline2", "ChatCommand")
end

function CDTL2:OnEnable()	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_JOINED")
	self:RegisterEvent("GROUP_LEFT")
	--self:RegisterEvent("PLAYER_TALENT_UPDATE")
	--self:RegisterEvent("SPELLS_CHANGED")
	--self:RegisterEvent("ENCOUNTER_END")

	CDTL2:Cleanup()

	CDTL2:CreateLanes()
	CDTL2:CreateBarFrames()
	CDTL2:CreateReadyFrames()
	CDTL2:CreateHolders()
	
	private.CreateUnlockFrame()
	private.CreateDebugFrame()
	
	CDTL2:Print("Loaded version: "..CDTL2.version)
	CDTL2:Print("Type /cdtl2 or /cooldowntimeline2 for options")
	
	CDTL2.tracking["manaTime"] = GetTime()
	CDTL2.tracking["manaPrevious"] = 0
	CDTL2.tracking["energyTimeCount"] = 2
	CDTL2.tracking["energyPrevious"] = 0
	
	C_Timer.After(5, function()
		CDTL2.currentFilter["default"] = "SPELLS"
		CDTL2.currentFilter["spells"] = CDTL2:GetAardvark("spells")
		CDTL2.currentFilter["items"] = CDTL2:GetAardvark("items")
		CDTL2.currentFilter["buffs"] = CDTL2:GetAardvark("buffs")
		CDTL2.currentFilter["debuffs"] = CDTL2:GetAardvark("debuffs")
		CDTL2.currentFilter["offensives"] = CDTL2:GetAardvark("offensives")
		CDTL2.currentFilter["petspells"] = CDTL2:GetAardvark("petspells")
		CDTL2.currentFilter["runes"] = CDTL2:GetAardvark("runes")
		CDTL2.currentFilter["customs"] = CDTL2:GetAardvark("customs")
		CDTL2.currentFilter["detected"] = CDTL2:GetAardvark("detected")

		--for t, c in pairs(CDTL2.currentFilter) do
			--CDTL2:Print("AARDVARK: "..tostring(t).." - "..tostring(c))
		--end

		CDTL2:GetCharacterData()

		CDTL2:ScanCurrentCooldowns(CDTL2.player["class"], CDTL2.player["race"])

		if CDTL2.player["class"] == "DEATHKNIGHT" then
			self:RegisterEvent("RUNE_POWER_UPDATE")
		end
		
		CDTL2:RefreshLane(1)
		CDTL2:RefreshLane(2)
		CDTL2:RefreshLane(3)
	end)
	
	local vMajor = 0
	local vMinor = 0
	if CDTL2.db.profile.global["firstRun"] or IsNewerVersion() then
		C_Timer.After(10, function()
			private.CreateFirstRunFrame()
		end)
	end
end

function CDTL2:ChatCommand(input)
    if not input or input:trim() == "" then
        Settings.OpenToCategory("CDTL2")
	elseif input:trim() == "lock" then
		CDTL2:ToggleFrameLock()
	elseif input:trim() == "unlock" then
		CDTL2:ToggleFrameLock()
	elseif input:trim() == "test" then
		CDTL2:EnableTesting()
	elseif input:trim() == "debug" then
		CDTL2:ToggleDebug()
    end
end

private.CreateDebugFrame = function()
	local frameName = "CDTL2_Debug_Frame"
	local f = CreateFrame("Frame", frameName, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	f:ClearAllPoints()
	f:SetPoint("TOP", 300, -75)
	f:SetSize(300, 200)
	
	-- BACKGROUND
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetAllPoints(true)
	f.bg:SetColorTexture( 
		CDTL2.colors["db"]["r"],
		CDTL2.colors["db"]["g"],
		CDTL2.colors["db"]["b"],
		CDTL2.colors["db"]["a"]
	)
	
	f.text = f:CreateFontString(nil,"ARTWORK")
	f.text:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.text:SetShadowColor( 0, 0, 0, 1 )
	f.text:SetShadowOffset(1.5, -1)
	f.text:SetText("CDTL2: Debug Enabled")
	f.text:SetPoint("TOP", 0, -5)
	
	f.t1 = f:CreateFontString(nil,"ARTWORK")
	f.t1:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.t1:SetShadowColor( 0, 0, 0, 1 )
	f.t1:SetShadowOffset(1.5, -1)
	f.t1:SetText("Text 1")
	f.t1:SetPoint("TOP", 0, -30)
	
	f.t2 = f:CreateFontString(nil,"ARTWORK")
	f.t2:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.t2:SetShadowColor( 0, 0, 0, 1 )
	f.t2:SetShadowOffset(1.5, -1)
	f.t2:SetText("Text 2")
	f.t2:SetPoint("TOP", 0, -60)
	
	f.t3 = f:CreateFontString(nil,"ARTWORK")
	f.t3:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.t3:SetShadowColor( 0, 0, 0, 1 )
	f.t3:SetShadowOffset(1.5, -1)
	f.t3:SetText("Text 3")
	f.t3:SetPoint("TOP", 0, -90)
	
	local b = CreateFrame("Button", frameName.."_B_Reload", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Reload")
	b:SetPoint("TOPLEFT", 5, -25)
	b:SetScript("OnClick", function()
		ReloadUI()
	end)
	
	local b = CreateFrame("Button", frameName.."_B_Options", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Options")
	b:SetPoint("TOPLEFT", 5, -50)
	b:SetScript("OnClick", function()
		Settings.OpenToCategory("CDTL2")
	end)
	
	local b = CreateFrame("Button", frameName.."_B_UnLock", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("(Un)Lock")
	b:SetPoint("TOPLEFT", 5, -75)
	b:SetScript("OnClick", function()
		CDTL2:ToggleFrameLock()
	end)
	
	local b = CreateFrame("Button", frameName.."_B_TestCode1", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("TestCode1")
	b:SetPoint("TOPLEFT", 5, -100)
	b:SetScript("OnClick", function()
		-- TEST CODE 1
	end)
		
	local b = CreateFrame("Button", frameName.."_B_TestCode2", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("TestCode2")
	b:SetPoint("TOPLEFT", 5, -125)
	b:SetScript("OnClick", function()
		-- TEST CODE 2
	end)
	
	-- ON UPDATE
	f:HookScript("OnUpdate", function(self, elapsed)
		
	end)
		
	-- DRAG AND DROP MOVEMENT
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	
	if not CDTL2.db.profile.global["debugMode"] then
		f:Hide()
	end
	
	CDTL2.debugFrame = f
end

private.CreateFirstRunFrame = function()
	local name = "CDTL2_Firstrun"
	local f = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f:SetPoint("TOP", 0, -150)
	f:SetSize(550, 300)
	
	-- BACKGROUND
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetAllPoints(true)
	f.bg:SetColorTexture( 0.1, 0.1, 0.1, 0.9 )
	
	-- HEADING TEXT
	f.text = f:CreateFontString(nil,"ARTWORK")
	f.text:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 20, "NONE")
	f.text:SetShadowColor( 0, 0, 0, 1 )
	f.text:SetShadowOffset(1.5, -1)
	f.text:SetText("|cFF54a3ffCDTL2|r - |cffffffffv"..CDTL2.version)
	f.text:SetPoint("TOP", 0, -20)

	-- DRAG AND DROP MOVEMENT
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	
	-- SCROLL FRAME
	local sf = CreateFrame("ScrollFrame", "CDTL2_Firstrun_Scroll", CDTL2_Firstrun, "UIPanelScrollFrameTemplate")
	sf:SetPoint("LEFT", 16, 0)
	sf:SetPoint("RIGHT", -32, 0)
	sf:SetPoint("TOP", 0, -55)
	sf:SetPoint("BOTTOM", 0, 70)
	
	-- EDIT BOX
	local ef = CreateFrame("EditBox", name.."_Edit", CDTL2_Firstrun_Scroll)
	ef:SetSize(sf:GetSize())
	ef:SetMultiLine(true)
	ef:SetAutoFocus(false)
	ef:SetFontObject("GameFontWhite")
	
	-- TEXT FOR THE BOX
	local text = ""
	text = text.."If you have any issues or suggestions, or just want to chat, please feel free to join the CDTL2 Discord:\n\n"
	text = text.."|cFF54a3ff"..CDTL2.discordlink.."|r\n\n"

	text = text..CDTL2:GetSpecialMessage()
	text = text..CDTL2:GetChangeLog()

	ef:SetText(text)
	
	sf:SetScrollChild(ef)

	-- BORDER
	local border = CreateFrame("Frame", "CDTL2_Firstrun_BD", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	border:SetParent(f)
	local s = {
		style = "CDTL2 Shadow",
		color = { r = 0, g = 0, b = 0, a = 0.25 },
		size = 5,
		padding = 5,
		inset = 0,
	}
	CDTL2:SetBorder(border, s)
	border:Show()
	border:SetFrameLevel(f:GetFrameLevel() + 1)
	
	-- RESIZABLE
	f:SetResizable(true)
	local rb = CreateFrame("Button", name.."_Resize", CDTL2_Firstrun)
	rb:SetPoint("BOTTOMRIGHT", -6, 7)
	rb:SetSize(16, 16)
	rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	rb:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			f:StartSizing("BOTTOMRIGHT")
			self:GetHighlightTexture():Hide()
		end
	end)
	rb:SetScript("OnMouseUp", function(self, button)
		f:StopMovingOrSizing()
		self:GetHighlightTexture():Show()
		ef:SetWidth(sf:GetWidth())
	end)

	-- SHOW AGAIN TEXT
	f.text1 = f:CreateFontString(nil,"ARTWORK")
	f.text1:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.text1:SetShadowColor( 0, 0, 0, 1 )
	f.text1:SetShadowOffset(1.5, -1)
	f.text1:SetText("Show this message next login/reload?")
	f.text1:SetPoint("BOTTOM", 0, 40)

	local b1 = CreateFrame("Button", name.."_Yes", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b1:SetSize(80 ,25)
	b1:SetText("Yes")
	b1:SetPoint("BOTTOM", -45, 8)
	b1:SetScript("OnClick", function()
		f:Hide()
	end)
	
	local b2 = CreateFrame("Button", name.."_No", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b2:SetSize(80 ,25)
	b2:SetText("No")
	b2:SetPoint("BOTTOM", 45, 8)
	b2:SetScript("OnClick", function()
		CDTL2.db.profile.global["firstRun"] = false
		CDTL2.db.profile.global["previousVersion"] = CDTL2.version
		f:Hide()
	end)

	f:SetFrameStrata("DIALOG")
	f:Show()
end

private.CreateUnlockFrame = function()
	local f = CreateFrame("Frame", "CDTL2_Unlock_Frame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	f:ClearAllPoints()
	f:SetPoint("TOP", 0, -70)
	f:SetSize(180, 70)
	
	-- BACKGROUND
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetAllPoints(true)
	f.bg:SetColorTexture( 
		CDTL2.colors["db"]["r"],
		CDTL2.colors["db"]["g"],
		CDTL2.colors["db"]["b"],
		CDTL2.colors["db"]["a"]
	)
	
	-- BORDER
	f.bd = CreateFrame("Frame", "CDTL2_Unlock_Frame_BD", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.bd:SetParent(f)
	CDTL2:SetBorder(f.bd, {
					style = "CDTL2 Shadow",
					color = { r = 0, g = 0, b = 0, a = 0.25 },
					size = 5,
					padding = 5,
					inset = 0,
				})
	f.bd:SetFrameLevel(f:GetFrameLevel() + 1)
	
	-- TEXT
	f.text = f:CreateFontString(nil,"ARTWORK")
	f.text:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 12, "NONE")
	f.text:SetShadowColor( 0, 0, 0, 1 )
	f.text:SetShadowOffset(1.5, -1)
	f.text:SetText("CDTL2\nFrames currently unlocked\nDrag and drop to move")
	f.text:SetPoint("TOP", 0, -5)
	
	local b = CreateFrame("Button", "CDTL2_Unlock_Frame_Button", f, "UIPanelButtonTemplate", BackdropTemplateMixin and "BackdropTemplate" or nil)
	b:SetSize(80 ,25) -- width, height
	b:SetText("Lock")
	b:SetPoint("BOTTOM", 0, 4)
	b:SetScript("OnClick", function()
		CDTL2:ToggleFrameLock()
		f:Hide()
	end)
	
	-- ON UPDATE
	f:HookScript("OnUpdate", function(self, elapsed)
		
	end)
	
	if not CDTL2.db.profile.global["unlockFrames"] then
		f:Hide()
	end
	
	CDTL2.unlockFrame = f
end

function CDTL2:EnableTesting()
	if CDTL2.testing then
		--CDTL2:Print("Already Testing")
	else
		CDTL2.testing = true
		CDTL2:CreateTestingFrame()
	end
end

function CDTL2:CreateTestingFrame()
	if CDTL2.testing then
		--local name = "CDTL2_Testing_Frame"
		local testingType = CDTL2.db.profile.global["testingType"]
		local testingNumber = CDTL2.db.profile.global["testingNumber"]
		local testingMinTime = CDTL2.db.profile.global["testingMinTime"]
		local testingMaxTime = CDTL2.db.profile.global["testingMaxTime"]
		local testingLoop = CDTL2.db.profile.global["testingLoop"]

		local f = CDTL2.GUI:Create("Frame")
		f:SetTitle("|cFF54a3ffCDTL2|r - |cffffffffTesting|r")
		f:SetLayout("Flow")
		f:SetWidth(200)
		f:SetHeight(450)
		f:SetAutoAdjustHeight(true)
		f:SetPoint("LEFT", 20, 0)
		f:SetCallback("OnClose", function(widget)
				CDTL2.GUI:Release(widget)
				CDTL2.testing = false
			end)
		
		local lblMain = CDTL2.GUI:Create("Label")
		lblMain:SetText("Here you can create a series of test Cooldowns to assist with configuration\n\n")
		lblMain:SetFullWidth(true)
		f:AddChild(lblMain)

		local ddType = CDTL2.GUI:Create("Dropdown")
		ddType:SetLabel("Type of Cooldown to test")
		ddType:SetFullWidth(true)
		ddType:AddItem("spells", "Spells")
		ddType:AddItem("items", "Items")
		ddType:AddItem("buffs", "Buffs")
		ddType:AddItem("debuffs", "Debuffs")
		ddType:AddItem("offensives", "Offensives")
		ddType:AddItem("petspells", "Pet Spells")
		if CDTL2.player["class"] == "DEATHKNIGHT" then
			ddType:AddItem("runes", "Runes")
		end

		ddType:SetValue(testingType)
		ddType:SetCallback("OnValueChanged", function(widget)
			CDTL2.db.profile.global["testingType"] = widget["value"]
		end)
		f:AddChild(ddType)

				local lblSpacer01 = CDTL2.GUI:Create("Label")
				lblSpacer01:SetText("\n")
				f:AddChild(lblSpacer01)

		local sNumber = CDTL2.GUI:Create("Slider")
		sNumber:SetLabel("Number of Cooldowns to create")
		sNumber:SetFullWidth(true)
		sNumber:SetSliderValues(1, 20, 1)
		sNumber:SetValue(testingNumber)
		sNumber:SetCallback("OnMouseUp", function(widget)
			--CDTL2:Print("sNumber: "..tostring(widget["value"]))
			CDTL2.db.profile.global["testingNumber"] = widget["value"]
		end)
		f:AddChild(sNumber)

				local lblSpacer02 = CDTL2.GUI:Create("Label")
				lblSpacer02:SetText("\n")
				f:AddChild(lblSpacer02)

		local sMinTime = CDTL2.GUI:Create("Slider")
		sMinTime:SetLabel("First Cooldown Duration")
		sMinTime:SetFullWidth(true)
		sMinTime:SetSliderValues(1, 600, 1)
		sMinTime:SetValue(testingMinTime)
		sMinTime:SetCallback("OnMouseUp", function(widget)
			--CDTL2:Print("sMinTime: "..tostring(widget["value"]))
			CDTL2.db.profile.global["testingMinTime"] = widget["value"]
		end)
		f:AddChild(sMinTime)

				local lblSpacer03 = CDTL2.GUI:Create("Label")
				lblSpacer03:SetText("\n")
				f:AddChild(lblSpacer03)

		local sMaxTime = CDTL2.GUI:Create("Slider")
		sMaxTime:SetLabel("Last Cooldown Duration")
		sMaxTime:SetFullWidth(true)
		sMaxTime:SetSliderValues(1, 600, 1)
		sMaxTime:SetValue(testingMaxTime)
		sMaxTime:SetCallback("OnMouseUp", function(widget)
			--CDTL2:Print("sMaxTime: "..tostring(widget["value"]))
			CDTL2.db.profile.global["testingMaxTime"] = widget["value"]
		end)
		f:AddChild(sMaxTime)

				local lblSpacer04 = CDTL2.GUI:Create("Label")
				lblSpacer04:SetText("\n")
				f:AddChild(lblSpacer04)

		local cbLoop = CDTL2.GUI:Create("CheckBox")
		cbLoop:SetLabel("Loop")
		cbLoop:SetFullWidth(true)
		cbLoop:SetValue(testingLoop)
		cbLoop:SetCallback("OnValueChanged", function(widget)
			--CDTL2:Print("cbLoop: "..tostring(widget:GetValue()))
			CDTL2.db.profile.global["testingLoop"] = widget:GetValue()
		end)
		f:AddChild(cbLoop)

				local lblSpacer05 = CDTL2.GUI:Create("Label")
				lblSpacer05:SetText("\n")
				f:AddChild(lblSpacer05)

		local btnCreate = CDTL2.GUI:Create("Button")
		--btnCreate:SetWidth(170)
		btnCreate:SetText("Create")
		btnCreate:SetFullWidth(true)
		btnCreate:SetCallback("OnClick", function()
				--print("Click!")
				CDTL2:GenerateTestCooldowns()
			end)
		f:AddChild(btnCreate)

		local btnClear = CDTL2.GUI:Create("Button")
		--btnCreate:SetWidth(170)
		btnClear:SetText("Clear")
		btnClear:SetFullWidth(true)
		btnClear:SetCallback("OnClick", function()
				--print("Click!")
				for _, cd in ipairs(CDTL2.cooldowns) do
					if cd.data["type"] == "testing" then
						if cd.icon:GetParent():GetName() ~= "CDTL2_Active_Icon_Holding" then
							--CDTL2:Print(tostring(cd:GetName()).. " - "..tostring(cd.data["name"]))
							CDTL2:SendToHolding(cd)
							CDTL2:SendToBarHolding(cd)
						end
					end
				end
			end)
		f:AddChild(btnClear)

		if CDTL2.db.profile.global["debug"] then
			CDTL2:Print("Created Testing Frame")
		end
	end
end

function CDTL2:COMBAT_LOG_EVENT_UNFILTERED()
	local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _ = CombatLogGetCurrentEventInfo()
	
	if subevent == "SPELL_AURA_APPLIED" then
		if sourceGUID == CDTL2.player["guid"] or destGUID == CDTL2.player["guid"] then
			local spellID, spellName, _, auraType, _, _, _, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())
			auraType = auraType:lower().."s"
			
			--CDTL2:Print(destGUID)
			
			if CDTL2.db.profile.global["debugMode"] then
				CDTL2:Print("AURA APPLIED: "..spellID.." - "..spellName.." - "..auraType.." - "..tostring(sourceName).." - "..destName)
			end
			
			-- PLAYER AURAS
			if destGUID == CDTL2.player["guid"] then
				local validSource = false
				if sourceGUID == CDTL2.player["guid"] then
					validSource = true
				else
					if auraType == "buffs" and not CDTL2.db.profile.global["buffs"]["onlyPlayer"] then
						validSource = true
					end
					
					if auraType == "debuffs" and not CDTL2.db.profile.global["debuffs"]["onlyPlayer"] then
						validSource = true
					end
				end
				
				if validSource then
					-- CHECK FOR TRIGGERS
					--local spellName, _, _ = CDTL2:GetSpellInfo(spellID)
					--local s = CDTL2:GetSpellSettings(spellName, "customs")
					local s = CDTL2:GetCustomSpellSettings(spellName, "aura")
					if s then
						--if s["triggerType"] and s["triggerType"] == "aura" then
							if CDTL2.db.profile.global["debugMode"] then
								CDTL2:Print("CUSTOM_FOUND: aura - "..spellName)
							end

							if not s["ignored"] then
								local ef = CDTL2:GetExistingCooldown(s["name"], "customs")
								if ef then
									CDTL2:SendToLane(ef)
									CDTL2:SendToBarFrame(ef)
									--+CDTL2:CheckEdgeCases(spellName)
								else
									if CDTL2.db.profile.global["customs"]["enabled"] then
										CDTL2:CreateCooldown(CDTL2:GetUID(),"customs" , s)
										CDTL2:CheckEdgeCases(spellName)
										
										if CDTL2:IsUsedBy("customs", spellID) then
											--CDTL2:Print("USEDBY MATCH: "..s["id"])
										else
											CDTL2:AddUsedBy("customs", spellID, CDTL2.player["guid"])
										end
									end
								end
							end
						--end
					else
						
					end

					local s = CDTL2:GetSpellSettings(spellName, auraType)
					if s then
						if not s["ignored"] then
							local ef = CDTL2:GetExistingCooldown(s["name"], auraType)
							if ef then
								CDTL2:SendToLane(ef)
								CDTL2:SendToBarFrame(ef)
							else
								if CDTL2.db.profile.global["buffs"]["enabled"] and auraType == "buffs"  then
									CDTL2:CreateCooldown(CDTL2:GetUID(),auraType , s)
									if not CDTL2:IsUsedBy("buffs", spellID) then
										CDTL2:AddUsedBy("buffs", spellID, CDTL2.player["guid"])
									end
								elseif CDTL2.db.profile.global["debuffs"]["enabled"] and auraType == "debuffs" then
									CDTL2:CreateCooldown(CDTL2:GetUID(),auraType , s)
									if not CDTL2:IsUsedBy("debuffs", spellID) then
										CDTL2:AddUsedBy("debuffs", spellID, CDTL2.player["guid"])
									end
								end
							end
						end
					else
						s = CDTL2:AuraExists("player", spellName)
						if s then
							s["highlight"] = true
							s["pinned"] = false
							
							s["usedBy"] = { CDTL2.player["guid"] }
							
							local ignoreThreshold = 0
							local link, _ = CDTL2:GetSpellLink(spellID)
							s["link"] = link
							
							if auraType == "buffs" then
								ignoreThreshold = CDTL2.db.profile.global["buffs"]["ignoreThreshold"]
								
								s["enabled"] = CDTL2.db.profile.global["buffs"]["showByDefault"]
								s["lane"] = CDTL2.db.profile.global["buffs"]["defaultLane"]
								s["barFrame"] = CDTL2.db.profile.global["buffs"]["defaultBar"]
								s["readyFrame"] = CDTL2.db.profile.global["buffs"]["defaultReady"]
							elseif auraType == "debuffs" then
								ignoreThreshold = CDTL2.db.profile.global["debuffs"]["ignoreThreshold"]
								
								s["enabled"] = CDTL2.db.profile.global["debuffs"]["showByDefault"]
								s["lane"] = CDTL2.db.profile.global["debuffs"]["defaultLane"]
								s["barFrame"] = CDTL2.db.profile.global["debuffs"]["defaultBar"]
								s["readyFrame"] = CDTL2.db.profile.global["debuffs"]["defaultReady"]
							end
							
							if s["bCD"] / 1000 > 3 and s["bCD"] / 1000 <= ignoreThreshold then
								s["ignored"] = false
							else
								s["ignored"] = true
							end

							table.insert(CDTL2.db.profile.tables[auraType], s)
							
							if not s["ignored"] then
								if CDTL2.db.profile.global["buffs"]["enabled"] and auraType == "buffs" then
									CDTL2:CreateCooldown(CDTL2:GetUID(),auraType , s)
								elseif CDTL2.db.profile.global["debuffs"]["enabled"] and auraType == "debuffs" then
									CDTL2:CreateCooldown(CDTL2:GetUID(),auraType , s)
								end
							end
						end
					end
				end
			
			-- OFFENSIVE AURAS
			else
				local s = CDTL2:GetSpellSettings(spellName, "offensives")
				if s then
					if not s["ignored"] then
						local ef = CDTL2:GetExistingCooldown(s["name"], "offensives", destGUID)
						if ef then
							CDTL2:SendToLane(ef)
							CDTL2:SendToBarFrame(ef)
							
							ef.data["currentCD"] = ef.data["baseCD"]
							ef.data["targetID"] = destGUID
							ef.data["targetName"] = destName
						else
							local rcd = CDTL2:RecycleOffensiveCD()
							if rcd then
								rcd.data["id"] = s["id"]
								rcd.data["name"] = s["name"]
								--rcd.data["rank"] = s["rank"]
								rcd.data["desc"] = s["desc"]
								rcd.data["icon"] = s["icon"]
								
								rcd.data["ignored"] = ""
								rcd.data["highlighted"] = ""
								
								rcd.data["lane"] = s["lane"]
								rcd.data["barFrame"] = s["barFrame"]
								rcd.data["readyFrame"] = s["readyFrame"]
								
								rcd.data["baseCD"] = s["bCD"] / 1000
								rcd.data["currentCD"] = s["bCD"] / 1000
								
								rcd.icon.icon = rcd.data["icon"]
								rcd.icon.name = rcd.data["name"]
								--rcd.icon.rank = rcd.data["rank"]
								rcd.icon.lane = rcd.data["lane"]
								
								rcd.data["targetID"] = destGUID
								rcd.data["targetName"] = destName
								
								CDTL2:SendToLane(rcd)
								CDTL2:SendToBarFrame(rcd)
							else
								if CDTL2.db.profile.global["offensives"]["enabled"] then
									local ncd = CDTL2:CreateCooldown(CDTL2:GetUID(),"offensives" , s)
									
									ncd.data["targetID"] = destGUID
									ncd.data["targetName"] = destName
									
									if not CDTL2:IsUsedBy("offensives", spellID) then
										CDTL2:AddUsedBy("offensives", spellID, CDTL2.player["guid"])
									end
								end
							end
						end
					end
				else
					local spellName, icon, originalIcon = CDTL2:GetSpellInfo(spellID)
					
					local s = {
						id = spellID,
						bCD = 0,
						name = spellName,
						type = "offensives",
						icon = icon,
						lane = CDTL2.db.profile.global["offensives"]["defaultLane"],
						barFrame = CDTL2.db.profile.global["offensives"]["defaultBar"],
						readyFrame = CDTL2.db.profile.global["offensives"]["defaultReady"],
					}
					
					s["enabled"] = CDTL2.db.profile.global["offensives"]["showByDefault"]
					s["highlight"] = true
					s["pinned"] = false
					
					s["usedBy"] = { CDTL2.player["guid"] }
					
					local link, _ = CDTL2:GetSpellLink(spellID)
					s["link"] = link
					
					table.insert(CDTL2.db.profile.tables["offensives"], s)
										
					if CDTL2.db.profile.global["offensives"]["enabled"] then
						--s["targetID"] = destGUID
						--s["targetName"] = destName
						
						local ncd = CDTL2:CreateCooldown(CDTL2:GetUID(),"offensives" , s)
						
						ncd.data["targetID"] = destGUID
						ncd.data["targetName"] = destName
					end
				end
			end
		end
	elseif subevent == "SPELL_AURA_REFRESH" then
		if sourceGUID == CDTL2.player["guid"] then
			local spellID, spellName, _, auraType, _, _, _, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())
			auraType = auraType:lower().."s"
			
			if CDTL2.db.profile.global["debugMode"] then
				CDTL2:Print("AURA REFRESH: "..spellID.." - "..spellName.." - "..auraType.." - "..sourceName.." - "..destName)
			end
			
			local ef = CDTL2:GetExistingCooldown(spellName, "offensives", destGUID)
			if ef then
				ef.data["currentCD"] = ef.data["baseCD"]
			end
		end		
	elseif subevent == "SPELL_AURA_REMOVED" then
		if sourceGUID == CDTL2.player["guid"] then
			local spellID, spellName, _, auraType, _, _, _, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())
			auraType = auraType:lower().."s"
			
			if CDTL2.db.profile.global["debugMode"] then
				CDTL2:Print("AURA REMOVED: "..spellID.." - "..spellName.." - "..auraType.." - "..sourceName.." - "..destName)
			end
			
			local ef = CDTL2:GetExistingCooldown(spellName, "offensives", destGUID)
			if ef then
				ef.data["currentCD"] = -1
			end
		end
		
	-- SWING DAMAGE
	elseif subevent == "SWING_DAMAGE" then
		if sourceGUID == CDTL2.player["guid"] then
			local amount, _, _, _, _, _, _, _, _, isOffHand = select(12, CombatLogGetCurrentEventInfo())
			local mhSpeed, ohSpeed = UnitAttackSpeed("player")
			
			if isOffHand then
				CDTL2.tracking["ohSwingTime"] = ohSpeed
			else
				CDTL2.tracking["mhSwingTime"] = mhSpeed
			end
		end
	
	-- SWING MISSED
	elseif subevent == "SWING_MISSED" then
		if sourceGUID == CDTL2.player["guid"] then
			local _, isOffHand, _, _ = select(12, CombatLogGetCurrentEventInfo())
			local mhSpeed, ohSpeed = UnitAttackSpeed("player")
			
			if isOffHand then
				CDTL2.tracking["ohSwingTime"] = ohSpeed
			else
				CDTL2.tracking["mhSwingTime"] = mhSpeed
			end
		end
	end
end

function CDTL2:UNIT_SPELLCAST_SUCCEEDED(...)
	local temp, unitTarget, castGUID, spellID = ...

	if unitTarget == "player" then
		local spellName, icon, originalIcon = CDTL2:GetSpellInfo(spellID)

		local isKnown = IsSpellKnown(spellID)
		local isKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown(spellID)

		if CDTL2.db.profile.global["debugMode"] then
			CDTL2:Print("SPELLCAST: "..spellName.."-"..castGUID)
		end

		if isKnown or isKnownOrOverridesKnown then
			local s = CDTL2:GetSpellSettings(spellName, "spells")
			if s then
				if not s["ignored"] then
					local ef = CDTL2:GetExistingCooldown(s["name"], "spells")
					if ef then
						CDTL2:SendToLane(ef)
						CDTL2:SendToBarFrame(ef)
						CDTL2:CheckEdgeCases(spellName)
					else
						if CDTL2.db.profile.global["spells"]["enabled"] then
							CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
							CDTL2:CheckEdgeCases(spellName)
							
							if CDTL2:IsUsedBy("spells", spellID) then
								--CDTL2:Print("USEDBY MATCH: "..s["id"])
							else
								CDTL2:AddUsedBy("spells", spellID, CDTL2.player["guid"])
							end
						end
					end
				end
			else
				s = {}
				
				--local currentCharges, maxCharges, _, cooldownDuration, _ = GetSpellCharges(spellID)
				local currentCharges, maxCharges, cooldownStart, cooldownDuration  = CDTL2:GetSpellCharges(spellID)
				local cooldownMS, gcdMS = CDTL2:GetSpellBaseCooldown(spellID)

				if cooldownDuration ~= nil and not isSecret(cooldownDuration) and cooldownDuration ~= 0 then
					cooldownMS = cooldownDuration * 1000
				end

				s["id"] = spellID
				s["name"] = spellName
				--s["rank"] = rank
				s["bCD"] = cooldownMS
				s["type"] = "spells"

				if maxCharges ~= nil and not isSecret(maxCharges) and maxCharges ~= 0 then
					s["charges"] = maxCharges
					s["bCD"] = cooldownMS
				end

				s["icon"] = icon
				s["lane"] = CDTL2.db.profile.global["spells"]["defaultLane"]
				s["barFrame"] = CDTL2.db.profile.global["spells"]["defaultBar"]
				s["readyFrame"] = CDTL2.db.profile.global["spells"]["defaultReady"]
				s["enabled"] = CDTL2.db.profile.global["spells"]["showByDefault"]
				s["highlight"] = true
				s["pinned"] = false
				s["usedBy"] = { CDTL2.player["guid"] }
				s["setCustomCD"] = false
				
				local link, _ = CDTL2:GetSpellLink(spellID)
				s["link"] = link
				
				if isSecret(s["bCD"]) then
					s["ignored"] = false
				elseif s["bCD"] / 1000 > 3 and s["bCD"] / 1000 <= CDTL2.db.profile.global["spells"]["ignoreThreshold"] then
					s["ignored"] = false
				else
					s["ignored"] = true
				end

				table.insert(CDTL2.db.profile.tables["spells"], s)
				
				if not s["ignored"] then
					if CDTL2.db.profile.global["spells"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"spells" , s)
						CDTL2:CheckEdgeCases(spellName)
					end
				end
			end
		else
			-- ITEM SPELLS
			local s = nil
			local is = CDTL2:GetItemSpell(spellID)
			if is then
				s = CDTL2:GetSpellSettings(is["itemName"], "items", true)
			else
				s = CDTL2:GetSpellSettings(spellName, "items", true, spellID)
			end
			
			if s then
				if not s["ignored"] then
					local ef = CDTL2:GetExistingCooldown(s["name"], "items")
					if ef then
						CDTL2:SendToLane(ef)
						CDTL2:SendToBarFrame(ef)
					else
						if CDTL2.db.profile.global["items"]["enabled"] then
							if not CDTL2:IsUsedBy("items", spellID) then
								CDTL2:AddUsedBy("items", spellID, CDTL2.player["guid"])
							end
							
							CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
						end
					end
				end
			else
				s = is
				if s then
					if CDTL2:IsValidItem(s["itemID"]) then
						s["usedBy"] = { CDTL2.player["guid"] }
						table.insert(CDTL2.db.profile.tables["items"], s)
						
						if CDTL2.db.profile.global["items"]["enabled"] then
							CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
						end
					end
				else
					--CDTL2:Print("NOTFOUND: "..spellID)

					-- CHECK FOR 'OTHER' SPELLS
					local spellName, icon, originalIcon = CDTL2:GetSpellInfo(spellID)
					--local s = CDTL2:GetSpellSettings(spellName, "customs")
					local s = CDTL2:GetCustomSpellSettings(spellName, "spell")
					if s then
						--if s["triggerType"] and s["triggerType"] == "spell" then
							if CDTL2.db.profile.global["debugMode"] then
								CDTL2:Print("CUSTOM_FOUND: spell - "..spellName.."-"..castGUID)
							end

							if not s["ignored"] then
								local ef = CDTL2:GetExistingCooldown(s["name"], "customs")
								if ef then
									CDTL2:SendToLane(ef)
									CDTL2:SendToBarFrame(ef)
									--+CDTL2:CheckEdgeCases(spellName)
								else
									if CDTL2.db.profile.global["customs"]["enabled"] then
										CDTL2:CreateCooldown(CDTL2:GetUID(),"customs" , s)
										CDTL2:CheckEdgeCases(spellName)
										
										if CDTL2:IsUsedBy("customs", spellID) then
											--CDTL2:Print("USEDBY MATCH: "..s["id"])
										else
											CDTL2:AddUsedBy("customs", spellID, CDTL2.player["guid"])
										end
									end
								end
							end
						--end
					else
						if CDTL2.db.profile.global["customDetection"] then
							-- RECORD 'OTHER' SPELL
							s = CDTL2:GetSpellSettings(spellName, "detected")
							if s then
								if CDTL2.db.profile.global["debugMode"] then
									CDTL2:Print("OTHER_FOUND: "..spellName.."-"..castGUID)
								end
							else
								--if CDTL2.db.profile.global["customDetection"] then
									--local currentCharges, maxCharges, _, cooldownDuration, _ = GetSpellCharges(spellID)
									local currentCharges, maxCharges, cooldownStart, cooldownDuration = CDTL2:GetSpellCharges(spellID)
									local cooldownMS, gcdMS = CDTL2:GetSpellBaseCooldown(spellID)

									if cooldownDuration ~= nil and not isSecret(cooldownDuration) and cooldownDuration ~= 0 then
										cooldownMS = cooldownDuration * 1000
									end

									if CDTL2.db.profile.global["debugMode"] then
										CDTL2:Print("OTHER_ADDING: "..spellName.." - "..spellID.." - "..tostring(cooldownMS).." - "..tostring(CDTL2.player["guid"]))
									end

									local s = {}

									s["id"] = spellID
									s["name"] = spellName
									s["type"] = "detected"

									if maxCharges ~= nil and not isSecret(maxCharges) and maxCharges ~= 0 then
										s["charges"] = maxCharges
										s["bCD"] = cooldownMS
									end

									s["icon"] = icon
									s["highlight"] = true
									s["pinned"] = false
									s["setCustomCD"] = false
									
									local link, _ = CDTL2:GetSpellLink(spellID)
									s["link"] = link
									
									table.insert(CDTL2.db.profile.tables["detected"], s)
							end
						else
							local cooldownMS, gcdMS = CDTL2:GetSpellBaseCooldown(spellID)
								
							if CDTL2.db.profile.global["debugMode"] then
								CDTL2:Print("OTHER_SKIPPED: "..tostring(spellName).." - "..tostring(spellID).." - "..tostring(cooldownMS).." - "..tostring(CDTL2.player["guid"]))
							end
						end
					end
				end
			end
		end
	elseif unitTarget == "pet" then
		local spellName, icon, originalIcon = CDTL2:GetSpellInfo(spellID)
		
		local isKnown = IsSpellKnown(spellID, true)
		local isKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown(spellID, true)

		if CDTL2.db.profile.global["debugMode"] then
			CDTL2:Print("PETCAST: "..spellName.."-"..castGUID)
		end

		if isKnown or isKnownOrOverridesKnown then
			local s = CDTL2:GetSpellSettings(spellName, "petspells")
			if s then
				if not s["ignored"] then
					local ef = CDTL2:GetExistingCooldown(s["name"], "petspells")
					if ef then
						CDTL2:SendToLane(ef)
						CDTL2:SendToBarFrame(ef)
						CDTL2:CheckEdgeCases(spellName)
					else
						if CDTL2.db.profile.global["petspells"]["enabled"] then
							CDTL2:CreateCooldown(CDTL2:GetUID(),"petspells" , s)
							CDTL2:CheckEdgeCases(spellName)
							
							if CDTL2:IsUsedBy("petspells", spellID) then
								--CDTL2:Print("USEDBY MATCH: "..s["id"])
							else
								CDTL2:AddUsedBy("petspells", spellID, CDTL2.player["guid"])
							end
						end
					end
				end
			else
				s = {}
			
				--local currentCharges, maxCharges, _, cooldownDuration, _ = GetSpellCharges(spellID)
				local currentCharges, maxCharges, cooldownStart, cooldownDuration = CDTL2:GetSpellCharges(spellID)
				local cooldownMS, gcdMS = CDTL2:GetSpellBaseCooldown(spellID)

				if cooldownDuration ~= nil and not isSecret(cooldownDuration) and cooldownDuration ~= 0 then
					cooldownMS = cooldownDuration * 1000
				end

				s["id"] = spellID
				s["name"] = spellName
				--s["rank"] = rank
				s["bCD"] = cooldownMS
				s["type"] = "petspells"

				if maxCharges ~= nil and not isSecret(maxCharges) and maxCharges ~= 0 then
					s["charges"] = maxCharges
					s["bCD"] = cooldownMS
				end

				s["icon"] = icon
				s["lane"] = CDTL2.db.profile.global["petspells"]["defaultLane"]
				s["barFrame"] = CDTL2.db.profile.global["petspells"]["defaultBar"]
				s["readyFrame"] = CDTL2.db.profile.global["petspells"]["defaultReady"]
				s["enabled"] = CDTL2.db.profile.global["petspells"]["showByDefault"]
				s["highlight"] = true
				s["pinned"] = false
				s["usedBy"] = { CDTL2.player["guid"] }
				s["setCustomCD"] = false
				
				local link, _ = CDTL2:GetSpellLink(spellID)
				s["link"] = link
				
				if s["bCD"] / 1000 > 3 and s["bCD"] / 1000 <= CDTL2.db.profile.global["petspells"]["ignoreThreshold"] then
					s["ignored"] = false
				else
					s["ignored"] = true
				end
				
				table.insert(CDTL2.db.profile.tables["petspells"], s)
				
				if not s["ignored"] then
					if CDTL2.db.profile.global["petspells"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"petspells" , s)
						CDTL2:CheckEdgeCases(spellName)
					end
				end
			end
		end
	end
end

function CDTL2:ITEM_LOCK_CHANGED(...)
	-- Detect item lock cooldowns
	-- Most commonly trinkets being equipped, that will begin a 30 second cooldown
	local _, bagOrSlotIndex, slotIndex = ...
	
	if not IsInventoryItemLocked(bagOrSlotIndex) and not IsInventoryItemLocked(slotIndex) then
		if slotIndex == nil then
			local itemId = GetInventoryItemID("player", bagOrSlotIndex)
			local spellName, spellID = GetItemSpell(itemId)
			
			if spellID then
				local s = CDTL2:GetSpellSettings(spellName, "items", false, spellID)
				if s then
					if not s["ignored"] then
						local ef = CDTL2:GetExistingCooldown(s["name"], "items")
						if ef then
							ef.data["bCD"] = 30000
							CDTL2:SendToLane(ef)
							CDTL2:SendToBarFrame(ef)
						else
							if CDTL2.db.profile.global["items"]["enabled"] then
								if not CDTL2:IsUsedBy("items", spellID) then
									CDTL2:AddUsedBy("items", spellID, CDTL2.player["guid"])
								end
								
								s["bCD"] = 30000
								CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
							end
						end
					end
				else
					s = CDTL2:GetItemSpell(spellID)
					if s then
						if CDTL2:IsValidItem(s["itemID"]) then
							s["usedBy"] = { CDTL2.player["guid"] }
							table.insert(CDTL2.db.profile.tables["items"], s)
							
							if CDTL2.db.profile.global["items"]["enabled"] then
								s["bCD"] = 30000
								CDTL2:CreateCooldown(CDTL2:GetUID(),"items" , s)
							end
						end
					else
						--CDTL2:Print("NOTFOUND: "..spellID)
					end
				end
			end
		end
	end
end

function CDTL2:PLAYER_REGEN_DISABLED()
	CDTL2.combat = true
	
	local ready1Enabled = CDTL2.db.profile.ready["ready1"]["enabled"]
	local ready2Enabled = CDTL2.db.profile.ready["ready2"]["enabled"]
	local ready3Enabled = CDTL2.db.profile.ready["ready3"]["enabled"]
	
	if CDTL2_Ready_1 then
		CDTL2_Ready_1.combatTimer = CDTL2.db.profile.ready["ready1"]["pTime"]
	end
	
	if CDTL2_Ready_2 then
		CDTL2_Ready_2.combatTimer = CDTL2.db.profile.ready["ready2"]["pTime"]
	end
	
	if CDTL2_Ready_3 then
		CDTL2_Ready_3.combatTimer = CDTL2.db.profile.ready["ready3"]["pTime"]
	end
end

function CDTL2:PLAYER_REGEN_ENABLED()
	CDTL2.combat = false
	
	if CDTL2_Ready_1 then
		CDTL2_Ready_1.combatTimer = 0
	end
	
	if CDTL2_Ready_2 then
		CDTL2_Ready_2.combatTimer = 0
	end
	
	if CDTL2_Ready_3 then
		CDTL2_Ready_3.combatTimer = 0
	end
end

--[[function CDTL2:ENCOUNTER_END()
	CDTL2:Print("ENCOUNTER_END")

	for _, cd in pairs(CDTL2.cooldowns) do
		if cd then
			CDTL2:Print("RESET: "..tostring(cd.data["name"]))

			if cd.data["id"] then
				local start, duration, enabled = CDTL2:GetSpellCooldown(cd.data["id"])

				CDTL2:Print("    "..cd.data["currentCD"])
				CDTL2:Print("    "..tostring(duration))
			end
		end
	end
end]]--

function CDTL2:SPELL_UPDATE_CHARGES()
	--CDTL2:Print("SPELL_UPDATE_CHARGES")
end

function CDTL2:UNIT_POWER_FREQUENT(...)
	local _, unitTarget, powerType = ...
	
	if unitTarget == "player" and powerType == "MANA" then
		if	CDTL2.db.profile.lanes["lane1"]["tracking"]["primaryTracking"] == "MANA_TICK" or
			CDTL2.db.profile.lanes["lane1"]["tracking"]["secondaryTracking"] == "MANA_TICK" or
			CDTL2.db.profile.lanes["lane2"]["tracking"]["primaryTracking"] == "MANA_TICK" or
			CDTL2.db.profile.lanes["lane2"]["tracking"]["secondaryTracking"] == "MANA_TICK" or
			CDTL2.db.profile.lanes["lane3"]["tracking"]["primaryTracking"] == "MANA_TICK" or
			CDTL2.db.profile.lanes["lane3"]["tracking"]["secondaryTracking"] == "MANA_TICK"
		then
			local currentTime = GetTime()
			local currentMana = UnitPower("player", Enum.PowerType.Mana)
			if currentMana ~= UnitPowerMax("player", Enum.PowerType.Mana) then
				local difference = currentMana - CDTL2.tracking["manaPrevious"]
							
				local timeDifference = 0
				if CDTL2.tracking["manaTime"] then
					timeDifference = currentTime - CDTL2.tracking["manaTime"]
				end
				
				if difference < 0 then
					if CDTL2.combat then
						CDTL2.tracking["manaTime"] = currentTime
						CDTL2.tracking["fsr"] = true
					end
				end
				
				if difference > 0 then
					local low = 0.1
					local high = 1.9
					
					if CDTL2.tracking["fsr"] then
						local high = 4.9
					end
					
					if timeDifference < low or  timeDifference > high then
						CDTL2.tracking["fsr"] = false
						CDTL2.tracking["manaTime"] = currentTime
					end
				end
				
				CDTL2.tracking["manaPrevious"] = currentMana
			end
		end
	end
end

function CDTL2:UNIT_POWER_UPDATE(...)
	local _, unitTarget, powerType = ...
	
	if unitTarget == "player" and powerType == "ENERGY" then
		if	CDTL2.db.profile.lanes["lane1"]["tracking"]["primaryTracking"] == "ENERGY_TICK" or
			CDTL2.db.profile.lanes["lane1"]["tracking"]["secondaryTracking"] == "ENERGY_TICK" or
			CDTL2.db.profile.lanes["lane2"]["tracking"]["primaryTracking"] == "ENERGY_TICK" or
			CDTL2.db.profile.lanes["lane2"]["tracking"]["secondaryTracking"] == "ENERGY_TICK" or
			CDTL2.db.profile.lanes["lane3"]["tracking"]["primaryTracking"] == "ENERGY_TICK" or
			CDTL2.db.profile.lanes["lane3"]["tracking"]["secondaryTracking"] == "ENERGY_TICK"
		then
			local currentTime = GetTime()
			local maxenergy = UnitPowerMax("player", Enum.PowerType.Energy)
			local currentEnergy = UnitPower("player", Enum.PowerType.Energy)
			
			if currentEnergy < maxenergy then
				local difference = currentEnergy - CDTL2.tracking["energyPrevious"]
				if (difference > 18 and difference < 22) or (difference > 38 and difference < 42) then
					CDTL2.tracking["energyTimeCount"] = 0
				end
			end
			
			CDTL2.tracking["energyPrevious"] = currentEnergy
		end
	end
end

function CDTL2:RUNE_POWER_UPDATE(...)
	local runeIndex, added = ...
	--local _, runeIndex, added = ...
	
	if CDTL2.db.profile.global["debugMode"] then
		CDTL2:Print("RUNES UPDATE: "..tostring(runeIndex).." - "..tostring(added))
	end
	
	if not added then
		local spellName = ""
		local icon = 0
		if runeIndex == 1 or runeIndex == 2 then
			spellName = "Blood Rune "..tostring(runeIndex)
			icon = 135770
		elseif runeIndex == 3 or runeIndex == 4 then
			spellName = "Unholy Rune "..tostring(runeIndex)
			icon = 135775
		elseif runeIndex == 5 or runeIndex == 6 then
			spellName = "Frost Rune "..tostring(runeIndex)
			icon = 135773
		end
		
		local s = CDTL2:GetSpellSettings(spellName, "runes")
		if s then
			if not s["ignored"] then
				local ef = CDTL2:GetExistingCooldown(s["name"], "runes")
				if ef then			
					local graceTime = GetTime() - ef.data["runeGraceTime"]
					if graceTime >= 2.5 then
						ef.data["baseCD"] = 7.5
					elseif graceTime > 0 then
						ef.data["baseCD"] = 10 - graceTime
					else
						ef.data["baseCD"] = 10
					end
					
					CDTL2:SendToLane(ef)
					CDTL2:SendToBarFrame(ef)
				else
					if CDTL2.db.profile.global["runes"]["enabled"] then
						CDTL2:CreateCooldown(CDTL2:GetUID(),"runes" , s)
					end
				end
			end
		else
			local s = {}
		
			s["name"] = spellName
			s["type"] = "runes"
			s["runeIndex"] = runeIndex
			s["icon"] = icon
			s["lane"] = CDTL2.db.profile.global["runes"]["defaultLane"]
			s["barFrame"] = CDTL2.db.profile.global["runes"]["defaultBar"]
			s["readyFrame"] = CDTL2.db.profile.global["runes"]["defaultReady"]
			s["enabled"] = CDTL2.db.profile.global["runes"]["showByDefault"]
			s["highlight"] = true
			s["pinned"] = false
			
			local start, duration, runeReady = CDTL2:GetRuneCooldown(runeIndex)

			if not isSecret(duration) then
				s["bCD"] = duration * 1000
			end
			s["usedBy"] = { CDTL2.player["guid"] }

			if isSecret(s["bCD"]) then
				s["ignored"] = false
			elseif s["bCD"] / 1000 > 3 and s["bCD"] / 1000 <= CDTL2.db.profile.global["runes"]["ignoreThreshold"] then
				s["ignored"] = false
			else
				s["ignored"] = true
			end
			
			table.insert(CDTL2.db.profile.tables["runes"], s)
			
			if not s["ignored"] then
				if CDTL2.db.profile.global["runes"]["enabled"] then
					CDTL2:CreateCooldown(CDTL2:GetUID(),"runes" , s)
				end
			end
		end
	else
		for _, rune in pairs(CDTL2.cooldowns) do
			if rune.data["runeIndex"] == runeIndex then
				rune.data["runeGraceTime"] = GetTime()
			end
		end
	end
end

function CDTL2:ACTIVE_TALENT_GROUP_CHANGED()
	C_Timer.After(2, function()
		CDTL2:OnTalentChanges()
	end)
end

function CDTL2:TRAIT_CONFIG_UPDATED()
	C_Timer.After(2, function()
		CDTL2:OnTalentChanges()
	end)
end

function CDTL2:RUNE_UPDATED()
	C_Timer.After(2, function()
		CDTL2:OnTalentChanges()
	end)
end

function CDTL2:PLAYER_ENTERING_WORLD()	
	local turnOn = CDTL2:DetermineOnOff()
	
	if turnOn then
		CDTL2:TurnOn()
	else
		CDTL2:TurnOff()
	end
end

function CDTL2:GROUP_JOINED()	
	local turnOn = CDTL2:DetermineOnOff()
	
	if turnOn then
		CDTL2:TurnOn()
	else
		CDTL2:TurnOff()
	end
end

function CDTL2:GROUP_LEFT()	
	local turnOn = CDTL2:DetermineOnOff()
	
	if turnOn then
		CDTL2:TurnOn()
	else
		CDTL2:TurnOff()
	end
end

function CDTL2:SPELLS_CHANGED(...)
    --CDTL2:Print("SPELLSCHANGED: re-scanning...")
    --CDTL2:ScanSpellbook()
end

function CDTL2:DetermineOnOff()
	local turnOn = false
	
	if CDTL2.db.profile.global["enabledAlways"] then
		turnOn = true
	else
		local inInstance, instanceType = IsInInstance()
		local inGroup = IsInGroup()
		
		if inInstance or inGroup then
			if inInstance and CDTL2.db.profile.global["enabledInstance"] then
				turnOn = true
			end
			
			if inGroup and CDTL2.db.profile.global["enabledGroup"] then
				turnOn = true
			end
		end
	end
	
	return turnOn
end

function CDTL2:TurnOn()	
	if not CDTL2.enabled then
		if CDTL2.db.profile.global["debugMode"] then
			CDTL2:Print("ENABLING DETECTION")
		end
	
		CDTL2:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		CDTL2:RegisterEvent("SPELL_UPDATE_CHARGES")
		CDTL2:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		CDTL2:RegisterEvent("ITEM_LOCK_CHANGED")
		CDTL2:RegisterEvent("PLAYER_REGEN_DISABLED")
		CDTL2:RegisterEvent("PLAYER_REGEN_ENABLED")
		CDTL2:RegisterEvent("UNIT_POWER_FREQUENT")
		CDTL2:RegisterEvent("UNIT_POWER_UPDATE")

		CDTL2:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		
		if CDTL2.tocversion >= 110000 then
			--CDTL2:RegisterEvent("TRAIT_CONFIG_UPDATED")
		end

		if CDTL2.tocversion < 20000 then
			CDTL2:RegisterEvent("RUNE_UPDATED")
		end
		
		CDTL2.enabled = true
	end
end

function CDTL2:TurnOff()
	if CDTL2.enabled then
		if CDTL2.db.profile.global["debugMode"] then
			CDTL2:Print("DISABLING DETECTION")
		end
		
		CDTL2:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		CDTL2:UnregisterEvent("SPELL_UPDATE_CHARGES")
		CDTL2:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		CDTL2:UnregisterEvent("ITEM_LOCK_CHANGED")
		CDTL2:UnregisterEvent("PLAYER_REGEN_DISABLED")
		CDTL2:UnregisterEvent("PLAYER_REGEN_ENABLED")
		CDTL2:UnregisterEvent("UNIT_POWER_FREQUENT")
		CDTL2:UnregisterEvent("UNIT_POWER_UPDATE")

		CDTL2:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		
		if CDTL2.tocversion >= 110000 then
			--CDTL2:UnregisterEvent("TRAIT_CONFIG_UPDATED")
		end

		if CDTL2.tocversion < 20000 then
			CDTL2:UnregisterEvent("RUNE_UPDATED")
		end
		
		CDTL2.enabled = false
	end
end

function IsNewerVersion()
	local nv = tostring(CDTL2.noticeVersion)
	local pv = tostring(CDTL2.db.profile.global["previousVersion"])

	local nv1, nv2 = nv:match("([^%.]*)%.?(.*)")
	nv1 = tonumber(nv1)
	nv2 = tonumber(nv2)

	local pv1, pv2 = pv:match("([^%.]*)%.?(.*)")
	pv1 = tonumber(pv1)
	pv2 = tonumber(pv2)

	if pv1 < nv1 then
		return true
	else
		if pv1 == nv1 then
			if pv2 < nv2 then
				return true
			end
		end
	end

	return false
end