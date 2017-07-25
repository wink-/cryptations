local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 1 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Paladin-Holy.JSON")

if content == nil or content == "" then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

-- Apply settings from config file
Dispell                 = Settings.Dispell
AvengingWrath           = Settings.AvengingWrath
HolyAvenger             = Settings.HolyAvenger
LayOnHands              = Settings.LayOnHands
BoS                     = Settings.BoS
TyrsDeliverance         = Settings.TyrsDeliverance
RuleOfLaw               = Settings.RuleOfLaw
BoL                     = Settings.BoL
BoF                     = Settings.BoF
InfusionHL              = Settings.InfusionHL
InfusionFoL             = Settings.InfusionFoL
Judgment                = Settings.UseJudgment
LightsHammer            = Settings.Judgment
LightOfDawn             = Settings.LightOfDawn
HolyPrism               = Settings.HolyPrism
BoV                     = Settings.BoV
LotM                    = Settings.LotM

AWHealth                = Settings.AWHealth
HAHealth                = Settings.HAHealth
LoHHealth               = Settings.LoHHealth
BoSHealth               = Settings.BoSHealth
TDHealth                = Settings.TDHealth
TDUnits                 = Settings.TDUnits
LHUnits                 = Settings.LHUnits
LHHealth                = Settings.LHHealth
LoDUnits                = Settings.LoDUnits
LoDHealth               = Settings.LoDHealth
HolyPrismUnits          = Settings.HolyPrismUnits
BoVUnits                = Settings.BoVUnits
BoVHealth               = Settings.BoVHealth
FoLHealth               = Settings.FoLHealth
BestowFaithHealth       = Settings.BestowFaithHealth
HLHealth                = Settings.HLHealth
HSHealth                = Settings.HSHealth
MaxMana                 = UnitPowerMax("player" , 0)

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local BossManager = LibStub("BossManager")
local Utils       = LibStub("Utils")

function Pulse()
  if UnitAffectingCombat(PlayerUnit) then
    -- Dispell engine
    if UseDispell then
      Rotation.Dispell()
    end

    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))

    PHAvengingWrath()
    PHHolyAvenger()
    PHLayOnHands()
    PHBoS()

    -- TODO
    -- Aura Mastery (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Protection (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Freedom (SHOULD BE HANDELED BY BOSS MANAGER)

    PHTyrsDeliverance()
    PHRuleOfLaw()
    PHBoL()
    PHBoF()
    PHBestowFaith()
    PHInfusionProc()
    PHHolyShock()
    PHJudgment()
    PHLightsHammer()
    PHLoD()
    PHHolyPrism()
    PHBoV()
    PHHolyLight()
    PHFlashOfLight()
  else
    -- OUT OF COMBAT ROUTINE
  end
end

-- Dispell Spells are handled here
function Dispell(unit, dispelType)
  if Spell.CanCast(4987, unit, 0, MaxMana * 0.13) and dispelType ~= "Curse" then
    return Spell.Cast(4987, unit)
  end
end
