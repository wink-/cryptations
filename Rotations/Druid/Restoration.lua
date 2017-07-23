local ClassID = select(3, UnitClass("player"))
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
Tranquility     = Settings.Tranquility
Innervate       = Settings.Innervate
Ironbark        = Settings.Ironbark
EoG             = Settings.EoG
Flourish        = Settings.Flourish
CenarionWard    = Settings.CenarionWard
Efflorescence   = Settings.Efflorescence
MaxRejuv        = Settings.MaxRejuv
LBTime          = Settings.LBTime
RejuvHealth     = Settings.RejuvHealth
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
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")
local Utils       = LibStub("Utils")

function Pulse()
  -- Combat Rotation
  if UnitAffectingCombat(PlayerUnit) then
    -- Dispell engine
    if Dispell then
      Rotation.Dispell()
    end

    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))

    DRTranquility()
    DRInnervate()
    DRIronbark()
    DREoG()
    DRFlourish()
    DREfflorescence()
    DRLifebloom()
    DRRegrowthClearcast()
    DRCenarionWard()
    DRRejuvenation()
    DRWildGrowth()
    DRSwiftmend()
    DRRegrowth()
    DRHealingTouch()
  -- Out Of Combat Rotation
  else

  end
end

function Dispell(unit, dispellType)
  if Spell.CanCast(88423, unit, 0, MaxMana * 0.13)
  and dispellType ~= "Disease" then
    return Spell.Cast(88423, unit)
  end
end
