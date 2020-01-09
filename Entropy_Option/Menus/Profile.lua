local Entropy = Entropy
local Option = Entropy.optionFrame
local LBO = LibStub("LibLimeOption-1.0")

local _G = _G
local pairs = _G.pairs
local ipairs = _G.ipairs
local unpack = _G.unpack
local InCombatLockdown = _G.InCombatLockdown
local UnitAffectingCombat = _G.UnitAffectingCombat

function Option:CreateProfileMenu(menu, parent)
	local profiles = {}
	local function disable()
		return StaticPopup_Visible("lime_NEW_PROFILE") or StaticPopup_Visible("lime_DELETE_PROFILE") or StaticPopup_Visible("lime_APPLY_PROFILE")
	end
	local function getTargetProfile()
		if menu.list:GetValue() then
			menu.targetProfile = profiles[menu.list:GetValue()]
		else
			menu.targetProfile = nil
		end
		return menu.targetProfile
	end
	menu.current = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	menu.current:SetPoint("TOPLEFT", 5, -5)
	menu.current:SetText("Current Profile: |cffffffff"..(EntropyDB.profileKeys[Entropy.profileName] or "Default"))
	menu.list = LBO:CreateWidget("List", parent, "Profile lists", nil, nil, disable, nil,
		function()
			return Option:ConvertTable(EntropyDB.profiles, profiles), true
		end,
		function(v)
			getTargetProfile()
			menu.apply:Update()
			menu.delete:Update()
		end
	)
	menu.list:SetPoint("TOPLEFT", menu.current, "BOTTOMLEFT", 0, -10)
	menu.list:HookScript("OnHide", function()
		StaticPopup_Hide("lime_NEW_PROFILE")
		StaticPopup_Hide("lime_DELETE_PROFILE")
		StaticPopup_Hide("lime_APPLY_PROFILE")
	end)
	menu.apply = LBO:CreateWidget("Button", parent, "Applies profile","Applies the selected profile to the current character.", nil,
		function()
			if disable() then
				return true
			elseif getTargetProfile() then
				if menu.targetProfile == Entropy.dbName then
					return true
				else
					return nil
				end
			else
				return true
			end
		end, true,
		function()
			StaticPopup_Show("lime_APPLY_PROFILE", getTargetProfile())
		end
	)
	menu.apply:SetPoint("TOPLEFT", menu.list, "BOTTOMLEFT", 0, 12)
	menu.apply:SetPoint("TOPRIGHT", menu.list, "BOTTOMRIGHT", 0, 12)
	menu.create = LBO:CreateWidget("Button", parent, "Create a new profile", "Copies the currently selected profile, creates new profile, and applies them to the current character. If you have not selected a profile, create a new profile with a default."
,	nil, disable, true,
		function()
			getTargetProfile()
			StaticPopup_Show("lime_NEW_PROFILE")
		end
	)
	menu.create:SetPoint("TOPLEFT", menu.apply, "BOTTOMLEFT", 0, 20)
	menu.create:SetPoint("TOPRIGHT", menu.apply, "BOTTOMRIGHT", 0, 20)

	menu.delete = LBO:CreateWidget("Button", parent, "Delete profile", "Deletes the currently selected profile.", nil,
		function()
			if disable() then
				return true
			elseif getTargetProfile() then
				if menu.targetProfile == "Default" or menu.targetProfile == Entropy.dbName then
					return true
				else
					return nil
				end
			else
				return true
			end
		end, true,
		function()
			StaticPopup_Show("lime_DELETE_PROFILE", getTargetProfile())
		end
	)
	menu.delete:SetPoint("TOPLEFT", menu.create, "BOTTOMLEFT", 0, 20)
	menu.delete:SetPoint("TOPRIGHT", menu.create, "BOTTOMRIGHT", 0, 20)

	menu.profilehelp = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	menu.profilehelp:SetText("Entropy Command\n|cffa2e665/entropy|r: Opens Preference for Entropy.\n|cffa2e665/entropy s [Profile name]|r: Switch to [Profile name] Profile. You can't change it while in battle.\n|cffa2e665/entropy h|r: Show list of commands.")
	menu.profilehelp:SetPoint("TOPLEFT", menu.delete, "BOTTOMLEFT", 5, -10)
	menu.profilehelp:SetSize(380, 250)
	menu.profilehelp:SetJustifyV("TOP")
	menu.profilehelp:SetJustifyH("LEFT")
	menu.profilehelp:SetSpacing("2")

	local function togglePopup()
		menu.list:Update()
		menu.apply:Update()
		menu.delete:Update()
		LBO:Refresh(parent)
	end
	local function checkCombat(self)
		if UnitAffectingCombat("player") or InCombatLockdown() then
			self:Hide()
		end
	end
	StaticPopupDialogs["lime_NEW_PROFILE"] = {
		preferredIndex = STATICPOPUP_NUMDIALOGS,
		text = "Create new profile.\nPlease enter new profile name.",
		button1 = OKAY, button2 = CANCEL, hideOnEscape = 1, timeout = 0, exclusive = 1, whileDead = 1, hasEditBox = 1, maxLetters = 32, showAlert = 1,
		OnUpdate = checkCombat, OnHide = togglePopup,
		OnAccept = function(self)
			local name = (self.editBox:GetText() or ""):trim()
			if name ~= "" then
				if EntropyDB.profiles[name] then
					Entropy:Message(("[|cff8080ff%s|r] profile already exists."):format(name))
				elseif Option:NewProfile(name, menu.targetProfile) then
					if EntropyDB.profiles[name] then
						menu.current:SetText("Current Profile: |cffffffff"..name)
						Entropy:Message(("[|cff8080ff%s|r] profile has been created."):format(name))
					else
						Entropy:Message("Failed to create profile.")
					end
				else
					Entropy:Message("Failed to create profile.")
				end
			end
		end,
		OnShow = function(self)
			self.button1:Disable()
			self.button2:Enable()
			self.editBox:SetText("")
			self.editBox:SetFocus()
			togglePopup()
		end,
		EditBoxOnTextChanged = function(self)
			if (self:GetParent().editBox:GetText() or ""):trim() ~= "" then
				self:GetParent().button1:Enable()
			else
				self:GetParent().button1:Disable()
			end
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		EditBoxOnEnterPressed = function(self)
			if (self:GetParent().editBox:GetText() or ""):trim() ~= "" then
				self:GetParent().button1:Click()
			end
		end,
	}
	StaticPopupDialogs["lime_DELETE_PROFILE"] = {
		preferredIndex = STATICPOPUP_NUMDIALOGS,
		text ="'%s' Delete this profile.\nAre you sure you want to delete?",
		button1 = YES, button2 = NO, hideOnEscape = 1, timeout = 0, exclusive = 1, whileDead = 1, showAlert = 1,
		OnUpdate = checkCombat, OnShow = togglePopup, OnHide = togglePopup,
		OnAccept = function(self)
			EntropyDB.profiles[menu.targetProfile] = nil
			for p, v in pairs(EntropyDB.profileKeys) do
				if v == menu.targetProfile then
					EntropyDB.profileKeys[p] = nil
				end
			end
			Entropy:Message(("[|cff8080ff%s|r] profile has been deleted."):format(menu.targetProfile))
		end,
	}
	StaticPopupDialogs["lime_APPLY_PROFILE"] = {
		preferredIndex = STATICPOPUP_NUMDIALOGS,
		text = "Do you want to apply the '%s' profile to the current character?",
		button1 = YES, button2 = NO, hideOnEscape = 1, timeout = 0, exclusive = 1, whileDead = 1, showAlert = 1,
		OnUpdate = checkCombat, OnShow = togglePopup, OnHide = togglePopup,
		OnAccept = function(self)
			menu.current:SetText("Current Profile: |cffffffff"..(menu.targetProfile or "Default"))
			Entropy:SetProfile(menu.targetProfile)
			Entropy:ApplyProfile()
			Entropy:Message(("[|cff8080ff%s|r] profile has been applied to the current character."):format(menu.targetProfile))
		end,
	}
end

function Option:NewProfile(profile1, profile2)
	if type(profile1) == "string" and not EntropyDB.profiles[profile1] then
		if type(profile2) == "string" and EntropyDB.profiles[profile2] then
			EntropyDB.profiles[profile1] = CopyTable(EntropyDB.profiles[profile2])
		end
		Entropy:SetProfile(profile1)
		Entropy:ApplyProfile()
		return true
	end
	return nil
end