local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 1 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Paladin-Holy.JSON")

if json.decode(content) == nil then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

-- Apply settings from config file
UseDispell                          = Settings.UseDispell
UseAvengingWrath                    = Settings.UseAvengingWrath
UseHolyAvenger                      = Settings.UseHolyAvenger
UseLayOnHands                       = Settings.UseLayOnHands
UseBlessingOfSacrifice              = Settings.UseBlessingOfSacrifice
UseTyrsDeliverance                  = Settings.UseTyrsDeliverance
UseRuleOfLaw                        = Settings.UseRuleOfLaw
UseBeaconOfLight                    = Settings.UseBeaconOfLight
UseBeaconOfFaith                    = Settings.UseBeaconOfFaith
UseHolyLightOnInfusion              = Settings.UseHolyLightOnInfusion
UseFlashOfLightOnInfusion           = Settings.UseFlashOfLightOnInfusion
UseJudgment                         = Settings.UseJudgment
UseLightsHammer                     = Settings.UseLightsHammer
UseLightofDawn                      = Settings.UseLightofDawn
UseHolyPrism                        = Settings.UseHolyPrism
UseBeaconOfVirtue                   = Settings.UseBeaconOfVirtue

AvengingWrathHealthThreshold        = Settings.AvengingWrathHealthThreshold
HolyAvengerHealthThreshold          = Settings.HolyAvengerHealthThreshold
LayOnHandsHealthThreshold           = Settings.LayOnHandsHealthThreshold
BlessingOfSacrificeHealthThreshold  = Settings.BlessingOfSacrificeHealthThreshold
TyrsDeliveranceHealthThreshold      = Settings.TyrsDeliveranceHealthThreshold
LightsHammerUnitThreshold           = Settings.LightsHammerUnitThreshold
LightsHammerHealthThreshold         = Settings.LightsHammerHealthThreshold
LightOfDawnUnitThreshold            = Settings.LightOfDawnUnitThreshold
LightOfDawnHealthThreshold          = Settings.LightOfDawnHealthThreshold
HolyPrismUnitThreshold              = Settings.HolyPrismUnitThreshold
BeaconOfVirtueUnitThreshold         = Settings.BeaconOfVirtueUnitThreshold
BeaconOfVirtueHealthThreshold       = Settings.BeaconOfVirtueHealthThreshold

TankHealthThreshold                 = Settings.TankHealthThreshold
OtherHealthThreshold                = Settings.OtherHealthThreshold
ToppingHealthThreshold              = Settings.ToppingHealthThreshold
FlashOfLightThreshold               = Settings.FlashOfLightThreshold
BestowFaithThreshold                = Settings.BestowFaithThreshold
MaxMana                             = UnitPowerMax("player" , 0)

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
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
