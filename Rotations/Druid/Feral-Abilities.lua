local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 2 then return end
if FireHack == nil then return end

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")
local Group       = LibStub("Group")

function DFRakeDebuffDuration()
  if Player.HasTalent(6, 2) then
    return 10
  end

  return 15
end

function DFFerociousBiteMaxEnergy()
  local EnergyNeeded = 25
  if Buff.Has(PlayerUnit, 106951) then
    EnergyNeeded = EnergyNeeded / 2
  elseif Buff.Has(PlayerUnit, 102543) then
    EnergyNeeded = EnergyNeeded * 0.4
  end

  return EnergyNeeded * 2
end

function IsRakeEnhanced()
  if Buff.Has(PlayerUnit, 102543)
  or Buff.Has(PlayerUnit, 5215)
  or Buff.Has(PlayerUnit, 58984) then
    RakeEnhanced = true
  else
    RakeEnhanced = false
  end
end

function DFRakeV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(1822, PlayerTarget, 3, 35) then
    if Buff.Has(PlayerUnit, 5215)
    or Buff.Has(PlayerUnit, 58984) then
      IsRakeEnhanced()
      return Spell.Cast(1822, PlayerTarget)
    end
  end
end

function DFTigersFury()
  if Spell.CanCast(5217)
  and Buff.Has(PlayerUnit, 16870)
  and MaxEnergy - Energy >= 60
  or MaxEnergy - Energy >= 80 then
    return Spell.Cast(5217)
  end
end

function DFIKotJ()
  if Spell.CanCast(102543)
  and Buff.Has(PlayerUnit, 5217) then
    return Spell.Cast(102543)
  end
end

function DFBerserk()
  if Spell.CanCast(106951)
  and Buff.Has(PlayerUnit, 5217) then
    return Spell.Cast(106951)
  end
end

function DFElunesGuidance()
  if Spell.CanCast(202060)
  and ComboPoints <= 1
  and Energy >= DFFerociousBiteMaxEnergy() then
    return Spell.Cast(202060)
  end
end

function DFFerociousBiteV1()
  local HasDebuff, Stacks, RemainingTime = Debuff.Has(PlayerTarget, 1079)
  if PlayerTarget ~= nil
  and Spell.CanCast(22568, PlayerTarget, 3, 25)
  and HasDebuff
  and RemainingTime < 1
  and TTD > 3
  and (Unit.PercentHealth(PlayerTarget) < 25 or Player.HasTalent(6, 1)) then
    return Spell.Cast(22568, PlayerTarget)
  end
end

function DFRegrowthV1()
  local HasBuff, Stacks, RemainingTime = Buff.Has(PlayerUnit, 69369)
  local GCD = Player.GetGCDDuration()
  if Spell.CanCast(8936)
  and Player.HasTalent(7, 2)
  and HasBuff
  and not Buff.Has(PlayerUnit, 145152)
  and (ComboPoints >= 5 or RemainingTime <= GCD
  or (ComboPoints == 2 and Spell.GetRemainingCooldown(210722) <= GCD)) then
    return Spell.Cast(8936, PlayerUnit)
  end
end

function DFRegrowthV2()
  local HasBuff, Stacks, RemainingTime = Buff.Has(PlayerUnit, 69369)
  if Spell.CanCast(8936, PlayerUnit)
  and IsEquippedItem(137024)
  and Player.HasTalent(7, 2)
  and not Buff.Has(PlayerUnit, 145152)
  and Stacks > 1 then
    return Spell.Cast(8936, PlayerUnit)
  end
end

function DFArtifact()
  if PlayerTarget ~= nil
  and Spell.CanCast(210722, PlayerTarget)
  and MaxComboPoints - ComboPoints >= 3
  and not Buff.Has(PlayerTarget, 202060) -- Elune's Guidance
  and (Buff.Has(PlayerUnit, 145152) or not Player.HasTalent(7, 2))
  and (Buff.Has(PlayerUnit, 52610) or not Player.HasTalent(5, 3)) then
    return Spell.Cast(210722, PlayerTarget)
  end
end

function DFRipV1()
  -- TODO: maybe remove the check to cast rip if the target does not already have rip
  local HasDebuff, Stacks, RemainingTime = Debuff.Has(PlayerTarget, 1079)
  if PlayerTarget ~= nil
  and Spell.CanCast(1079, PlayerTarget, 3, 30)
  and (RipCPSpent == 0 or ComboPoints > RipCPSpent or HasDebuff ~= true)
  and (Buff.Has(PlayerUnit, 52610) or not Player.HasTalent(5, 3)) then
    RipCPSpent = ComboPoints
    return Spell.Cast(1079, PlayerTarget)
  end
end

function DFFerociousBiteV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(22568, PlayerTarget, 3, 25)
  and Debuff.Has(1079, PlayerTarget)
  and (Player.HasTalent(7, 2) or Unit.PercentHealth(PlayerTarget) < 25)
  and (Buff.Has(PlayerUnit, 52610) or not Player.HasTalent(5, 3)) then
    return Spell.Cast(22568, PlayerTarget)
  end
end

function DFRipV2()
  local HasDebuff, Stacks, RemainingTime = Debuff.Has(PlayerTarget, 1079)
  if PlayerTarget ~= nil
  and Spell.CanCast(1079, PlayerTarget, 3, 30)
  and (HasDebuff ~= true or RemainingTime < 7)
  and (Buff.Has(PlayerUnit, 52610) or not Player.HasTalent(5, 3))
  and not Player.HasTalent(6, 1) then
    return Spell.Cast(1079, PlayerTarget)
  end
end

function DFSavageRoar()
  local HasBuff, Stacks, RemainingTime = Buff.Has(PlayerUnit, 52610)
  if PlayerTarget ~= nil
  and Spell.CanCast(52610, PlayerTarget, 3, 40)
  and (HasBuff ~= true or RemainingTime <= 12) then
    return Spell.Cast(52610, PlayerTarget)
  end
end

function DFMaim()
  if PlayerTarget ~= nil
  and Spell.CanCast(22570, PlayerTarget, 3, 35)
  and Buff.Has(PlayerUnit, 144354) then -- TODO: make sure this is the right buff id
    return Spell.Cast(22570, PlayerTarget)
  end
end

function DFFerociousBiteV3()
  local HasDebuff, Stacks, RemainingTime = Debuff.Has(PlayerTarget, 1079)
  if PlayerTarget ~= nil
  and Spell.CanCast(22568, PlayerTarget, 3, 25)
  and Energy >= DFFerociousBiteMaxEnergy()
  and RemainingTime ~= nil
  and (RemainingTime >= 8 or not Player.HasTalent(5, 3)) then
    return Spell.Cast(22568, PlayerTarget)
  end
end

function DFShadowmeld()
  if PlayerTarget ~= nil
  and Spell.CanCast(58984)
  and Buff.Has(PlayerUnit, 5217)
  and (Buff.Has(PlayerUnit, 52610) or not Player.HasTalent(5, 3))
  and (Buff.Has(PlayerUnit, 145152) or not Player.HasTalent(7, 2))
  and Spell.CanCast(1822, PlayerTarget) then
    return Spell.Cast(58984)
  end
end

function DFRakeV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(1822, PlayerTarget, 3, 35)
  and not Debuff.Has(PlayerTarget, 155722) then
    IsRakeEnhanced()
    return Spell.Cast(1822, PlayerTarget)
  end
end

-- TODO: test if multidotting works
function DFRakeV3()
  local Target = Group.FindDoTTarget(1822, 155722, 3)
  local HasDebuff, Stacks, RemainingTime = Debuff.Has(Target, 155722)
  if Target ~= nil
  and Spell.CanCast(1822, Target, 3, 35)
  and Unit.IsFacing(Target, MeleeAngle)
  and not Player.HasTalent(7, 2)
  and (HasDebuff ~= true or RemainingTime < 5) then
    IsRakeEnhanced()
    return Spell.Cast(1822, Target)
  end
end

function DFRakeV4()
  local HasDebuff, Stacks, RemainingTime = Debuff.Has(PlayerTarget, 155722)
  if PlayerTarget ~= nil
  and Spell.CanCast(1822, PlayerTarget, 3, 35)
  and Player.HasTalent(7, 2)
  and Buff.Has(PlayerUnit, 145152)
  and RemainingTime <= 5
  and TTD > (DFRakeDebuffDuration() / 2)
  and (not RakeEnhanced or (RakeEnhanced and Buff.Has(PlayerUnit, 102543))) then
    IsRakeEnhanced()
    return Spell.Cast(1822, PlayerTarget)
  end
end

function DFRakeV5()
  local Target = Group.FindDoTTarget(1822, 155722, 3)
  local HasDebuff, Stacks, RemainingTime = Debuff.Has(Target, 155722)
  if Target ~= nil
  and Spell.CanCast(1822, Target, 3, 35)
  and Unit.IsFacing(Target, MeleeAngle)
  and Player.HasTalent(7, 2)
  and Buff.Has(PlayerUnit, 145152)
  and (HasDebuff ~= true or RemainingTime <= 5)
  and getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile")) >= 0
  and (not RakeEnhanced or (RakeEnhanced and Buff.Has(PlayerUnit, 102543))) then
    IsRakeEnhanced()
    return Spell.Cast(1822, Target)
  end
end
