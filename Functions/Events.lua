local Unit = LibStub("Unit")

-- Improve this according to time based caching
UNIT_TRACKER = {}
TTD_TABLE = {}

function GetUnits()
  -- cache new units
  if UnitAffectingCombat("player")then
    for i = 1, GetObjectCount() do
      local Object = GetObjectWithIndex(i)
      if ObjectIsType(Object, ObjectTypes.Unit)
      and ObjectExists(Object)
      and Object ~= ObjectPointer("player")
      and not UNIT_TRACKER[Object]
      and (UnitAffectingCombat(Object) or Unit.IsDummy(Object)) then
        UNIT_TRACKER[Object] = GetTime()
        if TTD_TABLE[Object] == nil then
          TTD_TABLE[Object] = -1
        end
      end
    end

    -- update unit variables
    for Object, _ in pairs(UNIT_TRACKER) do
      local duration = GetTime() - UNIT_TRACKER[Object]
      local health = UnitHealth(Object)
      local diff = UnitHealthMax(Object) - health
      local dps = diff / duration
      local ttd = health / dps
      if ttd ~= math.huge and ttd >= 1 then
        TTD_TABLE[Object] = ttd
      end
    end
  end
  -- remove not existing units
  for Object,_ in pairs(UNIT_TRACKER) do
    if not ObjectExists(Object)
    or UnitHealth(Object) <= 1 then
      UNIT_TRACKER[Object] = nil
      TTD_TABLE[Object] = nil
    end
  end
end
AddTimerCallback(0.1, GetUnits)
