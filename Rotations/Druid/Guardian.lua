local DruidGuardian = LibStub("DruidGuardian")
local Unit          = LibStub("Unit")
local Rotation      = LibStub("Rotation")

function DruidGuardian.Initialize()
  -- load profile content
  local wowdir = GetWoWDirectory()
  local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
  local content = ReadFile(profiledir .. "Druid-Guardian.JSON")

  if content == nil or content == "" then
    return message("Error loading config file. Please contact the Author.")
  end

  local Settings = json.decode(content)

  Taunt           = Settings.Taunt
  Interrupt       = Settings.Interrupt
  InterruptAny    = Settings.InterruptAny
  InterruptMin    = Settings.InterruptMin
  InterruptMax    = Settings.InterruptMax
  AutoEngage      = Settings.AutoEngage
  AutoTarget      = Settings.AutoTarget
  TargetMode      = Settings.TargetMode
  Incarnation     = Settings.Incarnation
  BristlingFur     = Settings.BristlingFur
  SurvInstincts   = Settings.SurvInstincts
  Barkskin        = Settings.Barkskin
  Ironfur         = Settings.Ironfur
  FRegen          = Settings.FRegen
  Moonfire        = Settings.Moonfire
  Maul            = Settings.Maul
  RotS            = Settings.RotS
  AutoSwitchForm  = Settings.AutoSwitchForm
  SIHealth        = Settings.SIHealth
  BSHealth        = Settings.BSHealth
  IFHealth        = Settings.IFHealth
  FRHealth        = Settings.FRHealth
  MaulHealth      = Settings.MaulHealth
  MaulRage        = Settings.MaulRage
  RotSHealth      = Settings.RotSHealth
  PauseHotkey     = Settings.PauseHotkey
  AoEHotkey       = Settings.AoEHotkey
  CDHotkey        = Settings.CDHotkey
  MaxMana         = UnitPowerMax("player" , 0)
  MaxHealth       = UnitHealthMax("player")

  KeyCallbacks = {
    [PauseHotkey] = Rotation.TogglePause,
    [AoEHotkey] = Rotation.ToggleAoE,
    [CDHotkey] = Rotation.ToggleCD
  }

  -- set function variables
  Pulse = DruidGuardian.Pulse
  Interrupt = DruidGuardian.Interrupt
  Taunt = DruidGuardian.Taunt
  print("Guardian Druid loaded. Have fun.")
end

function DruidGuardian.Pulse()
  -- Call Taunt engine
  if Taunt then
    Rotation.Taunt()
  end

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

    DruidGuardian.SwitchToBearForm()
    DruidGuardian.Incarnation()
    DruidGuardian.SurvivalInstincts()
    DruidGuardian.Barkskin()
    DruidGuardian.RotS()
    DruidGuardian.Ironfur()
    DruidGuardian.BristlingFur()
    DruidGuardian.FrenziedRegeneration()
    DruidGuardian.LunarBeam()
    DruidGuardian.Pulverize()
    DruidGuardian.Moonfire()
    DruidGuardian.Mangle()
    DruidGuardian.Thrash()
    DruidGuardian.Maul()
    DruidGuardian.Swipe()
  else
    -- out of combat rotation
    DruidGuardian.SwitchToBearForm()
  end
end

function DruidGuardian.Taunt(Target)
  if Target ~= nil
  and Spell.CanCast(SB["Growl"], Target)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Growl"], Target)
  end

  if Target ~= nil
  and Moonfire
  and Spell.CanCast(SB["Moonfire"], Target)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Moonfire"], Target)
  end
end

function DruidGuardian.Interrupt(Target)
  if Target ~= nil
  and Spell.CanCast(SB["Skull Bash"], Target)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Skull Bash"], Target)
  end

  if Target ~= nil
  and Spell.CanCast(SB["Mighty Bash"], Target)
  and Unit.IsInLOS(Target)
  and not Unit.IsBoss(Target) then
    return Spell.Cast(SB["Mighty Bash"], Target)
  end

  if Target ~= nil
  and Spell.CanCast(SB["Incapacitating Roar"], Target)
  and Unit.IsInRange(PlayerUnit, Target, 10) then
    return Spell.Cast(SB["Incapacitating Roar"], Target)
  end
end
