

local Entropy = Entropy
local Option = Entropy.optionFrame
local LBO = LibStub("LibLimeOption-1.0")
local lime_mapicon = LibStub("LibDBIcon-1.0")

function Option:CreateUseMenu(menu, parent)
	self.CreateUseMenu = nil
	local runList = { L["사용하기"], L["사용 안함"] }
	menu.run = LBO:CreateWidget("DropDown", parent, L["lime_basic_01"], L["lime_basic_desc_01"], nil, nil, true,
		function() return Entropy.db.run and 1 or 2, runList end,
		function(v)
			Entropy:SetAttribute("run", v == 1)
			LimeOverlord:GetScript("PostClick")(LimeOverlord)
		end
	)
	menu.run:SetPoint("TOPLEFT", 5, -5)
	self.runMenu = menu.run
	local tooltipList = { L["표시 안함"], L["항상 표시"], L["전투 중이 아닐 때만 표시"], L["전투 중일 때만 표시"] }
	menu.tooltip = LBO:CreateWidget("DropDown", parent, L["lime_basic_03"], L["lime_basic_desc_03"], nil, nil, true,
		function() return Entropy.db.units.tooltip + 1, tooltipList end,
		function(v)
			Entropy.db.units.tooltip = v - 1
			Entropy:UpdateTooltipState()
		end
	)
	menu.tooltip:SetPoint("TOP", menu.run, "BOTTOM", 0, -10)
	menu.mapButtonToggle = LBO:CreateWidget("CheckBox", parent, L["lime_basic_05"], L["lime_basic_desc_05"], nil, nil, true,
		function() return EntropyDB.minimapButton.hide end,
		function(v)
			EntropyDB.minimapButton.hide = v
			if EntropyDB.minimapButton.hide then
				lime_mapicon:Hide("Lime")
			else
				lime_mapicon:Show("Lime")
			end
			menu.mapButtonLock:Update()
		end
	)
	menu.mapButtonToggle:SetPoint("TOP", menu.tooltip, "BOTTOM", 0, 0)
	menu.mapButtonLock = LBO:CreateWidget("CheckBox", parent, L["lime_basic_06"] , L["lime_basic_desc_06"], nil,
		function() return EntropyDB.minimapButton.hide end, nil,
		function() return not EntropyDB.minimapButton.dragable end,
		function(v)
			EntropyDB.minimapButton.dragable = not v
			if EntropyDB.minimapButton.dragable then
			    lime_mapicon:Unlock("Lime")
			else
			    lime_mapicon:Lock("Lime")
			end
		end
	)
	menu.mapButtonLock:SetPoint("TOP", menu.lock, "BOTTOM", 0, 0)
	menu.hideBlizzardParty = LBO:CreateWidget("CheckBox", parent, L["lime_basic_07"], L["lime_basic_desc_07"], nil, nil, true,
		function() return Entropy.db.hideBlizzardParty end,
		function(v)
			Entropy:HideBlizzardPartyFrame(v)
		end
	)
	menu.hideBlizzardParty:SetPoint("TOP", menu.mapButtonToggle, "BOTTOM", 0, 0)
	menu.clear = LBO:CreateWidget("Button", parent, L["lime_basic_08"],L["lime_basic_desc_08"] , nil, nil, true,
		function()
			Entropy.db.px, Entropy.db.py = nil
			Entropy:SetUserPlaced(nil)
			Entropy:ClearAllPoints()
			Entropy:SetPoint(Entropy.db.anchor, UIParent, "CENTER", 0, 0)
			Entropy:SetUserPlaced(nil)
		end
	)
	menu.clear:SetPoint("TOP", menu.mapButtonLock, "BOTTOM", 0, 0)
	menu.manager = LBO:CreateWidget("CheckBox", parent, L["lime_basic_09"], L["lime_basic_09"], nil, nil, true,
		function() return Entropy.db.useManager end,
		function(v)
			Entropy.db.useManager = v
			Entropy:ToggleManager()
			LBO:Refresh()
		end
	)
	menu.manager:SetPoint("TOP", menu.hideBlizzardParty, "BOTTOM", 0, -10)
	menu.managerPos = LBO:CreateWidget("Slider", parent, L["lime_basic_10"], L["lime_basic_desc_10"], nil, function() return not Entropy.db.useManager end, nil,
		function() return Entropy.db.managerPos, 0, 360, 0.1, L["도"] end,
		function(v)
			Entropy.db.managerPos = v
			Entropy:SetManagerPosition()
		end
	)
end