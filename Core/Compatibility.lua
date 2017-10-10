-- This file will contain functions and aliases that are only available
-- to certain unlockers, making more unlockers compatible

function PlayerTarget()
  if UnitGUID("target") ~= nil then
    return ObjectPointer("target")
  end

  return nil
end

function GetObjectsOfType(ObjectType)
  local ObjectsOfType = {}
  for i = 1, GetObjectCount() do
    local Object = GetObjectWithIndex(i)
    if ObjectIsType(Object, ObjectType) then
      table.insert(ObjectsOfType, Object)
    end
  end

  return ObjectsOfType
end
