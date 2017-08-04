local Buff = LibStub("Buff")

local MAXITERATIONS = 50

-- given an unit and a buffID, produces true if unit has Buff
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the buff from the player
function Buff.Has(unit, buffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  -- iterate over unit's auras
  for i = 1, MAXITERATIONS do
    local Name, _, _, _, _, _, _, Caster, _, _, ID = UnitBuff(unit, i)
    if ID == buffID then
      if (onlyPlayer ~= true or Caster == "player") then
        return true
      end
    end
  end

  return false
end

-- returns number of how many applications of the given buff the given unit has
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the buff from the player
function Buff.GetCount(unit, buffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  local BuffCount = 0

  for i = 1, MAXITERATIONS do
    local Name, _, _, _, _, _, _, Caster, _, _, ID = UnitBuff(unit, i)
    if ID == buffID
    and (onlyPlayer ~= true or Caster == "player") then
      BuffCount = BuffCount + 1
    end
  end

  return BuffCount
end

-- returns the remaining time of the given buff on the given unit
-- returns 0 if no buff was found with the given parameters
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the buff from the player
function Buff.RemainingTime(unit, buffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  for i = 1, MAXITERATIONS do
    local Name, _, _, _, _, _, Expires, Caster, _, _, ID = UnitBuff(unit, i)
    if ID == buffID
    and (onlyPlayer ~= true or Caster == "player") then
      return Expires - GetTime()
    end
  end

  return 0
end

-- returns how many stacks the given unit has of the given buff
-- returns 0 if no buff was found with the given parameters
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the buff from the player
function Buff.Stacks(unit, buffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  for i = 1, MAXITERATIONS do
    local Name, _, _, Stacks, _, _, _, Caster, _, _, ID = UnitBuff(unit, i)
    if ID == buffID
    and (onlyPlayer ~= true or Caster == "player") then
      return Stacks
    end
  end

  return 0
end

-- returns table containing every unit that has the given buff
-- onlyPlayer (optional): if this is set to true, only units that got the buff from the player will be returned
-- onlyFriends (optional): if this is set to true, only units from GROUP_MEMBERS will be checked
function Buff.FindUnitsWith(buffID, onlyPlayer, onlyFriends)
  local Units = {}

  -- for enemy units
  if onlyFriends ~= true then
    for Object, _ in pairs(UNIT_TRACKER) do
      if Buff.Has(Object, buffID, onlyPlayer) then
        table.insert(Units, Object)
      end
    end
  end

  -- for group units
  for i = 1, #GROUP_MEMBERS do
    if Buff.Has(GROUP_MEMBERS[i], buffID, onlyPlayer) then
      table.insert(Units, GROUP_MEMBERS[i])
    end
  end

  return Units
end
