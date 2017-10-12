local DruidBalance  = LibStub("DruidBalance")
local Unit          = LibStub("Unit")
local Spell         = LibStub("Spell")
local Rotation      = LibStub("Rotation")
local Player        = LibStub("Player")
local Buff          = LibStub("Buff")
local Debuff        = LibStub("Debuff")
local BossManager   = LibStub("BossManager")

function DruidBalance.Initialize()
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

  -- set function variables
  Pulse = DruidBalance.Pulse
  Interrupt = DruidBalance.Interrupt
  print("Balance Druid loaded. Have fun.")
end

function DruidBalance.EmeraldDreamcatcher()
  DruidBalance.StarsurgeV4()
  DruidBalance.SolarWrathV3()
  DruidBalance.LunarStrikeV3()
  DruidBalance.SolarWrathV4()
  DruidBalance.StarsurgeV5()
end

function DruidBalance.Cooldowns()
  -- Potion
  -- Trinkets
  -- Racials
  DruidBalance.AstralCommunion()
  DruidBalance.FoN()
  DruidBalance.WoE()
  DruidBalance.Incarnation()
  DruidBalance.CA()
end

function DruidBalance.Pulse()
  -- combat rotation
  if (UnitAffectingCombat(PlayerUnit) or AutoEngage)
  and UnitGUID("target") ~= nil
  and Unit.IsHostile("target") and UnitHealth("target") ~= 0 then
    -- pulse target engine
    Rotation.Target("hostile")

    -- call interrupt engine
    if Interrupt then
      Rotation.Interrupt()
    end

    DruidBalance.Moonkin()
    DruidBalance.Cooldowns()
    DruidBalance.StarsurgeV1()
    DruidBalance.FoE()
    DruidBalance.NewMoonV1()
    DruidBalance.MoonfireV1()
    DruidBalance.SunfireV1()
    DruidBalance.StellarFlareV1()
    DruidBalance.StarfallV1()
    if IsEquippedItem(137062)
    and #Units.GetUnitsInRadius(PlayerUnit, DBStarfallRadius, "hostile") <= 2 then
      DruidBalance.DruidBalance.EmeraldDreamcatcher()
    end
    DruidBalance.NewMoonV2()
    DruidBalance.StarfallV2()
    DruidBalance.StellarFlareV2()
    DruidBalance.SunfireV2()
    DruidBalance.MoonfireV2()
    DruidBalance.StarsurgeV2()
    DruidBalance.StarsurgeV3()
    DruidBalance.SolarWrathV1()
    DruidBalance.LunarStrikeV1()
    DruidBalance.LunarStrikeV2()
    DruidBalance.SolarWrathV2()
  else
    -- out of combat
    DruidBalance.BotA()
    DruidBalance.Moonkin()
  end
end

function DruidBalance.Interrupt(Target)
  if Spell.CanCast(78675, Target, 0, UnitPowerMax("player", 0) * 0.168)
  and Unit.IsInLOS(Target)
  and ObjectIsFacing(PlayerUnit, Target) then
    return Spell.Cast(78675, Target)
  end
end
