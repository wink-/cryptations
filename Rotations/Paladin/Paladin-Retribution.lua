local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Paladin - Retribution.JSON")

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

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

-- Use Blade or Hammer
BladeOrHammer = nil
if select(4, GetTalentInfo(4, 3, 1)) then BladeOrHammer = 198034
else BladeOrHammer = 184575 end

-- Use Strike or Zeal
StrikeOrZeal = nil
if select(4, GetTalentInfo(2, 2, 1)) then StrikeOrZeal = 217020
else StrikeOrZeal = 35395 end

function Pulse()
  local MaxMana           = UnitPowerMax(PlayerUnit , 0)
  local MaxHealth         = UnitHealthMax(PlayerUnit)
  local HolyPower         = UnitPower(PlayerUnit, 9)

  -- combat rotation
  if UnitAffectingCombat(PlayerUnit)
  or (AllowOutOfCombatRoutine and UnitGUID("target") ~= nil
  and Unit.IsHostile("target")) and UnitHealth("target") ~= 0 then

    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))
    local ttd = Unit.ComputeTTD(PlayerTarget)

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

    -- COOLDOWNLS

    -- Avenging Wrath (On Cooldown, when Judgment debuff is applied on target and when in melee range)
    if Spell.CanCast(31884) and Debuff.Has(PlayerTarget, 197277)
    and Unit.IsInAttackRange(85256, PlayerTarget) then
      return Spell.Cast(31884)
    end

    -- Shield of Vengeance (Use when below 70% health (defensive) or when 3 Enemy Units are within 8 yards (offensive))
    if Spell.CanCast(184662) then
      if Unit.PercentHealth(PlayerUnit) <= 70 then
        return Spell.Cast(184662)
      elseif getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= 3 then
        return Spell.Cast(184662)
      end
    end

    -- Crusade (Talent, Use on Cooldown)
    if Spell.CanCast(231895) then
      return Spell.Cast(231895)
    end

    -- Holy Wrath (Use when 4 Enemys are around and Health is below 50%)
    if Spell.CanCast(210220) and Unit.PercentHealth(PlayerUnit) <= 50
    and getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= 4 then
      return Spell.Cast(210220)
    end

    -- ROTATION --

    -- Holy Power Generating Phase --

    -- Don't overcap Holy Power
    -- Only cast during Judgment debuff when there is need to generate Holy Power
    -- or when ttd of target < specified threshold
    if (HolyPower < 5 and not Debuff.Has(PlayerTarget, 197277)) or HolyPower < 3 then
      -- Consecration (Use when at least 2 targets within 8 yards and not moving)
      if Spell.CanCast(205228) and not Unit.IsMoving(PlayerUnit)
      and getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= 2 then
        return Spell.Cast(205228)
      end

      -- Wake of Ashes (Use when having the Ashes to Ashes trait
      -- to generate Holy Power during Judgment debuff)
      if HolyPower == 0 and Player.HasArtifactTrait(179546) and Spell.CanCast(205273)
      and Unit.IsFacing(PlayerTarget, 90) then
        return Spell.Cast(205273)

      -- Crusader Strike (or Zeal if Talented)
      -- At least one charge used and charging
      elseif ((select(1, GetSpellCharges(StrikeOrZeal)) ~= 0 and not Spell.CanCast(BladeOrHammer))
      or (select(1, GetSpellCharges(StrikeOrZeal)) > 1 and Spell.CanCast(BladeOrHammer)))
      and HolyPower <= 4
      and Spell.CanCast(StrikeOrZeal, PlayerTarget, nil, nil, false) then
        return Spell.Cast(StrikeOrZeal)

      -- Blade of Justice (or Divine Hammer talent)
      -- Use together with Righteous Verdict if available
      elseif Spell.CanCast(BladeOrHammer, PlayerTarget, nil, nil, false) then
        -- Use Spender before using Blade of Justice to benefit from Righteous Verdict
        if Player.HasArtifactTrait(238062) and HolyPower >= 3 then
          -- Use AOE Spender (Divine Storm)
          if getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= HolyPowerAOESpenderUnitThrehsold
          and Spell.CanCast(53385) then
            local Sequence = {53385, BladeOrHammer}
            return Spell.AddToQueue(Sequence)
          end
          -- Use ST Spender (Templar's Verdict)
          if Spell.CanCast(85256, PlayerTarget) and Unit.IsInLOS(PlayerTarget) then
            local Sequence = {85256, BladeOrHammer}
            return Spell.AddToQueue(Sequence)
          end
        elseif HolyPower <= 3 then
          -- Use without Spender
          return Spell.Cast(BladeOrHammer)
        end
      end
    end

    -- Phase Independent Spells --

    -- Justicar's Vengeance (Talent, use if 5 HolyPower and below 80% health)
    if HolyPower == 5 and Unit.PercentHealth(PlayerUnit) <= 80 and Spell.CanCast(215661) then
      return Spell.Cast(215661)
    end

    -- Eye for an Eye (Talent, use when below 80% health)
    if Unit.PercentHealth(PlayerUnit) <= 80 and Spell.CanCast(205191) then
      Spell.Cast(205191)
    end

    -- Word of Glory (Talent, use when 3 units within 15 yards are below 80% health)
    if getn(Unit.GetUnitsBelowHealth(80, "friendly", true, PlayerUnit, 15)) >= 3
    and Spell.CanCast(210191) then
      Spell.Cast(210191)
    end

    -- Holy Power Spending Phase --

    -- Judgment (Cast when Holy Power >= 4)
    if HolyPower >= 4 and ttd >= JudgmentTTD
    and not Debuff.Has(PlayerTarget, 197277) and Unit.IsInAttackRange(85256, PlayerTarget)
    and Spell.CanCast(20271, PlayerTarget) and Unit.IsInLOS(PlayerTarget) then
      return Spell.Cast(20271, PlayerTarget)
    end

    -- Execution Sentence (Talent, Cast during Judgment debuff)
    if Spell.CanCast(213757, PlayerTarget, 9, 3) then
      if (Debuff.Has(PlayerTarget, 197277) or Spell.GetRemainingCooldown(20271) >= 1
      or ttd < JudgmentTTD) and Unit.IsInLOS(PlayerTarget) then
        return Spell.Cast(213757, PlayerTarget)
      end
    end

    -- Templar's Verdict (Cast during Judgment debuff)
    -- or Divine Storm during AOE
    if Debuff.Has(PlayerTarget, 197277) or Spell.GetRemainingCooldown(20271) >= 1
    or ttd < JudgmentTTD then
      if getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= HolyPowerAOESpenderUnitThreshold
      and Spell.CanCast(53385, nil, 9, 3) then
        return Spell.Cast(53385)
      elseif Spell.CanCast(85256, PlayerTarget, 9, 3) then
        return Spell.Cast(85256, PlayerTarget)
      end
    end
  else
    -- out of combat
  end
end

function Interrupt(unit)
  -- Rebuke
  if Spell.CanCast(96231, unit) and Unit.IsInLOS(unit) then
    return Spell.Cast(96231, unit)
  end

  -- Blinding Light
  if Spell.CanCast(115750) and Unit.IsInLOS(unit) and Unit.IsInRange(PlayerUnit, unit, 10) then
    return Spell.Cast(115750, unit)
  end

  -- Hammer of Justice
  -- TODO: fix using this on bosses
  if Spell.CanCast(853, unit) and Unit.IsInLOS(unit) and not Unit.IsBoss(unit) then
    return Spell.Cast(853, unit)
  end
end
