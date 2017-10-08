local PaladinRetribution  = LibStub("PaladinRetribution")
local Unit                = LibStub("Unit")
local Rotation            = LibStub("Rotation")
local Debuff              = LibStub("Debuff")

function PaladinRetribution.Initialize()
  -- load profile content
  local wowdir = GetWoWDirectory()
  local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
  local content = ReadFile(profiledir .. "Paladin-Retribution.JSON")

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
  AvengingWrath = Settings.AvengingWrath
  SoV           = Settings.SoV
  Crusade       = Settings.Crusade
  HolyWrath     = Settings.HolyWrath
  JusticarsVeng = Settings.JusticarsVeng
  EfaE          = Settings.EfaE
  WoG           = Settings.WoG
  SoVHealth     = Settings.SoVHealth
  SoVUnits      = Settings.SoVUnits
  HWHealth      = Settings.HWHealth
  HWUnits       = Settings.HWUnits
  JVHealth      = Settings.JVHealth
  EfaEHealth    = Settings.EfaEHealth
  WoGHealth     = Settings.WoGHealth
  WoGUnits      = Settings.WoGUnits
  JudgmentTTD   = Settings.JudgmentTTD
  PauseHotkey   = Settings.PauseHotkey
  AoEHotkey     = Settings.AoEHotkey
  CDHotkey      = Settings.CDHotkey
  MaxMana       = UnitPowerMax("player" , 0)

  KeyCallbacks = {
    [PauseHotkey] = Rotation.TogglePause,
    [AoEHotkey] = Rotation.ToggleAoE,
    [CDHotkey] = Rotation.ToggleCD
  }

  -- set function variables
  Pulse = PaladinRetribution.Pulse
  Interrupt = PaladinRetribution.Interrupt
  print("Retribution Paladin loaded. Have fun.")
end

function PaladinRetribution.SingleTargetSpenders()
  PaladinRetribution.ExecutionSentence()
  -- Justicars Vengeance
  PaladinRetribution.DivineStorm_ST()
  PaladinRetribution.TemplarsVerdict()
end

function PaladinRetribution.Pulse()
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

    -- OPENING SEQUENCE

    -- Judgment
    -- Blade of Justice
    -- Crusader Strike (Skip if Liadrin's Fury or T20 2-piece Bonus)
    -- Crusade + Execution Sentence (if talented) OR Templar's Verdict
    -- Wake of Ashes
    -- Arcane Torrent + Templar's Verdict (If Blood elf and Liadrin's Fury) or Crusader Strike
    -- Templar's Verdict

    PaladinRetribution.HolyWrath()
    PaladinRetribution.Judgment_Debuff()
    PaladinRetribution.Crusade()
    PaladinRetribution.AvengingWrathJudgment()
    PaladinRetribution.ShieldOfVengeance()

    if Debuff.Has(AB["Judgment Retribution"], PlayerTarget, true)
    and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3 then
      PaladinRetribution.DivineStorm_AOE()
    else
      PaladinRetribution.SingleTargetSpenders()
    end

    PaladinRetribution.WakeOfAshes()
    PaladinRetribution.BladeOfJustice()
    PaladinRetribution.DivineHammer()
    PaladinRetribution.Consecration()
    PaladinRetribution.Zeal()
    PaladinRetribution.CrusaderStrike()
    -- Judgment Filler
  else
    -- out of combat
  end
end

function PaladinRetribution.Interrupt(Target)
  PaladinCommon.Rebuke(Target)
  PaladinCommon.BlindingLight(Target)
  PaladinCommon.HammerOfJustice(Target)
end
