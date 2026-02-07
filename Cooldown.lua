--[[
	Cooldown Timeline, Vreenak (US-Remulos)
	https://www.curseforge.com/wow/addons/cooldown-timeline
]]--

local private = {}
private.updatePollRate = 2
private.autohidePollRate = 5
private.dynamicTextPollRate = 10
private.timeTextPollRate = 2

function CDTL2:CreateCooldown(UID, cdType, cdData)
	local fName = "CDTL2_CD_"..UID
	local f = CreateFrame("Frame", fName, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	f.updateCount = 0
	
	f.data = {
		uid = UID,
		id = cdData["id"],
		type = cdType,
		name = cdData["name"],
		rank = cdData["rank"],
		desc = cdData["desc"],
		icon = cdData["icon"],
		oaf = cdData["oaf"],
		stacks = 0,
		
		targetID = cdData["targetID"],
		targetName = cdData["targetName"],
		
		itemID = cdData["itemID"],
		itemName = cdData["itemName"],
		
		link = cdData["link"],
		
		enabled = cdData["enabled"],
		ignored = cdData["ignored"],
		highlight = cdData["highlight"],
		pinned = cdData["pinned"],
		
		lane = cdData["lane"],
		barFrame = cdData["barFrame"],
		readyFrame = cdData["readyFrame"],
		
		baseCD = cdData["bCD"] / 1000,
		currentCD = cdData["bCD"] / 1000,
		endTime = cdData["endTime"],
		overrideCD = false,
	}

	if cdData["charges"] then
		f.data["charges"] = cdData["charges"]
	end
	
	if cdData["school"] then
		f.data["school"] = cdData["school"]
	end
	
	if cdData["runeIndex"] then
		f.data["runeIndex"] = cdData["runeIndex"]
	end
	
	if cdType == "runes" then
		f.data["runeGraceTime"] = 0
	end

	if cdData["setCustomCD"] then
		f.data["setCustomCD"] = cdData["setCustomCD"]

		if cdData["customCDTime"] then
			f.data["customCDTime"] = cdData["customCDTime"]
			f.data["baseCD"] = f.data["customCDTime"] / 1000
		end
	end
	
	if cdType == "items" then
		if cdData["itemIcon"] then
			f.data["itemIcon"] = cdData["itemIcon"]
		else
			local spellName, icon, originalIcon = CDTL2:GetSpellInfo(f.data["id"])
			f.data["icon"] = icon
			
			local item = Item:CreateFromItemID(f.data["itemID"])
			item:ContinueOnItemLoad(function()
				f.data["itemIcon"] = item:GetItemIcon()
				
				CDTL2:SetSpellData(f.data["name"], cdType, "icon", f.data["icon"])
				CDTL2:SetSpellData(f.data["name"], cdType, "itemIcon", f.data["itemIcon"])
			end)
		end
	end
	
	if cdData["trigger"] then
		f.data["trigger"] = cdData["trigger"]
	end
	
	-- ON UPDATE
	f:HookScript("OnUpdate", function(self, elapsed)
		private.CooldownUpdate(self, elapsed)
	end)
	
	f.icon = CDTL2:CreateIcon(fName, f)
	CDTL2:SendToLane(f) 
	
	f.bar = CDTL2:CreateBar(fName, f)
	CDTL2:SendToBarFrame(f)
	
	table.insert(CDTL2.cooldowns, f)
	
	return f
end

function CDTL2:CreateIcon(fName, cd)
	local frameName = fName.."_Icon"
	local f = CreateFrame("Frame", frameName, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)

	f.uid = cd.data["uid"]
	f.valid = cd.data["enabled"]
	f.readyTime = 0
	f.yOffset = 0
	f.sOffset = 0
	f.currentCD = 0

	f.tx = f:CreateTexture()
	
	f.db = CreateFrame("Frame", frameName.."_DB", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.db:SetParent(f)
	f.db.bg = f.db:CreateTexture(nil, "BACKGROUND")
	f.db.text = f.db:CreateFontString(nil,"ARTWORK")
	if not CDTL2.db.profile.global["unlockFrames"] then
		f.db:Hide()
	end
	
	f:SetFrameLevel(20)
	return f
end

function CDTL2:CreateBar(fName, cd)
	local frameName = fName.."_Bar"
	local f = CreateFrame("Frame", frameName, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	
	f.valid = cd.data["enabled"]
	
	f.bar = CreateFrame("StatusBar", frameName.."_BA", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.bar:SetParent(f)
	f.bar.transitionThreshold = 0
	f.bar.bg = f:CreateTexture(nil, "BACKGROUND")
	
	f.icon = CreateFrame("Frame", frameName.."_IC", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.icon:SetParent(f)
	f.icon.tx = f.icon:CreateTexture(nil, "BACKGROUND")
	
	f.db = CreateFrame("Frame", frameName.."_DB", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	f.db:SetParent(f)
	f.db.bg = f.db:CreateTexture(nil, "BACKGROUND")
	f.db.text = f.db:CreateFontString(nil,"ARTWORK")
	if not CDTL2.db.profile.global["unlockFrames"] then
		f.db:Hide()
	end
	
	f:SetFrameLevel(20)
	return f
end

function CDTL2:RefreshAllBars()
	for _, cd in pairs(CDTL2.cooldowns) do
		CDTL2:RefreshBar(cd)
	end
end

function CDTL2:RefreshAllIcons()
	for _, cd in pairs(CDTL2.cooldowns) do
		CDTL2:RefreshIcon(cd)
	end
end

function CDTL2:RefreshBar(cd)
	local f = cd.bar
	local s = nil
	local p = f:GetParent():GetName()
	
	if p == "CDTL2_BarFrame_1_MF" or p == "CDTL2_BarFrame_2_MF" or p == "CDTL2_BarFrame_3_MF" then
		if cd.data["barFrame"] == 0 or cd.data["barFrame"] == 1 then
			s = CDTL2.db.profile.barFrames["frame1"]
		elseif cd.data["barFrame"] == 2 then
			s = CDTL2.db.profile.barFrames["frame2"]
		elseif cd.data["barFrame"] == 3 then
			s = CDTL2.db.profile.barFrames["frame3"]
		end
	else
		s = CDTL2.db.profile.barFrames["frame1"]
	end
		
	f:ClearAllPoints()
	f:SetPoint("CENTER", 0, 0)
	f:SetWidth(s["width"])
	f:SetHeight(s["height"])
	
	-- ICON
	local barWidth = s["width"]
	local iconOffset = 0
	if s["bar"]["iconEnabled"] then
		if not f.icon then
			f.icon = CreateFrame("Frame", f:GetName().."_BD", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
			f.icon:SetParent(f)
		end
		
		barWidth = barWidth - s["height"]
		iconOffset = s["height"]
			
		if s["bar"]["iconPosition"] == "RIGHT" then
			iconOffset = -s["height"]
		end
		
		f.icon:ClearAllPoints()
		f.icon:SetPoint(s["bar"]["iconPosition"], 0, 0)
		f.icon:SetWidth(s["height"])
		f.icon:SetHeight(s["height"])
		
		f.icon.tx:SetAllPoints(f.icon)
		
		local icon = cd.data["icon"]
		f.icon.tx:SetTexture(icon)
		
		local zoom = CDTL2.db.profile.global["zoom"]
		local tl = zoom - 1
		local br = 1 - (zoom - 1)
		f.icon.tx:SetTexCoord(tl, br, tl, br)
		
		if CDTL2.Masque then
			-- Kill masque for this icon(button)
			CDTL2.masqueGroup = CDTL2.Masque:Group("CDTL2")
			CDTL2.masqueGroup:RemoveButton(f.icon)
			
			-- Reapply masque
			CDTL2.masqueGroup:AddButton(f.icon, { Icon = f.icon.tx })
		end
		
		f.icon:Show()
	else
		if f.icon then
			barWidth = s["width"]
			iconOffset = 0
			
			f.icon:ClearAllPoints()
			f.icon:SetPoint(s["bar"]["iconPosition"], 0, 0)
			f.icon:SetWidth(s["height"])
			f.icon:SetHeight(s["height"])
			
			f.icon:Hide()
		end
	end
	
	-- BAR	
	f.bar:ClearAllPoints()
	f.bar:SetPoint(s["bar"]["iconPosition"], iconOffset, 0)
	f.bar:SetSize(barWidth, s["height"])
	
	-- FOREGROUND
	f.bar:SetMinMaxValues(0, 1)
	f.bar:SetValue(0.5)
	f.bar:SetStatusBarTexture(CDTL2.LSM:Fetch("statusbar", s["bar"]["fgTexture"]))
	f.bar:GetStatusBarTexture():SetHorizTile(false)
	f.bar:GetStatusBarTexture():SetVertTile(false)
	--[[f.bar:SetStatusBarColor(
		s["bar"]["fgTextureColor"]["r"],
		s["bar"]["fgTextureColor"]["g"],
		s["bar"]["fgTextureColor"]["b"],
		s["bar"]["fgTextureColor"]["a"]
	)]]--
	
	local fgColor = s["bar"]["fgTextureColor"]
	if s["bar"]["fgSchoolColor"] then
		local schoolColor = CDTL2.db.profile.global["schoolColors"]["Other"]
		if cd.data["school"] then
			schoolColor = CDTL2.db.profile.global["schoolColors"][cd.data["school"]]
		end
		
		fgColor = schoolColor
	elseif CDTL2.player["class"] then
		if s["bar"]["fgClassColor"] then
			fgColor = CDTL2.db.profile.global["classColors"][CDTL2.player["class"]]
		end
	end
	
	f.bar:SetStatusBarColor(
		fgColor["r"],
		fgColor["g"],
		fgColor["b"],
		fgColor["a"]
	)
	
	-- BACKGROUND
	f.bar.bg:SetTexture(CDTL2.LSM:Fetch("statusbar", s["bar"]["bgTexture"]))
	f.bar.bg:SetAllPoints(true)
	--[[f.bar.bg:SetVertexColor(
		s["bar"]["bgTextureColor"]["r"],
		s["bar"]["bgTextureColor"]["g"],
		s["bar"]["bgTextureColor"]["b"],
		s["bar"]["bgTextureColor"]["a"]
	)]]--
	
	local bgColor = s["bar"]["bgTextureColor"]
	if CDTL2.player["class"] then
		if s["bar"]["bgClassColor"] then
			bgColor = CDTL2.db.profile.global["classColors"][CDTL2.player["class"]]
		end
	end
	
	f.bar.bg:SetVertexColor(
		bgColor["r"],
		bgColor["g"],
		bgColor["b"],
		bgColor["a"]
	)
		
	-- TEXT
	if s["bar"]["text1"]["enabled"] or s["bar"]["text2"]["enabled"] or s["bar"]["text3"]["enabled"] then
		if not f.txt then
			f.txt = CreateFrame("Frame", f:GetName().."_TEXT", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
			f.txt:SetParent(f)
			f.txt.bg = f.txt:CreateTexture(nil, "BACKGROUND")
		end
		
		-- TEXT1
		if s["bar"]["text1"]["enabled"] then
			if not f.txt.text1 then
				f.txt.text1 = f.txt:CreateFontString(nil, "ARTWORK")
			end
			
			local ts = s["bar"]["text1"]
			local t = f.txt.text1
			t:ClearAllPoints()
			t:SetPoint(
					ts["align"],
					f,
					ts["anchor"],
					ts["offX"],
					ts["offY"]
				)
			t:SetFont(CDTL2.LSM:Fetch("font", ts["font"]), ts["size"], ts["outline"])
			t:SetText(CDTL2:ConvertTextTags(ts["text"], cd))
			t:SetTextColor(
					ts["color"]["r"],
					ts["color"]["g"],
					ts["color"]["b"],
					ts["color"]["a"]
				)
			t:SetShadowColor(
					ts["shadColor"]["r"],
					ts["shadColor"]["g"],
					ts["shadColor"]["b"],
					ts["shadColor"]["a"]
				)
			t:SetShadowOffset(ts["shadX"], ts["shadY"])
			t:SetNonSpaceWrap(false)
			t:Show()
		else
			if f.txt.text1 then
				f.txt.text1:Hide()
			end
		end
		-- TEXT2
		if s["bar"]["text2"]["enabled"] then
			if not f.txt.text2 then
				f.txt.text2 = f.txt:CreateFontString(nil, "ARTWORK")
			end
			
			t = f.txt.text2
			ts = s["bar"]["text2"]
			t:ClearAllPoints()
			t:SetPoint(
					ts["align"],
					f,
					ts["anchor"],
					ts["offX"],
					ts["offY"]
				)
			t:SetFont(CDTL2.LSM:Fetch("font", ts["font"]), ts["size"], ts["outline"])
			t:SetText(CDTL2:ConvertTextTags(ts["text"], cd))
			t:SetTextColor(
					ts["color"]["r"],
					ts["color"]["g"],
					ts["color"]["b"],
					ts["color"]["a"]
				)
			t:SetShadowColor(
					ts["shadColor"]["r"],
					ts["shadColor"]["g"],
					ts["shadColor"]["b"],
					ts["shadColor"]["a"]
				)
			t:SetShadowOffset(ts["shadX"], ts["shadY"])
			t:SetNonSpaceWrap(false)
			t:Show()
		else
			if f.txt.text2 then
				f.txt.text2:Hide()
			end
		end
		-- TEXT3
		if s["bar"]["text3"]["enabled"] then
			if not f.txt.text3 then
				f.txt.text3 = f.txt:CreateFontString(nil, "ARTWORK")
			end
			
			t = f.txt.text3
			ts = s["bar"]["text3"]
			t:ClearAllPoints()
			t:SetPoint(
					ts["align"],
					f,
					ts["anchor"],
					ts["offX"],
					ts["offY"]
				)
			t:SetFont(CDTL2.LSM:Fetch("font", ts["font"]), ts["size"], ts["outline"])
			t:SetText(CDTL2:ConvertTextTags(ts["text"], cd))
			t:SetTextColor(
					ts["color"]["r"],
					ts["color"]["g"],
					ts["color"]["b"],
					ts["color"]["a"]
				)
			t:SetShadowColor(
					ts["shadColor"]["r"],
					ts["shadColor"]["g"],
					ts["shadColor"]["b"],
					ts["shadColor"]["a"]
				)
			t:SetShadowOffset(ts["shadX"], ts["shadY"])
			t:SetNonSpaceWrap(false)
			t:Show()
		else
			if f.txt.text3 then
				f.txt.text3:Hide()
			end
		end
	else
		if f.txt.text1 then
			f.txt.text1:Hide()
		end
		
		if f.txt.text2 then
			f.txt.text2:Hide()
		end
		
		if f.txt.text3 then
			f.txt.text3:Hide()
		end
	end
	
	-- TRANSITION
	if s["transition"]["showTI"] then
		if not f.bd then
			f.bar.ti = CreateFrame("Frame", f:GetName().."_TI", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
			f.bar.ti:SetParent(f.bar)
			f.bar.ti.bg = f.bar.ti:CreateTexture(nil, "BACKGROUND")
		end
		
		private.CalcTransitionIndicator(cd, s)
		f.bar.ti:Show()
		f.txt:SetFrameLevel(f.bar.ti:GetFrameLevel() + 1)
	else
		if f.bar.ti then
			f.bar.ti:Hide()
		end
		
		private.CalcTransitionIndicator(cd, s)
	end	
	
	-- BORDER
	if s["bar"]["border"]["style"] ~= "None" then
		if not f.bd then
			f.bd = CreateFrame("Frame", f:GetName().."_BD", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
			f.bd:SetParent(f)
		end
		
		CDTL2:SetBorder(f.bd, s["bar"]["border"])
		f.bd:SetFrameLevel(f:GetFrameLevel() + 1)
		f.bd:Show()
	else
		if f.bd then
			f.bd:Hide()
		end
	end
	
	-- DEBUG/UNLOCK
	f.db:ClearAllPoints()
	f.db:SetPoint("CENTER", 0, 0)
	f.db.text:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 10, "NONE")
	f.db.text:ClearAllPoints()
	f.db.text:SetPoint("CENTER", 0, 0)
	f.db.text:SetText(cd.data["uid"].."_B\n"..cd.data["name"])
	f.db:SetSize(s["width"], s["height"])
	f.db.bg:SetAllPoints(true)
	f.db.bg:SetColorTexture( 0.1, 0.1, 0.1, 0.5 )
	
	if CDTL2.db.profile.global["debugMode"] then
		CDTL2:DebugOn(f)
	else
		CDTL2:DebugOff(f)
	end
end

function CDTL2:RefreshIcon(cd)
	local f = cd.icon
	local s = CDTL2.db.profile.lanes["lane1"]
	local p = f:GetParent():GetName()
	
	if p == "CDTL2_Lane_1" or p == "CDTL2_Lane_2" or p == "CDTL2_Lane_3" then
		if cd.data["lane"] == 0 or cd.data["lane"] == 1 then
			s = CDTL2.db.profile.lanes["lane1"]
		elseif cd.data["lane"] == 2 then
			s = CDTL2.db.profile.lanes["lane2"]
		elseif cd.data["lane"] == 3 then
			s = CDTL2.db.profile.lanes["lane3"]
		end
	elseif p == "CDTL2_Ready_1_MF" or p == "CDTL2_Ready_2_MF" or p == "CDTL2_Ready_3_MF" then
		if cd.data["readyFrame"] == 0 or cd.data["readyFrame"] == 1 then
			s = CDTL2.db.profile.ready["ready1"]
		elseif cd.data["readyFrame"] == 2 then
			s = CDTL2.db.profile.ready["ready2"]
		elseif cd.data["readyFrame"] == 3 then
			s = CDTL2.db.profile.ready["ready3"]
		end
	end

	if cd.data["setCustomCD"] then
		if cd.data["customCDTime"] then
			cd.data["baseCD"] = cd.data["customCDTime"] / 1000
		else
			local specialCase = false
			if cd.data["type"] == "items" then
				specialCase = true
			end
			local cds = CDTL2:GetSpellSettings(cd.data["name"], cd.data["type"], specialCase)
			if cds then
				cd.data["baseCD"] = cds["bCD"] / 1000
			end
		end
	else
		if cd.data["type"] ~= "testing" then
			local specialCase = false
			if cd.data["type"] == "items" then
				specialCase = true
			end

			local cds = CDTL2:GetSpellSettings(cd.data["name"], cd.data["type"], specialCase)
			if cds then
				cd.data["baseCD"] = cds["bCD"] / 1000
			end
		end
	end
	
	f.yOffset = s["iconOffset"]
	
	f:ClearAllPoints()
	f:SetPoint("CENTER", 0, 0)
	f:SetSize(s["icons"]["size"], s["icons"]["size"])
	
	-- Set the icon texture
	local icon = cd.data["icon"]
	if cd.data["type"] == "items" then
		if CDTL2.db.profile.global[cd.data["type"]]["useItemIcon"] then
			icon = cd.data["itemIcon"]
		end
	end
	f.tx:SetAllPoints()
	f.tx:SetTexture(icon)
	f.tx:SetAlpha(s["icons"]["alpha"])
	
	-- Set the icon texture zoom
	local zoom = CDTL2.db.profile.global["zoom"]
	local tl = zoom - 1
	local br = 1 - (zoom - 1)
	f.tx:SetTexCoord(tl, br, tl, br)
	
	if CDTL2.Masque then
		-- Kill masque for this icon(button)
		CDTL2.masqueGroup = CDTL2.Masque:Group("CDTL2")
		CDTL2.masqueGroup:RemoveButton(f)
		
		-- Reapply masque
		CDTL2.masqueGroup:AddButton(f, { Icon = f.tx })	
	end
	
	-- TEXT
	if s["icons"]["text1"]["enabled"] or s["icons"]["text2"]["enabled"] or s["icons"]["text3"]["enabled"] then
		if not f.txt then
			f.txt = CreateFrame("Frame", f:GetName().."_TEXT", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
			f.txt:SetParent(f)
			f.txt.bg = f.txt:CreateTexture(nil, "BACKGROUND")
		end
		
		-- TEXT1
		if s["icons"]["text1"]["enabled"] then
			if not f.txt.text1 then
				f.txt.text1 = f.txt:CreateFontString(nil, "ARTWORK")
			end
			
			local ts = s["icons"]["text1"]
			local t = f.txt.text1
			t:ClearAllPoints()
			t:SetPoint(
					ts["align"],
					f,
					ts["anchor"],
					ts["offX"],
					ts["offY"]
				)
			t:SetFont(CDTL2.LSM:Fetch("font", ts["font"]), ts["size"], ts["outline"])
			t:SetText(CDTL2:ConvertTextTags(ts["text"], cd))
			t:SetTextColor(
					ts["color"]["r"],
					ts["color"]["g"],
					ts["color"]["b"],
					ts["color"]["a"]
				)
			t:SetShadowColor(
					ts["shadColor"]["r"],
					ts["shadColor"]["g"],
					ts["shadColor"]["b"],
					ts["shadColor"]["a"]
				)
			t:SetShadowOffset(ts["shadX"], ts["shadY"])
			t:SetNonSpaceWrap(false)
			t:Show()
		else
			if f.txt.text1 then
				f.txt.text1:Hide()
			end
		end
		-- TEXT2
		if s["icons"]["text2"]["enabled"] then
			if not f.txt.text2 then
				f.txt.text2 = f.txt:CreateFontString(nil, "ARTWORK")
			end
			
			t = f.txt.text2
			ts = s["icons"]["text2"]
			t:ClearAllPoints()
			t:SetPoint(
					ts["align"],
					f,
					ts["anchor"],
					ts["offX"],
					ts["offY"]
				)
			t:SetFont(CDTL2.LSM:Fetch("font", ts["font"]), ts["size"], ts["outline"])
			t:SetText(CDTL2:ConvertTextTags(ts["text"], cd))
			t:SetTextColor(
					ts["color"]["r"],
					ts["color"]["g"],
					ts["color"]["b"],
					ts["color"]["a"]
				)
			t:SetShadowColor(
					ts["shadColor"]["r"],
					ts["shadColor"]["g"],
					ts["shadColor"]["b"],
					ts["shadColor"]["a"]
				)
			t:SetShadowOffset(ts["shadX"], ts["shadY"])
			t:SetNonSpaceWrap(false)
			t:Show()
		else
			if f.txt.text2 then
				f.txt.text2:Hide()
			end
		end
		-- TEXT3
		if s["icons"]["text3"]["enabled"] then
			if not f.txt.text3 then
				f.txt.text3 = f.txt:CreateFontString(nil, "ARTWORK")
			end
			
			t = f.txt.text3
			ts = s["icons"]["text3"]
			t:ClearAllPoints()
			t:SetPoint(
					ts["align"],
					f,
					ts["anchor"],
					ts["offX"],
					ts["offY"]
				)
			t:SetFont(CDTL2.LSM:Fetch("font", ts["font"]), ts["size"], ts["outline"])
			t:SetText(CDTL2:ConvertTextTags(ts["text"], cd))
			t:SetTextColor(
					ts["color"]["r"],
					ts["color"]["g"],
					ts["color"]["b"],
					ts["color"]["a"]
				)
			t:SetShadowColor(
					ts["shadColor"]["r"],
					ts["shadColor"]["g"],
					ts["shadColor"]["b"],
					ts["shadColor"]["a"]
				)
			t:SetShadowOffset(ts["shadX"], ts["shadY"])
			t:SetNonSpaceWrap(false)
			t:Show()
		else
			if f.txt.text3 then
				f.txt.text3:Hide()
			end
		end
	else
		if f.txt then
			if f.txt.text1 then
				f.txt.text1:Hide()
			end
			
			if f.txt.text2 then
				f.txt.text2:Hide()
			end
			
			if f.txt.text3 then
				f.txt.text3:Hide()
			end
		end
	end
	
	-- BORDER
	if s["icons"]["border"]["style"] ~= "None" then
		if not f.bd then
			f.bd = CreateFrame("Frame", f:GetName().."_BD", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
			f.bd:SetParent(f)
		end
		
		CDTL2:SetBorder(f.bd, s["icons"]["border"])
		f.bd:SetFrameLevel(f:GetFrameLevel() + 1)
		f.bd:Show()
	else
		if f.bd then
			f.bd:Hide()
		end
	end
		
	-- HIGHLIGHT BORDER
	if cd.data["highlight"] then
		if s["icons"]["highlight"]["border"]["style"] ~= "None" then
			if not f.hl then
				f.hl = CreateFrame("Frame", f:GetName().."_BD", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
				f.hl:SetParent(f)
				f.hl.tx = f.hl:CreateTexture()
			end
			
			CDTL2:SetBorder(f.hl, s["icons"]["highlight"]["border"])
			f.hl:ClearAllPoints()
			f.hl:SetPoint("CENTER", 0, 0)
			f.hl:SetSize(s["icons"]["size"], s["icons"]["size"])
			f.hl.tx:SetAllPoints(true)
			f.hl.tx:SetColorTexture( 1, 1, 1, 0.5 )
			f.hl:SetFrameLevel(f.hl:GetFrameLevel() + 1)

			CDTL2:RemoveHighlights(f, s)
			
			local style = s["icons"]["highlight"]["style"]
			if style == "GLOW" then
				ActionButton_ShowOverlayGlow(f)
			elseif style == "BORDER" then
				f.hl:SetBackdropBorderColor(
					s["icons"]["highlight"]["border"]["color"]["r"],
					s["icons"]["highlight"]["border"]["color"]["g"],
					s["icons"]["highlight"]["border"]["color"]["b"],
					s["icons"]["highlight"]["border"]["color"]["a"]
				)
			elseif style == "BORDER_FLASH" then
				f.hl:SetBackdropBorderColor(
					s["icons"]["highlight"]["border"]["color"]["r"],
					s["icons"]["highlight"]["border"]["color"]["g"],
					s["icons"]["highlight"]["border"]["color"]["b"],
					s["icons"]["highlight"]["border"]["color"]["a"]
				)
				
				f.hl.agBorderPulse = f.hl:CreateAnimationGroup()
				f.hl.agBorderPulse:SetLooping("BOUNCE")
				f.hl.agBorderPulse:SetToFinalAlpha(true)
				
				local borderPulse = f.hl.agBorderPulse:CreateAnimation("Alpha")
				borderPulse:SetFromAlpha(0.2)
				borderPulse:SetToAlpha(1)
				borderPulse:SetDuration(0.5)
				borderPulse:SetOrder(1)
				
				f.hl.agBorderPulse:Play()			
			elseif style == "FLASH" then
				f.hl:ClearAllPoints()
				f.hl:SetPoint("CENTER", 0, 0)
				f.hl:SetSize(s["icons"]["size"], s["icons"]["size"])
				f.hl.tx:SetColorTexture( 1, 1, 1, 1 )
				
				f.hl.agPulse = f.hl:CreateAnimationGroup()
				f.hl.agPulse:SetLooping("BOUNCE")
				f.hl.agPulse:SetToFinalAlpha(true)
				
				local borderPulse = f.hl.agPulse:CreateAnimation("Alpha")
				borderPulse:SetFromAlpha(0.2)
				borderPulse:SetToAlpha(1)
				borderPulse:SetDuration(0.5)
				borderPulse:SetOrder(1)
				
				f.hl.agPulse:Play()
			else
				CDTL2:RemoveHighlights(f, s)
			end
			
			f.hl:Show()
		else
			if f.hl then
				f.hl:Hide()
			end
		end
	else
		if f.hl then
			f.hl:Hide()
		end
	end
	
	f:EnableMouse(false)
	
	-- DEBUG/UNLOCK
	f.db:ClearAllPoints()
	f.db:SetPoint("CENTER", 0, 0)
	f.db.text:SetFont(CDTL2.LSM:Fetch("font", "Fira Sans Condensed"), 10, "NONE")
	f.db.text:ClearAllPoints()
	f.db.text:SetPoint("CENTER", 0, 0)
	f.db.text:SetText(cd.data["uid"].."_B\n"..cd.data["name"])
	f.db:SetSize(s["icons"]["size"], s["icons"]["size"])
	f.db.bg:SetAllPoints(true)
	f.db.bg:SetColorTexture( 0.1, 0.1, 0.1, 0.5 )
	
	if CDTL2.db.profile.global["debugMode"] then
		CDTL2:DebugOn(f)
	else
		CDTL2:DebugOff(f)
	end
end

private.BarUpdate = function(f, elapsed)
	local d = f.data
	local ba = f.bar
	ba.currentCD = d["currentCD"]
	
	local p = ba:GetParent():GetName()
	if p == "CDTL2_BarFrame_1_MF" or p == "CDTL2_BarFrame_2_MF" or p == "CDTL2_BarFrame_3_MF" then
		if d["currentCD"] > 0 then
			local s = nil
			if d["barFrame"] == 1 then
				s = CDTL2.db.profile.barFrames["frame1"]
			elseif d["barFrame"] == 2 then
				s = CDTL2.db.profile.barFrames["frame2"]
			elseif d["barFrame"] == 3 then
				s = CDTL2.db.profile.barFrames["frame3"]
			end
			
			local pBase = d["baseCD"]
			local pCurrent = d["currentCD"]
			
			if d["lane"] == 0 then
				-- For now, do nothing
			else
				if s["transition"]["hideTransitioned"] then
					--CDTL2:Print(tostring(d["currentCD"]).." - "..tostring(ba.transitionThreshold))
					if d["currentCD"] > ba.transitionThreshold then
						if not ba.valid then
							ba.valid = true
							ba:GetParent().triggerUpdate = true
						end
						
						if s["transition"]["style"] == "SHORTEN" then
							pBase = pBase - ba.transitionThreshold
							pCurrent = pCurrent - ba.transitionThreshold
						end
					else
						if ba.valid then
							ba.valid = false
							ba:GetParent().triggerUpdate = true
						end
					end
				end
			end
			
			local iconPercent = private.CalcLinearPosition(pCurrent, pBase)
			ba.bar:SetValue(iconPercent)
			
			if ba:GetAlpha() ~= 0 then
				private.UpdateText(f, ba.txt.text1, s["bar"]["text1"], s["bar"]["text1"]["text"])
				private.UpdateText(f, ba.txt.text2, s["bar"]["text2"], s["bar"]["text2"]["text"])
				private.UpdateText(f, ba.txt.text3, s["bar"]["text3"], s["bar"]["text3"]["text"])
			end
		else
			CDTL2:SendToBarHolding(f)
		end
	end
end

private.CalcLinearPosition = function(current, total, s)
	local p = 1

	if current < total then
		p = current / total
	end
	
	return p
end

private.CalcSplitPosition = function(current, total, s)
	local p = 1
	local max = 100
	local value = (current / total) * 100
	
	local ss = nil
	if s["mode"]["type"] == "SPLIT" then
		ss = s["mode"]["split"]
		if total > ss["max"] then
			total = ss["max"]
		end
	elseif s["mode"]["type"] == "SPLIT_ABS" then
		ss = s["mode"]["splitAbs"]
		max = ss["max"]
		value = current
		total = ss["max"]
	end
	
	local splits = ss["count"]
	
	if current < total then
		if splits == 1 then
			local s1v = ss["s1v"]
			local s1p = ss["s1p"]
			
			if value > s1v then
				local rPercent = max - s1v
				local rSize = 1 - s1p
				local cPercent = value - s1v
				local aPercent = cPercent / rPercent
				p = s1p + (rSize * aPercent)
			else
				local rPercent = s1v
				local rSize = s1p
				local cPercent = value - s1v
				local aPercent = cPercent / rPercent
				p = s1p + (rSize * aPercent)
			end
		elseif splits == 2 then
			local s1v = ss["s1v"]
			local s1p = ss["s1p"]
			local s2v = ss["s2v"]
			local s2p = ss["s2p"]
			
			if value > s2v then
				local rPercent = max - s2v
				local rSize = 1 - s2p
				local cPercent = value - s2v
				local aPercent = cPercent / rPercent
				p = s2p + (rSize * aPercent)
			elseif value > s1v then
				local rPercent = s2v - s1v
				local rSize = s2p - s1p
				local cPercent = value - s1v
				local aPercent = cPercent / rPercent
				p = s1p + (rSize * aPercent)
			else
				local rPercent = s1v
				local rSize = s1p
				local cPercent = value - s1v
				local aPercent = cPercent / rPercent
				p = s1p + (rSize * aPercent)
			end
		elseif splits == 3 then
			local s1v = ss["s1v"]
			local s1p = ss["s1p"]
			local s2v = ss["s2v"]
			local s2p = ss["s2p"]
			local s3v = ss["s3v"]
			local s3p = ss["s3p"]
			
			if value > s3v then
				local rPercent = max - s3v
				local rSize = 1 - s3p
				local cPercent = value - s3v
				local aPercent = cPercent / rPercent
				p = s3p + (rSize * aPercent)
			elseif value > s2v then
				local rPercent = s3v - s2v
				local rSize = s3p - s2p
				local cPercent = value - s2v
				local aPercent = cPercent / rPercent
				p = s2p + (rSize * aPercent)
			elseif value > s1v then
				local rPercent = s2v - s1v
				local rSize = s2p - s1p
				local cPercent = value - s1v
				local aPercent = cPercent / rPercent
				p = s1p + (rSize * aPercent)
			else
				local rPercent = s1v
				local rSize = s1p
				local cPercent = value - s1v
				local aPercent = cPercent / rPercent
				p = s1p + (rSize * aPercent)
			end
		end
	end
	
	return p
end

private.CalcTransitionIndicator = function(f, s)
	local ls = nil
	if f.data["lane"] == 1 then
		ls = CDTL2.db.profile.lanes["lane1"]
	elseif f.data["lane"] == 2 then
		ls = CDTL2.db.profile.lanes["lane2"]
	elseif f.data["lane"] == 3 then
		ls = CDTL2.db.profile.lanes["lane3"]
	end
	
	if ls then
		local mode = ls["mode"]["type"]
		
		local ms = nil
		if mode == "LINEAR" then
			ms = ls["mode"]["linear"]
		elseif mode == "LINEAR_ABS" then
			ms = ls["mode"]["linearAbs"]
		elseif mode == "SPLIT" then
			ms = ls["mode"]["split"]
		elseif mode == "SPLIT_ABS" then
			ms = ls["mode"]["splitAbs"]
		end
		
		f.bar.transitionThreshold = ms["max"]
		
		-- INDICATIOR
		local position = 0
		local width = s["transition"]["width"]
		if s["transition"]["showTI"] then
			local style = s["transition"]["style"]
			
			if style == "SHORTEN" then
				f.bar.bar.ti:SetAlpha(0)
			else
				if style == "LINE" then
					local bWidth = s["width"] - width
					if s["bar"]["iconEnabled"] then
						bWidth = bWidth - s["height"]
					end
					
					--position = (ms["max"] / f.data["baseCD"]) * bWidth
					position = f.data["baseCD"] > 0 and (ms["max"] / f.data["baseCD"]) * bWidth or bWidth
				elseif style == "REGION" then
					local percent = ms["max"] / f.data["baseCD"]
					
					local bWidth = s["width"] - width
					if s["bar"]["iconEnabled"] then
						bWidth = bWidth - s["height"]
					end
					
					width = bWidth * percent
					position = percent / 2
				end
				
				if f.bar.bar.ti then
					f.bar.bar.ti:SetAlpha(1)
				end
			end
		else
			if f.bar.bar.ti then
				f.bar.bar.ti:SetAlpha(0)
			end
		end
		
		if f.bar.bar.ti then		
			f.bar.bar.ti:ClearAllPoints()
			f.bar.bar.ti:SetPoint("LEFT", position, 0)
			f.bar.bar.ti:SetSize(width, s["height"])
			f.bar.bar.ti.bg:SetTexture(CDTL2.LSM:Fetch("statusbar", s["transition"]["texture"]))
			f.bar.bar.ti.bg:SetAllPoints(true)
			f.bar.bar.ti.bg:SetVertexColor(
				s["transition"]["textureColor"]["r"],
				s["transition"]["textureColor"]["g"],
				s["transition"]["textureColor"]["b"],
				s["transition"]["textureColor"]["a"]
			)
		end
	else
		if f.bar.bar.ti then
			f.bar.bar.ti:SetAlpha(0)
		end
		
		f.bar.transitionThreshold = 10000000
	end
end

private.CooldownUpdate = function(f, elapsed)
	local d = f.data
	local ic = f.icon
	local ba = f.bar
	
	local icVisible = ic:IsVisible()
	local baVisible = ba:IsVisible()
	
	if icVisible or baVisible then
		-- SPELLS
		if d["type"] == "spells" or d["type"] == "petspells" then
			if d["oaf"] then
				if CDTL2:AuraExists("player", d["name"]) or UnitChannelInfo("player") then
					-- Placeholder
				else
					--local start, duration, enabled, _ = GetSpellCooldown(d["id"])
					local start, duration, enabled = CDTL2:GetSpellCooldown(d["id"])
					
					if enabled == 0 then
						-- Placeholder

					else
						if d["currentCD"] >= 0 then
							d["currentCD"] = d["currentCD"] - elapsed
							
							
							if not d["overrideCD"] then
								if f.updateCount == 0 or f.updateCount % 50 == 0 then
									if d["setCustomCD"] then
										if d["customCDTime"] then
											d["baseCD"] = d["customCDTime"] / 1000
										end
									end


									--local start, duration, enabled, _ = GetSpellCooldown(d["id"])
									local start, duration, enabled = CDTL2:GetSpellCooldown(d["id"])
									d["currentCD"] = start + duration - GetTime()
								end
							end
						end
					end
				end
			else
				if d["currentCD"] >= 0 then
					d["currentCD"] = d["currentCD"] - elapsed

					if not d["overrideCD"] then
						if f.updateCount == 0 or f.updateCount % 50 == 0 then
							if d["setCustomCD"] then
								if d["customCDTime"] then
									d["baseCD"] = d["customCDTime"] / 1000
								end
							end

							--local start, duration, enabled, _ = GetSpellCooldown(d["id"])
							--local start, duration, enabled = CDTL2:GetSpellCooldown(d["id"])
							--d["currentCD"] = start + duration - GetTime()

							if enabled == 0 or enabled == false then
								CDTL2:SetSpellData(d["name"], "spells", "oaf", true)
								d["oaf"] = true
							end

							--if d["charges"] ~= 0 then
								--local currentCharges, maxCharges, cooldownStart, cooldownDuration = CDTL2:GetSpellCharges(d["id"])

								--if currentCharges < maxCharges then
									--CDTL2:Print("CHARGES")
								--end
							--else
								--CDTL2:Print("NO CHARGES")
								

								local start, duration, enabled = CDTL2:GetSpellCooldown(d["id"])
								d["currentCD"] = start + duration - GetTime()

								--if d["name"] == "Primal Rage" or d["name"] == "Implosive Trap" then
									--CDTL2:Print(d["name"].." - "..d["currentCD"].." : "..tostring(duration))
								--end
							--end
							
							if f.updateCount == 0 and CDTL2.db.profile.global["detectSharedCD"] then
								CDTL2:ScanSharedSpellCooldown(d["name"], d["currentCD"])
							end
						end
					end
				end
			end
			
		-- ITEMS
		elseif d["type"] == "items" then
			if f.updateCount % 50 == 0 then
				if d["baseCD"] == 0 then
					d["currentCD"] = 1000
					
					local tinker, slot = CDTL2:CheckEngTinkerCases(d["name"])
					if tinker then
						local _, spellID = GetItemSpell(d["itemID"])
						if spellID == d["id"] then
							local start, duration, enabled = CDTL2:GetInventoryItemCooldown("player", slot)
							
							d["baseCD"] = duration
							CDTL2:SetSpellData(d["name"], "items", "bCD", duration * 1000)
						end
					else
						local start, duration, enabled = C_Container.GetItemCooldown(d["itemID"])
						
						d["baseCD"] = duration
						CDTL2:SetSpellData(d["name"], "items", "bCD", duration * 1000)
					end
					
					if d["baseCD"] > 3 and d["baseCD"] <= CDTL2.db.profile.global["items"]["ignoreThreshold"] then
						d["ignored"] = false
						CDTL2:SetSpellData(d["name"], "items", "ignored", false)
					else
						d["ignored"] = true
						CDTL2:SetSpellData(d["name"], "items", "ignored", true)
						
						CDTL2:SendToHolding(f)
						CDTL2:SendToBarHolding(f)
					end
				end
			end
			
			d["currentCD"] = d["currentCD"] - elapsed
			if d["currentCD"] >= 0 then
				if f.updateCount % 50 == 0 then
					local tinker, slot = CDTL2:CheckEngTinkerCases(d["name"])
					if tinker then
						local _, spellID = GetItemSpell(d["itemID"])
						if spellID == d["id"] then
							--local start, duration, enabled = CDTL2:GetInventoryItemCooldown("player", slot)
							--d["baseCD"] = duration
							--d["currentCD"] = start + duration - GetTime()

							local start, duration, enabled = CDTL2:GetInventoryItemCooldown("player", slot)
							if start and duration then
								d["baseCD"] = duration
								d["currentCD"] = start + duration - GetTime()
							end
						end
					else
						local start, duration, enabled = C_Container.GetItemCooldown(d["itemID"])
						if duration and start then
							d["baseCD"] = duration
							d["currentCD"] = start + duration - GetTime()
						end
					end
				end
			end
			
		-- AURAS
		elseif d["type"] == "buffs" or d["type"] == "debuffs" then
			if f.updateCount == 0 or f.updateCount % 50 == 0 then
				local s = CDTL2:AuraExists("player", d["name"])
				if s then
					d["currentCD"] = s["endTime"] - GetTime()
					d["stacks"] = s["stacks"]
				else
					d["currentCD"] = -1
				end
			else
				if d["currentCD"] >= 0 then
					d["currentCD"] = d["currentCD"] - elapsed
				end
			end
			
		-- OFFENSIVES
		elseif d["type"] == "offensives" then
			if f.updateCount == 0 or f.updateCount % 50 == 0 then
				if d["baseCD"] == 0 then
					local s = CDTL2:AuraExists("target", d["name"])
					if s then
						d["baseCD"] = s["bCD"] / 1000
						d["currentCD"] = s["endTime"] - GetTime()
						d["stacks"] = s["stacks"]
						
						CDTL2:SetSpellData(d["name"], "offensives", "bCD", s["bCD"])
						
						if d["baseCD"] > 3 and d["baseCD"] <= CDTL2.db.profile.global["offensives"]["ignoreThreshold"] then
							s["ignored"] = false
							CDTL2:SetSpellData(d["name"], "offensives", "ignored", false)
						else
							s["ignored"] = true
							CDTL2:SetSpellData(d["name"], "offensives", "ignored", true)
							
							CDTL2:SendToHolding(f)
							CDTL2:SendToBarHolding(f)
						end
					else
						
					end
				end
			else
				if d["currentCD"] >= 0 then
					d["currentCD"] = d["currentCD"] - elapsed
				end
			end
		
		-- CUSTOMS
		elseif d["type"] == "customs" then
			d["currentCD"] = d["currentCD"] - elapsed

		-- RUNES
		elseif d["type"] == "runes" then
			d["currentCD"] = d["currentCD"] - elapsed
		
		-- TEST/UTILITY
		elseif d["type"] == "testing" or d["type"] == "spacer" then
			d["currentCD"] = d["currentCD"] - elapsed
		end
		
		if icVisible then
			private.IconUpdate(f, elapsed)
		end
		
		if baVisible then
			private.BarUpdate(f, elapsed)
		end
	end
	
	f.updateCount = f.updateCount + 1
	
	if f.updateCount > 12000 then
		f.updateCount = 1
	end
	
	private.ShowHide(f)
end

private.IconUpdate = function(f, elapsed)
	local d = f.data
	local ic = f.icon
	ic.currentCD = d["currentCD"]
	ic.pinned = d["pinned"]
	
	local p = ic:GetParent():GetName()
	if p == "CDTL2_Lane_1" or p == "CDTL2_Lane_2" or p == "CDTL2_Lane_3" then
		if d["currentCD"] > 0 then
			local s = nil
			if d["lane"] == 1 then
				s = CDTL2.db.profile.lanes["lane1"]
			elseif d["lane"] == 2 then
				s = CDTL2.db.profile.lanes["lane2"]
			elseif d["lane"] == 3 then
				s = CDTL2.db.profile.lanes["lane3"]
			end
			
			local iconPercent = 1
			local mode = s["mode"]["type"]
			local max = nil
			local hideTimeSurplus = nil
			
			if mode == "LINEAR" then
				max = s["mode"]["linear"]["max"]
				hideTimeSurplus = s["mode"]["linear"]["hideTimeSurplus"]
				
				local baseCD = d["baseCD"]
				if d["baseCD"] > max then
					baseCD = max
				end
				
				iconPercent = private.CalcLinearPosition(d["currentCD"], baseCD, s)
			elseif mode == "LINEAR_ABS" then
				max = s["mode"]["linearAbs"]["max"]
				hideTimeSurplus = s["mode"]["linearAbs"]["hideTimeSurplus"]
				iconPercent = private.CalcLinearPosition(d["currentCD"], max, s)
			elseif mode == "SPLIT" then
				max = s["mode"]["split"]["max"]
				hideTimeSurplus = s["mode"]["split"]["hideTimeSurplus"]
				
				local baseCD = d["baseCD"]
				if d["baseCD"] > max then
					baseCD = max
				end
				
				iconPercent = private.CalcSplitPosition(d["currentCD"], baseCD, s)
			elseif mode == "SPLIT_ABS" then
				max = s["mode"]["splitAbs"]["max"]
				hideTimeSurplus = s["mode"]["splitAbs"]["hideTimeSurplus"]
				
				iconPercent = private.CalcSplitPosition(d["currentCD"], d["baseCD"], s)
			end
			
			if d["currentCD"] > max then
				if hideTimeSurplus == true then
					if ic.valid then
						ic.valid = false
						ic:GetParent().triggerUpdate = true
					end
				else
					if not ic.valid then
						ic.valid = true
						ic:GetParent().triggerUpdate = true
					end
				end
			else
				if not ic.valid then
					ic.valid = true
					ic:GetParent().triggerUpdate = true
				end
			end
			
			local iconPosition = (s["width"] - s["icons"]["size"]) * iconPercent
			
			local anchor = "LEFT"
			if s["vertical"] then
				if s["reversed"] then
					anchor = "TOP"
					iconPosition = -iconPosition
				else
					anchor = "BOTTOM"
				end
				
				ic:ClearAllPoints()
				ic:SetPoint(anchor, ic.yOffset + ic.sOffset, iconPosition)
			else
				if s["reversed"] then
					anchor = "RIGHT"
					iconPosition = -iconPosition
				end
				
				ic:ClearAllPoints()
				ic:SetPoint(anchor, iconPosition, ic.yOffset + ic.sOffset)
				ic:SetPoint(anchor, iconPosition, ic.yOffset + ic.sOffset)
			end
			
			if ic:GetAlpha() ~= 0 then
				if ic.txt then
					private.UpdateText(f, ic.txt.text1, s["icons"]["text1"], s["icons"]["text1"]["text"])
					private.UpdateText(f, ic.txt.text2, s["icons"]["text2"], s["icons"]["text2"]["text"])
					private.UpdateText(f, ic.txt.text3, s["icons"]["text3"], s["icons"]["text3"]["text"])
				end
			end
			
			if CDTL2.db.profile.global["enableTooltip"] then	
				if ic:IsMouseOver() then	
					if d.link then	
						GameTooltip_SetDefaultAnchor(GameTooltip, ic)	
						GameTooltip:SetHyperlink(d.link)
						GameTooltip:Show()	
					end	
				else	
					if GameTooltip:IsOwned(ic) then	
						GameTooltip:Hide()	
					end	
				end	
			end	
			
			if s["stacking"]["raiseOnMouseOver"] then	
				if ic:IsMouseOver() then	
					ic:SetFrameStrata("HIGH")	
				else
					ic:SetFrameStrata("MEDIUM")	
				end	
			end
		else
			if d["type"] == "spacer" then
				
			elseif d["type"] == "test" then
				
			else
				CDTL2:SendToReady(f)
			end
		end
	elseif p == "CDTL2_Ready_1_MF" or p == "CDTL2_Ready_2_MF" or p == "CDTL2_Ready_3_MF" then
		if ic.readyTime > 0 then
			if not f.data["pinned"] then
				ic.readyTime = ic.readyTime - elapsed
			end
			
			if CDTL2.db.profile.global["enableTooltip"] then	
				if ic:IsMouseOver() then	
					if d.link then	
						GameTooltip_SetDefaultAnchor(GameTooltip, ic)	
						GameTooltip:SetHyperlink(d.link)	
						GameTooltip:Show()	
					end	
				else	
					if GameTooltip:IsOwned(ic) then	
						GameTooltip:Hide()	
					end	
				end
			end
		else
			if d["type"] == "testing" then
				if CDTL2.db.profile.global["testingLoop"] then
					CDTL2:SendToLane(f)
					CDTL2:SendToBarFrame(f)
				else
					CDTL2:SendToHolding(f)
				end
			else
				CDTL2:SendToHolding(f)
			end
		end
	else
		-- Do Nothing
	end
	
	if CDTL2.db.profile.global["notUsableTint"] then
		if f.data["type"] == "spells" or f.data["type"] == "petspells" then
			local usable, noPower = CDTL2:IsUsableSpell(f.data["id"])
			if noPower then
				if CDTL2.db.profile.global["notUsableDesaturate"] then
					ic.tx:SetDesaturated(1)
				else
					ic.tx:SetDesaturated(nil)
					ic.tx:SetVertexColor(
						CDTL2.db.profile.global["notUsableColor"]["r"],
						CDTL2.db.profile.global["notUsableColor"]["g"],
						CDTL2.db.profile.global["notUsableColor"]["b"],
						CDTL2.db.profile.global["notUsableColor"]["a"]
					)
				end
			else
				ic.tx:SetDesaturated(nil)
				ic.tx:SetVertexColor(1, 1, 1, 1)
			end
		end
	end
end

function CDTL2:SendToBarFrame(f)
	local ba = f.bar
	
	if f.data["barFrame"] == 1 then
		if CDTL2_BarFrame_1_MF then
			ba:GetParent().triggerUpdate = true
			ba:SetParent(CDTL2_BarFrame_1_MF)
			CDTL2_BarFrame_1_MF.triggerUpdate = true		
		else
			CDTL2:SendToBarHolding(f)
		end
	elseif f.data["barFrame"] == 2 then
		if CDTL2_BarFrame_2_MF then
			ba:GetParent().triggerUpdate = true
			ba:SetParent(CDTL2_BarFrame_2_MF)
			CDTL2_BarFrame_2_MF.triggerUpdate = true
		else
			CDTL2:SendToBarHolding(f)
		end
	elseif f.data["barFrame"] == 3 then
		if CDTL2_BarFrame_3_MF then
			ba:GetParent().triggerUpdate = true
			ba:SetParent(CDTL2_BarFrame_3_MF)
			CDTL2_BarFrame_3_MF.triggerUpdate = true
		else
			CDTL2:SendToBarHolding(f)
		end
	else
		CDTL2:SendToBarHolding(f)
	end
	
	CDTL2:RefreshBar(f)
end

function CDTL2:SendToBarHolding(f)
	local ba = f.bar
	
	if f.data["type"] == "offensives" then
		ba:GetParent().triggerUpdate = true
		ba:SetParent(CDTL2_Offensive_Bar_Holding)
	else
		ba:GetParent().triggerUpdate = true
		ba:SetParent(CDTL2_Bar_Holding)
	end
	
	CDTL2:RefreshBar(f)
end

function CDTL2:SendToHolding(f)	
	local ic = f.icon
	
	if f.data["type"] == "offensives" then
		ic:GetParent().triggerUpdate = true
		ic:SetParent(CDTL2_Offensive_Icon_Holding)
		f.data["overrideCD"] = false
	else
		ic:GetParent().triggerUpdate = true
		ic:SetParent(CDTL2_Active_Icon_Holding)
		f.data["overrideCD"] = false
		--ic:Hide()
	end
	
	if GameTooltip:IsOwned(ic) then	
		GameTooltip:Hide()	
	end
	
	CDTL2:RefreshIcon(f)
end

function CDTL2:SendToLane(f)
	local ic = f.icon
	
	if f.data["lane"] == 1 then
		if CDTL2_Lane_1 then
			ic:GetParent().triggerUpdate = true
			ic:SetParent(CDTL2_Lane_1)
			CDTL2_Lane_1.triggerUpdate = true
		else
			CDTL2:SendToHolding(f)
		end
	elseif f.data["lane"] == 2 then
		if CDTL2_Lane_2 then
			ic:GetParent().triggerUpdate = true
			ic:SetParent(CDTL2_Lane_2)
			CDTL2_Lane_2.triggerUpdate = true
		else
			CDTL2:SendToHolding(f)
		end
	elseif f.data["lane"] == 3 then
		if CDTL2_Lane_3 then
			ic:GetParent().triggerUpdate = true
			ic:SetParent(CDTL2_Lane_3)
			CDTL2_Lane_3.triggerUpdate = true
		else
			CDTL2:SendToHolding(f)
		end
	else
		CDTL2:SendToHolding(f)
	end
	
	CDTL2:RefreshIcon(f)
	
	f.data["updateCount"] = 0
	f.data["currentCD"] = f.data["baseCD"]
end

function CDTL2:SendToReady(f)
	local ic = f.icon
	local s = nil
	
	if f.data["readyFrame"] == 1 then
		if CDTL2_Ready_1_MF then
			ic:GetParent().triggerUpdate = true
			ic:SetParent(CDTL2_Ready_1_MF)
			s = CDTL2.db.profile.ready["ready1"]
			ic.readyTime = s["nTime"]
			
			if f.data["highlight"] then
				if s["hSound"] ~= "None" then
					PlaySoundFile(CDTL2.LSM:Fetch("sound", s["hSound"]), "SFX")
				end
			else
				if s["nSound"] ~= "None" then
					PlaySoundFile(CDTL2.LSM:Fetch("sound", s["nSound"]), "SFX")
				end
			end
			
			CDTL2_Ready_1.combatTimer = 0
			CDTL2_Ready_1_MF.triggerUpdate = true
			f.data["overrideCD"] = false
		else
			CDTL2:SendToHolding(f)
		end		
	elseif f.data["readyFrame"] == 2 then
		if CDTL2_Ready_2_MF then
			ic:GetParent().triggerUpdate = true
			ic:SetParent(CDTL2_Ready_2_MF)
			s = CDTL2.db.profile.ready["ready2"]
			ic.readyTime = s["nTime"]
			
			if f.data["highlight"] then
				if s["hSound"] ~= "None" then
					PlaySoundFile(CDTL2.LSM:Fetch("sound", s["hSound"]), "SFX")
				end
			else
				if s["nSound"] ~= "None" then
					PlaySoundFile(CDTL2.LSM:Fetch("sound", s["nSound"]), "SFX")
				end
			end
			
			CDTL2_Ready_2.combatTimer = 0
			CDTL2_Ready_2_MF.triggerUpdate = true
			f.data["overrideCD"] = false
		else
			CDTL2:SendToHolding(f)
		end
	elseif f.data["readyFrame"] == 3 then
		if CDTL2_Ready_3_MF then
			ic:GetParent().triggerUpdate = true
			ic:SetParent(CDTL2_Ready_3_MF)
			s = CDTL2.db.profile.ready["ready3"]
			ic.readyTime = s["nTime"]
			
			if f.data["highlight"] then
				if s["hSound"] ~= "None" then
					PlaySoundFile(CDTL2.LSM:Fetch("sound", s["hSound"]), "SFX")
				end
			else
				if s["nSound"] ~= "None" then
					PlaySoundFile(CDTL2.LSM:Fetch("sound", s["nSound"]), "SFX")
				end
			end
			
			CDTL2_Ready_3.combatTimer = 0
			CDTL2_Ready_3_MF.triggerUpdate = true
			f.data["overrideCD"] = false
		else
			CDTL2:SendToHolding(f)
		end
	else
		CDTL2:SendToHolding(f)
	end
	
	CDTL2:RefreshIcon(f)
end

private.ShowHide = function(f)
	if f.data["ignored"] then
		f.icon.valid = false
		f.bar.valid = false

		if CDTL2.db.profile.global["debugMode"] then
			f.bar:SetAlpha(0.35)
			f.icon:SetAlpha(0.35)
		else
			f.bar:SetAlpha(0)
			f.icon:SetAlpha(0)
		end
	else
		if f.data["enabled"] then
			-- ICONS
			if f.icon.valid then
				f.icon:SetAlpha(1)
			else
				if CDTL2.db.profile.global["debugMode"] then
					f.icon:SetAlpha(0.35)
				else
					f.icon:SetAlpha(0)
				end
			end
			-- BARS
			if f.bar.valid then
				f.bar:SetAlpha(1)
			else
				if CDTL2.db.profile.global["debugMode"] then
					f.bar:SetAlpha(0.35)
				else
					f.bar:SetAlpha(0)
				end
			end
		else
			f.icon.valid = false
			f.bar.valid = false
			
			if CDTL2.db.profile.global["debugMode"] then
				f.bar:SetAlpha(0.35)
				f.icon:SetAlpha(0.35)
			else
				f.bar:SetAlpha(0)
				f.icon:SetAlpha(0)
			end
		end
	end
end

private.UpdateText = function(f, tf, s, iString)
	if s["enabled"] then
		if s["dtags"] then
			if f.updateCount % private.dynamicTextPollRate == 0 then
				tf:SetText(CDTL2:ConvertTextDynamicTags(s["text"], f))
			end
		end
		
		if s["ttags"] then
			if f.data["currentCD"] <= 10 then
				if f.updateCount % private.timeTextPollRate == 0 then
					tf:SetText(CDTL2:ConvertTextTimeTags(s["text"], f))
				end
			else
				if f.updateCount % (private.timeTextPollRate * 3) == 0 then
					tf:SetText(CDTL2:ConvertTextTimeTags(s["text"], f))
				end
			end
		end
	end
end