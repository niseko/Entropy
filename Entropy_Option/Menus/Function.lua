
local Entropy = Entropy
local Option = Entropy.optionFrame
local LBO = LibStub("LibLimeOption-1.0")

local pairs = _G.pairs

function Option:CreateAggroMenu(menu, parent)
	menu.arrow = LBO:CreateWidget("CheckBox", parent, "View threat arrows", "Shows a red arrow to the left of the name of the player who has acquired the threat.", nil, nil, true,
		function()
			return Entropy.db.units.useAggroArrow
		end,
		function(v)
			Entropy.db.units.useAggroArrow = v
			Entropy:updateAll()
		end
	)
	menu.arrow:SetPoint("TOPLEFT", 5, 5)
end

function Option:CreateOutlineMenu(menu, parent)
	local outlineList = { "Disable", "Dispelable debuff", "Target", "Mouseover","Low Health (percent)", "Threat", "Role Icon", "Low Health (number)" }
	menu.use = LBO:CreateWidget("DropDown", parent, "Outline: How it works", "Set the outline.", nil, nil, true,
		function()
			return Entropy.db.units.outline.type + 1, outlineList
		end,
		function(v)
			Entropy.db.units.outline.type = v - 1
			Entropy:updateAll()
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function disable()
		return Entropy.db.units.outline.type == 0
	end
	menu.scale = LBO:CreateWidget("Slider", parent, "Outline: size", "Sets the size of the outline.", nil, disable, true,
		function() return Entropy.db.units.outline.scale * 100, 50, 150, 1, "%" end,
		function(v)
			Entropy.db.units.outline.scale = v / 100
			Entropy:updateAll()
		end
	)
	menu.scale:SetPoint("TOP", menu.use, "BOTTOM", 0, -10)
	menu.alpha = LBO:CreateWidget("Slider", parent, "Outline: transparency", "Sets the transparency of the outline.", nil, disable, true,
		function() return Entropy.db.units.outline.alpha * 100, 10, 100, 1, "%" end,
		function(v)
			Entropy.db.units.outline.alpha = v / 100
			Entropy:updateAll()
		end
	)
	menu.alpha:SetPoint("TOP", menu.scale, "TOP", 0, 0)
	menu.alpha:SetPoint("RIGHT", -5, 0)
	local function getColor(key)
		return Entropy.db.units.outline[key][1], Entropy.db.units.outline[key][2], Entropy.db.units.outline[key][3]
	end
	local function setColor(r, g, b, key)
		Entropy.db.units.outline[key][1], Entropy.db.units.outline[key][2], Entropy.db.units.outline[key][3] = r, g, b
		Entropy:updateAll()
	end
	menu.targetColor = LBO:CreateWidget("ColorPicker", parent, "Outline color", "Sets the outline color when a target is selected.", function() return Entropy.db.units.outline.type ~= 2 end, nil, true, getColor, setColor, "targetColor")
	menu.targetColor:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	menu.mouseoverColor = LBO:CreateWidget("ColorPicker", parent, "Outline color", "Sets the outline color when the mouse is over the target.", function() return Entropy.db.units.outline.type ~= 3 end, nil, true, getColor, setColor, "mouseoverColor")
	menu.mouseoverColor:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	menu.aggroColor = LBO:CreateWidget("ColorPicker", parent, "Outline color", "Sets the color of the outline of the target that acquired the threat.", function() return Entropy.db.units.outline.type ~= 5 end, nil, true, getColor, setColor, "aggroColor")
	menu.aggroColor:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	local function isLowHealth()
		return Entropy.db.units.outline.type ~= 4
	end
	menu.lowHealthColor = LBO:CreateWidget("ColorPicker", parent, "Outline color", "Sets the outline color of a low-health target.", isLowHealth, nil, true, getColor, setColor, "lowHealthColor")
	menu.lowHealthColor:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	menu.lowHealth = LBO:CreateWidget("Slider", parent, "Health Warning: amount","Shows the outline when the health falls below the specified percentage.", isLowHealth, nil, true,
		function() return Entropy.db.units.outline.lowHealth * 100, 1, 99, 1, "%" end,
		function(v)
			Entropy.db.units.outline.lowHealth = v / 100
			Entropy:updateAll()
		end
	)
	menu.lowHealth:SetPoint("TOP", menu.alpha, "BOTTOM", 0, -10)
	local function isRaidIcon()
		return Entropy.db.units.outline.type ~= 6
	end
	menu.raidIconColor = LBO:CreateWidget("ColorPicker", parent, "Outline color", "Sets the outline color of the target with the specified target marker icon.", isRaidIcon, nil, true, getColor, setColor, "raidIconColor")
	menu.raidIconColor:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	local function getRaidIcon(icon)
		return Entropy.db.units.outline.raidIcon[icon]
	end
	local function setRaidIcon(v, icon)
		Entropy.db.units.outline.raidIcon[icon] = v
		Entropy:updateAll()
	end
	for i, text in ipairs(Option.dropdownTable["Marks"]) do
		menu["raidIcon"..i] = LBO:CreateWidget("CheckBox", parent, text, text.." - Displays an outline.", isRaidIcon, nil, true, getRaidIcon, setRaidIcon, i)
		if i == 1 then
			menu["raidIcon"..i]:SetPoint("TOP", menu.raidIconColor, "BOTTOM", 0, 0)
		elseif i == 2 then
			menu["raidIcon"..i]:SetPoint("TOP", menu.raidIcon1, 0, 0)
			menu["raidIcon"..i]:SetPoint("RIGHT", -5, 0)
		else
			menu["raidIcon"..i]:SetPoint("TOP", menu["raidIcon"..(i - 2)], "BOTTOM", 0, 14)
		end
	end
	local function isLowHealth2()
		return Entropy.db.units.outline.type ~= 7
	end
	menu.lowHealthColor2 = LBO:CreateWidget("ColorPicker", parent, "Outline color", "Sets the outline color of a low-health target", isLowHealth2, nil, true, getColor, setColor, "lowHealthColor2")
	menu.lowHealthColor2:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	menu.lowHealth2 = LBO:CreateWidget("Slider", parent, "Health Warning: amount", "Shows the outline when the health falls below the specified health amount.", isLowHealth2, nil, true,
		function() return Entropy.db.units.outline.lowHealth2, 1, 5000000, 1, "" end,
		function(v)
			Entropy.db.units.outline.lowHealth2 = v
			Entropy:updateAll()
		end
	)
	menu.lowHealth2:SetPoint("TOP", menu.alpha, "BOTTOM", 0, -10)
end

function Option:CreateRangeMenu(menu, parent)
	menu.outrange = LBO:CreateWidget("Slider", parent, "Transparency", "Adjusts the health bar transparency of players who are out of range.", nil, nil, true,
		function()
			return Entropy.db.units.fadeOutAlpha * 100, 0, 100, 1, "%"
		end,
		function(v)
			Entropy.db.units.fadeOutAlpha = v / 100
			Entropy:updateAll()
		end
	)
	menu.outrange:SetPoint("TOPLEFT", 5, -10)
	menu.fadeOutColorFlag = LBO:CreateWidget("CheckBox", parent, "Change Color", "Allows you to change the health bar color of members who are out of range.", nil, nil, true,
		function()
			return Entropy.db.units.fadeOutColorFlag
		end,
		function(v)
			Entropy.db.units.fadeOutColorFlag = v
			Entropy:updateAll()
		end
	)
	menu.fadeOutColorFlag:SetPoint("TOP", menu.outrange, "BOTTOM", 0, 0)

	menu.fadeOutColor = LBO:CreateWidget("ColorPicker", parent, "Color", "Change the health bar color of members who are out of range.", nil, nil, true,
		function()
			return Entropy.db.units.fadeOutColor[1], Entropy.db.units.fadeOutColor[2], Entropy.db.units.fadeOutColor[3]
		end,
		function(r, g, b)
			Entropy.db.units.fadeOutColor[1], Entropy.db.units.fadeOutColor[2], Entropy.db.units.fadeOutColor[3] = r, g, b
			Entropy:updateAll()
		end
	)
	menu.fadeOutColor:SetPoint("TOP", menu.fadeOutColorFlag, "BOTTOM", 0, 0)
end

function Option:CreateSurvivalSkillMenu(menu, parent)
	--local function update(member)
	--	if member:IsVisible() then
	--		limeMember_UpdateSurvivalSkill(member)
	--		limeMember_UpdateDisplayText(member)
	--	end
	--end
	menu.use = LBO:CreateWidget("CheckBox", parent, "Show survival skills", "Displays the survival skills cast by the player.", nil, nil, true,
		function()
			return Entropy.db.units.useSurvivalSkill
		end,
		function(v)
			Entropy.db.units.useSurvivalSkill = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 0)
	menu.timer = LBO:CreateWidget("CheckBox", parent, "See remaining time","An additional indication of the remaining time of the survival skill cast by the player.", nil, function() return not Entropy.db.units.useSurvivalSkill end, true,
		function()
			return Entropy.db.units.showSurvivalSkillTimer
		end,
		function(v)
			Entropy.db.units.showSurvivalSkillTimer = v
			Entropy:updateAll()
		end
	)
	menu.timer:SetPoint("TOPRIGHT", -5, 0)
	menu.sub = LBO:CreateWidget("CheckBox", parent, "Show unimportant survival skills", "Also show survival skills with low cooldown time.", nil, function() return not Entropy.db.units.useSurvivalSkill end, true,
		function()
			return Entropy.db.units.showSurvivalSkillSub
		end,
		function(v)
			Entropy.db.units.showSurvivalSkillSub = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.sub:SetPoint("TOP", menu.use, "BOTTOM", 0, 5)
end

function Option:CreateHealPredictionMenu(menu, parent)
--		member.myHealPredictionBar:SetStatusBarColor(Entropy.db.units.myHealPredictionColor[1], Entropy.db.units.myHealPredictionColor[2], Entropy.db.units.myHealPredictionColor[3], Entropy.db.units.healPredictionAlpha)
--		member.otherHealPredictionBar:SetStatusBarColor(Entropy.db.units.otherHealPredictionColor[1], Entropy.db.units.otherHealPredictionColor[2], Entropy.db.units.otherHealPredictionColor[3], Entropy.db.units.healPredictionAlpha)
--		member.absorbPredictionBar:SetStatusBarColor(Entropy.db.units.AbsorbPredictionColor[1], Entropy.db.units.AbsorbPredictionColor[2], Entropy.db.units.AbsorbPredictionColor[3], Entropy.db.units.healPredictionAlpha)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Enable", "Sets whether to use the incoming healing and absorbing features.", nil, nil, true,
		function()
			return Entropy.db.units.displayHealPrediction
		end,
		function(v)
			Entropy.db.units.displayHealPrediction = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function disable()
		return not Entropy.db.units.displayHealPrediction
	end
	menu.myHealPrediction = LBO:CreateWidget("CheckBox", parent, "Hide myHealPrediction", "", nil, disable, true,
	function()
		return Entropy.db.units.hidemyHealPrediction
	end,
	function(v)
		Entropy.db.units.hidemyHealPrediction = v
		LBO:Refresh(parent)
		Entropy:updateAll()
	end
)
menu.myHealPrediction:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)
menu.myHealAbsorb = LBO:CreateWidget("CheckBox", parent, "Hide myHealAbsorb", "", nil, disable, true,
		function()
			return Entropy.db.units.hidemyHealAbsorb
		end,
		function(v)
			Entropy.db.units.hidemyHealAbsorb = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.myHealAbsorb:SetPoint("TOP", menu.myHealPrediction, "BOTTOM", 0, 0)
	menu.otherHealPrediction = LBO:CreateWidget("CheckBox", parent, "Hide otherHealPrediction", "", nil, disable, true,
		function()
			return Entropy.db.units.hideotherHealPrediction
		end,
		function(v)
			Entropy.db.units.hideotherHealPrediction = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.otherHealPrediction:SetPoint("TOP", menu.myHealAbsorb, "BOTTOM", 0, 0)
	menu.totalAbsorb = LBO:CreateWidget("CheckBox", parent, "Hide totalAbsorb", "", nil, disable, true,
		function()
			return Entropy.db.units.hidetotalAbsorb
		end,
		function(v)
			Entropy.db.units.hidetotalAbsorb = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.totalAbsorb:SetPoint("TOP", menu.otherHealPrediction, "BOTTOM", 0, 0)
	menu.overAbsorbGlow = LBO:CreateWidget("CheckBox", parent, "Hide overAbsorbGlow", "", nil, disable, true,
		function()
			return Entropy.db.units.hideoverAbsorbGlow
		end,
		function(v)
			Entropy.db.units.hideoverAbsorbGlow = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.overAbsorbGlow:SetPoint("TOP", menu.totalAbsorb, "BOTTOM", 0, 0)
	menu.overHealAbsorbGlow = LBO:CreateWidget("CheckBox", parent, "Hide overHealAbsorbGlow", "", nil, disable, true,
		function()
			return Entropy.db.units.hideoverHealAbsorbGlow
		end,
		function(v)
			Entropy.db.units.hideoverHealAbsorbGlow = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.overHealAbsorbGlow:SetPoint("TOP", menu.overAbsorbGlow, "BOTTOM", 0, 0)


	menu.alpha = LBO:CreateWidget("Slider", parent, "Transparency", "Sets the transparency of the bar that displays incoming healing to incoming players.", nil, true, true,
		function() return Entropy.db.units.healPredictionAlpha * 100, 0, 100, 1, "%" end,
		function(v)
			Entropy.db.units.healPredictionAlpha = v / 100
			Entropy:updateAll()
		end
	)
	menu.alpha:SetPoint("TOPRIGHT", -25, -15)
	menu.myColor = LBO:CreateWidget("ColorPicker", parent, "Players Healing color", "Set the color of your healing bar or icon.", nil, true, true,
		function() return Entropy.db.units.myHealPredictionColor[1], Entropy.db.units.myHealPredictionColor[2], Entropy.db.units.myHealPredictionColor[3] end,
		function(r, g, b)
			Entropy.db.units.myHealPredictionColor[1], Entropy.db.units.myHealPredictionColor[2], Entropy.db.units.myHealPredictionColor[3] = r, g, b
			Entropy:updateAll()
		end
	)
	menu.myColor:SetPoint("TOP", menu.alpha, "BOTTOM", 0, 0)
	menu.otherColor = LBO:CreateWidget("ColorPicker", parent, "Others Healing color","Sets the color of the healing bar or icon cast by someone else.", nil, true, true,
		function() return Entropy.db.units.otherHealPredictionColor[1], Entropy.db.units.otherHealPredictionColor[2], Entropy.db.units.otherHealPredictionColor[3] end,
		function(r, g, b)
			Entropy.db.units.otherHealPredictionColor[1], Entropy.db.units.otherHealPredictionColor[2], Entropy.db.units.otherHealPredictionColor[3] = r, g, b
			Entropy:updateAll()
		end
	)
	menu.otherColor:SetPoint("TOP", menu.myColor, "BOTTOM", 0, 0)
	menu.AbsorbColor = LBO:CreateWidget("ColorPicker", parent, "Expected absorbed bar color", "Sets the color of the expected absorption bar.", nil, true, true,
		function() return Entropy.db.units.absorbPredictionColor[1], Entropy.db.units.absorbPredictionColor[2], Entropy.db.units.absorbPredictionColor[3] end,
		function(r, g, b)
			Entropy.db.units.absorbPredictionColor[1], Entropy.db.units.absorbPredictionColor[2], Entropy.db.units.absorbPredictionColor[3] = r, g, b
			Entropy:updateAll()
		end
	)
	menu.AbsorbColor:SetPoint("TOP", menu.otherColor, "BOTTOM", 0, 0)
end
local AuraHighlight_Aura = {
	["outline"] = "OUTLINE",
	["fontSize"] = 12,
	["color"] = {
		1, -- [1]
		1, -- [2]
		1, -- [3]
		1, -- [4]
	},
	["displayText"] = " ",
	["yOffset"] = 0,
	["regionType"] = "text",
	["animation"] = {
		["start"] = {
			["duration_type"] = "seconds",
			["type"] = "none",
		},
		["main"] = {
			["duration_type"] = "seconds",
			["type"] = "none",
		},
		["finish"] = {
			["duration_type"] = "seconds",
			["type"] = "none",
		},
	},
	["anchorPoint"] = "CENTER",
	["customTextUpdate"] = "update",
	["automaticWidth"] = "Auto",
	["actions"] = {
		["start"] = {
			["do_custom"] = true,
			["custom"] = "local frame = aura_env.GetFrame(aura_env.state.unit)\nif frame then\n    aura_env.Highlight(frame, true)\nend",
		},
		["finish"] = {
			["do_custom"] = true,
			["custom"] = "local frame = aura_env.GetFrame(aura_env.state.unit)\nif frame then\n    aura_env.Highlight(frame, false)\nend",
		},
		["init"] = {
			["do_custom"] = true,
			["custom"] = "if select(4, GetAddOnInfo(\"LibGetFrame-1.0\")) then\n    aura_env.GetFrame = LibStub(\"LibGetFrame-1.0\").GetFrame\nelse\n    WeakAuras.prettyPrint((\"'%s' requires LibGetFrame-1.0 get it at https://www.curseforge.com/wow/addons/libgetframe\"):format(aura_env.id))\n    return\nend\n\naura_env.Highlight = function(frame,show)\n    if show then\n        frame.healthBar.colorOverride = true\n        CompactUnitFrame_UpdateHealthColor(frame)\n    else\n        frame.healthBar.colorOverride = false\n        CompactUnitFrame_UpdateHealthColor(frame)\n    end\nend",
		},
	},
	["triggers"] = {
		{
			["trigger"] = {
				["showClones"] = true,
				["useName"] = true,
				["auranames"] = { -- [1]
				},
				["combinePerUnit"] = true,
				["debuffType"] = "HELPFUL",
				["event"] = "Health",
				["unit"] = "group",
				["names"] = {
				},
				["auraspellids"] = { -- [2]
				},
				["spellIds"] = {
				},
				["subeventPrefix"] = "SPELL",
				["useExactSpellId"] = true,
				["subeventSuffix"] = "_CAST_START",
				["type"] = "aura2",
			},
			["untrigger"] = {
			},
		}, -- [1]
		{
			["trigger"] = {
				["showClones"] = true,
				["useName"] = true,
				["subeventSuffix"] = "_CAST_START",
				["event"] = "Health",
				["subeventPrefix"] = "SPELL",
				["auranames"] = { -- [1]
				},
				["auraspellids"] = { -- [2]
				},
				["unit"] = "group",
				["type"] = "aura2",
				["debuffType"] = "HARMFUL",
			},
			["untrigger"] = {
			},
		}, -- [2]
		["disjunctive"] = "any",
		["activeTriggerMode"] = -10,
	},
	["xOffset"] = 0,
	["internalVersion"] = 24,
	["justify"] = "LEFT",
	["selfPoint"] = "BOTTOM",
	["id"] = "!Entropy - Aura Highlight (Don't rename)",
	["font"] = "Friz Quadrata TT",
	["frameStrata"] = 1,
	["anchorFrameType"] = "SCREEN",
	["fixedWidth"] = 200,
	["config"] = {
	},
	["wordWrap"] = "WordWrap",
	["subRegions"] = {
	},
	["authorOptions"] = {
	},
	["conditions"] = {
	},
	["load"] = {
		["spec"] = {
			["multi"] = {
			},
		},
		["class"] = {
			["multi"] = {
			},
		},
		["size"] = {
			["multi"] = {
			},
		},
	},
	["uid"] = "",
}

local temporaryHighlightVar = {}
function Option:CreateHighlightAuraMenu(menu, parent)
	local auras = {}
	menu.list = LBO:CreateWidget("List", parent, "List of auras to highlight", nil, nil, nil, true,
		function()
			wipe(auras)
			local data = WeakAuras.GetData(AuraHighlight_Aura.id);
			if not data then
				-- error
			end
			for k,aura in pairs(data.triggers[1].trigger.auranames) do
				if aura and not auras[aura] then
					tinsert(auras, aura)
				end
			end
			local debuffs={}
			for k,aura in pairs(data.triggers[2].trigger.auranames) do
				if aura and not auras[aura] then
					tinsert(debuffs, aura)
				end
			end
			for k,v in pairs(debuffs) do auras[k] = v end
			sort(auras)
			temporaryHighlightVar = auras
			return auras, true
		end,
		function(v)
			menu.delete:Update()
		end
	)
	--menu.list:SetPoint("TOPLEFT", 5, -5)
	menu.delete = LBO:CreateWidget("Button", parent, "Remove", "Removes the selected aura from the list.", nil,
		function()
			if menu.list:GetValue() then
				menu.delete.title:SetFormattedText("Remove \"%s\"", auras[menu.list:GetValue()])
				return nil
			else
				menu.delete.title:SetText("Remove")
				return true
			end
		end, nil,
		function()
			local name = auras[menu.list:GetValue()]
			Entropy:Message(("\"%s\": Removed from list of auras to ignore."):format(name))
			for spellId in string.gmatch(name, "%d+") do
				name = tonumber(spellId)
			end
			if Entropy.ignoreAura[name] then
				Entropy.db.ignoreAura[name] = false
			else
				Entropy.db.ignoreAura[name] = nil
			end
			menu.list:Setup()
		end
	)
	--menu.delete:SetPoint("TOPLEFT", menu.list, "BOTTOMLEFT", 0, 12)
	--menu.delete:SetPoint("TOPRIGHT", menu.list, "BOTTOMRIGHT", 0, 12)
	menu.editbox = LBO:CreateEditBox(parent, nil, "ChatFontNormal", nil, true)
	--menu.editbox:SetPoint("TOPLEFT", menu.delete, "BOTTOMLEFT", 2, 6)
	--menu.editbox:SetPoint("TOPRIGHT", menu.delete, "BOTTOMRIGHT", -60, 6)
	menu.editbox:SetScript("OnTextChanged", function() menu.add:Update() end)
	menu.editbox:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)
	local function add()
		local text = (menu.editbox:GetText() or ""):trim()
		local spell
		if tonumber(text) then
			spell = tonumber(text)
			text = GetSpellInfo(text) or nil
		else
			spell = text
		end
		menu.editbox:SetText("")
		menu.editbox:ClearFocus()
		if not text then
			Entropy:Message(("%d does not exist."):format(spell))
		--elseif Entropy.db.ignoreAura[spell] or Entropy.db.ignoreAura[text] or (Entropy.ignoreAura[spell] and Entropy.db.ignoreAura[spell] ~= false) or (Entropy.ignoreAura[text] and Entropy.db.ignoreAura[text] ~= false) then
		--	Entropy:Message(("\"%s\" is already in the list of effects to ignore."):format(text))
		else
			Entropy:Message(("\"%s\" has been added to the list of effects to highlight."):format(text))
			--if Entropy.ignoreAura[spell] then
			--	Entropy.db.ignoreAura[spell] = nil
			--else
			--	Entropy.db.ignoreAura[spell] = true
			--end
			tinsert(temporaryHighlightVar, text)
			AuraHighlight_Aura.triggers[1].trigger.auranames = temporaryHighlightVar
			AuraHighlight_Aura.triggers[2].trigger.auranames = temporaryHighlightVar


			local diff = WeakAuras.diff(WeakAuras.GetData(AuraHighlight_Aura.id), AuraHighlight_Aura)
			WeakAuras.Update(WeakAuras.GetData(AuraHighlight_Aura.id), diff)
			menu.list:Setup()
			menu.delete:Update()
		end
	end
	menu.editbox:SetScript("OnEnterPressed", function(self)
		if (self:GetText() or ""):trim() ~= "" then
			add()
		else
			self:SetText("")
			self:ClearFocus()
		end
	end)
	menu.add = LBO:CreateWidget("Button", parent, "Add", "Add effects to the list.", nil, function() return (menu.editbox:GetText() or ""):trim() == "" end, true, add)
	--menu.add:SetPoint("TOPLEFT", menu.editbox, "TOPRIGHT", 2, 14)
	--menu.add:SetPoint("RIGHT", menu.delete, "RIGHT", 0, 0)
--[[menu.reset = LBO:CreateWidget("Button", parent, "Reset", "Restores the list of effects to be ignored to the default value.", nil, function() return not next(Entropy.db.ignoreAura) end, true,
		function()
			menu.editbox:SetText("")
			menu.editbox:ClearFocus()
			wipe(Entropy.db.ignoreAura)
			menu.list:Setup()
			menu.reset:Update()
			menu.delete:Update()
			Entropy:Message("A list of effects to ignore has been restored to the default value.")
		end
	)
	menu.reset:SetPoint("TOP", menu.add, "BOTTOM", 0, 18)
	menu.reset:SetPoint("LEFT", menu.delete, "LEFT", 0, 0)
	menu.reset:SetPoint("RIGHT", menu.delete, "RIGHT", 0, 0)]]--

	menu.import =
	LBO:CreateWidget(
	"Button",
	parent,
	"Import WA",
	"Required for Highlighting to work.",
	nil,
	nil,
	true,
	function()
		--> check if wa is installed
		if (not WeakAuras or not WeakAurasSaved) then
			return
		end

		if not WeakAurasSaved.displays[AuraHighlight_Aura.id] then
			WeakAuras.Add(AuraHighlight_Aura)
		end

	--local data = WeakAuras.GetData(AuraHighlight_Aura.id);
	--if(data) then
	--	print (data.triggers[1].trigger.auranames)
	--end

		--> check if the options panel has loaded
		local options_frame = WeakAuras.OptionsFrame and WeakAuras.OptionsFrame()
		if (options_frame) then
			WeakAuras.NewDisplayButton(AuraHighlight_Aura)
			if (options_frame and not options_frame:IsShown()) then
				WeakAuras.ToggleOptions()
			end
		end
		LBO:Refresh(parent)
	end)
	menu.import:SetPoint("CENTER", 0, -20)
	menu.highlightColor = LBO:CreateWidget(
		"ColorPicker",
		parent,
		"highlight color",
		"Sets the highlight color.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.colors.highlight[1], Entropy.db.colors.highlight[2], Entropy.db.colors.highlight[3]
		end,
		function(r, g, b)
			Entropy.db.colors.highlight[1], Entropy.db.colors.highlight[2], Entropy.db.colors.highlight[3] = r, g, b
			Entropy:updateAll()
	end)
	menu.highlightColor:SetPoint("TOP", menu.import, "BOTTOM", 0, 0)
end

function Option:CreateIgnoreAuraMenu(menu, parent)
	local auras = {}
	menu.list = LBO:CreateWidget("List", parent, "List of auras to ignore", nil, nil, nil, true,
		function()
			wipe(auras)
			for debuff in pairs(Entropy.ignoreAura) do
				if Entropy.db.ignoreAura[debuff] ~= false then
					local text
						if type(debuff) == "number" then
							text = ("%s (%d)"):format(GetSpellInfo(debuff) or "", debuff)
						else
							text = debuff
						end
						tinsert(auras, text)
				end
			end
			for debuff, v in pairs(Entropy.db.ignoreAura) do
				if v == true then
					if Entropy.ignoreAura[debuff] then
						Entropy.db.ignoreAura[debuff] = nil
					else
						local text
						if type(debuff) == "number" then
							text = ("%s (%d)"):format(GetSpellInfo(debuff) or "", debuff)
						else
							text = debuff
						end
						tinsert(auras, text)
					end
				end
			end
			sort(auras)
			return auras, true
		end,
		function(v)
			menu.delete:Update()
		end
	)
	menu.list:SetPoint("TOPLEFT", 5, -5)
	menu.delete = LBO:CreateWidget("Button", parent, "Remove", "Removes the selected aura from the list.", nil,
		function()
			if menu.list:GetValue() then
				menu.delete.title:SetFormattedText("Remove \"%s\"", auras[menu.list:GetValue()])
				return nil
			else
				menu.delete.title:SetText("Remove")
				return true
			end
		end, nil,
		function()
			local name = auras[menu.list:GetValue()]
			Entropy:Message(("\"%s\": Removed from list of auras to ignore."):format(name))
			for spellId in string.gmatch(name, "%d+") do
				name = tonumber(spellId)
			end
			if Entropy.ignoreAura[name] then
				Entropy.db.ignoreAura[name] = false
			else
				Entropy.db.ignoreAura[name] = nil
			end
			menu.list:Setup()
		end
	)
	menu.delete:SetPoint("TOPLEFT", menu.list, "BOTTOMLEFT", 0, 12)
	menu.delete:SetPoint("TOPRIGHT", menu.list, "BOTTOMRIGHT", 0, 12)
	menu.editbox = LBO:CreateEditBox(parent, nil, "ChatFontNormal", nil, true)
	menu.editbox:SetPoint("TOPLEFT", menu.delete, "BOTTOMLEFT", 2, 6)
	menu.editbox:SetPoint("TOPRIGHT", menu.delete, "BOTTOMRIGHT", -60, 6)
	menu.editbox:SetScript("OnTextChanged", function() menu.add:Update() end)
	menu.editbox:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)
	local function add()
		local text = (menu.editbox:GetText() or ""):trim()
		local spell
		if tonumber(text) then
			spell = tonumber(text)
			text = GetSpellInfo(text) or nil
		else
			spell = text
		end
		menu.editbox:SetText("")
		menu.editbox:ClearFocus()
		if not text then
			Entropy:Message(("%d does not exist."):format(spell))
		elseif Entropy.db.ignoreAura[spell] or Entropy.db.ignoreAura[text] or (Entropy.ignoreAura[spell] and Entropy.db.ignoreAura[spell] ~= false) or (Entropy.ignoreAura[text] and Entropy.db.ignoreAura[text] ~= false) then
			Entropy:Message(("\"%s\" is already in the list of effects to ignore."):format(text))
		else
			Entropy:Message(("\"%s\" has been added to the list of effects to ignore."):format(text))
			if Entropy.ignoreAura[spell] then
				Entropy.db.ignoreAura[spell] = nil
			else
				Entropy.db.ignoreAura[spell] = true
			end
			menu.list:Setup()
			menu.delete:Update()
		end
	end
	menu.editbox:SetScript("OnEnterPressed", function(self)
		if (self:GetText() or ""):trim() ~= "" then
			add()
		else
			self:SetText("")
			self:ClearFocus()
		end
	end)
	menu.add = LBO:CreateWidget("Button", parent, "Add", "Add effects to the list.", nil, function() return (menu.editbox:GetText() or ""):trim() == "" end, true, add)
	menu.add:SetPoint("TOPLEFT", menu.editbox, "TOPRIGHT", 2, 14)
	menu.add:SetPoint("RIGHT", menu.delete, "RIGHT", 0, 0)
--[[menu.reset = LBO:CreateWidget("Button", parent, "Reset", "Restores the list of effects to be ignored to the default value.", nil, function() return not next(Entropy.db.ignoreAura) end, true,
		function()
			menu.editbox:SetText("")
			menu.editbox:ClearFocus()
			wipe(Entropy.db.ignoreAura)
			menu.list:Setup()
			menu.reset:Update()
			menu.delete:Update()
			Entropy:Message("A list of effects to ignore has been restored to the default value.")
		end
	)
	menu.reset:SetPoint("TOP", menu.add, "BOTTOM", 0, 18)
	menu.reset:SetPoint("LEFT", menu.delete, "LEFT", 0, 0)
	menu.reset:SetPoint("RIGHT", menu.delete, "RIGHT", 0, 0)]]--
end
--[[
function Option:CreateDebuffIconMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateAura(member)
		end
	end
	menu.num = LBO:CreateWidget("Slider", parent, L["lime_func_aura_14"], L["lime_func_aura_15"], nil, disable, true,
		function()
			return Entropy.db.units.debuffIcon, 0, 5, 1, ""
		end,
		function(v)
			Entropy.db.units.debuffIcon = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.num:SetPoint("TOPLEFT", 5, -5)
	local function disable()
		return Entropy.db.units.debuffIcon == 0
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, "Position", L["lime_func_aura_16"], nil, disable, true,
		function()
			return Option.dropdownTable["IconPos"][Entropy.db.units.debuffIconPos], Option.dropdownTable["Icon"]
		end,
		function(v)
			Entropy.db.units.debuffIconPos = Option.dropdownTable["IconPos"][v]
			Option:UpdateIconPos()
		end
	)
	menu.pos:SetPoint("TOPRIGHT", -5, -5)
	menu.size = LBO:CreateWidget("Slider", parent, "Size", L["lime_func_aura_17"], nil, disable, true,
		function()
			return Entropy.db.units.debuffIconSize, 4, 20, 1, ""
		end,
		function(v)
			Entropy.db.units.debuffIconSize = v
			Option:UpdateMember(update)
		end
	)
	menu.size:SetPoint("TOP", menu.num, "BOTTOM", 0, -10)
	local typeList = { L["lime_func_button_27"], L["lime_func_button_23"], L["색상"] }
	menu.type = LBO:CreateWidget("DropDown", parent, L["lime_func_aura_18"], L["lime_func_aura_19"], nil, disable, true,
		function()
			return Entropy.db.units.debuffIconType, typeList
		end,
		function(v)
			Entropy.db.units.debuffIconType = v
			Option:UpdateMember(Entropy.headers[0].members[1].SetupDebuffIcon)
		end
	)
	menu.type:SetPoint("TOP", menu.pos, "BOTTOM", 0, -10)
	local function getDebuff(debuff)
		return Entropy.db.units.debuffIconFilter[debuff]
	end
	local function setDebuff(v, debuff)
		Entropy.db.units.debuffIconFilter[debuff] = v
		Option:UpdateMember(update)
	end
	local colorList = { "Magic", "Curse", "Disease", "Poison", "none" }
	local colorLocale = { L["마법"], L["저주"], L["질병"], L["독"], L["무속성"] }
	for i, color in ipairs(colorList) do
		menu["color"..i] = LBO:CreateWidget("CheckBox", parent, colorLocale[i]..L["lime_func_aura_20"], colorLocale[i]..L["lime_func_aura_21"], nil, disable, true, getDebuff, setDebuff, color)
		if i == 1 then
			menu["color"..i]:SetPoint("TOP", menu.size, "BOTTOM", 0, 0)
		elseif i == 2 then
			menu["color"..i]:SetPoint("TOP", menu.color1, 0, 0)
			menu["color"..i]:SetPoint("RIGHT", -5, 0)
		else
			menu["color"..i]:SetPoint("TOP", menu["color"..(i - 2)], "BOTTOM", 0, 14)
		end
	end
end

function Option:CreateDebuffHealthMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateState(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["lime_func_aura_22"], L["lime_func_aura_23"], nil, nil, true,
		function()
			return Entropy.db.units.useDispelColor
		end,
		function(v)
			Entropy.db.units.useDispelColor = v
			Option:UpdateMember(update)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	menu.sound = LBO:CreateWidget("Media", parent, L["lime_func_aura_24"], L["lime_func_aura_25"], nil, nil, true,
		function()
			return Entropy.db.units.dispelSound, "sound"
		end,
		function(v)
			Entropy.db.units.dispelSound = v
		end
	)
	menu.sound:SetPoint("TOPRIGHT", -5, -5)
end
]]--
function Option:CreateBossAuraMenu(menu, parent)
	local debuffs = {}
	menu.list = LBO:CreateWidget("List", parent, "List of important effects", nil, nil, nil, true,
		function()
			wipe(debuffs)
			for debuff in pairs(Entropy.bossAura) do
				if Entropy.db.userAura[debuff] ~= false then
					local text = ("%s(%d)"):format(GetSpellInfo(debuff) or "", debuff)
					tinsert(debuffs, text)
				end
			end
			for debuff, v in pairs(Entropy.db.userAura) do
				if v == true then
					if Entropy.bossAura[debuff] then
						Entropy.db.userAura[debuff] = nil
					else
						local text
						if type(debuff) == "number" then
							text = ("%s(%d)"):format(GetSpellInfo(debuff) or "", debuff)
						else
							text = debuff
						end
						tinsert(debuffs, text)
					end
				end
			end
			sort(debuffs)
			return debuffs, true
		end,
		function(v)
			menu.delete:Update()
		end
	)
	menu.list:SetPoint("TOPLEFT", 5, -5)
	menu.delete = LBO:CreateWidget("Button", parent, "Delete", "Removes the selected effect from the list.", nil,
		function()
			if menu.list:GetValue() then
				menu.delete.title:SetFormattedText( "\"%s\" Delete", debuffs[menu.list:GetValue()])
				return nil
			else
				menu.delete.title:SetText("Delete")
				return true
			end
		end, nil,
		function()
			local name = debuffs[menu.list:GetValue()]
			Entropy:Message(("\"%s\" has been removed from the list of important effects."):format(name))
			for spellId in string.gmatch(name, "%d+") do
				name = tonumber(spellId)
			end
			Entropy.db.userAura[name] = false
			menu.reset:Update()
			menu.list:Setup()
		end
	)
	menu.delete:SetPoint("TOPLEFT", menu.list, "BOTTOMLEFT", 0, 12)
	menu.delete:SetPoint("TOPRIGHT", menu.list, "BOTTOMRIGHT", 0, 12)
	menu.editbox = LBO:CreateEditBox(parent, nil, "ChatFontNormal", nil, true)
	menu.editbox:SetPoint("TOPLEFT", menu.delete, "BOTTOMLEFT", 2, 6)
	menu.editbox:SetPoint("TOPRIGHT", menu.delete, "BOTTOMRIGHT", -60, 6)
	menu.editbox:SetScript("OnTextChanged", function() menu.add:Update() end)
	menu.editbox:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)
	local function add()
		local text = (menu.editbox:GetText() or ""):trim()
		local spell
		if tonumber(text) then
			spell = tonumber(text)
			text = GetSpellInfo(text) or nil
		else
			spell = text
		end
		menu.editbox:SetText("")
		menu.editbox:ClearFocus()
		if not text then
			Entropy:Message(("%d does not exist."):format(spell))
		elseif Entropy.db.userAura[spell] or Entropy.db.userAura[spell] or (Entropy.bossAura[spell] and Entropy.db.userAura[spell] ~= false) or (Entropy.bossAura[text] and Entropy.db.userAura[text] ~= false) then
			Entropy:Message(("\"%s\" is already on the list of important effects."):format(text))
		else
			Entropy:Message(("\"%s\" has been added to the list of important effects."):format(text))
			if Entropy.bossAura[spell] then
				Entropy.db.userAura[spell] = nil
			else
				Entropy.db.userAura[spell] = true
			end
			menu.list:Setup()
			menu.reset:Update()
			menu.delete:Update()
		end
	end
	menu.editbox:SetScript("OnEnterPressed", function(self)
		if (self:GetText() or ""):trim() ~= "" then
			add()
		else
			self:SetText("")
			self:ClearFocus()
		end
	end)
	menu.add = LBO:CreateWidget("Button", parent, "Add", "Add effects to the list.", nil, function() return (menu.editbox:GetText() or ""):trim() == "" end, true, add)
	menu.add:SetPoint("TOPLEFT", menu.editbox, "TOPRIGHT", 2, 14)
	menu.add:SetPoint("RIGHT", menu.delete, "RIGHT", 0, 0)
	menu.reset = LBO:CreateWidget("Button", parent, "Reset", "Restores the list of important effects to the default value.", nil, function() return not next(Entropy.db.userAura) end, true,
		function()
			menu.editbox:SetText("")
			menu.editbox:ClearFocus()
			wipe(Entropy.db.userAura)
			menu.list:Setup()
			menu.reset:Update()
			menu.delete:Update()
			Entropy:Message("The list of important effects has been restored to the default value.")
		end
	)
	menu.reset:SetPoint("TOP", menu.add, "BOTTOM", 0, 18)
	menu.reset:SetPoint("LEFT", menu.delete, "LEFT", 0, 0)
	menu.reset:SetPoint("RIGHT", menu.delete, "RIGHT", 0, 0)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Using important effects", "Use the important effect icon display function.", nil, nil, true,
		function() return Entropy.db.units.useBossAura end,
		function(v)
			Entropy.db.units.useBossAura = v
			menu.pos:Update()
			menu.size:Update()
			menu.alpha:Update()
			menu.timer:Update()
		end
	)
	menu.use:SetPoint("TOPRIGHT", -5, -5)
end


function Option:CreateRaidTargetMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Enable", "Show target marker icon", nil, nil, true,
		function()
			return Entropy.db.units.useRaidIcon
		end,
		function(v)
			Entropy.db.units.useRaidIcon = v
			Entropy:updateAll()
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	local function disable()
		return not Entropy.db.units.useRaidIcon
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, "Position", "Sets the position of the target marker icon.", nil, disable, true,
		function()
			return Option.dropdownTable["IconPos"][Entropy.db.units.raidIconPos], Option.dropdownTable["Icon"]
		end,
		function(v)
			Entropy.db.units.raidIconPos = Option.dropdownTable["IconPos"][v]
			Entropy:updateAll()
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 10)
	menu.scale = LBO:CreateWidget("Slider", parent,"Size of target marker icon", "Sets the size of the target marker icon.", nil, disable, true,
		function()
			return Entropy.db.units.raidIconSize, 8, 24, 1, ""
		end,
		function(v)
			Entropy.db.units.raidIconSize = v
		end
	)
	menu.scale:SetPoint("TOP", menu.pos, "TOP", 0, 0)
	menu.scale:SetPoint("RIGHT", -5, 0)
	menu.target = LBO:CreateWidget("CheckBox", parent, "Displays the target marker icon for the target of target", "Displays the target marker icon for the target of target", nil, disable, true,
		function()
			return Entropy.db.units.raidIconTarget
		end,
		function(v)
			Entropy.db.units.raidIconTarget = v
		end
	)
	menu.target:SetPoint("TOP", menu.pos, "BOTTOM", 0, -5)
	local function get(id)
		return Entropy.db.units.raidIconFilter[id]
	end
	local function set(v, id)
		Entropy.db.units.raidIconFilter[id] = v
		Entropy:updateAll()
	end
	for i, icon in ipairs(self.dropdownTable["Marks"]) do
		menu["icon"..i] = LBO:CreateWidget("CheckBox", parent, icon.."", icon.."", nil, disable, true, get, set, i)
		if i == 1 then
			menu.icon1:SetPoint("TOP", menu.target, "BOTTOM", 0, 0)
		elseif i == 2 then
			menu.icon2:SetPoint("TOP", menu.icon1, "TOP", 0, 0)
			menu.icon2:SetPoint("RIGHT", -5, 0)
		else
			menu["icon"..i]:SetPoint("TOP", menu["icon"..(i - 2)], "BOTTOM", 0, 15)
		end
	end
end

function Option:CreateResurrectionMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Enable", "Sets the resurrection bar that is cast to the player.", nil, nil, true,
		function()
			return Entropy.db.units.useResurrectionBar
		end,
		function(v)
			Entropy.db.units.useResurrectionBar = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
end

function Option:CreateRaidRoleMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Enable", "Sets the display of the role icon.", nil, nil, true,
		function()
			return Entropy.db.units.displayRaidRoleIcon
		end,
		function(v)
			Entropy.db.units.displayRaidRoleIcon = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -10)
	local function disable()
		return not Entropy.db.units.displayRaidRoleIcon
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, "Position", "Sets the position to display the role icon.", nil, disable, true,
		function()
			return Option.dropdownTable["IconPos"][Entropy.db.units.roleIconPos], Option.dropdownTable["Icon"]
		end,
		function(v)
			Entropy.db.units.roleIconPos = Option.dropdownTable["IconPos"][v]
			Entropy:updateAll()
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 5)
	menu.size = LBO:CreateWidget("Slider", parent, "Size", "Sets the size of the role icon.", nil, disable, true,
		function()
			return Entropy.db.units.roleIconSize, 8, 20, 1, ""
		end,
		function(v)
			Entropy.db.units.roleIconSize = v
			Entropy:updateAll()
		end
	)
	menu.size:SetPoint("TOP", menu.pos, "TOP", 0, 0)
	menu.size:SetPoint("RIGHT", 0, -5)

	local pack = { "Default", "MiirGui"}
	menu.pack = LBO:CreateWidget("DropDown", parent, "Appearance", "Change the appearance of the role icon.", nil, disable, true,
		function()
			return Entropy.db.units.roleIcontype + 1, pack
		end,
		function(v)
			Entropy.db.units.roleIcontype = v - 1
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.pack:SetPoint("TOP", menu.pos, "BOTTOM", 0, 5)
end

function Option:CreateCenterStatusIconMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Enable", "Sets the display of the status icons displayed in the center.", nil, nil, true,
		function()
			return Entropy.db.units.centerStatusIcon
		end,
		function(v)
			Entropy.db.units.centerStatusIcon = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -10)
end
