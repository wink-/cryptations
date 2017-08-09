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

function PHLoDRange()
  local Range = 15

  if Player.HasTalent(7, 2) then
    Range = Range * 1.3
  end
  if Spell.CanCast(SB["Rule of Law"])
  or Buff.Has(PlayerUnit, AB["Rule of Law"]) then
    Range = Range * 1.5
  end

  return Range
end

function PHAvengingWrath()
  if AvengingWrath
  and Spell.CanCast(SB["Avenging Wrath"])
  and GetNumGroupMembers() > 1
  and Group.AverageHealth() <= AWHealth then
    return Spell.Cast(SB["Avenging Wrath"])
  end
end

function PHHolyAvenger()
  if HolyAvenger
  and Spell.CanCast(SB["Holy Avenger"])
  and GetNumGroupMembers() > 1
  and Group.AverageHealth() <= HAHealth then
    return Spell.Cast(SB["Holy Avenger"])
  end
end

function PHLayOnHands()
  local Target = Group.UnitToHeal()

  if Target ~= nil
  and LayOnHands
  and Spell.CanCast(SB["Lay on Hands"], Target)
  and Unit.PercentHealth(Target) <= LoHHealth then
    return Spell.Cast(SB["Lay on Hands"], Target)
  end
end

function PHBoS()
  local Target = Group.UnitToHeal()

  if Target ~= nil
  and BoS
  and Spell.CanCast(SB["Blessing of Sacrifice"], Target)
  and Spell.CanCast(SB["Divine Protection"])
  and not Buff.Has(Target, SB["Blessing of Sacrifice"])
  and Unit.PercentHealth(Target) <= BoSHealth then
    local Sequence = {
      SB["Divine Protection"],
      SB["Blessing of Sacrifice"]
    }
    return Spell.AddToQueue(Sequence, Target)
  end
end

function PHTyrsDeliverance()
  local TargetUnits = Unit.GetUnitsInRadius(PlayerUnit, 15, "friendly")

  if TyrsDeliverance
  and Spell.CanCast(SB["Tyr's Deliverance"]) then
    if GetNumGroupMembers() ~= 1
    and #TargetUnits >= TDUnits
    and Group.AverageHealthCustom(TargetUnits) <= TDHealth then
      return Spell.Cast(SB["Tyr's Deliverance"])
    end
  end
end

function PHHolyShock()
  local Target = Group.UnitToHeal()

  if Target ~= nil
  and ((not Buff.Has(Target, AB["Beacon of Faith"], true)
  and not Buff.Has(Target, AB["Beacon of Light"], true))
  or Unit.PercentHealth(Target) <= 60) -- TODO: add setting
  and Unit.PercentHealth(Target) <= HSHealth
  and Spell.CanCast(SB["Holy Shock"], Target, 0, MaxMana * 0.1)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Holy Shock"], Target)
  end
end

function PHHolyLight()
  local Target = Group.UnitToHeal()

  if Target ~= nil
  and ((not Buff.Has(Target, AB["Beacon of Faith"], true)
  and not Buff.Has(Target, AB["Beacon of Light"], true))
  or Unit.PercentHealth(Target) <= 60)
  and Unit.PercentHealth(Target) <= HLHealth
  and Spell.CanCast(SB["Holy Light"], Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Holy Light"], Target)
  end
end

function PHLotM()
  local Target = Group.UnitToHeal()

  if Target ~= nil
  and LotM
  and Unit.IsMoving(PlayerUnit)
  and not Spell.CanCast(SB["Holy Shock"], Target, 0, MaxMana * 0.1)
  and Spell.CanCast(SB["Light of the Martyr"], Target, 0, MaxMana * 0.075)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Light of the Martyr"], Target)
  end
end

function PHRuleOfLaw()
  if RuleOfLaw
  and Spell.CanCast(SB["Rule of Law"]) then
    return Spell.Cast(SB["Rule of Law"])
  end
end

function PHBeaconTarget()
  for i = 1, #GROUP_TANKS do
    local Unit = GROUP_TANKS[i]
    if not Buff.Has(Unit, AB["Beacon of Faith"], true)
    and not Buff.Has(Unit, AB["Beacon of Light"], true) then
      return Unit
    end
  end

  return nil
end

function PHBoL()
  local Target = PHBeaconTarget()

  if Target ~= nil
  and BoL
  and Player.HasTalent(7, 1)
  and Spell.CanCast(SB["Beacon of Light"], Target, 0, MaxMana * 0.025)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Beacon of Light"], Target)
  end
end

function PHBoF()
  local Target = PHBeaconTarget()

  if Target ~= nil
  and BoF
  and Spell.CanCast(SB["Beacon of Faith"], Target, 0, MaxMana * 0.03125)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Beacon of Faith"], Target)
  end
end

-- TODO:
-- 80-85 on tank,
-- 75-70 on group member when tanks don't need it
function PHBestowFaith()
  local Target = Group.TankToHeal()

  if Target ~= nil
  and Spell.CanCast(SB["Bestow Faith"], Target, 0, MaxMana * 0.06)
  and Unit.IsInLOS(Target)
  and not Buff.Has(Target, AB["Bestow Faith"])
  and Unit.PercentHealth(Target) <= BestowFaithHealth then
    return Spell.Cast(SB["Bestow Faith"], Target)
  end
end

function PHInfusionProc()
  local Target = Group.UnitToHeal()

  if Buff.Has(PlayerUnit, AB["Infusion of Light"]) then
    if Unit.PercentHealth(Target) <= 60 then -- TODO
      PHFoLInfusion(Target)
    else
      PHHLInfusion(Target)
    end
  end
end

function PHJudgment()
  local Target = PlayerTarget()

  if Judgment
  and Target ~= nil
  and IsSpellKnown(183778) -- TODO: change to Player.HasTalent()
  and Spell.CanCast(SB["Judgment Holy"], Target, 0, MaxMana * 0.03)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Judgment Holy"], Target)
  end
end

function PHLightsHammerPos()
  return ObjectPosition(Unit.FindBestToHeal(10, LHUnits, LHHealth, 40))
end

function PHLightsHammer()
  local x, y, z = PHLightsHammerPos()

  if x ~= nil and y ~= nil and z ~= nil
  and GetTotemInfo(1) == false
  and LightsHammer
  and Spell.CanCast(SB["Light's Hammer"], nil, 0, MaxMana * 0.28) then
    return Spell.CastGroundSpell(SB["Light's Hammer"], x, y, z)
  end
end

function PHLoD()
  local LoDRange = PHLoDRange()

  if LightOfDawn
  and Spell.CanCast(SB["Light of Dawn"], nil, 0, MaxMana * 0.14)
  and #Unit.GetUnitsInCone(PlayerUnit, ConeAngle, LoDRange, "friendly", true, LoDHealth) >= LoDUnits then
    PHRuleOfLaw()
    return Spell.Cast(SB["Light of Dawn"])
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
  and Spell.CanCast(SB["Holy Prism"], Target, 0, MaxMana * 0.17) then
    return Spell.Cast(SB["Holy Prism"], Target)
  end
end

function PHBoV()
  local Target = Unit.FindBestToHeal(30, BoVUnits, BoVHealth, 40)

  if Target ~= nil
  and BoV
  and Spell.CanCast(SB["Beacon of Virtue"], Target, 0, MaxMana * 0.1, false)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Beacon of Virtue"], Target)
  end
end

function PHFlashOfLight()
  local Target = Group.UnitToHeal()

  if Target ~= nil
  and ((not Buff.Has(Target, AB["Beacon of Faith"], true)
  and not Buff.Has(Target, AB["Beacon of Light"], true))
  or Unit.PercentHealth(Target) <= 60) -- TODO: add setting
  and Unit.PercentHealth(Target) <= FoLHealth
  and Spell.CanCast(SB["Flash of Light"], Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Flash of Light"], Target)
  end
end

function PHHLInfusion(Target)
  if Target ~= nil
  and Spell.CanCast(SB["Holy Light"], Target)
  and Unit.IsInLOS(Target) then
    return Spell.AddToQueue(SB["Holy Light"], Target)
  end
end

function PHFoLInfusion(Target)
  if Target ~= nil
  and Spell.CanCast(SB["Flash of Light"], Target)
  and Unit.IsInLOS(Target) then
    return Spell.AddToQueue(SB["Flash of Light"], Target)
  end
end
