local Buff = LibStub:NewLibrary("Buff", 1)

-- given an unit and a buffID, produces true if unit has Buff
-- second return argument is the buff count as a value (e.g. 2 stacks would give 2)
-- third return argument is the remaining buff time
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the buff from the player
function Buff.Has(unit, buffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  local BuffCount = Buff.GetCount(unit)

  -- iterate over unit's auras
  for i = 1, BuffCount do
    if select(11, UnitBuff(unit, i)) == buffID then
      if onlyPlayer == true and select(8, UnitBuff(unit, i)) == "player"
      or onlyPlayer == false or onlyPlayer == nil then
        local BuffStacks = select(4, UnitBuff(unit, i))
        local RemainingTime = select(7, UnitBuff(unit, i)) - GetTime()
        return true, BuffStacks, RemainingTime
      end
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
-- onlyPlayer (optional): if this is checked, only units that got the buff from the player will be returned
function Buff.FindUnitsWith(buffID, onlyPlayer)
  local ObjectCount = GetObjectCount()
  local Object = nil
  local Units = {}
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and Buff.Has(Object, buffID, onlyPlayer) then
      table.insert(Units, Object)
    end
  end
  return Units
end
