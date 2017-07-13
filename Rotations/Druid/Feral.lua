local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 2 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Druid-Feral.JSON")

if json.decode(content) == nil then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

Interrupt   = Settings.Interrupt

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")
RipCPSpent        = 0 -- This saves how many cp were spent on the last rip (usefull to check if we can apply a stronger rip)

function Finishers()
  DFRipV1()
  DFFerociousBiteV2()
  DFRipV2()
  DFSavageRoar()
  DFMaim()
  DFFerociousBiteV3()
  -- DFRipV3
end

function AoE()
  -- Thrash
  -- Brutal Slash
  -- Thrash 2
  -- Swipe
end

function Generators()
  -- Shadowmeld
  -- Rake
  -- Rake 2
  -- Rage 3
  -- Rake 4
  -- Brutal Slash
  -- Moonfire
  -- Thrash
  -- Swipe
  -- Thrash 3
  -- Thrash 4
  -- Shred
end

function Pulse()
  -- combat rotation
  if UnitAffectingCombat(PlayerUnit)
  or (AllowOutOfCombatRoutine and UnitGUID("target") ~= nil
  and Unit.IsHostile("target")) and UnitHealth("target") ~= 0 then

    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))
    TTD = Unit.ComputeTTD(PlayerTarget)

    Energy          = UnitPower("player", 3)
    MaxEnergy       = UnitPowerMax("player", 3)
    ComboPoints     = UnitPower("player", 4)
    MaxComboPoints  = UnitPowerMax("player", 4)

    -- call interrupt engine
    if Interrupt then
      Rotation.Interrupt()
    end

    DFRakeV1()
    DFTigersFury()
    DFIKotJ()
    DFBerserk()
    -- Cooldowns
    DFElunesGuidance()
    DFFerociousBiteV1()
    DFRegrowthV1()
    DFRegrowthV2()
    if ComboPoints >= 5 then
      Finishers()
    end
    DFArtifact()
    if getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile")) >= 5
    and ComboPoints <= 4 then
      AoE()
    end
    if ComboPoints <= 4
    and getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile")) < 5 then
      Generators()
    end
  else
    -- out of combat
  end
end

function Interrupt()
end
