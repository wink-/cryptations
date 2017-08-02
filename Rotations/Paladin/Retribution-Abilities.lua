local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")

function PRAvengingWrathJudgment()
  local Target = PlayerTarget()

  if Spell.CanCast(31884)
  and AvengingWrath
  and Debuff.Has(Target, 197277)
  and Unit.IsInAttackRange(85256, Target) then
    return Spell.Cast(31884)
  end
end

function PRShieldOfVengeance()
  if Spell.CanCast(184662)
  and SoV
  and Unit.PercentHealth(PlayerUnit) ~= 100 then
    return Spell.Cast(184662)
  end
end

function PRCrusade()
  if Crusade
  and Spell.CanCast(231895)
  and HolyPower == 5 then
    return Spell.Cast(231895)
  end
end

function PRHolyWrath()
  if HolyWrath
  and Spell.CanCast(210220)
  and Unit.PercentHealth(PlayerUnit) <= HWHealth
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true) >= HWUnits then
    return Spell.Cast(210220)
  end
end

function PRConsecration()
  if Spell.CanCast(205228)
  and not Unit.IsMoving(PlayerUnit)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true) >= 2 then
    return Spell.Cast(205228)
  end
end

function PRWakeOfAshes()
  local Target = PlayerTarget()

  if HolyPower <= 1
  and Player.ArtifactTraitRank(179546) ~= 0
  and Spell.CanCast(205273)
  and Unit.IsFacing(Target, 90) then
    return Spell.Cast(205273)
  end
end

-- TODO: add Righteous Verdict support if useful
function PRBladeOfJustice()
  local Target = PlayerTarget()

  if Target ~= nil
  and not Player.HasTalent(4, 3)
  and Spell.CanCast(184575, Target) then
    Spell.Cast(184575, Target)
  end
end

-- TODO: add Righteous Verdict support if useful
function PRDivineHammer()
  local Target = PlayerTarget()

  if Target ~= nil
  and Player.HasTalent(4, 3)
  and Spell.CanCast(198034, Target) then
    Spell.Cast(198034, Target)
  end
end

function PRZeal()
  local Target = PlayerTarget()

  if Target ~= nil
  and Player.HasTalent(2, 2)
  and Spell.CanCast(217020, Target) then
    Spell.Cast(217020, Target)
  end
end

function PRCrusaderStrike()
  local Target = PlayerTarget()

  if Target ~= nil
  and not Player.HasTalent(2, 2)
  and Spell.CanCast(35395, Target) then
    Spell.Cast(35395, Target)
  end
end

function PRJusticarsVengeance()
  if HolyPower == 5
  and Unit.PercentHealth(PlayerUnit) <= JVHealth
  and Spell.CanCast(215661) then
    return Spell.Cast(215661)
  end
end

function PREyeForAnEye()
  if EfaE
  and Unit.PercentHealth(PlayerUnit) <= EfaEHealth
  and Spell.CanCast(205191) then
    Spell.Cast(205191)
  end
end

function PRWordOfGlory()
  if WoG
  and #Unit.GetUnitsBelowHealth(WoGHealth, "friendly", true, PlayerUnit, 15) >= WoGUnits
  and Spell.CanCast(210191) then
    Spell.Cast(210191)
  end
end

function PRJudgment_Debuff()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(20271, Target)
  and Unit.IsInAttackRange(85256, Target)
  and Unit.IsInLOS(Target)
  and TTD >= JudgmentTTD
  and (HolyPower >= 3
  or (HolyPower >= 2
  and Player.HasTalent(2, 1))) then
    return Spell.Cast(20271, Target)
  end
end

function PRExecutionSentence()
  local Target = PlayerTarget()

  if Target ~= nil
  and Player.HasTalent(1, 2)
  and Spell.CanCast(213757, Target, 9, 3) then
      return Spell.Cast(213757, Target)
  end
end

function PRDivineStorm_AOE()
  local Target = PlayerTarget()

  if Target~= nil
  -- and Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3
  and Spell.CanCast(53385, nil, 9, 3) then
    if Debuff.Has(Target, 197277)
    -- or Spell.GetRemainingCooldown(20271) >= 1
    -- or TTD < JudgmentTTD
    then
      return Spell.Cast(53385)
    end
  end
end

function PRDivineStorm_ST()
  local Target = PlayerTarget()

  if Target~= nil
  and Spell.CanCast(53385, nil, 9, 3) then
    if Buff.Has(Target, 151813)
    and Stacks >= 25 then
    -- or Spell.GetRemainingCooldown(20271) >= 1
    -- or TTD < JudgmentTTD
      return Spell.Cast(53385)
    end
  end
end

function PRTemplarsVerdict()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(85256, Target, 9, 3) then
    if Debuff.Has(Target, 197277, true)
    -- or Spell.GetRemainingCooldown(20271) >= 1
    -- or TTD < JudgmentTTD
    then
      return Spell.Cast(85256, Target)
    end
  end
end
