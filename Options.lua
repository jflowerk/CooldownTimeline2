--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local private = {}

function CDTL2:GetChangeLog()
	local changeLog = ""
	changeLog = changeLog.."\n"
	changeLog = changeLog.."Changelog 2.6:\n\n"
	changeLog = changeLog.."  - Updated versions to be in-date\n"
	changeLog = changeLog.."  - ICDs are no longer supported\n"
	changeLog = changeLog.."  - Replacing ICDs is a the ability to add custom cooldowns\n"
	changeLog = changeLog.."      - You can access the new options in Filters > Custom\n"
	changeLog = changeLog.."      - You can specify if a custom cooldown is triggered by a spell cast, or gaining an aura\n"
	changeLog = changeLog.."      - You then specify a spell/aura ID and it should\n"
	changeLog = changeLog.."      - This should allow you to detect and track ICDs from trinkets, tier sets, or other such items\n"
	changeLog = changeLog.."  - Spells that don't get detected can now be added manually as a 'custom'\n"
	changeLog = changeLog.."  - Testing has been done on this on all versions of the game, but if there are any issues let me know\n"
	changeLog = changeLog.."  - The active filter should now default to the first entry for its type\n"
	changeLog = changeLog.."  - Some unused filter data will be removed next time the profile is loaded\n"
	changeLog = changeLog.."\n\n"
	changeLog = changeLog.."Changelog 2.6r1:\n\n"
	changeLog = changeLog.."  - Added an icon and colouring to display in the retail addon screen\n"
	changeLog = changeLog.."  - Added 'Test Mode', which allows you to generate test cooldowns\n"
	changeLog = changeLog.."      - These test cooldowns can be used to show how cooldowns of various types will appear\n"
	changeLog = changeLog.."      - You can access 'Test Mode' via the main options page or with the '/cdtl2 test' command\n"
	changeLog = changeLog.."  - Fixed an issue preventing cooldowns from resetting correctly\n"
	changeLog = changeLog.."  - Did some futher cleanup to remove references to ICDs and early custom framework\n"
	changeLog = changeLog.."\n\n"
	changeLog = changeLog.."Changelog 2.6r2:\n\n"
	changeLog = changeLog.."  - Updated for the latest versions of the game\n"
	changeLog = changeLog.."  - It appears to work out of the box in Mists of Pandaria, but let me know if there are errors\n"
	changeLog = changeLog.."\n\n"
	changeLog = changeLog.."Changelog 2.6r3:\n\n"
	changeLog = changeLog.."  - Updated for the latest versions of the game\n"
	changeLog = changeLog.."  - It appears to work out of the box in TBC Anniversary, but let me know if there are errors\n"
		
	return changeLog
end

function CDTL2:GetChangeLogMessage()
	local message = ""
	message = message.."\n"
	message = message.."CDTL2 is an almost complete re-write of the mod\n\n"
	message = message.."Version 1 settings are saved independent of version 2, so you can manually install and use old versions if you wish\n"
	message = message.."This also means version 1 settings will not roll over into version 2\n\n"
	message = message.."\n"
	
	return message
end

function CDTL2:GetSpecialMessage()
	local message = ""
	--message = message.."\n"
	--message = message.."Profile import/exporting testing is still ongoing.\n"
	--message = message.."\n"
	--message = message.."While I havent seen any issues with this feature yet, I want to make sure it works ok, so please provide feedback where appropriate.\n"
	--message = message.."\n"
		
	return message
end

function CDTL2:GetMainOptions()
	local options = {
		name = "CDTL2",
		type = "group",
		childGroups  = "tab",
		args = {
			global = {
				name = "Global",
				type = "group",
				order = 100,
				childGroups  = "tab",
				args = {
					spacer100 = {
						name = "\nEnabled:\n",
						type = "description",
						order = 100,
					},
					enabledAlways = {
						name = "Always",
						desc = "If selected, CD/Duration detection will always be on",
						order = 101,
						type = "toggle",
						--width = "full",
						get = function(info, index)
								return CDTL2.db.profile.global["enabledAlways"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["enabledAlways"] = val
								
								local turnOn = CDTL2:DetermineOnOff()
	
								if turnOn then
									CDTL2:TurnOn()
								else
									CDTL2:TurnOff()
								end
							end,
					},
					enabledGroup = {
						name = "In Group",
						desc = "If selected, CD/Duration detection will be enabled when in a party/raid",
						order = 102,
						type = "toggle",
						--width = "full",
						disabled = function(info)
								return CDTL2.db.profile.global["enabledAlways"]
							end,
						get = function(info, index)
								return CDTL2.db.profile.global["enabledGroup"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["enabledGroup"] = val
								
								local turnOn = CDTL2:DetermineOnOff()
	
								if turnOn then
									CDTL2:TurnOn()
								else
									CDTL2:TurnOff()
								end
							end,
					},
					enabledInstance = {
						name = "In Instance",
						desc = "If selected, CD/Duration detection will be enabled when in an instance/raid/bg/arena",
						order = 103,
						type = "toggle",
						--width = "full",
						disabled = function(info)
								return CDTL2.db.profile.global["enabledAlways"]
							end,
						get = function(info, index)
								return CDTL2.db.profile.global["enabledInstance"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["enabledInstance"] = val
								
								local turnOn = CDTL2:DetermineOnOff()
	
								if turnOn then
									CDTL2:TurnOn()
								else
									CDTL2:TurnOff()
								end
							end,
					},
					spacer199 = {
						name = "\n\n",
						type = "description",
						order = 199,
					},
					unlockFrames = {
						name = "Unlock Frames",
						desc = "Unlock frames to allow drag and drop movement",
						order = 200,
						type = "toggle",
						width = "full",
						get = function(info, index)
								return CDTL2.db.profile.global["unlockFrames"]
							end,
						set = function(info, val)
								CDTL2:ToggleFrameLock()
							end,
					},
					autohide = {
						name = "Auto-hide Frames",
						desc = "If selected frames will hide themselves when there is no active bar/icon in it",
						order = 201,
						type = "toggle",
						width = "full",
						get = function(info, index)
								return CDTL2.db.profile.global["autohide"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["autohide"] = val
								
								for i = 1, 3, 1 do
									CDTL2:RefreshLane(i)
									CDTL2:RefreshReady(i)
									CDTL2:RefreshBarFrame(i)
								end
							end,
					},
					enableTooltip = {
						name = "Enable tooltips",
						desc = "If selected mousing over icons will display a tooltip",
						order = 300,
						type = "toggle",
						width = "full",
						get = function(info, index)
								return CDTL2.db.profile.global["enableTooltip"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["enableTooltip"] = val
							end,
					},
					detectSharedCD = {
						name = "Detect Shared Spell Cooldowns",
						desc = "If selected the mod will attempt to dectect other spells that share a cooldown as the initially cast spell and generate icons/bars for them",
						order = 401,
						type = "toggle",
						width = "full",
						get = function(info, index)
								return CDTL2.db.profile.global["detectSharedCD"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["detectSharedCD"] = val
							end,
					},
					spacer500 = {
						name = "\n\n",
						type = "description",
						order = 500,
					},
					zoom = {
						name = "Icon Zoom",
						desc = "Sets the zoom level of icons",
						order = 501,
						type = "range",
						softMin = 1,
						softMax = 1.5,
						get = function(info, index)
								return CDTL2.db.profile.global["zoom"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["zoom"] = val
								CDTL2:RefreshAllIcons()
								CDTL2:RefreshAllBars()
							end,
					},
					spacer600 = {
						name = "\n\n",
						type = "description",
						order = 600,
					},
					notUsableTint = {
						name = "Tint Unsuable Icons",
						desc = "If selected unsuable icons (eg. not enough mana) will be desaturated/tinted",
						order = 601,
						type = "toggle",
						width = "full",
						get = function(info, index)
								return CDTL2.db.profile.global["notUsableTint"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["notUsableTint"] = val
							end,
					},
					spacer602 = {
						name = "",
						type = "description",
						order = 602,
						hidden = function(info)
								return not CDTL2.db.profile.global["notUsableTint"]
							end,
					},
					notUsableDesaturate = {
						name = "Desaturate",
						desc = "If selected non usable icons will be desaturated instead of colored",
						order = 603,
						type = "toggle",
						hidden = function(info)
								return not CDTL2.db.profile.global["notUsableTint"]
							end,
						get = function(info, index)
								return CDTL2.db.profile.global["notUsableDesaturate"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["notUsableDesaturate"] = val
							end,
					},
					notUsableColor = {
						name = "Not Usable Color",
						desc = "Select the tint color of non usable icons",
						order = 604,
						type = "color",
						hidden = function(info)
								return not CDTL2.db.profile.global["notUsableTint"]
							end,
						hasAlpha = true,
						get = function(info)
								local r = CDTL2.db.profile.global["notUsableColor"]["r"]
								local g = CDTL2.db.profile.global["notUsableColor"]["g"]
								local b = CDTL2.db.profile.global["notUsableColor"]["b"]
								local a = CDTL2.db.profile.global["notUsableColor"]["a"]
								
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["notUsableColor"] = { r = red, g = green, b = blue, a = alpha }							
								CDTL2:RefreshAllIcons()
							end,
					},
					spacer700 = {
						name = "\n\n",
						type = "description",
						order = 700,
					},
					openTestPanel = {
						name = function(info)
								return "Open Test Panel"
							end,
						desc = function(info)
								return ""
							end,
						order = 701,
						--width = "half",
						type = "execute",
						func = function(info)
								CDTL2:EnableTesting()
							end,
					},
				},
			},
			colors = {
				name = "Colors",
				type = "group",
				order = 200,
				childGroups  = "tab",
				args = {
					spacer100 = {
						name = "\nClass Colors",
						type = "description",
						fontSize = "large",
						order = 100,
					},
					spacer200 = {
						name = "\n",
						type = "description",
						order = 200,
					},
					deathknightColor = {
						name = "Death Knight",
						desc = "Set the Death Knight class color",
						order = 201,
						type = "color",
						hasAlpha = true,
						hidden = function(info)
							if CDTL2.tocversion >= 30000 then
								return false
							end
							
							return true
						end,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["DEATHKNIGHT"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["DEATHKNIGHT"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					demonhunterColor = {
						name = "Demon Hunter",
						desc = "Set the Demon Hunter class color",
						order = 202,
						type = "color",
						hasAlpha = true,
						hidden = function(info)
							if CDTL2.tocversion >= 70000 then
								return false
							end
							
							return true
						end,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["DEMONHUNTER"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["DEMONHUNTER"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					druidColor = {
						name = "Druid",
						desc = "Set the Druid class color",
						order = 203,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["DRUID"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["DRUID"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					evokerColor = {
						name = "Evoker",
						desc = "Set the Evoker class color",
						order = 204,
						type = "color",
						hasAlpha = true,
						hidden = function(info)
							if CDTL2.tocversion >= 100000 then
								return false
							end
							
							return true
						end,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["EVOKER"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["EVOKER"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					hunterColor = {
						name = "Hunter",
						desc = "Set the Hunter class color",
						order = 205,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["HUNTER"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["HUNTER"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					mageColor = {
						name = "Mage",
						desc = "Set the Mage class color",
						order = 206,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["MAGE"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["MAGE"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					monkColor = {
						name = "Monk",
						desc = "Set the Monk class color",
						order = 207,
						type = "color",
						hasAlpha = true,
						hidden = function(info)
							if CDTL2.tocversion >= 50000 then
								return false
							end
							
							return true
						end,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["MONK"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["MONK"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					paladinColor = {
						name = "Paladin",
						desc = "Set the Paladin class color",
						order = 208,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["PALADIN"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["PALADIN"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					priestColor = {
						name = "Priest",
						desc = "Set the Priest class color",
						order = 209,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["PRIEST"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["PRIEST"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					rogueColor = {
						name = "Rogue",
						desc = "Set the Rogue class color",
						order = 210,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["ROGUE"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["ROGUE"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					shamanColor = {
						name = "Shaman",
						desc = "Set the Shaman class color",
						order = 211,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["SHAMAN"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["SHAMAN"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					warlockColor = {
						name = "Warlock",
						desc = "Set the Warlock class color",
						order = 212,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["WARLOCK"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["WARLOCK"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
					warriorColor = {
						name = "Warrior",
						desc = "Set the Warrior class color",
						order = 213,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local t = CDTL2.db.profile.global["classColors"]["WARRIOR"]
								
								local r = t["r"]
								local g = t["g"]
								local b = t["b"]
								local a = t["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								CDTL2.db.profile.global["classColors"]["WARRIOR"] = { r = red, g = green, b = blue, a = alpha }
							end,
					},
				},
			},
			importexport = {
				name = "Import/Export",
				type = "group",
				order = 300,
				childGroups  = "tab",
				args = {
					spacer100 = {
						name = "\nExport",
						type = "description",
						fontSize = "large",
						order = 100,
						--width = "full",
					},
					exportMode = {
						name = "",
						desc = "What should be exported",
						order = 101,
						type = "select",
						values = {
								["ALL"] = "All Settings and Data",
								["CDDATA"] = "Cooldown Data Only",
								["SETTINGS"] = "CDTL2 Settings Only",
							},
						get = function(info, index)
								return CDTL2.db.profile.global["exportMode"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["exportMode"] = val
							end,
					},
					exportbox = {
						name = "",
						type = "input",
						multiline = 10,
						order = 200,
						width = "full",
						get = function(info)
								local exportMode = CDTL2.db.profile.global["exportMode"]

								local table = {}

								if exportMode == "CDDATA" then
									table = CDTL2:TableCopy(CDTL2.db.profile.tables)
								else
									table = CDTL2:TableCopy(CDTL2.db.profile)

									if exportMode == "SETTINGS" then
										table.tables.spells = {}
										table.tables.petspells = {}
										table.tables.items = {}
										table.tables.buffs = {}
										table.tables.debuffs = {}
										table.tables.offensives = {}
										table.tables.runes = {}
										table.tables.customs = {}
										table.tables.detected = {}
									end
								end

								-- SERIALIZE
								local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")	
								local serialized = LibAceSerializer:Serialize(table)

								-- DEFLATE
								local LibDeflate = LibStub:GetLibrary("LibDeflate")
								local deflated = LibDeflate:CompressDeflate(serialized)
								local printable = LibDeflate:EncodeForPrint(deflated)

								return printable
							end,
						set = function(info, val)
								return nil
							end,
					},
					spacer300 = {
						name = "\nImport",
						type = "description",
						fontSize = "large",
						order = 300,
						--width = "full",
					},
					importMode = {
						name = "",
						desc = "What should be imported",
						order = 301,
						type = "select",
						values = {
								["ALL"] = "All Settings and Data",
								["CDDATA"] = "Cooldown Data Only",
								["SETTINGS"] = "CDTL2 Settings Only",
							},
						get = function(info, index)
								return CDTL2.db.profile.global["importMode"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["importMode"] = val
							end,
					},
					importbox = {
						name = "",
						type = "input",
						multiline = 10,
						order = 400,
						width = "full",
						get = function(info)
								return ""
							end,
						set = function(info, val)
								return CDTL2:ImportHandler(val)
							end,
					},
				}
			},
			changelog = {
				name = "Changelog",
				type = "group",
				order = 400,
				childGroups  = "tab",
				args = {
					spacer100 = {
						name = function() return "CDTL2 v"..CDTL2.version.."\n\n" end,
						fontSize = "large",
						type = "description",
						order = 100,
					},
					cdtl2discord = {
						name = "Discord",
						type = "input",
						order = 200,
						width = "full",
						get = function(info)
							return CDTL2.discordlink
							end,
						set = function(info, val)
								return nil
							end,
					},
					spacer300 = {
						name = function(info)
							local info = ""
							--info = info..CDTL2:GetChangeLogMessage()
							info = info..CDTL2:GetChangeLog()
							return info
						end,
						type = "description",
						order = 300,
					},
				},
			},
		},
	}
	
	return options
end

function CDTL2:GetFilterOptions()
	local options = {
		name = "Filters",
		type = "group",
		childGroups  = "tab",
		args = {
			defaults = {
				name = "Defaults",
				type = "group",
				order = 100,
				args = {
					spacer100 = {
						name = "\n\nSelect a type to edit its default settings\n",
						type = "description",
						order = 100,
					},
					list = {
						name = "",
						desc = "",
						order = 101,
						type = "select",
						values = function(info)
								local choices = {}
									choices["SPELLS"] = "Spells"
									choices["ITEMS"] = "Items"
									choices["BUFFS"] = "Buffs"
									choices["DEBUFFS"] = "Debufs"
									choices["OFFENSIVES"] = "Offensives"
									choices["PETSPELLS"] = "Pet Spells"
									choices["CUSTOMS"] = "Customs"

									--[[if CDTL2.db.profile.global["debugMode"] then
										choices["OTHER"] = "Other"
									end]]--
									
								if CDTL2.player["class"] == "DEATHKNIGHT" then
									choices["RUNES"] = "Runes"
								end
								
								return choices
							end,
						get = function(info)
								return CDTL2.currentFilter["default"]
							end,
						set = function(info, val)
								CDTL2.currentFilter["default"] = val
								CDTL2.currentFilterHidden["default"] = false
							end,
					},
					spacer102 = {
						name = "\n",
						type = "description",
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						order = 102,
					},
					clearAll = {
						name = "Clear Settings",
						desc = function(info)
								return "This will clear all "..string.lower(CDTL2.currentFilter["default"]).." cooldown settings"
							end,
						confirm = true,
						order = 103,
						type = "execute",
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						func = function(info)
								local default = CDTL2.currentFilter["default"]
								
								for k, v in pairs(CDTL2.db.profile.tables[string.lower(default)]) do
									CDTL2.db.profile.tables[string.lower(default)][k]=nil
								end
								
								CDTL2.currentFilter[string.lower(default)] = "<< Select >>"
								CDTL2.currentFilterHidden[string.lower(default)] = true
							end
					},
					clearQuestItems = {
						name = "Clear Quest Items",
						desc = function(info)
								return "This will clear all "..string.lower(CDTL2.currentFilter["default"]).." cooldown settings"
							end,
						confirm = true,
						order = 104,
						type = "execute",
						hidden = function(info)
								if string.lower(CDTL2.currentFilter["default"]) ~= "items" then
									return true
								end
								
								return false
							end,
						func = function(info)
								local cleanTable = {}
						
								for k, v in pairs(CDTL2.db.profile.tables["items"]) do
									local _, _, _, _, _, classID, subclassID = GetItemInfoInstant(v["itemID"])
									
									if classID == 12 then
									else
										table.insert(cleanTable, v)
									end
								end
								
								CDTL2.db.profile.tables["items"] = cleanTable
							end
					},
					spacer200 = {
						name = "\n\n",
						type = "description",
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						order = 200,
					},
					enabled = {
						name = "Enabled",
						desc = "If unselected cooldowns of this type will be ignored",
						order = 201.1,
						type = "toggle",
						--width = "half",
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						get = function(info, index)
								local default = CDTL2.currentFilter["default"]
								return CDTL2.db.profile.global[string.lower(default)]["enabled"]
							end,
						set = function(info, val)
								local default = CDTL2.currentFilter["default"]
								CDTL2.db.profile.global[string.lower(default)]["enabled"] = val
								
								for _, cd in pairs(CDTL2.cooldowns) do
									if cd.data["type"] == string.lower(default) then
										cd.data["enabled"] = val
									end
								end
							end,
					},
					onlyPlayer = {
						name = "Player Only",
						desc = function(info)
								local default = string.lower(CDTL2.currentFilter["default"])
								return "If selected only "..default.." applied by the player will be tracked"
							end,
						order = 201.2,
						type = "toggle",
						--width = "half",
						hidden = function(info)
								local default = string.lower(CDTL2.currentFilter["default"])
								
								if default == "buffs" or default == "debuffs" then
									return false
								end
								
								return true
							end,
						get = function(info, index)
								local default = string.lower(CDTL2.currentFilter["default"])
								
								if default == "buffs" or default == "debuffs" then
									return CDTL2.db.profile.global[default]["onlyPlayer"]
								end
								
								return false
							end,
						set = function(info, val)
								local default = string.lower(CDTL2.currentFilter["default"])
								
								if default == "buffs" or default == "debuffs" then
									CDTL2.db.profile.global[default]["onlyPlayer"] = val
								end
							end,
					},
					showByDefault = {
						name = "Show by Default",
						desc = "If unselected you will need to manually enable each newly detected cooldown in order for them to show as bars/icons",
						order = 202.1,
						type = "toggle",
						--width = "half",
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						get = function(info, index)
								local default = CDTL2.currentFilter["default"]
								return CDTL2.db.profile.global[string.lower(default)]["showByDefault"]
							end,
						set = function(info, val)
								local default = CDTL2.currentFilter["default"]
								CDTL2.db.profile.global[string.lower(default)]["showByDefault"] = val
							end,
					},
					useItemIcon = {
						name = "Use Item Icon",
						desc = "If selected the displayed icon will be the item icon\nOtherwise the spell icon will be used instead",
						order = 202.1,
						type = "toggle",
						--width = "half",
						hidden = function(info)
								local default = string.lower(CDTL2.currentFilter["default"])
								
								if default == "items" then
									return false
								end
								
								return true
							end,
						get = function(info, index)
								local default = string.lower(CDTL2.currentFilter["default"])
								if default == "items" then
									return CDTL2.db.profile.global[default]["useItemIcon"]
								end
								
								return nil
							end,
						set = function(info, val)
								local default = string.lower(CDTL2.currentFilter["default"])
								if default == "items" then
									CDTL2.db.profile.global[default]["useItemIcon"] = val
									CDTL2:RefreshAllIcons()
									CDTL2:RefreshAllBars()
								end
							end,
					},
					spacer250 = {
						name = "\n\n",
						type = "description",
						order = 250,
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
					},
					ignoreThreshold = {
						name = "Ignore Threshold",
						desc = "Any cooldown/duration longer than this will be disabled by default\n",
						order = 251,
						type = "range",
						softMin = 5,
						softMax = 1800,
						bigStep = 1,
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						get = function(info, index)
								local default = CDTL2.currentFilter["default"]
								return CDTL2.db.profile.global[string.lower(default)]["ignoreThreshold"]
							end,
						set = function(info, val)
								local default = CDTL2.currentFilter["default"]
								CDTL2.db.profile.global[string.lower(default)]["ignoreThreshold"] = val
								
								for _, spell in pairs(CDTL2.cooldowns) do
									if spell.data["type"] == string.lower(default) then
										if spell.data["baseCD"] / 1000 > val then
											CDTL2:SendToHolding(spell)
											CDTL2:SendToBarHolding(spell)
										else
											CDTL2:SendToLane(spell)
											CDTL2:SendToBarFrame(spell)
										end
									end
								end
								
								for _, spell in pairs(CDTL2.db.profile.tables[string.lower(default)]) do
									if spell["bCD"] / 1000 > 3 and spell["bCD"] / 1000 <= val then
										spell["ignored"] = false
									else
										spell["ignored"] = true
									end
								end
								
								CDTL2:ScanCurrentCooldowns(CDTL2.player["class"], CDTL2.player["race"])
							end,
					},
					spacer300 = {
						name = "\n\n",
						type = "description",
						order = 300,
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
					},
					defaultLane = {
						name = "Default Lane",
						desc = function(info)
								return "Set the default lane all new "..string.lower(CDTL2.currentFilter["default"]).." icons will use"
							end,
						order = 301,
						type = "select",
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						width = "half",
						values = { [0] = "Hide", [1] = "1", [2] = "2", [3] = "3" },
						get = function(info)
								local default = CDTL2.currentFilter["default"]
								return CDTL2.db.profile.global[string.lower(default)]["defaultLane"]
							end,
						set = function(info, val)
								local default = CDTL2.currentFilter["default"]
								CDTL2.db.profile.global[string.lower(default)]["defaultLane"] = val
							end,
					},
					setDefaultLane = {
						name = "Set All",
						desc = function(info)
								return "This will override current settings, and set all "..string.lower(CDTL2.currentFilter["default"]).." cooldowns to the default value"
							end,
						confirm = true,
						order = 302,
						type = "execute",hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						width = "half",
						func = function(info)
								local default = CDTL2.currentFilter["default"]
								for _, spell in pairs(CDTL2.cooldowns) do
									if spell.data["type"] == string.lower(default) then
										if spell.data["baseCD"] > CDTL2.db.profile.global[string.lower(default)]["defaultLane"] then
											spell.data["enabled"] = false
										end
									end
								end
								
								for _, spell in pairs(CDTL2.db.profile.tables[string.lower(default)]) do
									spell["lane"] = CDTL2.db.profile.global[string.lower(default)]["defaultLane"]
								end
								
								CDTL2:RefreshAllIcons()
							end
					},
					spacer310 = {
						name = "\n",
						type = "description",
						order = 310,
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
					},
					defaultBar = {
						name = "Default Bar",
						desc = function(info)
								return "Set the default bar frame all new "..string.lower(CDTL2.currentFilter["default"]).." will use"
							end,
						order = 311,
						type = "select",
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						width = "half",
						values = { [0] = "Hide", [1] = "1", [2] = "2", [3] = "3" },
						get = function(info)
								local default = CDTL2.currentFilter["default"]
								return CDTL2.db.profile.global[string.lower(default)]["defaultBar"]
							end,
						set = function(info, val)
								local default = CDTL2.currentFilter["default"]
								CDTL2.db.profile.global[string.lower(default)]["defaultBar"] = val
							end,
					},
					setDefaultBar = {
						name = "Set All",
						desc = function(info)
								return "This will override current settings, and set all "..string.lower(CDTL2.currentFilter["default"]).." cooldowns to the default value"
							end,
						confirm = true,
						order = 312,
						type = "execute",
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						width = "half",
						func = function(info)
								local default = CDTL2.currentFilter["default"]
								for _, spell in pairs(CDTL2.cooldowns) do
									if spell.data["type"] == string.lower(default) then
										if spell.data["baseCD"] > CDTL2.db.profile.global[string.lower(default)]["defaultBar"] then
											spell.data["enabled"] = false
										end
									end
								end
								
								for _, spell in pairs(CDTL2.db.profile.tables[string.lower(default)]) do
									spell["barFrame"] = CDTL2.db.profile.global[string.lower(default)]["defaultBar"]
								end
								
								CDTL2:RefreshAllBars()
							end
					},
					spacer320 = {
						name = "\n",
						type = "description",
						order = 320,
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
					},
					defaultReady = {
						name = "Default Ready",
						desc = function(info)
								return "Set the default ready frame all new "..string.lower(CDTL2.currentFilter["default"]).." icons will use"
							end,
						order = 321,
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						type = "select",
						hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						width = "half",
						values = { [0] = "Hide", [1] = "1", [2] = "2", [3] = "3" },
						get = function(info)
								local default = CDTL2.currentFilter["default"]
								return CDTL2.db.profile.global[string.lower(default)]["defaultReady"]
							end,
						set = function(info, val)
								local default = CDTL2.currentFilter["default"]
								CDTL2.db.profile.global[string.lower(default)]["defaultReady"] = val
							end,
					},
					setDefaultReady = {
						name = "Set All",
						desc = function(info)
								return "This will override current settings, and set all "..string.lower(CDTL2.currentFilter["default"]).." cooldowns to the default value"
							end,
						confirm = true,
						order = 322,
						type = "execute",hidden = function(info)
								return CDTL2.currentFilterHidden["default"]
							end,
						width = "half",
						func = function(info)
								local default = CDTL2.currentFilter["default"]
								for _, spell in pairs(CDTL2.cooldowns) do
									if spell.data["type"] == string.lower(default) then
										if spell.data["baseCD"] > CDTL2.db.profile.global[string.lower(default)]["defaultReady"] then
											spell.data["enabled"] = false
										end
									end
								end
								
								for _, spell in pairs(CDTL2.db.profile.tables[string.lower(default)]) do
									spell["readyFrame"] = CDTL2.db.profile.global[string.lower(default)]["defaultReady"]
								end
								
								CDTL2:RefreshAllIcons()
							end
					},
				},
			},
			spells = private.GetFilterSet("spells", 100),
			items = private.GetFilterSet("items", 200),
			buffs = private.GetFilterSet("buffs", 300),
			debuffs = private.GetFilterSet("debuffs", 400),
			offensives = private.GetFilterSet("offensives", 500),
			petspells = private.GetFilterSet("petspells", 600),
			customs = private.GetCustomSet("customs", 800),
			runes = private.GetFilterSet("runes", 900),
		}
	}
	
	return options
end

function CDTL2:GetLaneOptions()
	local options = {
		name = "Lanes",
		type = "group",
		childGroups  = "tab",
		args = {
			--global = private.GetGlobalSet("lane"),
			lane1 = private.GetLaneSet(1),
			lane2 = private.GetLaneSet(2),
			lane3 = private.GetLaneSet(3),
		}
	}
	
	return options
end

function CDTL2:GetReadyOptions()
	local options = {
		name = "Ready",
		type = "group",
		childGroups  = "tab",
		args = {
			ready1 = private.GetReadySet(1),
			ready2 = private.GetReadySet(2),
			ready3 = private.GetReadySet(3),
		}
	}
	
	return options	
end

function CDTL2:GetBarFrameOptions()
	local options = {
		name = "Bar Frames",
		type = "group",
		childGroups  = "tab",
		args = {
			barFrame1 = private.GetBarFrameSet(1),
			barFrame2 = private.GetBarFrameSet(2),
			barFrame3 = private.GetBarFrameSet(3),
		}
	}
	
	return options	
end

private.GetGlobalSet = function(t)
	local options = {
		name = "Global",
		type = "group",
		order = 100,
		args = {
			spacer100 = {
				name = function(info)
							return "Global "..t.." options\n\n"
						end,
				type = "description",
				fontSize = "large",
				order = 100,
			},
			spacer101 = {
				name = "*WARNING*Making changes here will overide existing settings",
				type = "description",
				order = 101,
			},
			fgTexture = {
				name = "Foreground Texture",
				desc = "Selects the texture",
				order = 501,
				type = "select",
				width = 0.7,
				dialogControl = 'LSM30_Statusbar',
				values = AceGUIWidgetLSMlists.statusbar,
				get = function(info, index)
						return "None"
					end,
				set = function(info, val)
						CDTL2.db.profile.lanes["lane1"]["fgTexture"] = val
						CDTL2.db.profile.lanes["lane2"]["fgTexture"] = val
						CDTL2.db.profile.lanes["lane3"]["fgTexture"] = val
						CDTL2:RefreshLane(1)
						CDTL2:RefreshLane(2)
						CDTL2:RefreshLane(3)
					end,
			},
			fgTextureColor = {
				name = "Color",
				desc = "Sets the texture color",
				order = 502,
				type = "color",
				width = 0.4,
				hasAlpha = true,
				get = function(info)
						return CDTL2.db.profile.lanes["global"]["fgTextureColor"]
					end,
				set = function(info, red, green, blue, alpha)
						--lane["fgTextureColor"] = { r = red, g = green, b = blue, a = alpha }
						local color = { r = red, g = green, b = blue, a = alpha }
						
						CDTL2.db.profile.lanes["global"]["fgTextureColor"] = color
						CDTL2.db.profile.lanes["lane1"]["fgTextureColor"] = color
						CDTL2.db.profile.lanes["lane2"]["fgTextureColor"] = color
						CDTL2.db.profile.lanes["lane3"]["fgTextureColor"] = color
						CDTL2:RefreshLane(1)
						CDTL2:RefreshLane(2)
						CDTL2:RefreshLane(3)
					end,
			},
			fgClassColor = {
				name = "Class Color",
				desc = "Set the texture color to your class color",
				order = 503,
				type = "toggle",
				width = 0.5,
				get = function(info)
						return false
					end,
				set = function(info, val)
						--lane["fgClassColor"] = val
						CDTL2.db.profile.lanes["lane1"]["fgClassColor"] = val
						CDTL2.db.profile.lanes["lane2"]["fgClassColor"] = val
						CDTL2.db.profile.lanes["lane3"]["fgClassColor"] = val
						CDTL2:RefreshLane(1)
						CDTL2:RefreshLane(2)
						CDTL2:RefreshLane(3)
					end,
			},
			spacer600 = {
				name = "",
				type = "description",
				order = 600,
			},
			bgTexture = {
				name = "Background Texture",
				desc = "Sets the background texture",
				order = 601,
				type = "select",
				width = 0.7,
				dialogControl = 'LSM30_Statusbar',
				values = AceGUIWidgetLSMlists.statusbar,
				get = function(info, index)
						return "None"
					end,
				set = function(info, val)
						CDTL2.db.profile.lanes["lane1"]["bgTexture"] = val
						CDTL2.db.profile.lanes["lane2"]["bgTexture"] = val
						CDTL2.db.profile.lanes["lane3"]["bgTexture"] = val
						CDTL2:RefreshLane(1)
						CDTL2:RefreshLane(2)
						CDTL2:RefreshLane(3)
					end,
			},
		},
	}

	return options
end

private.GetBarFrameSet = function(i)
	local frame = nil
	
	if i == 1 then
		frame = CDTL2.db.profile.barFrames["frame1"]
	elseif i == 2 then
		frame = CDTL2.db.profile.barFrames["frame2"]
	elseif i == 3 then
		frame = CDTL2.db.profile.barFrames["frame3"]
	end
	
	local options = {
		name = function(info)
				return frame["name"]
			end,
		type = "group",
		order = 100,
		args = {
			general = {
				name = "General",
				type = "group",
				order = 100,
				args = {
					barFrameName = {
						name = "Frame Name",
						type = "input",
						order = 101,
						get = function(info)
								return frame["name"]
							end,
						set = function(info, val)
								frame["name"] = val
								CDTL2:RefreshBarFrame(i)
							end,
					},
					barFrameEnabled = {
						name = "Enabled",
						desc = "",
						order = 102,
						type = "toggle",
						get = function(info, index)
								return frame["enabled"]
							end,
						set = function(info, val)
								frame["enabled"] = val
								
								if val then
									CDTL2:CreateBarFrames()
								end
								
								CDTL2:RefreshBarFrame(i)
							end,
					},
					spacer200 = {
						name = "\n\n",
						type = "description",
						order = 200,
					},
					grow = {
						name = "Grow Direction",
						desc = "Select which direction new bars will grow in",
						order = 201,
						type = "select",
						values = {
								["UP"] = "UP",
								["DOWN"] = "DOWN",
								["LEFT"] = "LEFT",
								["RIGHT"] = "RIGHT",
								["CENTER_H"] = "CENTER (H)",
								["CENTER_V"] = "CENTER (V)",
							},
						get = function(info, index)
								return frame["grow"]
							end,
						set = function(info, val)
								frame["grow"] = val
							end,
					},
					spacer300 = {
						name = "\n\n",
						type = "description",
						order = 300,
					},
					hideTransitioned = {
						name = "Transition bars",
						desc = "If enabled, bars will be hidden once its cooldown drops below the lane max time, and its icon has appeared",
						order = 301,
						type = "toggle",
						get = function(info, index)
								return frame["transition"]["hideTransitioned"]
							end,
						set = function(info, val)
								frame["transition"]["hideTransitioned"] = val
							end,
					},
					spacer310 = {
						name = "",
						type = "description",
						order = 310,
						hidden = function(info)
								return not frame["transition"]["hideTransitioned"]
							end,
					},
					showTI = {
						name = "Show Indicator",
						desc = "If enabled, the bar will have an indicator showing when it will transition",
						order = 311,
						type = "toggle",
						hidden = function(info)
								return not frame["transition"]["hideTransitioned"]
							end,
						get = function(info, index)
								return frame["transition"]["showTI"]
							end,
						set = function(info, val)
								frame["transition"]["showTI"] = val
								CDTL2:RefreshAllBars()
							end,
					},
					style = {
						name = "Indicator Style",
						desc = "Select a style of indicator",
						order = 312,
						type = "select",
						hidden = function(info)
								if frame["transition"]["hideTransitioned"] then
									if frame["transition"]["showTI"] then
										return false
									end
								end
								
								return true
							end,
						values = {
								["SHORTEN"] = "Shorten",
								["LINE"] = "Line",
								["REGION"] = "Region",
							},
						get = function(info, index)
								return frame["transition"]["style"]
							end,
						set = function(info, val)
								frame["transition"]["style"] = val
								CDTL2:RefreshAllBars()
							end,
					},
					spacer320 = {
						name = "",
						type = "description",
						hidden = function(info)
								if frame["transition"]["hideTransitioned"] then
									if frame["transition"]["showTI"] then
										local style = frame["transition"]["style"]
										if style == "LINE" or style == "REGION" then
											return false
										end
									end
								end
								
								return true
							end,
						order = 320,
					},
					fgTexture = {
						name = "Indicator Texture",
						desc = "Selects the texture",
						order = 321,
						type = "select",
						hidden = function(info)
								if frame["transition"]["hideTransitioned"] then
									if frame["transition"]["showTI"] then
										local style = frame["transition"]["style"]
										if style == "LINE" or style == "REGION" then
											return false
										end
									end
								end
								
								return true
							end,
						dialogControl = 'LSM30_Statusbar',
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info, index)
								return frame["transition"]["texture"]
							end,
						set = function(info, val)
								frame["transition"]["texture"] = val
								CDTL2:RefreshAllBars()
							end,
					},
					fgTextureColor = {
						name = "Indicator Color",
						desc = "Sets the texture color",
						order = 322,
						type = "color",
						hidden = function(info)
								if frame["transition"]["hideTransitioned"] then
									if frame["transition"]["showTI"] then
										local style = frame["transition"]["style"]
										if style == "LINE" or style == "REGION" then
											return false
										end
									end
								end
								
								return true
							end,
						hasAlpha = true,
						get = function(info)
								local r = frame["transition"]["textureColor"]["r"]
								local g = frame["transition"]["textureColor"]["g"]
								local b = frame["transition"]["textureColor"]["b"]
								local a = frame["transition"]["textureColor"]["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								frame["transition"]["textureColor"] = { r = red, g = green, b = blue, a = alpha }
								CDTL2:RefreshAllBars()
							end,
					},
					spacer330 = {
						name = "",
						type = "description",
						order = 330,
						hidden = function(info)
								if frame["transition"]["hideTransitioned"] then
									if frame["transition"]["showTI"] then
										local style = frame["transition"]["style"]
										if style == "LINE" then
											return false
										end
									end
								end
								
								return true
							end,
					},
					widthTI = {
						name = "Indicator Line Width",
						desc = "Sets the width of the transition indicator line",
						order = 331,
						type = "range",
						hidden = function(info)
								if frame["transition"]["hideTransitioned"] then
									if frame["transition"]["showTI"] then
										local style = frame["transition"]["style"]
										if style == "LINE" then
											return false
										end
									end
								end
								
								return true
							end,
						softMin = 0,
						softMax = 40,
						bigStep = 1,
						get = function(info, index)
								return frame["transition"]["width"]
							end,
						set = function(info, val)
								frame["transition"]["width"] = val
						end,
					},
					
					spacer500 = {
						name = "\n\n",
						type = "description",
						order = 500,
					},
					xPadding = {
						name = "x Padding",
						desc = "Sets the x offset between growing bars",
						order = 601,
						type = "range",
						softMin = -20,
						softMax = 20,
						bigStep = 1,
						get = function(info, index)
								return frame["bar"]["xPadding"]
							end,
						set = function(info, val)
								frame["bar"]["xPadding"] = val
						end,
					},
					yPadding = {
						name = "y Padding",
						desc = "Sets the y offset between growing bars",
						order = 602,
						type = "range",
						softMin = -20,
						softMax = 20,
						bigStep = 1,
						get = function(info, index)
								return frame["bar"]["yPadding"]
							end,
						set = function(info, val)
								frame["bar"]["yPadding"] = val
						end,
					},
				}
			},
			appearance = {
				name = "Appearance",
				type = "group",
				order = 200,
				args = {
					posX = {
						name = "x Position",
						desc = "Sets the x position of the frame",
						order = 111,
						type = "range",
						softMin = -500,
						softMax = 500,
						bigStep = 1,
						get = function(info, index)
								return frame["posX"]
							end,
						set = function(info, val)
								frame["posX"] = val
								CDTL2:RefreshBarFrame(i)
							end,
					},
					posY = {
						name = "y Position",
						desc = "Sets the y position of the frame",
						order = 112,
						type = "range",
						softMin = -500,
						softMax = 500,
						bigStep = 1,
						get = function(info, index)
								return frame["posY"]
							end,
						set = function(info, val)
								frame["posY"] = val
								CDTL2:RefreshBarFrame(i)
							end,
					},
					spacer113 = {
						name = "",
						type = "description",
						order = 113,
					},
					relativeTo = {
						name = "Anchor Point",
						desc = "The x/y position is relative to this point of the screen",
						order = 114,
						type = "select",
						values = {
								["TOPLEFT"] = "TOPLEFT",
								["TOP"] = "TOP",
								["TOPRIGHT"] = "TOPRIGHT",
								["LEFT"] = "LEFT",
								["CENTER"] = "CENTER",
								["RIGHT"] = "RIGHT",
								["BOTTOMLEFT"] = "BOTTOMLEFT",
								["BOTTOM"] = "BOTTOM",
								["BOTTOMRIGHT"] = "BOTTOMRIGHT",
							},
						get = function(info, index)
								return frame["relativeTo"]
							end,
						set = function(info, val)
								frame["relativeTo"] = val
								CDTL2:RefreshBarFrame(i)
							end,
					},
					spacer200 = {
						name = "\n\n",
						type = "description",
						order = 200,
					},
					padding = {
						name = "Padding",
						desc = "Sets the amount of padding in the frame",
						order = 201,
						type = "range",
						softMin = 0,
						softMax = 40,
						bigStep = 1,
						get = function(info, index)
								return frame["padding"]
							end,
						set = function(info, val)
								frame["padding"] = val
								CDTL2:RefreshAllIcons()
								CDTL2:RefreshBarFrame(i)
						end,
					},
					spacer300 = {
						name = "\n\n",
						type = "description",
						order = 300,
					},
					bgTexture = {
						name = "Background Texture",
						desc = "Sets the background texture",
						order = 301,
						type = "select",
						dialogControl = 'LSM30_Statusbar',
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info, index)
								return frame["bgTexture"]
							end,
						set = function(info, val)
								frame["bgTexture"] = val
								CDTL2:RefreshBarFrame(i)
							end,
					},
					bgTextureColor = {
						name = "Color",
						desc = "Sets the background texture color",
						order = 302,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local r = frame["bgTextureColor"]["r"]
								local g = frame["bgTextureColor"]["g"]
								local b = frame["bgTextureColor"]["b"]
								local a = frame["bgTextureColor"]["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								frame["bgTextureColor"] = { r = red, g = green, b = blue, a = alpha }
								CDTL2:RefreshBarFrame(i)
							end,
					},
					spacer400 = {
						name = "\n\n",
						type = "description",
						order = 400,
					},
					border = {
						name = "                    Border Texture",
						desc = "Selects the border texture",
						order = 401,
						type = "select",
						dialogControl = 'LSM30_Border',
						values = AceGUIWidgetLSMlists.border,
						get = function(info) return frame["border"]["style"] end,
						set = function(info, val)
								frame["border"]["style"] = val
								CDTL2:RefreshBarFrame(i)
							end,
					},
					borderColor = {
						name = "Color",
						desc = "Selects the border color",
						order = 402,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local r = frame["border"]["color"]["r"]
								local g = frame["border"]["color"]["g"]
								local b = frame["border"]["color"]["b"]
								local a = frame["border"]["color"]["a"]
								
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								frame["border"]["color"] = { r = red, g = green, b = blue, a = alpha }							
								CDTL2:RefreshBarFrame(i)
							end,
					},
					spacer410 = {
						name = "",
						type = "description",
						order = 410,
					},
					borderSize = {
						name = "Size",
						desc = "Sets the size of the border",
						order = 411,
						type = "range",
						softMin = 1,
						softMax = 40,
						bigStep = 1,
						get = function(info) return frame["border"]["size"] end,
						set = function(info, val)
								frame["border"]["size"] = val
								CDTL2:RefreshBarFrame(i)
							end,
					},
					borderPadding = {
						name = "Padding",
						desc = "Sets the size of the border",
						order = 412,
						type = "range",
						softMin = 0,
						softMax = 40,
						bigStep = 1,
						get = function(info) return frame["border"]["padding"] end,
						set = function(info, val)
								frame["border"]["padding"] = val
								CDTL2:RefreshBarFrame(i)
							end,
					},
				}
			},
			bars = {
				name = "Bars",
				type = "group",
				order = 300,
				args = {
					width = {
						name = "Width",
						desc = "Sets the width of the bars",
						order = 101,
						type = "range",
						softMin = 1,
						softMax = 300,
						bigStep = 1,
						get = function(info, index)
								return frame["width"]
							end,
						set = function(info, val)
								frame["width"] = val
								CDTL2:RefreshAllBars()
								CDTL2:RefreshBarFrame(i)
						end,
					},
					height = {
						name = "Height",
						desc = "Sets the height of the bars",
						order = 102,
						type = "range",
						softMin = 1,
						softMax = 100,
						bigStep = 1,
						get = function(info, index)
								return frame["height"]
							end,
						set = function(info, val)
								frame["height"] = val
								CDTL2:RefreshAllBars()
								CDTL2:RefreshBarFrame(i)
						end,
					},
					spacer102 = {
						name = "\n\n",
						type = "description",
						order = 103,
					},
					fgTexture = {
						name = "Foreground Texture",
						desc = "Selects the texture",
						order = 104,
						type = "select",
						width = 0.7,
						dialogControl = 'LSM30_Statusbar',
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info, index)
								return frame["bar"]["fgTexture"]
							end,
						set = function(info, val)
								frame["bar"]["fgTexture"] = val
								CDTL2:RefreshAllBars()
							end,
					},
					fgTextureColor = {
						name = "Color",
						desc = "Sets the texture color",
						order = 105,
						type = "color",
						width = 0.4,
						hasAlpha = true,
						disabled  = function(info)
								if frame["bar"]["fgClassColor"] or frame["bar"]["fgSchoolColor"] then
									return true
								end
								
								return false
							end,
						get = function(info)								
								local c = frame["bar"]["fgTextureColor"]
								if frame["bar"]["fgClassColor"] then
									c = CDTL2.db.profile.global["classColors"][CDTL2.player["class"]]
								end
						
								local r = c["r"]
								local g = c["g"]
								local b = c["b"]
								local a = c["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								frame["bar"]["fgTextureColor"] = { r = red, g = green, b = blue, a = alpha }
								CDTL2:RefreshAllBars()
							end,
					},
					fgClassColor = {
						name = "Class Color",
						desc = "Set the texture color to your class color",
						order = 107,
						type = "toggle",
						width = 0.5,
						get = function(info)
								return frame["bar"]["fgClassColor"]
							end,
						set = function(info, val)
								frame["bar"]["fgClassColor"] = val
								CDTL2:RefreshAllBars()
							end,
					},
					spacer109 = {
						name = "",
						type = "description",
						order = 109,
					},
					bgTexture = {
						name = "Background Texture",
						desc = "Sets the background texture",
						order = 110,
						type = "select",
						width = 0.7,
						dialogControl = 'LSM30_Statusbar',
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info, index)
								return frame["bar"]["bgTexture"]
							end,
						set = function(info, val)
								frame["bar"]["bgTexture"] = val
								CDTL2:RefreshAllBars(i)
							end,
					},
					bgTextureColor = {
						name = "Color",
						desc = "Sets the background texture color",
						order = 111,
						type = "color",
						width = 0.4,
						hasAlpha = true,
						disabled  = function(info)
								if frame["bar"]["bgClassColor"] or frame["bar"]["bgSchoolColor"] then
									return true
								end
								
								return false
							end,
						get = function(info)
								local c = frame["bar"]["bgTextureColor"]
								if frame["bar"]["bgClassColor"] then
									c = CDTL2.db.profile.global["classColors"][CDTL2.player["class"]]
								end
						
								local r = c["r"]
								local g = c["g"]
								local b = c["b"]
								local a = c["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								frame["bar"]["bgTextureColor"] = { r = red, g = green, b = blue, a = alpha }
								CDTL2:RefreshAllBars(i)
							end,
					},
					bgClassColor = {
						name = "Class Color",
						desc = "Set the texture color to your class color",
						order = 113,
						type = "toggle",
						width = 0.5,
						get = function(info)
								return frame["bar"]["bgClassColor"]
							end,
						set = function(info, val)
								frame["bar"]["bgClassColor"] = val
								CDTL2:RefreshAllBars()
							end,
					},
					spacer115 = {
						name = "\n\n",
						type = "description",
						order = 115,
					},
					textHeader = {
						name = "Bar Text",
						type = "header",
						order = 200.1,
					},
					-- BAR TEXT 1
					bText1Text = private.GetTextText(frame["bar"]["text1"], 210, i, "BAR", false),
					bText1Enabled = private.GetTextEnabled(frame["bar"]["text1"], 210, i, "BAR"),
					bText1Edit = private.GetTextEdit(frame["bar"]["text1"], 210, i, "BAR"),
					bText1Font = private.GetTextFont(frame["bar"]["text1"], 210, i, "BAR"),
					bText1Outline = private.GetTextOutline(frame["bar"]["text1"], 210, i, "BAR"),
					bText1S1 = { name = "", type = "description", order = 210 + 4.3, hidden = function(info) return not frame["bar"]["text1"]["edit"] end, },
					bText1Size = private.GetTextSize(frame["bar"]["text1"], 210, i, "BAR"),
					bText1Color = private.GetTextColor(frame["bar"]["text1"], 210, i, "BAR"),
					bText1ShadowColor = private.GetTextShadowColor(frame["bar"]["text1"], 210, i, "BAR"),
					bText1S2 = { name = "", type = "description", order = 210 + 4.7, hidden = function(info) return not frame["bar"]["text1"]["edit"] end, },
					bText1ShadowXOffset = private.GetTextShadowXOffset(frame["bar"]["text1"], 210, i, "BAR"),
					bText1ShadowYOffset = private.GetTextShadowYOffset(frame["bar"]["text1"], 210, i, "BAR"),
					bText1S3 = { name = "", type = "description", order = 210 + 5.1, hidden = function(info) return not frame["bar"]["text1"]["edit"] end, },
					bText1Anchor = private.GetTextAnchor(frame["bar"]["text1"], 210, i, "BAR"),
					bText1Align = private.GetTextAlign(frame["bar"]["text1"], 210, i, "BAR"),
					bText1S4 = { name = "", type = "description", order = 210 + 5.4, hidden = function(info) return not frame["bar"]["text1"]["edit"] end, },
					bText1XOffset = private.GetTextXOffset(frame["bar"]["text1"], 210, i, "BAR"),
					bText1YOffset = private.GetTextYOffset(frame["bar"]["text1"], 210, i, "BAR"),
					bText1Footer = { name = "", type = "header", order = 210 + 9.8, hidden = function(info) return not frame["bar"]["text1"]["edit"] end, },
					-- BAR TEXT 2
					bText2S0 = { name = "\n", type = "description", order = 220, hidden = function(info) return not frame["bar"]["text2"]["used"] end, },
					bText2Header = { name = "", type = "header", order = 220 + 0.1, hidden = function(info) return not frame["bar"]["text2"]["edit"] end, },
					bText2Text = private.GetTextText(frame["bar"]["text2"], 220, i, "BAR", false),
					bText2Enabled = private.GetTextEnabled(frame["bar"]["text2"], 220, i, "BAR"),
					bText2Edit = private.GetTextEdit(frame["bar"]["text2"], 220, i, "BAR"),
					bText2Font = private.GetTextFont(frame["bar"]["text2"], 220, i, "BAR"),
					bText2Outline = private.GetTextOutline(frame["bar"]["text2"], 220, i, "BAR"),
					bText2S1 = { name = "", type = "description", order = 220 + 4.3, hidden = function(info) return not frame["bar"]["text2"]["edit"] end, },
					bText2Size = private.GetTextSize(frame["bar"]["text2"], 220, i, "BAR"),
					bText2Color = private.GetTextColor(frame["bar"]["text2"], 220, i, "BAR"),
					bText2ShadowColor = private.GetTextShadowColor(frame["bar"]["text2"], 220, i, "BAR"),
					bText2S2 = { name = "", type = "description", order = 220 + 4.7, hidden = function(info) return not frame["bar"]["text2"]["edit"] end, },
					bText2ShadowXOffset = private.GetTextShadowXOffset(frame["bar"]["text2"], 220, i, "BAR"),
					bText2ShadowYOffset = private.GetTextShadowYOffset(frame["bar"]["text2"], 220, i, "BAR"),
					bText2S3 = { name = "", type = "description", order = 220 + 5.1, hidden = function(info) return not frame["bar"]["text2"]["edit"] end, },
					bText2Anchor = private.GetTextAnchor(frame["bar"]["text2"], 220, i, "BAR"),
					bText2Align = private.GetTextAlign(frame["bar"]["text2"], 220, i, "BAR"),
					bText2S4 = { name = "", type = "description", order = 220 + 5.4, hidden = function(info) return not frame["bar"]["text2"]["edit"] end, },
					bText2XOffset = private.GetTextXOffset(frame["bar"]["text2"], 220, i, "BAR"),
					bText2YOffset = private.GetTextYOffset(frame["bar"]["text2"], 220, i, "BAR"),
					bText2Footer = { name = "", type = "header", order = 220 + 9.8, hidden = function(info) return not frame["bar"]["text2"]["edit"] end, },
					-- BAR TEXT 3
					bText3S0 = { name = "\n", type = "description", order = 230, hidden = function(info) return not frame["bar"]["text3"]["used"] end, },
					bText3Header = { name = "", type = "header", order = 230 + 0.1, hidden = function(info) return not frame["bar"]["text3"]["edit"] end, },
					bText3Text = private.GetTextText(frame["bar"]["text3"], 230, i, "BAR", false),
					bText3Enabled = private.GetTextEnabled(frame["bar"]["text3"], 230, i, "BAR"),
					bText3Edit = private.GetTextEdit(frame["bar"]["text3"], 230, i, "BAR"),
					bText3Font = private.GetTextFont(frame["bar"]["text3"], 230, i, "BAR"),
					bText3Outline = private.GetTextOutline(frame["bar"]["text3"], 230, i, "BAR"),
					bText3S1 = { name = "", type = "description", order = 230 + 4.3, hidden = function(info) return not frame["bar"]["text3"]["edit"] end, },
					bText3Size = private.GetTextSize(frame["bar"]["text3"], 230, i, "BAR"),
					bText3Color = private.GetTextColor(frame["bar"]["text3"], 230, i, "BAR"),
					bText3ShadowColor = private.GetTextShadowColor(frame["bar"]["text3"], 230, i, "BAR"),
					bText3S2 = { name = "", type = "description", order = 230 + 4.7, hidden = function(info) return not frame["bar"]["text3"]["edit"] end, },
					bText3ShadowXOffset = private.GetTextShadowXOffset(frame["bar"]["text3"], 230, i, "BAR"),
					bText3ShadowYOffset = private.GetTextShadowYOffset(frame["bar"]["text3"], 230, i, "BAR"),
					bText3S3 = { name = "", type = "description", order = 230 + 5.1, hidden = function(info) return not frame["bar"]["text3"]["edit"] end, },
					bText3Anchor = private.GetTextAnchor(frame["bar"]["text3"], 230, i, "BAR"),
					bText3Align = private.GetTextAlign(frame["bar"]["text3"], 230, i, "BAR"),
					bText3S4 = { name = "", type = "description", order = 230 + 5.4, hidden = function(info) return not frame["bar"]["text3"]["edit"] end, },
					bText3XOffset = private.GetTextXOffset(frame["bar"]["text3"], 230, i, "BAR"),
					bText3YOffset = private.GetTextYOffset(frame["bar"]["text3"], 230, i, "BAR"),
					bText3Footer = { name = "", type = "header", order = 230 + 9.8, hidden = function(info) return not frame["bar"]["text3"]["edit"] end, },
					spacer298 = {
						name = "\n",
						type = "description",
						order = 298,
					},
					textFooter = {
						name = "",
						type = "header",
						order = 299,
					},
					spacer300 = {
						name = "\n\n",
						type = "description",
						order = 300,
					},
					iconEnabled = {
						name = "Show icon",
						desc = "",
						order = 301,
						type = "toggle",
						get = function(info, index)
								return frame["bar"]["iconEnabled"]
							end,
						set = function(info, val)
								frame["bar"]["iconEnabled"] = val
								CDTL2:RefreshAllBars()
							end,
					},
					iconPosition = {
						name = "Icon position",
						desc = "Which side of the bar should the icon appear",
						order = 302,
						type = "select",
						values = {
								["LEFT"] = "Left",
								["RIGHT"] = "Right",
							},
						get = function(info, index)
								return frame["bar"]["iconPosition"]
							end,
						set = function(info, val)
								frame["bar"]["iconPosition"] = val
								CDTL2:RefreshAllBars()
							end,
					},
					spacer400 = {
						name = "\n\n",
						type = "description",
						order = 400,
					},
					border = {
						name = "                    Border Texture",
						desc = "Selects the border texture",
						order = 401,
						type = "select",
						dialogControl = 'LSM30_Border',
						values = AceGUIWidgetLSMlists.border,
						get = function(info) return frame["bar"]["border"]["style"] end,
						set = function(info, val)
								frame["bar"]["border"]["style"] = val
								CDTL2:RefreshAllBars()
							end,
					},
					borderColor = {
						name = "Color",
						desc = "Selects the border color",
						order = 402,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local r = frame["bar"]["border"]["color"]["r"]
								local g = frame["bar"]["border"]["color"]["g"]
								local b = frame["bar"]["border"]["color"]["b"]
								local a = frame["bar"]["border"]["color"]["a"]
								
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								frame["bar"]["border"]["color"] = { r = red, g = green, b = blue, a = alpha }							
								CDTL2:RefreshAllBars()
							end,
					},
					spacer410 = {
						name = "",
						type = "description",
						order = 410,
					},
					borderSize = {
						name = "Size",
						desc = "Sets the size of the border",
						order = 411,
						type = "range",
						softMin = 1,
						softMax = 40,
						bigStep = 1,
						get = function(info) return frame["bar"]["border"]["size"] end,
						set = function(info, val)
								frame["bar"]["border"]["size"] = val
								CDTL2:RefreshAllBars()
							end,
					},
					borderPadding = {
						name = "Padding",
						desc = "Sets the size of the border",
						order = 411,
						type = "range",
						softMin = 0,
						softMax = 40,
						bigStep = 1,
						get = function(info) return frame["bar"]["border"]["padding"] end,
						set = function(info, val)
								frame["bar"]["border"]["padding"] = val
								CDTL2:RefreshAllBars()
							end,
					},
				}
			},
		}
	}
	
	return options
end

private.GetFilterSet = function(t, o)
	local options = {
		name = function(info)
				if t == "customs" then
					return "Custom"
				end

				return t:gsub("^%l", string.upper)
			end,
		type = "group",
		order = o,
		hidden = function(info)
				if t == "runes" then
					if CDTL2.player["class"] ~= "DEATHKNIGHT" then
						return true
					end
				end

				return false
			end,
		args = {
			spacer100 = {
				name = "\n\nSelect something to edit its settings\n",
				type = "description",
				order = 100,
			},
			list = {
				name = function(info)
						local n = ""
						return n
					end,
				desc = function(info)
						local n = ""
						return n
					end,
				order = 101,
				type = "select",
				values = function(info)
						local list = {}
						if t == "items" then
							list = CDTL2:LoadFilterList(t, true)
						else
							list = CDTL2:LoadFilterList(t)
						end
						return list
					end,
				get = function(info)
						return CDTL2.currentFilter[t]
					end,
				set = function(info, val)
						local list = {}
						if t == "items" then
							list = CDTL2:LoadFilterList(t, true)
						else
							list = CDTL2:LoadFilterList(t)
						end

						CDTL2.currentFilter[t] = list[val]
						CDTL2.currentFilterHidden[t] = false
					end,
			},
			spacer110 = {
				--name = "*Spells will show up here once they have been detected at least once*\n\n\n",
				name = function(info)
					if t == "customs" then
						return "*Custom cooldowns will appear here once saved*\n\n\n"
					end

					return "*Cooldowns will appear here once they have been detected at least once*\n\n\n"
					end,
				type = "description",
				order = 110,
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
			},
			triggerType = {
				name = "Trigger Type",
				desc = "What will trigger the cooldown to begin, a spell or aura?",
				order = 111,
				hidden = function(info)
						if t == "customs" then
							return CDTL2.currentFilterHidden[t]
						end

						return true
					end,
				type = "select",
				width = "half",
				values = function(info)
						local choices = {}
						choices["spell"] = "Spell"
						choices["aura"] = "Aura"
							
						return choices
					end,
				get = function(info)
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if CDTL2.custom["triggerType"] then
									return CDTL2.custom["triggerType"]
								end
							else
								local s = CDTL2:GetSpellSettings(CDTL2.currentFilter["customs"], t, false)
								if s then
									return s["triggerType"]
								end
							end
						end

						return ""
					end,
				set = function(info, val)
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								CDTL2.custom["triggerType"] = val
							else
								local s = CDTL2:GetSpellSettings(CDTL2.currentFilter["customs"], t, false)
								if s then
									s["triggerType"] = val
								end
							end
						end
					end,
			},
			triggerID = {
				name = "Trigger ID",
				desc = "Entering a valid Spell/Aura ID here will populate the other fields",
				type = "input",
				order = 112,
				hidden = function(info)
						if t == "customs" then
							return CDTL2.currentFilterHidden[t]
						end

						return true
					end,
				disabled = function ()
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if not CDTL2.custom["triggerType"] then
									return true
								end
							else
								local s = CDTL2:GetSpellSettings(CDTL2.currentFilter["customs"], "customs", false)
								if s then
									if s["triggerType"] == "" then
										return true
									end
								end 
							end
						end

						return false
					end,
				get = function(info)
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if CDTL2.custom["id"] then
									return CDTL2.custom["id"]
								end
							else
								local s = CDTL2:GetSpellSettings(CDTL2.currentFilter["customs"], "customs", false)
								if s then
									return tostring(s["id"])
								end
							end
						end

						return ""
					end,
				set = function(info, val)
						if CDTL2.currentFilter[t] == "<< Add New >>" then
							local spellName, icon, originalIcon = CDTL2:GetSpellInfo(val)

							if spellName then
								CDTL2.custom["id"] = tonumber(val)
								CDTL2.custom["name"] = spellName
								CDTL2.custom["icon"] = icon
								CDTL2.custom["type"] = "customs"

								CDTL2.custom["bCD"] = 60000
								CDTL2.custom["usedBy"] = { CDTL2.player["guid"] }
								CDTL2.custom["setCustomCD"] = false
								
								local link, _ = CDTL2:GetSpellLink(val)
								CDTL2.custom["link"] = link

								local cDefaults = CDTL2.db.profile.global["customs"]
								CDTL2.custom["enabled"] = cDefaults["showByDefault"]
								CDTL2.custom["highlight"] = true
								CDTL2.custom["pinned"] = false
								CDTL2.custom["ignored"] = false
								CDTL2.custom["lane"] = cDefaults["defaultLane"]
								CDTL2.custom["barFrame"] = cDefaults["defaultBar"]
								CDTL2.custom["readyFrame"] = cDefaults["defaultReady"]

								CDTL2.customIsValid = true
							else
								CDTL2.custom = {}
								CDTL2.customIsValid = false
							end
						else
							-- Setup editing
						end
					end,
			},
			spacer113 = {
				name = "\n",
				type = "description",
				order = 113,
				hidden = function(info)
						if t == "customs" then
							return CDTL2.currentFilterHidden[t]
						end

						return true
					end,
			},
			itemTypePrefix = {
				name = function(info)
						local n = "Item:   "
						
						return n
					end,
				type = "description",
				order = 200,
				width = 0.2,
				hidden = function(info)
						if not CDTL2.currentFilterHidden[t] then
							if t == "items" then
								return false
							end
						end
						
						return true
					end,
			},
			itemName = {
				name = function(info)
						local n = ""
						if t == "items" then
							local specialCase = true
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if CDTL2.currentFilter[t] then
								if s and s["link"] then
									n = "  "..s["link"]
								else
									n = CDTL2.currentFilter[t]
								end
							end
						end
						
						return n
					end,
				type = "description",
				order = 201,
				width = 1.5,
				fontSize = "large",
				hidden = function(info)
						if not CDTL2.currentFilterHidden[t] then
							if t == "items" then
								return false
							end
						end
						
						return true
					end,
				image = function(info)
					local specialCase = false
					if t == "items" then
						specialCase = true
					end
					local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
					
					if s then
						return s["itemIcon"]
					else
						return 134400
					end
				end,
				imageWidth = 24,
				imageHeight = 24,
				imageCoords = {0.1,0.9,0.1,0.9},
			},
			spacer202 = {
				name = "",
				type = "description",
				order = 202,
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
			},
			cdType = {
				name = function(info)
						local n = " "
						
						if t == "spells" or t == "items" or t == "petspells" then
							n = "Spell:   "
						elseif t == "buffs" or t == "debuffs" or t == "offensives" then
							n = "Aura:   "
						elseif t == "runes" then
							n = "Rune:   "
						elseif t == "customs" then
							n = "Name:   "
						end
						
						return n
					end,
				type = "description",
				order = 203,
				width = 0.2,
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
			},
			cdName = {
				name = function(info)
						local n = " "
						
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if CDTL2.custom["name"] then
									n = CDTL2.custom["name"]
								else
									if CDTL2.customIsValid == false then
										n = "Enter valid trigger ID"
									else
										n = "New Custom"
									end
								end
							else
								n = CDTL2.currentFilter[t]
							end
						else
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if CDTL2.currentFilter[t] then
								if s then
									n = "  "..s["name"]
								else
									n = CDTL2.currentFilter[t]
								end
							end
						end
						
						return n
					end,
				type = "description",
				order = 205,
				width = 1.5,
				fontSize = "large",
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
				image = function(info)
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if CDTL2.custom["icon"] then
									return CDTL2.custom["icon"]
								else
									return 134400
								end
							else
								local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
								if s then
									return s["icon"]
								else
									return 134400
								end
							end
						else
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if s then
								return s["icon"]
							else
								return 134400
							end
						end
					end,
				imageWidth = 24,
				imageHeight = 24,
				imageCoords = {0.1,0.9,0.1,0.9},
			},
			spacer300 = {
				name = " \n",
				type = "description",
				order = 300,
				width = "full",
			},
			cooldownType = {
				name = function(info)
						local n = " "
						
						if t == "spells" or t == "items" or t == "petspells" or t == "customs" then
							n = "Cooldown:"
						elseif t == "buffs" or t == "debuffs" or t == "offensives" then
							n = "Duration:"
						elseif t == "runes" then
							n = "Recharge:"
						end
						
						return n
					end,
				type = "description",
				order = 301,
				width = 0.3,
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
			},
			cooldownValue = {
				name = function(info)
						local n = " "

						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							n = 0
						else
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if s then
								n =	n.."  "..(s["bCD"] / 1000).." sec\n"
							end								
						end
						
						return n
					end,
				type = "description",
				order = 302,
				hidden = function(info)
						if t == "customs" then
							return true
						else
							if CDTL2.currentFilterHidden[t] then
								return true
							else
								local specialCase = false
								if t == "items" then
									specialCase = true
								end
								local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)

								if s then
									if s["setCustomCD"] ~= nil then
										return s["setCustomCD"]
									end
								end
							end
						end

						return false
					end,
				width = 1.5,
				fontSize = "large",
			},
			setNewCD = {
				name = " ",
				desc = "Set the default cooldown value.",
				order = 303,
				hidden = function(info)
						if t == "customs" then
							return CDTL2.currentFilterHidden[t]
						end

						return true
					end,
				disabled = function ()
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if not CDTL2.customIsValid then
									return true
								end
							end
						end

						return false
					end,
				type = "input",
				get = function(info, index)
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if CDTL2.custom["bCD"] then
									return tostring(CDTL2.custom["bCD"] / 1000)
								else
									return "60"
								end
							else
								local s = CDTL2:GetSpellSettings(CDTL2.currentFilter["customs"], t, false)
								if s then
									return tostring(s["bCD"] / 1000)
								else
									return "0"
								end
							end
						end

						return "999"
					end,
				set = function(info, val)
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								CDTL2.custom["bCD"] = val * 1000
							else
								CDTL2:SetSpellData(CDTL2.currentFilter[t], t, "bCD", val * 1000)
								
								local s = CDTL2:GetExistingCooldown(CDTL2.currentFilter[t], t)
								if s then
									s.data["bCD"] = val * 1000
								
									CDTL2:RefreshIcon(s)
								end
							end
						end
					end,
			},
			customCDTime = {
				name = "",
				desc = "Set the value of the custom CD",
				type = "input",
				order = 304,
				hidden = function(info)
						if t == "customs" then
							return true
						else
							if CDTL2.currentFilterHidden[t] then
								return true
							else
								local specialCase = false
								if t == "items" then
									specialCase = true
								end
								local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)

								if s then
									if s["setCustomCD"] ~= nil then
										return not s["setCustomCD"]
									else
										s["setCustomCD"] = false
										return true
									end
								end
							end
						end

						return false
					end,
				get = function(info)
						if t ~= "customs" then
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)

							if s["customCDTime"] ~= nil then
								return tostring(s["customCDTime"] / 1000)
							end

							return tostring(s["bCD"] / 1000)
						end

						return ""
					end,
				set = function(info, val)				
						CDTL2:SetSpellData(CDTL2.currentFilter[t], t, "customCDTime", val * 1000)

						local e = CDTL2:GetExistingCooldown(CDTL2.currentFilter[t], t)
						if e then
							e.data["customCDTime"] = val * 1000
							CDTL2:RefreshIcon(e)
							CDTL2:RefreshBar(e)
						end
					end,
			},
			setCustomCD = {
				name = "Custom CD Time",
				desc = "Allows you to set a custom time for the cooldown.  This can be used for if a talent changes a cooldown time and the mod cannot detect it.",
				order = 305,
				hidden = function(info)
						if t == "customs" then
							return true
						end

						return CDTL2.currentFilterHidden[t]
					end,
				type = "toggle",
				get = function(info, index)
						if t ~= "customs" then
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)

							return s["setCustomCD"]
						end

						return false
					end,
				set = function(info, val)
						local specialCase = false
						if t == "items" then
							specialCase = true
						end
						local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
						
						CDTL2:SetSpellData(CDTL2.currentFilter[t], t, "setCustomCD", val)

						local e = CDTL2:GetExistingCooldown(CDTL2.currentFilter[t], t)
						if e then
							e.data["setCustomCD"] = val
							CDTL2:RefreshIcon(e)
							CDTL2:RefreshBar(e)
						end
					end,
			},
			spacer400 = {
				name = " \n\n",
				type = "description",
				order = 400,
				width = "full",
			},
			clearSettings = {
				--name = "Clear Individual Settings",
				name = function(info)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							return "Clear"
						end

						return "Clear Individual Settings"
					end,
				desc = function(info)
						if t == "customs" then
							return "Clear unsaved custom settings"
						end

						local s = ""
						
						if CDTL2.currentFilter[t] then
							s = CDTL2.currentFilter[t]
						end
				
						return "This will clear cooldown settings for "..s
					end,
				confirm = true,
				order = 401,
				type = "execute",
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
				disabled = function ()
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if not CDTL2.custom["triggerType"] then
									return true
								end
							else
								local s = CDTL2:GetSpellSettings(CDTL2.currentFilter["customs"], t, false)
								if s then
									if s["triggerType"] == "" then
										return true
									end
								end 
							end
						end

						return false
					end,
				func = function(info)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							CDTL2.custom = {}
							CDTL2.customIsValid = false
						else
							local s = ""
							
							if CDTL2.currentFilter[t] then
								s = CDTL2.currentFilter[t]
							end
							
							local index = nil
							for k, spell in pairs(CDTL2.db.profile.tables[t]) do
								--[[if spell["itemName"] == s then
									index = k
								end]]--
								if spell["name"] == s then
									index = k
								end
							end
							
							if index then
								table.remove(CDTL2.db.profile.tables[t], index)

								CDTL2.currentFilter[t] = "<< Add New >>"
								CDTL2.customIsValid = false
								CDTL2.currentFilterHidden[t] = false
							end
						end
					end,
			},
			saveCustom = {
				name = "Save Custom",
				desc = function(info)
						return "Save current details as a custom cooldown"
					end,
				confirm = true,
				order = 402,
				type = "execute",
				hidden = function(info)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							return false
						end

						return true
					end,
				disabled = function ()
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if not CDTL2.customIsValid then
									return true
								end
							end
						end

						return false
					end,
				func = function(info)
						local s = CDTL2:GetSpellSettings(CDTL2.currentFilter["customs"], "customs", false)

						if not s then
							local name = CDTL2.custom["name"]			
							table.insert(CDTL2.db.profile.tables["customs"], CDTL2.custom)

							CDTL2.custom = {}
							CDTL2.customIsValid = false
							CDTL2.currentFilter[t] = name

							CDTL2:Print("CUSTOM: "..name.." saved")
						else
							CDTL2:Print("CUSTOM: "..tostring(s["name"]).." already saved")
						end
					end,
			},
			spacer500 = {
				name = " \n\n",
				type = "description",
				order = 500,
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
			},
			enabled = {
				name = "Enabled",
				desc = "Untick this to never show this as an icon/bar",
				order = 501,
				type = "toggle",
				width = "half",
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
				disabled = function ()
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if not CDTL2.customIsValid then
									return true
								end
							end
						end

						return false
					end,
				get = function(info, index)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							if CDTL2.custom["enabled"] then
								return CDTL2.custom["enabled"]
							else
								return CDTL2.db.profile.global["customs"]["showByDefault"]
							end
						else
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if s then
								return s["enabled"]
							else
								return nil
							end
						end
					end,
				set = function(info, val)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							CDTL2.custom["enabled"] = val
						else
							CDTL2:SetSpellData(CDTL2.currentFilter[t], t, "enabled", val)
						
							local s = CDTL2:GetExistingCooldown(CDTL2.currentFilter[t], t)
							if s then
								s.data["enabled"] = val
								
								CDTL2:RefreshIcon(s)
								CDTL2:RefreshBar(s)
							end
						end
					end,
			},
			highlight = {
				name = "Highlight",
				desc = "Tick to apply highlighting to the icon",
				order = 502,
				type = "toggle",
				width = "half",
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
				disabled = function ()
							if t == "customs" then
								if CDTL2.currentFilter[t] == "<< Add New >>" then
									if not CDTL2.customIsValid then
										return true
									end
								end
							end
	
							return false
						end,
				get = function(info, index)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							if CDTL2.custom["highlight"] then
								return CDTL2.custom["highlight"]
							else
								return false
							end
						else
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if s then
								return s["highlight"]
							else
								return nil
							end
						end
					end,
				set = function(info, val)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							CDTL2.custom["highlight"] = val
						else
							CDTL2:SetSpellData(CDTL2.currentFilter[t], t, "highlight", val)
						
							local s = CDTL2:GetExistingCooldown(CDTL2.currentFilter[t], t)
							if s then
								s.data["highlight"] = val
							
								CDTL2:RefreshIcon(s)
							end
						end
					end,
			},
			pinned = {
				name = "Pinned",
				desc = "Tick to keep an icon in the ready frame until the cooldownis used again",
				order = 503,
				type = "toggle",
				width = "half",
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
				disabled = function ()
							if t == "customs" then
								if CDTL2.currentFilter[t] == "<< Add New >>" then
									if not CDTL2.customIsValid then
										return true
									end
								end
							end
	
							return false
						end,
				get = function(info, index)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							if CDTL2.custom["pinned"] then
								return CDTL2.custom["pinned"]
							else
								return false
							end
						else
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if s then
								return s["pinned"]
							else
								return nil
							end
						end
					end,
				set = function(info, val)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							CDTL2.custom["pinned"] = val
						else
							CDTL2:SetSpellData(CDTL2.currentFilter[t], t, "pinned", val)
						
							local s = CDTL2:GetExistingCooldown(CDTL2.currentFilter[t], t)
							if s then
								s.data["pinned"] = val
							
								CDTL2:RefreshIcon(s)
							end
						end
					end,
			},
			ignored = {
				name = "Ignored",
				desc = "Manually choose if something should be ignored or not.\nThis can be used in tandem with setting custom cooldown times to force misbehaving cooldowns to show correctly",
				order = 504,
				type = "toggle",
				width = "half",
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
				disabled = function ()
							if t == "customs" then
								if CDTL2.currentFilter[t] == "<< Add New >>" then
									if not CDTL2.customIsValid then
										return true
									end
								end
							end
	
							return false
						end,
				get = function(info, index)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							if CDTL2.custom["ignored"] then
								return CDTL2.custom["ignored"]
							else
								return false
							end
						else
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if s then
								return s["ignored"]
							else
								return nil
							end
						end
					end,
				set = function(info, val)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							CDTL2.custom["ignored"] = val
						else
							CDTL2:SetSpellData(CDTL2.currentFilter[t], t, "ignored", val)
						
							local s = CDTL2:GetExistingCooldown(CDTL2.currentFilter[t], t)
							if s then
								s.data["ignored"] = val
							
								CDTL2:RefreshIcon(s)
							end
						end
					end,
			},
			spacer600 = {
				name = "\n\nSelect the frame the icon/bar will be shown\nIf the selected frame is not enabled, the icon/bar will not appear\n\n",
				type = "description",
				order = 600,
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
			},
			lane = {
				name = "Lane",
				desc = "",
				order = 601,
				type = "select",
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
				disabled = function ()
							if t == "customs" then
								if CDTL2.currentFilter[t] == "<< Add New >>" then
									if not CDTL2.customIsValid then
										return true
									end
								end
							end
	
							return false
						end,
				width = "half",
				values = { [0] = "Hide", [1] = "1", [2] = "2", [3] = "3" },
				get = function(info)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							if CDTL2.custom["lane"] then
								return CDTL2.custom["lane"]
							else
								return CDTL2.db.profile.global["customs"]["defaultLane"]
							end
						else
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if s then
								return s["lane"]
							else
								return nil
							end
						end
						
					end,
				set = function(info, val)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							CDTL2.custom["lane"] = val
						else
							CDTL2:SetSpellData(CDTL2.currentFilter[t], t, "lane", tonumber(val))
						
							local s = CDTL2:GetExistingCooldown(CDTL2.currentFilter[t], t)
							if s then
								s.data["lane"] = val
								
								CDTL2:SendToLane(s)
							end
						end
						
					end,
			},
			barFrame = {
				name = "Bar Frame",
				desc = "",
				order = 602,
				type = "select",
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
				disabled = function ()
							if t == "customs" then
								if CDTL2.currentFilter[t] == "<< Add New >>" then
									if not CDTL2.customIsValid then
										return true
									end
								end
							end
	
							return false
						end,
				width = "half",
				values = { [0] = "Hide", [1] = "1", [2] = "2", [3] = "3" },
				get = function(info)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							if CDTL2.custom["barFrame"] then
								return CDTL2.custom["barFrame"]
							else
								return CDTL2.db.profile.global["customs"]["defaultBar"]
							end
						else
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if s then
								return s["barFrame"]
							else
								return nil
							end
						end
						
					end,
				set = function(info, val)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							CDTL2.custom["barFrame"] = val
						else
							CDTL2:SetSpellData(CDTL2.currentFilter[t], t, "barFrame", tonumber(val))
						
							local s = CDTL2:GetExistingCooldown(CDTL2.currentFilter[t], t)
							if s then
								s.data["barFrame"] = val
								
								CDTL2:SendToBarFrame(s)
							end
						end
						
					end,
			},
			readyFrame = {
				name = "Ready Frame",
				desc = "",
				order = 603,
				hidden = function(info)
						return CDTL2.currentFilterHidden[t]
					end,
				disabled = function ()
						if t == "customs" then
							if CDTL2.currentFilter[t] == "<< Add New >>" then
								if not CDTL2.customIsValid then
									return true
								end
							end
						end

						return false
					end,
				type = "select",
				width = "half",
				values = { [0] = "Hide", [1] = "1", [2] = "2", [3] = "3" },
				get = function(info)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							if CDTL2.custom["readyFrame"] then
								return CDTL2.custom["readyFrame"]
							else
								return CDTL2.db.profile.global["customs"]["defaultReady"]
							end
						else
							local specialCase = false
							if t == "items" then
								specialCase = true
							end
							local s = CDTL2:GetSpellSettings(CDTL2.currentFilter[t], t, specialCase)
							
							if s then
								return s["readyFrame"]
							else
								return nil
							end
						end
						
					end,
				set = function(info, val)
						if t == "customs" and CDTL2.currentFilter[t] == "<< Add New >>" then
							CDTL2.custom["readyFrame"] = val
						else
							CDTL2:SetSpellData(CDTL2.currentFilter[t], t, "readyFrame", tonumber(val))
						
							local s = CDTL2:GetExistingCooldown(CDTL2.currentFilter[t], t)
							if s then
								s.data["readyFrame"] = val
								
								CDTL2:SendToReady(s)
							end
						end
						
					end,
			},			
		},
	}

	return options
end

private.GetCustomSet = function(t, o)
	local cSubOrder = 1
	local dSubOrder = 1

	local options = {
		name = "Custom",
		type = "group",
		order = o,
		childGroups  = "tab",
		args = {
			saved = private.GetFilterSet(t, 100),
			detected = {
				name = "Detected",
				type = "group",
				order = 200,
				args = {
					spacer100 = {
						name = function(info, index)
								local s = " \n\n"

								s = s.."When detection is enabled, spell data will be kept for all spells cast by the player.\n"
								s = s.."This will include many instances of spells cast by game systems that can mostly be ignored.\n"
								s = s.."To save a spell as a custom trigger, just select the spell from the list and then hit the 'Save As Custom' button.\n"
								s = s.." \n"

								return s
							end,
						type = "description",
						order = 100,
						width = "full"
					},
					customDetection = {
						name = "Enable Detection",
						desc = "Detect and record 'miscellaneous' spells",
						order = 101,
						type = "toggle",
						--width = "half",
						get = function(info, index)
							return CDTL2.db.profile.global["customDetection"]
							end,
						set = function(info, val)
								CDTL2.db.profile.global["customDetection"] = val
							end,
					},
					clearAllDetected = {
						name = "Clear Detected",
						desc = function(info)
								return "This will clear all detected 'miscellaneous' spells"
							end,
						confirm = true,
						order = 102,
						type = "execute",
						func = function(info)
								for k, v in pairs(CDTL2.db.profile.tables["detected"]) do
									CDTL2.db.profile.tables["detected"][k] = nil
								end
								
								CDTL2.currentFilter["detected"] = "<< Select Detected >>"
							end
					},
					spacer200 = {
						--name = "\n\nSelect something to edit its settings\n",
						name = " \n\nSelect a detected spell to create a custom cooldown\n",
						type = "description",
						order = 200,
					},
					list = {
						name = function(info)
								local n = ""
								return n
							end,
						desc = function(info)
								local n = ""
								return n
							end,
						order = 201,
						type = "select",
						values = function(info)
								local list = {}

								list = CDTL2:LoadDetectedList("detected")

								return list
							end,
						get = function(info)
								return CDTL2.currentFilter["detected"]
							end,
						set = function(info, val)
								local list = CDTL2:LoadDetectedList("detected")
		
								CDTL2.currentFilter["detected"] = list[val]
								CDTL2.currentFilterHidden["detected"] = false
							end,
					},
					spacer202 = {
						name = function(info)
								return "*Miscellaneous spells that have been detected will appear here*\n\n\n"
							end,
						type = "description",
						order = 202,
					},
					cdType = {
						name = function(info)
								local n = " "
								
								if t == "spells" or t == "items" or t == "petspells" then
									n = "Spell:   "
								elseif t == "buffs" or t == "debuffs" or t == "offensives" then
									n = "Aura:   "
								elseif t == "runes" then
									n = "Rune:   "
								elseif t == "customs" or t == "detected" then
									n = "Name:   "
								end
								
								return n
							end,
						type = "description",
						order = 203,
						width = 0.2,
					},
					cdName = {
						name = function(info)
								local n = " "
								
								if CDTL2.currentFilter["detected"] == "<< Select Detected >>" then
									n = "Select a detected spell"
								else
									local s = CDTL2:GetSpellSettings(CDTL2.currentFilter["detected"], "detected", specialCase)
									if s then
										n = "  "..s["name"]
									else
										n = CDTL2.currentFilter["detected"]
									end
								end
								
								return n
							end,
						type = "description",
						order = 204,
						width = 1.5,
						fontSize = "large",
						image = function(info)
								if CDTL2.currentFilter["detected"] ~= "<< Select Detected >>" then
									local s = CDTL2:GetSpellSettings(CDTL2.currentFilter["detected"], "detected", false)
									
									if s then
										return s["icon"]
									end
								end

								return 134400
							end,
						imageWidth = 24,
						imageHeight = 24,
						imageCoords = {0.1,0.9,0.1,0.9},
					},
					spacer300 = {
						name =  " \n\n",
						type = "description",
						order = 300,
					},
					saveDetected = {
						name = "Save As Custom",
						desc = function(info)
								return "This will save the detected spell as custom cooldown"
							end,
						confirm = true,
						order = 301,
						disabled = function ()
								if CDTL2.currentFilter["detected"] == "<< Select Detected >>" then
									return true
								end
		
								return false
							end,
						type = "execute",
						func = function(info)
								local s = CDTL2:GetSpellSettings(CDTL2.currentFilter["detected"], "detected", false)
								if s then
									local existingData = CDTL2:GetSpellSettings(CDTL2.currentFilter["detected"], "customs", false)
									if existingData then
										--CDTL2:Print("CUSTOM_ALREADY_EXISTS: "..CDTL2.currentFilter["detected"])
									else
										local c = CDTL2:TableCopy(s)

										c["bCD"] = 60000
										c["usedBy"] = { CDTL2.player["guid"] }

										c["type"] = "customs"
										c["triggerType"] = "spell"

										c["lane"] = CDTL2.db.profile.global["customs"]["defaultLane"]
										c["barFrame"] = CDTL2.db.profile.global["customs"]["defaultBar"]
										c["readyFrame"] = CDTL2.db.profile.global["customs"]["defaultReady"]
										c["enabled"] = CDTL2.db.profile.global["customs"]["showByDefault"]

										if c["bCD"] / 1000 > 3 and c["bCD"] / 1000 <= CDTL2.db.profile.global["customs"]["ignoreThreshold"] then
											c["ignored"] = false
										else
											c["ignored"] = true
										end
										
										table.insert(CDTL2.db.profile.tables["customs"], c)
										CDTL2.currentFilter["customs"] = c["name"]
									end
								end
							end
					},
				},
			},
		},
	}

	return options
end

private.GetLaneSet = function(i)
	local frame = nil
	local lane = nil
	
	if i == 1 then
		lane = CDTL2.db.profile.lanes["lane1"]
	elseif i == 2 then
		lane = CDTL2.db.profile.lanes["lane2"]
	elseif i == 3 then
		lane = CDTL2.db.profile.lanes["lane3"]
	end
	
	local options = {
		name = function(info)
				return lane["name"]
			end,
		type = "group",
		order = 100,
		args = {
			general = {
				name = "General",
				type = "group",
				order = 100,
				args = {
					name = {
						name = "Frame Name",
						type = "input",
						order = 101,
						get = function(info)
								return lane["name"]
							end,
						set = function(info, val)
								lane["name"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					enabled = {
						name = "Enabled",
						desc = "",
						order = 102,
						type = "toggle",
						get = function(info, index)
								return lane["enabled"]
							end,
						set = function(info, val)
								lane["enabled"] = val
								
								if val then
									CDTL2:CreateLanes()
								end
								
								CDTL2:RefreshLane(i)
							end,
					},
					spacer103 = {
						name = "",
						type = "description",
						order = 103,
					},
					reversed = {
						name = "Reversed",
						desc = "Selecting this will reverse icon travel direction from right-to-left, to left-to-right",
						order = 104,
						type = "toggle",
						get = function(info, index)
								return lane["reversed"]
							end,
						set = function(info, val)
								lane["reversed"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					vertical = {
						name = "Vertical",
						desc = "The frame will be vertical instead of horizontal",
						order = 105,
						type = "toggle",
						get = function(info, index)
								return lane["vertical"]
							end,
						set = function(info, val)
								lane["vertical"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					spacer200 = {
						name = "\n\n",
						type = "description",
						order = 200,
					},
					mode = {
						name = "Mode",
						desc = "How icons will progress along the lane",
						order = 201,
						type = "select",
						values = {
								["LINEAR"] = "Linear (%)",
								["LINEAR_ABS"] = "Linear (Time)",
								["SPLIT"] = "Split (%)",
								["SPLIT_ABS"] = "Split (Time)",
							},
						get = function(info, index)
								return lane["mode"]["type"]
							end,
						set = function(info, val)
								lane["mode"]["type"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					timeFormat = {
						name = "Time Format",
						desc = "Select the format to display times",
						order = 202,
						type = "select",
						hidden = function(info)
							local mode = lane["mode"]["type"]
							if mode == "LINEAR_ABS" or mode == "SPLIT_ABS" then
								return false
							end
							
							return true
						end,
						values = {
								["XhYmZs"] = "XhYmZs",
								["H:MM:SS"] = "H:MM:SS",
							},
						get = function(info, index)
								local mode = lane["mode"]["type"]
								if mode == "LINEAR_ABS" then
									return lane["mode"]["linearAbs"]["timeFormat"]
								elseif mode == "SPLIT_ABS" then
									return lane["mode"]["splitAbs"]["timeFormat"]
								end
								
								return ""
							end,
						set = function(info, val)
								local mode = lane["mode"]["type"]
								if mode == "LINEAR_ABS" then
									lane["mode"]["linearAbs"]["timeFormat"] = val
								elseif mode == "SPLIT_ABS" then
									lane["mode"]["splitAbs"]["timeFormat"] = val
								end
								CDTL2:RefreshLane(i)
							end,
					},
					spacer300 = {
						name = "",
						type = "description",
						order = 300,
					},
					maxTime = {
						name = "Max Time",
						desc = "How many seconds the lane represents",
						order = 301,
						type = "range",
						softMin = 10,
						softMax = 180,
						bigStep = 1,
						get = function(info, index)
								local mt = 0
								local mode = lane["mode"]["type"]
								
								if mode == "LINEAR" then
									mt = lane["mode"]["linear"]["max"]
								elseif mode == "LINEAR_ABS" then
									mt = lane["mode"]["linearAbs"]["max"]
								elseif mode == "SPLIT" then
									mt = lane["mode"]["split"]["max"]
								elseif mode == "SPLIT_ABS" then
									mt = lane["mode"]["splitAbs"]["max"]
								end
								
								return mt
							end,
						set = function(info, val)
								local mode = lane["mode"]["type"]
								
								if mode == "LINEAR" then
									lane["mode"]["linear"]["max"] = val
								elseif mode == "LINEAR_ABS" then
									lane["mode"]["linearAbs"]["max"] = val
								elseif mode == "SPLIT" then
									lane["mode"]["split"]["max"] = val
								elseif mode == "SPLIT_ABS" then
									lane["mode"]["splitAbs"]["max"] = val
								end
								
								CDTL2:RefreshLane(i)
						end,
					},
					hideLongTimers = {
						name = "Hide Long Timers",
						desc = "Should icons with remaining cooldowns longer than the max time be hidden",
						order = 302,
						type = "toggle",
						get = function(info, index)
								local mode = lane["mode"]["type"]
								
								if mode == "LINEAR" then
									return lane["mode"]["linear"]["hideTimeSurplus"]
								elseif mode == "LINEAR_ABS" then
									return lane["mode"]["linearAbs"]["hideTimeSurplus"]
								elseif mode == "SPLIT" then
									return lane["mode"]["split"]["hideTimeSurplus"]
								elseif mode == "SPLIT_ABS" then
									return lane["mode"]["splitAbs"]["hideTimeSurplus"]
								end
								
								return nil
							end,
						set = function(info, val)
								local mode = lane["mode"]["type"]
								
								if mode == "LINEAR" then
									lane["mode"]["linear"]["hideTimeSurplus"] = val
								elseif mode == "LINEAR_ABS" then
									lane["mode"]["linearAbs"]["hideTimeSurplus"] = val
								elseif mode == "SPLIT" then
									lane["mode"]["split"]["hideTimeSurplus"] = val
								elseif mode == "SPLIT_ABS" then
									lane["mode"]["splitAbs"]["hideTimeSurplus"] = val
								end
							end,
					},
					spacer400 = {
						name = "\n\n",
						type = "description",
						order = 400,
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								return false
							end
							return true
						end,
					},
					sSplitCount = {
						name = "Split Count",
						desc = "How many % splits appear on the lane",
						order = 401,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								return false
							end
							return true
						end,
						min = 1,
						max = 3,
						bigStep = 1,
						get = function(info, index)
								return lane["mode"]["split"]["count"]
							end,
						set = function(info, val)
								lane["mode"]["split"]["count"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					spacer410 = {
						name = "\n\n",
						type = "description",
						order = 410,
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								return false
							end
							return true
						end,
					},
					sSplit1Position = {
						name = "Split 1 Position",
						desc = "What position should split 1 appear",
						order = 411,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								return false
							end
							return true
						end,
						min = 0,
						max = 1,
						get = function(info, index)
								return lane["mode"]["split"]["s1p"]
							end,
						set = function(info, val)
								lane["mode"]["split"]["s1p"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					sSplit1Value = {
						name = "Split 1 Value",
						desc = "What percentage should split 1 occur",
						order = 412,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								return false
							end
							return true
						end,
						min = 0,
						max = 100,
						bigStep = 1,
						get = function(info, index)
								return lane["mode"]["split"]["s1v"]
							end,
						set = function(info, val)
								lane["mode"]["split"]["s1v"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					spacer420 = {
						name = "",
						type = "description",
						order = 420,
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								if lane["mode"]["split"]["count"] >= 2 then
									return false
								end
							end
							return true
						end,
					},
					sSplit2Position = {
						name = "Split 2 Position",
						desc = "What position should split 2 appear",
						order = 421,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								if lane["mode"]["split"]["count"] >= 2 then
									return false
								end
							end
							return true
						end,
						min = 0,
						max = 1,
						get = function(info, index)
								return lane["mode"]["split"]["s2p"]
							end,
						set = function(info, val)
								lane["mode"]["split"]["s2p"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					sSplit2Value = {
						name = "Split 2 Value",
						desc = "What percentage should split 2 occur",
						order = 422,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								if lane["mode"]["split"]["count"] >= 2 then
									return false
								end
							end
							return true
						end,
						min = 0,
						max = 100,
						bigStep = 1,
						get = function(info, index)
								return lane["mode"]["split"]["s2v"]
							end,
						set = function(info, val)
								lane["mode"]["split"]["s2v"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					spacer430 = {
						name = "",
						type = "description",
						order = 430,
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								if lane["mode"]["split"]["count"] >= 2 then
									return false
								end
							end
							return true
						end,
					},
					sSplit3Position = {
						name = "Split 3 Position",
						desc = "What position should split 3 appear",
						order = 431,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								if lane["mode"]["split"]["count"] >= 3 then
									return false
								end
							end
							return true
						end,
						min = 0,
						max = 1,
						get = function(info, index)
								return lane["mode"]["split"]["s3p"]
							end,
						set = function(info, val)
								lane["mode"]["split"]["s3p"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					sSplit3Value = {
						name = "Split 3 Value",
						desc = "What percentage should split 3 occur",
						order = 432,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT" then
								if lane["mode"]["split"]["count"] >= 3 then
									return false
								end
							end
							return true
						end,
						min = 0,
						max = 100,
						bigStep = 1,
						get = function(info, index)
								return lane["mode"]["split"]["s3v"]
							end,
						set = function(info, val)
								lane["mode"]["split"]["s3v"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					spacer500 = {
						name = "\n\n",
						type = "description",
						order = 500,
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								return false
							end
							return true
						end,
					},
					saSplitCount = {
						name = "Split Count",
						desc = "How many % splits appear on the lane",
						order = 502,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								return false
							end
							return true
						end,
						min = 1,
						max = 3,
						bigStep = 1,
						get = function(info, index)
								return lane["mode"]["splitAbs"]["count"]
							end,
						set = function(info, val)
								lane["mode"]["splitAbs"]["count"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					spacer510 = {
						name = "\n\n",
						type = "description",
						order = 510,
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								return false
							end
							return true
						end,
					},
					saSplit1Position = {
						name = "Split 1 Position",
						desc = "What position should splitAbs 1 appear",
						order = 511,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								return false
							end
							return true
						end,
						min = 0,
						max = 1,
						get = function(info, index)
								return lane["mode"]["splitAbs"]["s1p"]
							end,
						set = function(info, val)
								lane["mode"]["splitAbs"]["s1p"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					saSplit1Value = {
						name = "Split 1 Value",
						desc = "What percentage should splitAbs 1 occur",
						order = 512,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								return false
							end
							return true
						end,
						min = 1,
						max = 360,
						bigStep = 1,
						get = function(info, index)
								return lane["mode"]["splitAbs"]["s1v"]
							end,
						set = function(info, val)
								lane["mode"]["splitAbs"]["s1v"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					spacer520 = {
						name = "",
						type = "description",
						order = 520,
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								if lane["mode"]["splitAbs"]["count"] >= 2 then
									return false
								end
							end
							return true
						end,
					},
					saSplit2Position = {
						name = "Split 2 Position",
						desc = "What position should splitAbs 2 appear",
						order = 521,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								if lane["mode"]["splitAbs"]["count"] >= 2 then
									return false
								end
							end
							return true
						end,
						min = 0,
						max = 1,
						get = function(info, index)
								return lane["mode"]["splitAbs"]["s2p"]
							end,
						set = function(info, val)
								lane["mode"]["splitAbs"]["s2p"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					saSplit2Value = {
						name = "Split 2 Value",
						desc = "What percentage should splitAbs 2 occur",
						order = 522,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								if lane["mode"]["splitAbs"]["count"] >= 2 then
									return false
								end
							end
							return true
						end,
						min = 1,
						max = 360,
						bigStep = 1,
						get = function(info, index)
								return lane["mode"]["splitAbs"]["s2v"]
							end,
						set = function(info, val)
								lane["mode"]["splitAbs"]["s2v"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					spacer530 = {
						name = "",
						type = "description",
						order = 530,
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								if lane["mode"]["splitAbs"]["count"] >= 2 then
									return false
								end
							end
							return true
						end,
					},
					saSplit3Position = {
						name = "Split 3 Position",
						desc = "What position should splitAbs 3 appear",
						order = 531,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								if lane["mode"]["splitAbs"]["count"] >= 3 then
									return false
								end
							end
							return true
						end,
						min = 0,
						max = 1,
						get = function(info, index)
								return lane["mode"]["splitAbs"]["s3p"]
							end,
						set = function(info, val)
								lane["mode"]["splitAbs"]["s3p"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					saSplit3Value = {
						name = "Split 3 Value",
						desc = "What percentage should splitAbs 3 occur",
						order = 532,
						type = "range",
						hidden = function(info)
							if lane["mode"]["type"] == "SPLIT_ABS" then
								if lane["mode"]["splitAbs"]["count"] >= 3 then
									return false
								end
							end
							return true
						end,
						max = 360,
						min = 1,
						bigStep = 1,
						get = function(info, index)
								return lane["mode"]["splitAbs"]["s3v"]
							end,
						set = function(info, val)
								lane["mode"]["splitAbs"]["s3v"] = val
								CDTL2:RefreshLane(i)
						end,
					},					
					spacer600 = {
						name = "\n\n",
						type = "description",
						order = 600,
					},
					overrideAutohide = {
						name = "Override Autohide",
						desc = function(info, index)
								local desc = "This will override autohiding, and show the lane in the following circumstances:\n\n"
									desc = desc.."Player Health: while health is below max\n"
									desc = desc.."Class Power: while class power is below max (or above 0 in the case of rage)\n"
									desc = desc.."Energy Tick: while in stealth\n"
								return desc
							end,
						order = 601,
						type = "toggle",
						get = function(info, index)
								return lane["tracking"]["overrideAutohide"]
							end,
						set = function(info, val)
								lane["tracking"]["overrideAutohide"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					spacer602 = {
						name = "\n",
						type = "description",
						order = 602,
					},
					primaryTracking = {
						name = "Primary Tracking",
						desc = "",
						order = 603,
						type = "select",
						values = {
								["NONE"] = "None",
								["GCD"] = "GCD",
								["HEALTH"] = "Health",
								["CLASS_POWER"] = "Class Power",
								["COMBO_POINTS"] = "Combo Points",
								["MANA_TICK"] = "Mana Tick",
								["ENERGY_TICK"] = "Energy Tick",
								["MH_SWING"] = "MH Swing",
								["OH_SWING"] = "OH Swing",
								["RANGE_SWING"] = "Ranged Auto-attack",
							},
						get = function(info, index)
								return lane["tracking"]["primaryTracking"]
							end,
						set = function(info, val)
								lane["tracking"]["primaryTracking"] = val
							end,
					},
					primaryReversed = {
						name = "Reverse",
						desc = "Reverse the direction of the primary tracking indicator",
						order = 604,
						type = "toggle",
						get = function(info, index)
								return lane["tracking"]["primaryReversed"]
							end,
						set = function(info, val)
								lane["tracking"]["primaryReversed"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					spacer610 = {
						name = "\n",
						type = "description",
						order = 610,
					},
					secondaryTracking = {
						name = "Secondary Tracking",
						desc = "",
						order = 611,
						type = "select",
						values = {
								["NONE"] = "None",
								["GCD"] = "GCD",
								["HEALTH"] = "Health",
								["CLASS_POWER"] = "Class Power",
								["COMBO_POINTS"] = "Combo Points",
								["MANA_TICK"] = "Mana Tick",
								["ENERGY_TICK"] = "Energy Tick",
								["MH_SWING"] = "MH Swing",
								["OH_SWING"] = "OH Swing",
								["RANGE_SWING"] = "Ranged Auto-attack",
							},
						get = function(info, index)
								return lane["tracking"]["secondaryTracking"]
							end,
						set = function(info, val)
								lane["tracking"]["secondaryTracking"] = val
							end,
					},
					secondaryReversed = {
						name = "Reverse",
						desc = "Reverse the direction of the secondary tracking indicator",
						order = 612,
						type = "toggle",
						get = function(info, index)
								return lane["tracking"]["secondaryReversed"]
							end,
						set = function(info, val)
								lane["tracking"]["secondaryReversed"] = val
							end,
					},
					spacer613 = {
						name = "\n",
						type = "description",
						order = 613,
					},
					stWidth = {
						name = "ST Width",
						desc = "Set the width of the secondary tracker",
						order = 614,
						type = "range",
						hidden = function(info)
							if lane["tracking"]["secondaryTracking"] ~= "NONE" then
								return false
							end
							return true
						end,
						max = 360,
						min = 1,
						bigStep = 1,
						get = function(info, index)
								return lane["tracking"]["stWidth"]
							end,
						set = function(info, val)
								lane["tracking"]["stWidth"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					stHeight = {
						name = "ST Height",
						desc = "Set the height of the secondary tracker",
						order = 615,
						type = "range",
						hidden = function(info)
							if lane["tracking"]["secondaryTracking"] ~= "NONE" then
								return false
							end
							return true
						end,
						max = 360,
						min = 1,
						bigStep = 1,
						get = function(info, index)
								return lane["tracking"]["stHeight"]
							end,
						set = function(info, val)
								lane["tracking"]["stHeight"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					spacer616 = {
						name = "\n",
						type = "description",
						order = 616,
						hidden = function(info)
							if lane["tracking"]["secondaryTracking"] ~= "NONE" then
								return false
							end
							return true
						end,
					},
					stTexture = {
						name = "ST Texture",
						desc = "Selects the ST texture",
						order = 617,
						type = "select",
						hidden = function(info)
							if lane["tracking"]["secondaryTracking"] ~= "NONE" then
								return false
							end
							return true
						end,
						dialogControl = 'LSM30_Statusbar',
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info, index)
								return lane["tracking"]["stTexture"]
							end,
						set = function(info, val)
								lane["tracking"]["stTexture"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					stTextureColor = {
						name = "ST Color",
						desc = "Sets the ST texture color",
						order = 618,
						type = "color",
						hidden = function(info)
							if lane["tracking"]["secondaryTracking"] ~= "NONE" then
								return false
							end
							return true
						end,
						hasAlpha = true,
						get = function(info)
								local r = lane["tracking"]["stTextureColor"]["r"]
								local g = lane["tracking"]["stTextureColor"]["g"]
								local b = lane["tracking"]["stTextureColor"]["b"]
								local a = lane["tracking"]["stTextureColor"]["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								lane["tracking"]["stTextureColor"] = { r = red, g = green, b = blue, a = alpha }
								CDTL2:RefreshLane(i)
							end,
					},
				},
			},
			appearance = {
				name = "Appearance",
				type = "group",
				order = 200,
				args = {
					width = {
						name = "Width",
						desc = "Sets the width for the lane",
						order = 201,
						type = "range",
						softMin = 1,
						softMax = 600,
						bigStep = 1,
						get = function(info, index)
								return lane["width"]
							end,
						set = function(info, val)
								lane["width"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					height = {
						name = "Height",
						desc = "Sets the height for the lane",
						order = 202,
						type = "range",
						softMin = 1,
						softMax = 600,
						bigStep = 1,
						get = function(info, index)
								return lane["height"]
							end,
						set = function(info, val)
								lane["height"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					spacer300 = {
						name = "",
						type = "description",
						order = 300,
					},
					posX = {
						name = "x Position",
						desc = "Sets the x position of the lane",
						order = 301,
						type = "range",
						softMin = -500,
						softMax = 500,
						bigStep = 1,
						get = function(info, index)
								return lane["posX"]
							end,
						set = function(info, val)
								lane["posX"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					posY = {
						name = "y Position",
						desc = "Sets the y position of the lane",
						order = 302,
						type = "range",
						softMin = -500,
						softMax = 500,
						bigStep = 1,
						get = function(info, index)
								return lane["posY"]
							end,
						set = function(info, val)
								lane["posY"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					spacer400 = {
						name = "",
						type = "description",
						order = 400,
					},
					relativeTo = {
						name = "Anchor Point",
						desc = "The x/y position is relative to this point of the screen",
						order = 401,
						type = "select",
						values = {
								["TOPLEFT"] = "TOPLEFT",
								["TOP"] = "TOP",
								["TOPRIGHT"] = "TOPRIGHT",
								["LEFT"] = "LEFT",
								["CENTER"] = "CENTER",
								["RIGHT"] = "RIGHT",
								["BOTTOMLEFT"] = "BOTTOMLEFT",
								["BOTTOM"] = "BOTTOM",
								["BOTTOMRIGHT"] = "BOTTOMRIGHT",
							},
						get = function(info, index)
								return lane["relativeTo"]
							end,
						set = function(info, val)
								lane["relativeTo"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					spacer500 = {
						name = "\n\n",
						type = "description",
						order = 500,
					},
					fgTexture = {
						name = "Foreground Texture",
						desc = "Selects the texture",
						order = 501,
						type = "select",
						width = 0.7,
						dialogControl = 'LSM30_Statusbar',
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info, index)
								return lane["fgTexture"]
							end,
						set = function(info, val)
								lane["fgTexture"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					fgTextureColor = {
						name = "Color",
						desc = "Sets the texture color",
						order = 502,
						type = "color",
						width = 0.4,
						hasAlpha = true,
						disabled  = function(info)
								return lane["fgClassColor"]
							end,
						get = function(info)
								local c = lane["fgTextureColor"]
								if lane["fgClassColor"] then
									c = CDTL2.db.profile.global["classColors"][CDTL2.player["class"]]
								end
						
								local r = c["r"]
								local g = c["g"]
								local b = c["b"]
								local a = c["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								lane["fgTextureColor"] = { r = red, g = green, b = blue, a = alpha }
								CDTL2:RefreshLane(i)
							end,
					},
					fgClassColor = {
						name = "Class Color",
						desc = "Set the texture color to your class color",
						order = 503,
						type = "toggle",
						width = 0.5,
						get = function(info)
								return lane["fgClassColor"]
							end,
						set = function(info, val)
								lane["fgClassColor"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					spacer600 = {
						name = "",
						type = "description",
						order = 600,
					},
					bgTexture = {
						name = "Background Texture",
						desc = "Sets the background texture",
						order = 601,
						type = "select",
						width = 0.7,
						dialogControl = 'LSM30_Statusbar',
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info, index)
								return lane["bgTexture"]
							end,
						set = function(info, val)
								lane["bgTexture"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					bgTextureColor = {
						name = "Color",
						desc = "Sets the background texture color",
						order = 602,
						type = "color",
						width = 0.4,
						hasAlpha = true,
						disabled  = function(info)
								return lane["bgClassColor"]
							end,
						get = function(info)
								local c = lane["bgTextureColor"]
								if lane["bgClassColor"] then
									c = CDTL2.db.profile.global["classColors"][CDTL2.player["class"]]
								end
						
								local r = c["r"]
								local g = c["g"]
								local b = c["b"]
								local a = c["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								lane["bgTextureColor"] = { r = red, g = green, b = blue, a = alpha }
								CDTL2:RefreshLane(i)
							end,
					},
					bgClassColor = {
						name = "Class Color",
						desc = "Set the texture color to your class color",
						order = 603,
						type = "toggle",
						width = 0.5,
						get = function(info)
								return lane["bgClassColor"]
							end,
						set = function(info, val)
								lane["bgClassColor"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					spacer700 = {
						name = "",
						type = "description",
						order = 700,
					},
					laneAlpha = {
						name = "Lane Alpha",
						desc = "Set the alpha for the lane (this will reset custom text alpha settings, but they can be adjusted again after setting this)",
						order = 701,
						type = "range",
						min = 0,
						max = 1,
						get = function(info, index)
								return lane["alpha"]
							end,
						set = function(info, val)
								lane["alpha"] = val
								CDTL2:RefreshLane(i)
						end,
					},
					spacer702 = {
						name = "\n\n",
						type = "description",
						order = 702,
					},
					border = {
						name = "                    Border Texture",
						desc = "Selects the border texture",
						order = 703,
						type = "select",
						dialogControl = 'LSM30_Border',
						values = AceGUIWidgetLSMlists.border,
						get = function(info) return lane["border"]["style"] end,
						set = function(info, val)
								lane["border"]["style"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					borderColor = {
						name = "Color",
						desc = "Selects the border color",
						order = 704,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local r = lane["border"]["color"]["r"]
								local g = lane["border"]["color"]["g"]
								local b = lane["border"]["color"]["b"]
								local a = lane["border"]["color"]["a"]
								
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								lane["border"]["color"] = { r = red, g = green, b = blue, a = alpha }							
								CDTL2:RefreshLane(i)
							end,
					},
					spacer710 = {
						name = "",
						type = "description",
						order = 710,
					},
					borderSize = {
						name = "Size",
						desc = "Sets the size of the border",
						order = 711,
						type = "range",
						softMin = 1,
						softMax = 40,
						bigStep = 1,
						get = function(info) return lane["border"]["size"] end,
						set = function(info, val)
								lane["border"]["size"] = val
								CDTL2:RefreshLane(i)
							end,
					},
					borderPadding = {
						name = "Padding",
						desc = "Sets the size of the border",
						order = 711,
						type = "range",
						softMin = 0,
						softMax = 40,
						bigStep = 1,
						get = function(info) return lane["border"]["padding"] end,
						set = function(info, val)
								lane["border"]["padding"] = val
								CDTL2:RefreshLane(i)
							end,
					},
				},
			},
			icons = {
				name = "Icons",
				type = "group",
				order = 300,
				args = {
					size = {
						name = "Size",
						desc = "Sets the size of icons in lane 1",
						order = 101,
						type = "range",
						softMin = 1,
						softMax = 128,
						bigStep = 1,
						get = function(info, index)
								return lane["icons"]["size"]
							end,
						set = function(info, val)
								lane["icons"]["size"] = val
								CDTL2:RefreshAllIcons()
						end,
					},
					spacer102 = {
						name = "\n",
						type = "description",
						order = 102,
					},
					iconAlpha = {
						name = "Icon Transparency",
						desc = "Set the alpha for the icon (text alpha is set in text settings)",
						order = 103,
						type = "range",
						min = 0,
						max = 1,
						get = function(info, index)
								return lane["icons"]["alpha"]
							end,
						set = function(info, val)
								lane["icons"]["alpha"] = val
								
								CDTL2:RefreshAllIcons()
						end,
					},
					spacer110 = {
						name = "\n",
						type = "description",
						order = 110,
					},
					yOffset = {
						name = "Icon Offset",
						desc = "Offsets icons position on the lane from the center line",
						order = 111,
						type = "range",
						softMin = -30,
						softMax = 30,
						bigStep = 1,
						get = function(info, index)
								return lane["iconOffset"]
							end,
						set = function(info, val)
								lane["iconOffset"] = val
								CDTL2:RefreshAllIcons()
						end,
					},
					spacer120 = {
						name = "\n\n",
						type = "description",
						order = 120,
					},
					textHeader = {
						name = "Icon Text",
						type = "header",
						order = 200.1,
					},
					spacer200 = {
						name = "\n",
						type = "description",
						order = 200.2,
					},
					-- ICON TEXT 1
					iText1Text = private.GetTextText(lane["icons"]["text1"], 210, i, "ICON", false),
					iText1Enabled = private.GetTextEnabled(lane["icons"]["text1"], 210, i, "ICON"),
					iText1Edit = private.GetTextEdit(lane["icons"]["text1"], 210, i, "ICON"),
					iText1Font = private.GetTextFont(lane["icons"]["text1"], 210, i, "ICON"),
					iText1Outline = private.GetTextOutline(lane["icons"]["text1"], 210, i, "ICON"),
					iText1S1 = { name = "", type = "description", order = 210 + 4.3, hidden = function(info) return not lane["icons"]["text1"]["edit"] end, },
					iText1Size = private.GetTextSize(lane["icons"]["text1"], 210, i, "ICON"),
					iText1Color = private.GetTextColor(lane["icons"]["text1"], 210, i, "ICON"),
					iText1ShadowColor = private.GetTextShadowColor(lane["icons"]["text1"], 210, i, "ICON"),
					iText1S2 = { name = "", type = "description", order = 210 + 4.7, hidden = function(info) return not lane["icons"]["text1"]["edit"] end, },
					iText1ShadowXOffset = private.GetTextShadowXOffset(lane["icons"]["text1"], 210, i, "ICON"),
					iText1ShadowYOffset = private.GetTextShadowYOffset(lane["icons"]["text1"], 210, i, "ICON"),
					iText1S3 = { name = "", type = "description", order = 210 + 5.1, hidden = function(info) return not lane["icons"]["text1"]["edit"] end, },
					iText1Anchor = private.GetTextAnchor(lane["icons"]["text1"], 210, i, "ICON"),
					iText1Align = private.GetTextAlign(lane["icons"]["text1"], 210, i, "ICON"),
					iText1S4 = { name = "", type = "description", order = 210 + 5.4, hidden = function(info) return not lane["icons"]["text1"]["edit"] end, },
					iText1XOffset = private.GetTextXOffset(lane["icons"]["text1"], 210, i, "ICON"),
					iText1YOffset = private.GetTextYOffset(lane["icons"]["text1"], 210, i, "ICON"),
					iText1Footer = { name = "", type = "header", order = 210 + 9.8, hidden = function(info) return not lane["icons"]["text1"]["edit"] end, },
					-- ICON TEXT 2
					iText2S0 = { name = "\n", type = "description", order = 220, hidden = function(info) return not lane["icons"]["text2"]["used"] end, },
					iText2Header = { name = "", type = "header", order = 220 + 0.1, hidden = function(info) return not lane["icons"]["text2"]["edit"] end, },
					iText2Text = private.GetTextText(lane["icons"]["text2"], 220, i, "ICON", false),
					iText2Enabled = private.GetTextEnabled(lane["icons"]["text2"], 220, i, "ICON"),
					iText2Edit = private.GetTextEdit(lane["icons"]["text2"], 220, i, "ICON"),
					iText2Font = private.GetTextFont(lane["icons"]["text2"], 220, i, "ICON"),
					iText2Outline = private.GetTextOutline(lane["icons"]["text2"], 220, i, "ICON"),
					iText2S1 = { name = "", type = "description", order = 220 + 4.3, hidden = function(info) return not lane["icons"]["text2"]["edit"] end, },
					iText2Size = private.GetTextSize(lane["icons"]["text2"], 220, i, "ICON"),
					iText2Color = private.GetTextColor(lane["icons"]["text2"], 220, i, "ICON"),
					iText2ShadowColor = private.GetTextShadowColor(lane["icons"]["text2"], 220, i, "ICON"),
					iText2S2 = { name = "", type = "description", order = 220 + 4.7, hidden = function(info) return not lane["icons"]["text2"]["edit"] end, },
					iText2ShadowXOffset = private.GetTextShadowXOffset(lane["icons"]["text2"], 220, i, "ICON"),
					iText2ShadowYOffset = private.GetTextShadowYOffset(lane["icons"]["text2"], 220, i, "ICON"),
					iText2S3 = { name = "", type = "description", order = 220 + 5.1, hidden = function(info) return not lane["icons"]["text2"]["edit"] end, },
					iText2Anchor = private.GetTextAnchor(lane["icons"]["text2"], 220, i, "ICON"),
					iText2Align = private.GetTextAlign(lane["icons"]["text2"], 220, i, "ICON"),
					iText2S4 = { name = "", type = "description", order = 220 + 5.4, hidden = function(info) return not lane["icons"]["text2"]["edit"] end, },
					iText2XOffset = private.GetTextXOffset(lane["icons"]["text2"], 220, i, "ICON"),
					iText2YOffset = private.GetTextYOffset(lane["icons"]["text2"], 220, i, "ICON"),
					iText2Footer = { name = "", type = "header", order = 220 + 9.8, hidden = function(info) return not lane["icons"]["text2"]["edit"] end, },
					-- ICON TEXT 3
					iText3S0 = { name = "\n", type = "description", order = 230, hidden = function(info) return not lane["icons"]["text3"]["used"] end, },
					iText3Header = { name = "", type = "header", order = 230 + 0.1, hidden = function(info) return not lane["icons"]["text3"]["edit"] end, },
					iText3Text = private.GetTextText(lane["icons"]["text3"], 230, i, "ICON", false),
					iText3Enabled = private.GetTextEnabled(lane["icons"]["text3"], 230, i, "ICON"),
					iText3Edit = private.GetTextEdit(lane["icons"]["text3"], 230, i, "ICON"),
					iText3Font = private.GetTextFont(lane["icons"]["text3"], 230, i, "ICON"),
					iText3Outline = private.GetTextOutline(lane["icons"]["text3"], 230, i, "ICON"),
					iText3S1 = { name = "", type = "description", order = 230 + 4.3, hidden = function(info) return not lane["icons"]["text3"]["edit"] end, },
					iText3Size = private.GetTextSize(lane["icons"]["text3"], 230, i, "ICON"),
					iText3Color = private.GetTextColor(lane["icons"]["text3"], 230, i, "ICON"),
					iText3ShadowColor = private.GetTextShadowColor(lane["icons"]["text3"], 230, i, "ICON"),
					iText3S2 = { name = "", type = "description", order = 230 + 4.7, hidden = function(info) return not lane["icons"]["text3"]["edit"] end, },
					iText3ShadowXOffset = private.GetTextShadowXOffset(lane["icons"]["text3"], 230, i, "ICON"),
					iText3ShadowYOffset = private.GetTextShadowYOffset(lane["icons"]["text3"], 230, i, "ICON"),
					iText3S3 = { name = "", type = "description", order = 230 + 5.1, hidden = function(info) return not lane["icons"]["text3"]["edit"] end, },
					iText3Anchor = private.GetTextAnchor(lane["icons"]["text3"], 230, i, "ICON"),
					iText3Align = private.GetTextAlign(lane["icons"]["text3"], 230, i, "ICON"),
					iText3S4 = { name = "", type = "description", order = 230 + 5.4, hidden = function(info) return not lane["icons"]["text3"]["edit"] end, },
					iText3XOffset = private.GetTextXOffset(lane["icons"]["text3"], 230, i, "ICON"),
					iText3YOffset = private.GetTextYOffset(lane["icons"]["text3"], 230, i, "ICON"),
					iText3Footer = { name = "", type = "header", order = 230 + 9.8, hidden = function(info) return not lane["icons"]["text3"]["edit"] end, },
					spacer288 = {
						name = "\n",
						type = "description",
						order = 288,
					},
					textFooter = {
						name = "",
						type = "header",
						order = 289,
					},
					spacer300 = {
						name = "\n\n",
						type = "description",
						order = 300,
					},
					border = {
						name = "                    Border Texture",
						desc = "Selects the border texture",
						order = 301,
						type = "select",
						dialogControl = 'LSM30_Border',
						values = AceGUIWidgetLSMlists.border,
						get = function(info) return lane["icons"]["border"]["style"] end,
						set = function(info, val)
								lane["icons"]["border"]["style"] = val
								CDTL2:RefreshAllIcons()
							end,
					},
					borderColor = {
						name = "Color",
						desc = "Selects the border color",
						order = 302,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local r = lane["icons"]["border"]["color"]["r"]
								local g = lane["icons"]["border"]["color"]["g"]
								local b = lane["icons"]["border"]["color"]["b"]
								local a = lane["icons"]["border"]["color"]["a"]
								
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								lane["icons"]["border"]["color"] = { r = red, g = green, b = blue, a = alpha }							
								CDTL2:RefreshAllIcons()
							end,
					},
					spacer310 = {
						name = "",
						type = "description",
						order = 310,
					},
					borderSize = {
						name = "Size",
						desc = "Sets the size of the border",
						order = 311,
						type = "range",
						softMin = 1,
						softMax = 40,
						bigStep = 1,
						get = function(info) return lane["icons"]["border"]["size"] end,
						set = function(info, val)
								lane["icons"]["border"]["size"] = val
								CDTL2:RefreshAllIcons()
							end,
					},
					borderPadding = {
						name = "Padding",
						desc = "Sets the size of the border",
						order = 311,
						type = "range",
						softMin = 0,
						softMax = 40,
						bigStep = 1,
						get = function(info) return lane["icons"]["border"]["padding"] end,
						set = function(info, val)
								lane["icons"]["border"]["padding"] = val
								CDTL2:RefreshAllIcons()
							end,
					},
					spacer400 = {
						name = "\n\n",
						type = "description",
						order = 400,
					},
					highlightStyle = {
						name = "Highlight Style",
						desc = "How to highlight icons",
						order = 401,
						type = "select",
						values = {
								["BORDER"] = "Border",
								["BORDER_FLASH"] = "Border Flash",
								["FLASH"] = "Flash Icon",
								["GLOW"] = "Glow",
							},
						get = function(info, index)
								return lane["icons"]["highlight"]["style"]
							end,
						set = function(info, val)
								lane["icons"]["highlight"]["style"] = val
								CDTL2:RefreshAllIcons()
							end,
					},
					spacer500 = {
						name = "\n\n",
						type = "description",
						order = 500,
						hidden = function(info)
								if	lane["icons"]["highlight"]["style"] == "BORDER" or
									lane["icons"]["highlight"]["style"] == "BORDER_FLASH"
								then
									return false
								end
								
								return true
							end,
					},
					hlBorder = {
						name = "                    Border Texture",
						desc = "Selects the border texture",
						order = 501,
						hidden = function(info)
								if	lane["icons"]["highlight"]["style"] == "BORDER" or
									lane["icons"]["highlight"]["style"] == "BORDER_FLASH"
								then
									return false
								end
								
								return true
							end,
						type = "select",
						dialogControl = 'LSM30_Border',
						values = AceGUIWidgetLSMlists.border,
						get = function(info) return lane["icons"]["highlight"]["border"]["style"] end,
						set = function(info, val)
								lane["icons"]["highlight"]["border"]["style"] = val
								CDTL2:RefreshAllIcons()
							end,
					},
					hlBorderColor = {
						name = "Color",
						desc = "Selects the border color",
						order = 502,
						hidden = function(info)
								if	lane["icons"]["highlight"]["style"] == "BORDER" or
									lane["icons"]["highlight"]["style"] == "BORDER_FLASH"
								then
									return false
								end
								
								return true
							end,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local r = lane["icons"]["highlight"]["border"]["color"]["r"]
								local g = lane["icons"]["highlight"]["border"]["color"]["g"]
								local b = lane["icons"]["highlight"]["border"]["color"]["b"]
								local a = lane["icons"]["highlight"]["border"]["color"]["a"]
								
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								lane["icons"]["highlight"]["border"]["color"] = { r = red, g = green, b = blue, a = alpha }							
								CDTL2:RefreshAllIcons()
							end,
					},
					spacer510 = {
						name = "",
						type = "description",
						order = 510,
						hidden = function(info)
								if	lane["icons"]["highlight"]["style"] == "BORDER" or
									lane["icons"]["highlight"]["style"] == "BORDER_FLASH"
								then
									return false
								end
								
								return true
							end,
					},
					hlBorderSize = {
						name = "Size",
						desc = "Sets the size of the border",
						order = 511,
						hidden = function(info)
								if	lane["icons"]["highlight"]["style"] == "BORDER" or
									lane["icons"]["highlight"]["style"] == "BORDER_FLASH"
								then
									return false
								end
								
								return true
							end,
						type = "range",
						softMin = 1,
						softMax = 40,
						bigStep = 1,
						get = function(info) return lane["icons"]["highlight"]["border"]["size"] end,
						set = function(info, val)
								lane["icons"]["highlight"]["border"]["size"] = val
								CDTL2:RefreshAllIcons()
							end,
					},
					hlBorderPadding = {
						name = "Padding",
						desc = "Sets the size of the border",
						order = 511,
						hidden = function(info)
								if	lane["icons"]["highlight"]["style"] == "BORDER" or
									lane["icons"]["highlight"]["style"] == "BORDER_FLASH"
								then
									return false
								end
								
								return true
							end,
						type = "range",
						softMin = 0,
						softMax = 40,
						bigStep = 1,
						get = function(info) return lane["icons"]["highlight"]["border"]["padding"] end,
						set = function(info, val)
								lane["icons"]["highlight"]["border"]["padding"] = val
								CDTL2:RefreshAllIcons()
							end,
					},
				}
			},
			stacking = {
				name = "Stacking",
				type = "group",
				order = 400,
				args = {
					enabled = {
						name = "Enabled",
						desc = "Enable icon stacking",
						order = 101,
						type = "toggle",
						width = 0.5,
						get = function(info)
								return lane["stacking"]["enabled"]
							end,
						set = function(info, val)
								lane["stacking"]["enabled"] = val
							end,
					},
					raise = {
						name = "Raise On Mouseover",
						desc = "Mousing over an icon will raise it to the top of its stack and make it easier to see",
						order = 102,
						type = "toggle",
						get = function(info)
								return lane["stacking"]["raiseOnMouseOver"]
							end,
						set = function(info, val)
								lane["stacking"]["raiseOnMouseOver"] = val
							end,
					},
					spacer200 = {
						name = "\n\n",
						type = "description",
						order = 200,
					},
					style = {
						name = "Stack Style",
						desc = "Select which direction new icons will grow in",
						order = 201,
						type = "select",
						values = {
								["GROUPED"] = "Grouped",
								["OFFSET"] = "Offset",
							},
						get = function(info, index)
								return lane["stacking"]["style"]
							end,
						set = function(info, val)
								lane["stacking"]["style"] = val
							end,
					},
					grow = {
						name = "Grow Direction",
						desc = "What direction should icon stacks grow",
						order = 202,
						type = "select",
						values = {
								["UP"] = "Up",
								["DOWN"] = "Down",
								["CENTER"] = "Center",
							},
						get = function(info, index)
								return lane["stacking"]["grow"]
							end,
						set = function(info, val)
								lane["stacking"]["grow"] = val
							end,
					},
					spacer300 = {
						name = "\n\n",
						type = "description",
						order = 300,
					},
					height = {
						name = "Height",
						desc = "Sets the max height of the stack",
						order = 301,
						type = "range",
						softMin = 0,
						softMax = 100,
						bigStep = 1,
						get = function(info, index)
								return lane["stacking"]["height"]
							end,
						set = function(info, val)
								lane["stacking"]["height"] = val
						end,
					},
				}
			},
			text = {
				name = "Text",
				type = "group",
				order = 500,
				args = {
					defaultHeader = {
						name = "Default Text",
						type = "header",
						order = 100,
					},
					-- DEFAULT TEXT 1
					dText1Text = private.GetTextText(lane["modeText"]["text1"], 210, i, "LANE", true),
					dText1Enabled = private.GetTextEnabled(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1Edit = private.GetTextEdit(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1Font = private.GetTextFont(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1Outline = private.GetTextOutline(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1S1 = { name = "", type = "description", order = 210 + 4.3, hidden = function(info) return not lane["modeText"]["text1"]["edit"] end, },
					dText1Size = private.GetTextSize(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1Color = private.GetTextColor(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1ShadowColor = private.GetTextShadowColor(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1S2 = { name = "", type = "description", order = 210 + 4.7, hidden = function(info) return not lane["modeText"]["text1"]["edit"] end, },
					dText1ShadowXOffset = private.GetTextShadowXOffset(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1ShadowYOffset = private.GetTextShadowYOffset(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1S3 = { name = "", type = "description", order = 210 + 5.1, hidden = function(info) return not lane["modeText"]["text1"]["edit"] end, },
					dText1Anchor = private.GetTextAnchor(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1Align = private.GetTextAlign(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1S4 = { name = "", type = "description", order = 210 + 5.4, hidden = function(info) return not lane["modeText"]["text1"]["edit"] end, },
					dText1XOffset = private.GetTextXOffset(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1YOffset = private.GetTextYOffset(lane["modeText"]["text1"], 210, i, "LANE"),
					dText1Footer = { name = "", type = "header", order = 210 + 9.8, hidden = function(info) return not lane["modeText"]["text1"]["edit"] end, },
					-- DEFAULT TEXT 2
					dText2S0 = { name = "\n", type = "description", order = 220, hidden = function(info) return not lane["modeText"]["text2"]["used"] end, },
					dText2Header = { name = "", type = "header", order = 220 + 0.1, hidden = function(info) return not lane["modeText"]["text2"]["edit"] end, },
					dText2Text = private.GetTextText(lane["modeText"]["text2"], 220, i, "LANE", true),
					dText2Enabled = private.GetTextEnabled(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2Edit = private.GetTextEdit(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2Font = private.GetTextFont(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2Outline = private.GetTextOutline(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2S1 = { name = "", type = "description", order = 220 + 4.3, hidden = function(info) return not lane["modeText"]["text2"]["edit"] end, },
					dText2Size = private.GetTextSize(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2Color = private.GetTextColor(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2ShadowColor = private.GetTextShadowColor(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2S2 = { name = "", type = "description", order = 220 + 4.7, hidden = function(info) return not lane["modeText"]["text2"]["edit"] end, },
					dText2ShadowXOffset = private.GetTextShadowXOffset(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2ShadowYOffset = private.GetTextShadowYOffset(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2S3 = { name = "", type = "description", order = 220 + 5.1, hidden = function(info) return not lane["modeText"]["text2"]["edit"] end, },
					dText2Anchor = private.GetTextAnchor(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2Align = private.GetTextAlign(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2S4 = { name = "", type = "description", order = 220 + 5.4, hidden = function(info) return not lane["modeText"]["text2"]["edit"] end, },
					dText2XOffset = private.GetTextXOffset(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2YOffset = private.GetTextYOffset(lane["modeText"]["text2"], 220, i, "LANE"),
					dText2Footer = { name = "", type = "header", order = 220 + 9.8, hidden = function(info) return not lane["modeText"]["text2"]["edit"] end, },
					-- DEFAULT TEXT 3
					dText3S0 = { name = "\n", type = "description", order = 230, hidden = function(info) return not lane["modeText"]["text3"]["used"] end, },
					dText3Header = { name = "", type = "header", order = 230 + 0.1, hidden = function(info) return not lane["modeText"]["text3"]["edit"] end, },
					dText3Text = private.GetTextText(lane["modeText"]["text3"], 230, i, "LANE", true),
					dText3Enabled = private.GetTextEnabled(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3Edit = private.GetTextEdit(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3Font = private.GetTextFont(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3Outline = private.GetTextOutline(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3S1 = { name = "", type = "description", order = 230 + 4.3, hidden = function(info) return not lane["modeText"]["text3"]["edit"] end, },
					dText3Size = private.GetTextSize(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3Color = private.GetTextColor(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3ShadowColor = private.GetTextShadowColor(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3S2 = { name = "", type = "description", order = 230 + 4.7, hidden = function(info) return not lane["modeText"]["text3"]["edit"] end, },
					dText3ShadowXOffset = private.GetTextShadowXOffset(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3ShadowYOffset = private.GetTextShadowYOffset(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3S3 = { name = "", type = "description", order = 230 + 5.1, hidden = function(info) return not lane["modeText"]["text3"]["edit"] end, },
					dText3Anchor = private.GetTextAnchor(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3Align = private.GetTextAlign(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3S4 = { name = "", type = "description", order = 230 + 5.4, hidden = function(info) return not lane["modeText"]["text3"]["edit"] end, },
					dText3XOffset = private.GetTextXOffset(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3YOffset = private.GetTextYOffset(lane["modeText"]["text3"], 230, i, "LANE"),
					dText3Footer = { name = "", type = "header", order = 230 + 9.8, hidden = function(info) return not lane["modeText"]["text3"]["edit"] end, },
					-- DEFAULT TEXT 4
					dText4S0 = { name = "\n", type = "description", order = 240, hidden = function(info) return not lane["modeText"]["text4"]["used"] end, },
					dText4Header = { name = "", type = "header", order = 240 + 0.1, hidden = function(info) return not lane["modeText"]["text4"]["edit"] end, },
					dText4Text = private.GetTextText(lane["modeText"]["text4"], 240, i, "LANE", true),
					dText4Enabled = private.GetTextEnabled(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4Edit = private.GetTextEdit(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4Font = private.GetTextFont(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4Outline = private.GetTextOutline(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4S1 = { name = "", type = "description", order = 240 + 4.3, hidden = function(info) return not lane["modeText"]["text4"]["edit"] end, },
					dText4Size = private.GetTextSize(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4Color = private.GetTextColor(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4ShadowColor = private.GetTextShadowColor(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4S2 = { name = "", type = "description", order = 240 + 4.7, hidden = function(info) return not lane["modeText"]["text4"]["edit"] end, },
					dText4ShadowXOffset = private.GetTextShadowXOffset(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4ShadowYOffset = private.GetTextShadowYOffset(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4S3 = { name = "", type = "description", order = 240 + 5.1, hidden = function(info) return not lane["modeText"]["text4"]["edit"] end, },
					dText4Anchor = private.GetTextAnchor(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4Align = private.GetTextAlign(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4S4 = { name = "", type = "description", order = 240 + 5.4, hidden = function(info) return not lane["modeText"]["text4"]["edit"] end, },
					dText4XOffset = private.GetTextXOffset(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4YOffset = private.GetTextYOffset(lane["modeText"]["text4"], 240, i, "LANE"),
					dText4Footer = { name = "", type = "header", order = 240 + 9.8, hidden = function(info) return not lane["modeText"]["text4"]["edit"] end, },
					-- DEFAULT TEXT 5
					dText5S0 = { name = "\n", type = "description", order = 250, hidden = function(info) return not lane["modeText"]["text5"]["used"] end, },
					dText5Header = { name = "", type = "header", order = 250 + 0.1, hidden = function(info) return not lane["modeText"]["text5"]["edit"] end, },
					dText5Text = private.GetTextText(lane["modeText"]["text5"], 250, i, "LANE", true),
					dText5Enabled = private.GetTextEnabled(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5Edit = private.GetTextEdit(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5Font = private.GetTextFont(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5Outline = private.GetTextOutline(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5S1 = { name = "", type = "description", order = 250 + 4.3, hidden = function(info) return not lane["modeText"]["text5"]["edit"] end, },
					dText5Size = private.GetTextSize(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5Color = private.GetTextColor(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5ShadowColor = private.GetTextShadowColor(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5S2 = { name = "", type = "description", order = 250 + 4.7, hidden = function(info) return not lane["modeText"]["text5"]["edit"] end, },
					dText5ShadowXOffset = private.GetTextShadowXOffset(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5ShadowYOffset = private.GetTextShadowYOffset(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5S3 = { name = "", type = "description", order = 250 + 5.1, hidden = function(info) return not lane["modeText"]["text5"]["edit"] end, },
					dText5Anchor = private.GetTextAnchor(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5Align = private.GetTextAlign(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5S4 = { name = "", type = "description", order = 250 + 5.4, hidden = function(info) return not lane["modeText"]["text5"]["edit"] end, },
					dText5XOffset = private.GetTextXOffset(lane["modeText"]["text5"], 250, i, "LANE"),
					dText5YOffset = private.GetTextYOffset(lane["modeText"]["text5"], 250, i, "LANE"),
					customHeader = {
						name = "Custom Text",
						type = "header",
						order = 300,
					},
					-- CUSTOM TEXT 1
					cText1S0 = { name = "\n", type = "description", order = 310, },
					cText1Text = private.GetTextText(lane["customText"]["text1"], 310, i, "LANE"),
					cText1Enabled = private.GetTextEnabled(lane["customText"]["text1"], 310, i, "LANE"),
					cText1Edit = private.GetTextEdit(lane["customText"]["text1"], 310, i, "LANE"),
					cText1Font = private.GetTextFont(lane["customText"]["text1"], 310, i, "LANE"),
					cText1Outline = private.GetTextOutline(lane["customText"]["text1"], 310, i, "LANE"),
					cText1S1 = { name = "", type = "description", order = 310 + 4.3, hidden = function(info) return not lane["customText"]["text1"]["edit"] end, },
					cText1Size = private.GetTextSize(lane["customText"]["text1"], 310, i, "LANE"),
					cText1Color = private.GetTextColor(lane["customText"]["text1"], 310, i, "LANE"),
					cText1ShadowColor = private.GetTextShadowColor(lane["customText"]["text1"], 310, i, "LANE"),
					cText1S2 = { name = "", type = "description", order = 310 + 4.7, hidden = function(info) return not lane["customText"]["text1"]["edit"] end, },
					cText1ShadowXOffset = private.GetTextShadowXOffset(lane["customText"]["text1"], 310, i, "LANE"),
					cText1ShadowYOffset = private.GetTextShadowYOffset(lane["customText"]["text1"], 310, i, "LANE"),
					cText1S3 = { name = "", type = "description", order = 310 + 5.1, hidden = function(info) return not lane["customText"]["text1"]["edit"] end, },
					cText1Anchor = private.GetTextAnchor(lane["customText"]["text1"], 310, i, "LANE"),
					cText1Align = private.GetTextAlign(lane["customText"]["text1"], 310, i, "LANE"),
					cText1S4 = { name = "", type = "description", order = 310 + 5.4, hidden = function(info) return not lane["customText"]["text1"]["edit"] end, },
					cText1XOffset = private.GetTextXOffset(lane["customText"]["text1"], 310, i, "LANE"),
					cText1YOffset = private.GetTextYOffset(lane["customText"]["text1"], 310, i, "LANE"),
					cText1Footer = { name = "", type = "header", order = 310 + 9.8, hidden = function(info) return not lane["customText"]["text1"]["edit"] end, },
					-- CUSTOM TEXT 2
					cText2S0 = { name = "\n", type = "description", order = 320, hidden = function(info) return not lane["customText"]["text2"]["used"] end, },
					cText2Header = { name = "", type = "header", order = 320 + 0.1, hidden = function(info) return not lane["customText"]["text2"]["edit"] end, },
					cText2Text = private.GetTextText(lane["customText"]["text2"], 320, i, "LANE"),
					cText2Enabled = private.GetTextEnabled(lane["customText"]["text2"], 320, i, "LANE"),
					cText2Edit = private.GetTextEdit(lane["customText"]["text2"], 320, i, "LANE"),
					cText2Font = private.GetTextFont(lane["customText"]["text2"], 320, i, "LANE"),
					cText2Outline = private.GetTextOutline(lane["customText"]["text2"], 320, i, "LANE"),
					cText2S1 = { name = "", type = "description", order = 320 + 4.3, hidden = function(info) return not lane["customText"]["text2"]["edit"] end, },
					cText2Size = private.GetTextSize(lane["customText"]["text2"], 320, i, "LANE"),
					cText2Color = private.GetTextColor(lane["customText"]["text2"], 320, i, "LANE"),
					cText2ShadowColor = private.GetTextShadowColor(lane["customText"]["text2"], 320, i, "LANE"),
					cText2S2 = { name = "", type = "description", order = 320 + 4.7, hidden = function(info) return not lane["customText"]["text2"]["edit"] end, },
					cText2ShadowXOffset = private.GetTextShadowXOffset(lane["customText"]["text2"], 320, i, "LANE"),
					cText2ShadowYOffset = private.GetTextShadowYOffset(lane["customText"]["text2"], 320, i, "LANE"),
					cText2S3 = { name = "", type = "description", order = 320 + 5.1, hidden = function(info) return not lane["customText"]["text2"]["edit"] end, },
					cText2Anchor = private.GetTextAnchor(lane["customText"]["text2"], 320, i, "LANE"),
					cText2Align = private.GetTextAlign(lane["customText"]["text2"], 320, i, "LANE"),
					cText2S4 = { name = "", type = "description", order = 320 + 5.4, hidden = function(info) return not lane["customText"]["text2"]["edit"] end, },
					cText2XOffset = private.GetTextXOffset(lane["customText"]["text2"], 320, i, "LANE"),
					cText2YOffset = private.GetTextYOffset(lane["customText"]["text2"], 320, i, "LANE"),
					cText2Footer = { name = "", type = "header", order = 320 + 9.8, hidden = function(info) return not lane["customText"]["text2"]["edit"] end, },
					-- CUSTOM TEXT 3
					cText3S0 = { name = "\n", type = "description", order = 330, hidden = function(info) return not lane["customText"]["text3"]["used"] end, },
					cText3Header = { name = "", type = "header", order = 330 + 0.1, hidden = function(info) return not lane["customText"]["text3"]["edit"] end, },
					cText3Text = private.GetTextText(lane["customText"]["text3"], 330, i, "LANE"),
					cText3Enabled = private.GetTextEnabled(lane["customText"]["text3"], 330, i, "LANE"),
					cText3Edit = private.GetTextEdit(lane["customText"]["text3"], 330, i, "LANE"),
					cText3Font = private.GetTextFont(lane["customText"]["text3"], 330, i, "LANE"),
					cText3Outline = private.GetTextOutline(lane["customText"]["text3"], 330, i, "LANE"),
					cText3S1 = { name = "", type = "description", order = 330 + 4.3, hidden = function(info) return not lane["customText"]["text3"]["edit"] end, },
					cText3Size = private.GetTextSize(lane["customText"]["text3"], 330, i, "LANE"),
					cText3Color = private.GetTextColor(lane["customText"]["text3"], 330, i, "LANE"),
					cText3ShadowColor = private.GetTextShadowColor(lane["customText"]["text3"], 330, i, "LANE"),
					cText3S2 = { name = "", type = "description", order = 330 + 4.7, hidden = function(info) return not lane["customText"]["text3"]["edit"] end, },
					cText3ShadowXOffset = private.GetTextShadowXOffset(lane["customText"]["text3"], 330, i, "LANE"),
					cText3ShadowYOffset = private.GetTextShadowYOffset(lane["customText"]["text3"], 330, i, "LANE"),
					cText3S3 = { name = "", type = "description", order = 330 + 5.1, hidden = function(info) return not lane["customText"]["text3"]["edit"] end, },
					cText3Anchor = private.GetTextAnchor(lane["customText"]["text3"], 330, i, "LANE"),
					cText3Align = private.GetTextAlign(lane["customText"]["text3"], 330, i, "LANE"),
					cText3S4 = { name = "", type = "description", order = 330 + 5.4, hidden = function(info) return not lane["customText"]["text3"]["edit"] end, },
					cText3XOffset = private.GetTextXOffset(lane["customText"]["text3"], 330, i, "LANE"),
					cText3YOffset = private.GetTextYOffset(lane["customText"]["text3"], 330, i, "LANE"),
					cText3Footer = { name = "", type = "header", order = 330 + 9.8, hidden = function(info) return not lane["customText"]["text3"]["edit"] end, },
					-- CUSTOM TEXT 4
					cText4S0 = { name = "\n", type = "description", order = 340, hidden = function(info) return not lane["customText"]["text4"]["used"] end, },
					cText4Header = { name = "", type = "header", order = 340 + 0.1, hidden = function(info) return not lane["customText"]["text4"]["edit"] end, },
					cText4Text = private.GetTextText(lane["customText"]["text4"], 340, i, "LANE"),
					cText4Enabled = private.GetTextEnabled(lane["customText"]["text4"], 340, i, "LANE"),
					cText4Edit = private.GetTextEdit(lane["customText"]["text4"], 340, i, "LANE"),
					cText4Font = private.GetTextFont(lane["customText"]["text4"], 340, i, "LANE"),
					cText4Outline = private.GetTextOutline(lane["customText"]["text4"], 340, i, "LANE"),
					cText4S1 = { name = "", type = "description", order = 340 + 4.3, hidden = function(info) return not lane["customText"]["text4"]["edit"] end, },
					cText4Size = private.GetTextSize(lane["customText"]["text4"], 340, i, "LANE"),
					cText4Color = private.GetTextColor(lane["customText"]["text4"], 340, i, "LANE"),
					cText4ShadowColor = private.GetTextShadowColor(lane["customText"]["text4"], 340, i, "LANE"),
					cText4S2 = { name = "", type = "description", order = 340 + 4.7, hidden = function(info) return not lane["customText"]["text4"]["edit"] end, },
					cText4ShadowXOffset = private.GetTextShadowXOffset(lane["customText"]["text4"], 340, i, "LANE"),
					cText4ShadowYOffset = private.GetTextShadowYOffset(lane["customText"]["text4"], 340, i, "LANE"),
					cText4S3 = { name = "", type = "description", order = 340 + 5.1, hidden = function(info) return not lane["customText"]["text4"]["edit"] end, },
					cText4Anchor = private.GetTextAnchor(lane["customText"]["text4"], 340, i, "LANE"),
					cText4Align = private.GetTextAlign(lane["customText"]["text4"], 340, i, "LANE"),
					cText4S4 = { name = "", type = "description", order = 340 + 5.4, hidden = function(info) return not lane["customText"]["text4"]["edit"] end, },
					cText4XOffset = private.GetTextXOffset(lane["customText"]["text4"], 340, i, "LANE"),
					cText4YOffset = private.GetTextYOffset(lane["customText"]["text4"], 340, i, "LANE"),
					cText4Footer = { name = "", type = "header", order = 340 + 9.8, hidden = function(info) return not lane["customText"]["text4"]["edit"] end, },
					-- CUSTOM TEXT 5
					cText5S0 = { name = "\n", type = "description", order = 350, hidden = function(info) return not lane["customText"]["text5"]["used"] end, },
					cText5Header = { name = "", type = "header", order = 350 + 0.1, hidden = function(info) return not lane["customText"]["text5"]["edit"] end, },
					cText5Text = private.GetTextText(lane["customText"]["text5"], 350, i, "LANE"),
					cText5Enabled = private.GetTextEnabled(lane["customText"]["text5"], 350, i, "LANE"),
					cText5Edit = private.GetTextEdit(lane["customText"]["text5"], 350, i, "LANE"),
					cText5Font = private.GetTextFont(lane["customText"]["text5"], 350, i, "LANE"),
					cText5Outline = private.GetTextOutline(lane["customText"]["text5"], 350, i, "LANE"),
					cText5S1 = { name = "", type = "description", order = 350 + 4.3, hidden = function(info) return not lane["customText"]["text5"]["edit"] end, },
					cText5Size = private.GetTextSize(lane["customText"]["text5"], 350, i, "LANE"),
					cText5Color = private.GetTextColor(lane["customText"]["text5"], 350, i, "LANE"),
					cText5ShadowColor = private.GetTextShadowColor(lane["customText"]["text5"], 350, i, "LANE"),
					cText5S2 = { name = "", type = "description", order = 350 + 4.7, hidden = function(info) return not lane["customText"]["text5"]["edit"] end, },
					cText5ShadowXOffset = private.GetTextShadowXOffset(lane["customText"]["text5"], 350, i, "LANE"),
					cText5ShadowYOffset = private.GetTextShadowYOffset(lane["customText"]["text5"], 350, i, "LANE"),
					cText5S3 = { name = "", type = "description", order = 350 + 5.1, hidden = function(info) return not lane["customText"]["text5"]["edit"] end, },
					cText5Anchor = private.GetTextAnchor(lane["customText"]["text5"], 350, i, "LANE"),
					cText5Align = private.GetTextAlign(lane["customText"]["text5"], 350, i, "LANE"),
					cText5S4 = { name = "", type = "description", order = 350 + 5.4, hidden = function(info) return not lane["customText"]["text5"]["edit"] end, },
					cText5XOffset = private.GetTextXOffset(lane["customText"]["text5"], 350, i, "LANE"),
					cText5YOffset = private.GetTextYOffset(lane["customText"]["text5"], 350, i, "LANE"),
					cText5Footer = { name = "", type = "header", order = 350 + 9.8, hidden = function(info) return not lane["customText"]["text5"]["edit"] end, },
				},
			},
		}
	}
	
	return options
end

private.GetReadySet = function(i)
	local ready = nil
	
	if i == 1 then
		ready = CDTL2.db.profile.ready["ready1"]
	elseif i == 2 then
		ready = CDTL2.db.profile.ready["ready2"]
	elseif i == 3 then
		ready = CDTL2.db.profile.ready["ready3"]
	end
	
	local options = {
		name = function(info)
				return ready["name"]
			end,
		type = "group",
		order = 100,
		args = {
			general = {
				name = "General",
				type = "group",
				order = 100,
				args = {
					name = {
						name = "Frame Name",
						type = "input",
						order = 101,
						get = function(info)
								return ready["name"]
							end,
						set = function(info, val)
								ready["name"] = val
								CDTL2:RefreshReady(i)
							end,
					},
					enabled = {
						name = "Enabled",
						desc = "",
						order = 102,
						type = "toggle",
						get = function(info, index)
								return ready["enabled"]
							end,
						set = function(info, val)
								ready["enabled"] = val
								
								if val then
									CDTL2:CreateReadyFrames()
								end
								
								CDTL2:RefreshReady(i)
							end,
					},
					spacer200 = {
						name = "\n\n",
						type = "description",
						order = 200,
					},
					grow = {
						name = "Grow Direction",
						desc = "Select which direction new icons will grow in",
						order = 201,
						type = "select",
						values = {
								["UP"] = "UP",
								["DOWN"] = "DOWN",
								["LEFT"] = "LEFT",
								["RIGHT"] = "RIGHT",
								["CENTER_H"] = "CENTER (H)",
								["CENTER_V"] = "CENTER (V)",
							},
						get = function(info, index)
								return ready["grow"]
							end,
						set = function(info, val)
								ready["grow"] = val
							end,
					},
					spacer300 = {
						name = "\n\n",
						type = "description",
						order = 300,
					},
					nTime = {
						name = "Normal Duration",
						desc = "How long an icon should stay in the ready frame",
						order = 301,
						type = "range",
						softMin = 1,
						softMax = 20,
						bigStep = 1,
						get = function(info, index)
								return ready["nTime"]
							end,
						set = function(info, val)
								ready["nTime"] = val
						end,
					},
					nSound = {
						name = "Normal Sound",
						desc = "Select which sound to play when an icon enters the frame",
						order = 302,
						type = "select",
						dialogControl = 'LSM30_Sound',
						values = AceGUIWidgetLSMlists.sound,
						get = function(info, index)
								return ready["nSound"]
							end,
						set = function(info, val)
								ready["nSound"] = val
							end,
					},
					spacer400 = {
						name = "",
						type = "description",
						order = 400,
					},
					hTime = {
						name = "Highlight Duration",
						desc = "How long a highlighted icon should stay in the ready frame",
						order = 401,
						type = "range",
						softMin = 1,
						softMax = 20,
						bigStep = 1,
						get = function(info, index)
								return ready["hTime"]
							end,
						set = function(info, val)
								ready["hTime"] = val
						end,
					},
					hSound = {
						name = "Highlight Sound",
						desc = "Select which sound to play when a highlighted icon enters the frame",
						order = 402,
						type = "select",
						dialogControl = 'LSM30_Sound',
						values = AceGUIWidgetLSMlists.sound,
						get = function(info, index)
								return ready["hSound"]
							end,
						set = function(info, val)
								ready["hSound"] = val
							end,
					},
					spacer500 = {
						name = "\n\n",
						type = "description",
						order = 500,
					},
					pTime = {
						name = "Pinned Hide Time",
						desc = "How long the ready frame will stay visible after combat ends",
						order = 501,
						type = "range",
						softMin = 1,
						softMax = 20,
						bigStep = 1,
						get = function(info, index)
								return ready["pTime"]
							end,
						set = function(info, val)
								ready["pTime"] = val
						end,
					},
					spacer600 = {
						name = "\n\n",
						type = "description",
						order = 600,
					},
					xPadding = {
						name = "x Padding",
						desc = "Sets the x offset between growing icons",
						order = 601,
						type = "range",
						softMin = -20,
						softMax = 20,
						bigStep = 1,
						get = function(info, index)
								return ready["icons"]["xPadding"]
							end,
						set = function(info, val)
								ready["icons"]["xPadding"] = val
						end,
					},
					yPadding = {
						name = "y Padding",
						desc = "Sets the y offset between growing icons",
						order = 602,
						type = "range",
						softMin = -20,
						softMax = 20,
						bigStep = 1,
						get = function(info, index)
								return ready["icons"]["yPadding"]
							end,
						set = function(info, val)
								ready["icons"]["yPadding"] = val
						end,
					},
				}
			},
			appearance = {
				name = "Appearance",
				type = "group",
				order = 200,
				args = {
					posX = {
						name = "x Position",
						desc = "Sets the x position of the frame",
						order = 111,
						type = "range",
						softMin = -500,
						softMax = 500,
						bigStep = 1,
						get = function(info, index)
								return ready["posX"]
							end,
						set = function(info, val)
								ready["posX"] = val
								CDTL2:RefreshReady(i)
							end,
					},
					posY = {
						name = "y Position",
						desc = "Sets the y position of the frame",
						order = 112,
						type = "range",
						softMin = -500,
						softMax = 500,
						bigStep = 1,
						get = function(info, index)
								return ready["posY"]
							end,
						set = function(info, val)
								ready["posY"] = val
								CDTL2:RefreshReady(i)
							end,
					},
					spacer113 = {
						name = "",
						type = "description",
						order = 113,
					},
					relativeTo = {
						name = "Anchor Point",
						desc = "The x/y position is relative to this point of the screen",
						order = 114,
						type = "select",
						values = {
								["TOPLEFT"] = "TOPLEFT",
								["TOP"] = "TOP",
								["TOPRIGHT"] = "TOPRIGHT",
								["LEFT"] = "LEFT",
								["CENTER"] = "CENTER",
								["RIGHT"] = "RIGHT",
								["BOTTOMLEFT"] = "BOTTOMLEFT",
								["BOTTOM"] = "BOTTOM",
								["BOTTOMRIGHT"] = "BOTTOMRIGHT",
							},
						get = function(info, index)
								return ready["relativeTo"]
							end,
						set = function(info, val)
								ready["relativeTo"] = val
								CDTL2:RefreshReady(i)
							end,
					},
					spacer200 = {
						name = "\n\n",
						type = "description",
						order = 200,
					},
					padding = {
						name = "Padding",
						desc = "Sets the amount of padding in the frame",
						order = 201,
						type = "range",
						softMin = 0,
						softMax = 40,
						bigStep = 1,
						get = function(info, index)
								return ready["padding"]
							end,
						set = function(info, val)
								ready["padding"] = val
								CDTL2:RefreshAllIcons()
								CDTL2:RefreshReady(i)
						end,
					},
					spacer300 = {
						name = "\n\n",
						type = "description",
						order = 300,
					},
					bgTexture = {
						name = "Background Texture",
						desc = "Sets the background texture",
						order = 301,
						type = "select",
						dialogControl = 'LSM30_Statusbar',
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info, index)
								return ready["bgTexture"]
							end,
						set = function(info, val)
								ready["bgTexture"] = val
								CDTL2:RefreshReady(i)
							end,
					},
					bgTextureColor = {
						name = "Color",
						desc = "Sets the background texture color",
						order = 302,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local r = ready["bgTextureColor"]["r"]
								local g = ready["bgTextureColor"]["g"]
								local b = ready["bgTextureColor"]["b"]
								local a = ready["bgTextureColor"]["a"]
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								ready["bgTextureColor"] = { r = red, g = green, b = blue, a = alpha }
								CDTL2:RefreshReady(i)
							end,
					},
					spacer400 = {
						name = "\n\n",
						type = "description",
						order = 400,
					},
					border = {
						name = "                    Border Texture",
						desc = "Selects the border texture",
						order = 401,
						type = "select",
						dialogControl = 'LSM30_Border',
						values = AceGUIWidgetLSMlists.border,
						get = function(info) return ready["border"]["style"] end,
						set = function(info, val)
								ready["border"]["style"] = val
								CDTL2:RefreshReady(i)
							end,
					},
					borderColor = {
						name = "Color",
						desc = "Selects the border color",
						order = 402,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local r = ready["border"]["color"]["r"]
								local g = ready["border"]["color"]["g"]
								local b = ready["border"]["color"]["b"]
								local a = ready["border"]["color"]["a"]
								
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								ready["border"]["color"] = { r = red, g = green, b = blue, a = alpha }							
								CDTL2:RefreshReady(i)
							end,
					},
					spacer410 = {
						name = "",
						type = "description",
						order = 410,
					},
					borderSize = {
						name = "Size",
						desc = "Sets the size of the border",
						order = 411,
						type = "range",
						softMin = 1,
						softMax = 40,
						bigStep = 1,
						get = function(info) return ready["border"]["size"] end,
						set = function(info, val)
								ready["border"]["size"] = val
								CDTL2:RefreshReady(i)
							end,
					},
					borderPadding = {
						name = "Padding",
						desc = "Sets the size of the border",
						order = 412,
						type = "range",
						softMin = 0,
						softMax = 40,
						bigStep = 1,
						get = function(info) return ready["border"]["padding"] end,
						set = function(info, val)
								ready["border"]["padding"] = val
								CDTL2:RefreshReady(i)
							end,
					},
				}
			},
			icons = {
				name = "Icons",
				type = "group",
				order = 300,
				args = {
					size = {
						name = "Size",
						desc = "Sets the size of the frame, and icons in the ready frame",
						order = 101,
						type = "range",
						softMin = 1,
						softMax = 128,
						bigStep = 1,
						get = function(info, index)
								return ready["icons"]["size"]
							end,
						set = function(info, val)
								ready["icons"]["size"] = val
								CDTL2:RefreshAllIcons()
								CDTL2:RefreshReady(i)
						end,
					},
					spacer102 = {
						name = "\n",
						type = "description",
						order = 102,
					},
					iconAlpha = {
						name = "Icon Transparency",
						desc = "Set the alpha for the icon (text alpha is set in text settings)",
						order = 103,
						type = "range",
						min = 0,
						max = 1,
						get = function(info, index)
								return ready["icons"]["alpha"]
							end,
						set = function(info, val)
								ready["icons"]["alpha"] = val
								
								CDTL2:RefreshAllIcons()
						end,
					},
					spacer104 = {
						name = "\n\n",
						type = "description",
						order = 104,
					},
					textHeader = {
						name = "Icon Text",
						type = "header",
						order = 200.1,
					},
					spacer200 = {
						name = "\n",
						type = "description",
						order = 200.2,
					},
					-- ICON TEXT 1
					iText1Text = private.GetTextText(ready["icons"]["text1"], 210, i, "ICON", false),
					iText1Enabled = private.GetTextEnabled(ready["icons"]["text1"], 210, i, "ICON"),
					iText1Edit = private.GetTextEdit(ready["icons"]["text1"], 210, i, "ICON"),
					iText1Font = private.GetTextFont(ready["icons"]["text1"], 210, i, "ICON"),
					iText1Outline = private.GetTextOutline(ready["icons"]["text1"], 210, i, "ICON"),
					iText1S1 = { name = "", type = "description", order = 210 + 4.3, hidden = function(info) return not ready["icons"]["text1"]["edit"] end, },
					iText1Size = private.GetTextSize(ready["icons"]["text1"], 210, i, "ICON"),
					iText1Color = private.GetTextColor(ready["icons"]["text1"], 210, i, "ICON"),
					iText1ShadowColor = private.GetTextShadowColor(ready["icons"]["text1"], 210, i, "ICON"),
					iText1S2 = { name = "", type = "description", order = 210 + 4.7, hidden = function(info) return not ready["icons"]["text1"]["edit"] end, },
					iText1ShadowXOffset = private.GetTextShadowXOffset(ready["icons"]["text1"], 210, i, "ICON"),
					iText1ShadowYOffset = private.GetTextShadowYOffset(ready["icons"]["text1"], 210, i, "ICON"),
					iText1S3 = { name = "", type = "description", order = 210 + 5.1, hidden = function(info) return not ready["icons"]["text1"]["edit"] end, },
					iText1Anchor = private.GetTextAnchor(ready["icons"]["text1"], 210, i, "ICON"),
					iText1Align = private.GetTextAlign(ready["icons"]["text1"], 210, i, "ICON"),
					iText1S4 = { name = "", type = "description", order = 210 + 5.4, hidden = function(info) return not ready["icons"]["text1"]["edit"] end, },
					iText1XOffset = private.GetTextXOffset(ready["icons"]["text1"], 210, i, "ICON"),
					iText1YOffset = private.GetTextYOffset(ready["icons"]["text1"], 210, i, "ICON"),
					iText1Footer = { name = "", type = "header", order = 210 + 9.8, hidden = function(info) return not ready["icons"]["text1"]["edit"] end, },
					-- ICON TEXT 2
					iText2S0 = { name = "\n", type = "description", order = 220, hidden = function(info) return not ready["icons"]["text2"]["used"] end, },
					iText2Header = { name = "", type = "header", order = 220 + 0.1, hidden = function(info) return not ready["icons"]["text2"]["edit"] end, },
					iText2Text = private.GetTextText(ready["icons"]["text2"], 220, i, "ICON", false),
					iText2Enabled = private.GetTextEnabled(ready["icons"]["text2"], 220, i, "ICON"),
					iText2Edit = private.GetTextEdit(ready["icons"]["text2"], 220, i, "ICON"),
					iText2Font = private.GetTextFont(ready["icons"]["text2"], 220, i, "ICON"),
					iText2Outline = private.GetTextOutline(ready["icons"]["text2"], 220, i, "ICON"),
					iText2S1 = { name = "", type = "description", order = 220 + 4.3, hidden = function(info) return not ready["icons"]["text2"]["edit"] end, },
					iText2Size = private.GetTextSize(ready["icons"]["text2"], 220, i, "ICON"),
					iText2Color = private.GetTextColor(ready["icons"]["text2"], 220, i, "ICON"),
					iText2ShadowColor = private.GetTextShadowColor(ready["icons"]["text2"], 220, i, "ICON"),
					iText2S2 = { name = "", type = "description", order = 220 + 4.7, hidden = function(info) return not ready["icons"]["text2"]["edit"] end, },
					iText2ShadowXOffset = private.GetTextShadowXOffset(ready["icons"]["text2"], 220, i, "ICON"),
					iText2ShadowYOffset = private.GetTextShadowYOffset(ready["icons"]["text2"], 220, i, "ICON"),
					iText2S3 = { name = "", type = "description", order = 220 + 5.1, hidden = function(info) return not ready["icons"]["text2"]["edit"] end, },
					iText2Anchor = private.GetTextAnchor(ready["icons"]["text2"], 220, i, "ICON"),
					iText2Align = private.GetTextAlign(ready["icons"]["text2"], 220, i, "ICON"),
					iText2S4 = { name = "", type = "description", order = 220 + 5.4, hidden = function(info) return not ready["icons"]["text2"]["edit"] end, },
					iText2XOffset = private.GetTextXOffset(ready["icons"]["text2"], 220, i, "ICON"),
					iText2YOffset = private.GetTextYOffset(ready["icons"]["text2"], 220, i, "ICON"),
					iText2Footer = { name = "", type = "header", order = 220 + 9.8, hidden = function(info) return not ready["icons"]["text2"]["edit"] end, },
					-- ICON TEXT 3
					iText3S0 = { name = "\n", type = "description", order = 230, hidden = function(info) return not ready["icons"]["text3"]["used"] end, },
					iText3Header = { name = "", type = "header", order = 230 + 0.1, hidden = function(info) return not ready["icons"]["text3"]["edit"] end, },
					iText3Text = private.GetTextText(ready["icons"]["text3"], 230, i, "ICON", false),
					iText3Enabled = private.GetTextEnabled(ready["icons"]["text3"], 230, i, "ICON"),
					iText3Edit = private.GetTextEdit(ready["icons"]["text3"], 230, i, "ICON"),
					iText3Font = private.GetTextFont(ready["icons"]["text3"], 230, i, "ICON"),
					iText3Outline = private.GetTextOutline(ready["icons"]["text3"], 230, i, "ICON"),
					iText3S1 = { name = "", type = "description", order = 230 + 4.3, hidden = function(info) return not ready["icons"]["text3"]["edit"] end, },
					iText3Size = private.GetTextSize(ready["icons"]["text3"], 230, i, "ICON"),
					iText3Color = private.GetTextColor(ready["icons"]["text3"], 230, i, "ICON"),
					iText3ShadowColor = private.GetTextShadowColor(ready["icons"]["text3"], 230, i, "ICON"),
					iText3S2 = { name = "", type = "description", order = 230 + 4.7, hidden = function(info) return not ready["icons"]["text3"]["edit"] end, },
					iText3ShadowXOffset = private.GetTextShadowXOffset(ready["icons"]["text3"], 230, i, "ICON"),
					iText3ShadowYOffset = private.GetTextShadowYOffset(ready["icons"]["text3"], 230, i, "ICON"),
					iText3S3 = { name = "", type = "description", order = 230 + 5.1, hidden = function(info) return not ready["icons"]["text3"]["edit"] end, },
					iText3Anchor = private.GetTextAnchor(ready["icons"]["text3"], 230, i, "ICON"),
					iText3Align = private.GetTextAlign(ready["icons"]["text3"], 230, i, "ICON"),
					iText3S4 = { name = "", type = "description", order = 230 + 5.4, hidden = function(info) return not ready["icons"]["text3"]["edit"] end, },
					iText3XOffset = private.GetTextXOffset(ready["icons"]["text3"], 230, i, "ICON"),
					iText3YOffset = private.GetTextYOffset(ready["icons"]["text3"], 230, i, "ICON"),
					iText3Footer = { name = "", type = "header", order = 230 + 9.8, hidden = function(info) return not ready["icons"]["text3"]["edit"] end, },
					spacer298 = {
						name = "\n",
						type = "description",
						order = 298,
					},
					textFooter = {
						name = "",
						type = "header",
						order = 299,
					},
					spacer300 = {
						name = "\n\n",
						type = "description",
						order = 300,
					},
					border = {
						name = "                    Border Texture",
						desc = "Selects the border texture",
						order = 301,
						type = "select",
						dialogControl = 'LSM30_Border',
						values = AceGUIWidgetLSMlists.border,
						get = function(info) return ready["icons"]["border"]["style"] end,
						set = function(info, val)
								ready["icons"]["border"]["style"] = val
								CDTL2:RefreshAllIcons()
							end,
					},
					borderColor = {
						name = "Color",
						desc = "Selects the border color",
						order = 302,
						type = "color",
						hasAlpha = true,
						get = function(info)
								local r = ready["icons"]["border"]["color"]["r"]
								local g = ready["icons"]["border"]["color"]["g"]
								local b = ready["icons"]["border"]["color"]["b"]
								local a = ready["icons"]["border"]["color"]["a"]
								
								return r, g, b, a
							end,
						set = function(info, red, green, blue, alpha)
								ready["icons"]["border"]["color"] = { r = red, g = green, b = blue, a = alpha }							
								CDTL2:RefreshAllIcons()
							end,
					},
					spacer310 = {
						name = "",
						type = "description",
						order = 310,
					},
					borderSize = {
						name = "Size",
						desc = "Sets the size of the border",
						order = 311,
						type = "range",
						softMin = 1,
						softMax = 40,
						bigStep = 1,
						get = function(info) return ready["icons"]["border"]["size"] end,
						set = function(info, val)
								ready["icons"]["border"]["size"] = val
								CDTL2:RefreshAllIcons()
							end,
					},
					borderPadding = {
						name = "Padding",
						desc = "Sets the size of the border",
						order = 311,
						type = "range",
						softMin = 0,
						softMax = 40,
						bigStep = 1,
						get = function(info) return ready["icons"]["border"]["padding"] end,
						set = function(info, val)
								ready["icons"]["border"]["padding"] = val
								CDTL2:RefreshAllIcons()
							end,
					},
					spacer400 = {
						name = "\n\n",
						type = "description",
						order = 400,
					},
					highlightStyle = {
						name = "Highlight Style",
						desc = "How to highlight icons",
						order = 401,
						type = "select",
						values = {
								["BORDER"] = "Border",
								["BORDER_FLASH"] = "Border Flash",
								["FLASH"] = "Flash Icon",
								["GLOW"] = "Glow",
							},
						get = function(info, index)
								return ready["icons"]["highlight"]["style"]
							end,
						set = function(info, val)
								ready["icons"]["highlight"]["style"] = val
								CDTL2:RefreshAllIcons(i)
							end,
					},
				}
			},
		}
	}
	
	return options
end

private.GetTextText = function(s, o, i, r, d)
	local options = {
		name = function(info)
				return " "
			end,
		desc = function(info)
				if r == "LANE" then
					return CDTL2:GetCustomTextTagDescription()
				else
					return CDTL2:GetCustomIconTagDescription()
				end
			end,
		type = "input",
		order = o + 1,
		disabled = d,
		hidden = function(info)
				return not s["used"]
			end,
		get = function(info)
				return s["text"]
			end,
		set = function(info, val)
				s["text"] = val
				
				if CDTL2:ScanForDynamicTags(val) then
					s["dtags"] = true
				end
				
				if CDTL2:ScanForTimeTags(val) then
					s["ttags"] = true
				end
				
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextEnabled = function(s, o, i, r)
	local options = {
		name = "Enabled",
		desc = "Show this text",
		order = o + 2,
		type = "toggle",
		width = 0.5,
		hidden = function(info)
				return not s["used"]
			end,
		get = function(info)
				return s["enabled"]
			end,
		set = function(info, val)
				s["enabled"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextEdit = function(s, o, i, r)
	local options = {
		name = "Edit",
		desc = "Show this text",
		order = o + 3,
		type = "toggle",
		width = 0.5,
		hidden = function(info)
				return not s["used"]
			end,
		get = function(info)
				return s["edit"]
			end,
		set = function(info, val)
				s["edit"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextFont = function(s, o, i, r)
	local options = {
		name = "Font",
		desc = "Selects the font for text on the bars",
		order = o + 4.1,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "select",
		dialogControl = 'LSM30_Font',
		values = AceGUIWidgetLSMlists.font,
		get = function(info) return s["font"] end,
		set = function(info, val)
				s["font"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextOutline = function(s, o, i, r)
	local options = {
		name = "Outline",
		desc = "Sets the text outline",
		order = o + 4.2,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "select",
		values = {
				["NONE"] = "None",
				["OUTLINE"] = "Outline",
				["THICKOUTLINE"] = "Thick Outline",
				["MONOCHROME"] = "Monochrome"
			},
		get = function(info) return s["outline"] end,
		set = function(info, val)
				s["outline"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextSize = function(s, o, i, r)
	local options = {
		name = "Font Size",
		desc = "Sets the size of the font",
		order = o + 4.4,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "range",
		softMin = 1,
		softMax = 64,
		bigStep = 1,
		get = function(info) return s["size"] end,
		set = function(info, val)
				s["size"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextColor = function(s, o, i, r)
	local options = {
		name = "Color",
		desc = "Selects the font color",
		order = o + 4.5,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "color",
		hasAlpha = true,
		get = function(info)
				local t = s["color"]
				
				local r = t["r"]
				local g = t["g"]
				local b = t["b"]
				local a = t["a"]
				return r, g, b, a
			end,
		set = function(info, red, green, blue, alpha)
				s["color"] = { r = red, g = green, b = blue, a = alpha }
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextShadowColor = function(s, o, i, r)
	local options = {
		name = "Shadow Color",
		desc = "Selects the shadow color",
		order = o + 4.6,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "color",
		hasAlpha = true,
		get = function(info)
				local t = s["shadColor"]
				
				local r = t["r"]
				local g = t["g"]
				local b = t["b"]
				local a = t["a"]
				return r, g, b, a
			end,
		set = function(info, red, green, blue, alpha)
				s["shadColor"] = { r = red, g = green, b = blue, a = alpha }
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextShadowXOffset = function(s, o, i, r)
	local options = {
		name = "Shadow x Offset",
		desc = "Sets the text shadow x offset",
		order = o + 4.8,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "range",
		softMin = -5,
		softMax = 5,
		bigStep = 1,
		get = function(info) return s["shadX"] end,
		set = function(info, val)
				s["shadX"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextShadowYOffset = function(s, o, i, r)
	local options = {
		name = "Shadow y Offset",
		desc = "Sets the text shadow y offset",
		order = o + 4.9,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "range",
		softMin = -5,
		softMax = 5,
		bigStep = 1,
		get = function(info) return s["shadY"] end,
		set = function(info, val)
				s["shadY"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextAnchor = function(s, o, i, r)
	local options = {
		name = "Anchor",
		desc = "Sets the text anchor point",
		order = o + 5.2,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "select",
		values = {
				["TOPLEFT"] = "TOPLEFT",
				["TOP"] = "TOP",
				["TOPRIGHT"] = "TOPRIGHT",
				["LEFT"] = "LEFT",
				["CENTER"] = "CENTER",
				["RIGHT"] = "RIGHT",
				["BOTTOMLEFT"] = "BOTTOMLEFT",
				["BOTTOM"] = "BOTTOM",
				["BOTTOMRIGHT"] = "BOTTOMRIGHT",
			},
		get = function(info) return s["anchor"] end,
		set = function(info, val)
				s["anchor"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextAlign = function(s, o, i, r)
	local options = {
		name = "Align",
		desc = "Sets the text alignment",
		order = o + 5.3,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "select",
		values = {
				["LEFT"] = "LEFT",
				["CENTER"] = "CENTER",
				["RIGHT"] = "RIGHT",
			},
		get = function(info) return s["align"] end,
		set = function(info, val)
				s["align"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextXOffset = function(s, o, i, r)
	local options = {
		name = "x Offset",
		desc = "Sets text x offset",
		order = o + 5.5,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "range",
		softMin = -5,
		softMax = 5,
		bigStep = 1,
		get = function(info) return s["offX"] end,
		set = function(info, val)
				s["offX"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end

private.GetTextYOffset = function(s, o, i, r)
	local options = {
		name = "y Offset",
		desc = "Sets text y offset",
		order = o + 5.6,
		hidden = function(info)
				return not s["edit"]
			end,
		type = "range",
		softMin = -5,
		softMax = 5,
		bigStep = 1,
		get = function(info) return s["offY"] end,
		set = function(info, val)
				s["offY"] = val
				if r == "LANE" then
					CDTL2:RefreshLane(i)
				elseif r == "BAR" then
					CDTL2:RefreshAllBars()
				elseif r == "ICON" then
					CDTL2:RefreshAllIcons()
				end
			end,
	}
	
	return options
end