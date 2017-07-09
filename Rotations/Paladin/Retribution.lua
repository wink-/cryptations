local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Paladin-Retribution.JSON")

if json.decode(content) == nil then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

UseInterruptEngine                = Settings.UseInterruptEngine
UseAvengingWrath                  = Settings.UseAvengingWrath
UseShieldOfVengeance              = Settings.UseShieldOfVengeance
UseCrusade                        = Settings.UseCrusade
UseHolyWrath                      = Settings.UseHolyWrath
UseJusticarsVengeance             = Settings.UseJusticarsVengeance
UseEyeForAnEye                    = Settings.UseEyeForAnEye
UseWordOfGlory                    = Settings.UseWordOfGlory
HolyPowerAOESpenderUnitThreshold  = Settings.HolyPowerAOESpenderUnitThreshold
ShieldOfVengeanceHealthThreshold  = Settings.ShieldOfVengeanceHealthThreshold
ShieldOfVengeanceUnitThreshold    = Settings.ShieldOfVengeanceUnitThreshold
HolyWrathHealthThreshold          = Settings.HolyWrathHealthThreshold
HolyWrathUnitThreshold            = Settings.HolyWrathUnitThreshold
JusticarsVengeanceHealthThreshold = Settings.JusticarsVengeanceHealthThreshold
EyeForAnEyeHealthThreshold        = Settings.EyeForAnEyeHealthThreshold
WordOfGloryHealthThreshold        = Settings.WordOfGloryHealthThreshold
WordOfGloryUnitThreshold          = Settings.WordOfGloryUnitThreshold
JudgmentTTD                       = Settings.JudgmentTTD
MaxMana                           = UnitPowerMax("player" , 0)

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

function SingleTargetSpenders()
  PRExecutionSentence()
  -- Justicars Vengeance
  PRDivineStorm_ST()
  PRTemplarsVerdict()
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

    HolyPower = UnitPower("player", 9)

    -- call interrupt engine
    if UseInterruptEngine then
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

    if Debuff.Has(197277, PlayerTarget, true)
    and Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3 then
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

function Interrupt(unit)
  PlayerTarget = unit
  PRebuke()
  PBlindingLight()
  PHammerOfJustice()
end
