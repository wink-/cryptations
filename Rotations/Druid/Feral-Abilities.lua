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

local RipCPSpent   = 0 -- This saves how many cp were spent on the last rip (usefull to check if we can apply a stronger rip)
local RakeEnhanced = false -- This saves whether or not the last used rake was enhanced (through stealth or incarnation)

function OnTargetSwitch()
  RipCPSpent    = 0
  RakeEnhanced  = false
end

function DFRakeDebuffDuration()
  if Player.HasTalent(6, 2) then
    return 10
  end

  return 15
end

function DFRakeIntervalSec()
  if Player.HasTalent(6, 2) then
    return 2
  end

  return 3
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

function DFProwl()
  local Target = GetObjectWithGUID(UnitGUID("target"))
  if Target ~= nil
  and UnitHealth(Target) ~= 0
  and not Buff.Has(PlayerUnit, 5215)
  and Unit.IsHostile(Target)
  and Spell.CanCast(5215)
  and Unit.IsInRange(PlayerUnit, Target, 20) then
    return Spell.Cast(5215)
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
  local Energy    = UnitPower("player", 3)
  local MaxEnergy = UnitPowerMax("player", 3)
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
  local Energy      = UnitPower("player", 3)
  local ComboPoints = UnitPower("player", 4)
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
  local GCD          = Player.GetGCDDuration()
  local ComboPoints  = UnitPower("player", 4)
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
  local ComboPoints    = UnitPower("player", 4)
  local MaxComboPoints = UnitPowerMax("player", 4)
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
  local ComboPoints = UnitPower("player", 4)
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
  local Energy    = UnitPower("player", 3)
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
  and not Unit.IsTanking(PlayerUnit, PlayerTarget)
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

-- same as above but with multidot support
function DFRakeV5()
  local Target = Group.FindDoTTarget(1822, 155722, 3)
  local HasDebuff, _, RemainingTime = Debuff.Has(Target, 155722)
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

function DFBrutalSlashV1()
  local Energy      = UnitPower("player", 3)
  local BSCharges   = Spell.GetCharges(202028)
  local ChargeTime  = Spell.GetRemainingChargeTime(202028)
  local GCD         = Player.GetGCDDuration()
  if PlayerTarget ~= nil
  and Spell.CanCast(202028, nil, 3, 20)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Energy >= 35
  and ((BSCharges >= 2 and ChargeTime <= GCD)
  or #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") > 1) then -- TODO: add TTD
    return Spell.Cast(202028)
  end
end

function DFMoonfire()
  local Target = Group.FindDoTTarget(8921, 155625, 5)
  if Target == nil or not ObjectExists(Target) then return end
  local HasDebuff, _, RemainingTime = Debuff.Has(Target, 155625)
  if Spell.CanCast(8921, Target)
  and (HasDebuff ~= true or RemainingTime < 4)
  and Debuff.Has(Target, 155722) then -- TODO: add TTD
    return Spell.Cast(8921, Target)
  end
end

function DFThrashV1()
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 106830)
  if PlayerTarget ~= nil
  and Spell.CanCast(77758, nil, 3, 50)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3
  and (HasDebuff ~= true or RemainingTime < 4) then
    return Spell.Cast(77758)
  end
end

function DFSwipeV1()
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 106830)
  if PlayerTarget ~= nil
  and Spell.CanCast(106785, nil, 3, 45)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3
  and (HasDebuff == true and RemainingTime >= 4) then
    return Spell.Cast(106785)
  end
end


function DFThrashV2()
  local HasT19Bonus2                = Player.HasSetPiece(2)
  local TCRank                      = Player.ArtifactTraitRank(238048)
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 106830)
  if PlayerTarget ~= nil
  and Spell.CanCast(106830, nil, 3, 50)
  and (HasT19Bonus2 or TCRank >= 4)
  and (HasDebuff ~= true or RemainingTime < 4)
  and IsEquippedItem(137056) then
    return Spell.Cast(106830)
  end
end

function DFThrashV3()
  local HasT19Bonus4                = Player.HasSetPiece(4)
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 106830)
  if PlayerTarget ~= nil
  and Spell.CanCast(106830, nil, 3, 50)
  and (HasT19Bonus4)
  and (HasDebuff ~= true or RemainingTime < 4)
  and Buff.Has(PlayerUnit, 135700)
  and not Buff.Has(PlayerUnit, 145152) then
    return Spell.Cast(106830)
  end
end

function DFShred()
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 155722)
  local Energy    = UnitPower("player", 3)
  local MaxEnergy = UnitPowerMax("player", 3)
  if PlayerTarget ~= nil
  and Spell.CanCast(5221, PlayerTarget, 3, 40)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") < 3
  and ((HasDebuff == true and RemainingTime > DFRakeIntervalSec())
  or (MaxEnergy - Energy) < 1) then
    return Spell.Cast(5221, PlayerTarget)
  end
end

function DFThrashV4()
  local HasT19Bonus2                = Player.HasSetPiece(2)
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 106830)
  if PlayerTarget ~= nil
  and Spell.CanCast(106830, nil, 3, 50)
  and (HasT19Bonus2)
  and (HasDebuff ~= true or RemainingTime < 4) then
    return Spell.Cast(106830)
  end
end

function DFBrutalSlashV2()
  local HasT19Bonus2                = Player.HasSetPiece(2)
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 106830)
  if PlayerTarget ~= nil
  and Spell.CanCast(202028, nil, 3, 20)
  and (not HasT19Bonus2 or (HasDebuff == true and RemainingTime >= 4)) then
    return Spell.Cast(202028)
  end
end

function DFThrashV5()
  if PlayerTarget ~= nil
  and Spell.CanCast(106830, nil, 3, 50)
  and IsEquippedItem(137056) then
    return Spell.Cast(106830)
  end
end

function DFSwipeV2()
  local HasT19Bonus2                = Player.HasSetPiece(2)
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 106830)
  if PlayerTarget ~= nil
  and Spell.CanCast(106785, nil, 3, 45)
  and (not HasT19Bonus2 or (HasDebuff == true and RemainingTime >= 4)) then
    return Spell.Cast(106785)
  end
end
