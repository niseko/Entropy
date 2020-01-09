local MAJOR_VERSION, MINOR_VERSION = "LibLimeDispel-1.0", 24

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _G = _G
local type = _G.type
local next = _G.next
local select = _G.select
local pairs = _G.pairs
local wipe = _G.table.wipe
local IsSpellKnown = _G.IsSpellKnown
local UnitDebuff = _G.UnitDebuff
local UnitCanAttack = _G.UnitCanAttack
local UnitCanAssist = _G.UnitCanAssist

local scanDispel
local class = select(2, UnitClass("player"))

lib.Callbacks = lib.Callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.blankfunc = lib.blankfunc or function() return nil end
lib.help = lib.help or {}
lib.enrageSpells = lib.enrageSpells or {}
wipe(lib.enrageSpells)
--lib.enrageSpells[134] = true

if class == "WARRIOR" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
	end
elseif class == "ROGUE" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
	end
elseif class == "PRIEST" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = IsSpellKnown(528) and true or nil
		wipe(lib.help)
		lib.help.Magic = IsSpellKnown(527) and true or nil
		lib.help.Disease = lib.help.Magic
	end
elseif class == "MAGE" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = IsSpellKnown(30449) and true or nil
		lib.help.Curse = IsSpellKnown(475) and true or nil
		wipe(lib.help)
	end
elseif class == "WARLOCK" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = (IsSpellKnown(89808) or IsSpellKnown(115276)) and true or nil
		wipe(lib.help)
	end
elseif class == "HUNTER" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
	end
elseif class == "DRUID" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
		lib.help.Curse = (IsSpellKnown(2782) or IsSpellKnown(88423)) and true or nil
		lib.help.Poison = lib.help.Curse
		lib.help.Magic = IsSpellKnown(88423) and true or nil
	end
elseif class == "SHAMAN" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = IsSpellKnown(370) and true or nil
		wipe(lib.help)
		lib.help.Curse = (IsSpellKnown(51886) or IsSpellKnown(77130)) and true or nil
		lib.help.Magic = IsSpellKnown(77130) and true or nil
	end
elseif class == "PALADIN" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
		lib.help.Poison = (IsSpellKnown(213644) or IsSpellKnown(4987)) and true or nil
		lib.help.Disease = lib.help.Poison
		lib.help.Magic = IsSpellKnown(4987) and true or nil
	end
elseif class == "MONK" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		lib.help.Poison = (IsSpellKnown(218164) or IsSpellKnown(115450)) and true or nil
		lib.help.Disease = lib.help.Poison
		lib.help.Magic = IsSpellKnown(115450) and true or nil
	end
elseif class == "DEMONHUNTER" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
	end
else
	lib.Dispel = lib.blankfunc
	lib.DispelHelp = lib.blankfunc
	lib.DispelHarm = lib.blankfunc
	lib.CheckHarmDispel = lib.blankfunc
	lib.CheckHelpDispel = lib.blankfunc
	lib.IsDispelable = lib.blankfunc
	if lib.frame then
		lib.frame:UnregisterAllEvents()
		lib.frame:SetScript("OnEvent", nil)
	end
	if lib.tranquilize or lib.harm or next(lib.help) then
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
		lib.Callbacks:Fire("Update")
	end
	return
end

function lib:CheckHarmDispel(aura, spell)
	return (lib.harm and aura == "Magic") or (lib.tranquilize and lib.enrageSpells[spell])
end

function lib:CheckHelpDispel(aura)
	return lib.help[aura]
end

function lib:IsDispelable(unit, index)
	if UnitCanAttack("player", unit) then
		local auraType, _, _, _, _, _, auraID = select(4, UnitBuff(unit, index))
		return lib:CheckHarmDispel(auraType, auraID)
	elseif UnitCanAssist("player", unit) then
		return lib:CheckHelpDispel(select(4, UnitDebuff(unit, index)) or nil)
	end
	return nil
end

function lib:DispelHelp(unit, usablefunc)
	if next(lib.help) then
		for i = 1, 40 do
			local name, _, _, auraType, _, _, _, _, _, spellId = UnitDebuff(unit, i)
			if name then
				if lib:CheckHelpDispel(auraType) then
					if type(usablefunc) == "function" then
						if usablefunc(name, spellId) then
							return UnitDebuff(unit, i)
						end
					elseif type(usablefunc) == "table" then
						if not usablefunc[name] and not usablefunc[auraID] then
							return UnitDebuff(unit, i)
						end
					else
						return UnitDebuff(unit, i)
					end
				end
			else
				break
			end
		end
	end
	return nil
end

function lib:DispelHarm(unit, usablefunc)
	if lib.harm or lib.tranquilize then
		for i = 1, 40 do
			local name, _, _, auraType, _, _, _, _, _, auraID = UnitBuff(unit, i)
			if name then
				if lib:CheckHarmDispel(auraType, auraID) then
					if type(usablefunc) == "function" then
						if usablefunc(name) then
							return UnitBuff(unit, i)
						end
					elseif type(usablefunc) == "table" then
						if not usablefunc[name] and not usablefunc[auraID] then
							return UnitBuff(unit, i)
						end
					else
						return UnitBuff(unit, i)
					end
				end
			else
				break
			end
		end
	end
	return nil
end

function lib:Dispel(unit, usablefunc)
	if UnitCanAttack("player", unit) then
		return lib:DispelHarm(unit, usablefunc)
	elseif UnitCanAssist("player", unit) then
		return lib:DispelHelp(unit, usablefunc)
	else
		return nil
	end
end

local p_help, p_tranquilize, p_harm = {}

lib.frame = lib.frame or CreateFrame("Frame")
lib.frame:UnregisterAllEvents()
lib.frame:RegisterEvent("PLAYER_LOGIN")
lib.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
lib.frame:RegisterEvent("PLAYER_TALENT_UPDATE")
lib.frame:RegisterEvent("SPELLS_CHANGED")
lib.frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
lib.frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
lib.frame:SetScript("OnEvent", function()
	p_tranquilize = lib.tranquilize
	p_harm = lib.harm
	wipe(p_help)
	for p in pairs(lib.help) do
		p_help[p] = true
	end
	scanDispel()
	if lib.tranquilize ~= p_tranquilize or p_harm ~= lib.harm then
		return lib.Callbacks:Fire("Update")
	end
	for p in pairs(DebuffTypeSymbol) do
		if lib.help[p] ~= p_help[p] then
			return lib.Callbacks:Fire("Update")
		end
	end
end)
if IsLoggedIn() then
	lib.frame:GetScript("OnEvent")(lib.frame)
end