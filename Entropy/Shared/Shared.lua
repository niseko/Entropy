local LSM = LibStub("LibSharedMedia-3.0")
local ruRU, western = LSM.LOCALE_BIT_ruRU, LSM.LOCALE_BIT_western
local flag = ruRU + western
local FONT = LSM.MediaType.FONT
local STATUSBAR = LSM.MediaType.STATUSBAR
local BACKGROUND = LSM.MediaType.BACKGROUND
local BORDER = LSM.MediaType.BORDER

local path = "Interface\\AddOns\\Entropy\\Shared\\"

LSM:Register(STATUSBAR, "Charcoal", path.."Texture\\Charcoal")
LSM:Register(STATUSBAR, "Glaze", path.."Texture\\Glaze")
LSM:Register(STATUSBAR, "Gloss", path.."Texture\\Gloss")
LSM:Register(STATUSBAR, "Halycon", path.."Texture\\Halycon")
LSM:Register(STATUSBAR, "Melli", path.."Texture\\Melli")
LSM:Register(STATUSBAR, "Pill", path.."Texture\\Pill")
LSM:Register(STATUSBAR, "Smooth", path.."Texture\\Smooth")
LSM:Register(STATUSBAR, "Smooth v2", path.."Texture\\Smoothv2")
LSM:Register(STATUSBAR, "Steel", path.."Texture\\Steel")
LSM:Register(STATUSBAR, "Gradient", path.."Texture\\Gradient")
LSM:Register(STATUSBAR, "Glamour7", path.."Texture\\Glamour7.tga")
LSM:Register(STATUSBAR, "normtex", path.."Texture\\normTex.tga")
LSM:Register(STATUSBAR, "Plain", path.."Texture\\Plain.tga")
LSM:Register(STATUSBAR, "PlainDark", path.."Texture\\Plain28.tga")
LSM:Register(STATUSBAR, "PlainLight", path.."Texture\\Plain84.tga")

LSM:Register(BACKGROUND, "Plain White", path.."Texture\\White8x8")

LSM:Register(FONT, "Noto Sans Condensed", path.."Fonts\\NotoSans-Condensed.ttf", flag)
LSM:Register(FONT, "Noto Sans", path.."Fonts\\NotoSans-Regular.ttf", flag)
LSM:Register(FONT, "FiraCode-Regular", path.."Fonts\\FiraCode-Regular.ttf")
LSM:Register(FONT, "pearl", path.."Fonts\\pearl.ttf")
LSM:Register(FONT, "Roboto", path.."Fonts\\Roboto-Regular.ttf")
LSM:Register(FONT, "Roboto Medium", path.."Fonts\\Roboto-Medium.ttf")
LSM:Register(FONT, "OpenSans", path.."Fonts\\OpenSans-Regular.ttf")
LSM:Register(FONT, "Raleway Medium", path.."Fonts\\Raleway-Medium.ttf")
LSM:Register(FONT, "Raleway", path.."Fonts\\Raleway-Regular.ttf")

local function register(...)
	for tCnt = 1, select('#', ...) do
		LSM:Register(STATUSBAR, select(tCnt, ...), path.."Texture\\bar" .. tCnt .. ".tga")
	end
end

register("Rhombs", "Twirls", "Pipe, dark", "Concave, dark", "Pipe, light", "Flat", "Concave, light",
	"Convex", "Textile", "Mirrorfinish", "Diagonals", "Zebra", "Marble", "Modern Art", "Polished Wood", "Gradient",
	"Minimalist", "Aluminium");

LSM:Register(STATUSBAR, "Bar Highlighter", path.."Texture\\highlight2.tga")
LSM:Register(STATUSBAR, "Plain White", path.."Texture\\plain_white.tga")
LSM:Register(STATUSBAR, "LiteStepLite", path.."Texture\\LiteStepLite.tga")
LSM:Register(STATUSBAR, "Tukui", path.."Texture\\tukuibar.tga")

LSM:Register(BORDER, "Plain White", path.."Texture\\White8x8")
LSM:Register(BORDER, "Plain", path.."Texture\\Plain8x8")
