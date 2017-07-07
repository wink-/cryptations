local Debuff = LibStub:NewLibrary("Debuff", 1)

-- given an unit and debuffID, produces true if unit has debuff
-- second return argument is the debuff count as a value (e.g. 2 stacks would give 2)
-- third return argument is the remaining buff time
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the buff from the player
function Debuff.Has(unit, debuffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  local DebuffCount = Debuff.GetCount(unit)

  -- iterate over unit's auras
  for i = 1, DebuffCount do
    if select(11, UnitDebuff(unit, i)) == debuffID then
      if onlyPlayer == true and select(8, UnitDebuff(unit, i)) == "player"
      or onlyPlayer == false or onlyPlayer == nil then
        local DebuffStacks = select(4, UnitDebuff(unit, i))
        local RemainingTime = select(7, UnitDebuff(unit, i)) - GetTime()
        return true, DebuffStacks, RemainingTime
      end
    end
  end

  return false
end

-- returns number of how many debuffs the given unit has
function Debuff.GetCount(unit)
  if unit == nil then
    return nil
  end

  local DebuffIndex = 1
  local DebuffCount = 0

  while (select(1, UnitDebuff(unit, DebuffIndex))) do
    DebuffIndex = DebuffIndex + 1
    DebuffCount = DebuffCount + 1
  end

  return DebuffCount
end

-- returns table containing every unit that has the given debuff
-- onlyPlayer (optional): if this is checked, only units that got the buff from the player will be returned
function Debuff.FindUnitsWith(debuffID, onlyPlayer)
  local ObjectCount = GetObjectCount()
  local Object = nil
  local Units = {}
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and Debuff.Has(Object, debuffID, onlyPlayer) then
      table.insert(Units, Object)
    end
  end
  return Units
end
