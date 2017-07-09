local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 1 then return end
if FireHack == nil then return end

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")
local Utils       = LibStub("Utils")
local Group       = LibStub("Group")

function PHAvengingWrath()
  if UseAvengingWrath
  and Spell.CanCast(31842)
  and GetNumGroupMembers() ~= 1
  and Group.AverageHealth() <= AvengingWrathHealthThreshold then
    return Spell.Cast(31842)
  end
end

function PHHolyAvenger()
  if UseHolyAvenger
  and Spell.CanCast(105809)
  and GetNumGroupMembers() ~= 1
  and Group.AverageHealth() <= HolyAvengerHealthThreshold then
    return Spell.Cast(105809)
  end
end

function PHLayOnHands()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and UseLayOnHands
  and Spell.CanCast(633, Target)
  and Unit.PercentHealth(Target) <= LayOnHandsHealthThreshold then
    return Spell.Cast(633, Target)
  end
end

function PHBoS()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and UseBlessingOfSacrifice
  and Spell.CanCast(6940, Target)
  and Spell.CanCast(498)
  and not Buff.Has(Target, 6940)
  and Unit.PercentHealth(Target) <= BlessingOfSacrificeHealthThreshold then
    local Sequence = {498, 6940}
    return Spell.AddToQueue(Sequence, Target)
  end
end

function PHTyrsDeliverance()
  if UseTyrsDeliverance
  and Spell.CanCast(200652) then
    if GetNumGroupMembers() ~= 1
    and Spell.GetPreviousSpell() ~= 200652
    and Group.AverageHealth() <= TyrsDeliveranceHealthThreshold then
      return Spell.Cast(200652)
    end
  end
end

function PHHolyShock()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Spell.CanCast(20473, Target, 0, MaxMana * 0.1)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(20473, Target)
  end
end

function PHHolyLight()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Spell.CanCast(82326, Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(82326, Target)
  end
end

function PHLotM()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Unit.IsMoving(PlayerUnit)
  and not Spell.CanCast(20473, Target, 0, MaxMana * 0.1)
  and Spell.CanCast(183998, Target, 0, MaxMana * 0.075)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(183998, Target)
  end
end

function PHRuleOfLaw()
  if UseRuleOfLaw
  and Spell.CanCast(214202) then
    return Spell.Cast(214202)
  end
end

function PHBoL()
  local Target = Group.TankToHeal()
  if Target ~= nil
  and UseBeaconOfLight
  and not select(4, GetTalentInfo(7, 3, 1))
  and Spell.CanCast(53563, Target, 0, MaxMana * 0.025)
  and Unit.IsInLOS(Target)
  and not Buff.Has(Target, 53563) then
    return Spell.Cast(53563, Target)
  end
end

function PHBoF()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and UseBeaconOfFaith
  and Spell.CanCast(156910, Target, 0, MaxMana * 0.03125)
  and not Buff.Has(Target, 156910)
  and Unit.IsInLOS(Target)
  and not Buff.Has(Target, 53563) then
    return Spell.Cast(156910, Target)
  end
end

function PHBestowFaith()
  local Target = Group.TankToHeal()
  if Target ~= nil
  and Spell.CanCast(223306, Target, 0, MaxMana * 0.06)
  and Unit.IsInLOS(Target)
  and not Buff.Has(Target, 223306)
  and Unit.PercentHealth(Target) <= BestowFaithThreshold then
    return Spell.Cast(223306, Target)
  end
end

function PHInfusionProc()
  if Buff.Has(PlayerUnit, 53576) then
    if UseHolyLightOnInfusion then
      PHHolyLight()
    elseif UseFlashOfLightOnInfusion then
      PHFlashOfLight()
    end
  end
end

function PHJudgment()
  if UseJudgment
  and PlayerTarget ~= nil
  and IsSpellKnown(183778)
  and Spell.CanCast(20271, PlayerTarget, 0, MaxMana * 0.03)
  and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(20271, PlayerTarget)
  end
end

function PHLightsHammerTarget()
  -- Find best fitting unit
  local GroupMembers = Player.GetGroupMembers()
  local BestUnit = nil
  local BestUnitTargetCount = 0
  for i = 1, getn(GroupMembers) do
    if (BestUnitTargetCount == 0
    and getn(Unit.GetUnitsBelowHealth(LightsHammerHealthThreshold, "friendly", true, GroupMembers[i], 10)) >= LightsHammerUnitThreshold)
    or (BestUnitTargetCount ~= 0
    and getn(Unit.GetUnitsBelowHealth(LightsHammerHealthThreshold, "friendly", true, GroupMembers[i], 10)) >= BestUnitTargetCount) then
      BestUnit = GroupMembers[i]
      BestUnitTargetCount = getn(Unit.GetUnitsBelowHealth(LightsHammerHealthThreshold, "friendly", true, GroupMembers[i], 10))
    end
  end
end

function PHLightsHammer()
  if UseLightsHammer and Spell.CanCast(114158, nil, 0, MaxMana * 0.28)
  and BestUnit ~= nil then
    -- Place Hammer in center of suitable units (if in range)
    local Units = Unit.GetUnitsBelowHealth(LightsHammerHealthThreshold, "friendly", true, BestUnit, 10)
    local x, y, z = Unit.GetCenterBetweenUnits(Units)
    return Spell.CastGroundSpell(114158, x, y, z)
  end
end

function PHLoD()
  if UseLightofDawn
  and Spell.CanCast(85222, nil, 0, MaxMana * 0.14) then
    -- Rule of Law
    if Buff.Has(PlayerUnit, 214202)
    and (getn(Unit.GetUnitsInCone(PlayerUnit, ConeAngle, 22.5, "friendly", true, LightOfDawnHealthThreshold))
    >= LightOfDawnUnitThreshold) then
      return Spell.Cast(85222)
    -- Beacon of the Lightbringer
    elseif select(4, GetTalentInfo(7, 2, 1))
    and (getn(Unit.GetUnitsInCone(PlayerUnit, ConeAngle, 19.5, "friendly", true, LightOfDawnHealthThreshold))
    >= LightOfDawnUnitThreshold) then
      return Spell.Cast(85222)
    -- Standard
  elseif (getn(Unit.GetUnitsInCone(PlayerUnit, ConeAngle, 15, "friendly", true, LightOfDawnHealthThreshold))
    >= LightOfDawnUnitThreshold) then
      return Spell.Cast(85222)
    end
  end
end

function PHHolyPrismTarget()
  local BestTarget        = nil
  local UnitCountBest     = 0
  local UnitCountCurrent  = 0
  local CurrentObject     = nil
  local Units             = nil
  local ObjectCount       = GetObjectCount()
  for i = 1, ObjectCount do
    CurrentObject = GetObjectWithIndex(i)
    if ObjectIsType(CurrentObject, ObjectTypes.Unit)
    and ObjectExists(CurrentObject)
    and Unit.IsInLOS(CurrentObject)
    and Unit.IsHostile(CurrentObject) then
      Units = Unit.GetUnitsInRadius(CurrentObject, 15, "friendly", true)
      UnitCountCurrent = getn(Units)
      if UnitCountCurrent >= HolyPrismUnitThreshold
      and UnitCountCurrent > UnitCountBest then
        UnitCountBest = UnitCountCurrent
        BestTarget = CurrentObject
      end
    end
  end

  return BestTarget
end

function PHHolyPrism()
  local Target = PHHolyPrismTarget()
  if Target ~= nil
  and UseHolyPrism
  and Spell.CanCast(114165, Target, 0, MaxMana * 0.17) then
    return Spell.Cast(114165, Target)
  end
end

function PHBoV()
  local Target = Unit.FindBestToHeal(30, BeaconOfVirtueUnitThreshold, BeaconOfVirtueHealthThreshold)
  if Target ~= nil
  and UseBeaconOfVirtue
  and Spell.CanCast(200025, Target, 0, MaxMana * 0.1)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(200025, Target)
  end
end

function PHFlashOfLight()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Unit.PercentHealth(Target) <= FlashOfLightThreshold
  and Spell.CanCast(82326, Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(82326, Target)
  end
end
