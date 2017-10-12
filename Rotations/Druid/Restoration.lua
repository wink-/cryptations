local DruidRestoration  = LibStub("DruidRestoration")
local Unit              = LibStub("Unit")
local Spell             = LibStub("Spell")
local Rotation          = LibStub("Rotation")
local Player            = LibStub("Player")
local BossManager       = LibStub("BossManager")
local Utils             = LibStub("Utils")

function DruidRestoration.Initialize()
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
  EoGHealth       = Settings.EoGHealth
  FLHoTCount      = Settings.FLHoTCount
  RWHealth        = Settings.RWHealth
  PauseHotkey     = Settings.PauseHotkey
  AoEHotkey       = Settings.AoEHotkey
  CDHotkey        = Settings.CDHotkey
  MaxMana         = UnitPowerMax("player", 0)

  KeyCallbacks = {
    [PauseHotkey] = Rotation.TogglePause,
    [AoEHotkey] = Rotation.ToggleAoE,
    [CDHotkey] = Rotation.ToggleCD
  }

  -- set function variables
  Pulse = DruidRestoration.Pulse
  Dispell = DruidRestoration.Dispell
  print("Restoration Druid loaded. Have fun.")
end

function DruidRestoration.Pulse()
  -- Combat Rotation
  if not Unit.IsCastingSpecific(PlayerUnit, SB["Tranquility"])
  and GetNumGroupMembers() > 0 then
    -- Dispell engine
    if Dispell then
      Rotation.Dispell()
    end

    -- pulse target engine and remember target
    Rotation.Target("hostile")

    DruidRestoration.Ironbark()
    DruidRestoration.Lifebloom()
    DruidRestoration.Incarnation()
    DruidRestoration.Swiftmend()
    DruidRestoration.Tranquility()
    DruidRestoration.Innervate()
    DruidRestoration.EoG()
    DruidRestoration.Flourish()
    DruidRestoration.Efflorescence()
    DruidRestoration.RegrowthClearcast()
    DruidRestoration.CenarionWard()
    DruidRestoration.Renewal()
    DruidRestoration.Regrowth()
    DruidRestoration.WildGrowth()
    DruidRestoration.Rejuvenation()
    DruidRestoration.HealingTouch()
    DruidRestoration.SolarWrath()
  end
end

function DruidRestoration.Dispell(unit, dispellType)
  if Spell.CanCast(SB["Nature's Cure"], unit, 0, MaxMana * 0.13)
  and dispellType ~= "Disease" then
    return Spell.Cast(SB["Nature's Cure"], unit)
  end
end
