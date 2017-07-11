local ClassID = select(3, UnitClass("player"))
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
  if Spell.CanCast(31884) and Debuff.Has(PlayerTarget, 197277)
  and Unit.IsInAttackRange(85256, PlayerTarget) then
    return Spell.Cast(31884)
  end
end

function PRShieldOfVengeance()
  if Spell.CanCast(184662)
  and Unit.PercentHealth(PlayerUnit) ~= 100 then
    return Spell.Cast(184662)
  end
end

function PRCrusade()
  if Spell.CanCast(231895)
  and HolyPower == 5 then
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
  if HolyPower <= 1
  and Player.HasArtifactTrait(179546)
  and Spell.CanCast(205273)
  and Unit.IsFacing(PlayerTarget, 90) then
    return Spell.Cast(205273)
  end
end

-- TODO: add Righteous Verdict support if useful
function PRBladeOfJustice()
  if PlayerTarget ~= nil
  and not select(4, GetTalentInfo(4, 3, 1))
  and Spell.CanCast(184575, PlayerTarget) then
    Spell.Cast(184575, PlayerTarget)
  end
end

-- TODO: add Righteous Verdict support if useful
function PRDivineHammer()
  if PlayerTarget ~= nil
  and select(4, GetTalentInfo(4, 3, 1))
  and Spell.CanCast(198034, PlayerTarget) then
    Spell.Cast(198034, PlayerTarget)
  end
end

function PRZeal()
  if PlayerTarget ~= nil
  and select(4, GetTalentInfo(2, 2, 1))
  and Spell.CanCast(217020, PlayerTarget) then
    Spell.Cast(217020, PlayerTarget)
  end
end

function PRCrusaderStrike()
  if PlayerTarget ~= nil
  and not select(4, GetTalentInfo(2, 2, 1))
  and Spell.CanCast(35395, PlayerTarget) then
    Spell.Cast(35395, PlayerTarget)
  end
end

function PRJusticarsVengeance()
  if HolyPower == 5
  and Unit.PercentHealth(PlayerUnit) <= 80
  and Spell.CanCast(215661) then
    return Spell.Cast(215661)
  end
end

function PREyeForAnEye()
  if Unit.PercentHealth(PlayerUnit) <= 80
  and Spell.CanCast(205191) then
    Spell.Cast(205191)
  end
end

function PRWordOfGlory()
  if getn(Unit.GetUnitsBelowHealth(80, "friendly", true, PlayerUnit, 15)) >= 3
  and Spell.CanCast(210191) then
    Spell.Cast(210191)
  end
end

function PRJudgment_Debuff()
  if HolyPower >= 3 or (HolyPower >= 2
  and select(4, GetTalentInfo(2, 1, 1)))
  and TTD >= JudgmentTTD
  and Unit.IsInAttackRange(85256, PlayerTarget)
  and Spell.CanCast(20271, PlayerTarget) and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(20271, PlayerTarget)
  end
end

function PRExecutionSentence()
  if PlayerTarget ~= nil
  and select(4, GetTalentInfo(1, 2, 1))
  and Spell.CanCast(213757, PlayerTarget, 9, 3) then
      return Spell.Cast(213757, PlayerTarget)
  end
end

function PRDivineStorm_AOE()
  if PlayerTarget~= nil
  -- and Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3
  and Spell.CanCast(53385, nil, 9, 3) then
    if Debuff.Has(PlayerTarget, 197277)
    -- or Spell.GetRemainingCooldown(20271) >= 1
    -- or TTD < JudgmentTTD
    then
      return Spell.Cast(53385)
    end
  end
end

function PRDivineStorm_ST()
  if PlayerTarget~= nil
  and Spell.CanCast(53385, nil, 9, 3) then
    local HasBuff, Stacks, RemainingTime = Buff.Has(PlayerTarget, 151813)
    if HasBuff ~= nil
    and HasBuff == true
    and Stacks >= 25 then
    -- or Spell.GetRemainingCooldown(20271) >= 1
    -- or TTD < JudgmentTTD
      return Spell.Cast(53385)
    end
  end
end

function PRTemplarsVerdict()
  if PlayerTarget ~= nil
  and Spell.CanCast(85256, PlayerTarget, 9, 3) then
    if Debuff.Has(PlayerTarget, 197277, true)
    -- or Spell.GetRemainingCooldown(20271) >= 1
    -- or TTD < JudgmentTTD
    then
      return Spell.Cast(85256, PlayerTarget)
    end
  end
end
