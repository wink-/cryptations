local _, _, ClassID = UnitClass("player")
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
  if Buff.Has(PlayerUnit, AB["Berserk"]) then
    EnergyNeeded = EnergyNeeded / 2
  elseif Buff.Has(PlayerUnit, AB["Incarnation: King of the Jungle"]) then
    EnergyNeeded = EnergyNeeded * 0.4
  end

  return EnergyNeeded * 2
end

function IsRakeEnhanced()
  if Buff.Has(PlayerUnit, AB["Incarnation: King of the Jungle"])
  or Buff.Has(PlayerUnit, AB["Prowl"])
  or Buff.Has(PlayerUnit, AB["Shadowmeld"]) then
    RakeEnhanced = true
  else
    RakeEnhanced = false
  end
end

function DFProwl()
  local Target = GetObjectWithGUID(UnitGUID("target"))
  if Target ~= nil
  and UnitHealth(Target) ~= 0
  and not Buff.Has(PlayerUnit, AB["Prowl"])
  and Unit.IsHostile(Target)
  and Spell.CanCast(SB["Prowl"])
  and Unit.IsInRange(PlayerUnit, Target, 20) then
    return Spell.Cast(SB["Prowl"])
  end
end

function DFRakeV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Rake"], PlayerTarget, 3, 35) then
    if Buff.Has(PlayerUnit, AB["Prowl"])
    or Buff.Has(PlayerUnit, AB["Shadowmeld"]) then
      IsRakeEnhanced()
      return Spell.Cast(SB["Rake"], PlayerTarget)
    end
  end
end

function DFTigersFury()
  local Energy    = UnitPower("player", 3)
  local MaxEnergy = UnitPowerMax("player", 3)
  if Spell.CanCast(SB["Tiger's Fury"])
  and Buff.Has(PlayerUnit, AB["Clearcasting"])
  and MaxEnergy - Energy >= 60
  or MaxEnergy - Energy >= 80 then
    return Spell.Cast(SB["Tiger's Fury"])
  end
end

function DFIKotJ()
  if Spell.CanCast(SB["Incarnation: King of the Jungle"])
  and Buff.Has(PlayerUnit, AB["Tiger's Fury"]) then
    return Spell.Cast(SB["Incarnation: King of the Jungle"])
  end
end

function DFBerserk()
  if Spell.CanCast(SB["Berserk"])
  and Buff.Has(PlayerUnit, SB["Tiger's Fury"]) then
    return Spell.Cast(SB["Berserk"])
  end
end

function DFElunesGuidance()
  local Energy      = UnitPower("player", 3)
  local ComboPoints = UnitPower("player", 4)
  if Spell.CanCast(SB["Elune's Guidance"])
  and ComboPoints <= 1
  and Energy >= DFFerociousBiteMaxEnergy() then
    return Spell.Cast(SB["Elune's Guidance"])
  end
end

function DFFerociousBiteV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Ferocious Bite"], PlayerTarget, 3, 25)
  and Debuff.Has(PlayerTarget, AB["Rip"])
  and Debuff.RemainingTime(PlayerTarget, AB["Rip"]) < 1
  and TTD > 3
  and (Unit.PercentHealth(PlayerTarget) < 25 or Player.HasTalent(6, 1)) then
    return Spell.Cast(SB["Ferocious Bite"], PlayerTarget)
  end
end

function DFRegrowthV1()
  local GCD          = Player.GetGCDDuration()
  local ComboPoints  = UnitPower("player", 4)
  if Spell.CanCast(SB["Regrowth"])
  and Player.HasTalent(7, 2)
  and Buff.Has(PlayerUnit, AB["Predatory Swiftness"])
  and not Buff.Has(PlayerUnit, AB["Bloodtalons"])
  and (ComboPoints >= 5 or Buff.RemainingTime(PlayerUnit, AB["Predatory Swiftness"]) <= GCD
  or (ComboPoints == 2 and Spell.GetRemainingCooldown(SB["Ashamane's Frenzy"]) <= GCD)) then
    return Spell.Cast(SB["Regrowth"], PlayerUnit)
  end
end

function DFRegrowthV2()
  if Spell.CanCast(SB["Regrowth"], PlayerUnit)
  and IsEquippedItem(137024)
  and Player.HasTalent(7, 2)
  and not Buff.Has(PlayerUnit, AB["Bloodtalons"])
  and Buff.Stacks(PlayerUnit, AB["Predatory Swiftness"]) > 1 then
    return Spell.Cast(SB["Regrowth"], PlayerUnit)
  end
end

function DFArtifact()
  local ComboPoints    = UnitPower("player", 4)
  local MaxComboPoints = UnitPowerMax("player", 4)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Ashamane's Frenzy"], PlayerTarget)
  and MaxComboPoints - ComboPoints >= 3
  and not Buff.Has(PlayerTarget, AB["Elune's Guidance"]) -- Elune's Guidance
  and (Buff.Has(PlayerUnit, AB["Bloodtalons"]) or not Player.HasTalent(7, 2))
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) or not Player.HasTalent(5, 3)) then
    return Spell.Cast(SB["Ashamane's Frenzy"], PlayerTarget)
  end
end

function DFRipV1()
  local ComboPoints = UnitPower("player", 4)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Rip"], PlayerTarget, 3, 30)
  and (RipCPSpent == 0 or ComboPoints > RipCPSpent
  or Debuff.Has(PlayerTarget, AB["Rip"]) ~= true)
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) or not Player.HasTalent(5, 3)) then
    RipCPSpent = ComboPoints
    return Spell.Cast(SB["Rip"], PlayerTarget)
  end
end

function DFFerociousBiteV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Ferocious Bite"], PlayerTarget, 3, 25)
  and Debuff.Has(AB["Rip"], PlayerTarget)
  and (Player.HasTalent(7, 2) or Unit.PercentHealth(PlayerTarget) < 25)
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) or not Player.HasTalent(5, 3)) then
    return Spell.Cast(SB["Ferocious Bite"], PlayerTarget)
  end
end

function DFRipV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Rip"], PlayerTarget, 3, 30)
  and (Debuff.Has(PlayerTarget, AB["Rip"]) ~= true
  or Debuff.RemainingTime(PlayerTarget, AB["Rip"]) < 7)
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) or not Player.HasTalent(5, 3))
  and not Player.HasTalent(6, 1) then
    return Spell.Cast(SB["Rip"], PlayerTarget)
  end
end

function DFSavageRoar()
  if PlayerTarget ~= nil
  and Spell.CanCast(AB["Savage Roar"], PlayerTarget, 3, 40)
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) ~= true
  or Buff.RemainingTime(PlayerUnit, AB["Savage Roar"]) <= 12) then
    return Spell.Cast(SB["Savage Roar"], PlayerTarget)
  end
end

function DFMaim()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Maim"], PlayerTarget, 3, 35)
  and Buff.Has(PlayerUnit, AB["Fiery Red Maimers"]) then
    return Spell.Cast(SB["Maim"], PlayerTarget)
  end
end

function DFFerociousBiteV3()
  local Energy    = UnitPower("player", 3)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Ferocious Bite"], PlayerTarget, 3, 25)
  and Energy >= DFFerociousBiteMaxEnergy()
  and Debuff.Has(PlayerTarget, AB["Rip"])
  and (Debuff.RemainingTime(PlayerTarget, AB["Rip"]) >= 8
  or not Player.HasTalent(5, 3)) then
    return Spell.Cast(SB["Ferocious Bite"], PlayerTarget)
  end
end

function DFShadowmeld()
  if PlayerTarget ~= nil
  and not Unit.IsTanking(PlayerUnit, PlayerTarget)
  and Spell.CanCast(SB["Shadowmeld"])
  and Buff.Has(PlayerUnit, AB["Tiger's Fury"])
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) or not Player.HasTalent(5, 3))
  and (Buff.Has(PlayerUnit, AB["Bloodtalons"]) or not Player.HasTalent(7, 2))
  and Spell.CanCast(SB["Rake"], PlayerTarget) then
    return Spell.Cast(SB["Shadowmeld"])
  end
end

function DFRakeV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Rake"], PlayerTarget, 3, 35)
  and not Debuff.Has(PlayerTarget, AB["Rake"]) then
    IsRakeEnhanced()
    return Spell.Cast(SB["Rake"], PlayerTarget)
  end
end

function DFRakeV3()
  local Target = Group.FindDoTTarget(SB["Rake"], AB["Rake"], 3)
  if Target ~= nil
  and Spell.CanCast(SB["Rake"], Target, 3, 35)
  and Unit.IsFacing(Target, MeleeAngle)
  and not Player.HasTalent(7, 2)
  and (not Debuff.Has(Target, AB["Rake"])
  or Debuff.RemainingTime(Target, AB["Rake"]) < 5) then
    IsRakeEnhanced()
    return Spell.Cast(SB["Rake"], Target)
  end
end

function DFRakeV4()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Rake"], PlayerTarget, 3, 35)
  and Player.HasTalent(7, 2)
  and Buff.Has(PlayerUnit, AB["Bloodtalons"])
  and Debuff.RemainingTime(PlayerTarget, AB["Rake"]) <= 5
  and TTD > (DFRakeDebuffDuration() / 2)
  and (not RakeEnhanced or (RakeEnhanced
  and Buff.Has(PlayerUnit, AB["Incarnation: King of the Jungle"]))) then
    IsRakeEnhanced()
    return Spell.Cast(SB["Rake"], PlayerTarget)
  end
end

-- same as above but with multidot support
function DFRakeV5()
  local Target = Group.FindDoTTarget(SB["Rake"], AB["Rake"], 3)
  if Target ~= nil
  and Spell.CanCast(SB["Rake"], Target, 3, 35)
  and Unit.IsFacing(Target, MeleeAngle)
  and Player.HasTalent(7, 2)
  and Buff.Has(PlayerUnit, AB["Bloodtalons"])
  and (not Debuff.Has(Target, AB["Rake"])
  or Debuff.RemainingTime(Target, AB["Rake"]) <= 5)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 0
  and (not RakeEnhanced or (RakeEnhanced
  and Buff.Has(PlayerUnit, AB["Incarnation: King of the Jungle"]))) then
    IsRakeEnhanced()
    return Spell.Cast(SB["Rake"], Target)
  end
end

function DFBrutalSlashV1()
  local Energy      = UnitPower("player", 3)
  local BSCharges   = Spell.GetCharges(SB["Brutal Slash"])
  local ChargeTime  = Spell.GetRemainingChargeTime(SB["Brutal Slash"])
  local GCD         = Player.GetGCDDuration()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Brutal Slash"], nil, 3, 20)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Energy >= 35
  and ((BSCharges >= 2 and ChargeTime <= GCD)
  or #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") > 1) then -- TODO: add TTD
    return Spell.Cast(SB["Brutal Slash"])
  end
end

function DFMoonfire()
  local Target = Group.FindDoTTarget(SB["Moonfire"], AB["Moonfire"], 5)
  if Target == nil or not ObjectExists(Target) then return end
  if Spell.CanCast(SB["Moonfire"], Target)
  and (not Debuff.Has(Target, AB["Moonfire"])
  or Debuff.RemainingTime(Target, AB["Moonfire"]) < 4)
  and Debuff.Has(Target, AB["Rake"]) then -- TODO: add TTD
    return Spell.Cast(SB["Moonfire"], Target)
  end
end

function DFThrashV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Thrash"], nil, 3, 50)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3
  and (not Debuff.Has(PlayerTarget, AB["Thrash"]) or RemainingTime < 4) then
    return Spell.Cast(SB["Thrash"])
  end
end

function DFSwipeV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Swipe Cat"], nil, 3, 45)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3
  and (Debuff.Has(PlayerTarget, AB["Thrash"])
  and Debuff.RemainingTime(PlayerTarget, AB["Thrash"]) >= 4) then
    return Spell.Cast(SB["Swipe Cat"])
  end
end


function DFThrashV2()
  local HasT19Bonus2 = Player.HasSetPiece(2)
  local TCRank       = Player.ArtifactTraitRank(238048)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Thrash"], nil, 3, 50)
  and (HasT19Bonus2 or TCRank >= 4)
  and (not Debuff.Has(PlayerTarget, AB["Thrash"])
  or Debuff.RemainingTime(PlayerTarget, AB["Thrash"]) < 4)
  and IsEquippedItem(137056) then
    return Spell.Cast(SB["Thrash"])
  end
end

function DFThrashV3()
  local HasT19Bonus4 = Player.HasSetPiece(4)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Thrash"], nil, 3, 50)
  and (HasT19Bonus4)
  and (not Debuff.Has(PlayerTarget, AB["Thrash"])
  or Debuff.RemainingTime(PlayerTarget, AB["Thrash"]) < 4)
  and Buff.Has(PlayerUnit, AB["Clearcasting"])
  and not Buff.Has(PlayerUnit, AB["Bloodtalons"]) then
    return Spell.Cast(SB["Thrash"])
  end
end

function DFShred()
  local Energy    = UnitPower("player", 3)
  local MaxEnergy = UnitPowerMax("player", 3)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Shred"], PlayerTarget, 3, 40)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") < 3
  and ((Debuff.Has(PlayerTarget, AB["Rake"])
  and Debuff.RemainingTime(PlayerTarget, AB["Rake"]) > DFRakeIntervalSec())
  or (MaxEnergy - Energy) < 1) then
    return Spell.Cast(SB["Shred"], PlayerTarget)
  end
end

function DFThrashV4()
  local HasT19Bonus2 = Player.HasSetPiece(2)
  if PlayerTarget ~= nil
  and Spell.CanCast(AB["Thrash"], nil, 3, 50)
  and (HasT19Bonus2)
  and (not Debuff.Has(PlayerTarget, AB["Thrash"])
  or Debuff.RemainingTime(PlayerTarget, AB["Thrash"]) < 4) then
    return Spell.Cast(SB["Thrash"])
  end
end

function DFBrutalSlashV2()
  local HasT19Bonus2 = Player.HasSetPiece(2)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Brutal Slash"], nil, 3, 20)
  and (not HasT19Bonus2 or (Debuff.Has(PlayerTarget, AB["Thrash"])
  and Debuff.RemainingTime(PlayerTarget, AB["Thrash"]) >= 4)) then
    return Spell.Cast(SB["Brutal Slash"])
  end
end

function DFThrashV5()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Thrash"], nil, 3, 50)
  and IsEquippedItem(137056) then
    return Spell.Cast(SB["Thrash"])
  end
end

function DFSwipeV2()
  local HasT19Bonus2 = Player.HasSetPiece(2)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Swipe Cat"], nil, 3, 45)
  and (not HasT19Bonus2 or (Debuff.Has(PlayerTarget, AB["Thrash"])
  and Debuff.RemainingTime(PlayerTarget, AB["Thrash"]) >= 4)) then
    return Spell.Cast(SB["Swipe Cat"])
  end
end
