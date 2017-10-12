local DruidFeral  = LibStub("DruidFeral")
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

function DruidFeral.OnTargetSwitch()
  RipCPSpent    = 0
  RakeEnhanced  = false
end

function DruidFeral.RakeDebuffDuration()
  if Player.HasTalent(6, 2) then
    return 10
  end

  return 15
end

function DruidFeral.RakeIntervalSec()
  if Player.HasTalent(6, 2) then
    return 2
  end

  return 3
end

function DruidFeral.FerociousBiteMaxEnergy()
  local EnergyNeeded = 25
  if Buff.Has(PlayerUnit, AB["Berserk"]) then
    EnergyNeeded = EnergyNeeded / 2
  elseif Buff.Has(PlayerUnit, AB["Incarnation: King of the Jungle"]) then
    EnergyNeeded = EnergyNeeded * 0.4
  end

  return EnergyNeeded * 2
end

function DruidFeral.IsRakeEnhanced()
  if Buff.Has(PlayerUnit, AB["Incarnation: King of the Jungle"])
  or Buff.Has(PlayerUnit, AB["Prowl"])
  or Buff.Has(PlayerUnit, AB["Shadowmeld"]) then
    RakeEnhanced = true
  else
    RakeEnhanced = false
  end
end

function DruidFeral.Cat()
  if Spell.CanCast(SB["Cat Form"])
  and not IsMounted()
  and not UnitIsDeadOrGhost("player")
  and not UnitControllingVehicle("player")
  and not Player.IsInShapeshift() then
    return Spell.Cast(SB["Cat Form"])
  end
end

function DruidFeral.Prowl()
  local Target = PlayerTarget()

  if Prowl
  and Target ~= nil
  and Spell.CanCast(SB["Prowl"])
  and not Buff.Has(PlayerUnit, AB["Prowl"])
  and (UnitHealth(Target) ~= 0
  and Unit.IsHostile(Target)
  and Unit.IsInRange(PlayerUnit, Target, 30)
  or ProwlMode == "Always") then
    return Spell.Cast(SB["Prowl"])
  end
end

function DruidFeral.RakeV1()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Rake"], Target, 3, 35) then
    if Buff.Has(PlayerUnit, AB["Prowl"])
    or Buff.Has(PlayerUnit, AB["Shadowmeld"]) then
      DruidFeral.IsRakeEnhanced()
      return Spell.Cast(SB["Rake"], Target)
    end
  end
end

function DruidFeral.TigersFury()
  local Energy    = UnitPower("player", 3)
  local MaxEnergy = UnitPowerMax("player", 3)

  if Spell.CanCast(SB["Tiger's Fury"])
  and Buff.Has(PlayerUnit, AB["Clearcasting"])
  and MaxEnergy - Energy >= 60
  or MaxEnergy - Energy >= 80 then
    return Spell.Cast(SB["Tiger's Fury"])
  end
end

function DruidFeral.IKotJ()
  if Incarnation
  and Spell.CanCast(SB["Incarnation: King of the Jungle"])
  and Buff.Has(PlayerUnit, AB["Tiger's Fury"]) then
    return Spell.Cast(SB["Incarnation: King of the Jungle"])
  end
end

function DruidFeral.Berserk()
  if Berserk
  and Spell.CanCast(SB["Berserk"])
  and Buff.Has(PlayerUnit, SB["Tiger's Fury"]) then
    return Spell.Cast(SB["Berserk"])
  end
end

function DruidFeral.ElunesGuidance()
  local Target      = PlayerTarget()
  local Energy      = UnitPower("player", 3)
  local ComboPoints = UnitPower("player", 4)

  if Target ~= nil
  and Spell.CanCast(SB["Rip"], Target) -- Dummy for range check
  and Spell.CanCast(SB["Elune's Guidance"])
  and ComboPoints <= 1
  and Energy >= DruidFeral.FerociousBiteMaxEnergy() then
    return Spell.Cast(SB["Elune's Guidance"])
  end
end

function DruidFeral.FerociousBiteV1()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Ferocious Bite"], Target, 3, 25)
  and Debuff.Has(Target, AB["Rip"])
  and Debuff.RemainingTime(Target, AB["Rip"]) < 1
  and TTD_TABLE[Target] > 3
  and (Unit.PercentHealth(Target) < 25 or Player.HasTalent(6, 1)) then
    return Spell.Cast(SB["Ferocious Bite"], Target)
  end
end

function DruidFeral.RegrowthV1()
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

function DruidFeral.RegrowthV2()
  if Spell.CanCast(SB["Regrowth"], PlayerUnit)
  and IsEquippedItem(137024)
  and Player.HasTalent(7, 2)
  and not Buff.Has(PlayerUnit, AB["Bloodtalons"])
  and Buff.Stacks(PlayerUnit, AB["Predatory Swiftness"]) > 1 then
    return Spell.Cast(SB["Regrowth"], PlayerUnit)
  end
end

function DruidFeral.Artifact()
  local ComboPoints     = UnitPower("player", 4)
  local MaxComboPoints  = UnitPowerMax("player", 4)
  local Target          = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Ashamane's Frenzy"], Target)
  and MaxComboPoints - ComboPoints >= 3
  and not Buff.Has(Target, AB["Elune's Guidance"])
  and (Buff.Has(PlayerUnit, AB["Bloodtalons"]) or not Player.HasTalent(7, 2))
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) or not Player.HasTalent(5, 3)) then
    return Spell.Cast(SB["Ashamane's Frenzy"], Target)
  end
end

function DruidFeral.RipV1()
  local ComboPoints = UnitPower("player", 4)
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Rip"], Target, 3, 30)
  and (RipCPSpent == 0 or ComboPoints > RipCPSpent
  or Debuff.Has(Target, AB["Rip"]) ~= true)
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) or not Player.HasTalent(5, 3)) then
    RipCPSpent = ComboPoints
    return Spell.Cast(SB["Rip"], Target)
  end
end

function DruidFeral.FerociousBiteV2()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Ferocious Bite"], Target, 3, 25)
  and Debuff.Has(AB["Rip"], Target)
  and (Player.HasTalent(7, 2) or Unit.PercentHealth(Target) < 25)
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) or not Player.HasTalent(5, 3)) then
    return Spell.Cast(SB["Ferocious Bite"], Target)
  end
end

function DruidFeral.RipV2()
  if RipMD then
    local Target = Unit.FindDoTTarget(SB["Rip"], AB["Rip"], RipMDCount)
  else
    local Target = PlayerTarget()
  end

  local ComboPoints = UnitPower("player", 4)

  if Target ~= nil
  and Spell.CanCast(SB["Rip"], Target, 3, 30)
  and Player.IsFacing(Target)
  and (not Debuff.Has(Target, AB["Rip"])
  or Debuff.RemainingTime(Target, AB["Rip"]) < 7)
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) or not Player.HasTalent(5, 3))
  and not Player.HasTalent(6, 1) then
    RipCPSpent = ComboPoints
    return Spell.Cast(SB["Rip"], Target)
  end
end

function DruidFeral.SavageRoar()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Savage Roar"], Target, 3, 40)
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) ~= true
  or Buff.RemainingTime(PlayerUnit, AB["Savage Roar"]) <= 12) then
    return Spell.Cast(SB["Savage Roar"], Target)
  end
end

function DruidFeral.Maim()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Maim"], Target, 3, 35)
  and Buff.Has(PlayerUnit, AB["Fiery Red Maimers"]) then
    return Spell.Cast(SB["Maim"], Target)
  end
end

function DruidFeral.FerociousBiteV3()
  local Energy    = UnitPower("player", 3)
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Ferocious Bite"], Target, 3, 25)
  and Energy >= DruidFeral.FerociousBiteMaxEnergy()
  and Debuff.Has(Target, AB["Rip"])
  and (Debuff.RemainingTime(Target, AB["Rip"]) >= 8
  or not Player.HasTalent(5, 3)) then
    return Spell.Cast(SB["Ferocious Bite"], Target)
  end
end

function DruidFeral.Shadowmeld()
  local Target = PlayerTarget()

  if Shadowmeld
  and Target ~= nil
  and not Unit.IsTanking(PlayerUnit, Target)
  and Spell.CanCast(SB["Shadowmeld"])
  and Buff.Has(PlayerUnit, AB["Tiger's Fury"])
  and (Buff.Has(PlayerUnit, AB["Savage Roar"]) or not Player.HasTalent(5, 3))
  and (Buff.Has(PlayerUnit, AB["Bloodtalons"]) or not Player.HasTalent(7, 2))
  and Spell.CanCast(SB["Rake"], Target) then
    return Spell.Cast(SB["Shadowmeld"])
  end
end

function DruidFeral.RakeV2()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Rake"], Target, 3, 35)
  and not Debuff.Has(Target, AB["Rake"]) then
    DruidFeral.IsRakeEnhanced()
    return Spell.Cast(SB["Rake"], Target)
  end
end

function DruidFeral.RakeV3()
  if RakeMD then
    local Target = Unit.FindDoTTarget(SB["Rake"], AB["Rake"], RakeMDCount)
  else
    local Target = PlayerTarget()
  end

  if Target ~= nil
  and Spell.CanCast(SB["Rake"], Target, 3, 35)
  and Player.IsFacing(Target)
  and not Player.HasTalent(7, 2)
  and (not Debuff.Has(Target, AB["Rake"])
  or Debuff.RemainingTime(Target, AB["Rake"]) < 5) then
    DruidFeral.IsRakeEnhanced()
    return Spell.Cast(SB["Rake"], Target)
  end
end

function DruidFeral.RakeV4()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Rake"], Target, 3, 35)
  and Player.HasTalent(7, 2)
  and Buff.Has(PlayerUnit, AB["Bloodtalons"])
  and Debuff.RemainingTime(Target, AB["Rake"]) <= 5
  and TTD_TABLE[Target] > (DruidFeral.RakeDebuffDuration() / 2)
  and (not RakeEnhanced or (RakeEnhanced
  and Buff.Has(PlayerUnit, AB["Incarnation: King of the Jungle"]))) then
    DruidFeral.IsRakeEnhanced()
    return Spell.Cast(SB["Rake"], Target)
  end
end

function DruidFeral.RakeV5()
  if RakeMD then
    local Target = Unit.FindDoTTarget(SB["Rake"], AB["Rake"], RakeMDCount)
  else
    local Target = PlayerTarget()
  end

  if Target ~= nil
  and Spell.CanCast(SB["Rake"], Target, 3, 35)
  and Player.IsFacing(Target)
  and Player.HasTalent(7, 2)
  and Buff.Has(PlayerUnit, AB["Bloodtalons"])
  and (not Debuff.Has(Target, AB["Rake"])
  or Debuff.RemainingTime(Target, AB["Rake"]) <= 5)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 0
  and (not RakeEnhanced or (RakeEnhanced
  and Buff.Has(PlayerUnit, AB["Incarnation: King of the Jungle"]))) then
    DruidFeral.IsRakeEnhanced()
    return Spell.Cast(SB["Rake"], Target)
  end
end

function DruidFeral.BrutalSlashV1()
  local Energy      = UnitPower("player", 3)
  local BSCharges   = Spell.GetCharges(SB["Brutal Slash"])
  local ChargeTime  = Spell.GetRemainingChargeTime(SB["Brutal Slash"])
  local GCD         = Player.GetGCDDuration()
  local Target      = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Brutal Slash"], nil, 3, 20)
  and Player.IsFacing(Target)
  and Energy >= 35
  and ((BSCharges >= 2 and ChargeTime <= GCD)
  or #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") > 1) then -- TODO: add TTD
    return Spell.Cast(SB["Brutal Slash"])
  end
end

function DruidFeral.Moonfire()
  if MoonfireMD
  and Moonfire then
    local Target = Unit.FindDoTTarget(SB["Moonfire"], AB["Moonfire"], MFMDCount)
  elseif Moonfire then
    local Target = PlayerTarget()
  else
    return
  end

  if Moonfire
  and Target ~= nil
  and Spell.CanCast(SB["Moonfire"], Target)
  and (not Debuff.Has(Target, AB["Moonfire"])
  or Debuff.RemainingTime(Target, AB["Moonfire"]) < 4)
  and Debuff.Has(Target, AB["Rake"]) then -- TODO: add TTD
    return Spell.Cast(SB["Moonfire"], Target)
  end
end

function DruidFeral.ThrashV1()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Thrash Cat"], nil, 3, 50)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3
  and (not Debuff.Has(Target, AB["Thrash Cat"]) or RemainingTime < 4) then
    return Spell.Cast(SB["Thrash Cat"])
  end
end

function DruidFeral.SwipeV1()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Swipe Cat"], nil, 3, 45)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") >= 3
  and (Debuff.Has(Target, AB["Thrash Cat"])
  and Debuff.RemainingTime(Target, AB["Thrash Cat"]) >= 4) then
    return Spell.Cast(SB["Swipe Cat"])
  end
end


function DruidFeral.ThrashV2()
  local HasT19Bonus2 = Player.HasSetPiece(2)
  local TCRank       = Player.ArtifactTraitRank(238048)
  local Target       = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Thrash Cat"], nil, 3, 50)
  and (HasT19Bonus2 or TCRank >= 4)
  and (not Debuff.Has(Target, AB["Thrash Cat"])
  or Debuff.RemainingTime(Target, AB["Thrash Cat"]) < 4)
  and IsEquippedItem(137056) then
    return Spell.Cast(SB["Thrash Cat"])
  end
end

function DruidFeral.ThrashV3()
  local HasT19Bonus4 = Player.HasSetPiece(4)
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Thrash Cat"], nil, 3, 50)
  and (HasT19Bonus4)
  and (not Debuff.Has(Target, AB["Thrash Cat"])
  or Debuff.RemainingTime(Target, AB["Thrash Cat"]) < 4)
  and Buff.Has(PlayerUnit, AB["Clearcasting"])
  and not Buff.Has(PlayerUnit, AB["Bloodtalons"]) then
    return Spell.Cast(SB["Thrash Cat"])
  end
end

function DruidFeral.Shred()
  local Energy    = UnitPower("player", 3)
  local MaxEnergy = UnitPowerMax("player", 3)
  local Target    = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Shred"], Target, 3, 40)
  and Player.IsFacing(Target)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile") < 3
  and ((Debuff.Has(Target, AB["Rake"])
  and Debuff.RemainingTime(Target, AB["Rake"]) > DruidFeral.RakeIntervalSec())
  or (MaxEnergy - Energy) < 1) then
    Rotation.Debug("Casting Shred on " .. ObjectName(Target))
    return Spell.Cast(SB["Shred"], Target)
  end
end

function DruidFeral.ThrashV4()
  local HasT19Bonus2  = Player.HasSetPiece(2)
  local Target        = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(AB["Thrash Cat"], nil, 3, 50)
  and (HasT19Bonus2)
  and (not Debuff.Has(Target, AB["Thrash Cat"])
  or Debuff.RemainingTime(Target, AB["Thrash Cat"]) < 4) then
    return Spell.Cast(SB["Thrash Cat"])
  end
end

function DruidFeral.BrutalSlashV2()
  local HasT19Bonus2  = Player.HasSetPiece(2)
  local Target        = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Brutal Slash"], nil, 3, 20)
  and (not HasT19Bonus2 or (Debuff.Has(Target, AB["Thrash Cat"])
  and Debuff.RemainingTime(Target, AB["Thrash Cat"]) >= 4)) then
    return Spell.Cast(SB["Brutal Slash"])
  end
end

function DruidFeral.ThrashV5()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Thrash Cat"], nil, 3, 50)
  and IsEquippedItem(137056) then
    return Spell.Cast(SB["Thrash Cat"])
  end
end

function DruidFeral.SwipeV2()
  local HasT19Bonus2  = Player.HasSetPiece(2)
  local Target        = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Swipe Cat"], nil, 3, 45)
  and (not HasT19Bonus2 or (Debuff.Has(Target, AB["Thrash Cat"])
  and Debuff.RemainingTime(Target, AB["Thrash Cat"]) >= 4)) then
    return Spell.Cast(SB["Swipe Cat"])
  end
end
