local DruidFeral  = LibStub("DruidFeral")
local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local BossManager = LibStub("BossManager")

function DruidFeral.Initialize()
  -- load profile content
  local wowdir = GetWoWDirectory()
  local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
  local content = ReadFile(profiledir .. "Druid-Feral.JSON")

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
  Prowl         = Settings.Prowl
  ProwlMode     = Settings.ProwlMode
  Incarnation   = Settings.Incarnation
  Berserk       = Settings.Berserk
  Shadowmeld    = Settings.Shadowmeld
  Moonfire      = Settings.Moonfire
  MoonfireMD    = Settings.MoonfireMD
  RakeMD        = Settings.RakeMD
  RipMD         = Settings.RipMD
  RakeMDCount   = Settings.RakeMDCount
  MFMDCount     = Settings.MFMDCount
  RipMDCount    = Settings.RipMDCount
  PauseHotkey   = Settings.PauseHotkey
  AoEHotkey     = Settings.AoEHotkey
  CDHotkey      = Settings.CDHotkey

  KeyCallbacks = {
    [PauseHotkey] = Rotation.TogglePause,
    [AoEHotkey] = Rotation.ToggleAoE,
    [CDHotkey] = Rotation.ToggleCD
  }

  -- set function variables
  Pulse = DruidFeral.Pulse
  Interrupt = DruidFeral.Interrupt
  print("Feral Druid loaded. Have fun.")
end

function DruidFeral.Finishers()
  DruidFeral.RipV1()
  DruidFeral.FerociousBiteV2()
  DruidFeral.RipV2()
  DruidFeral.SavageRoar()
  DruidFeral.Maim()
  DruidFeral.FerociousBiteV3()
  -- DruidFeral.RipV3
end

function DruidFeral.AoE()
  -- Thrash
  -- Brutal Slash
  -- Thrash 2
  -- Swipe
end

function DruidFeral.Generators()
  DruidFeral.Shadowmeld()
  DruidFeral.RakeV2()
  DruidFeral.RakeV3()
  DruidFeral.RakeV4()
  DruidFeral.RakeV5()
  DruidFeral.BrutalSlashV1()
  --DruidFeral.Moonfire()
  DruidFeral.ThrashV1()
  DruidFeral.SwipeV1()
  DruidFeral.ThrashV2()
  DruidFeral.ThrashV3()
  DruidFeral.Shred()
end

function DruidFeral.Pulse()
  -- combat rotation
  if (UnitAffectingCombat(PlayerUnit) or AutoEngage)
  and UnitGUID("target") ~= nil
  and Unit.IsHostile("target") and UnitHealth("target") ~= 0 then

    -- pulse target engine and remember target
    Rotation.Target("hostile")

    local ComboPoints = UnitPower("player", 4)

    -- call interrupt engine
    if Interrupt then
      Rotation.Interrupt()
    end

    DruidFeral.Prowl()
    DruidFeral.RakeV1()
    DruidFeral.TigersFury()
    DruidFeral.IKotJ()
    DruidFeral.Berserk()
    -- Cooldowns
    DruidFeral.ElunesGuidance()
    DruidFeral.FerociousBiteV1()
    DruidFeral.RegrowthV1()
    DruidFeral.RegrowthV2()
    if ComboPoints >= 5 then
      Rotation.Debug("Calling Finishers")
      DruidFeral.Finishers()
    end
    DruidFeral.Artifact()
    if #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 5
    and ComboPoints <= 4 then
      Rotation.Debug("Calling AoE")
      DruidFeral.AoE()
    end
    if ComboPoints <= 4
    and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") < 5 then
      Rotation.Debug("Calling Generators")
      DruidFeral.Generators()
    end
  else
    -- out of combat
    DruidFeral.Cat()
    DruidFeral.Prowl()
  end
end

function DruidFeral.Interrupt()
end
