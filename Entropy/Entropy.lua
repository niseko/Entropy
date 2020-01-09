local _G = _G
--local type = _G.type
local pairs = _G.pairs
--local unpack = _G.unpack
--local GetSpellInfo = _G.GetSpellInfo
--local LBDB = LibStub("LibLimeDB-1.1")
--local LibGetFrame = LibStub("LibGetFrame-1.0")
local SM = LibStub("LibSharedMedia-3.0")

local group = {
	part = true, -- party, only check char 1 to 4
	raid = true,
}
-- 코어 프레임 설정
Entropy = CreateFrame("Frame", ..., UIParent, "SecureHandlerAttributeTemplate")
Entropy:SetScript(
	"OnEvent",
	function(self, event, ...)
		self[event](self, ...)
	end
)
Entropy:RegisterEvent("PLAYER_LOGIN")

-- 로그인 시 기본 이벤트 처리
function Entropy:PLAYER_LOGIN()
	self.PLAYER_LOGIN = nil
	if not Entropy.db then
		self:InitDB()
	end
	self.version = GetAddOnMetadata(self:GetName(), "Version")
	self:ApplyProfile()

	--- Broker library
	local LDB =
		LibStub("LibDataBroker-1.1"):NewDataObject("Entropy",	{
		type = "data source",
		text = "",
		icon = "Interface\\AddOns\\Entropy\\Shared\\Texture\\cluster2.tga",
		OnClick = function(_, button)	Entropy:OnClick(button) end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then
				return
			end
			Entropy:OnTooltip(tooltip)
		end,
		OnLeave = GameTooltip_Hide
	})

	-- Map icon library
	local entropy_mapicon = LibStub("LibDBIcon-1.0")
	entropy_mapicon:Register("Entropy", LDB, EntropyDB.minimapButton)
	if EntropyDB.minimapButton.hide then
		entropy_mapicon:Hide("Entropy")
	else
		entropy_mapicon:Show("Entropy")
	end
	if EntropyDB.minimapButton.dragable then
		entropy_mapicon:Unlock("Entropy")
	else
		entropy_mapicon:Lock("Entropy")
	end

	CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider:Hide()
	CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider:Hide()
end

function Entropy:OnClick(button)
	if button == "RightButton" then
		--L_ToggleDropDownMenu(1, nil, Entropy.mapButtonMenu, "cursor")
	elseif InterfaceOptionsFrame:IsShown() and InterfaceOptionsFramePanelContainer.displayedPanel == Entropy.optionFrame then
		InterfaceOptionsFrame_Show()
	else
		InterfaceOptionsFrame_Show()
		InterfaceOptionsFrame_OpenToCategory(Entropy.optionFrame)
	end
end

function Entropy:OnTooltip(tooltip)
	tooltip = tooltip or GameTooltip
	tooltip:AddLine("Entropy".." "..Entropy.version)
end

-- Global message output function
function Entropy:Message(msg)
	ChatFrame1:AddMessage("|cffa2e665<Entropy> |r" .. msg, 1, 1, 1)
end

-- Global object initialization logic
local clearObjectFuncs = {}

function Entropy:RegisterClearObject(func)
	clearObjectFuncs[func] = true
end

function Entropy:CallbackClearObject(object)
	for func in pairs(clearObjectFuncs) do
		func(object)
	end
end

-- Preferences frame initial setting
Entropy.optionFrame = CreateFrame("Frame", Entropy:GetName() .. "OptionFrame", InterfaceOptionsFramePanelContainer)
Entropy.optionFrame:Hide()
Entropy.optionFrame.name = "E|cffD5C280n|r|cffCCAD3Dt|r|cff958859r|r|cff806C26o|r|cffCCBA7Ap|r|cff4D4117y|r"
Entropy.optionFrame.addon = Entropy:GetName()
Entropy.optionFrame:SetScript(
	"OnShow",
	function(self)
		if InCombatLockdown() then -- Lock during combat
			if not self.title then
				self.title = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
				self.title:SetText(self.name)
				self.title:SetPoint("TOPLEFT", 8, -12)
				self.version = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				self.version:SetText(Entropy.version)
				self.version:SetPoint("LEFT", self.title, "RIGHT", 2, 0)
				self.combatWarn = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
				self.combatWarn:SetText("You can't change preferences during combat.")
				self.combatWarn:SetPoint("CENTER", 0, 0)
			end
			if not self:IsEventRegistered("PLAYER_REGEN_ENABLED") then
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else -- Load Options
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			self:SetScript("OnEvent", nil)
			self:SetScript("OnShow", nil)
			LoadAddOn(self.addon .. "_Option")
		end
	end
)
Entropy.optionFrame:SetScript(
	"OnEvent",
	function(self, event, arg)
		if event == "PLAYER_REGEN_ENABLED" then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			if self:IsVisible() and not self.loaded and self:GetScript("OnShow") then
				self:GetScript("OnShow")(self)
			end
		end
	end
)
InterfaceOptions_AddCategory(Entropy.optionFrame)

-- Slash Command
SLASH_entropy1 = "/ent"
SLASH_entropy2 = "/ya"
SLASH_entropy3 = "/entropy"

-- Slash Command Script
local function handler(msg)
	local command, arg1 = strsplit(" ", msg)
	if command == "h" or command == "help" then
		Entropy:Message(
			"Entropy Command\n|cffa2e665/entropy|r: Opens Preference for Entropy.\n|cffa2e665/entropy s [Profile name]|r: Switch to [Profile name] Profile. You can't change it while in battle.\n|cffa2e665/entropy h|r: Show list of commands."
		) -- 도움말 출력
	elseif command == "s" and arg1 then -- /entropy s sample (Correctly entered arguments to profile preferences)
		if EntropyDB.profiles[arg1] then
			if not InCombatLockdown() then -- Allow profile replacement only when not in combat
				Entropy:SetProfile(arg1)
				Entropy:ApplyProfile()
				Entropy:Message(("[|cff8080ff%s|r] profile applied to the current character."):format(arg1))
			else
				Entropy:Message("You can't change preferences during combat.")
			end
		else
			Entropy:Message(("[|cff8080ff%s|r] profile doesn't exist."):format(arg1))
		end
	elseif command == "s" then -- /entropy s (Set profile preferences but no arguments)
		Entropy:Message("Please specify a Profile name. How to use the command: /entropy [Profile name]")
	else -- Open Options
		InterfaceOptionsFrame_Show()
		InterfaceOptionsFrame_OpenToCategory(Entropy.optionFrame)
	end
end
SlashCmdList["entropy"] = handler

local function EntropyRaidGroup_UpdateLayout(frame)
	if not Entropy.db.hideGroupTitle then
		if not frame.title:IsShown() then frame.title:Show() end
		return
	end

	local totalHeight = 0
	local totalWidth = 0

	frame.title:ClearAllPoints()
	frame.title:Hide()

	if (CUF_HORIZONTAL_GROUPS) then
		local frame1 = _G[frame:GetName() .. "Member1"]
		frame1:ClearAllPoints()
		frame1:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

		for i = 2, MEMBERS_PER_RAID_GROUP do
			local unitFrame = _G[frame:GetName() .. "Member" .. i]
			unitFrame:ClearAllPoints()
			unitFrame:SetPoint("LEFT", _G[frame:GetName() .. "Member" .. (i - 1)], "RIGHT", 0, 0)
		end
		totalHeight = totalHeight + _G[frame:GetName() .. "Member1"]:GetHeight()
		totalWidth = totalWidth + _G[frame:GetName() .. "Member1"]:GetWidth() * MEMBERS_PER_RAID_GROUP
	else
		local frame1 = _G[frame:GetName() .. "Member1"]
		frame1:ClearAllPoints()
		frame1:SetPoint("TOP", frame, "TOP", 0, 0)

		for i = 2, MEMBERS_PER_RAID_GROUP do
			local unitFrame = _G[frame:GetName() .. "Member" .. i]
			unitFrame:ClearAllPoints()
			unitFrame:SetPoint("TOP", _G[frame:GetName() .. "Member" .. (i - 1)], "BOTTOM", 0, 0)
		end
		totalHeight = totalHeight + _G[frame:GetName() .. "Member1"]:GetHeight() * MEMBERS_PER_RAID_GROUP
		totalWidth = totalWidth + _G[frame:GetName() .. "Member1"]:GetWidth()
	end

	if (frame.borderFrame:IsShown()) then
		totalWidth = totalWidth + 12
		totalHeight = totalHeight + 4
	end

	frame:SetSize(totalWidth, totalHeight)
end




local function EntropyUnitFrame_UpdateName(frame)
	if not Entropy.db then Entropy:InitDB() end
	if not group[strsub(frame.displayedUnit, 1, 4)] then return end
	if not frame:IsShown() then return end

	if Entropy.db.units.trimServer then
		frame.name:SetText(frame.name:GetText():match("[^-]+"))
	end

	if Entropy.db.units.className then
		local red, green, blue = GetClassColor(select(2, UnitClass(frame.unit)))
		frame.name:SetVertexColor(red, green, blue, 1)
	else
		frame.name:SetVertexColor(Entropy.db.colors.name[1], Entropy.db.colors.name[2], Entropy.db.colors.name[3], 1)
	end
end

local highlightList = {}
local currentAuraScanTarget = nil

local function EntropyUnitFrame_UpdateHealthColor(frame)
	if not Entropy.db then
		Entropy:InitDB()
	end
	if not group[strsub(frame.displayedUnit, 1, 4)] then return end
		if not frame:IsShown() then return end

	local r, g, b
	local englishClass = select(2, UnitClass(frame.unit))
	local classColor = Entropy.db.colors[englishClass]
	if (not UnitIsConnected(frame.unit)) then
		--Color it gray
		r, g, b = Entropy.db.colors.offline[1], Entropy.db.colors.offline[2], Entropy.db.colors.offline[3]
	elseif frame.healthBar.colorOverride then
		r, g, b = Entropy.db.colors.highlight[1], Entropy.db.colors.highlight[2], Entropy.db.colors.highlight[3]
	else
		--Try to color it by class.
		if Entropy.db.units.useClassColors and classColor then
			-- Use class colors for players if class color option is turned on
			r, g, b = classColor[1], classColor[2], classColor[3]
		else
			r, g, b = Entropy.db.colors.help[1], Entropy.db.colors.help[2], Entropy.db.colors.help[3]
		end
	end

	if (r ~= frame.healthBar.r or g ~= frame.healthBar.g or b ~= frame.healthBar.b) then
		frame.healthBar:SetStatusBarColor(r, g, b)

		if (frame.optionTable.colorHealthWithExtendedColors) then
			frame.selectionHighlight:SetVertexColor(r, g, b)
		else
			frame.selectionHighlight:SetVertexColor(1, 1, 1)
		end

		frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b
	end

	if (not UnitIsConnected(frame.unit)) then
		--Color it gray
		r, g, b = Entropy.db.colors.offline[1], Entropy.db.colors.offline[2], Entropy.db.colors.offline[3]
	elseif ( UnitIsDeadOrGhost(frame.displayedUnit) ) then
		r, g, b = Entropy.db.colors.dead[1], Entropy.db.colors.dead[2], Entropy.db.colors.dead[3]
	elseif Entropy.db.colors.classBackground and classColor then
		r, g, b = classColor[1], classColor[2], classColor[3]
	else
		r,g,b = Entropy.db.colors.background[1], Entropy.db.colors.background[2], Entropy.db.colors.background[3]
	end
	if (r ~= frame.background.r or g ~= frame.background.g or b ~= frame.background.b) then
		frame.background:SetVertexColor(r, g, b)
	end
end

local NATIVE_UNIT_FRAME_HEIGHT = 36;
local NATIVE_UNIT_FRAME_WIDTH = 72;

local function DefaultEntropyUnitFrameSetup(frame)
	if not Entropy.db then
		Entropy:InitDB()
	end

	frame:SetSize(Entropy.db.width, Entropy.db.height);
	local componentScale = (Entropy.db.height / NATIVE_UNIT_FRAME_HEIGHT + Entropy.db.width / NATIVE_UNIT_FRAME_WIDTH) / 2--min(Entropy.db.height / NATIVE_UNIT_FRAME_HEIGHT, Entropy.db.width / NATIVE_UNIT_FRAME_WIDTH);
	local powerBarHeight = 8;
	local powerBarUsedHeight = DefaultCompactUnitFrameOptions.displayPowerBar and powerBarHeight or 0;

	local backgroundTexture = SM:Fetch("statusbar", Entropy.db.units.backgroundtexture)
	frame.background:SetTexture(backgroundTexture);
	frame.background:SetVertexColor(Entropy.db.colors.background[1], Entropy.db.colors.background[2], Entropy.db.colors.background[3])
	frame.background:SetTexCoord(0,1,0,1);

	local statusBarTexture = SM:Fetch("statusbar", Entropy.db.units.texture)
	frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	frame.healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0 + powerBarUsedHeight);
	frame.healthBar:SetStatusBarTexture(statusBarTexture, "BORDER")

	if ( frame.powerBar ) then
		if ( DefaultCompactUnitFrameOptions.displayPowerBar ) then
			if ( DefaultCompactUnitFrameOptions.displayBorder ) then
				frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -2);
			else
				frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0);
			end
			frame.powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1);
			frame.powerBar:SetStatusBarTexture(statusBarTexture, "BORDER");
			frame.powerBar.background:SetTexture(backgroundTexture);
			frame.powerBar:Show();
		else
			frame.powerBar:Hide();
		end
	end

	if not Entropy.db.units.displayHealPrediction then
		DefaultCompactUnitFrameOptions.displayHealPrediction = false
	elseif (DefaultCompactUnitFrameOptions.displayHealPrediction == false) then -- will have to force enable this
		DefaultCompactUnitFrameOptions.displayHealPrediction = true
	end


	--frame.myHealPrediction:ClearAllPoints();
	--frame.myHealPrediction:SetColorTexture(1,1,1);
	--frame.myHealPrediction:SetGradient("VERTICAL", 8/255, 93/255, 72/255, 11/255, 136/255, 105/255);

	--frame.myHealAbsorb:ClearAllPoints();
	--frame.myHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);
	--frame.myHealAbsorbLeftShadow:ClearAllPoints();
	--frame.myHealAbsorbRightShadow:ClearAllPoints();

	--frame.otherHealPrediction:ClearAllPoints();
	--frame.otherHealPrediction:SetColorTexture(1,1,1);
	--frame.otherHealPrediction:SetGradient("VERTICAL", 11/255, 53/255, 43/255, 21/255, 89/255, 72/255);

	--frame.totalAbsorb:ClearAllPoints();
	--frame.totalAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Fill");
	--frame.totalAbsorb.overlay = frame.totalAbsorbOverlay;
	--frame.totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true);	--Tile both vertically and horizontally
	--frame.totalAbsorbOverlay:SetAllPoints(frame.totalAbsorb);
	--frame.totalAbsorbOverlay.tileSize = 32;

	--frame.overAbsorbGlow:ClearAllPoints();
	--frame.overAbsorbGlow:Show()
	--frame.overAbsorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield");
	--frame.overAbsorbGlow:SetBlendMode("ADD");
	--frame.overAbsorbGlow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMRIGHT", -7, 0);
	--frame.overAbsorbGlow:SetPoint("TOPLEFT", frame.healthBar, "TOPRIGHT", -7, 0);
	--frame.overAbsorbGlow:SetWidth(16);

	--frame.overHealAbsorbGlow:ClearAllPoints();
	--frame.overHealAbsorbGlow:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb");
	--frame.overHealAbsorbGlow:SetBlendMode("ADD");
	--frame.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMLEFT", 7, 0);
	--frame.overHealAbsorbGlow:SetPoint("TOPRIGHT", frame.healthBar, "TOPLEFT", 7, 0);
	--frame.overHealAbsorbGlow:SetWidth(16);
--[[
	DefaultCompactUnitFrameOptions = {
		useClassColors = true,
		displaySelectionHighlight = true,
		displayAggroHighlight = true,
		displayName = true,
		fadeOutOfRange = true,
		displayStatusText = true,
		displayHealPrediction = true,
		displayRoleIcon = true,
		displayRaidRoleIcon = true,
		displayDispelDebuffs = true,
		displayBuffs = true,
		displayDebuffs = true,
		displayOnlyDispellableDebuffs = false,
		displayNonBossDebuffs = true,
		healthText = "none",
		displayIncomingResurrect = true,
		displayIncomingSummon = true,
		displayInOtherGroup = true,
		displayInOtherPhase = true,
	}
]]--

	if Entropy.db.units.roleIcon then
		DefaultCompactUnitFrameOptions.displayRoleIcon = false
	elseif (DefaultCompactUnitFrameOptions.displayRoleIcon == false) then
		DefaultCompactUnitFrameOptions.displayRoleIcon = true
	end

	--frame.name:SetPoint("TOPLEFT", frame.roleIcon, "TOPRIGHT", 0, -1);
	--frame.name:SetPoint("TOPRIGHT", -3, -3);
	--frame.name:SetJustifyH("LEFT");

	local NATIVE_FONT_SIZE = 12;
	local fontName, fontSize, fontFlags = frame.statusText:GetFont();
	local buffSize = Entropy.db.units.buffIconSize * componentScale;
	local readyCheckSize = 15 * componentScale;
	frame.statusText:SetFont(fontName, NATIVE_FONT_SIZE * componentScale, fontFlags);
	frame.statusText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 3, Entropy.db.height / 3 - 2);
	frame.statusText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, Entropy.db.height / 3 - 2);
	frame.statusText:SetHeight(12 * componentScale);

	frame.readyCheckIcon:ClearAllPoints();
	frame.readyCheckIcon:SetPoint("BOTTOM", frame, "BOTTOM", 0, Entropy.db.height / 3 - 4);
	frame.readyCheckIcon:SetSize(readyCheckSize, readyCheckSize);

	--CompactUnitFrame_SetMaxBuffs(frame, 3);
	--CompactUnitFrame_SetMaxDebuffs(frame, 3);
	--CompactUnitFrame_SetMaxDispelDebuffs(frame, 3);

	local buffPos, buffRelativePoint, buffOffset = "BOTTOMRIGHT", "BOTTOMLEFT", CUF_AURA_BOTTOM_OFFSET + powerBarUsedHeight;
	frame.buffFrames[1]:ClearAllPoints();
	frame.buffFrames[1]:SetPoint(buffPos, frame, "BOTTOMRIGHT", -3, buffOffset);
	for i=1, #frame.buffFrames do
		if ( i > 1 ) then
			frame.buffFrames[i]:ClearAllPoints();
			frame.buffFrames[i]:SetPoint(buffPos, frame.buffFrames[i - 1], buffRelativePoint, 0, 0);
		end
		frame.buffFrames[i]:SetScript("OnEnter", function() end) -- TODO reconsider
		frame.buffFrames[i]:SetScript("OnLeave", function() end)
		frame.buffFrames[i]:SetSize(buffSize, buffSize);
		frame.buffFrames[i].count:SetFont(SM:Fetch("font", Entropy.db.font.file), Entropy.db.font.size, Entropy.db.font.attribute)
	end

	local debuffPos, debuffRelativePoint, debuffOffset = "BOTTOMLEFT", "BOTTOMRIGHT", CUF_AURA_BOTTOM_OFFSET + powerBarUsedHeight;
	frame.debuffFrames[1]:ClearAllPoints();
	frame.debuffFrames[1]:SetPoint(debuffPos, frame, "BOTTOMLEFT", 3, debuffOffset);
	for i=1, #frame.debuffFrames do
		if ( i > 1 ) then
			frame.debuffFrames[i]:ClearAllPoints();
			frame.debuffFrames[i]:SetPoint(debuffPos, frame.debuffFrames[i - 1], debuffRelativePoint, 0, 0);
		end
		frame.debuffFrames[i]:SetScript("OnEnter", function() end)
		frame.debuffFrames[i]:SetScript("OnLeave", function() end)
		frame.debuffFrames[i].baseSize = buffSize;
		frame.debuffFrames[i].maxHeight = Entropy.db.height - powerBarUsedHeight - CUF_AURA_BOTTOM_OFFSET - CUF_NAME_SECTION_SIZE;
		frame.debuffFrames[i].count:SetFont(SM:Fetch("font", Entropy.db.font.file), Entropy.db.font.size, Entropy.db.font.attribute) -- TODO add seperate font setting
	end

	frame.dispelDebuffFrames[1]:SetPoint("TOPRIGHT", -3, -2);
	for i=1, #frame.dispelDebuffFrames do
		if ( i > 1 ) then
			frame.dispelDebuffFrames[i]:SetPoint("RIGHT", frame.dispelDebuffFrames[i - 1], "LEFT", 0, 0);
		end
		frame.dispelDebuffFrames[i]:SetSize(12, 12);
		--frame.dispelDebuffFrames[i].count:SetFont(SM:Fetch("font", Entropy.db.font.file), Entropy.db.font.size, Entropy.db.font.attribute)
	end

	--frame.selectionHighlight:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights");
	--frame.selectionHighlight:SetTexCoord(unpack(texCoords["Raid-TargetFrame"]));
	--frame.selectionHighlight:SetAllPoints(frame);

	--frame.aggroHighlight:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights");
	--frame.aggroHighlight:SetTexCoord(unpack(texCoords["Raid-AggroFrame"]));
	--frame.aggroHighlight:SetAllPoints(frame);

	frame.centerStatusIcon:ClearAllPoints();
	frame.centerStatusIcon:SetPoint("CENTER", frame, "BOTTOM", 0, Entropy.db.height / 3 + 2);
	frame.centerStatusIcon:SetSize(11 * componentScale, 11 * componentScale); -- TODO add setting?

	-- Border stuff

	frame.name:SetFont(SM:Fetch("font", Entropy.db.font.file), Entropy.db.font.size, Entropy.db.font.attribute)
	if Entropy.db.font.shadow then
		frame.name:SetShadowOffset(1, -1)
	else
		frame.name:SetShadowOffset(0, 0)
	end
end


local function EntropyUnitFrame_UpdateHealPrediction(frame)
	if not Entropy.db then return end
	if not group[strsub(frame.displayedUnit, 1, 4)] then return end

	local offset = 0
	if Entropy.db.units.hidemyHealPrediction then
		frame.myHealPrediction:SetWidth(-1)
		frame.myHealPrediction:Hide()
		offset = offset + (frame.myHealPrediction:GetWidth() or 0)
	end
	if Entropy.db.units.hideotherHealPrediction then
		frame.otherHealPrediction:SetWidth(-1)
		frame.otherHealPrediction:Hide()
		--offset = offset + (frame.otherHealPrediction:GetWidth() or 0)
	end
	if Entropy.db.units.hidemyHealAbsorb then
		frame.myHealAbsorb:Hide()
	elseif offset ~= 0 then
		--local point, relativeTo, relativePoint, _, yOfs = frame.myHealAbsorb:GetPoint(1)
		--frame.myHealAbsorb:SetPoint(point, relativeTo, relativePoint, -offset, yOfs)
		--point, relativeTo, relativePoint, _, yOfs = frame.myHealAbsorb:GetPoint(2)
		--frame.myHealAbsorb:SetPoint(point, relativeTo, relativePoint, -offset, yOfs)
	end
	if Entropy.db.units.hidetotalAbsorb then
		frame.totalAbsorb:Hide()
		frame.totalAbsorbOverlay:Hide()
	elseif offset ~= 0 then
		local _, totalMax = frame.healthBar:GetMinMaxValues();
		local health = frame.healthBar:GetValue();
		local totalWidth, _ = frame.healthBar:GetSize();
		local totalAbsorb = UnitGetTotalAbsorbs(frame.displayedUnit) or 0;
		local barSize = min((totalMax - health) / totalMax * totalWidth, (totalAbsorb / totalMax) * totalWidth)
		frame.totalAbsorb:SetWidth(barSize) -- shit won't work if only one of them is hidden bro
		--frame.totalAbsorb:ClearAllPoints()
		--frame.totalAbsorb:SetPoint(frame.myHealPrediction:GetPoint())
		--local point, relativeTo, relativePoint, _, yOfs = frame.myHealPrediction:GetPoint()
		--print (relativeTo:GetName())
		--local point, relativeTo, relativePoint, _, yOfs = frame.totalAbsorb:GetPoint(1)
		--frame.totalAbsorb:SetPoint(point, relativeTo, relativePoint, -offset, yOfs)
		--point, relativeTo, relativePoint, _, yOfs = frame.totalAbsorb:GetPoint(2)
		--frame.totalAbsorb:SetPoint(point, relativeTo, relativePoint, -offset, yOfs)
		--point, relativeTo, relativePoint, _, yOfs = frame.totalAbsorbOverlay:GetPoint(1)
		--frame.totalAbsorbOverlay:SetPoint(point, relativeTo, relativePoint, -offset, yOfs)
		--point, relativeTo, relativePoint, _, yOfs = frame.totalAbsorbOverlay:GetPoint(2)
		--frame.totalAbsorbOverlay:SetPoint(point, relativeTo, relativePoint, -offset, yOfs)
	end
	if Entropy.db.units.hideoverAbsorbGlow then
		frame.overAbsorbGlow:Hide()
		frame.overAbsorbGlow:SetWidth(-1)

	end
	--else
	--	frame.overAbsorbGlow:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", 0, 0)
	--	frame.overAbsorbGlow:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", 0, 0)
	--	previousTexture = frame.overAbsorbGlow
	--end
	if Entropy.db.units.hideoverHealAbsorbGlow then
		frame.overHealAbsorbGlow:Hide()
		frame.overHealAbsorbGlow:SetWidth(-1)

	--else
	--	frame.overHealAbsorbGlow:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", 0, 0)
	--	frame.overHealAbsorbGlow:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", 0, 0)
	end
end

local function EntropyUnitFrame_UpdateStatusText(frame)
	if ( not frame.statusText ) then
		return;
	end
	if not Entropy.db then
		Entropy:InitDB()
	end
	if not group[strsub(frame.displayedUnit, 1, 4)] then return end
	if not frame:IsShown() then return end

	EntropyUnitFrame_UpdateHealthColor(frame)
end


hooksecurefunc("CompactRaidGroup_UpdateLayout", EntropyRaidGroup_UpdateLayout)
--hooksecurefunc("CompactUnitFrame_UpdateName", print);
hooksecurefunc("CompactUnitFrame_UpdateName", EntropyUnitFrame_UpdateName)
hooksecurefunc("DefaultCompactUnitFrameSetup", DefaultEntropyUnitFrameSetup)
hooksecurefunc("CompactUnitFrame_UpdateHealthColor", EntropyUnitFrame_UpdateHealthColor)
hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", EntropyUnitFrame_UpdateHealPrediction)
hooksecurefunc("CompactUnitFrame_UpdateStatusText", EntropyUnitFrame_UpdateStatusText)

local Default_CompactUnitFrame_UtilShouldDisplayBuff = CompactUnitFrame_UtilShouldDisplayBuff
function CompactUnitFrame_UtilShouldDisplayBuff (...)
	local spellId = select(10, ...)
	local name = select(1, ...)
	local expirationTime = select(6, ...)

	--if name == "Riptide" then --currentAuraScanTarget
		--highlightList[currentAuraScanTarget] = expirationTime
		--print (GetTime() .. " " .. expirationTime)
	--end

	if Entropy.ignoreAura[spellId] == true or Entropy.db.ignoreAura[spellId] == true or Entropy.db.ignoreAura[name] == true then
		return false
	end

	return Default_CompactUnitFrame_UtilShouldDisplayBuff(...)
end

local Default_CompactUnitFrame_Util_ShouldDisplayDebuff= CompactUnitFrame_Util_ShouldDisplayDebuff
function CompactUnitFrame_Util_ShouldDisplayDebuff (...)
	local spellId = select(10, ...)
	local name = select(1, ...)
	
	if Entropy.ignoreAura[spellId] == true or Entropy.db.ignoreAura[spellId] == true or Entropy.db.ignoreAura[name] == true then
		return false
	end

	return Default_CompactUnitFrame_Util_ShouldDisplayDebuff(...)
end

--local prevhook = _G.CompactUnitFrame_UtilShouldDisplayBuff
--_G.CompactUnitFrame_UtilShouldDisplayBuff = function(...)
--	local buffName, _, _, _, _, _, source = ...
--	-- if buffName == "Devotion Aura" then
--	--   print(Utl.vdump({...}))
--	-- end
--	-- local buffName, _, _, _, _, _, source, _, _, spellId = UnitAura(...)
--	if source == "player" then
--		if BANNED_BUFFS[buffName] ~= nil then
--			return false
--		end
--		if MY_ADDITIONAL_BUFFS_IDX[buffName] ~= nil then
--			return true
--		end
--	end
--	return prevhook(...)
--end

-- for all raidmembers
-- CompactUnitFrame_UpdateAll(frame)
-- CompactRaidGroup_ApplyFunctionToAllFrames(_G["CompactRaidFrameStuff"], "all", CompactUnitFrame_UpdateAll)
-- or CompactRaidFrameThing.applyFunc() idk

--local panel = CompactUnitFrameProfiles.optionsFrame;
--for i=1, #panel.optionControls do
--	panel.optionControls[i]:updateFunc();
--end

function Entropy:updateAll()
	if InCombatLockdown() then return end
	--Refresh all frames to make sure the changes stick.
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "normal", DefaultCompactUnitFrameSetup)
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "normal", CompactUnitFrame_UpdateAll)
	--Update the borders on the group frames.
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "group", CompactRaidGroup_UpdateBorder)
	--Update the container in case sizes and such changed.
	CompactRaidFrameContainer_TryUpdate(CompactRaidFrameContainer)
end

--local prevhook = CompactUnitFrame_UpdateAuras
--CompactUnitFrame_UpdateAuras = function(frame)
--	currentAuraScanTarget = frame
--
--	prevhook(frame)
--
--	for targetFrame, expirationTime in pairs(highlightList) do
--		targetFrame.healthBar:SetStatusBarColor(1, 0, 0)
--		targetFrame.healthBar.r, targetFrame.healthBar.g, targetFrame.healthBar.b = 1, 0, 0
--
--		if GetTime() >= expirationTime then
--			print ("delete " .. targetFrame:GetName())
--			EntropyUnitFrame_UpdateHealthColor(targetFrame)
--			highlightList[targetFrame] = nil
--		end
--	end
--end

hooksecurefunc("CompactUnitFrame_UpdateInRange", function(frame)
	if not Entropy.db then
		Entropy:InitDB()
	end
	if not Entropy.db.units.useCustomFadeAlpha then return end
	if not group[strsub(frame.displayedUnit, 1, 4)] then return end
	if not frame:IsShown() then return end

	local inRange, checkedRange = UnitInRange(frame.displayedUnit)
	if checkedRange and not inRange then
		frame:SetAlpha(Entropy.db.units.outOfRangeAlpha)
		frame.background:SetAlpha(Entropy.db.units.outOfRangeBgAlpha)
	else
		frame:SetAlpha(Entropy.db.units.inRangeAlpha)
		frame.background:SetAlpha(Entropy.db.units.inRangeBgAlpha)
	end
end)





