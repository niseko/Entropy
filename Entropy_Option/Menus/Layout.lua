local Entropy = Entropy
local Option = Entropy.optionFrame
local LBO = LibStub("LibLimeOption-1.0")
local SM = LibStub("LibSharedMedia-3.0")

local _G = _G
local pairs = _G.pairs
local ipairs = _G.ipairs
local unpack = _G.unpack

function Option:CreateFrameMenu(menu, parent)
	menu.texture =
		LBO:CreateWidget(
		"Media",
		parent,
		"Texture",
		"Set the bar texture.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.units.texture, "statusbar"
		end,
		function(v)
			Entropy.db.units.texture = v
			Entropy:updateAll()
		end
	)
	menu.texture:SetPoint("TOPLEFT", 5, -5)
	menu.useCustomAlpha =
		LBO:CreateWidget(
		"CheckBox",
		parent,
		"Out of Range Alpha",
		"Adjust the alpha of the frame when someone is OOR. CPU intensive.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.units.useCustomFadeAlpha
		end,
		function(v)
			Entropy.db.units.useCustomFadeAlpha = v
			Entropy:updateAll()
			LBO:Refresh(parent)
		end
	)
	local function disable()
		return not Entropy.db.units.useCustomFadeAlpha
	end
	menu.useCustomAlpha:SetPoint("TOP", menu.texture, "BOTTOM", 0, -10)
	menu.alpha =
		LBO:CreateWidget(
		"Slider",
		parent,
		"Alpha",
		"Adjust the alpha of the frame when someone is OOR.",
		nil,
		disable,
		true,
		function()
			return Entropy.db.units.outOfRangeAlpha * 100, 0, 100, 1, ""
		end,
		function(v)
			Entropy.db.units.outOfRangeAlpha = v / 100
			Entropy:updateAll()
		end
	)
	menu.alpha:SetPoint("TOP", menu.useCustomAlpha, "BOTTOM", 0, -10)
	menu.alphaBG =
		LBO:CreateWidget(
		"Slider",
		parent,
		"Background Alpha",
		"Adjust the alpha of the frame background when someone is OOR.",
		nil,
		disable,
		true,
		function()
			return Entropy.db.units.outOfRangeBgAlpha * 100, 0, 100, 1, ""
		end,
		function(v)
			Entropy.db.units.outOfRangeBgAlpha = v / 100
			Entropy:updateAll()
		end
	)
	menu.alphaBG:SetPoint("TOP", menu.alpha, "BOTTOM", 0, -10)

	menu.width =
		LBO:CreateWidget(
		"Slider",
		parent,
		"Width",
		"Adjust the width of the frame.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.width, 32, 256, 1, ""
		end,
		function(v)
			Entropy.db.width = v
			Entropy:updateAll()
		end
	)
	menu.width:SetPoint("TOPRIGHT", -5, -5)
	menu.height =
		LBO:CreateWidget(
		"Slider",
		parent, --CompactUnitFrameProfilesGeneralOptionsFrame
		"Height",
		"Adjust the height of the frame.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.height, 25, 256, 1, ""
		end,
		function(v)
			Entropy.db.height = v
			Entropy:updateAll()
		end
	)
	menu.height:SetPoint("TOP", menu.width, "BOTTOM", 0, -10) -- menu.height:SetPoint("TOP", CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown, "BOTTOMLEFT", 100, 0)

	menu.buffSize =
		LBO:CreateWidget(
		"Slider",
		parent,
		"Buff Size",
		"Adjust the buff size.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.units.buffIconSize, 5, 32, 1, ""
		end,
		function(v)
			Entropy.db.units.buffIconSize = v
			Entropy:updateAll()
		end
	)
	menu.buffSize:SetPoint("TOP", menu.height, "BOTTOM", 0, -10)
end

function Option:CreateHealthBarMenu(menu, parent)
	menu.classColor =
		LBO:CreateWidget(
		"CheckBox",
		parent,
		"Color by class",
		"Change the bar color according to the color of each class.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.units.useClassColors
		end,
		function(v)
			Entropy.db.units.useClassColors = v
			Entropy:updateAll()
		end
	)
	menu.classColor:SetPoint("TOPRIGHT", -5, -5)
	menu.reset =
		LBO:CreateWidget(
		"Button",
		parent,
		"Reset Color",
		"Returns the set color to the default value.",
		nil,
		nil,
		true,
		function()
			Entropy.db.colors.help[1], Entropy.db.colors.help[2], Entropy.db.colors.help[3] = 0, 1, 0
			Entropy.db.colors.harm[1], Entropy.db.colors.harm[2], Entropy.db.colors.harm[3] = 0.5, 0, 0
			Entropy.db.colors.vehicle[1], Entropy.db.colors.vehicle[2], Entropy.db.colors.vehicle[3] = 0, 0.4, 0
			Entropy.db.colors.offline[1], Entropy.db.colors.offline[2], Entropy.db.colors.offline[3] = 0.5, 0.5, 0.5
			Entropy.db.colors.dead[1], Entropy.db.colors.dead[2], Entropy.db.colors.dead[3] = 0.5, 0.5, 0.5
			for class, color in pairs(RAID_CLASS_COLORS) do
				if Entropy.db.colors[class] then
					Entropy.db.colors[class][1], Entropy.db.colors[class][2], Entropy.db.colors[class][3] = color.r, color.g, color.b
				end
			end
			Entropy:updateAll()
			LBO:Refresh(parent)
		end
	)
	menu.reset:SetPoint("TOPLEFT", 5, -5)
	local colorList = {
		"help",
		"harm",
		"vehicle",
		"offline",
		"dead",
		"WARRIOR",
		"ROGUE",
		"PRIEST",
		"MAGE",
		"WARLOCK",
		"HUNTER",
		"DRUID",
		"SHAMAN",
		"PALADIN",
		"DEATHKNIGHT",
		"MONK",
		"DEMONHUNTER"
	}
	local colorLocale = {
		"Friendly",
		"Hostile",
		"Vehicle",
		"Offline",
		"Dead",
		"Warrior",
		"Rogue",
		"Priest",
		"Mage",
		"Warlock",
		"Hunter",
		"Druid",
		"Shaman",
		"Paladin",
		"Death Knight",
		"Monk",
		"Demon Hunter"
	}
	local function getColor(color)
		return Entropy.db.colors[color][1], Entropy.db.colors[color][2], Entropy.db.colors[color][3]
	end
	local function setColor(r, g, b, color)
		Entropy.db.colors[color][1], Entropy.db.colors[color][2], Entropy.db.colors[color][3] = r, g, b
		Entropy:updateAll()
	end
	for i, color in ipairs(colorList) do
		menu["color" .. i] =
			LBO:CreateWidget(
			"ColorPicker",
			parent,
			colorLocale[i],
			colorLocale[i] .. ": change color",
			nil,
			nil,
			true,
			getColor,
			setColor,
			color
		)
		if i == 1 then
			menu["color" .. i]:SetPoint("TOP", menu.reset, "BOTTOM", 0, 15)
		elseif i == 2 then
			menu["color" .. i]:SetPoint("TOP", menu.color1, 0, 0)
			menu["color" .. i]:SetPoint("RIGHT", -5, 0)
		else
			menu["color" .. i]:SetPoint("TOP", menu["color" .. (i - 2)], "BOTTOM", 0, 14)
		end
	end
end

function Option:CreateHealthBarBackgroundMenu(menu, parent)
	menu.texture =
		LBO:CreateWidget(
		"Media",
		parent,
		"Texture",
		"Set the bar texture.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.units.backgroundtexture, "statusbar"
		end,
		function(v)
			Entropy.db.units.backgroundtexture = v
			Entropy:updateAll()
		end
	)
	menu.texture:SetPoint("TOPLEFT", 5, -5)

	menu.classColor =
		LBO:CreateWidget(
		"CheckBox",
		parent,
		"Color by class",
		"Displays the background in the class color.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.colors.classBackground
		end,
		function(v)
			Entropy.db.colors.classBackground = v
			Entropy:updateAll()
			LBO:Refresh(parent)
		end
	)
	menu.classColor:SetPoint("TOP", menu.texture, "BOTTOM", 0, -5)
	menu.color = LBO:CreateWidget(
	"ColorPicker",
	parent,
	"Background color",
	"Sets the Background color. Does not apply when using color by class.",
	nil,
	nil,
	true,
	function()
		return Entropy.db.colors.background[1], Entropy.db.colors.background[2], Entropy.db.colors.background[3]
	end,
	function(r, g, b)
		Entropy.db.colors.background[1], Entropy.db.colors.background[2], Entropy.db.colors.background[3] = r, g, b
		Entropy:updateAll()
	end
	)
	menu.color:SetPoint("TOPRIGHT", -5, -50)
end

function Option:CreateManaBarMenu(menu, parent)
	menu.height =
		LBO:CreateWidget(
		"Slider",
		parent,
		"Size ratio",
		"Sets the size ratio of the resource bar. Setting the percentage to 0% hides the resource bar; setting it to 100% hides the bar.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.units.powerBarHeight * 100, 0, 100, 1, "%"
		end,
		function(v)
			Entropy.db.units.powerBarHeight = v / 100
			Entropy:updateAll()
		end
	)
	menu.height:SetPoint("TOPRIGHT", -5, -5)
	local colorList = {
		"MANA",
		"RAGE",
		"FOCUS",
		"ENERGY",
		"RUNIC_POWER",
		"LUNAR_POWER",
		"INSANITY",
		"FURY",
		"PAIN",
		"MAELSTROM"
	}

	menu.reset =
		LBO:CreateWidget(
		"Button",
		parent,
		"Reset Color",
		"Returns the set color to the default value.",
		nil,
		nil,
		true,
		function()
			for _, color in pairs(colorList) do
				Entropy.db.colors[color][1], Entropy.db.colors[color][2], Entropy.db.colors[color][3] = PowerBarColor[color].r, PowerBarColor[color].g, PowerBarColor[color].b
			end
			Entropy:updateAll()
			LBO:Refresh(parent)
		end
	)
	menu.reset:SetPoint("TOP", menu.pos, "BOTTOM", 0, -5)
	local function getColor(color)
		return Entropy.db.colors[color][1], Entropy.db.colors[color][2], Entropy.db.colors[color][3]
	end
	local function setColor(r, g, b, color)
		Entropy.db.colors[color][1], Entropy.db.colors[color][2], Entropy.db.colors[color][3] = r, g, b
		Entropy:updateAll()
	end
	for i, color in ipairs(colorList) do
		menu["color" .. i] =
			LBO:CreateWidget("ColorPicker", parent, _G[color], _G[color] .. "", nil, nil, true, getColor, setColor, color)
		if i == 1 then
			menu["color" .. i]:SetPoint("TOP", menu.reset, "BOTTOM", 0, 15)
		elseif i == 2 then
			menu["color" .. i]:SetPoint("TOP", menu.color1, 0, 0)
			menu["color" .. i]:SetPoint("RIGHT", -5, 0)
		else
			menu["color" .. i]:SetPoint("TOP", menu["color" .. (i - 2)], "BOTTOM", 0, 14)
		end
	end
end

function Option:CreateNameMenu(menu, parent)
	menu.file =
		LBO:CreateWidget(
		"Font",
		parent,
		"Font settings",
		"Change the font.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.font.file, Entropy.db.font.size, Entropy.db.font.attribute, Entropy.db.font.shadow
		end,
		function(file, size, attribute, shadow)
			Entropy.db.font.file, Entropy.db.font.size, Entropy.db.font.attribute, Entropy.db.font.shadow = file, size, attribute, shadow
			Entropy:updateAll()
		end
	)
	menu.file:SetPoint("TOPLEFT", 5, -5)
	menu.classColor =
		LBO:CreateWidget(
		"CheckBox",
		parent,
		"Color by class",
		"Displays the name in the class color.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.units.className
		end,
		function(v)
			Entropy.db.units.className = v
			Entropy:updateAll()
			LBO:Refresh(parent)
		end
	)
	menu.classColor:SetPoint("TOP", menu.file, "BOTTOM", 0, -5)
	menu.roleIconVisibility =
		LBO:CreateWidget(
		"CheckBox",
		parent,
		"Hide RoleIcon",
		"",
		nil,
		nil,
		true,
		function()
			return Entropy.db.units.roleIcon
		end,
		function(v)
			Entropy.db.units.roleIcon = v
			Entropy:updateAll()
			LBO:Refresh(parent)
		end
	)
	menu.roleIconVisibility:SetPoint("TOP", menu.classColor, "BOTTOM", 0, -10)
	menu.color =
		LBO:CreateWidget(
		"ColorPicker",
		parent,
		"name color",
		"Sets the name color. Does not apply when using color by class.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.colors.name[1], Entropy.db.colors.name[2], Entropy.db.colors.name[3]
		end,
		function(r, g, b)
			Entropy.db.colors.name[1], Entropy.db.colors.name[2], Entropy.db.colors.name[3] = r, g, b
			Entropy:updateAll()
		end
	)
	menu.color:SetPoint("TOPRIGHT", -5, -60)
	menu.trimServer =
		LBO:CreateWidget(
		"CheckBox",
		parent,
		"Trim server",
		"Trims server.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.units.trimServer
		end,
		function(v)
			Entropy.db.units.trimServer = v
			Entropy:updateAll()
		end
	)
	menu.trimServer:SetPoint("TOP", menu.roleIconVisibility, "BOTTOM", 0, -5)
end

function Option:CreatePartyTagMenu(menu, parent)
	menu.use =
		LBO:CreateWidget(
		"CheckBox",
		parent,
		"Hide the Group #s",
		"Toggles Visibility of the Group # of the raid Group.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.hideGroupTitle
		end,
		function(v)
			Entropy.db.hideGroupTitle = v
			Entropy:updateAll()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
end

function Option:CreateBorderMenu(menu, parent)
	menu.use =
		LBO:CreateWidget(
		"CheckBox",
		parent,
		"View background border",
		"View the border surrounding the entire raid frames.",
		nil,
		nil,
		true,
		function()
			return Entropy.db.border
		end,
		function(v)
			Entropy.db.border = v
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	local function disable()
		return not Entropy.db.border
	end
	menu.reset =
		LBO:CreateWidget(
		"Button",
		parent,
		"Reset color",
		"Returns the set color to the default value.",
		nil,
		disable,
		true,
		function()
			Entropy.db.borderBackdrop[1], Entropy.db.borderBackdrop[2], Entropy.db.borderBackdrop[3], Entropy.db.borderBackdrop[4] = 0, 0, 0, 0
			Entropy.db.borderBackdropBorder[1], Entropy.db.borderBackdropBorder[2], Entropy.db.borderBackdropBorder[3], Entropy.db.borderBackdropBorder[4] = 0.58, 0.58, 0.58, 1
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.reset:SetPoint("TOPRIGHT", -5, 5)
	menu.backdrop =
		LBO:CreateWidget(
		"ColorPicker",
		parent,
		"Inner Border Color",
		"Adjust the color and transparency of the inner border of the raid frame.",
		nil,
		disable,
		true,
		function()
			return Entropy.db.borderBackdrop[1], Entropy.db.borderBackdrop[2], Entropy.db.borderBackdrop[3], Entropy.db.borderBackdrop[4]
		end,
		function(r, g, b, a)
			Entropy.db.borderBackdrop[1], Entropy.db.borderBackdrop[2], Entropy.db.borderBackdrop[3], Entropy.db.borderBackdrop[4] = r, g, b, a
			Entropy:updateAll()
		end
	)
	menu.backdrop:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)
	menu.border =
		LBO:CreateWidget(
		"ColorPicker",
		parent,
		"Border color",
		"Sets the color and transparency of the border surrounding the entire raid frames.",
		nil,
		disable,
		true,
		function()
			return Entropy.db.borderBackdropBorder[1], Entropy.db.borderBackdropBorder[2], Entropy.db.borderBackdropBorder[3], Entropy.db.borderBackdropBorder[4]
		end,
		function(r, g, b, a)
			Entropy.db.borderBackdropBorder[1], Entropy.db.borderBackdropBorder[2], Entropy.db.borderBackdropBorder[3], Entropy.db.borderBackdropBorder[4] = r, g, b, a
			Entropy:updateAll()
		end
	)
	menu.border:SetPoint("TOP", menu.reset, "BOTTOM", 0, 0)
end

function Option:CreateDebuffColorMenu(menu, parent)
	menu.reset =
		LBO:CreateWidget(
		"Button",
		parent,
		"Reset color",
		"Returns the set color to the default value.",
		nil,
		nil,
		true,
		function()
			Entropy.db.colors.Magic[1], Entropy.db.colors.Magic[2], Entropy.db.colors.Magic[3] = DebuffTypeColor.Magic.r, DebuffTypeColor.Magic.g, DebuffTypeColor.Magic.b
			Entropy.db.colors.Curse[1], Entropy.db.colors.Curse[2], Entropy.db.colors.Curse[3] = DebuffTypeColor.Curse.r, DebuffTypeColor.Curse.g, DebuffTypeColor.Curse.b
			Entropy.db.colors.Disease[1], Entropy.db.colors.Disease[2], Entropy.db.colors.Disease[3] = DebuffTypeColor.Disease.r, DebuffTypeColor.Disease.g, DebuffTypeColor.Disease.b
			Entropy.db.colors.Poison[1], Entropy.db.colors.Poison[2], Entropy.db.colors.Poison[3] = DebuffTypeColor.Poison.r, DebuffTypeColor.Poison.g, DebuffTypeColor.Poison.b
			Entropy.db.colors.none[1], Entropy.db.colors.none[2], Entropy.db.colors.none[3] = DebuffTypeColor.none.r, DebuffTypeColor.none.g, DebuffTypeColor.none.b
			LBO:Refresh(parent)
			Entropy:updateAll()
		end
	)
	menu.reset:SetPoint("TOPLEFT", 5, 2)
	local function getColor(color)
		return Entropy.db.colors[color][1], Entropy.db.colors[color][2], Entropy.db.colors[color][3]
	end
	local function setColor(r, g, b, color)
		Entropy.db.colors[color][1], Entropy.db.colors[color][2], Entropy.db.colors[color][3] = r, g, b
		Entropy:updateAll()
	end
	local colorList = {"Magic", "Curse", "Disease", "Poison", "none"}
	for i, color in ipairs(colorList) do
		menu["color" .. i] =
			LBO:CreateWidget(
			"ColorPicker",
			parent,
			colorList[i],
			colorList[i] .. "Change the color of the debuff.",
			nil,
			nil,
			true,
			getColor,
			setColor,
			color
		)
		if i == 1 then
			menu["color" .. i]:SetPoint("TOP", menu.reset, "BOTTOM", 0, 15)
		elseif i == 2 then
			menu["color" .. i]:SetPoint("TOP", menu.color1, 0, 0)
			menu["color" .. i]:SetPoint("RIGHT", -5, 0)
		else
			menu["color" .. i]:SetPoint("TOP", menu["color" .. (i - 2)], "BOTTOM", 0, 14)
		end
	end
end
