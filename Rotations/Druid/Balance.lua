local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 1 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Druid-Balance.JSON")

if content == nil or content == "" then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

function EmeraldDreamcatcher()
  -- StarsurgeV4
  -- Solar WrathV3
  -- Lunar StrikeV3
  -- Solar WrathV4
  -- StarsurgeV5
end

function Cooldowns()
  -- Potion
  -- Trinkets
  -- Racials
  DBAstralCommunion()
  DBFoN()
  DBWoE()
  DBIncarnation()
  DBCA()
end

function Pulse()
  -- combat rotation
  if UnitAffectingCombat(PlayerUnit)
  or (AllowOutOfCombatRoutine and UnitGUID("target") ~= nil
  and Unit.IsHostile("target")) and UnitHealth("target") ~= 0 then
    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))

    -- call interrupt engine
    if Interrupt then
      Rotation.Interrupt()
    end

    DBMoonkin()
    Cooldowns()
    DBStarsurgeV1()
    DBFoE()
    DBNewMoonV1()
    DBMoonfireV1()
    DBSunfireV1()
    DBStellarFlareV1()
    DBStarfallV1()
    if IsEquippedItem(137062)
    and #Units.GetUnitsInRadius(PlayerUnit, DBStarfallRadius, "hostile") <= 2 then
      EmeraldDreamcatcher()
    end
    DBNewMoonV2()
    DBStarfallV2()
    DBStellarFlareV2()
    DBSunfireV2()
    DBMoonfireV2()
    DBStarsurgeV2()
    DBStarsurgeV3()
    DBSolarWrathV1()
    DBLunarStrikeV1()
    DBLunarStrikeV2()
    DBSolarWrathV2()
  else
    -- out of combat
    DBBotA()
  end
end

function Interrupt()
end
