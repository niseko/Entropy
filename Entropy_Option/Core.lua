local Entropy = Entropy
local Option = Entropy.optionFrame
Option.loaded = true
Option:SetScript("OnShow", nil)
Option:UnregisterAllEvents()
Option:SetScript(
	"OnEvent",
	function(self, event, ...)
		self[event](self, ...)
	end
)

local _G = _G
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local sort = _G.table.sort
local twipe = _G.table.wipe
local tinsert = _G.table.insert
local tremove = _G.table.remove
local CreateFrame = _G.CreateFrame
local LBO = LibStub("LibLimeOption-1.0")

local menuOnClick = function(id)
	Option:ShowDetailMenu(id)
end
local menuList = {
	--{name = "General", desc = "Sets whether to use raid frames.", func = menuOnClick, create = "Use"},
	{name = "Frame Setup", desc = "Sets the appearance.", func = menuOnClick, create = "Frame"},
	{name = "HealthBar Color", desc = "Sets the health bar color.", func = menuOnClick, create = "HealthBar"},
	{name = "HealthBar Background", desc = "...", func = menuOnClick, create = "HealthBarBackground"},
	--{name = "PowerBar", desc = "Sets the appearance of the resource bar.", func = menuOnClick, create = "ManaBar"},
	{name = "Name Text", desc = "Sets the appearance and style of the name.", func = menuOnClick, create = "Name"},
	{name = "Aura Highlight", desc = "Aura highlighting.", func = menuOnClick, create = "HighlightAura"},
	{name = "Aura Filter", desc = "Aura filtering.", func = menuOnClick, create = "IgnoreAura"},
	--{name = "Health Text", desc = "Set how you want to display Health.", func = menuOnClick, create = "LostHealth"},
	--{name = "BG Border", desc = "Sets the border around the raid frames.", func = menuOnClick, create = "Border"},
	--{name = "Aggro", desc = "Set how you want to display the person who acquired the threat.", func = menuOnClick, create = "Aggro"},
	--{name = "Range", desc = "Set how to display the person who is 40m away from yourself.", func = menuOnClick, create = "Range"},
	{name = "Heal Prediction", desc = "Set how to display the amount of healing and the amount of absorption.", func = menuOnClick, create = "HealPrediction"},
	--{name = "Enemy", desc = "Change the player's health bar color to become hostile.", func = menuOnClick, create = "Enemy"},
	--{name = "Defensives", desc = "Tracks the survival skills used by the player and displays them.", func = menuOnClick, create = "SurvivalSkill"},
	--{name = "Role", desc = "Displays the role icon given to the player.", func = menuOnClick, create = "RaidRole"},
	--{name = "Raidmarker", desc = "Displays the marker icon.", func = menuOnClick, create = "RaidTarget"},
	--{name = "Leader", desc = "Shows Group leader icon.", func = menuOnClick, create = "LeaderIcon"},
	--{name = "Profile", desc = "You can manage profiles.", func = menuOnClick, create = "Profile", disableScroll = true},
	{name = "Misc", desc = "Misc.", func = menuOnClick, create = "PartyTag"},
}
Option.dropdownTable = {
	["Icon"] = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"},
	["IconPos"] = {
		["TOPLEFT"] = "TOPLEFT",
		["TOP"] = "TOP",
		["TOPRIGHT"] = "TOPRIGHT",
		["LEFT"] = "LEFT",
		["CENTER"] = "CENTER",
		["RIGHT"] = "RIGHT",
		["BOTTOMLEFT"] = "BOTTOMLEFT",
		["BOTTOM"] = "BOTTOM",
		["BOTTOMRIGHT"] = "BOTTOMRIGHT",
		TOPLEFT = "TOPLEFT",
		TOP = "TOP",
		TOPRIGHT = "TOPRIGHT",
		LEFT = "LEFT",
		CENTER = "CENTER",
		RIGHT = "RIGHT",
		BOTTOMLEFT = "BOTTOMLEFT",
		BOTTOM = "BOTTOM",
		BOTTOMRIGHT = "BOTTOMRIGHT"
	},
	["Marks"] = {}
}
for i = 1, 8 do
	Option.dropdownTable["Marks"][i] =
		("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0:0:0:-1|t %s" .. " Marker"):format(
		i,
		_G["RAID_TARGET_" .. i]
	)
end
if not Option.title then
	Option.title = Option:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Option.title:SetText(Option.name)
	Option.title:SetPoint("TOPLEFT", 12, -12)
	Option.version = Option:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	Option.version:SetText(Entropy.version)
	Option.version:SetPoint("LEFT", Option.title, "RIGHT", 4, 0)
	Option.Author = Option:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	Option.Author:SetText("|cff777777Niseko|r")
	Option.Author:SetPoint("TOPRIGHT", -13, -13)
end
if Option.combatWarn then
	Option.combatWarn:Hide()
end
Option.mainBorder = CreateFrame("Frame", nil, Option)
Option.mainBorder:SetBackdrop(
	{
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		edgeSize = 16,
		insets = {left = 5, right = 5, top = 5, bottom = 5}
	}
)
Option.mainBorder:SetPoint("TOPLEFT", Option.title, "BOTTOMLEFT", 1, -26)
Option.mainBorder:SetPoint("BOTTOMRIGHT", Option, "BOTTOMLEFT", 163, 10)

Option.mainScroll, Option.detailScroll = {}, {}

local function menuCheck(menu)
	for p, v in pairs(menu) do
		if v.create and type(Option["Create" .. v.create .. "Menu"]) ~= "function" then
			tremove(menu, p)
			menuCheck(menu)
			break
		end
	end
end

Option.detailBorder = CreateFrame("Frame", nil, Option)
Option.detailBorder:SetBackdrop(
	{
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		edgeSize = 16,
		insets = {left = 5, right = 5, top = 5, bottom = 5}
	}
)
Option.detailBorder:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
Option.detailBorder:SetPoint("TOPLEFT", Option.mainBorder, "TOPRIGHT", 4, 0)
Option.detailBorder:SetPoint("BOTTOMRIGHT", Option, "BOTTOMRIGHT", -10, 10)
Option.detailDesc = Option:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
Option.detailDesc:SetHeight(36)
Option.detailDesc:SetJustifyH("LEFT")
Option.detailDesc:SetJustifyV("BOTTOM")
Option.detailDesc:SetNonSpaceWrap(true)
Option.detailDesc:SetPoint("BOTTOMLEFT", Option.detailBorder, "TOPLEFT", 12, 4)
Option.detailDesc:SetPoint("RIGHT", -18, 0)

function Option:Setup()
	self.mainScroll = LBO:CreateWidget("Menu", self, menuList)
	self.mainScroll:SetAllPoints(Option.mainBorder)
	self.mainScroll:Show()
	self:ShowDetailMenu(1)
end

function Option:ShowDetailMenu(id)
	self.openedDetailName = menuList[id].name
	if not self.detailScroll[self.openedDetailName] then
		local menu
		if menuList[id].create and not menuList[id].disableScroll then
			menu = LBO:CreateWidget("ScrollFrame", self.mainScroll)
		else
			menu = CreateFrame("Frame", nil, self.mainScroll)
		end
		menu:Hide()
		menu.options = {}
		menu:SetPoint("TOPLEFT", self.detailBorder, "TOPLEFT", 5, -5)
		menu:SetPoint("BOTTOMRIGHT", self.detailBorder, "BOTTOMRIGHT", -5, 5)
		if menuList[id].create and self["Create" .. menuList[id].create .. "Menu"] then
			self["Create" .. menuList[id].create .. "Menu"](self, menu.options, menu.content or menu)
			self["Create" .. menuList[id].create .. "Menu"] = nil
		end
		menuList[id].create = nil
		self.detailScroll[self.openedDetailName] = menu
	end
	for name, frame in pairs(self.detailScroll) do
		if name == self.openedDetailName then
			frame:Show()
		else
			frame:Hide()
		end
	end
	self.detailDesc:SetText(menuList[id].desc or "")
end

local optKey, optValue

function Option:SetOption(...)
	Entropy:SetAttribute("startupdate", nil)
	for i = 1, select("#", ...), 2 do
		optKey, optValue = select(i, ...)
		Entropy:SetAttribute(optKey, optValue or nil)
	end
	Entropy:SetAttribute("startupdate", true)
end


function Option:ConvertTable(input, output)
	if type(input) == "table" then
		if type(output) == "table" then
			twipe(output)
		else
			output = {}
		end
		for p, v in pairs(input) do
			if v then
				tinsert(output, p)
			end
		end
		sort(output)
		return output
	else
		return nil
	end
end

Option:Setup()
