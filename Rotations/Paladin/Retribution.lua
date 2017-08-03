local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

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
MaxMana       = UnitPowerMax("player" , 0)

local Unit        = LibStub("Unit")
local Rotation    = LibStub("Rotation")
local Debuff      = LibStub("Debuff")

KeyCallbacks = {
  ["CTRL,P"] = Rotation.TogglePause,
  ["CTRL,A"] = Rotation.ToggleAoE
}

function SingleTargetSpenders()
  PRExecutionSentence()
  -- Justicars Vengeance
  PRDivineStorm_ST()
  PRTemplarsVerdict()
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

    -- OPENING SEQUENCE

    -- Judgment
    -- Blade of Justice
    -- Crusader Strike (Skip if Liadrin's Fury or T20 2-piece Bonus)
    -- Crusade + Execution Sentence (if talented) OR Templar's Verdict
    -- Wake of Ashes
    -- Arcane Torrent + Templar's Verdict (If Blood elf and Liadrin's Fury) or Crusader Strike
    -- Templar's Verdict

    PRHolyWrath()
    PRJudgment_Debuff()
    PRCrusade()
    PRAvengingWrathJudgment()
    PRShieldOfVengeance()

    if Debuff.Has(AB["Judgment Retribution"], PlayerTarget, true)
    and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3 then
      PRDivineStorm_AOE()
    else
      SingleTargetSpenders()
    end

    PRWakeOfAshes()
    PRBladeOfJustice()
    PRDivineHammer()
    PRConsecration()
    PRZeal()
    PRCrusaderStrike()
    -- Judgment Filler
  else
    -- out of combat
  end
end

function Interrupt(Target)
  PRebuke(Target)
  PBlindingLight(Target)
  PHammerOfJustice(Target)
end
