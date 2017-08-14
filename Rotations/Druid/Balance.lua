local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 1 then return end

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

-- Unlocker related stuff here
if FireHack ~= nil then
  -- load profile content
  local wowdir = GetWoWDirectory()
  local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
  local content = ReadFile(profiledir .. "Druid-Balance.JSON")

  if content == nil or content == "" then
    return message("Error loading config file. Please contact the Author.")
  end

  local Settings = json.decode(content)

  Interrupt     = Settings.Interrupt
  InterruptAny  = Settings.InterruptAny
  InterruptMin  = Settings.InterruptMin
  InterruptMax  = Settings.InterruptMax
  AutoEngage    = Settings.AutoEngage
  AutoTarget    = Settings.AutoTarget
  TargetMode    = Settings.TargetMode
  Incarnation   = Settings.Incarnation
  CA            = Settings.CA
  FoN           = Settings.FoN
  WoE           = Settings.WoE
  MoonkinForm   = Settings.MoonkinForm
  BotA          = Settings.BotA
  BoE           = Settings.BoE
  BoA           = Settings.BoA
  StFMD         = Settings.StFMD
  MFMD          = Settings.MFMD
  SFMD          = Settings.SFMD
  StFMDCount    = Settings.StFMDCount
  MFMDCount     = Settings.MFMDCount
  SFMDCount     = Settings.SFMDCount
  PauseHotkey   = Settings.PauseHotkey
  AoEHotkey     = Settings.AoEHotkey
  CDHotkey      = Settings.CDHotkey

  KeyCallbacks = {
    [PauseHotkey] = Rotation.TogglePause,
    [AoEHotkey] = Rotation.ToggleAoE,
    [CDHotkey] = Rotation.ToggleCD
  }
end

function EmeraldDreamcatcher()
  DBStarsurgeV4()
  DBSolarWrathV3()
  DBLunarStrikeV3()
  DBSolarWrathV4()
  DBStarsurgeV5()
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
  if (UnitAffectingCombat(PlayerUnit) or AutoEngage)
  and UnitGUID("target") ~= nil
  and Unit.IsHostile("target") and UnitHealth("target") ~= 0 then
    -- pulse target engine and remember target
    Rotation.Target("hostile")

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
    DBMoonkin()
  end
end

function Interrupt(Target)
  if Spell.CanCast(78675, Target, 0, UnitPowerMax("player", 0) * 0.168)
  and Unit.IsInLOS(Target)
  and ObjectIsFacing(PlayerUnit, Target) then
    return Spell.Cast(78675, Target)
  end
end
