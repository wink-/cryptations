local Debuff = LibStub("Debuff")

local MAXITERATIONS = 50

-- given an unit and a DebuffID, produces true if unit has Debuff
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the Debuff from the player
function Debuff.Has(unit, debuffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  -- iterate over unit's auras
  for i = 1, MAXITERATIONS do
    local Name, _, _, _, _, _, _, Caster, _, _, ID = UnitDebuff(unit, i)
    if ID == debuffID then
      if (onlyPlayer ~= true or Caster == "player") then
        return true
      end
    end
  end

  return false
end

-- returns number of how many applications of the given Debuff the given unit has
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the Debuff from the player
function Debuff.GetCount(unit, debuffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  local DebuffCount = 0

  for i = 1, MAXITERATIONS do
    local Name, _, _, _, _, _, _, Caster, _, _, ID = UnitDebuff(unit, i)
    if ID == debuffID
    and (onlyPlayer ~= true or Caster == "player") then
      DebuffCount = DebuffCount + 1
    end
  end

  return DebuffCount
end

-- returns the initial duration of the given debuff on the given unit
-- returns 0 if no debuff was found with the given parameters
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the debuff from the player
function Debuff.Duration(unit, debuffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  for i = 1, MAXITERATIONS do
    local _, _, _, _, _, Duration, _, Caster, _, _, ID = UnitDebuff(unit, i)
    if ID == debuffID
    and (onlyPlayer ~= true or Caster == 'player') then
      return Duration
    end
  end

  return 0
end

-- returns true when the given debuff on the given unit is refreshable (remaining duration <= duration * 0.3)
function Debuff.Refreshable(unit, debuffID)
  local Duration  = Debuff.Duration(unit, debuffID, true)
  local Remaining = Debuff.RemainingTime(unit, debuffID, true)

  return Remaining <= Duration * 0.3
end

-- returns the remaining time of the given Debuff on the given unit
-- returns 0 if no Debuff was found with the given parameters
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the Debuff from the player
function Debuff.RemainingTime(unit, debuffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  for i = 1, MAXITERATIONS do
    local Name, _, _, _, _, _, Expires, Caster, _, _, ID = UnitDebuff(unit, i)
    if ID == debuffID
    and (onlyPlayer ~= true or Caster == "player") then
      return Expires - GetTime()
    end
  end

  return 0
end

-- returns how many stacks the given unit has of the given Debuff
-- returns 0 if no Debuff was found with the given parameters
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the Debuff from the player
function Debuff.Stacks(unit, debuffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  for i = 1, MAXITERATIONS do
    local Name, _, _, Stacks, _, _, _, Caster, _, _, ID = UnitDebuff(unit, i)
    if ID == debuffID
    and (onlyPlayer ~= true or Caster == "player") then
      return Stacks
    end
  end

  return 0
end

-- returns table containing every unit that has the given Debuff
-- onlyPlayer (optional): if this is checked, only units that got the Debuff from the player will be returned
-- onlyFriends (optional): if this is set to true, only units from GROUP_MEMBERS will be checked
function Debuff.FindUnitsWith(debuffID, onlyPlayer, onlyFriends)
  local Units = {}

  -- for enemy units
  if onlyFriends ~= true then
    for Object, _ in pairs(UNIT_TRACKER) do
      if Debuff.Has(Object, debuffID, onlyPlayer) then
        table.insert(Units, Object)
      end
    end
  end

  -- for group units
  for i = 1, #GROUP_MEMBERS do
    if Debuff.Has(GROUP_MEMBERS[i], debuffID, onlyPlayer) then
      table.insert(Units, GROUP_MEMBERS[i])
    end
  end

  return Units
end
