local _, _, ClassID = UnitClass("player")
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
  if AvengingWrath
  and Spell.CanCast(31842)
  and GetNumGroupMembers() ~= 1
  and Group.AverageHealth() <= AWHealth then
    return Spell.Cast(31842)
  end
end

function PHHolyAvenger()
  if HolyAvenger
  and Spell.CanCast(105809)
  and GetNumGroupMembers() ~= 1
  and Group.AverageHealth() <= HAHealth then
    return Spell.Cast(105809)
  end
end

function PHLayOnHands()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and LayOnHands
  and Spell.CanCast(633, Target)
  and Unit.PercentHealth(Target) <= LoHHealth then
    return Spell.Cast(633, Target)
  end
end

function PHBoS()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and BoS
  and Spell.CanCast(6940, Target)
  and Spell.CanCast(498)
  and not Buff.Has(Target, 6940)
  and Unit.PercentHealth(Target) <= BoSHealth then
    local Sequence = {498, 6940}
    return Spell.AddToQueue(Sequence, Target)
  end
end

function PHTyrsDeliverance()
  local TargetUnits = Unit.GetUnitsInRadius(PlayerUnit, 15, "friendly")
  if TyrsDeliverance
  and Spell.CanCast(200652) then
    if GetNumGroupMembers() ~= 1
    and #TargetUnits >= TDUnits
    and Spell.GetPreviousSpell() ~= 200652
    and Group.AverageHealthCustom(TargetUnits) <= TDHealth then
      return Spell.Cast(200652)
    end
  end
end

function PHHolyShock()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Unit.PercentHealth(Target) <= HSHealth
  and Spell.CanCast(20473, Target, 0, MaxMana * 0.1)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(20473, Target)
  end
end

function PHHolyLight()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Unit.PercentHealth(Target) <= HLHealth
  and Spell.CanCast(82326, Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(82326, Target)
  end
end

function PHLotM()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and LotM
  and Unit.IsMoving(PlayerUnit)
  and not Spell.CanCast(20473, Target, 0, MaxMana * 0.1)
  and Spell.CanCast(183998, Target, 0, MaxMana * 0.075)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(183998, Target)
  end
end

function PHRuleOfLaw()
  if RuleOfLaw
  and Spell.CanCast(214202) then
    return Spell.Cast(214202)
  end
end

function PHBoL()
  local Target = Group.TankToHeal()
  if Target ~= nil
  and BoL
  and not Player.HasTalent(7, 3)
  and Spell.CanCast(53563, Target, 0, MaxMana * 0.025)
  and Unit.IsInLOS(Target)
  and not Buff.Has(Target, 53563) then
    return Spell.Cast(53563, Target)
  end
end

function PHBoF()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and BoF
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
  and Unit.PercentHealth(Target) <= BestowFaithHealth then
    return Spell.Cast(223306, Target)
  end
end

function PHInfusionProc()
  if Buff.Has(PlayerUnit, 53576) then
    if InfusionHL then
      PHHolyLight()
    elseif InfusionFoL then
      PHFlashOfLight()
    end
  end
end

function PHJudgment()
  if Judgment
  and PlayerTarget ~= nil
  and IsSpellKnown(183778)
  and Spell.CanCast(20271, PlayerTarget, 0, MaxMana * 0.03)
  and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(20271, PlayerTarget)
  end
end

function PHLightsHammerPos()
  return ObjectPosition(Unit.FindBestToHeal(10, LHUnits, LHHealth))
end

function PHLightsHammer()
  local x, y, z = PHLightsHammerPos()
  if x ~= nil and y ~= nil and z ~= nil
  and GetTotemInfo(1) == false
  and LightsHammer
  and Spell.CanCast(114158, nil, 0, MaxMana * 0.28) then
    return Spell.CastGroundSpell(114158, x, y, z)
  end
end

function PHLoD()
  if LightOfDawn
  and Spell.CanCast(85222, nil, 0, MaxMana * 0.14) then
    -- Rule of Law
    if Buff.Has(PlayerUnit, 214202)
    and (#Unit.GetUnitsInCone(PlayerUnit, ConeAngle, 22.5, "friendly", true, LoDHealth) >= LoDUnits) then
      return Spell.Cast(85222)
    -- Beacon of the Lightbringer
  elseif Player.HasTalent(7, 2)
    and (#Unit.GetUnitsInCone(PlayerUnit, ConeAngle, 19.5, "friendly", true, LoDHealth) >= LoDUnits) then
      return Spell.Cast(85222)
    -- Standard
  elseif (#Unit.GetUnitsInCone(PlayerUnit, ConeAngle, 15, "friendly", true, LoDHealth) >= LoDUnits) then
      return Spell.Cast(85222)
    end
  end
end

function PHHolyPrismTarget()
  local BestTarget        = nil
  local UnitCountBest     = 0
  local UnitCountCurrent  = 0
  local Units             = nil
  for Object, _ in pairs(UNIT_TRACKER) do
    if ObjectIsType(Object, ObjectTypes.Unit)
    and ObjectExists(Object)
    and Unit.IsInLOS(Object)
    and Unit.IsHostile(Object) then
      Units = Unit.GetUnitsInRadius(Object, 15, "friendly", true)
      UnitCountCurrent = #Units
      if UnitCountCurrent >= HolyPrismUnits
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
  local Target = Unit.FindBestToHeal(30, BoVUnits, BoVHealth)
  if Target ~= nil
  and BeaconOfVirtue
  and Spell.CanCast(200025, Target, 0, MaxMana * 0.1)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(200025, Target)
  end
end

function PHFlashOfLight()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Unit.PercentHealth(Target) <= FoLHealth
  and Spell.CanCast(82326, Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(82326, Target)
  end
end
