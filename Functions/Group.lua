local Group   = LibStub("Group")
local Spell   = LibStub("Spell")
local Unit    = LibStub("Unit")
local Debuff  = LibStub("Debuff")

GROUP_MEMBERS = {}
GROUP_TANKS   = {}

local RefreshRate = 0.5
local Lowest      = nil
local LowestTank  = nil

-- updates the tanks table
function Group.UpdateTanks()
  table.wipe(GROUP_TANKS)

  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and (UnitInParty(Object) or UnitInRaid(Object))
    and (UnitGroupRolesAssigned(Object) == "TANK" or ObjectID(Object) == 72218) then
      table.insert(GROUP_TANKS, Object)
    end
  end
end

-- updates the group members table
function Group.UpdateMembers()
  table.wipe(GROUP_MEMBERS)

  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and (UnitInRaid(Object) or UnitInParty(Object)) then
      table.insert(GROUP_MEMBERS, Object)
    end
  end
end

-- returns the percentage of the average group health
function Group.AverageHealth()
  local Health = 0
  local Count  = 0
  for i = 1, getn(GROUP_MEMBERS) do
    Health = Health + Unit.PercentHealth(GROUP_MEMBERS[i])
    Count = Count + 1
  end

  return Health / Count
end

-- returns the percentage of the average health of the given units
function Group.AverageHealthCustom(units)
  local Health = 0
  local Count   = 0
  for i = 1, getn(units) do
    Health = Health + Unit.PercentHealth(units[i])
    Count = Count + 1
  end

  return Health / Count
end

-- updates the heal priority list
function Group.HealPriority()
  if NextGroupRefresh ~= nil and NextGroupRefresh > GetTime() then return end

  -- function for sorting heal priority list
  function compare(a, b)
    return Unit.PercentHealth(a) < Unit.PercentHealth(b)
  end

  table.sort(GROUP_MEMBERS, compare)
  table.sort(GROUP_TANKS, compare)
  Lowest = GROUP_MEMBERS[1]
  LowestTank = GROUP_TANKS[1]
  NextGroupRefresh = GetTime() + RefreshRate
end

-- Calls the update function and then returns the lowest unit
function Group.UnitToHeal()
  Group.HealPriority()
  return Lowest
end

-- Calls the update function and then returns the lowest tank
function Group.TankToHeal()
  Group.HealPriority()
  return LowestTank
end

-- returns table with group that is the best to heal for an aoe heal spell
-- TODO: add max distance from player
function Group.FindBestToHeal(radius, minUnits, health)
  local CurrentUnits      = {}
  local BestUnits         = {}
  local LowestHealthAvg   = 100
  local CurrentHealthAvg  = 100
  for i = 1, #GROUP_MEMBERS do
    CurrentUnits = Unit.GetUnitsBelowHealth(health, "friendly", true, GROUP_MEMBERS[i], radius)
    table.insert(CurrentUnits, GROUP_MEMBERS[i])
    CurrentHealthAvg = Group.AverageHealthCustom(CurrentUnits)
    if #CurrentUnits >= minUnits
    and #CurrentUnits > #BestUnits
    and CurrentHealthAvg < LowestHealthAvg then
      LowestHealthAvg = CurrentHealthAvg
      BestUnits = CurrentUnits
    end
  end

  if #BestUnits >= minUnits then
    return BestUnits
  end

  return nil
end

-- returns table with unit group that is the best to cast an aoe spell on
-- TODO: add max distance from player
function Group.FindBestToAOE(radius, minUnits)
  local BestUnits         = {}
  for Object, _ in pairs(UNIT_TRACKER) do
    local CurrentUnits  = {}
    if ObjectIsType(Object, ObjectTypes.Unit)
    and Unit.IsHostile(Object)
    and (UnitAffectingCombat(Object) or Unit.IsDummy(Object))
    and ObjectExists(Object)
    and Unit.IsInLOS(Object) then
      CurrentUnits = Unit.GetUnitsInRadius(Object, radius, "hostile", true)
      table.insert(CurrentUnits, Object)
      if #CurrentUnits >= minUnits
      and #CurrentUnits > #BestUnits then
        BestUnits = CurrentUnits
      end
    end
  end

  if #BestUnits >= minUnits then
    return BestUnits
  end

  return nil
end

-- this returns the first unit to DoT according to the given parameters
-- spellID is used to check if the unit is in attack range
-- count: units to keep the buff up on
function Group.FindDoTTarget(spellID, debuffID, count)
  -- first check if the player's current target is suitable for a dot
  if PlayerTarget ~= nil
  and getn(Debuff.FindUnitsWith(debuffID, true)) <= count
  and Unit.IsHostile(PlayerTarget)
  and (UnitAffectingCombat(PlayerTarget) or Unit.IsDummy(PlayerTarget))
  and Unit.IsInAttackRange(spellID, PlayerTarget)
  and not Debuff.Has(PlayerTarget, debuffID) then
    return PlayerTarget
  end

  -- check if any other unit is suitable for a dot
  for Object, _ in pairs(UNIT_TRACKER) do
    if ObjectIsType(Object, ObjectTypes.Unit)
    and ObjectExists(Object)
    and Unit.IsHostile(Object)
    and (UnitAffectingCombat(Object) or Unit.IsDummy(Object))
    and Unit.IsInLOS(Object)
    and Unit.IsInAttackRange(spellID, Object)
    and getn(Debuff.FindUnitsWith(debuffID, true)) <= count
    and not Debuff.Has(Object, debuffID) then
      return Object
    end
  end

  return nil
end
