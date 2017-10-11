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
  if Debug then print("Updating Tanks ...") end
  table.wipe(GROUP_TANKS)

  local Units = GetObjectsOfType(ObjectTypes.Unit)
  for i = 1, #Units do
    local Object = Units[i]
    if ObjectExists(Object)
    and (UnitInParty(Object) or UnitInRaid(Object))
    and (UnitGroupRolesAssigned(Object) == "TANK" or ObjectID(Object) == 72218) then -- ObjectID refers to Oto the Protector
      table.insert(GROUP_TANKS, Object)
    end
  end
end

-- updates the group members table
function Group.UpdateMembers()
  if Debug then print("Updating Group Members ...") end
  table.wipe(GROUP_MEMBERS)

  local Units = GetObjectsOfType(ObjectTypes.Unit)
  for i = 1, #Units do
    local Object = Units[i]
    if ObjectExists(Object)
    and (UnitInRaid(Object) or UnitInParty(Object)) then
      table.insert(GROUP_MEMBERS, Object)
    end
  end
end

-- returns the percentage of the average group health
function Group.AverageHealth()
  local Health = 0
  local Count  = 0
  for i = 1, #GROUP_MEMBERS do
    Health = Health + Unit.PercentHealth(GROUP_MEMBERS[i])
    Count = Count + 1
  end

  return Health / Count
end

-- returns the percentage of the average health of the given units
function Group.AverageHealthCustom(units)
  local Health = 0
  local Count   = 0
  for i = 1, #units do
    Health = Health + Unit.PercentHealth(units[i])
    Count = Count + 1
  end

  return Health / Count
end

-- updates the heal priority list
local NextGroupRefresh = GetTime()
function Group.HealPriority()
  if NextGroupRefresh > GetTime() then return end

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
