local Buff = LibStub:NewLibrary("Buff", 1)

-- given an unit and a buffID, produces true if unit has Buff
-- second return argument is the buff count as a value (e.g. 2 stacks would give 2)
function Buff.Has(unit, buffID)
  if unit == nil then
    return nil
  end

  local BuffCount = Buff.GetCount(unit)

  -- iterate over unit's auras
  for i = 1, BuffCount do
    if select(11, UnitBuff(unit, i)) == buffID then
      local BuffStacks = select(4, UnitBuff(unit, i))
      return true, BuffStacks
    end
  end
  return false
end

-- returns number of how many buffs the given unit has
function Buff.GetCount(unit)
  if unit == nil then
    return nil
  end

  local BuffIndex = 1
  local BuffCount = 0

  while (select(1, UnitBuff(unit, BuffIndex))) do
    BuffIndex = BuffIndex + 1
    BuffCount = BuffCount + 1
  end
  return BuffCount
end

-- returns table containing every unit that has the given buff
function Buff.FindUnitsWith(buffID)
  local ObjectCount = GetObjectCount()
  local Object = nil
  local Units = {}
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and Buff.Has(Object, buffID) then
      table.insert(Units, Object)
    end
  end
  return Units
end
