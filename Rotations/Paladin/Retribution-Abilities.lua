local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")
local Group       = LibStub("Group")

function PRAvengingWrathJudgment()
  if Spell.CanCast(31884) and Debuff.Has(PlayerTarget, 197277)
  and Unit.IsInAttackRange(85256, PlayerTarget) then
    return Spell.Cast(31884)
  end
end

function PRShieldOfVengeance()
  if Spell.CanCast(184662) then
    if Unit.PercentHealth(PlayerUnit) <= 70 then
      return Spell.Cast(184662)
    elseif getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= 3 then
      return Spell.Cast(184662)
    end
  end
end

function PRCrusade()
  if Spell.CanCast(231895) then
    return Spell.Cast(231895)
  end
end

function PRHolyWrath()
  if Spell.CanCast(210220) and Unit.PercentHealth(PlayerUnit) <= 50
  and getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= 4 then
    return Spell.Cast(210220)
  end
end

function PRConsecration()
  if Spell.CanCast(205228) and not Unit.IsMoving(PlayerUnit)
  and getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= 2 then
    return Spell.Cast(205228)
  end
end

function PRWakeOfAshes()
  if HolyPower == 0 and Player.HasArtifactTrait(179546) and Spell.CanCast(205273)
  and Unit.IsFacing(PlayerTarget, 90) then
    return Spell.Cast(205273)
  end
end

function PRCrusaderStrikeOrZeal()
  if StrikeOrZeal == nil or BladeOrHammer == nil then return end
  if ((select(1, GetSpellCharges(StrikeOrZeal) ~= 0 and not Spell.CanCast(BladeOrHammer))
  or (select(1, GetSpellCharges(StrikeOrZeal) > 1 and Spell.CanCast(BladeOrHammer)))
  and HolyPower <= 4
  and Spell.CanCast(StrikeOrZeal, PlayerTarget, nil, nil, false) then
    return Spell.Cast(StrikeOrZeal)
  end
end

function PRBoJOrDH()
  if BladeOrHammer == nil then return end
  if Spell.CanCast(BladeOrHammer, PlayerTarget, nil, nil, false) then
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

function PRJusticarsVengeance()
  if HolyPower == 5 and Unit.PercentHealth(PlayerUnit) <= 80 and Spell.CanCast(215661) then
    return Spell.Cast(215661)
  end
end

function PREyeForAnEye()
  if Unit.PercentHealth(PlayerUnit) <= 80 and Spell.CanCast(205191) then
    Spell.Cast(205191)
  end
end

function PRWordOfGlory()
  if getn(Unit.GetUnitsBelowHealth(80, "friendly", true, PlayerUnit, 15)) >= 3
  and Spell.CanCast(210191) then
    Spell.Cast(210191)
  end
end

function PRJudgment()
  if HolyPower >= 4 and ttd >= JudgmentTTD
  and not Debuff.Has(PlayerTarget, 197277) and Unit.IsInAttackRange(85256, PlayerTarget)
  and Spell.CanCast(20271, PlayerTarget) and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(20271, PlayerTarget)
  end
end

function PRExecutionSentence()
  if Spell.CanCast(213757, PlayerTarget, 9, 3) then
    if (Debuff.Has(PlayerTarget, 197277) or Spell.GetRemainingCooldown(20271) >= 1
    or ttd < JudgmentTTD) and Unit.IsInLOS(PlayerTarget) then
      return Spell.Cast(213757, PlayerTarget)
    end
  end
end

function PRDivineStorm()
  if PlayerTarget~= nil
  and Spell.CanCast(53385, nil, 9, 3) then
    if Debuff.Has(PlayerTarget, 197277)
    or Spell.GetRemainingCooldown(20271) >= 1
    or ttd < JudgmentTTD then
      return Spell.Cast(53385)
    end
  end
end

function PRTemplarsVerdict()
  if PlayerTarget ~= nil
  and Spell.CanCast(85256, PlayerTarget, 9, 3) then
    if Debuff.Has(PlayerTarget, 197277) or Spell.GetRemainingCooldown(20271) >= 1
    or ttd < JudgmentTTD then
      return Spell.Cast(85256, PlayerTarget)
    end
  end
end
