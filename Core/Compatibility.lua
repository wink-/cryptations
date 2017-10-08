-- This file will contain functions and aliases that are only available
-- to certain unlockers, making more unlockers compatible

function PlayerTarget()
  return ObjectPointer("target")
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
