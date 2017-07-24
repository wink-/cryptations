local Unit = LibStub("Unit")

ValidUnits = {}
function GetUnits()
  table.wipe(ValidUnits)
  if UnitAffectingCombat("player") or true then
    for i = 1, GetObjectCount() do
      local Object = GetObjectWithIndex(i)
      if ObjectIsType(Object, ObjectTypes.Unit)
      and ObjectExists(Object)
      and Object ~= ObjectPointer("player")
      and (UnitAffectingCombat(Object) or Unit.IsDummy(Object)) then
        table.insert(ValidUnits, Object)
      end
    end
  end
end
AddTimerCallback(0.1, GetUnits)
