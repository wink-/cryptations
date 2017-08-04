local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 4 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Druid-Restoration.JSON")

if content == nil or content == "" then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

Dispell         = Settings.Dispell
AutoEngage      = Settings.AutoEngage
AutoTarget      = Settings.AutoTarget
TargetMode      = Settings.TargetMode
Incarnation     = Settings.Incarnation
Tranquility     = Settings.Tranquility
Innervate       = Settings.Innervate
Ironbark        = Settings.Ironbark
EoG             = Settings.EoG
Flourish        = Settings.Flourish
CenarionWard    = Settings.CenarionWard
Efflorescence   = Settings.Efflorescence
Renewal         = Settings.Renewal
DPS             = Settings.DPS
MaxRejuv        = Settings.MaxRejuv
IncarHealth     = Settings.IncarHealth
LBTime          = Settings.LBTime
RejuvHealth     = Settings.RejuvHealth
GermHealth      = Settings.GermHealth
RegrowthHealth  = Settings.RegrowthHealth
HTHealth        = Settings.HTHealth
CWHealth        = Settings.CWHealth
TQHealth        = Settings.TQHealth
IBHealth        = Settings.IBHealth
WGUnits         = Settings.WGUnits
WGHealth        = Settings.WGHealth
SMHealth        = Settings.SMHealth
EFUnits         = Settings.EFUnits
EFHealth        = Settings.EFHealth
EoGHoTCount     = Settings.EoGHoTCount
MaxMana         = UnitPowerMax("player", 0)

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local BossManager = LibStub("BossManager")
local Utils       = LibStub("Utils")

KeyCallbacks = {
  ["CTRL,P"] = Rotation.TogglePause,
  ["CTRL,A"] = Rotation.ToggleAoE
}

function Pulse()
  -- Combat Rotation
  if UnitAffectingCombat(PlayerUnit) then
    -- Dispell engine
    if Dispell then
      Rotation.Dispell()
    end

    -- pulse target engine and remember target
    Rotation.Target("hostile")

    DRIronbark()
    DRLifebloom()
    DRIncarnation()
    DRSwiftmend()
    DRTranquility()
    DRInnervate()
    DREoG()
    DRFlourish()
    DREfflorescence()
    DRRegrowthClearcast()
    DRCenarionWard()
    DRRenewal()
    DRRegrowth()
    DRWildGrowth()
    DRRejuvenation()
    DRHealingTouch()
    DRSolarWrath()
  else
    -- Out Of Combat Rotation
  end
end

function Dispell(unit, dispellType)
  if Spell.CanCast(SB["Nature's Cure"], unit, 0, MaxMana * 0.13)
  and dispellType ~= "Disease" then
    return Spell.Cast(SB["Nature's Cure"], unit)
  end
end
