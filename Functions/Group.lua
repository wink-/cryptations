local Group = LibStub:NewLibrary("Group", 1)
local Spell = LibStub("Spell")
local Unit  = LibStub("Unit")

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

function Group.TankToHeal()
  Group.HealPriority()
  return LowestTank
end
