local entropy = _G[...]
local wipe = _G.table.wipe
local LBDB = LibStub("LibLimeDB-1.1")
local version = 4

entropy.classes = { "WARRIOR", "DRUID", "PALADIN", "DEATHKNIGHT", "PRIEST", "SHAMAN", "ROGUE", "MAGE", "WARLOCK", "HUNTER", "MONK", "DEMONHUNTER" }
local function newTable() return {} end
local defaultProfile = "Default"
local colorWhite = { 1, 1, 1 }
local colorRed = { 1, 0, 0 }
local colorGreen = { 0, 1, 0 }
local colorYellow = { 1, 1, 0 }

-- Default CVars
local default = {
	anchor = "TOPLEFT", dir = 1, width = 80, height = 50, offset = 1, highlightAlpha = 0.5,
	border = true, borderBackdrop = { 0, 0, 0, 0 }, borderBackdropBorder = { 0.58, 0.58, 0.58, 1 },
	partyTag = true, partyTagParty = { 0.7, 0.28, 0.28, 0.8 }, partyTagRaid = { 0, 0, 0, 0.8 },
	groupby = "GROUP",	-- GROUP:파티별 CLASS:직업별
	sortName = false,
	column = 8,
	managerPos = 25,
	units = {
		displayPowerBar = true, powerBarHeight = 0.10,
		displayHealPrediction = true, healPredictionAlpha = 0.35, myHealPredictionColor = colorGreen, otherHealPredictionColor = colorYellow, absorbPredictionColor = { 0, 0.7, 1 },
		hidemyHealPrediction = false, hidemyHealAbsorb = false, hideotherHealPrediction = false, hidetotalAbsorb = false, hideoverAbsorbGlow = false, hideoverHealAbsorbGlow = false,
		displayRaidRoleIcon = true, roleIconPos = "TOPLEFT", roleIconSize = 12, centerStatusIcon = true, roleIcontype = 0,
		useRaidIcon = true, raidIconPos = "TOPLEFT", raidIconSize = 12, raidIconSelf = true, raidIconTarget = false, raidIconFilter = { true, true, true, true, true, true, true, true },
		useClassColors = true, className = false, outRangeName = true, offlineName = true, deathName = true,
		useBossAura = true, bossAuraSize = 18, bossAuraPos = "CENTER", bossAuraAlpha = 0.75, bossAuraTimer = true,
		bossAuraOpt = 1,	-- 1:남은 시간 2:경과 시간 0:시간 표시 안함
		fadeOutOfRangeHealth = true, fadeOutOfRangePower = true, fadeOutAlpha = 0.35, fadeOutColorFlag = false, fadeOutColor = { 0.2, 0.2, 0.2 },
		useCustomFadeAlpha = false, outOfRangeAlpha = 0.55,	inRangeAlpha = 1,	outOfRangeBgAlpha = 1,	inRangeBgAlpha = 1,
		texture = "Smooth",
		backgroundtexture = "Smooth",
		tooltip = 2,		-- 1:항상 2:비전투중에만 3:전투중에만 0:표시안함
		healthRange = 1,	-- 1:항상 2:사정거리 안 3:사정거리 밖
		healthType = 0,	-- 1:손실생명력 2:손실생명력% 3:남은생명력 4:남은생명력% 0:표시안함
		nameEndl = false, shortLostHealth = false, healthRed = false, showAbsorbHealth = false, 
		useCastingBar = true, castingBarColor = { 0.2, 0.8, 0.2 }, castingBarHeight = 3, castingBarPos = 2, -- 1:TOP 2:BOTTOM 3:LEFT 4:RIGHT
		usePowerBarAlt = true, powerBarAltHeight = 3, powerBarAltPos = 1, -- 1:TOP 2:BOTTOM 3:LEFT 4:RIGHT
		useResurrectionBar = true, resurrectionBarColor = { 0, 0.75, 1 },
		dispelSound = "None", dispelSoundDelay = 5, useHarm = true,
		outline = {
			type = 1,	-- 1:해제 가능한 디버프 2:대상 3:마우스 오버 4:체력 낮음 5:어그로 6:전술목표 아이콘 0:사용 안함
			scale = 0.75 , alpha = 1,
			lowHealth = 0.7, lowHealthColor = colorRed,
			lowHealth2 = 10000, lowHealthColor2 = colorRed,
			raidIcon = { true, true, true, true, true, true, true, true }, raidIconColor = colorWhite,
			targetColor = colorYellow, mouseoverColor = colorYellow, aggroColor = colorRed,
		},
		targetColor = colorYellow, mouseoverColor = colorYellow, aggroColor = colorRed,
		debuffIcon = 5, debuffIconSize = 10, debuffIconPos = "TOPRIGHT", debuffIconType = 1,	-- 1:Icon+Color 2:Icon 3:Color
		debuffIconFilter = { Magic = true, Curse = true, Disease = true, Poison = true, none = true },
		buffIconSize = 11, buffIconPos = "LEFT",
		useAggroArrow = true, aggroType = 1, -- 1:사용 안함 2:항상 3:파티/공격대 4:공격대
		aggroGain = "None", aggroLost = "None",
		useDispelColor = false,
		useLeaderIcon=false, leaderIconSize=12, leaderIconPos = "TOPLEFT",
	},
	font = {
		file = "Friz Quadrata TT", size = 12, attribute = "", shadow = true,
	},
	colors = {
		name = { 1, 1, 1 },
		help = colorGreen,
		harm = { 0.5, 0, 0 },
		vehicle = { 0, 0.4, 0 },
		offline = { 0.25, 0.25, 0.25 },
		dead = { 0.5, 0.5, 0.5 },
		background = { 1, 1, 1 }, -- 0.10, 0.10, 0.10, 0.55
		highlight = colorRed,
		WARRIOR = { RAID_CLASS_COLORS.WARRIOR.r, RAID_CLASS_COLORS.WARRIOR.g, RAID_CLASS_COLORS.WARRIOR.b },
		PRIEST = { RAID_CLASS_COLORS.PRIEST.r, RAID_CLASS_COLORS.PRIEST.g, RAID_CLASS_COLORS.PRIEST.b },
		ROGUE = { RAID_CLASS_COLORS.ROGUE.r, RAID_CLASS_COLORS.ROGUE.g, RAID_CLASS_COLORS.ROGUE.b },
		MAGE = { RAID_CLASS_COLORS.MAGE.r, RAID_CLASS_COLORS.MAGE.g, RAID_CLASS_COLORS.MAGE.b },
		WARLOCK = { RAID_CLASS_COLORS.WARLOCK.r, RAID_CLASS_COLORS.WARLOCK.g, RAID_CLASS_COLORS.WARLOCK.b },
		HUNTER = { RAID_CLASS_COLORS.HUNTER.r, RAID_CLASS_COLORS.HUNTER.g, RAID_CLASS_COLORS.HUNTER.b },
		DRUID = { RAID_CLASS_COLORS.DRUID.r, RAID_CLASS_COLORS.DRUID.g, RAID_CLASS_COLORS.DRUID.b },
		SHAMAN = { RAID_CLASS_COLORS.SHAMAN.r, RAID_CLASS_COLORS.SHAMAN.g, RAID_CLASS_COLORS.SHAMAN.b },
		PALADIN = { RAID_CLASS_COLORS.PALADIN.r, RAID_CLASS_COLORS.PALADIN.g, RAID_CLASS_COLORS.PALADIN.b },
		DEATHKNIGHT = { RAID_CLASS_COLORS.DEATHKNIGHT.r, RAID_CLASS_COLORS.DEATHKNIGHT.g, RAID_CLASS_COLORS.DEATHKNIGHT.b },
		MONK = { RAID_CLASS_COLORS.MONK.r, RAID_CLASS_COLORS.MONK.g, RAID_CLASS_COLORS.MONK.b },
		DEMONHUNTER = { RAID_CLASS_COLORS.DEMONHUNTER.r, RAID_CLASS_COLORS.DEMONHUNTER.g, RAID_CLASS_COLORS.DEMONHUNTER.b },
		--- Character Resources
		MANA = { PowerBarColor.MANA.r, PowerBarColor.MANA.g, PowerBarColor.MANA.b },
		RAGE = { PowerBarColor.RAGE.r, PowerBarColor.RAGE.g, PowerBarColor.RAGE.b },
		FOCUS = { PowerBarColor.FOCUS.r, PowerBarColor.FOCUS.g, PowerBarColor.FOCUS.b },
		ENERGY = { PowerBarColor.ENERGY.r, PowerBarColor.ENERGY.g, PowerBarColor.ENERGY.b },
		RUNIC_POWER = { PowerBarColor.RUNIC_POWER.r, PowerBarColor.RUNIC_POWER.g, PowerBarColor.RUNIC_POWER.b },
		LUNAR_POWER = { PowerBarColor.LUNAR_POWER.r, PowerBarColor.LUNAR_POWER.g, PowerBarColor.LUNAR_POWER.b }, --- Balance Druid
		INSANITY = { PowerBarColor.INSANITY.r, PowerBarColor.INSANITY.g, PowerBarColor.INSANITY.b }, ---Shadow Priest
		FURY = { PowerBarColor.FURY.r, PowerBarColor.FURY.g, PowerBarColor.FURY.b }, --- Demon Hunter
		PAIN = { PowerBarColor.PAIN.r, PowerBarColor.PAIN.g, PowerBarColor.PAIN.b }, --- Demon Hunter
		MAELSTROM = { PowerBarColor.MAELSTROM.r, PowerBarColor.MAELSTROM.g, PowerBarColor.MAELSTROM.b }, --- Enhancement Shaman
		--- Debuff/buffs color
		Magic = { DebuffTypeColor.Magic.r, DebuffTypeColor.Magic.g, DebuffTypeColor.Magic.b },
		Curse = { DebuffTypeColor.Curse.r, DebuffTypeColor.Curse.g, DebuffTypeColor.Curse.b },
		Disease = { DebuffTypeColor.Disease.r, DebuffTypeColor.Disease.g, DebuffTypeColor.Disease.b },
		Poison = { DebuffTypeColor.Poison.r, DebuffTypeColor.Poison.g, DebuffTypeColor.Poison.b },
		none = { DebuffTypeColor.none.r, DebuffTypeColor.none.g, DebuffTypeColor.none.b },
	},
	ignoreAura = {}, userAura = {},
}

Entropy.ignoreAura = {
	[6788] = true, [8326] = true, [11196] = true, [15822] = true, [21163] = true,
	[24360] = true, [24755] = true, [25771] = true, [26004] = true, [26013] = true,
	[26680] = true, [28169] = true, [28504] = true, [29232] = true, [30108] = true,
	[30529] = true, [36032] = true, [36893] = true, [36900] = true, [36901] = true,
	[40880] = true, [40882] = true, [40883] = true, [40891] = true, [40896] = true,
	[40897] = true, [41292] = true, [41337] = true, [41350] = true, [41425] = true,
	[43681] = true, [55711] = true, [57723] = true, [57724] = true, [64805] = true,
	[64808] = true, [64809] = true, [64810] = true, [64811] = true, [64812] = true,
	[64813] = true, [64814] = true, [64815] = true, [64816] = true, [69127] = true,
	[69438] = true, [70402] = true, [71328] = true, [72144] = true, [72145] = true,
	[80354] = true, [89798] = true, [96328] = true, [96325] = true,
	[96326] = true, [95809] = true, [36895] = true, [71041] = true, [122835] = true,
	[173660] = true, [173649] = true, [173657] = true, [173658] = true, [173976] = true,
	[173661] = true, [174524] = true, [173659] = true,
	[160455] = true, -- Fatigued
	[206151] = true,	[234143] = true,	[264689] = true, [546] = true,
	[157504] = true, --Cloudburst Totem
	[192082] = true, --Wind Rush
	["Recharging"] = true,["Drained Soul"] = true,["Arcane Vulnerability"] = true,["Darkest Depths"] = true,
	["Undulating Tides"] = true,["Demonic Gateway"] = true,["Sanitizing Strike"] = true,
	["Shatter"] = true,["Evolving Affliction"] = true,["Rupturing Blood"] = true,["Essence Shear"] = true,
	["Heartstopper Venom"] = true,["Azerite Energy"] = true,["Azerite Residue"] = true,
	["Dark Bargain"] = true,["Shadow Mend"] = true,["Immunosuppression"] = true,["Creator's Grace"] = true,
	["Lunar Suffusion"] = true,["Removed from the Circle"] = true,["Lunar Suffision"] = true,["Gaze of Aman'thul"] = true,
	["AUGH"] = true,["Imperfect Physiology"] = true,["Strength of the Sky"] = true,
	["Lingering Wail"] = true,["Quel'Delar's Compulsion"] = true,["Bursting Boil"] = true,["The Light Saves"] = true,
	["Curse of the Dreadblades"] = true,["Torment of Fel"] = true,["Empowered Flame Rend"] = true,["Unbreakable Will"] = true,
	["Umbral Suffision"] = true,["Aegisjalmur"] = true,["the Armguard of Awe"] = true,["Lingering Mischief"] = true,
	["Demonic Gateway"] = true,["Orb of Frost"] = true,
	["Archbishop Benedictus' Restitution"] = true,
	["Cheated Death"] = true,["Speed: Slow"] = true,["Surrendered Soul"] = true,
	["Transporter Malfunction"] = true,["Umbra Suffusion"] = true,["Sense of Dread"] = true,["Sands of Time"] = true,
	["Torment of Flames"] = true,["Light Infusion"] = true,["Banished in Time"] = true,["Lingering Infection"] = true,
	["Speed: Normal"] = true,["Putrid Blood"] = true,["Astral Vulnerability"] = true,["Sin'dorei Spite"] = true,
	["Torment of Frost"] = true,["Lord of Flames"] = true,["Lured"] = true,["Nightwell Energy"] = true,
	["ablative shielding"] = true,["Demon's Vigor"] = true,["Moonfeather Fever"] = true,["Fel Heart Bond Frayed"] = true,
	["Fel Infusion"] = true,["Oozeling's Disgusting Aura"] = true,["Cauterized"] = true,
	["Warlord's Exhaustion"] = true,["Slippery"] = true,
	["Speed: Fast"] = true,["Uncontained Fel"] = true,["Gaze of Aman'Thul"] = true,
	["Celerity Zone"] = true,["Masquerade"] = true,["Annihilation"] = true,["Strength of the Sea"] = true,
	["Void-Touched"] = true,["Number One Fan"] = true,["Illusionary Night"] = true,["Torment of Shadows"] = true,
	["Evolving Affliction"] = true,["Dark Purpose"] = true,["Unclean Contagion"] = true,
	["Xalzaix's Gaze"] = true,["Heartbroken"] = true,["Diamond of the Unshakeable Protector"] = true,
	["Opal of Unleashed Rage"] = true,["Topaz of Brilliant Sunlight"] = true,["Unleashed Rage"] = true,
	["Tailwind Sapphire"] = true,["Incandescence"] = true,["Amethyst of the Shadow King"] = true,
	["Ruby of Focused Animus"] = true,["Emerald of Earthen Roots"] = true,["Earthen Roots"] = true,
	["Depleted Diamond"] = true,["Thief's Bane"] = true,["Grossly Incandescent!"] = true,
	["Brilliant Aura"] = true,["Soothing Breeze"] = true,["Dark Knowledge"] = true,["Tailwinds"] = true,
	["Howling Winds"] = true,["Aphotic Blast"] = true,["Shear Mind"] = true,["Dark Herald"] = true,
	["Disturbingly Divine Presence"] = true,["Disgusting Mucus"] = true,["Phantom Pain"] = true,
	["Recalibrating"] = true,["Frost Mark"] = true,["Toxic Brand"] = true,["Frozen Blood"] = true,["Venomous Blood"] = true,
}

function entropy:InitDB()
	self.InitDB = nil
	if not EntropyDB or not EntropyDB.version or EntropyDB.version ~= version then
		EntropyDB = {
			version = version,
			profileKeys = {},
			profiles = {},
			minimapButton = { hide = false, radius = 80, angle = 19, dragable = true, rounding = 10 },
		}
		entropy:Message("An error occurred in the user environment setting, and the user environment was set as the default value.")
	end

	for name, key in pairs(EntropyDB.profileKeys) do
		if not(type(name) == "string" and type(key) == "string" and EntropyDB.profiles[key]) then
			EntropyDB.profileKeys[name] = nil
		end
	end

	for _, db in pairs(EntropyDB.profiles) do
		LBDB:UnregisterDB(db, default)
		if db.ignoreAura then
			for aura in pairs(self.ignoreAura) do
				if db.ignoreAura[aura] then
					db.ignoreAura[aura] = nil
				end
			end
			for aura, v in pairs(db.ignoreAura) do
				if v == false and not self.ignoreAura[aura] then
					db.ignoreAura[aura] = nil
				end
			end
		end
		if db.userAura then
			for aura in pairs(self.bossAura) do
				if db.userAura[aura] then
					db.userAura[aura] = nil
				end
			end
		end
	end
	self.profileName = UnitName("player").." - "..GetRealmName()
	self:SetProfile(EntropyDB.profileKeys[self.profileName])
end

function entropy:SetProfile(profile)
	profile = profile or defaultProfile
	if type(profile) == "string" and profile ~= self.dbName then
		if self.dbName and EntropyDB.profiles[self.dbName] then
			LBDB:UnregisterDB(EntropyDB.profiles[self.dbName])
		end
		if profile == defaultProfile then
			EntropyDB.profileKeys[self.profileName] = nil
		else
			EntropyDB.profileKeys[self.profileName] = profile
		end
		if not EntropyDB.profiles[profile] then
			EntropyDB.profiles[profile] = {}
		end
		self.db = LBDB:RegisterDB(EntropyDB.profiles[profile], default, newTable)
		self.dbName = profile
	end
end

function entropy:ApplyProfile()
	self.nameWidth = self.db.width - 2
	self:SetAttribute("ready", nil)
	self:SetAttribute("startupdate", nil)
	self:SetAttribute("ready", true)
end
